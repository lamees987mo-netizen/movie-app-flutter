import 'package:equatable/equatable.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Everything the details screen needs, loaded in a single request.
///
/// The basic fields live in [movie], so the same object can be passed to
/// the watchlist without conversion.
class MovieDetails extends Equatable {
  const MovieDetails({
    required this.movie,
    this.runtime,
    this.genres = const [],
    this.cast = const [],
    this.trailerYoutubeKey,
    this.similar = const [],
  });

  final Movie movie;

  /// Length in minutes, `null` when unknown.
  final int? runtime;

  /// Genre names, e.g. `['Action', 'Drama']`.
  final List<String> genres;
  final List<CastMember> cast;

  /// YouTube video id: open `https://www.youtube.com/watch?v=<key>`.
  final String? trailerYoutubeKey;

  /// Movies TMDB considers similar to this one; empty when there are none.
  final List<Movie> similar;

  @override
  List<Object?> get props => [
    movie,
    runtime,
    genres,
    cast,
    trailerYoutubeKey,
    similar,
  ];
}

class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  /// The person's TMDB id, used to open their page (`/person/:id`).
  final int id;
  final String name;
  final String character;

  /// Relative TMDB path; build the full URL with `ImageUrl.profile`.
  final String? profilePath;

  @override
  List<Object?> get props => [id, name, character, profilePath];
}
