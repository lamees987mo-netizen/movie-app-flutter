import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';

/// Loads everything the details screen shows, in one request.
///
/// Today it only forwards to the repository. It exists because the details
/// screen is where business rules tend to grow (e.g. "merge in the
/// watchlist flag" or "prefer a localized trailer"). When that happens, the
/// logic goes here, so the cubit stays about UI state only.
///
/// Callable class: use it like a function, `await getMovieDetails(id)`.
class GetMovieDetails {
  const GetMovieDetails(this._repository);

  final MoviesRepository _repository;

  Future<Result<MovieDetails>> call(int movieId) =>
      _repository.getMovieDetails(movieId);
}
