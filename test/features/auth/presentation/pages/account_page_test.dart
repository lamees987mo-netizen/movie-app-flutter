// url_launcher_platform_interface comes with url_launcher; the test only
// needs it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/account_page.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../movies/movies_test_helpers.dart';
import '../../../movies/presentation/fake_url_launcher.dart';
import '../../auth_test_helpers.dart';

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockWatchlistCubit extends MockCubit<WatchlistState>
    implements WatchlistCubit {}

void main() {
  late MockAuthCubit auth;
  late MockAccountCubit account;
  late MockWatchlistCubit watchlist;
  late MockSettingsCubit settings;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(const Locale('en'));
  });

  setUp(() {
    auth = MockAuthCubit();
    account = MockAccountCubit();
    watchlist = MockWatchlistCubit();
    settings = MockSettingsCubit();
    when(() => auth.state).thenReturn(const AuthSignedOut());
    when(() => account.state).thenReturn(const AccountIdle());
    when(() => account.signOut()).thenAnswer((_) async {});
    when(
      () => watchlist.state,
    ).thenReturn(const WatchlistLoaded([tMovie1, tMovie2]));
    when(() => settings.state).thenReturn(const SettingsState());
    when(() => settings.setThemeMode(any())).thenAnswer((_) async {});
    when(() => settings.setLocale(any())).thenAnswer((_) async {});
  });

  /// The view inside a small router, so the rows can navigate. The pages
  /// they open are replaced by a text naming them.
  Future<void> pumpView(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    bool settle = true,
  }) async {
    GoRoute stub(String path) =>
        GoRoute(path: path, builder: (_, _) => Text('page $path'));
    final router = GoRouter(
      initialLocation: Routes.account,
      routes: [
        GoRoute(
          path: Routes.account,
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<AccountCubit>.value(value: account),
              BlocProvider<WatchlistCubit>.value(value: watchlist),
            ],
            child: const AccountView(),
          ),
        ),
        stub(Routes.signIn),
        stub(Routes.watchlist),
        stub(Routes.accountProfile),
        stub(Routes.accountSecurity),
        stub(Routes.terms),
        stub(Routes.about),
      ],
    );
    addTearDown(router.dispose);
    // A tall phone, so every row is built (a ListView only builds the
    // rows on screen).
    tester.view
      ..physicalSize = const Size(400, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<SettingsCubit>.value(value: settings),
        ],
        child: MaterialApp.router(
          locale: locale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> tapOn(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) =>
      tapOn(tester, find.text(text));

  group('guest', () {
    testWidgets('shows "Guest", a Sign in button and every group', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsWidgets);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      for (final row in [
        'Manage profile',
        'Security & privacy',
        'My watchlist',
        'Dark mode',
        'Language',
        'Help center',
        'Terms & policies',
        'About us',
      ]) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      // No notifications row: the app has no notifications.
      expect(find.textContaining('Notification'), findsNothing);
    });

    testWidgets('has no "Sign out" row', (tester) async {
      await pumpView(tester);
      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('"Sign in" opens the sign-in screen', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'Sign in');

      expect(find.text('page ${Routes.signIn}'), findsOneWidget);
    });

    for (final row in ['Manage profile', 'Security & privacy']) {
      testWidgets('"$row" opens sign-in too', (tester) async {
        await pumpView(tester);

        await tapText(tester, row);

        expect(find.text('page ${Routes.signIn}'), findsOneWidget);
      });
    }
  });

  group('signed in', () {
    setUp(() => when(() => auth.state).thenReturn(const AuthSignedIn(tUser)));

    testWidgets('shows the name, email and initials', (tester) async {
      await pumpView(tester);

      expect(find.text('Lamees Saad'), findsOneWidget);
      expect(find.text('lamees@example.com'), findsOneWidget);
      expect(find.text('LS'), findsOneWidget);
      expect(find.text('Guest'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsNothing);
    });

    testWidgets('a user without a name sees the email as the title', (
      tester,
    ) async {
      when(() => auth.state).thenReturn(const AuthSignedIn(tEmailOnlyUser));
      await pumpView(tester);

      expect(find.text('ann@example.com'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('"Manage profile" opens the profile page', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'Manage profile');

      expect(find.text('page ${Routes.accountProfile}'), findsOneWidget);
    });

    testWidgets('"Security & privacy" opens the security page', (
      tester,
    ) async {
      await pumpView(tester);

      await tapText(tester, 'Security & privacy');

      expect(find.text('page ${Routes.accountSecurity}'), findsOneWidget);
    });

    testWidgets('"Sign out" is at the bottom and signs out at once', (
      tester,
    ) async {
      await pumpView(tester);

      await tapText(tester, 'Sign out');

      verify(() => account.signOut()).called(1);
    });

    testWidgets('"Sign out" is disabled while busy', (tester) async {
      when(() => account.state).thenReturn(const AccountBusy());
      await pumpView(tester, settle: false);

      await tester.tap(find.text('Sign out'));
      await tester.pump();

      verifyNever(() => account.signOut());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('"requires recent login" offers to sign out', (tester) async {
      whenListen(
        account,
        Stream.value(
          const AccountError(AuthFailure(AuthError.requiresRecentLogin)),
        ),
        initialState: const AccountIdle(),
      );
      await pumpView(tester);

      expect(find.textContaining('sign in again'), findsOneWidget);
      await tester.tap(find.widgetWithText(SnackBarAction, 'Sign out'));
      await tester.pumpAndSettle();
      verify(() => account.signOut()).called(1);
    });

    testWidgets('other errors show their message', (tester) async {
      whenListen(
        account,
        Stream.value(const AccountError(NetworkFailure())),
        initialState: const AccountIdle(),
      );
      await pumpView(tester);

      expect(find.textContaining('No internet connection'), findsOneWidget);
      expect(find.byType(SnackBarAction), findsNothing);
    });
  });

  group('My watchlist', () {
    testWidgets('shows the number of saved movies', (tester) async {
      await pumpView(tester);

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'My watchlist'),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('no number while loading', (tester) async {
      when(() => watchlist.state).thenReturn(const WatchlistLoading());
      await pumpView(tester);

      expect(find.text('2'), findsNothing);
    });

    testWidgets('opens the Watchlist tab', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'My watchlist');

      expect(find.text('page ${Routes.watchlist}'), findsOneWidget);
    });
  });

  group('Preferences', () {
    Switch darkSwitch(WidgetTester tester) =>
        tester.widget<Switch>(find.byType(Switch));

    testWidgets('light theme: switch off and "Light"', (tester) async {
      await pumpView(tester);

      expect(darkSwitch(tester).value, isFalse);
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('dark theme: switch on and "Dark"', (tester) async {
      await pumpView(tester, themeMode: ThemeMode.dark);

      expect(darkSwitch(tester).value, isTrue);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('"follow the system" on a dark phone: switch on', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpView(tester, themeMode: ThemeMode.system);

      expect(darkSwitch(tester).value, isTrue);
    });

    testWidgets('turning the switch on chooses the dark theme', (
      tester,
    ) async {
      await pumpView(tester);

      await tapOn(tester, find.byType(Switch));

      verify(() => settings.setThemeMode(ThemeMode.dark)).called(1);
    });

    testWidgets('tapping the row in dark mode chooses the light theme', (
      tester,
    ) async {
      await pumpView(tester, themeMode: ThemeMode.dark);

      await tapText(tester, 'Dark mode');

      verify(() => settings.setThemeMode(ThemeMode.light)).called(1);
    });

    testWidgets('"Language" shows the current one and picks from a sheet', (
      tester,
    ) async {
      await pumpView(tester);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Language'),
          matching: find.text('English'),
        ),
        findsOneWidget,
      );

      await tapText(tester, 'Language');
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      verify(() => settings.setLocale(const Locale('ar'))).called(1);
      expect(find.byType(BottomSheet), findsNothing);
    });
  });

  group('Support', () {
    late FakeUrlLauncher launcher;

    setUp(() {
      launcher = FakeUrlLauncher();
      UrlLauncherPlatform.instance = launcher;
    });

    testWidgets('"Help center" opens the GitHub issues in the browser', (
      tester,
    ) async {
      await pumpView(tester);

      await tapText(tester, 'Help center');

      expect(
        launcher.launches.single.$1,
        'https://github.com/lamees987mo-netizen/movie-app-flutter/issues',
      );
      expect(
        launcher.launches.single.$2.mode,
        PreferredLaunchMode.externalApplication,
      );
    });

    testWidgets('a link that cannot open shows a SnackBar', (tester) async {
      launcher.result = false;
      await pumpView(tester);

      await tapText(tester, 'Help center');

      expect(find.text("Couldn't open the link."), findsOneWidget);
    });

    testWidgets('"Terms & policies" opens its page', (
      tester,
    ) async {
      await pumpView(tester);

      await tapText(tester, 'Terms & policies');
      expect(find.text('page ${Routes.terms}'), findsOneWidget);
    });

    testWidgets('"About us" opens its page', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'About us');

      expect(find.text('page ${Routes.about}'), findsOneWidget);
    });
  });

  testWidgets('Arabic: right-to-left, translated, chevrons mirrored', (
    tester,
  ) async {
    when(() => auth.state).thenReturn(const AuthSignedIn(tUser));
    when(
      () => settings.state,
    ).thenReturn(const SettingsState(locale: Locale('ar')));
    await pumpView(tester, locale: const Locale('ar'));

    expect(find.text('الملف الشخصي'), findsWidgets);
    expect(find.text('إدارة الملف الشخصي'), findsOneWidget);
    expect(find.text('التفضيلات'), findsOneWidget);
    final context = tester.element(find.text('إدارة الملف الشخصي'));
    expect(Directionality.of(context), TextDirection.rtl);
    // The chevron icon mirrors itself in RTL (it points to the left).
    expect(Icons.chevron_right.matchTextDirection, isTrue);
    // The leading icon is on the right side of the row in Arabic.
    final row = find.widgetWithText(ListTile, 'إدارة الملف الشخصي');
    final icon = find.descendant(
      of: row,
      matching: find.byIcon(Icons.person_outline),
    );
    expect(
      tester.getCenter(icon).dx,
      greaterThan(tester.getCenter(row).dx),
    );
    expect(tester.takeException(), isNull);
  });
}
