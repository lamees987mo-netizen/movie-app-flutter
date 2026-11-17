import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/usecases/delete_account.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';

import '../../auth_test_helpers.dart';

class MockDeleteAccount extends Mock implements DeleteAccount {}

void main() {
  late MockAuthRepository repository;
  late MockDeleteAccount deleteAccount;

  const recentLogin = AuthFailure(AuthError.requiresRecentLogin);

  setUp(() {
    repository = MockAuthRepository();
    deleteAccount = MockDeleteAccount();
    when(
      () => repository.signOut(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => deleteAccount.call(),
    ).thenAnswer((_) async => const Success(null));
  });

  AccountCubit build() =>
      AccountCubit(repository: repository, deleteAccount: deleteAccount);

  blocTest<AccountCubit, AccountState>(
    'sign out: busy, then idle again',
    build: build,
    act: (cubit) => cubit.signOut(),
    expect: () => const [AccountBusy(), AccountIdle()],
    verify: (_) => verify(() => repository.signOut()).called(1),
  );

  blocTest<AccountCubit, AccountState>(
    'sign out failing: the error',
    setUp: () => when(
      () => repository.signOut(),
    ).thenAnswer((_) async => const Err(UnknownFailure())),
    build: build,
    act: (cubit) => cubit.signOut(),
    expect: () => const [AccountBusy(), AccountError(UnknownFailure())],
  );

  blocTest<AccountCubit, AccountState>(
    'delete: busy, then deleted',
    build: build,
    act: (cubit) => cubit.deleteAccount(),
    expect: () => const [AccountBusy(), AccountDeleted()],
  );

  blocTest<AccountCubit, AccountState>(
    'delete needing a fresh sign-in: the error',
    setUp: () => when(
      () => deleteAccount.call(),
    ).thenAnswer((_) async => const Err(recentLogin)),
    build: build,
    act: (cubit) => cubit.deleteAccount(),
    expect: () => const [AccountBusy(), AccountError(recentLogin)],
  );

  blocTest<AccountCubit, AccountState>(
    'a second tap while busy is ignored',
    build: build,
    act: (cubit) async {
      final first = cubit.deleteAccount();
      await cubit.signOut();
      await first;
    },
    expect: () => const [AccountBusy(), AccountDeleted()],
    verify: (_) => verifyNever(() => repository.signOut()),
  );
}
