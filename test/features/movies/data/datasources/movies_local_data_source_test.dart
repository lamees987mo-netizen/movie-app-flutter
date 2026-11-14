import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_data_source.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

import '../../../../fixtures/fixture_reader.dart';

/// Uses a real Hive box in a temporary folder, so the storage format is
/// really tested (including reading it back after the box is reopened).
void main() {
  const boxName = 'home_cache_test';
  final page = MoviesPageModel.fromJson(jsonFixture('movies_page.json'));
  final details = MovieDetailsModel.fromJson(jsonFixture('movie_details.json'));

  late Directory tempDir;
  late Box<dynamic> box;
  late MoviesLocalDataSourceImpl dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('home_cache_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>(boxName);
    dataSource = MoviesLocalDataSourceImpl(box);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('returns null when nothing was saved', () {
    expect(dataSource.getCachedFirstPage(MovieCategory.trending, 'en'), isNull);
  });

  test('reads back a saved page, also after reopening the box', () async {
    await dataSource.cacheFirstPage(MovieCategory.trending, 'en', page);
    await box.close();
    box = await Hive.openBox<dynamic>(boxName);
    dataSource = MoviesLocalDataSourceImpl(box);

    final cached = dataSource.getCachedFirstPage(MovieCategory.trending, 'en');

    expect(cached?.toEntity(), page.toEntity());
  });

  test('keeps each category and language apart', () async {
    await dataSource.cacheFirstPage(MovieCategory.trending, 'ar', page);

    expect(dataSource.getCachedFirstPage(MovieCategory.trending, 'en'), isNull);
    expect(dataSource.getCachedFirstPage(MovieCategory.upcoming, 'ar'), isNull);
    expect(
      dataSource.getCachedFirstPage(MovieCategory.trending, 'ar'),
      isNotNull,
    );
  });

  test('throws CacheException for a corrupted entry', () async {
    await box.put('trending_en', 'not json');

    expect(
      () => dataSource.getCachedFirstPage(MovieCategory.trending, 'en'),
      throwsA(isA<CacheException>()),
    );
  });

  group('movie details', () {
    test('returns null when this movie was never saved', () {
      expect(dataSource.getCachedMovieDetails(details.id, 'en'), isNull);
    });

    test('reads back everything, also after reopening the box', () async {
      await dataSource.cacheMovieDetails('en', details);
      await box.close();
      box = await Hive.openBox<dynamic>(boxName);
      dataSource = MoviesLocalDataSourceImpl(box);

      final cached = dataSource.getCachedMovieDetails(details.id, 'en');

      // Cast and trailer are nested in the TMDB JSON (`credits.cast`,
      // `videos.results`), so this also checks they survive the round trip.
      expect(cached?.toEntity(), details.toEntity());
      expect(cached?.toEntity().cast, isNotEmpty);
      expect(cached?.toEntity().trailerYoutubeKey, isNotNull);
    });

    test('keeps each language apart', () async {
      await dataSource.cacheMovieDetails('ar', details);

      expect(dataSource.getCachedMovieDetails(details.id, 'en'), isNull);
      expect(dataSource.getCachedMovieDetails(details.id, 'ar'), isNotNull);
      expect(box.containsKey('details_${details.id}_ar'), isTrue);
    });

    test('throws CacheException for a corrupted entry', () async {
      await box.put('details_${details.id}_en', 42);

      expect(
        () => dataSource.getCachedMovieDetails(details.id, 'en'),
        throwsA(isA<CacheException>()),
      );
    });
  });
}
