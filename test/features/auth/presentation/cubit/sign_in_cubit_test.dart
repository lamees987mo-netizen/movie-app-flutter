import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';

import '../../auth_test_helpers.dart';

void main() {
  late MockAuthRepository repository;

  const wrongPassword = AuthFailure(AuthError.invalidCredentials);

  setUp(() {
    repository = MockAuthRepository();
    when(
      () => repository.signInWithGoogle(),
    ).thenAnswer((_) async => const Success(tUser));
    when(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Success(tUser));
    when(
      () => repository.signUpWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      ),
    ).thenAnswer((_) async => const Success(tUser));
    when(
      () => repository.sendPasswordResetEmail(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  SignInCubit build() => SignInCubit(repository: repository);

  blocTest<SignInCubit, SignInState>(
    'Google: loading, then success',
    build: build,
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => const [SignInLoading(), SignInSuccess()],
  );

  blocTest<SignInCubit, SignInState>(
    'Google cancelled: loading, then the error',
    setUp: () => when(() => repository.signInWithGoogle()).thenAnswer(
      (_) async => const Err(AuthFailure(AuthError.cancelled)),
    ),
    build: build,
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => const [
      SignInLoading(),
      SignInError(AuthFailure(AuthError.cancelled)),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'email sign-in trims the email (not the password)',
    build: build,
    act: (cubit) => cubit.signInWithEmail(email: '  a@b.co ', password: ' pw '),
    expect: () => const [SignInLoading(), SignInSuccess()],
    verify: (_) => verify(
      () => repository.signInWithEmail(email: 'a@b.co', password: ' pw '),
    ).called(1),
  );

  blocTest<SignInCubit, SignInState>(
    'wrong password: the error',
    setUp: () => when(
      () => repository.signInWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Err(wrongPassword)),
    build: build,
    act: (cubit) => cubit.signInWithEmail(email: 'a@b.co', password: 'x'),
    expect: () => const [SignInLoading(), SignInError(wrongPassword)],
  );

  blocTest<SignInCubit, SignInState>(
    'sign-up passes the trimmed name',
    build: build,
    act: (cubit) => cubit.signUpWithEmail(
      name: ' Lamees ',
      email: 'a@b.co',
      password: 'secret1',
    ),
    expect: () => const [SignInLoading(), SignInSuccess()],
    verify: (_) => verify(
      () => repository.signUpWithEmail(
        email: 'a@b.co',
        password: 'secret1',
        name: 'Lamees',
      ),
    ).called(1),
  );

  blocTest<SignInCubit, SignInState>(
    'password reset: tells which email got the link',
    build: build,
    act: (cubit) => cubit.sendPasswordResetEmail(' a@b.co '),
    expect: () => const [SignInLoading(), SignInResetEmailSent('a@b.co')],
  );

  blocTest<SignInCubit, SignInState>(
    'password reset offline: the error',
    setUp: () => when(
      () => repository.sendPasswordResetEmail(any()),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: build,
    act: (cubit) => cubit.sendPasswordResetEmail('a@b.co'),
    expect: () => const [SignInLoading(), SignInError(NetworkFailure())],
  );

  test('taps while loading are ignored', () async {
    final pending = Completer<Result<AppUser>>();
    when(
      () => repository.signInWithGoogle(),
    ).thenAnswer((_) => pending.future);
    final cubit = build();

    unawaited(cubit.signInWithGoogle());
    await cubit.signInWithGoogle();
    await cubit.sendPasswordResetEmail('a@b.co');
    pending.complete(const Success(tUser));
    await pumpEventQueue();

    verify(() => repository.signInWithGoogle()).called(1);
    verifyNever(() => repository.sendPasswordResetEmail(any()));
    expect(cubit.state, const SignInSuccess());
    await cubit.close();
  });
}
