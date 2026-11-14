import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';

part 'movies_page_model.g.dart';

/// The paginated wrapper TMDB uses for every list and search endpoint.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MoviesPageModel {
  const MoviesPageModel({
    required this.page,
    required this.results,
    required this.totalPages,
  });

  factory MoviesPageModel.fromJson(Map<String, dynamic> json) =>
      _$MoviesPageModelFromJson(json);

  /// TMDB answers "page must be less than or equal to 500" for any page
  /// above 500, even when `total_pages` says there are more.
  static const int maxPages = 500;

  final int page;
  final List<MovieModel> results;
  final int totalPages;

  Map<String, dynamic> toJson() => _$MoviesPageModelToJson(this);

  /// [isFromCache] is set by the repository when this page came from the
  /// offline cache instead of the network.
  PaginatedMovies toEntity({bool isFromCache = false}) => PaginatedMovies(
    movies: results.map((model) => model.toEntity()).toList(),
    page: page,
    // Clamped so pagination stops at the last page TMDB will serve.
    totalPages: math.min(totalPages, maxPages),
    isFromCache: isFromCache,
  );
}
