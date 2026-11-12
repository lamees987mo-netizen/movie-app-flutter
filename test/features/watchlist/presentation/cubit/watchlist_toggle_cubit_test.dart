import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository repository;

  setUp(() => repository = MockWatchlistRepository());

  WatchlistToggleCubit buildCubit() =>
      WatchlistToggleCubit(movie: tMovie1, repository: repository);

  test('starts as not saved', () {
    expect(buildCubit().state, const WatchlistToggleState());
  });

  group('load', () {
    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'emits isSaved from the repository',
      setUp: () => when(
        () => repository.isInWatchlist(tMovie1.id),
      ).thenAnswer((_) async => const Success(true)),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => const [WatchlistToggleState(isSaved: true)],
    );

    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'emits the failure when reading fails',
      setUp: () => when(
        () => repository.isInWatchlist(tMovie1.id),
      ).thenAnswer((_) async => const Err(CacheFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => const [WatchlistToggleState(failure: CacheFailure())],
    );
  });

  group('toggle', () {
    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'saves the movie',
      setUp: () => when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => const Success(true)),
      build: buildCubit,
      act: (cubit) => cubit.toggle(),
      expect: () => const [WatchlistToggleState(isSaved: true)],
      verify: (_) => verify(() => repository.toggle(tMovie1)).called(1),
    );

    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'removes a saved movie',
      setUp: () => when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => const Success(false)),
      build: buildCubit,
      seed: () => const WatchlistToggleState(isSaved: true),
      act: (cubit) => cubit.toggle(),
      expect: () => const [WatchlistToggleState()],
    );

    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'keeps isSaved and adds the failure when saving fails',
      setUp: () => when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => const Err(CacheFailure())),
      build: buildCubit,
      seed: () => const WatchlistToggleState(isSaved: true),
      act: (cubit) => cubit.toggle(),
      expect: () => const [
        WatchlistToggleState(isSaved: true, failure: CacheFailure()),
      ],
    );

    blocTest<WatchlistToggleCubit, WatchlistToggleState>(
      'clears an old failure first, so a repeated failure is shown again',
      setUp: () => when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => const Err(CacheFailure())),
      build: buildCubit,
      seed: () => const WatchlistToggleState(failure: CacheFailure()),
      act: (cubit) => cubit.toggle(),
      expect: () => const [
        WatchlistToggleState(),
        WatchlistToggleState(failure: CacheFailure()),
      ],
    );

    test('ignores taps while a toggle is running', () async {
      final completer = Completer<Result<bool>>();
      when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) => completer.future);
      final cubit = buildCubit();

      final first = cubit.toggle();
      await cubit.toggle();
      completer.complete(const Success(true));
      await first;

      verify(() => repository.toggle(tMovie1)).called(1);
      expect(cubit.state, const WatchlistToggleState(isSaved: true));
      await cubit.close();
    });
  });
}
