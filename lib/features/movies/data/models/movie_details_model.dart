import 'package:json_annotation/json_annotation.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';

part 'movie_details_model.g.dart';

/// Response of `movie/{id}?append_to_response=credits,videos`.
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class MovieDetailsModel {
  const MovieDetailsModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.genres,
    required this.cast,
    required this.videos,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.runtime,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsModelFromJson(json);

  /// Used by the offline cache. Note: `cast` and `videos` are written as
  /// flat lists; `MoviesLocalDataSource` nests them back the way TMDB
  /// sends them (`credits.cast`, `videos.results`) so `fromJson` can read
  /// them.
  Map<String, dynamic> toJson() => _$MovieDetailsModelToJson(this);

  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  @JsonKey(defaultValue: 0)
  final double voteAverage;
  final String? releaseDate;
  final int? runtime;
  @JsonKey(defaultValue: <GenreModel>[])
  final List<GenreModel> genres;

  /// Read from the nested `credits.cast` list.
  @JsonKey(readValue: _readCast, defaultValue: <CastMemberModel>[])
  final List<CastMemberModel> cast;

  /// Read from the nested `videos.results` list.
  @JsonKey(readValue: _readVideos, defaultValue: <VideoModel>[])
  final List<VideoModel> videos;

  static Object? _readCast(Map<dynamic, dynamic> json, String key) =>
      (json['credits'] as Map<String, dynamic>?)?['cast'];

  static Object? _readVideos(Map<dynamic, dynamic> json, String key) =>
      (json['videos'] as Map<String, dynamic>?)?['results'];

  /// The YouTube key of the best trailer: an official one if available,
  /// otherwise the first trailer, otherwise `null`.
  String? get trailerYoutubeKey {
    final trailers = videos.where((v) => v.isYoutubeTrailer).toList();
    if (trailers.isEmpty) return null;
    final official = trailers.where((v) => v.official);
    return (official.isNotEmpty ? official.first : trailers.first).key;
  }

  MovieDetails toEntity() => MovieDetails(
    movie: Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      releaseDate: DateTime.tryParse(releaseDate ?? ''),
      genreIds: genres.map((genre) => genre.id).toList(),
    ),
    runtime: runtime,
    genres: genres.map((genre) => genre.name).toList(),
    cast: cast.map((member) => member.toEntity()).toList(),
    trailerYoutubeKey: trailerYoutubeKey,
  );
}

@JsonSerializable()
class GenreModel {
  const GenreModel({required this.id, required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);

  final int id;
  final String name;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CastMemberModel {
  const CastMemberModel({
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) =>
      _$CastMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastMemberModelToJson(this);

  final String name;
  @JsonKey(defaultValue: '')
  final String character;
  final String? profilePath;

  CastMember toEntity() => CastMember(
    name: name,
    character: character,
    profilePath: profilePath,
  );
}

@JsonSerializable()
class VideoModel {
  const VideoModel({
    required this.key,
    required this.site,
    required this.type,
    required this.official,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  final String key;
  final String site;
  final String type;
  @JsonKey(defaultValue: false)
  final bool official;

  bool get isYoutubeTrailer => site == 'YouTube' && type == 'Trailer';
}
