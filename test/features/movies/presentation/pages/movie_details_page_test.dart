import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/pages/movie_details_page.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/cast_list.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/details_summary.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/similar_movies.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/widgets/watchlist_button.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../movies_test_helpers.dart';

class MockMovieDetailsCubit extends MockCubit<MovieDetailsState>
    implements MovieDetailsCubit {}

class MockWatchlistToggleCubit extends MockCubit<WatchlistToggleState>
    implements WatchlistToggleCubit {}

void main() {
  late MockMovieDetailsCubit cubit;

  setUp(() {
    cubit = MockMovieDetailsCubit();
    // The loaded page shows a WatchlistButton, which gets its cubit from
    // the service locator, so register a mock one.
    sl.registerFactoryParam<WatchlistToggleCubit, Movie, void>((_, _) {
      final toggle = MockWatchlistToggleCubit();
      when(() => toggle.state).thenReturn(const WatchlistToggleState());
      when(toggle.load).thenAnswer((_) async {});
      return toggle;
    });
  });

  tearDown(() => sl.unregister<WatchlistToggleCubit>());

  /// Tests [MovieDetailsView] (the body of the page) with a mock cubit, so
  /// neither the service locator nor the network is needed.
  Future<void> pumpView(WidgetTester tester, MovieDetailsState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        BlocProvider<MovieDetailsCubit>.value(
          value: cubit,
          child: const MovieDetailsView(heroTag: 'trending-1'),
        ),
      ),
    );
  }

  testWidgets('shows a skeleton while loading', (tester) async {
    await pumpView(tester, const MovieDetailsLoading());
    await tester.pump();

    final skeletonizer = tester.widget<Skeletonizer>(findSkeletonizer);
    expect(skeletonizer.enabled, isTrue);
    // The fake skeleton movie must never be saveable.
    expect(find.byType(WatchlistButton), findsNothing);
  });

  testWidgets('shows the watchlist button once loaded', (tester) async {
    await pumpView(tester, const MovieDetailsLoaded(tDetails));

    expect(find.byType(WatchlistButton), findsOneWidget);
    expect(find.text('Add to watchlist'), findsOneWidget);
  });

  testWidgets('shows title, info, genres, overview, cast and trailer', (
    tester,
  ) async {
    await pumpView(tester, const MovieDetailsLoaded(tDetails));

    expect(find.text('Inside Out 2'), findsOneWidget);
    expect(find.text('7.6'), findsOneWidget);
    expect(find.text('97 min'), findsOneWidget);
    expect(find.text('Animation'), findsOneWidget);
    expect(find.text('Emotions.'), findsOneWidget);
    expect(find.text('Amy Poehler'), findsOneWidget);
    expect(find.text('Joy (voice)'), findsOneWidget);
    expect(find.text('Play trailer'), findsOneWidget);
  });

  testWidgets('hides the trailer button when there is no trailer', (
    tester,
  ) async {
    const noTrailer = MovieDetails(movie: tMovie1);
    await pumpView(tester, const MovieDetailsLoaded(noTrailer));

    expect(find.text('Play trailer'), findsNothing);
  });

  group('similar movies', () {
    const withSimilar = MovieDetails(movie: tMovie1, similar: [tMovie2]);

    testWidgets('are hidden when there are none', (tester) async {
      await pumpView(tester, const MovieDetailsLoaded(tDetails));

      expect(find.text('Similar movies'), findsNothing);
      expect(find.byType(SimilarMovies), findsNothing);
    });

    testWidgets('are shown with hero tags unique to this page', (
      tester,
    ) async {
      await pumpView(tester, const MovieDetailsLoaded(withSimilar));

      expect(find.text('Similar movies'), findsOneWidget);
      final poster = tester.widget<MoviePosterCard>(
        find.descendant(
          of: find.byType(SimilarMovies),
          matching: find.byType(MoviePosterCard),
        ),
      );
      expect(poster.movie, tMovie2);
      expect(poster.heroTag, 'similar-1-2');
    });

    testWidgets('keep a placeholder row in the loading skeleton', (
      tester,
    ) async {
      await pumpView(tester, const MovieDetailsLoading());
      await tester.pump();

      expect(find.byType(SimilarMovies), findsOneWidget);
    });
  });

  group('navigation', () {
    /// Where the test router went, and with which `extra`.
    late String openedPath;
    late Object? openedExtra;

    Future<void> pumpWithRouter(WidgetTester tester, MovieDetails details) {
      // A tall screen shows the whole page, so nothing hides under the
      // pinned app bar and taps land where expected.
      tester.view
        ..physicalSize = const Size(800, 2000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      when(() => cubit.state).thenReturn(MovieDetailsLoaded(details));
      Widget record(GoRouterState state) {
        openedPath = state.uri.path;
        openedExtra = state.extra;
        return Text('opened $openedPath');
      }

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => BlocProvider<MovieDetailsCubit>.value(
              value: cubit,
              child: const MovieDetailsView(),
            ),
          ),
          GoRoute(path: '/movie/:id', builder: (_, state) => record(state)),
          GoRoute(path: '/person/:id', builder: (_, state) => record(state)),
        ],
      );
      addTearDown(router.dispose);
      return tester.pumpWidget(
        MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
    }

    testWidgets('tapping a cast member opens their page', (tester) async {
      await pumpWithRouter(tester, tDetails);

      await tester.tap(find.text('Amy Poehler'));
      await tester.pumpAndSettle();

      expect(openedPath, '/person/56322');
      final args = openedExtra! as PersonArgs;
      expect(args.name, 'Amy Poehler');
      expect(args.profilePath, isNull);
    });

    testWidgets('tapping a similar movie opens its details', (tester) async {
      await pumpWithRouter(
        tester,
        const MovieDetails(movie: tMovie1, similar: [tMovie2]),
      );

      final poster = find.descendant(
        of: find.byType(SimilarMovies),
        matching: find.byType(MoviePosterCard),
      );
      await tester.tap(poster);
      await tester.pumpAndSettle();

      expect(openedPath, '/movie/2');
      final args = openedExtra! as MovieDetailsArgs;
      expect(args.movie, tMovie2);
      expect(args.heroTag, 'similar-1-2');
    });
  });

  group('layout', () {
    void setScreenSize(WidgetTester tester, Size size) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('on a phone, the overview is below the summary', (
      tester,
    ) async {
      setScreenSize(tester, const Size(400, 900));
      await pumpView(tester, const MovieDetailsLoaded(tDetails));

      final summary = tester.getRect(find.byType(DetailsSummary));
      final overview = tester.getRect(find.text('Overview'));
      expect(overview.top, greaterThan(summary.bottom));
    });

    testWidgets('on a wide screen, summary and overview sit side by side', (
      tester,
    ) async {
      setScreenSize(tester, const Size(1400, 1000));
      await pumpView(tester, const MovieDetailsLoaded(tDetails));

      final summary = tester.getRect(find.byType(DetailsSummary));
      final overview = tester.getRect(find.text('Overview'));
      expect(overview.left, greaterThanOrEqualTo(summary.right));
      expect(overview.top, lessThan(summary.bottom));
      // The content is centered and not wider than 1000.
      final cast = tester.getRect(find.byType(CastList));
      expect(cast.width, lessThanOrEqualTo(1000));
      expect(cast.left, 200);
    });
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpView(tester, const MovieDetailsError(ServerFailure(500)));

    expect(find.textContaining('server is having trouble'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });
}
