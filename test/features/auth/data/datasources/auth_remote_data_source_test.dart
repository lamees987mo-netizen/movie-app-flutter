import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as fake;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_app/features/auth/data/datasources/google_sign_in_client.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

class MockGoogleSignInClient extends Mock implements GoogleSignInClient {}

/// For the error cases: mocktail lets any method throw any exception.
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockGoogleSignInClient google;

  final bob = fake.MockUser(
    uid: 'bob-uid',
    email: 'bob@example.com',
    displayName: 'Bob',
    photoURL: 'https://example.com/bob.png',
  );
  const bobUser = AppUser(
    uid: 'bob-uid',
    email: 'bob@example.com',
    displayName: 'Bob',
    photoUrl: 'https://example.com/bob.png',
  );

  setUpAll(() => registerFallbackValue(FakeAuthCredential()));

  setUp(() {
    google = MockGoogleSignInClient();
    when(() => google.signIn()).thenAnswer((_) async => 'id-token');
    when(() => google.signOut()).thenAnswer((_) async {});
  });

  group('with firebase_auth_mocks (happy paths)', () {
    test('a guest has no current user', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      expect(dataSource.currentUser, isNull);
    });

    test('maps the signed-in Firebase user', () {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(signedIn: true, mockUser: bob),
        google,
      );

      expect(dataSource.currentUser, bobUser);
    });

    test('signInWithGoogle uses the Google ID token', () async {
      final auth = fake.MockFirebaseAuth(mockUser: bob);
      final dataSource = FirebaseAuthDataSource(auth, google);

      expect(await dataSource.signInWithGoogle(), bobUser);
      verify(() => google.signIn()).called(1);
      expect(auth.currentUser?.uid, 'bob-uid');
    });

    test('signInWithEmail signs in', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(mockUser: bob),
        google,
      );

      final user = await dataSource.signInWithEmail(
        email: 'bob@example.com',
        password: 'secret1',
      );

      expect(user.uid, 'bob-uid');
    });

    test('signUpWithEmail creates the user and sets the name', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      final user = await dataSource.signUpWithEmail(
        email: 'new@example.com',
        password: 'secret1',
        name: 'Lamees',
      );

      expect(user.email, 'new@example.com');
      expect(user.displayName, 'Lamees');
    });

    test('userChanges emits the user after sign-in', () async {
      final auth = fake.MockFirebaseAuth(mockUser: bob);
      final dataSource = FirebaseAuthDataSource(auth, google);

      final events = dataSource.userChanges().take(2).toList();
      await dataSource.signInWithEmail(email: 'bob@example.com', password: 'x');

      expect(await events, [null, bobUser]);
    });

    test('signOut also forgets the Google account', () async {
      final auth = fake.MockFirebaseAuth(signedIn: true, mockUser: bob);
      final dataSource = FirebaseAuthDataSource(auth, google);

      await dataSource.signOut();

      expect(auth.currentUser, isNull);
      verify(() => google.signOut()).called(1);
    });

    test('sendPasswordResetEmail completes', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      await expectLater(
        dataSource.sendPasswordResetEmail('bob@example.com'),
        completes,
      );
    });

    test('deleteAccount deletes the user and signs out of Google', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(signedIn: true, mockUser: bob),
        google,
      );

      await dataSource.deleteAccount();

      verify(() => google.signOut()).called(1);
    });

    test('signUpWithEmail users sign in with email', () async {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      final user = await dataSource.signUpWithEmail(
        email: 'new@example.com',
        password: 'secret1',
      );

      expect(user.signInMethod, SignInMethod.email);
    });

    test('maps the provider to the sign-in method', () {
      AppUser? mapWith(List<String> providerIds) => FirebaseAuthDataSource(
        fake.MockFirebaseAuth(
          signedIn: true,
          mockUser: fake.MockUser(
            uid: 'u',
            providerData: [
              for (final id in providerIds) _userInfo(providerId: id),
            ],
          ),
        ),
        google,
      ).currentUser;

      expect(mapWith(['google.com'])?.signInMethod, SignInMethod.google);
      expect(mapWith(['password'])?.signInMethod, SignInMethod.email);
      // Google linked to an email account: it still has a password.
      expect(
        mapWith(['google.com', 'password'])?.signInMethod,
        SignInMethod.email,
      );
      expect(mapWith([])?.signInMethod, SignInMethod.unknown);
    });

    test('updateDisplayName renames the signed-in user', () async {
      final auth = fake.MockFirebaseAuth(signedIn: true, mockUser: bob);
      final dataSource = FirebaseAuthDataSource(auth, google);

      final user = await dataSource.updateDisplayName('Robert');

      expect(user.displayName, 'Robert');
      expect(auth.currentUser?.displayName, 'Robert');
    });

    test('updateDisplayName without a user throws unknown', () {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      expect(
        dataSource.updateDisplayName('Robert'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.unknown,
          ),
        ),
      );
    });

    test('deleteAccount without a user throws unknown', () {
      final dataSource = FirebaseAuthDataSource(
        fake.MockFirebaseAuth(),
        google,
      );

      expect(
        dataSource.deleteAccount(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.unknown,
          ),
        ),
      );
    });
  });

  group('error mapping', () {
    late MockFirebaseAuth auth;
    late FirebaseAuthDataSource dataSource;

    setUp(() {
      auth = MockFirebaseAuth();
      dataSource = FirebaseAuthDataSource(auth, google);
    });

    Future<void> signInThrowing(String code) {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: code));
      return dataSource.signInWithEmail(email: 'a@b.co', password: 'x');
    }

    Matcher throwsAuth(AuthError error) => throwsA(
      isA<AuthException>().having((e) => e.error, 'error', error),
    );

    const codes = {
      'invalid-credential': AuthError.invalidCredentials,
      'wrong-password': AuthError.invalidCredentials,
      'user-not-found': AuthError.invalidCredentials,
      'email-already-in-use': AuthError.emailAlreadyInUse,
      'weak-password': AuthError.weakPassword,
      'invalid-email': AuthError.invalidEmail,
      'user-disabled': AuthError.userDisabled,
      'too-many-requests': AuthError.tooManyRequests,
      'requires-recent-login': AuthError.requiresRecentLogin,
      'operation-not-allowed': AuthError.unavailable,
      'something-new': AuthError.unknown,
    };
    for (final MapEntry(key: code, value: error) in codes.entries) {
      test('"$code" -> $error', () {
        expect(signInThrowing(code), throwsAuth(error));
      });
    }

    test('"network-request-failed" -> NetworkException', () {
      expect(
        signInThrowing('network-request-failed'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('a cancelled Google picker stays cancelled', () {
      when(
        () => google.signIn(),
      ).thenThrow(const AuthException(AuthError.cancelled));

      expect(dataSource.signInWithGoogle(), throwsAuth(AuthError.cancelled));
      verifyNever(() => auth.signInWithCredential(any()));
    });

    test('any other error -> unknown', () {
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(StateError('boom'));

      expect(
        dataSource.sendPasswordResetEmail('a@b.co'),
        throwsAuth(AuthError.unknown),
      );
    });

    test('deleteAccount maps "requires-recent-login"', () {
      final user = MockUser();
      when(() => auth.currentUser).thenReturn(user);
      when(
        user.delete,
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

      expect(
        dataSource.deleteAccount(),
        throwsAuth(AuthError.requiresRecentLogin),
      );
      verifyNever(() => google.signOut());
    });
  });
}

class _MockUserInfo extends Mock implements UserInfo {}

/// One of a user's sign-in providers, e.g. `google.com` or `password`.
UserInfo _userInfo({required String providerId}) {
  final info = _MockUserInfo();
  when(() => info.providerId).thenReturn(providerId);
  return info;
}
