import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/app_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_cubit.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/pages/home_page.dart';
import 'package:movie_app/features/movies/presentation/pages/movie_details_page.dart';
import 'package:movie_app/features/movies/presentation/pages/see_all_page.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/pages/search_page.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/settings/presentation/pages/settings_page.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../features/movies/movies_test_helpers.dart';

class MockMovieSectionCubit extends MockCubit<MovieSectionState>
    implements MovieSectionCubit {}

class MockSeeAllCubit extends MockCubit<SeeAllState> implements SeeAllCubit {}

class MockMovieDetailsCubit extends MockCubit<MovieDetailsState>
    implements MovieDetailsCubit {}

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class MockWatchlistCubit extends MockCubit<WatchlistState>
    implements WatchlistCubit {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockSettingsCubit settings;

  /// What each page asked `sl` for, to check the route parameters.
  late List<MovieCategory> seeAllCategories;
  late List<int> detailsIds;

  setUp(() {
    seeAllCategories = [];
    detailsIds = [];

    // Every page gets a mock in a state without a skeleton, so
    // pumpAndSettle() can finish.
    final connectivity = MockConnectivity();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
    when(
      connectivity.checkConnectivity,
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);

    sl
      ..registerSingleton<Connectivity>(connectivity)
      ..registerFactoryParam<MovieSectionCubit, MovieCategory, void>((
        category,
        _,
      ) {
        final cubit = MockMovieSectionCubit();
        when(() => cubit.category).thenReturn(category);
        when(() => cubit.state).thenReturn(const MovieSectionLoaded([tMovie1]));
        when(cubit.load).thenAnswer((_) async {});
        return cubit;
      })
      ..registerFactoryParam<SeeAllCubit, MovieCategory, void>((category, _) {
        seeAllCategories.add(category);
        final cubit = MockSeeAllCubit();
        when(() => cubit.state).thenReturn(const SeeAllError(ServerFailure()));
        when(cubit.loadFirstPage).thenAnswer((_) async {});
        return cubit;
      })
      ..registerFactoryParam<MovieDetailsCubit, int, void>((movieId, _) {
        detailsIds.add(movieId);
        final cubit = MockMovieDetailsCubit();
        when(
          () => cubit.state,
        ).thenReturn(const MovieDetailsError(ServerFailure()));
        when(cubit.load).thenAnswer((_) async {});
        return cubit;
      })
      ..registerFactory<SearchBloc>(() {
        final bloc = MockSearchBloc();
        when(() => bloc.state).thenReturn(const SearchInitial());
        return bloc;
      })
      ..registerFactory<WatchlistCubit>(() {
        final cubit = MockWatchlistCubit();
        when(() => cubit.state).thenReturn(const WatchlistEmpty());
        when(cubit.load).thenAnswer((_) async {});
        return cubit;
      });

    settings = MockSettingsCubit();
    when(() => settings.state).thenReturn(const SettingsState());
  });

  tearDown(sl.reset);

  Future<GoRouter> pumpApp(WidgetTester tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<SettingsCubit>.value(
        value: settings,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('starts on Home', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('the bottom navigation opens each tab page', (tester) async {
    await pumpApp(tester);

    final tabs = <String, Type>{
      'Search': SearchPage,
      'Watchlist': WatchlistPage,
      'Settings': SettingsPage,
      'Home': HomePage,
    };
    for (final MapEntry(key: label, value: page) in tabs.entries) {
      await tester.tap(navLabel(label));
      await tester.pumpAndSettle();

      expect(find.byType(page), findsOneWidget, reason: label);
    }
  });

  testWidgets('movie details opens above the shell with its args', (
    tester,
  ) async {
    final router = await pumpApp(tester);

    unawaited(
      router.push(
        Routes.movieDetailsPath(42),
        extra: const MovieDetailsArgs(heroTag: 'trending-42', movie: tMovie2),
      ),
    );
    await tester.pumpAndSettle();

    final page = tester.widget<MovieDetailsPage>(
      find.byType(MovieDetailsPage),
    );
    expect(page.movieId, 42);
    expect(page.heroTag, 'trending-42');
    expect(page.preview, tMovie2);
    expect(detailsIds, [42]);
    // Full-screen route: the bottom navigation is hidden.
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('movie details deep link works without args', (tester) async {
    final router = await pumpApp(tester);

    router.go(Routes.movieDetailsPath(7));
    await tester.pumpAndSettle();

    final page = tester.widget<MovieDetailsPage>(
      find.byType(MovieDetailsPage),
    );
    expect(page.movieId, 7);
    expect(page.heroTag, isNull);
    expect(page.preview, isNull);
  });

  testWidgets('see all opens the category from the path', (tester) async {
    final router = await pumpApp(tester);

    unawaited(router.push(Routes.seeAllPath(MovieCategory.topRated.name)));
    await tester.pumpAndSettle();

    final page = tester.widget<SeeAllPage>(find.byType(SeeAllPage));
    expect(page.category, MovieCategory.topRated);
    expect(seeAllCategories, [MovieCategory.topRated]);
  });
}
