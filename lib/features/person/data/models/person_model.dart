import 'package:json_annotation/json_annotation.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';

part 'person_model.g.dart';

/// Response of `person/{id}?append_to_response=movie_credits`.
@JsonSerializable(fieldRename: FieldRename.snake, createToJson: false)
class PersonModel {
  const PersonModel({
    required this.id,
    required this.name,
    required this.biography,
    this.profilePath,
    this.birthday,
    this.placeOfBirth,
    this.credits = const [],
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) =>
      _$PersonModelFromJson(json);

  /// How many movies the page shows.
  static const int knownForLimit = 20;

  final int id;
  @JsonKey(defaultValue: '')
  final String name;

  /// TMDB sends `null` or `""` when there is none.
  @JsonKey(defaultValue: '')
  final String biography;
  final String? profilePath;

  /// `yyyy-MM-dd`, or `null` when unknown.
  final String? birthday;
  final String? placeOfBirth;

  /// Read from the nested `movie_credits.cast` list.
  @JsonKey(readValue: _readCredits, defaultValue: <MovieCreditModel>[])
  final List<MovieCreditModel> credits;

  static Object? _readCredits(Map<dynamic, dynamic> json, String key) =>
      (json['movie_credits'] as Map<String, dynamic>?)?['cast'];

  /// The movies to show: the most voted first, each movie once (an actor
  /// can play two roles in one movie), at most [knownForLimit].
  ///
  /// Sorted by vote count rather than popularity, because popularity
  /// changes daily and favours new, small movies.
  List<MovieCreditModel> get knownFor {
    final sorted = [...credits]
      ..sort((a, b) {
        final byVotes = b.voteCount.compareTo(a.voteCount);
        return byVotes != 0 ? byVotes : b.popularity.compareTo(a.popularity);
      });
    final seenIds = <int>{};
    return sorted
        .where((credit) => seenIds.add(credit.movie.id))
        .take(knownForLimit)
        .toList();
  }

  Person toEntity() => Person(
    id: id,
    name: name,
    biography: biography.trim(),
    profilePath: profilePath,
    birthday: DateTime.tryParse(birthday ?? ''),
    // Treat "" like "unknown", so the page can simply check for null.
    placeOfBirth: (placeOfBirth?.trim().isEmpty ?? true) ? null : placeOfBirth,
    knownFor: knownFor.map((credit) => credit.movie.toEntity()).toList(),
  );
}

/// One movie from `movie_credits.cast`: a normal movie plus the numbers
/// used for sorting.
class MovieCreditModel {
  const MovieCreditModel({
    required this.movie,
    this.voteCount = 0,
    this.popularity = 0,
  });

  /// Reuses [MovieModel] for the movie fields, so there is one parser.
  factory MovieCreditModel.fromJson(Map<String, dynamic> json) =>
      MovieCreditModel(
        movie: MovieModel.fromJson(json),
        voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
        popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      );

  final MovieModel movie;
  final int voteCount;
  final double popularity;
}
