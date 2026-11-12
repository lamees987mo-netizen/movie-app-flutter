import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/utils/movie_category_title.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A titled, horizontally scrolling list of posters for one [category].
///
/// It reads a [MovieSectionCubit] from the context, so the parent must
/// provide one (see `HomePage`).
class MovieSection extends StatelessWidget {
  const MovieSection({required this.category, super.key});

  final MovieCategory category;

  static const double _posterWidth = 120;

  /// Posters are 2:3, so the list is 1.5x as tall as a poster is wide.
  static const double _listHeight = _posterWidth * 3 / 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(category: category),
        BlocBuilder<MovieSectionCubit, MovieSectionState>(
          builder: (context, state) => switch (state) {
            MovieSectionLoading() => const _LoadingList(),
            MovieSectionLoaded(:final movies) => _MovieList(
              category: category,
              movies: movies,
            ),
            MovieSectionError(:final failure) => ErrorView(
              message: failure.message(AppLocalizations.of(context)),
              onRetry: () => context.read<MovieSectionCubit>().load(),
            ),
          },
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.category});

  final MovieCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        end: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.title(l10n),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(
            onPressed: () => context.push(Routes.seeAllPath(category.name)),
            child: Text(l10n.moviesSeeAll),
          ),
        ],
      ),
    );
  }
}

class _MovieList extends StatelessWidget {
  const _MovieList({required this.category, required this.movies});

  final MovieCategory category;
  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Text(AppLocalizations.of(context).commonEmpty),
      );
    }

    return SizedBox(
      height: MovieSection._listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final movie = movies[index];
          // The same movie can be in two sections, so the category is part
          // of the tag to keep Hero tags unique on the screen.
          final heroTag = '${category.name}-${movie.id}';
          return MoviePosterCard(
            movie: movie,
            width: MovieSection._posterWidth,
            heroTag: heroTag,
            onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
          );
        },
      ),
    );
  }
}

/// Grey placeholder posters with a shimmer while the first page loads.
class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SizedBox(
        height: MovieSection._listHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          // Nothing to scroll yet.
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          itemCount: 6,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, index) => MoviePosterCard(
            // A fake movie without a poster: nothing is downloaded.
            movie: Movie(id: index, title: '', overview: '', voteAverage: 0),
            width: MovieSection._posterWidth,
          ),
        ),
      ),
    );
  }
}
