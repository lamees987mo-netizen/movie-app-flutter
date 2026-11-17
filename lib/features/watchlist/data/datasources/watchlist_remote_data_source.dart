import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';

/// The signed-in user's watchlist in the cloud.
///
/// An interface, so the sync logic can be tested with a mock instead of a
/// real Firestore. Every method throws a [NetworkException] when Firestore
/// can't be reached and a [ServerException] for any other error.
abstract interface class WatchlistRemoteDataSource {
  Future<List<SavedMovieModel>> getAll(String uid);

  Future<void> put(String uid, SavedMovieModel entry);

  Future<void> putAll(String uid, List<SavedMovieModel> entries);

  Future<void> remove(String uid, int movieId);

  Future<void> removeAll(String uid);
}

/// Stores one document per movie at `users/{uid}/watchlist/{movieId}`,
/// with the same JSON as the Hive box ([SavedMovieModel.toJson]).
///
/// The security rules (`firestore.rules`) only let a user read and write
/// documents under their own `users/{uid}`.
///
/// Firestore keeps its own offline cache on Android and iOS: a write made
/// offline is saved on the phone and sent when the connection is back.
/// That is also why a write's `Future` can stay pending for a long time
/// while offline, so callers should not make the UI wait for it.
class FirestoreWatchlistDataSource implements WatchlistRemoteDataSource {
  FirestoreWatchlistDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Firestore accepts at most 500 writes in one batch.
  static const int _maxBatchSize = 500;

  CollectionReference<Map<String, dynamic>> _watchlist(String uid) =>
      _firestore.collection('users').doc(uid).collection('watchlist');

  @override
  Future<List<SavedMovieModel>> getAll(String uid) => _guard(() async {
    final snapshot = await _watchlist(uid).get();
    return snapshot.docs
        .map((document) => SavedMovieModel.fromJson(document.data()))
        .toList();
  });

  @override
  Future<void> put(String uid, SavedMovieModel entry) => _guard(
    () => _watchlist(uid).doc('${entry.movie.id}').set(entry.toJson()),
  );

  @override
  Future<void> putAll(String uid, List<SavedMovieModel> entries) => _guard(
    () => _inBatches(entries, (batch, entry) {
      batch.set(_watchlist(uid).doc('${entry.movie.id}'), entry.toJson());
    }),
  );

  @override
  Future<void> remove(String uid, int movieId) =>
      _guard(() => _watchlist(uid).doc('$movieId').delete());

  @override
  Future<void> removeAll(String uid) => _guard(() async {
    final snapshot = await _watchlist(uid).get();
    await _inBatches(
      snapshot.docs,
      (batch, document) => batch.delete(document.reference),
    );
  });

  /// Writes [items] in batches of at most [_maxBatchSize]. A batch is
  /// all-or-nothing, and much faster than one request per movie.
  Future<void> _inBatches<T>(
    List<T> items,
    void Function(WriteBatch batch, T item) write,
  ) async {
    for (var start = 0; start < items.length; start += _maxBatchSize) {
      final batch = _firestore.batch();
      items.skip(start).take(_maxBatchSize).forEach((item) {
        write(batch, item);
      });
      await batch.commit();
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (error) {
      // "unavailable": offline, or the server could not be reached.
      if (error.code == 'unavailable') throw const NetworkException();
      throw ServerException(message: error.code);
    } on Object catch (error) {
      // E.g. a TypeError from a document with an unexpected shape.
      throw ServerException(message: error.toString());
    }
  }
}
