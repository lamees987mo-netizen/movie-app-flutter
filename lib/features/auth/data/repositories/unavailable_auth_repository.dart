import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';

/// Used when Firebase is not running (widget tests, integration tests,
/// desktop): nobody is ever signed in, and every action answers
/// [AuthError.unavailable]. The app works as a guest, like before sign-in
/// existed.
///
/// The same idea as `NoopAnalyticsService`.
class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  static const _unavailable = AuthFailure(AuthError.unavailable);

  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> userChanges() => Stream.value(null);

  @override
  Future<Result<AppUser>> signInWithGoogle() async => const Err(_unavailable);

  @override
  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async => const Err(_unavailable);

  @override
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async => const Err(_unavailable);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async =>
      const Err(_unavailable);

  @override
  Future<Result<AppUser>> updateDisplayName(String name) async =>
      const Err(_unavailable);

  @override
  Future<Result<void>> signOut() async => const Err(_unavailable);

  @override
  Future<Result<void>> deleteAccount() async => const Err(_unavailable);
}
