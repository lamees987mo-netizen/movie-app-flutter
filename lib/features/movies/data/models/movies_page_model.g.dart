// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies_page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoviesPageModel _$MoviesPageModelFromJson(Map<String, dynamic> json) =>
    MoviesPageModel(
      page: (json['page'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: (json['total_pages'] as num).toInt(),
    );

Map<String, dynamic> _$MoviesPageModelToJson(MoviesPageModel instance) =>
    <String, dynamic>{
      'page': instance.page,
      'results': instance.results.map((e) => e.toJson()).toList(),
      'total_pages': instance.totalPages,
    };
