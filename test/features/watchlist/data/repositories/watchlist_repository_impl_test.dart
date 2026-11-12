import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/data/repositories/watchlist_repository_impl.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistLocalDataSource extends Mock
    implements WatchlistLocalDataSource {}

void main() {
  late MockWatchlistLocalDataSource dataSource;
  late WatchlistRepositoryImpl repository;

  final model1 = MovieModel.fromEntity(tMovie1);
  final model2 = MovieModel.fromEntity(tMovie2);

  setUpAll(() => registerFallbackValue(model1));

  setUp(() {
    dataSource = MockWatchlistLocalDataSource();
    repository = WatchlistRepositoryImpl(dataSource);
  });

  group('getAll', () {
    test('returns the saved movies as entities', () async {
      when(() => dataSource.getAll()).thenReturn([model2, model1]);

      expect(await repository.getAll(), const Success([tMovie2, tMovie1]));
    });

    test('returns CacheFailure when the data source throws', () async {
      when(() => dataSource.getAll()).thenThrow(const CacheException());

      expect(await repository.getAll(), const Err<List<Movie>>(CacheFailure()));
    });
  });

  group('isInWatchlist', () {
    test('returns what the data source says', () async {
      when(() => dataSource.contains(1)).thenReturn(true);

      expect(await repository.isInWatchlist(1), const Success(true));
    });

    test('returns CacheFailure when the data source throws', () async {
      when(() => dataSource.contains(1)).thenThrow(const CacheException());

      expect(
        await repository.isInWatchlist(1),
        const Err<bool>(CacheFailure()),
      );
    });
  });

  group('toggle', () {
    test('adds a movie that is not saved and returns true', () async {
      when(() => dataSource.contains(tMovie1.id)).thenReturn(false);
      when(() => dataSource.add(any())).thenAnswer((_) async {});

      expect(await repository.toggle(tMovie1), const Success(true));

      final saved =
          verify(() => dataSource.add(captureAny())).captured.single
              as MovieModel;
      expect(saved.toEntity(), tMovie1);
      verifyNever(() => dataSource.remove(any()));
    });

    test('removes a saved movie and returns false', () async {
      when(() => dataSource.contains(tMovie1.id)).thenReturn(true);
      when(() => dataSource.remove(tMovie1.id)).thenAnswer((_) async {});

      expect(await repository.toggle(tMovie1), const Success(false));
      verify(() => dataSource.remove(tMovie1.id)).called(1);
      verifyNever(() => dataSource.add(any()));
    });

    test('returns CacheFailure when saving fails', () async {
      when(() => dataSource.contains(tMovie1.id)).thenReturn(false);
      when(
        () => dataSource.add(any()),
      ).thenThrow(const CacheException('disk full'));

      expect(await repository.toggle(tMovie1), const Err<bool>(CacheFailure()));
    });
  });

  group('watch', () {
    late StreamController<void> changes;

    setUp(() {
      changes = StreamController<void>();
      when(() => dataSource.changes()).thenAnswer((_) => changes.stream);
    });

    tearDown(() => changes.close());

    test('emits the current list, then again after each change', () async {
      var stored = [model1];
      when(() => dataSource.getAll()).thenAnswer((_) => stored);

      final emitted = <Object>[];
      final subscription = repository.watch().listen(emitted.add);
      await pumpEventQueue();
      expect(emitted, [
        [tMovie1],
      ]);

      stored = [model2, model1];
      changes.add(null);
      await pumpEventQueue();
      expect(emitted, [
        [tMovie1],
        [tMovie2, tMovie1],
      ]);

      // Cancelling stops listening to the box (and does not hang).
      await subscription.cancel();
      expect(changes.hasListener, isFalse);
    });

    test('emits a CacheFailure error and keeps going', () async {
      when(() => dataSource.getAll()).thenThrow(const CacheException());

      final errors = <Object>[];
      final data = <List<Object>>[];
      final subscription = repository.watch().listen(
        data.add,
        onError: errors.add,
      );
      await pumpEventQueue();
      expect(errors, [const CacheFailure()]);

      when(() => dataSource.getAll()).thenReturn([model1]);
      changes.add(null);
      await pumpEventQueue();
      expect(data, [
        [tMovie1],
      ]);

      await subscription.cancel();
    });
  });
}
