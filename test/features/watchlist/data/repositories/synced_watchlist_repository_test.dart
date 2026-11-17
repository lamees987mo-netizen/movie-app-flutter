import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/repositories/synced_watchlist_repository.dart';
import 'package:movie_app/features/watchlist/data/sync/watchlist_sync_service.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

class MockSyncService extends Mock implements WatchlistSyncService {}

void main() {
  late MockWatchlistRepository local;
  late MockSyncService sync;
  late SyncedWatchlistRepository repository;

  setUpAll(() => registerFallbackValue(tMovie1));

  setUp(() {
    local = MockWatchlistRepository();
    sync = MockSyncService();
    repository = SyncedWatchlistRepository(local, sync);
    when(
      () => sync.pushChange(any(), saved: any(named: 'saved')),
    ).thenAnswer((_) async {});
  });

  test('reads come from the local repository', () async {
    when(
      () => local.getAll(),
    ).thenAnswer((_) async => const Success([tMovie1]));
    when(
      () => local.isInWatchlist(1),
    ).thenAnswer((_) async => const Success(true));
    when(() => local.watch()).thenAnswer((_) => Stream.value([tMovie1]));

    expect(await repository.getAll(), const Success([tMovie1]));
    expect(await repository.isInWatchlist(1), const Success(true));
    expect(await repository.watch().first, [tMovie1]);
    verifyZeroInteractions(sync);
  });

  test('a saved movie is also sent to the cloud', () async {
    when(
      () => local.toggle(tMovie1),
    ).thenAnswer((_) async => const Success(true));

    expect(await repository.toggle(tMovie1), const Success(true));
    verify(() => sync.pushChange(tMovie1, saved: true)).called(1);
  });

  test('a removed movie is also removed from the cloud', () async {
    when(
      () => local.toggle(tMovie1),
    ).thenAnswer((_) async => const Success(false));

    await repository.toggle(tMovie1);

    verify(() => sync.pushChange(tMovie1, saved: false)).called(1);
  });

  test('nothing is sent when the local save failed', () async {
    when(
      () => local.toggle(tMovie1),
    ).thenAnswer((_) async => const Err(CacheFailure()));

    expect(await repository.toggle(tMovie1), const Err<bool>(CacheFailure()));
    verifyNever(
      () => sync.pushChange(any<Movie>(), saved: any(named: 'saved')),
    );
  });
}
