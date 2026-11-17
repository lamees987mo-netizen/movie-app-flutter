import 'package:google_sign_in/google_sign_in.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';

/// Shows Google's account picker and returns the chosen account's ID token,
/// which Firebase turns into a signed-in user.
///
/// A small interface around the `google_sign_in` plugin, so the Firebase
/// data source can be tested without a real Google account.
abstract interface class GoogleSignInClient {
  /// Throws an [AuthException] (e.g. [AuthError.cancelled] when the user
  /// closes the picker).
  Future<String> signIn();

  /// Forgets the chosen account, so the picker shows again next time.
  /// Never throws.
  Future<void> signOut();
}

/// Uses `google_sign_in` 7, whose singleton must be initialized once
/// before use.
///
/// On Android no client id is needed: the plugin reads the web client id
/// from `google-services.json`. On iOS it reads `GIDClientID` from
/// `Info.plist`, unless [clientId] is given.
class GoogleSignInClientImpl implements GoogleSignInClient {
  GoogleSignInClientImpl(this._google, {this.clientId});

  final GoogleSignIn _google;
  final String? clientId;

  Future<void>? _initialization;

  @override
  Future<String> signIn() async {
    try {
      await _initialize();
      if (!_google.supportsAuthenticate()) {
        throw const AuthException(AuthError.unavailable);
      }
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) throw const AuthException(AuthError.unknown);
      return idToken;
    } on GoogleSignInException catch (error) {
      throw AuthException(_toAuthError(error.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _initialize();
      await _google.signOut();
    } on Object {
      // Nothing to do: the Firebase sign-out is what really matters.
    }
  }

  /// Starts `initialize()` once and reuses it; after a failure the next
  /// call tries again.
  Future<void> _initialize() async {
    try {
      await (_initialization ??= _google.initialize(clientId: clientId));
    } on Object {
      _initialization = null;
      rethrow;
    }
  }

  static AuthError _toAuthError(GoogleSignInExceptionCode code) =>
      switch (code) {
        // On Android some setup errors (e.g. a missing SHA fingerprint)
        // also arrive as "canceled"; the plugin can't tell them apart.
        GoogleSignInExceptionCode.canceled ||
        GoogleSignInExceptionCode.interrupted => AuthError.cancelled,
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          AuthError.unavailable,
        _ => AuthError.unknown,
      };
}
