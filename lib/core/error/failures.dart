import 'package:equatable/equatable.dart';

/// Errors as seen by the domain and presentation layers.
///
/// Because the class is `sealed`, a `switch` over a [Failure] must handle
/// every subtype, so the compiler reminds us when a new one is added.
/// Turn a failure into user-facing text with `failure.message(l10n)`
/// (see `failure_message.dart`).
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class ServerFailure extends Failure {
  const ServerFailure([this.statusCode]);

  final int? statusCode;

  @override
  List<Object?> get props => [statusCode];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

final class CacheFailure extends Failure {
  const CacheFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure();
}

/// Why signing in, signing up or changing the account failed.
///
/// One enum instead of one class per reason: the UI only needs the reason
/// to pick a message (see `failure_message.dart`).
enum AuthError {
  /// Wrong email or password. Firebase no longer says which of the two, so
  /// nobody can find out which emails have an account.
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  invalidEmail,
  userDisabled,
  tooManyRequests,

  /// Deleting the account needs a fresh sign-in (Firebase asks for one when
  /// the last sign-in is more than a few minutes old).
  requiresRecentLogin,

  /// The user closed the Google account picker.
  cancelled,

  /// Sign-in is not set up: no Firebase (tests, desktop), or the method is
  /// not enabled in the Firebase console.
  unavailable,
  unknown,
}

/// A sign-in or account error. A lost connection is a [NetworkFailure]
/// instead, so it shows the same message as everywhere else in the app.
final class AuthFailure extends Failure {
  const AuthFailure(this.error);

  final AuthError error;

  @override
  List<Object?> get props => [error];
}
