import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';

/// Uses a real Hive box in a temporary folder (no mocks), so the storage
/// format and the `Map<dynamic, dynamic>` conversion are really tested.
void main() {
  const boxName = 'watchlist_test';

  const dune = MovieModel(
    id: 693134,
    title: 'Dune: Part Two',
    overview: 'Spice.',
    voteAverage: 8.2,
    genreIds: [878, 12],
    posterPath: '/dune.jpg',
    releaseDate: '2024-02-27',
  );
  const insideOut = MovieModel(
    id: 1022789,
    title: 'Inside Out 2',
    overview: 'Emotions.',
    voteAverage: 7.6,
    genreIds: [16],
  );

  late Directory tempDir;
  late Box<dynamic> box;
  late WatchlistLocalDataSourceImpl dataSource;
  late DateTime now;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('watchlist_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>(boxName);
    now = DateTime(2024);
    dataSource = WatchlistLocalDataSourceImpl(box, clock: () => now);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('is empty at first', () {
    expect(dataSource.getAll(), isEmpty);
    expect(dataSource.contains(dune.id), isFalse);
  });

  test('add stores the movie JSON plus added_at under the movie id', () async {
    await dataSource.add(dune);

    expect(dataSource.contains(dune.id), isTrue);
    final stored = box.get(dune.id) as Map;
    expect(stored['title'], 'Dune: Part Two');
    expect(
      stored[WatchlistLocalDataSourceImpl.addedAtKey],
      now.millisecondsSinceEpoch,
    );
  });

  test('getAll returns the most recently added movie first', () async {
    await dataSource.add(dune);
    now = now.add(const Duration(minutes: 1));
    await dataSource.add(insideOut);

    expect(dataSource.getAll().map((m) => m.id), [insideOut.id, dune.id]);
  });

  test('reads entries back after the box is reopened', () async {
    await dataSource.add(dune);
    await box.close();

    // After reopening, Hive returns Map<dynamic, dynamic> values.
    box = await Hive.openBox<dynamic>(boxName);
    final movies = WatchlistLocalDataSourceImpl(box).getAll();

    expect(movies, hasLength(1));
    final movie = movies.single;
    expect(movie.id, dune.id);
    expect(movie.title, dune.title);
    expect(movie.voteAverage, dune.voteAverage);
    expect(movie.genreIds, dune.genreIds);
    expect(movie.posterPath, dune.posterPath);
    expect(movie.releaseDate, dune.releaseDate);
  });

  test('remove deletes the movie', () async {
    await dataSource.add(dune);
    await dataSource.remove(dune.id);

    expect(dataSource.contains(dune.id), isFalse);
    expect(dataSource.getAll(), isEmpty);
  });

  test('changes emits after every add and remove', () async {
    final events = <void>[];
    final subscription = dataSource.changes().listen(events.add);

    await dataSource.add(dune);
    await dataSource.remove(dune.id);
    await pumpEventQueue();

    expect(events, hasLength(2));
    await subscription.cancel();
  });

  test('getAll throws a CacheException for an unreadable entry', () async {
    await box.put(1, 'not a movie');

    expect(dataSource.getAll, throwsA(isA<CacheException>()));
  });

  test('add throws a CacheException when Hive fails', () async {
    await box.close();

    await expectLater(dataSource.add(dune), throwsA(isA<CacheException>()));
  });
}
