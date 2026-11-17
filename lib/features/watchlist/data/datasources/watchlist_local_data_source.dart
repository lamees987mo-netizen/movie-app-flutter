import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';

/// Reads and writes the watchlist in the Hive `watchlist` box.
///
/// Every method throws a [CacheException] when Hive fails or a stored entry
/// cannot be read.
abstract interface class WatchlistLocalDataSource {
  /// The saved movies, most recently added first.
  List<MovieModel> getAll();

  /// Like [getAll], but with the date each movie was saved. Used by the
  /// cloud sync, which copies entries between devices without changing
  /// their order.
  List<SavedMovieModel> getAllSaved();

  bool contains(int movieId);

  /// Saves [movie] with the current time as its `added_at`.
  Future<void> add(MovieModel movie);

  /// Saves entries that already have an `added_at` (e.g. downloaded from
  /// the cloud), keeping their dates.
  Future<void> putAll(List<SavedMovieModel> entries);

  Future<void> remove(int movieId);

  /// Removes every movie (used when the user signs out).
  Future<void> clear();

  /// Emits (without data) after every change to the box.
  Stream<void> changes();
}

/// Storage format: key = movie id, value = [SavedMovieModel.toJson] (the
/// movie's JSON plus `added_at`), so no type adapters are needed.
class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  /// [clock] is only replaced in tests, to control the `added_at` order.
  WatchlistLocalDataSourceImpl(this._box, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Box<dynamic> _box;
  final DateTime Function() _clock;

  static const String addedAtKey = SavedMovieModel.addedAtKey;

  @override
  List<MovieModel> getAll() =>
      getAllSaved().map((entry) => entry.movie).toList();

  @override
  List<SavedMovieModel> getAllSaved() => _guard(() {
    return _box.values.map(_toJsonMap).map(SavedMovieModel.fromJson).toList()
      ..sort((a, b) {
        final byDate = b.addedAt.compareTo(a.addedAt);
        // Same timestamp: fall back to the id, so the order stays stable.
        if (byDate != 0) return byDate;
        return b.movie.id.compareTo(a.movie.id);
      });
  });

  @override
  bool contains(int movieId) => _guard(() => _box.containsKey(movieId));

  @override
  Future<void> add(MovieModel movie) => _guardAsync(
    () => _box.put(
      movie.id,
      SavedMovieModel(movie: movie, addedAt: _clock()).toJson(),
    ),
  );

  @override
  Future<void> putAll(List<SavedMovieModel> entries) => _guardAsync(
    () => _box.putAll({
      for (final entry in entries) entry.movie.id: entry.toJson(),
    }),
  );

  @override
  Future<void> remove(int movieId) => _guardAsync(() => _box.delete(movieId));

  @override
  Future<void> clear() => _guardAsync(_box.clear);

  @override
  Stream<void> changes() => _box.watch().map((_) {});

  /// While the app runs Hive gives back the map that was put, but after a
  /// restart it is a `Map<dynamic, dynamic>`, so copy it with String keys.
  /// Lists inside (`genre_ids`) come back as `List<dynamic>`, which
  /// `MovieModel.fromJson` handles.
  static Map<String, dynamic> _toJsonMap(dynamic value) {
    if (value is! Map) {
      throw CacheException('Unexpected watchlist entry: $value');
    }
    return value.map<String, dynamic>(
      (dynamic key, dynamic v) => MapEntry(key.toString(), v),
    );
  }

  T _guard<T>(T Function() action) {
    try {
      return action();
    } on CacheException {
      rethrow;
    } on Object catch (error) {
      // A HiveError, or a TypeError from an entry with an unexpected shape.
      throw CacheException(error.toString());
    }
  }

  Future<void> _guardAsync(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error) {
      throw CacheException(error.toString());
    }
  }
}
