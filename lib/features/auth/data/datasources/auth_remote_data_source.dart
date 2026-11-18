import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/data/datasources/google_sign_in_client.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

/// Talks to Firebase Authentication.
///
/// Every method throws an [AuthException] (with the reason already
/// translated) or a [NetworkException]; never a Firebase type, so the
/// repository doesn't depend on Firebase's error codes.
abstract interface class AuthRemoteDataSource {
  AppUser? get currentUser;

  Stream<AppUser?> userChanges();

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<AppUser> updateDisplayName(String name);

  Future<void> signOut();

  Future<void> deleteAccount();
}

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  FirebaseAuthDataSource(this._auth, this._google);

  final FirebaseAuth _auth;
  final GoogleSignInClient _google;

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  /// `userChanges` (not `authStateChanges`) so a new display name, set
  /// right after sign-up, reaches the screens too.
  @override
  Stream<AppUser?> userChanges() => _auth.userChanges().map(_toAppUser);

  @override
  Future<AppUser> signInWithGoogle() => _guard(() async {
    final idToken = await _google.signIn();
    final credential = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return _requireUser(credential.user);
  });

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _requireUser(credential.user);
  });

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null && name != null && name.isNotEmpty) {
      await user.updateDisplayName(name);
    }
    // `currentUser` has the new name; the credential's copy may not.
    return _requireUser(_auth.currentUser ?? user);
  });

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  @override
  Future<AppUser> updateDisplayName(String name) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthError.unknown);
    await user.updateDisplayName(name);
    // `userChanges` emits the new name too, so every screen updates.
    return _requireUser(_auth.currentUser ?? user);
  });

  @override
  Future<void> signOut() => _guard(() async {
    await _google.signOut();
    await _auth.signOut();
  });

  @override
  Future<void> deleteAccount() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException(AuthError.unknown);
    await user.delete();
    await _google.signOut();
  });

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          signInMethod: _signInMethodOf(user),
        );

  /// A user can have several providers (e.g. Google linked to an email
  /// account). Email wins, because then there is a password to change.
  static SignInMethod _signInMethodOf(User user) {
    final providers = user.providerData.map((info) => info.providerId);
    if (providers.contains(EmailAuthProvider.PROVIDER_ID)) {
      return SignInMethod.email;
    }
    if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
      return SignInMethod.google;
    }
    return SignInMethod.unknown;
  }

  static AppUser _requireUser(User? user) =>
      _toAppUser(user) ?? (throw const AuthException(AuthError.unknown));

  /// Runs [action] and translates Firebase's errors.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'network-request-failed') {
        throw const NetworkException();
      }
      throw AuthException(_toAuthError(error.code));
    } on Object catch (error, stackTrace) {
      log('Unexpected auth error', error: error, stackTrace: stackTrace);
      throw const AuthException(AuthError.unknown);
    }
  }

  /// Firebase error codes: https://firebase.google.com/docs/auth/admin/errors
  /// and the `FirebaseAuthException` docs of each method.
  static AuthError _toAuthError(String code) => switch (code) {
    // Newer projects (with email enumeration protection, the default)
    // answer "invalid-credential" for both a wrong password and an unknown
    // email; older ones use the two specific codes.
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'INVALID_LOGIN_CREDENTIALS' => AuthError.invalidCredentials,
    'email-already-in-use' => AuthError.emailAlreadyInUse,
    'weak-password' => AuthError.weakPassword,
    'invalid-email' => AuthError.invalidEmail,
    'user-disabled' => AuthError.userDisabled,
    'too-many-requests' => AuthError.tooManyRequests,
    'requires-recent-login' => AuthError.requiresRecentLogin,
    // The sign-in method is not enabled in the Firebase console.
    'operation-not-allowed' => AuthError.unavailable,
    _ => AuthError.unknown,
  };
}
