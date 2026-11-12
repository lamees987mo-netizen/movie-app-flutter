import 'dart:async';
import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._dataSource);

  final WatchlistLocalDataSource _dataSource;

  @override
  Future<Result<List<Movie>>> getAll() => _guard(_readAll);

  @override
  Future<Result<bool>> isInWatchlist(int movieId) =>
      _guard(() => _dataSource.contains(movieId));

  @override
  Future<Result<bool>> toggle(Movie movie) => _guard(() async {
    if (_dataSource.contains(movie.id)) {
      await _dataSource.remove(movie.id);
      return false;
    }
    await _dataSource.add(MovieModel.fromEntity(movie));
    return true;
  });

  /// Emits the current list right away, then again after every change.
  ///
  /// A read that fails is emitted as a stream *error* holding a [Failure]
  /// and the stream keeps going, so listeners never see raw exceptions.
  ///
  /// Not an `async*` generator on purpose: one waiting in `await for`
  /// only stops at its next `yield`, so cancelling it (e.g. in a cubit's
  /// `close`) would hang until the box changed again.
  @override
  Stream<List<Movie>> watch() => Stream.multi((controller) {
    void emitSnapshot() {
      try {
        controller.add(_readAll());
      } on Object catch (error, stackTrace) {
        controller.addError(_toFailure(error, stackTrace));
      }
    }

    emitSnapshot();
    final subscription = _dataSource.changes().listen(
      (_) => emitSnapshot(),
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  List<Movie> _readAll() =>
      _dataSource.getAll().map((model) => model.toEntity()).toList();

  /// Runs [action] and converts any exception into the matching [Failure].
  Future<Result<T>> _guard<T>(FutureOr<T> Function() action) async {
    try {
      return Success(await action());
    } on Object catch (error, stackTrace) {
      return Err(_toFailure(error, stackTrace));
    }
  }

  static Failure _toFailure(Object error, StackTrace stackTrace) {
    if (error is CacheException) return const CacheFailure();
    // Not expected: the data source wraps everything in CacheException.
    log('Unexpected watchlist error', error: error, stackTrace: stackTrace);
    return const UnknownFailure();
  }
}
