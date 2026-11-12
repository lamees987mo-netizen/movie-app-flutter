import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';

/// The outcome of a repository call: either a [Success] or an [Err].
///
/// Read it with [fold], or with a `switch` and pattern matching:
/// ```dart
/// switch (result) {
///   case Success(:final value): ...
///   case Err(:final failure): ...
/// }
/// ```
sealed class Result<T> extends Equatable {
  const Result();

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T value) onSuccess,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Err(:final failure) => onFailure(failure),
  };

  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
