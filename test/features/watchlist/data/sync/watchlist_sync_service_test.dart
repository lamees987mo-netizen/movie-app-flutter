import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';
import 'package:movie_app/features/watchlist/data/sync/watchlist_sync_service.dart';

import '../../../movies/movies_test_helpers.dart';

class MockLocal extends Mock implements WatchlistLocalDataSource {}

class MockRemote extends Mock implements WatchlistRemoteDataSource {}

void main() {
  late MockLocal local;
  late MockRemote remote;
  late WatchlistSyncService sync;

  final onlyLocal = SavedMovieModel(
    movie: MovieModel.fromEntity(tMovie1),
    addedAt: DateTime(2024),
  );
  final onlyRemote = SavedMovieModel(
    movie: MovieModel.fromEntity(tMovie2),
    addedAt: DateTime(2023),
  );
  final now = DateTime(2025, 5, 5);

  List<int> ids(List<SavedMovieModel> entries) =>
      entries.map((e) => e.movie.id).toList();

  setUpAll(() => registerFallbackValue(onlyLocal));

  setUp(() {
    local = MockLocal();
    remote = MockRemote();
    sync = WatchlistSyncService(
      local: local,
      remote: remote,
      clock: () => now,
      deleteTimeout: const Duration(milliseconds: 50),
    );
    when(() => local.getAllSaved()).thenReturn([onlyLocal]);
    when(() => local.putAll(any())).thenAnswer((_) async {});
    when(() => local.clear()).thenAnswer((_) async {});
    when(() => remote.getAll(any())).thenAnswer((_) async => [onlyRemote]);
    when(() => remote.putAll(any(), any())).thenAnswer((_) async {});
    when(() => remote.put(any(), any())).thenAnswer((_) async {});
    when(() => remote.remove(any(), any())).thenAnswer((_) async {});
    when(() => remote.removeAll(any())).thenAnswer((_) async {});
  });

  group('sign-in', () {
    test('downloads cloud-only movies and uploads phone-only ones', () async {
      await sync.onUserChanged('u1');

      expect(sync.userId, 'u1');
      final downloaded =
          verify(() => local.putAll(captureAny())).captured.single
              as List<SavedMovieModel>;
      expect(ids(downloaded), [tMovie2.id]);
      // The cloud date is kept.
      expect(downloaded.single.addedAt, DateTime(2023));
      final uploaded =
          verify(() => remote.putAll('u1', captureAny())).captured.single
              as List<SavedMovieModel>;
      expect(ids(uploaded), [tMovie1.id]);
      verifyNever(() => local.clear());
    });

    test('writes nothing when both lists already match', () async {
      when(() => remote.getAll(any())).thenAnswer((_) async => [onlyLocal]);

      await sync.onUserChanged('u1');

      verifyNever(() => local.putAll(any()));
      verifyNever(() => remote.putAll(any(), any()));
    });

    test('a failing download is logged, not thrown', () async {
      when(
        () => remote.getAll(any()),
      ).thenThrow(const NetworkException());

      await expectLater(sync.onUserChanged('u1'), completes);
      expect(sync.userId, 'u1');
      verifyNever(() => local.putAll(any()));
    });

    test('stops if the user signed out during the download', () async {
      final download = Completer<List<SavedMovieModel>>();
      when(() => remote.getAll(any())).thenAnswer((_) => download.future);

      final signIn = sync.onUserChanged('u1');
      await sync.onUserChanged(null);
      download.complete([onlyRemote]);
      await signIn;

      verifyNever(() => local.putAll(any()));
    });
  });

  group('sign-out', () {
    test('a guest opening the app clears nothing', () async {
      await sync.onUserChanged(null);

      verifyNever(() => local.clear());
      verifyNever(() => remote.getAll(any()));
    });

    test('clears the phone list after a user signs out', () async {
      await sync.onUserChanged('u1');
      await sync.onUserChanged(null);

      verify(() => local.clear()).called(1);
      expect(sync.userId, isNull);
    });

    test('switching accounts clears, then merges the new account', () async {
      await sync.onUserChanged('u1');
      await sync.onUserChanged('u2');

      verifyInOrder([
        () => local.clear(),
        () => remote.getAll('u2'),
      ]);
    });

    test('a failing clear is logged, not thrown', () async {
      when(() => local.clear()).thenThrow(const CacheException());
      await sync.onUserChanged('u1');

      await expectLater(sync.onUserChanged(null), completes);
    });
  });

  group('bind', () {
    test('follows the user stream (and ignores repeats)', () async {
      final users = StreamController<String?>();
      sync.bind(users.stream);

      users
        ..add(null)
        ..add('u1')
        ..add('u1')
        ..add(null);
      await pumpEventQueue();

      verify(() => remote.getAll('u1')).called(1);
      verify(() => local.clear()).called(1);
      await sync.dispose();
      await users.close();
    });
  });

  group('pushChange', () {
    test('does nothing for a guest', () async {
      await sync.pushChange(tMovie1, saved: true);

      verifyZeroInteractions(remote);
    });

    test('uploads a saved movie with the current time', () async {
      await sync.onUserChanged('u1');

      await sync.pushChange(tMovie1, saved: true);

      final entry =
          verify(() => remote.put('u1', captureAny())).captured.single
              as SavedMovieModel;
      expect(entry.movie.id, tMovie1.id);
      expect(entry.addedAt, now);
    });

    test('deletes a removed movie', () async {
      await sync.onUserChanged('u1');

      await sync.pushChange(tMovie1, saved: false);

      verify(() => remote.remove('u1', tMovie1.id)).called(1);
    });

    test('a Firestore error is logged, not thrown', () async {
      await sync.onUserChanged('u1');
      when(
        () => remote.put(any(), any()),
      ).thenThrow(const ServerException(message: 'permission-denied'));

      await expectLater(sync.pushChange(tMovie1, saved: true), completes);
    });
  });

  group('cloud data (delete account)', () {
    test('deleteCloudData removes every movie of the user', () async {
      expect(await sync.deleteCloudData('u1'), const Success<void>(null));
      verify(() => remote.removeAll('u1')).called(1);
    });

    test('offline: NetworkFailure', () async {
      when(
        () => remote.removeAll(any()),
      ).thenThrow(const NetworkException());

      expect(
        await sync.deleteCloudData('u1'),
        const Err<void>(NetworkFailure()),
      );
    });

    test('a write that never finishes times out as NetworkFailure', () async {
      when(
        () => remote.removeAll(any()),
      ).thenAnswer((_) => Completer<void>().future);

      expect(
        await sync.deleteCloudData('u1'),
        const Err<void>(NetworkFailure()),
      );
    });

    test('other errors: ServerFailure', () async {
      when(
        () => remote.removeAll(any()),
      ).thenThrow(const ServerException(message: 'permission-denied'));

      expect(
        await sync.deleteCloudData('u1'),
        const Err<void>(ServerFailure()),
      );
    });

    test('restoreCloudData uploads the phone list again', () async {
      await sync.restoreCloudData('u1');

      final uploaded =
          verify(() => remote.putAll('u1', captureAny())).captured.single
              as List<SavedMovieModel>;
      expect(ids(uploaded), [tMovie1.id]);
    });

    test('restoreCloudData never throws', () async {
      when(
        () => remote.putAll(any(), any()),
      ).thenThrow(const NetworkException());

      await expectLater(sync.restoreCloudData('u1'), completes);
    });
  });
}
