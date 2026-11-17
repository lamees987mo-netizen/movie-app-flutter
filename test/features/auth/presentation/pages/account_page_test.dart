import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/account_page.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_panel.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../../movies/movies_test_helpers.dart';
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

  setUp(() {
    auth = MockAuthCubit();
    account = MockAccountCubit();
    watchlist = MockWatchlistCubit();
    settings = MockSettingsCubit();
    when(() => auth.state).thenReturn(const AuthSignedOut());
    when(() => account.state).thenReturn(const AccountIdle());
    when(() => account.signOut()).thenAnswer((_) async {});
    when(() => account.deleteAccount()).thenAnswer((_) async {});
    when(
      () => watchlist.state,
    ).thenReturn(const WatchlistLoaded([tMovie1, tMovie2]));
    when(() => settings.state).thenReturn(const SettingsState());
  });

  /// The view inside a small router, so the "Sign in" button and the
  /// watchlist line can navigate.
  Future<void> pumpView(WidgetTester tester, {bool settle = true}) async {
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
        GoRoute(
          path: Routes.signIn,
          builder: (_, _) => const Text('sign-in page'),
        ),
        GoRoute(
          path: Routes.watchlist,
          builder: (_, _) => const Text('watchlist page'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<SettingsCubit>.value(value: settings),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
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

  /// [settle] is false while a spinner runs (it would never settle).
  Future<void> tapText(
    WidgetTester tester,
    String text, {
    bool settle = true,
  }) async {
    await tester.ensureVisible(find.text(text));
    await tester.pump();
    await tester.tap(find.text(text));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  group('guest', () {
    testWidgets('explains why to sign in, and shows the settings', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Sign in to sync your watchlist'), findsOneWidget);
      expect(find.byType(SettingsPanel), findsOneWidget);
      // At the bottom of the list (required by TMDB).
      await tester.scrollUntilVisible(
        find.textContaining('uses the TMDB API'),
        200,
      );
      expect(find.textContaining('uses the TMDB API'), findsOneWidget);
      expect(find.text('Sign out'), findsNothing);
      expect(find.text('Delete account'), findsNothing);
    });

    testWidgets('"Sign in" opens the sign-in screen', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'Sign in');

      expect(find.text('sign-in page'), findsOneWidget);
    });
  });

  group('signed in', () {
    setUp(() => when(() => auth.state).thenReturn(const AuthSignedIn(tUser)));

    testWidgets('shows the profile and the watchlist count', (tester) async {
      await pumpView(tester);

      expect(find.text('Lamees Saad'), findsOneWidget);
      expect(find.text('lamees@example.com'), findsOneWidget);
      expect(find.text('LS'), findsOneWidget);
      expect(find.text('2 saved movies'), findsOneWidget);
      expect(find.text('Synced with your account'), findsOneWidget);
      expect(find.text('Sign in to sync your watchlist'), findsNothing);
    });

    testWidgets('the watchlist line opens the Watchlist tab', (tester) async {
      await pumpView(tester);

      await tapText(tester, '2 saved movies');

      expect(find.text('watchlist page'), findsOneWidget);
    });

    testWidgets('a user without a name sees the email as the title', (
      tester,
    ) async {
      when(() => auth.state).thenReturn(
        const AuthSignedIn(tEmailOnlyUser),
      );
      when(() => watchlist.state).thenReturn(const WatchlistEmpty());
      await pumpView(tester);

      expect(find.text('ann@example.com'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('No saved movies'), findsOneWidget);
    });

    testWidgets('"Sign out" signs out', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'Sign out');

      verify(() => account.signOut()).called(1);
    });

    testWidgets('"Delete account" asks first; Cancel keeps the account', (
      tester,
    ) async {
      await pumpView(tester);

      await tapText(tester, 'Delete account');
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete your account?'), findsNothing);
      verifyNever(() => account.deleteAccount());
    });

    testWidgets('confirming deletes the account', (tester) async {
      await pumpView(tester);

      await tapText(tester, 'Delete account');
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => account.deleteAccount()).called(1);
    });

    testWidgets('the buttons are disabled while busy', (tester) async {
      when(() => account.state).thenReturn(const AccountBusy());
      await pumpView(tester, settle: false);

      await tapText(tester, 'Sign out', settle: false);
      await tapText(tester, 'Delete account', settle: false);

      verifyNever(() => account.signOut());
      expect(find.text('Delete your account?'), findsNothing);
    });

    testWidgets('"requires recent login" explains and offers to sign out', (
      tester,
    ) async {
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

    testWidgets('confirms the deletion', (tester) async {
      whenListen(
        account,
        Stream.value(const AccountDeleted()),
        initialState: const AccountIdle(),
      );
      await pumpView(tester);

      expect(find.text('Your account was deleted.'), findsOneWidget);
    });
  });
}
