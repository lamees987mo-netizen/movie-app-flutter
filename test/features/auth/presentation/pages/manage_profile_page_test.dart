import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/manage_profile_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../auth_test_helpers.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late MockAuthCubit auth;
  late MockProfileCubit profile;

  const googleUser = AppUser(
    uid: 'u1',
    email: 'lamees@example.com',
    displayName: 'Lamees Saad',
    signInMethod: SignInMethod.google,
  );

  setUp(() {
    auth = MockAuthCubit();
    profile = MockProfileCubit();
    when(() => auth.state).thenReturn(const AuthSignedIn(googleUser));
    when(() => profile.state).thenReturn(const ProfileIdle());
    when(() => profile.saveName(any())).thenAnswer((_) async {});
  });

  /// [settle] is false while a spinner runs (it would never settle).
  Future<void> pumpView(WidgetTester tester, {bool settle = true}) async {
    final router = GoRouter(
      initialLocation: Routes.accountProfile,
      routes: [
        GoRoute(
          path: Routes.account,
          builder: (_, _) => const Text('account page'),
        ),
        GoRoute(
          path: Routes.accountProfile,
          builder: (_, _) => BlocProvider<ProfileCubit>.value(
            value: profile,
            child: const ManageProfileView(),
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
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  testWidgets('shows the name to edit, the email and the sign-in method', (
    tester,
  ) async {
    await pumpView(tester);

    expect(find.text('Manage profile'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Lamees Saad'),
      findsOneWidget,
    );
    expect(find.text('lamees@example.com'), findsOneWidget);
    expect(find.text('Sign-in method'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('email accounts show "Email and password"', (tester) async {
    when(() => auth.state).thenReturn(
      const AuthSignedIn(
        AppUser(uid: 'u2', email: 'a@b.co', signInMethod: SignInMethod.email),
      ),
    );
    await pumpView(tester);

    expect(find.text('Email and password'), findsOneWidget);
  });

  testWidgets('an unknown sign-in method is not shown', (tester) async {
    when(() => auth.state).thenReturn(const AuthSignedIn(tUser));
    await pumpView(tester);

    expect(find.text('Sign-in method'), findsNothing);
  });

  testWidgets('Save sends the new name', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.byType(TextFormField), 'Lamees Elsaka');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => profile.saveName('Lamees Elsaka')).called(1);
  });

  testWidgets('an empty name is not saved', (tester) async {
    await pumpView(tester);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
    verifyNever(() => profile.saveName(any()));
  });

  testWidgets('Save is disabled while saving', (tester) async {
    when(() => profile.state).thenReturn(const ProfileSaving());
    await pumpView(tester, settle: false);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('says when the name was saved', (tester) async {
    whenListen(
      profile,
      Stream.value(const ProfileSaved()),
      initialState: const ProfileIdle(),
    );
    await pumpView(tester);

    expect(find.text('Your name was saved.'), findsOneWidget);
  });

  testWidgets('shows an error message', (tester) async {
    whenListen(
      profile,
      Stream.value(const ProfileError(NetworkFailure())),
      initialState: const ProfileIdle(),
    );
    await pumpView(tester);

    expect(find.textContaining('No internet connection'), findsOneWidget);
  });

  testWidgets('goes back to the account tab when the user signs out', (
    tester,
  ) async {
    whenListen(
      auth,
      Stream.value(const AuthSignedOut()),
      initialState: const AuthSignedIn(googleUser),
    );
    await pumpView(tester);

    expect(find.text('account page'), findsOneWidget);
  });
}
