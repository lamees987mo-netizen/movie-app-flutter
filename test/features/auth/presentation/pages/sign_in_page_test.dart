import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:movie_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

import '../../auth_test_helpers.dart';

void main() {
  late MockSignInCubit cubit;

  setUp(() {
    cubit = MockSignInCubit();
    when(() => cubit.state).thenReturn(const SignInIdle());
    when(() => cubit.signInWithGoogle()).thenAnswer((_) async {});
    when(
      () => cubit.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => cubit.signUpWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.sendPasswordResetEmail(any())).thenAnswer((_) async {});
  });

  /// A home page with a button that pushes the sign-in view, so closing
  /// it after success can be checked.
  Future<void> pumpView(WidgetTester tester, {bool settle = true}) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<SignInCubit>.value(
                    value: cubit,
                    child: const SignInView(),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // Let the page transition finish (a spinner never settles).
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  Finder submitButton(String label) => find.widgetWithText(FilledButton, label);

  testWidgets('shows the sign-in form with Google', (tester) async {
    await pumpView(tester);

    expect(find.widgetWithText(AppBar, 'Sign in'), findsOneWidget);
    expect(field('Email'), findsOneWidget);
    expect(field('Password'), findsOneWidget);
    expect(field('Name (optional)'), findsNothing);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('empty fields show validation errors, nothing is sent', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(submitButton('Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    verifyNever(
      () => cubit.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('an invalid email is refused', (tester) async {
    await pumpView(tester);

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.enterText(field('Password'), 'secret');
    await tester.tap(submitButton('Sign in'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('a valid form signs in', (tester) async {
    await pumpView(tester);

    await tester.enterText(field('Email'), 'a@b.co');
    await tester.enterText(field('Password'), 'pw');
    await tester.tap(submitButton('Sign in'));
    await tester.pump();

    verify(
      () => cubit.signInWithEmail(email: 'a@b.co', password: 'pw'),
    ).called(1);
  });

  testWidgets('create-account mode asks for a name and a long password', (
    tester,
  ) async {
    await pumpView(tester);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Create account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);

    await tester.enterText(field('Name (optional)'), 'Lamees');
    await tester.enterText(field('Email'), 'a@b.co');
    await tester.enterText(field('Password'), '123');
    await tester.tap(submitButton('Create account'));
    await tester.pump();
    expect(find.text('Use at least 6 characters'), findsOneWidget);

    await tester.enterText(field('Password'), '123456');
    await tester.tap(submitButton('Create account'));
    await tester.pump();
    verify(
      () => cubit.signUpWithEmail(
        name: 'Lamees',
        email: 'a@b.co',
        password: '123456',
      ),
    ).called(1);
  });

  testWidgets('the eye button shows the password', (tester) async {
    await pumpView(tester);
    TextField passwordField() => tester.widget<TextField>(
      find.descendant(of: field('Password'), matching: find.byType(TextField)),
    );

    expect(passwordField().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
  });

  testWidgets('"Forgot password?" needs only a valid email', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    // The password field is not checked for a reset.
    expect(find.text('Enter your password'), findsNothing);

    await tester.enterText(field('Email'), 'a@b.co');
    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    verify(() => cubit.sendPasswordResetEmail('a@b.co')).called(1);
  });

  testWidgets('Google button signs in with Google', (tester) async {
    await pumpView(tester);

    await tester.tap(find.text('Continue with Google'));

    verify(() => cubit.signInWithGoogle()).called(1);
  });

  testWidgets('shows the error message', (tester) async {
    when(() => cubit.state).thenReturn(
      const SignInError(AuthFailure(AuthError.invalidCredentials)),
    );
    await pumpView(tester);

    expect(find.text('Wrong email or password.'), findsOneWidget);
  });

  testWidgets('while loading, the buttons are disabled', (tester) async {
    when(() => cubit.state).thenReturn(const SignInLoading());
    await pumpView(tester, settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Continue with Google'));
    verifyNever(() => cubit.signInWithGoogle());
  });

  testWidgets('tells the user the reset email was sent', (tester) async {
    whenListen(
      cubit,
      Stream.value(const SignInResetEmailSent('a@b.co')),
      initialState: const SignInIdle(),
    );
    await pumpView(tester);

    expect(find.textContaining('we sent it a link'), findsOneWidget);
  });

  testWidgets('closes after a successful sign-in', (tester) async {
    whenListen(
      cubit,
      Stream.value(const SignInSuccess()),
      initialState: const SignInIdle(),
    );
    await pumpView(tester);

    expect(find.byType(SignInView), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });
}
