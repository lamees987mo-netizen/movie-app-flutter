import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';

/// Reads and writes the watchlist in the Hive `watchlist` box.
///
/// Every method throws a [CacheException] when Hive fails or a stored entry
/// cannot be read.
abstract interface class WatchlistLocalDataSource {
  /// The saved movies, most recently added first.
  List<MovieModel> getAll();

  bool contains(int movieId);

  Future<void> add(MovieModel movie);

  Future<void> remove(int movieId);

  /// Emits (without data) after every change to the box.
  Stream<void> changes();
}

/// Storage format: key = movie id, value = `MovieModel.toJson()` plus an
/// extra `added_at` field (milliseconds since epoch) used to sort the list
/// newest first. `MovieModel.fromJson` ignores the extra field, so no type
/// adapters are needed.
class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  /// [clock] is only replaced in tests, to control the `added_at` order.
  WatchlistLocalDataSourceImpl(this._box, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Box<dynamic> _box;
  final DateTime Function() _clock;

  static const String addedAtKey = 'added_at';

  @override
  List<MovieModel> getAll() => _guard(() {
    final entries = _box.values.map(_toJsonMap).toList()
      ..sort((a, b) {
        final byDate = _addedAt(b).compareTo(_addedAt(a));
        // Same timestamp: fall back to the id, so the order stays stable.
        if (byDate != 0) return byDate;
        return (b['id'] as num).compareTo(a['id'] as num);
      });
    return entries.map(MovieModel.fromJson).toList();
  });

  @override
  bool contains(int movieId) => _guard(() => _box.containsKey(movieId));

  @override
  Future<void> add(MovieModel movie) => _guardAsync(
    () => _box.put(movie.id, <String, dynamic>{
      ...movie.toJson(),
      addedAtKey: _clock().millisecondsSinceEpoch,
    }),
  );

  @override
  Future<void> remove(int movieId) => _guardAsync(() => _box.delete(movieId));

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

  static int _addedAt(Map<String, dynamic> json) =>
      (json[addedAtKey] as num?)?.toInt() ?? 0;

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
