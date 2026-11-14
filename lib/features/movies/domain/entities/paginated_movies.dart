import 'package:equatable/equatable.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// One page of movies plus what is needed to load the next one.
class PaginatedMovies extends Equatable {
  const PaginatedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
    this.isFromCache = false,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;

  /// `true` when the page was read from the offline cache because the
  /// network failed. The UI uses it to show the "You're offline" banner,
  /// also when the phone has Wi-Fi but no real internet.
  final bool isFromCache;

  /// `true` when there is no next page to request.
  bool get hasReachedMax => page >= totalPages;

  @override
  List<Object?> get props => [movies, page, totalPages, isFromCache];
}
