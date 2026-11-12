import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A grid of posters for the search results. Tapping a poster opens the
/// details of that movie.
class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({required this.movies, super.key});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return _PosterGrid(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final heroTag = 'search-${movie.id}';
        return MoviePosterCard(
          movie: movie,
          heroTag: heroTag,
          onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
        );
      },
    );
  }
}

/// Grey placeholder posters with a shimmer while a search runs.
class SearchLoadingGrid extends StatelessWidget {
  const SearchLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: _PosterGrid(
        itemCount: 12,
        // Nothing to scroll yet.
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) => MoviePosterCard(
          // A fake movie without a poster: nothing is downloaded.
          movie: Movie(id: index, title: '', overview: '', voteAverage: 0),
        ),
      ),
    );
  }
}

/// The layout shared by the results and the skeleton, so the skeleton
/// has exactly the shape of the results.
class _PosterGrid extends StatelessWidget {
  const _PosterGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics? physics;

  /// Posters are at most this wide: phones get 3 columns, larger screens
  /// get more.
  static const double _maxPosterWidth = 140;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      // Scrolling the results hides the keyboard.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _maxPosterWidth,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
