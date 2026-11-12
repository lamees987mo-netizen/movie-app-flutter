import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

/// Keeps the first page of each Home section on the device, so Home can
/// still show something when there is no internet.
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
}

class MoviesLocalDataSourceImpl implements MoviesLocalDataSource {
  MoviesLocalDataSourceImpl(this._box);

  /// The `homeCache` box.
  final Box<dynamic> _box;

  /// One entry per category AND language (e.g. `trending_ar`), so Arabic
  /// titles are never shown when the app is in English, and the reverse.
  static String _key(MovieCategory category, String languageCode) =>
      '${category.name}_$languageCode';

  // The page is stored as a JSON *string*, not as a map: after an app
  // restart Hive returns nested maps as `Map<dynamic, dynamic>`, which
  // `fromJson` cannot read directly. A string avoids that problem.

  @override
  Future<void> cacheFirstPage(
    MovieCategory category,
    String languageCode,
    MoviesPageModel page,
  ) async {
    try {
      await _box.put(_key(category, languageCode), jsonEncode(page.toJson()));
    } on Object catch (error) {
      throw CacheException(error.toString());
    }
  }

  @override
  MoviesPageModel? getCachedFirstPage(
    MovieCategory category,
    String languageCode,
  ) {
    try {
      final raw = _box.get(_key(category, languageCode));
      if (raw == null) return null;
      return MoviesPageModel.fromJson(
        jsonDecode(raw as String) as Map<String, dynamic>,
      );
    } on Object catch (error) {
      throw CacheException(error.toString());
    }
  }
}
