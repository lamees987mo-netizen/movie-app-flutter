import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/widgets/offline_banner.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/pages/home_page.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_section.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';

import '../../movies_test_helpers.dart';

class MockMovieSectionCubit extends MockCubit<MovieSectionState>
    implements MovieSectionCubit {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  /// The cubit HomePage got from `sl` for each category.
  late Map<MovieCategory, MockMovieSectionCubit> cubits;
  late MockConnectivity connectivity;
  late StreamController<List<ConnectivityResult>> connectivityChanges;
  late MockSettingsCubit settings;
  late StreamController<SettingsState> settingsChanges;

  /// Lets a test make a section emit a new state (see [emitSection]).
  late Map<MovieCategory, StreamController<MovieSectionState>> sectionChanges;

  setUp(() {
    cubits = {};
    sectionChanges = {};
    sl.registerFactoryParam<MovieSectionCubit, MovieCategory, void>((
      category,
      _,
    ) {
      final cubit = MockMovieSectionCubit();
      when(() => cubit.category).thenReturn(category);
      when(() => cubit.state).thenReturn(const MovieSectionLoaded([tMovie1]));
      when(cubit.load).thenAnswer((_) async {});
      when(cubit.refresh).thenAnswer((_) async {});
      final changes = sectionChanges[category] =
          StreamController<MovieSectionState>.broadcast();
      when(() => cubit.stream).thenAnswer((_) => changes.stream);
      return cubits[category] = cubit;
    });

    connectivity = MockConnectivity();
    connectivityChanges = StreamController<List<ConnectivityResult>>();
    when(
      () => connectivity.onConnectivityChanged,
    ).thenAnswer((_) => connectivityChanges.stream);
    when(
      connectivity.checkConnectivity,
    ).thenAnswer((_) async => [ConnectivityResult.wifi]);
    sl.registerSingleton<Connectivity>(connectivity);

    settings = MockSettingsCubit();
    settingsChanges = StreamController<SettingsState>();
    whenListen(
      settings,
      settingsChanges.stream,
      initialState: const SettingsState(),
    );
  });

  tearDown(() async {
    await connectivityChanges.close();
    await settingsChanges.close();
    for (final changes in sectionChanges.values) {
      await changes.close();
    }
    await sl.reset();
  });

  /// Makes the section of [category] switch to [state], like a real cubit.
  Future<void> emitSection(
    WidgetTester tester,
    MovieCategory category,
    MovieSectionState state,
  ) async {
    when(() => cubits[category]!.state).thenReturn(state);
    sectionChanges[category]!.add(state);
    // Two pumps, for the same reason as in `showEvents`.
    await tester.pump();
    await tester.pump();
  }

  Future<void> pumpHome(WidgetTester tester) async {
    // Tall enough for all four sections to be built at once.
    tester.view
      ..physicalSize = const Size(800, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<SettingsCubit>.value(
        value: settings,
        child: wrapWithApp(const HomePage()),
      ),
    );
    // Let checkConnectivity() complete.
    await tester.pump();
  }

  /// Stream events reach HomePage only after the frame that the first
  /// `pump` draws, so a second pump is needed to see their effect.
  Future<void> showEvents(WidgetTester tester) async {
    await tester.pump();
    await tester.pump();
  }

  void verifyEveryCubitRefreshed() {
    for (final cubit in cubits.values) {
      verify(cubit.refresh).called(1);
    }
  }

  testWidgets('shows the four sections in order and loads each one', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Movie App'), findsOneWidget);
    expect(find.byType(MovieSection), findsNWidgets(4));

    final sections = tester.widgetList<MovieSection>(find.byType(MovieSection));
    expect(sections.map((s) => s.category), [
      MovieCategory.trending,
      MovieCategory.nowPlaying,
      MovieCategory.topRated,
      MovieCategory.upcoming,
    ]);
    for (final title in ['Trending', 'Now Playing', 'Top Rated', 'Upcoming']) {
      expect(find.text(title), findsOneWidget);
    }

    expect(cubits.keys, unorderedEquals(MovieCategory.values));
    for (final cubit in cubits.values) {
      verify(cubit.load).called(1);
      verifyNever(cubit.refresh);
    }
    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('shows the offline banner when there is no connection', (
    tester,
  ) async {
    when(
      connectivity.checkConnectivity,
    ).thenAnswer((_) async => [ConnectivityResult.none]);

    await pumpHome(tester);

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.text("You're offline. Showing saved content."), findsOneWidget);
  });

  testWidgets(
    'shows the banner while a section shows cached movies, also online',
    (tester) async {
      // E.g. Wi-Fi without internet: connectivity says "online", but the
      // repository had to fall back to the cache.
      await pumpHome(tester);
      expect(find.byType(OfflineBanner), findsNothing);

      await emitSection(
        tester,
        MovieCategory.topRated,
        const MovieSectionLoaded([tMovie1], isFromCache: true),
      );
      expect(find.byType(OfflineBanner), findsOneWidget);

      // Fresh data again (e.g. after pull to refresh): the banner goes.
      await emitSection(
        tester,
        MovieCategory.topRated,
        const MovieSectionLoaded([tMovie2]),
      );
      expect(find.byType(OfflineBanner), findsNothing);
    },
  );

  testWidgets('shows the banner when the connection drops', (tester) async {
    await pumpHome(tester);
    expect(find.byType(OfflineBanner), findsNothing);

    connectivityChanges.add([ConnectivityResult.none]);
    await showEvents(tester);

    expect(find.byType(OfflineBanner), findsOneWidget);
    for (final cubit in cubits.values) {
      verifyNever(cubit.refresh);
    }
  });

  testWidgets('back online: hides the banner and refreshes every section', (
    tester,
  ) async {
    when(
      connectivity.checkConnectivity,
    ).thenAnswer((_) async => [ConnectivityResult.none]);
    await pumpHome(tester);
    expect(find.byType(OfflineBanner), findsOneWidget);

    connectivityChanges.add([ConnectivityResult.mobile]);
    await showEvents(tester);

    expect(find.byType(OfflineBanner), findsNothing);
    verifyEveryCubitRefreshed();
  });

  testWidgets('ignores events that do not change the online status', (
    tester,
  ) async {
    await pumpHome(tester);

    connectivityChanges.add([ConnectivityResult.wifi]);
    await showEvents(tester);

    expect(find.byType(OfflineBanner), findsNothing);
    for (final cubit in cubits.values) {
      verifyNever(cubit.refresh);
    }
  });

  testWidgets('refreshes every section when the language changes', (
    tester,
  ) async {
    await pumpHome(tester);

    settingsChanges.add(const SettingsState(locale: Locale('ar')));
    await showEvents(tester);

    verifyEveryCubitRefreshed();
  });

  testWidgets('does not refresh when only the theme changes', (tester) async {
    await pumpHome(tester);

    settingsChanges.add(const SettingsState(themeMode: ThemeMode.dark));
    await showEvents(tester);

    for (final cubit in cubits.values) {
      verifyNever(cubit.refresh);
    }
  });

  testWidgets('pull to refresh refreshes every section', (tester) async {
    await pumpHome(tester);

    // The pull must be long compared to the (tall) test screen.
    await tester.fling(find.text('Trending'), const Offset(0, 1000), 1000);
    await tester.pumpAndSettle();

    verifyEveryCubitRefreshed();
  });

  testWidgets('closes its cubits and stops listening when disposed', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(connectivityChanges.hasListener, isTrue);

    await tester.pumpWidget(const SizedBox());

    for (final cubit in cubits.values) {
      verify(cubit.close).called(1);
    }
    expect(connectivityChanges.hasListener, isFalse);
  });
}
