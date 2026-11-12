import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';

/// The state of the Movie Details screen.
sealed class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

final class MovieDetailsLoading extends MovieDetailsState {
  const MovieDetailsLoading();
}

final class MovieDetailsLoaded extends MovieDetailsState {
  const MovieDetailsLoaded(this.details);

  final MovieDetails details;

  @override
  List<Object?> get props => [details];
}

final class MovieDetailsError extends MovieDetailsState {
  const MovieDetailsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
