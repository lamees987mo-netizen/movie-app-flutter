import 'package:equatable/equatable.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// One page of movies plus what is needed to load the next one.
class PaginatedMovies extends Equatable {
  const PaginatedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;

  /// `true` when there is no next page to request.
  bool get hasReachedMax => page >= totalPages;

  @override
  List<Object?> get props => [movies, page, totalPages];
}
