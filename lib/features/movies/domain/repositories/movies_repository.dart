import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';

/// The contract the presentation layer depends on.
///
/// Methods never throw: errors come back as `Err(failure)`.
abstract interface class MoviesRepository {
  Future<Result<PaginatedMovies>> getMovies(
    MovieCategory category, {
    int page = 1,
  });

  Future<Result<MovieDetails>> getMovieDetails(int movieId);

  Future<Result<PaginatedMovies>> searchMovies(String query, {int page = 1});
}
