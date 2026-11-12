import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Locally saved movies (Hive). Works fully offline.
abstract interface class WatchlistRepository {
  Future<Result<List<Movie>>> getAll();

  Future<Result<bool>> isInWatchlist(int movieId);

  /// Adds the movie if missing, removes it otherwise.
  /// Returns `true` when the movie is in the watchlist afterwards.
  Future<Result<bool>> toggle(Movie movie);

  /// Emits the full list every time the watchlist changes.
  Stream<List<Movie>> watch();
}
