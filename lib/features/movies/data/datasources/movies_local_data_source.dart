import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

/// Keeps the first page of each Home section, and the details of every
/// movie the user opened, on the device. So Home and the details screen
/// (and with it the watchlist) still work when there is no internet.
///
/// Throws a [CacheException] on any storage error.
abstract interface class MoviesLocalDataSource {
  Future<void> cacheFirstPage(
    MovieCategory category,
    String languageCode,
    MoviesPageModel page,
  );

  /// `null` when nothing was saved yet for this category and language.
  MoviesPageModel? getCachedFirstPage(
    MovieCategory category,
    String languageCode,
  );

  Future<void> cacheMovieDetails(
    String languageCode,
    MovieDetailsModel details,
  );

  /// `null` when this movie was never opened in this language.
  MovieDetailsModel? getCachedMovieDetails(int movieId, String languageCode);
}

class MoviesLocalDataSourceImpl implements MoviesLocalDataSource {
  MoviesLocalDataSourceImpl(this._box);

  /// The `homeCache` box.
  final Box<dynamic> _box;

  /// One entry per category AND language (e.g. `trending_ar`), so Arabic
  /// titles are never shown when the app is in English, and the reverse.
  static String _pageKey(MovieCategory category, String languageCode) =>
      '${category.name}_$languageCode';

  /// Same idea for details: `details_1022789_ar`. The `details_` prefix
  /// keeps these keys apart from the page keys in the same box.
  static String _detailsKey(int movieId, String languageCode) =>
      'details_${movieId}_$languageCode';

  // Everything is stored as a JSON *string*, not as a map: after an app
  // restart Hive returns nested maps as `Map<dynamic, dynamic>`, which
  // `fromJson` cannot read directly. A string avoids that problem.

  @override
  Future<void> cacheFirstPage(
    MovieCategory category,
    String languageCode,
    MoviesPageModel page,
  ) => _write(_pageKey(category, languageCode), page.toJson());

  @override
  MoviesPageModel? getCachedFirstPage(
    MovieCategory category,
    String languageCode,
  ) => _read(_pageKey(category, languageCode), MoviesPageModel.fromJson);

  @override
  Future<void> cacheMovieDetails(
    String languageCode,
    MovieDetailsModel details,
  ) {
    // `toJson` writes `cast` and `videos` as flat lists, but `fromJson`
    // reads them from where TMDB puts them (`credits.cast` and
    // `videos.results`). So save them in TMDB's shape.
    final json = details.toJson();
    json['credits'] = {'cast': json.remove('cast')};
    json['videos'] = {'results': json['videos']};
    return _write(_detailsKey(details.id, languageCode), json);
  }

  @override
  MovieDetailsModel? getCachedMovieDetails(int movieId, String languageCode) =>
      _read(_detailsKey(movieId, languageCode), MovieDetailsModel.fromJson);

  Future<void> _write(String key, Map<String, dynamic> json) async {
    try {
      await _box.put(key, jsonEncode(json));
    } on Object catch (error) {
      throw CacheException(error.toString());
    }
  }

  T? _read<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final raw = _box.get(key);
      if (raw == null) return null;
      return fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    } on Object catch (error) {
      throw CacheException(error.toString());
    }
  }
}
