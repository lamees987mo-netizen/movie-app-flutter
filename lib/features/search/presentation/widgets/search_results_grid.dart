import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A grid of posters for the search results that loads more pages as the
/// user scrolls. Tapping a poster opens the details of that movie.
class SearchResultsGrid extends StatelessWidget {
  const SearchResultsGrid({required this.state, super.key});

  final SearchLoaded state;

  /// Start loading the next page when one of the last [_loadMoreThreshold]
  /// posters is built (about two rows on a phone).
  static const int _loadMoreThreshold = 6;

  /// Asks for the next page, unless that would be pointless.
  ///
  /// Called from `itemBuilder` (like the "See all" grid): the grid only
  /// builds posters that are on or just below the screen, so "the last
  /// posters are being built" means "the user is near the end". The event
  /// is sent after the frame, because state must not change during a
  /// build; the bloc ignores extra requests.
  ///
  /// After a failure nothing is requested automatically (that would retry
  /// in a loop): the user taps "Retry" below the results.
  void _maybeLoadMore(BuildContext context) {
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.loadMoreFailure != null) {
      return;
    }
    final bloc = context.read<SearchBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!bloc.isClosed) bloc.add(const SearchNextPageRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = state.movies;
    return _PosterGrid(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        if (index >= movies.length - _loadMoreThreshold) {
          _maybeLoadMore(context);
        }
        final movie = movies[index];
        final heroTag = 'search-${movie.id}';
        return MoviePosterCard(
          movie: movie,
          heroTag: heroTag,
          onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
        );
      },
      footer: _Footer(state: state),
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
    this.footer,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollPhysics? physics;

  /// Shown below the grid (the "loading more" spinner or its retry).
  final Widget? footer;

  /// Posters are at most this wide: phones get 3 columns, larger screens
  /// get more.
  static const double _maxPosterWidth = 140;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return CustomScrollView(
      physics: physics,
      // Scrolling the results hides the keyboard.
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _maxPosterWidth,
              childAspectRatio: 2 / 3,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          ),
        ),
        if (footer != null)
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(child: footer),
          ),
      ],
    );
  }
}

/// Below the results: a spinner while the next page loads, or a small
/// retry when it failed. Empty otherwise.
class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final SearchLoaded state;

  @override
  Widget build(BuildContext context) {
    final failure = state.loadMoreFailure;
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (failure != null) return _LoadMoreError(failure: failure);
    return const SizedBox.shrink();
  }
}

class _LoadMoreError extends StatelessWidget {
  const _LoadMoreError({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        end: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        children: [
          Text(
            failure.message(l10n),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          TextButton.icon(
            onPressed: () =>
                context.read<SearchBloc>().add(const SearchNextPageRequested()),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
