import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/domain/usecases/delete_account.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserCloudData extends Mock implements UserCloudData {}

void main() {
  late MockAuthRepository auth;
  late MockUserCloudData cloudData;
  late DeleteAccount deleteAccount;

  const recentLogin = AuthFailure(AuthError.requiresRecentLogin);

  setUp(() {
    auth = MockAuthRepository();
    cloudData = MockUserCloudData();
    deleteAccount = DeleteAccount(auth: auth, cloudData: cloudData);
    when(() => auth.currentUser).thenReturn(const AppUser(uid: 'u1'));
    when(
      () => cloudData.deleteCloudData(any()),
    ).thenAnswer((_) async => const Success(null));
    when(() => cloudData.restoreCloudData(any())).thenAnswer((_) async {});
    when(
      () => auth.deleteAccount(),
    ).thenAnswer((_) async => const Success(null));
  });

  test('deletes the cloud data first, then the account', () async {
    expect(await deleteAccount(), const Success<void>(null));

    verifyInOrder([
      () => cloudData.deleteCloudData('u1'),
      () => auth.deleteAccount(),
    ]);
    verifyNever(() => cloudData.restoreCloudData(any()));
  });

  test('keeps the account when the data could not be deleted', () async {
    when(
      () => cloudData.deleteCloudData(any()),
    ).thenAnswer((_) async => const Err(NetworkFailure()));

    expect(await deleteAccount(), const Err<void>(NetworkFailure()));
    verifyNever(() => auth.deleteAccount());
    verify(() => cloudData.restoreCloudData('u1')).called(1);
  });

  test('puts the data back when deleting the account fails', () async {
    when(
      () => auth.deleteAccount(),
    ).thenAnswer((_) async => const Err(recentLogin));

    expect(await deleteAccount(), const Err<void>(recentLogin));
    verify(() => cloudData.restoreCloudData('u1')).called(1);
  });

  test('does nothing for a guest', () async {
    when(() => auth.currentUser).thenReturn(null);

    expect(
      await deleteAccount(),
      const Err<void>(AuthFailure(AuthError.unknown)),
    );
    verifyZeroInteractions(cloudData);
  });

  test('NoUserCloudData (no Firebase) has nothing to delete', () async {
    const none = NoUserCloudData();

    expect(await none.deleteCloudData('u1'), const Success<void>(null));
    await expectLater(none.restoreCloudData('u1'), completes);
  });
}
