import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Maps a [Failure] to the localized text shown to the user.
extension FailureMessage on Failure {
  String message(AppLocalizations l10n) => switch (this) {
    NetworkFailure() => l10n.commonErrorNetwork,
    ServerFailure() => l10n.commonErrorServer,
    NotFoundFailure() => l10n.commonNotFound,
    CacheFailure() => l10n.commonCacheError,
    UnknownFailure() => l10n.commonErrorGeneric,
    AuthFailure(:final error) => switch (error) {
      AuthError.invalidCredentials => l10n.authErrorInvalidCredentials,
      AuthError.emailAlreadyInUse => l10n.authErrorEmailInUse,
      AuthError.weakPassword => l10n.authErrorWeakPassword,
      AuthError.invalidEmail => l10n.authErrorInvalidEmail,
      AuthError.userDisabled => l10n.authErrorUserDisabled,
      AuthError.tooManyRequests => l10n.authErrorTooManyRequests,
      AuthError.requiresRecentLogin => l10n.authErrorRequiresRecentLogin,
      AuthError.cancelled => l10n.authErrorCancelled,
      AuthError.unavailable => l10n.authErrorUnavailable,
      AuthError.unknown => l10n.commonErrorGeneric,
    },
  };
}
