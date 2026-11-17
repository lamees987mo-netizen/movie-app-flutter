import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/sign_in_cubit.dart';

/// Shared mocks and data for the auth feature's tests.
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockSignInCubit extends MockCubit<SignInState> implements SignInCubit {}

class MockAccountCubit extends MockCubit<AccountState>
    implements AccountCubit {}

const tUser = AppUser(
  uid: 'u1',
  email: 'lamees@example.com',
  displayName: 'Lamees Saad',
);

/// Email accounts may have no display name.
const tEmailOnlyUser = AppUser(uid: 'u2', email: 'ann@example.com');
