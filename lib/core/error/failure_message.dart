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
  };
}
