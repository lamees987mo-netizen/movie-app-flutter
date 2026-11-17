import 'dart:async';
import 'dart:developer';

import 'package:movie_app/core/account/user_cloud_data.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:movie_app/features/watchlist/data/datasources/watchlist_remote_data_source.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';

/// Keeps the Hive watchlist and the signed-in user's Firestore copy in sync.
///
/// Hive stays the source of truth for the screens (it works offline and
/// answers at once); Firestore is a copy that follows the user to other
/// devices. The rules:
///
/// - **Sign-in** ([bind] sees a user id): merge both lists. Movies only in
///   the cloud are saved to Hive (with their original date); movies only on
///   the phone (e.g. saved as a guest) are uploaded. Nothing is deleted, so
///   the result is the union of both lists.
/// - **While signed in**: every add/remove is written to Hive first, then
///   to Firestore ([pushChange]). A Firestore error is only logged: the
///   local change already happened, and Firestore itself retries writes
///   made offline once the connection is back.
/// - **Sign-out** ([bind] sees `null` after a user): clear Hive. The list
///   is safe in the account, and the next person using the phone must not
///   see it.
///
/// Known limit: a movie removed on one device while another device is
/// offline comes back at that device's next merge, because the merge never
/// deletes (nothing records deletions). Acceptable for a watchlist.
class WatchlistSyncService implements UserCloudData {
  /// [clock] and the delete timeout are only changed in tests.
  WatchlistSyncService({
    required this._local,
    required this._remote,
    DateTime Function()? clock,
    this._deleteTimeout = const Duration(seconds: 20),
  }) : _clock = clock ?? DateTime.now;

  final WatchlistLocalDataSource _local;
  final WatchlistRemoteDataSource _remote;
  final DateTime Function() _clock;
  final Duration _deleteTimeout;

  StreamSubscription<String?>? _subscription;

  /// The signed-in user's id, or `null` for a guest.
  String? get userId => _userId;
  String? _userId;

  /// Follows the signed-in user. [userIds] emits the user's id, or `null`
  /// when nobody is signed in. `initDependencies` calls this once at
  /// startup with the auth feature's user stream.
  ///
  /// A first `null` (a guest opening the app) clears nothing: only a
  /// change from a user to `null` is a sign-out.
  void bind(Stream<String?> userIds) {
    unawaited(_subscription?.cancel());
    _subscription = userIds.distinct().listen(
      (userId) => unawaited(onUserChanged(userId)),
      onError: (Object error, StackTrace stackTrace) =>
          log('User stream error', error: error, stackTrace: stackTrace),
    );
  }

  /// Reacts to a sign-in, sign-out or account switch. Never throws.
  /// Public so tests can await it; the app calls it through [bind].
  Future<void> onUserChanged(String? userId) async {
    final previous = _userId;
    if (userId == previous) return;
    _userId = userId;
    // Signed out, or switched accounts: the old account's list must go.
    if (previous != null) await _clearLocal();
    if (userId != null) await _merge(userId);
  }

  /// Writes one add or remove to the cloud. Does nothing for guests, and
  /// never throws: errors are logged, and the local change stays.
  Future<void> pushChange(Movie movie, {required bool saved}) async {
    final userId = _userId;
    if (userId == null) return;
    try {
      if (saved) {
        await _remote.put(
          userId,
          SavedMovieModel(
            movie: MovieModel.fromEntity(movie),
            addedAt: _clock(),
          ),
        );
      } else {
        await _remote.remove(userId, movie.id);
      }
    } on Object catch (error, stackTrace) {
      log(
        'Could not sync movie ${movie.id}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _merge(String userId) async {
    try {
      final remote = await _remote.getAll(userId);
      // The user signed out (or switched) while we were waiting.
      if (_userId != userId) return;

      final local = _local.getAllSaved();
      final localIds = {for (final entry in local) entry.movie.id};
      final remoteIds = {for (final entry in remote) entry.movie.id};

      final toDownload = [
        for (final entry in remote)
          if (!localIds.contains(entry.movie.id)) entry,
      ];
      final toUpload = [
        for (final entry in local)
          if (!remoteIds.contains(entry.movie.id)) entry,
      ];

      // Download first: it is local and fast, so the screen updates even
      // if the upload has to wait for a connection.
      if (toDownload.isNotEmpty) await _local.putAll(toDownload);
      if (toUpload.isNotEmpty) await _remote.putAll(userId, toUpload);
    } on Object catch (error, stackTrace) {
      // Not fatal: the local list still works, and the next sign-in or
      // app start merges again.
      log('Watchlist merge failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _clearLocal() async {
    try {
      await _local.clear();
    } on Object catch (error, stackTrace) {
      log(
        'Could not clear the watchlist',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes the user's cloud watchlist (before deleting the account).
  ///
  /// Gives up after a timeout: offline, Firestore waits for the connection
  /// forever, and "Delete account" would keep spinning.
  @override
  Future<Result<void>> deleteCloudData(String uid) async {
    try {
      await _remote.removeAll(uid).timeout(_deleteTimeout);
      return const Success(null);
    } on NetworkException {
      return const Err(NetworkFailure());
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on Object catch (error, stackTrace) {
      log(
        'Could not delete the cloud watchlist',
        error: error,
        stackTrace: stackTrace,
      );
      return const Err(ServerFailure());
    }
  }

  @override
  Future<void> restoreCloudData(String uid) async {
    try {
      await _remote.putAll(uid, _local.getAllSaved());
    } on Object catch (error, stackTrace) {
      log(
        'Could not restore the cloud watchlist',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Stops following the user. The app never calls it (the service lives
  /// as long as the app); tests do.
  Future<void> dispose() async => _subscription?.cancel();
}
