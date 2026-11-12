import 'package:json_annotation/json_annotation.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

part 'movie_model.g.dart';

/// A movie exactly as TMDB sends it in list responses.
///
/// `toJson` is also used to store movies in Hive (watchlist, home cache).
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieModel {
  const MovieModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.genreIds,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  factory MovieModel.fromEntity(Movie movie) => MovieModel(
    id: movie.id,
    title: movie.title,
    overview: movie.overview,
    voteAverage: movie.voteAverage,
    genreIds: movie.genreIds,
    posterPath: movie.posterPath,
    backdropPath: movie.backdropPath,
    releaseDate: movie.releaseDate?.toIso8601String().substring(0, 10),
  );

  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  @JsonKey(defaultValue: 0)
  final double voteAverage;

  /// `yyyy-MM-dd`, or an empty string for unreleased movies.
  final String? releaseDate;
  @JsonKey(defaultValue: <int>[])
  final List<int> genreIds;

  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    releaseDate: DateTime.tryParse(releaseDate ?? ''),
    genreIds: genreIds,
  );
}
