import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../../auth_test_helpers.dart';

void main() {
  late MockAuthRepository repository;
  late StreamController<AppUser?> users;

  setUp(() {
    repository = MockAuthRepository();
    users = StreamController<AppUser?>();
    when(() => repository.currentUser).thenReturn(null);
    when(() => repository.userChanges()).thenAnswer((_) => users.stream);
  });

  tearDown(() => users.close());

  test('starts signed out for a guest', () async {
    final cubit = AuthCubit(repository: repository);

    expect(cubit.state, const AuthSignedOut());
    await cubit.close();
  });

  test('starts signed in when Firebase remembers the user', () async {
    when(() => repository.currentUser).thenReturn(tUser);
    final cubit = AuthCubit(repository: repository);

    expect(cubit.state, const AuthSignedIn(tUser));
    await cubit.close();
  });

  blocTest<AuthCubit, AuthState>(
    'follows signed out -> signed in -> signed out',
    build: () => AuthCubit(repository: repository),
    act: (_) async {
      users
        ..add(tUser)
        ..add(null);
    },
    expect: () => const [AuthSignedIn(tUser), AuthSignedOut()],
  );

  blocTest<AuthCubit, AuthState>(
    'keeps the last user when the stream reports an error',
    build: () => AuthCubit(repository: repository),
    act: (_) async {
      users
        ..add(tUser)
        ..addError(StateError('boom'));
    },
    expect: () => const [AuthSignedIn(tUser)],
  );

  test('close stops listening', () async {
    final cubit = AuthCubit(repository: repository);
    await cubit.close();

    expect(users.hasListener, isFalse);
  });
}
