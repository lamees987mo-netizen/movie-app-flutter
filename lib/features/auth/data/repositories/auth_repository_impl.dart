import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthRemoteDataSource _dataSource;

  @override
  AppUser? get currentUser => _dataSource.currentUser;

  @override
  Stream<AppUser?> userChanges() => _dataSource.userChanges();

  @override
  Future<Result<AppUser>> signInWithGoogle() =>
      _guard(_dataSource.signInWithGoogle);

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(
    () => _dataSource.signInWithEmail(email: email, password: password),
  );

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) => _guard(
    () => _dataSource.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    ),
  );

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      _guard(() => _dataSource.sendPasswordResetEmail(email));

  @override
  Future<Result<void>> signOut() => _guard(_dataSource.signOut);

  @override
  Future<Result<void>> deleteAccount() => _guard(_dataSource.deleteAccount);

  /// Runs [action] and converts any exception into the matching [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on AuthException catch (error) {
      return Err(AuthFailure(error.error));
    } on NetworkException {
      return const Err(NetworkFailure());
    } on Object catch (error, stackTrace) {
      // Not expected: the data source translates every error.
      log('Unexpected auth error', error: error, stackTrace: stackTrace);
      return const Err(UnknownFailure());
    }
  }
}
