// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonModel _$PersonModelFromJson(Map<String, dynamic> json) => PersonModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String? ?? '',
  biography: json['biography'] as String? ?? '',
  profilePath: json['profile_path'] as String?,
  birthday: json['birthday'] as String?,
  placeOfBirth: json['place_of_birth'] as String?,
  credits:
      (PersonModel._readCredits(json, 'credits') as List<dynamic>?)
          ?.map((e) => MovieCreditModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);
