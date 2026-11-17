import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_app/features/auth/data/repositories/unavailable_auth_repository.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  const user = AppUser(uid: 'u1', email: 'a@b.co');

  setUp(() {
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource);
  });

  test('passes the current user and the user stream through', () async {
    when(() => dataSource.currentUser).thenReturn(user);
    when(
      () => dataSource.userChanges(),
    ).thenAnswer((_) => Stream.value(user));

    expect(repository.currentUser, user);
    expect(await repository.userChanges().first, user);
  });

  group('successes', () {
    test('signInWithGoogle', () async {
      when(() => dataSource.signInWithGoogle()).thenAnswer((_) async => user);

      expect(await repository.signInWithGoogle(), const Success(user));
    });

    test('signInWithEmail', () async {
      when(
        () => dataSource.signInWithEmail(email: 'a@b.co', password: 'pw'),
      ).thenAnswer((_) async => user);

      expect(
        await repository.signInWithEmail(email: 'a@b.co', password: 'pw'),
        const Success(user),
      );
    });

    test('signUpWithEmail', () async {
      when(
        () => dataSource.signUpWithEmail(
          email: 'a@b.co',
          password: 'pw1234',
          name: 'Ann',
        ),
      ).thenAnswer((_) async => user);

      expect(
        await repository.signUpWithEmail(
          email: 'a@b.co',
          password: 'pw1234',
          name: 'Ann',
        ),
        const Success(user),
      );
    });

    test('sendPasswordResetEmail, signOut, deleteAccount', () async {
      when(
        () => dataSource.sendPasswordResetEmail('a@b.co'),
      ).thenAnswer((_) async {});
      when(() => dataSource.signOut()).thenAnswer((_) async {});
      when(() => dataSource.deleteAccount()).thenAnswer((_) async {});

      expect(
        await repository.sendPasswordResetEmail('a@b.co'),
        const Success<void>(null),
      );
      expect(await repository.signOut(), const Success<void>(null));
      expect(await repository.deleteAccount(), const Success<void>(null));
    });
  });

  group('failures', () {
    test('AuthException -> AuthFailure with the same reason', () async {
      when(
        () => dataSource.signInWithGoogle(),
      ).thenThrow(const AuthException(AuthError.cancelled));

      expect(
        await repository.signInWithGoogle(),
        const Err<AppUser>(AuthFailure(AuthError.cancelled)),
      );
    });

    test('NetworkException -> NetworkFailure', () async {
      when(() => dataSource.signOut()).thenThrow(const NetworkException());

      expect(await repository.signOut(), const Err<void>(NetworkFailure()));
    });

    test('anything else -> UnknownFailure', () async {
      when(() => dataSource.deleteAccount()).thenThrow(StateError('boom'));

      expect(
        await repository.deleteAccount(),
        const Err<void>(UnknownFailure()),
      );
    });
  });

  group('UnavailableAuthRepository (no Firebase)', () {
    const unavailable = UnavailableAuthRepository();
    const failure = AuthFailure(AuthError.unavailable);

    test('nobody is ever signed in', () async {
      expect(unavailable.currentUser, isNull);
      expect(await unavailable.userChanges().toList(), [null]);
    });

    test('every action answers "unavailable"', () async {
      expect(
        await unavailable.signInWithGoogle(),
        const Err<AppUser>(failure),
      );
      expect(
        await unavailable.signInWithEmail(email: 'a', password: 'b'),
        const Err<AppUser>(failure),
      );
      expect(
        await unavailable.signUpWithEmail(email: 'a', password: 'b'),
        const Err<AppUser>(failure),
      );
      expect(
        await unavailable.sendPasswordResetEmail('a'),
        const Err<void>(failure),
      );
      expect(await unavailable.signOut(), const Err<void>(failure));
      expect(await unavailable.deleteAccount(), const Err<void>(failure));
    });
  });
}
