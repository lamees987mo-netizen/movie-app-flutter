import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/profile_cubit.dart';

import '../../auth_test_helpers.dart';

void main() {
  late MockAuthRepository repository;

  const renamed = AppUser(uid: 'u1', displayName: 'Lamees');

  setUp(() {
    repository = MockAuthRepository();
    when(
      () => repository.updateDisplayName(any()),
    ).thenAnswer((_) async => const Success(renamed));
  });

  ProfileCubit build() => ProfileCubit(repository: repository);

  test('starts idle', () {
    expect(build().state, const ProfileIdle());
  });

  blocTest<ProfileCubit, ProfileState>(
    'saving: busy, then saved, with the name trimmed',
    build: build,
    act: (cubit) => cubit.saveName('  Lamees  '),
    expect: () => const [ProfileSaving(), ProfileSaved()],
    verify: (_) =>
        verify(() => repository.updateDisplayName('Lamees')).called(1),
  );

  blocTest<ProfileCubit, ProfileState>(
    'a failure is shown',
    setUp: () => when(
      () => repository.updateDisplayName(any()),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: build,
    act: (cubit) => cubit.saveName('Lamees'),
    expect: () => const [ProfileSaving(), ProfileError(NetworkFailure())],
  );

  blocTest<ProfileCubit, ProfileState>(
    'a second tap while saving is ignored',
    build: build,
    act: (cubit) async {
      final first = cubit.saveName('A');
      await cubit.saveName('B');
      await first;
    },
    expect: () => const [ProfileSaving(), ProfileSaved()],
    verify: (_) => verifyNever(() => repository.updateDisplayName('B')),
  );
}
