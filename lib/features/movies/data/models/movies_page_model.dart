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

  final int page;
  final List<MovieModel> results;
  final int totalPages;

  Map<String, dynamic> toJson() => _$MoviesPageModelToJson(this);

  PaginatedMovies toEntity() => PaginatedMovies(
    movies: results.map((model) => model.toEntity()).toList(),
    page: page,
    totalPages: totalPages,
  );
}
