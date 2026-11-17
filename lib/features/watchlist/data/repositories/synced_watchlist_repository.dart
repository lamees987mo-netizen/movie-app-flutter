import 'dart:async';

import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/sync/watchlist_sync_service.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

/// Adds cloud sync to the local [WatchlistRepository] (a "decorator").
///
/// It has the same interface, so cubits and screens don't know whether
/// sync is on. Reads go straight to the local repository; a successful
/// toggle is also sent to the cloud through [WatchlistSyncService].
///
/// The cloud write is not awaited: the button reacts as soon as Hive has
/// saved the change, even on a slow or missing connection.
class SyncedWatchlistRepository implements WatchlistRepository {
  SyncedWatchlistRepository(this._local, this._sync);

  final WatchlistRepository _local;
  final WatchlistSyncService _sync;

  @override
  Future<Result<List<Movie>>> getAll() => _local.getAll();

  @override
  Future<Result<bool>> isInWatchlist(int movieId) =>
      _local.isInWatchlist(movieId);

  @override
  Stream<List<Movie>> watch() => _local.watch();

  @override
  Future<Result<bool>> toggle(Movie movie) async {
    final result = await _local.toggle(movie);
    if (result case Success(value: final saved)) {
      unawaited(_sync.pushChange(movie, saved: saved));
    }
    return result;
  }
}
