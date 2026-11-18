import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

/// Signing in and out, and the account itself.
///
/// Like every repository it never throws: errors come back as an `Err`
/// holding an `AuthFailure` (wrong password, cancelled, ...) or a
/// `NetworkFailure`.
abstract interface class AuthRepository {
  /// The signed-in user right now, or `null` for a guest.
  AppUser? get currentUser;

  /// Emits the current user (or `null`) when listened to, then again on
  /// every sign-in, sign-out and profile change.
  Stream<AppUser?> userChanges();

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<AppUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates an account and signs in. [name] becomes the display name.
  Future<Result<AppUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  /// Sends a "reset your password" link to [email].
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Changes the signed-in user's display name. Returns the updated user.
  Future<Result<AppUser>> updateDisplayName(String name);

  Future<Result<void>> signOut();

  /// Deletes the signed-in user's account (only the account: the cloud
  /// data is deleted by the `DeleteAccount` use case first).
  Future<Result<void>> deleteAccount();
}
