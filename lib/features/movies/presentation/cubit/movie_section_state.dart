import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The state of one horizontal movie list on the Home screen.
///
/// `sealed` means these three classes are the only possible states, so a
/// `switch (state)` in the UI must handle all of them.
sealed class MovieSectionState extends Equatable {
  const MovieSectionState();

  @override
  List<Object?> get props => [];
}

/// The first request is in flight: show a skeleton.
final class MovieSectionLoading extends MovieSectionState {
  const MovieSectionLoading();
}

final class MovieSectionLoaded extends MovieSectionState {
  const MovieSectionLoaded(this.movies);

  final List<Movie> movies;

  @override
  List<Object?> get props => [movies];
}

final class MovieSectionError extends MovieSectionState {
  const MovieSectionError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
