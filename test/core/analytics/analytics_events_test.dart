import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';

import '../../features/movies/movies_test_helpers.dart';

class _MockAnalytics extends Mock implements AnalyticsService {}

class _MockWatchlistRepository extends Mock implements WatchlistRepository {}

class _MockMoviesRepository extends Mock implements MoviesRepository {}

/// The few actions the app reports to analytics.
void main() {
  late _MockAnalytics analytics;

  setUp(() {
    analytics = _MockAnalytics();
    when(
      () => analytics.logWatchlistChanged(
        movieId: any(named: 'movieId'),
        added: any(named: 'added'),
      ),
    ).thenAnswer((_) async {});
    when(() => analytics.logSearch(any())).thenAnswer((_) async {});
  });

  group('watchlist', () {
    late _MockWatchlistRepository repository;

    setUp(() => repository = _MockWatchlistRepository());

    WatchlistToggleCubit build() => WatchlistToggleCubit(
      movie: tMovie1,
      repository: repository,
      analytics: analytics,
    );

    test('logs an add, then a remove', () async {
      final answers = [true, false];
      when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => Success(answers.removeAt(0)));
      final cubit = build();

      await cubit.toggle();
      await cubit.toggle();

      verifyInOrder([
        () => analytics.logWatchlistChanged(movieId: tMovie1.id, added: true),
        () => analytics.logWatchlistChanged(movieId: tMovie1.id, added: false),
      ]);
      await cubit.close();
    });

    test('logs nothing when saving fails', () async {
      when(
        () => repository.toggle(tMovie1),
      ).thenAnswer((_) async => const Err(CacheFailure()));
      final cubit = build();

      await cubit.toggle();

      verifyNever(
        () => analytics.logWatchlistChanged(
          movieId: any(named: 'movieId'),
          added: any(named: 'added'),
        ),
      );
      await cubit.close();
    });
  });

  test('search logs one event per real search, not per keystroke', () async {
    final repository = _MockMoviesRepository();
    when(
      () => repository.searchMovies(any(), page: any(named: 'page')),
    ).thenAnswer((_) async => const Success(tPage));
    final bloc =
        SearchBloc(
            repository: repository,
            debounceDuration: const Duration(milliseconds: 20),
            analytics: analytics,
          )
          ..add(const SearchQueryChanged('d'))
          ..add(const SearchQueryChanged('du'))
          ..add(const SearchQueryChanged('dune'));

    await Future<void>.delayed(const Duration(milliseconds: 150));

    verify(() => analytics.logSearch('dune')).called(1);
    verifyNoMoreInteractions(analytics);
    await bloc.close();
  });

  test('the no-op service has no router observers', () {
    expect(const NoopAnalyticsService().navigatorObservers, isEmpty);
  });
}
