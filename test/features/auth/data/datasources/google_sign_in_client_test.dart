import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/data/datasources/google_sign_in_client.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late MockGoogleSignIn google;
  late MockAccount account;
  late GoogleSignInClientImpl client;

  setUp(() {
    google = MockGoogleSignIn();
    account = MockAccount();
    client = GoogleSignInClientImpl(google, clientId: 'ios-client');
    when(
      () => google.initialize(clientId: any(named: 'clientId')),
    ).thenAnswer((_) async {});
    when(() => google.supportsAuthenticate()).thenReturn(true);
    when(() => google.authenticate()).thenAnswer((_) async => account);
    when(() => google.signOut()).thenAnswer((_) async {});
    when(
      () => account.authentication,
    ).thenReturn(const GoogleSignInAuthentication(idToken: 'id-token'));
  });

  Matcher throwsAuth(AuthError error) =>
      throwsA(isA<AuthException>().having((e) => e.error, 'error', error));

  test('returns the ID token, initializing only once', () async {
    expect(await client.signIn(), 'id-token');
    expect(await client.signIn(), 'id-token');

    verify(() => google.initialize(clientId: 'ios-client')).called(1);
  });

  test('tries to initialize again after a failure', () async {
    var calls = 0;
    when(
      () => google.initialize(clientId: any(named: 'clientId')),
    ).thenAnswer((_) async {
      if (calls++ == 0) throw StateError('not ready');
    });

    await expectLater(client.signIn(), throwsA(isA<StateError>()));
    expect(await client.signIn(), 'id-token');
  });

  test('a closed picker is "cancelled"', () {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    expect(client.signIn(), throwsAuth(AuthError.cancelled));
  });

  test('a setup error is "unavailable"', () {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
      ),
    );

    expect(client.signIn(), throwsAuth(AuthError.unavailable));
  });

  test('other Google errors are "unknown"', () {
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.uiUnavailable,
      ),
    );

    expect(client.signIn(), throwsAuth(AuthError.unknown));
  });

  test('no ID token is "unknown"', () {
    when(
      () => account.authentication,
    ).thenReturn(const GoogleSignInAuthentication(idToken: null));

    expect(client.signIn(), throwsAuth(AuthError.unknown));
  });

  test('a platform without authenticate() is "unavailable"', () {
    when(() => google.supportsAuthenticate()).thenReturn(false);

    expect(client.signIn(), throwsAuth(AuthError.unavailable));
  });

  test('signOut never throws', () async {
    when(() => google.signOut()).thenThrow(StateError('boom'));

    await expectLater(client.signOut(), completes);
  });
}
