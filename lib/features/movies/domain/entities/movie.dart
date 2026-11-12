import 'package:equatable/equatable.dart';

/// A movie as shown in lists, grids and the watchlist.
class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.genreIds = const [],
  });

  final int id;
  final String title;
  final String overview;

  /// Relative TMDB path; build the full URL with `ImageUrl.poster`.
  final String? posterPath;

  /// Relative TMDB path; build the full URL with `ImageUrl.backdrop`.
  final String? backdropPath;

  /// Rating from 0 to 10.
  final double voteAverage;

  /// `null` when TMDB has no release date yet.
  final DateTime? releaseDate;
  final List<int> genreIds;

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    releaseDate,
    genreIds,
  ];
}
