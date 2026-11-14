import 'package:equatable/equatable.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// An actor (or any TMDB person), as shown on the person page.
class Person extends Equatable {
  const Person({
    required this.id,
    required this.name,
    required this.biography,
    this.profilePath,
    this.birthday,
    this.placeOfBirth,
    this.knownFor = const [],
  });

  final int id;
  final String name;

  /// Empty when TMDB has no biography (common in Arabic).
  final String biography;

  /// Relative TMDB path; build the full URL with `ImageUrl.profile`.
  final String? profilePath;
  final DateTime? birthday;
  final String? placeOfBirth;

  /// Their best-known movies, most voted first, without duplicates.
  final List<Movie> knownFor;

  @override
  List<Object?> get props => [
    id,
    name,
    biography,
    profilePath,
    birthday,
    placeOfBirth,
    knownFor,
  ];
}
