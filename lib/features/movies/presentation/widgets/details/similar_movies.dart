import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';

/// A horizontal row of posters; tapping one opens its details page on top
/// of the current one.
class SimilarMovies extends StatelessWidget {
  const SimilarMovies({
    required this.movies,
    required this.parentMovieId,
    super.key,
  });

  final List<Movie> movies;

  /// The movie of the current page. It is part of the Hero tags, so they
  /// never clash with the tag of the poster at the top of this page.
  final int parentMovieId;

  static const double _posterWidth = 110;

  /// Posters are 2:3, so the row is 1.5x as tall as a poster is wide.
  static const double _height = _posterWidth * 3 / 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final movie = movies[index];
          final heroTag = 'similar-$parentMovieId-${movie.id}';
          return MoviePosterCard(
            movie: movie,
            width: _posterWidth,
            heroTag: heroTag,
            onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
          );
        },
      ),
    );
  }
}
