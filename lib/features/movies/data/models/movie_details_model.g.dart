// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieDetailsModel _$MovieDetailsModelFromJson(Map<String, dynamic> json) =>
    MovieDetailsModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cast:
          (MovieDetailsModel._readCast(json, 'cast') as List<dynamic>?)
              ?.map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      videos:
          (MovieDetailsModel._readVideos(json, 'videos') as List<dynamic>?)
              ?.map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      similar:
          (MovieDetailsModel._readSimilar(json, 'similar') as List<dynamic>?)
              ?.map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
    );

GenreModel _$GenreModelFromJson(Map<String, dynamic> json) =>
    GenreModel(id: (json['id'] as num).toInt(), name: json['name'] as String);

CastMemberModel _$CastMemberModelFromJson(Map<String, dynamic> json) =>
    CastMemberModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
  key: json['key'] as String,
  site: json['site'] as String,
  type: json['type'] as String,
  official: json['official'] as bool? ?? false,
);
