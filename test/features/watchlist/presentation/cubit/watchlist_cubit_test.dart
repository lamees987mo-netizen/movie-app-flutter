import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository repository;
  late StreamController<List<Movie>> watchlist;

  setUp(() {
    repository = MockWatchlistRepository();
    // Broadcast, so closing it in tearDown does not wait for a listener.
    watchlist = StreamController<List<Movie>>.broadcast();
    when(() => repository.watch()).thenAnswer((_) => watchlist.stream);
  });

  tearDown(() => watchlist.close());

  WatchlistCubit buildCubit() => WatchlistCubit(repository: repository);

  test('starts in the loading state', () {
    expect(buildCubit().state, const WatchlistLoading());
  });

  blocTest<WatchlistCubit, WatchlistState>(
    'emits Empty, then Loaded as the watchlist changes',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      watchlist.add([]);
      await pumpEventQueue();
      watchlist.add([tMovie1]);
      await pumpEventQueue();
      watchlist.add([tMovie2, tMovie1]);
    },
    expect: () => const [
      WatchlistLoading(),
      WatchlistEmpty(),
      WatchlistLoaded([tMovie1]),
      WatchlistLoaded([tMovie2, tMovie1]),
    ],
  );

  blocTest<WatchlistCubit, WatchlistState>(
    'emits Error when the repository reports a failure',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      watchlist.addError(const CacheFailure());
    },
    expect: () => const [WatchlistLoading(), WatchlistError(CacheFailure())],
  );

  blocTest<WatchlistCubit, WatchlistState>(
    'recovers when a later update arrives after an error',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      watchlist.addError(const CacheFailure());
      await pumpEventQueue();
      watchlist.add([tMovie1]);
    },
    expect: () => const [
      WatchlistLoading(),
      WatchlistError(CacheFailure()),
      WatchlistLoaded([tMovie1]),
    ],
  );

  test('close cancels the subscription', () async {
    final cubit = buildCubit();
    await cubit.load();
    expect(watchlist.hasListener, isTrue);

    await cubit.close();

    expect(watchlist.hasListener, isFalse);
  });

  test('load again (retry) replaces the old subscription', () async {
    final second = StreamController<List<Movie>>.broadcast();
    addTearDown(second.close);
    final cubit = buildCubit();
    await cubit.load();

    when(() => repository.watch()).thenAnswer((_) => second.stream);
    await cubit.load();

    expect(watchlist.hasListener, isFalse);
    expect(second.hasListener, isTrue);
    await cubit.close();
  });
}
