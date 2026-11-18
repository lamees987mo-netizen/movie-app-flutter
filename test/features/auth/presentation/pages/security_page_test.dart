import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/security_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../auth_test_helpers.dart';

void main() {
  late MockAuthCubit auth;
  late MockAccountCubit account;

  const emailUser = AppUser(
    uid: 'u1',
    email: 'lamees@example.com',
    signInMethod: SignInMethod.email,
  );
  const googleUser = AppUser(
    uid: 'u2',
    email: 'lamees@gmail.com',
    signInMethod: SignInMethod.google,
  );

  setUp(() {
    auth = MockAuthCubit();
    account = MockAccountCubit();
    when(() => auth.state).thenReturn(const AuthSignedIn(emailUser));
    when(() => account.state).thenReturn(const AccountIdle());
    when(() => account.deleteAccount()).thenAnswer((_) async {});
    when(() => account.sendPasswordReset(any())).thenAnswer((_) async {});
  });

  Future<void> pumpView(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: Routes.accountSecurity,
      routes: [
        GoRoute(
          path: Routes.account,
          // A Scaffold, so it can show SnackBars like the real page.
          builder: (_, _) => const Scaffold(body: Text('account page')),
        ),
        GoRoute(
          path: Routes.accountSecurity,
          builder: (_, _) => BlocProvider<AccountCubit>.value(
            value: account,
            child: const SecurityView(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('email account', () {
    testWidgets('offers "Change password" and "Delete account"', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.text('Security & privacy'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Delete account'), findsOneWidget);
    });

    testWidgets('"Change password" emails a reset link to the user', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();

      verify(
        () => account.sendPasswordReset('lamees@example.com'),
      ).called(1);
    });

    testWidgets('says where the link was sent', (tester) async {
      whenListen(
        account,
        Stream.value(const AccountPasswordResetSent('lamees@example.com')),
        initialState: const AccountIdle(),
      );
      await pumpView(tester);

      expect(
        find.text(
          'We sent a link to lamees@example.com to change your password.',
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('Google accounts have no "Change password", only a note', (
    tester,
  ) async {
    when(() => auth.state).thenReturn(const AuthSignedIn(googleUser));
    await pumpView(tester);

    expect(find.text('Change password'), findsNothing);
    expect(find.textContaining('managed in your Google account'), findsOne);
    expect(find.text('Delete account'), findsOneWidget);
  });

  testWidgets('"Delete account" asks first; Cancel keeps the account', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => account.deleteAccount());
  });

  testWidgets('confirming deletes the account', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => account.deleteAccount()).called(1);
  });

  testWidgets('the rows are disabled while busy', (tester) async {
    when(() => account.state).thenReturn(const AccountBusy());
    await pumpView(tester);

    await tester.tap(find.text('Change password'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    verifyNever(() => account.sendPasswordReset(any()));
    expect(find.text('Delete your account?'), findsNothing);
  });

  testWidgets('after deleting: back to the account tab, with a message', (
    tester,
  ) async {
    whenListen(
      account,
      Stream.value(const AccountDeleted()),
      initialState: const AccountIdle(),
    );
    whenListen(
      auth,
      Stream.value(const AuthSignedOut()),
      initialState: const AuthSignedIn(emailUser),
    );
    await pumpView(tester);

    expect(find.text('account page'), findsOneWidget);
    expect(find.text('Your account was deleted.'), findsOneWidget);
  });
}
