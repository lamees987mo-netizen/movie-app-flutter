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
