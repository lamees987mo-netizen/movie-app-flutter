import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/pages/search_page.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../../movies/movies_test_helpers.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

void main() {
  late MockSearchBloc bloc;
  late MockSettingsCubit settings;
  late StreamController<SettingsState> settingsChanges;

  setUp(() {
    bloc = MockSearchBloc();
    when(() => bloc.isClosed).thenReturn(false);
    settings = MockSettingsCubit();
    settingsChanges = StreamController<SettingsState>();
    whenListen(
      settings,
      settingsChanges.stream,
      initialState: const SettingsState(),
    );
  });

  // Not awaited: most tests never listen to it, and `close()` of a stream
  // nobody listened to never completes.
  tearDown(() => unawaited(settingsChanges.close()));

  /// Shows the whole [SearchPage]; it needs the app-wide [SettingsCubit].
  Future<void> pumpPage(WidgetTester tester) => tester.pumpWidget(
    BlocProvider<SettingsCubit>.value(
      value: settings,
      child: wrapWithApp(const SearchPage()),
    ),
  );

  /// Shows a [SearchView] whose bloc is stuck in [state].
  Future<void> pumpView(WidgetTester tester, SearchState state) {
    when(() => bloc.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        BlocProvider<SearchBloc>.value(value: bloc, child: const SearchView()),
      ),
    );
  }

  group('search field', () {
    testWidgets('shows the hint and sends every change to the bloc', (
      tester,
    ) async {
      await pumpView(tester, const SearchInitial());

      expect(find.text('Search movies'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'dune');
      verify(() => bloc.add(const SearchQueryChanged('dune'))).called(1);
    });

    testWidgets('the clear button empties the field and resets the search', (
      tester,
    ) async {
      await pumpView(tester, const SearchInitial());

      // Nothing to clear yet.
      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'dune');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(find.text('dune'), findsNothing);
      expect(find.byIcon(Icons.clear), findsNothing);
      verify(() => bloc.add(const SearchQueryChanged(''))).called(1);
    });
  });

  testWidgets('invites the user to type when the query is empty', (
    tester,
  ) async {
    await pumpView(tester, const SearchInitial());

    expect(
      find.text('Type a movie name to start searching.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a skeleton while loading', (tester) async {
    await pumpView(tester, const SearchLoading());

    // Skeletonizer animates forever, so use pump(), not pumpAndSettle().
    await tester.pump();

    expect(findSkeletonizer, findsOneWidget);
  });

  testWidgets('shows one poster per result with unique hero tags', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SearchLoaded(movies: [tMovie1, tMovie2], query: 'a'),
    );

    final cards = tester.widgetList<MoviePosterCard>(
      find.byType(MoviePosterCard),
    );
    expect(cards.map((card) => card.heroTag), ['search-1', 'search-2']);
    expect(findSkeletonizer, findsNothing);
  });

  testWidgets('shows a message when nothing matches', (tester) async {
    await pumpView(tester, const SearchEmpty('zzz'));

    expect(find.text('No movies match "zzz".'), findsOneWidget);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    await pumpView(
      tester,
      const SearchError(failure: NetworkFailure(), query: 'dune'),
    );

    expect(find.textContaining('No internet connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => bloc.add(const SearchRetried())).called(1);
  });

  testWidgets('tapping a poster opens its details with the hero tag', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(
      const SearchLoaded(movies: [tMovie1], query: 'inside'),
    );
    MovieDetailsArgs? openedWith;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<SearchBloc>.value(
            value: bloc,
            child: const SearchView(),
          ),
        ),
        GoRoute(
          path: Routes.movieDetails,
          builder: (_, state) {
            openedWith = state.extra as MovieDetailsArgs?;
            return Text('details ${state.pathParameters['id']}');
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

    await tester.tap(find.byType(MoviePosterCard));
    await tester.pumpAndSettle();

    expect(find.text('details 1'), findsOneWidget);
    expect(openedWith?.heroTag, 'search-1');
    expect(openedWith?.movie, tMovie1);
  });

  group('SearchPage', () {
    tearDown(() => sl.unregister<SearchBloc>());

    testWidgets('gets its bloc from sl and closes it when removed', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const SearchInitial());
      var created = 0;
      sl.registerFactory<SearchBloc>(() {
        created++;
        return bloc;
      });

      await pumpPage(tester);

      expect(created, 1);
      expect(find.byType(SearchView), findsOneWidget);
      expect(find.text('Search movies'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'dune');
      verify(() => bloc.add(const SearchQueryChanged('dune'))).called(1);

      // The page created the bloc, so it also closes it.
      await tester.pumpWidget(const SizedBox());
      verify(bloc.close).called(1);
    });

    testWidgets('searches again when the language changes', (tester) async {
      when(() => bloc.state).thenReturn(const SearchInitial());
      sl.registerFactory<SearchBloc>(() => bloc);
      await pumpPage(tester);

      settingsChanges.add(const SettingsState(themeMode: ThemeMode.dark));
      await tester.pump();
      verifyNever(() => bloc.add(const SearchLanguageChanged()));

      settingsChanges.add(const SettingsState(locale: Locale('ar')));
      await tester.pump();
      verify(() => bloc.add(const SearchLanguageChanged())).called(1);
    });
  });

  group('more results', () {
    /// More than fit on the screen, so the last ones are not built yet.
    final manyMovies = [
      for (var id = 1; id <= 60; id++)
        Movie(id: id, title: 'Movie $id', overview: '', voteAverage: 5),
    ];

    testWidgets('asks for the next page only near the end', (tester) async {
      await pumpView(
        tester,
        SearchLoaded(movies: manyMovies, query: 'a', hasReachedMax: false),
      );
      await tester.pump();
      verifyNever(() => bloc.add(const SearchNextPageRequested()));

      await tester.scrollUntilVisible(
        find.byWidgetPredicate(
          (w) => w is MoviePosterCard && w.movie.id == 60,
        ),
        500,
        // The text field has a Scrollable too; scroll the results.
        scrollable: find.descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pump();

      verify(() => bloc.add(const SearchNextPageRequested())).called(
        greaterThan(0),
      );
    });

    testWidgets('does not ask after the last page', (tester) async {
      await pumpView(
        tester,
        const SearchLoaded(movies: [tMovie1, tMovie2], query: 'a'),
      );
      await tester.pump();

      verifyNever(() => bloc.add(const SearchNextPageRequested()));
    });

    testWidgets('shows a spinner below the results while loading more', (
      tester,
    ) async {
      await pumpView(
        tester,
        const SearchLoaded(
          movies: [tMovie1, tMovie2],
          query: 'a',
          hasReachedMax: false,
          isLoadingMore: true,
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verifyNever(() => bloc.add(const SearchNextPageRequested()));
    });

    testWidgets('keeps the results after a failure and retries on tap', (
      tester,
    ) async {
      await pumpView(
        tester,
        const SearchLoaded(
          movies: [tMovie1, tMovie2],
          query: 'a',
          hasReachedMax: false,
          loadMoreFailure: NetworkFailure(),
        ),
      );
      await tester.pump();

      expect(find.byType(MoviePosterCard), findsNWidgets(2));
      expect(find.textContaining('No internet connection'), findsOneWidget);
      // No automatic retry loop.
      verifyNever(() => bloc.add(const SearchNextPageRequested()));

      await tester.tap(find.text('Retry'));
      verify(() => bloc.add(const SearchNextPageRequested())).called(1);
    });
  });
}
