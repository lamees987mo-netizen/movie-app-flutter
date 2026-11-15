import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';

void main() {
  MoviesPageModel pageModel({required int page, required int totalPages}) =>
      MoviesPageModel(page: page, results: const [], totalPages: totalPages);

  group('toEntity', () {
    test('keeps totalPages up to 500', () {
      expect(pageModel(page: 1, totalPages: 42).toEntity().totalPages, 42);
      expect(pageModel(page: 1, totalPages: 500).toEntity().totalPages, 500);
    });

    test('clamps totalPages to 500, the last page TMDB serves', () {
      final entity = pageModel(page: 1, totalPages: 46012).toEntity();

      expect(entity.totalPages, MoviesPageModel.maxPages);
    });

    test('page 500 is the last page even if TMDB reports more', () {
      final entity = pageModel(page: 500, totalPages: 46012).toEntity();

      expect(entity.hasReachedMax, isTrue);
    });

    test('is not from the cache unless the caller says so', () {
      final model = pageModel(page: 1, totalPages: 1);

      expect(model.toEntity().isFromCache, isFalse);
      expect(model.toEntity(isFromCache: true).isFromCache, isTrue);
    });
  });
}
