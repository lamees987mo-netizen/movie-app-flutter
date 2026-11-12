import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/pages/search_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../../movies/movies_test_helpers.dart';

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

void main() {
  late MockSearchBloc bloc;

  setUp(() => bloc = MockSearchBloc());

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
}
