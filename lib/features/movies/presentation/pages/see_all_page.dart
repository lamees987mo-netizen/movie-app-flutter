import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_cubit.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/utils/movie_category_title.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Every movie of one [category], in a grid that loads more pages as the
/// user scrolls.
///
/// This widget only creates the cubit; [SeeAllView] draws the screen, so
/// widget tests can give the view a mock cubit.
class SeeAllPage extends StatelessWidget {
  const SeeAllPage({required this.category, super.key});

  final MovieCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<SeeAllCubit>(param1: category);
        // Not awaited on purpose: the cubit emits its states as it goes.
        unawaited(cubit.loadFirstPage());
        return cubit;
      },
      // TMDB returns titles in the app's language, so reload when the
      // language changes (like Home does).
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => previous.locale != current.locale,
        listener: (context, _) =>
            unawaited(context.read<SeeAllCubit>().refresh()),
        child: SeeAllView(category: category),
      ),
    );
  }
}

/// Draws the "See all" screen for the state of the [SeeAllCubit] above it.
class SeeAllView extends StatelessWidget {
  const SeeAllView({required this.category, super.key});

  final MovieCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(category.title(l10n))),
      body: BlocBuilder<SeeAllCubit, SeeAllState>(
        builder: (context, state) => switch (state) {
          SeeAllLoading() => const _LoadingGrid(),
          SeeAllError(:final failure) => ErrorView(
            message: failure.message(l10n),
            onRetry: () => context.read<SeeAllCubit>().loadFirstPage(),
          ),
          SeeAllLoaded() => _MovieGrid(category: category, state: state),
        },
      ),
    );
  }
}

/// Posters are 2:3. Columns are at most this wide, so a phone gets 3 and
/// a tablet or landscape screen gets more.
const double _maxPosterWidth = 160;

const SliverGridDelegate _gridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: _maxPosterWidth,
      childAspectRatio: 2 / 3,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
    );

const EdgeInsetsDirectional _gridPadding = EdgeInsetsDirectional.all(
  AppSpacing.md,
);

class _MovieGrid extends StatelessWidget {
  const _MovieGrid({required this.category, required this.state});

  final MovieCategory category;
  final SeeAllLoaded state;

  /// Start loading the next page when one of the last [_loadMoreThreshold]
  /// posters is built (about two rows on a phone).
  static const int _loadMoreThreshold = 6;

  /// Asks for the next page, unless that would be pointless.
  ///
  /// It is called from `itemBuilder` instead of a scroll listener: the
  /// grid only builds posters that are on (or just below) the screen, so
  /// "the last posters are being built" means "the user is near the end".
  /// Unlike a scroll listener, this also works when the first page is too
  /// short to scroll (e.g. on a tablet).
  ///
  /// The cubit call is delayed to after the frame because a widget must
  /// not change state while it is being built. Several posters may ask in
  /// the same frame; the cubit ignores the extra calls.
  ///
  /// After a failure, nothing is requested automatically (that would retry
  /// in a loop): the user taps "Retry" in the footer.
  void _maybeLoadMore(BuildContext context) {
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.loadMoreFailure != null) {
      return;
    }
    final cubit = context.read<SeeAllCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!cubit.isClosed) unawaited(cubit.loadMore());
    });
  }

  @override
  Widget build(BuildContext context) {
    final movies = state.movies;
    return RefreshIndicator(
      onRefresh: () => context.read<SeeAllCubit>().refresh(),
      child: CustomScrollView(
        // Lets the user pull to refresh even when the content is short.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (movies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyView(title: AppLocalizations.of(context).commonEmpty),
            )
          else
            SliverPadding(
              padding: _gridPadding,
              sliver: SliverGrid.builder(
                gridDelegate: _gridDelegate,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  if (index >= movies.length - _loadMoreThreshold) {
                    _maybeLoadMore(context);
                  }
                  return _GridPoster(category: category, movie: movies[index]);
                },
              ),
            ),
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(child: _Footer(state: state)),
          ),
        ],
      ),
    );
  }
}

class _GridPoster extends StatelessWidget {
  const _GridPoster({required this.category, required this.movie});

  final MovieCategory category;
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    // Prefixed so it cannot clash with a Home tag during the transition.
    final heroTag = 'seeAll-${category.name}-${movie.id}';
    return MoviePosterCard(
      movie: movie,
      heroTag: heroTag,
      onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
    );
  }
}

/// Below the grid: a spinner while the next page loads, or a small retry
/// when it failed. Empty otherwise.
class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final SeeAllLoaded state;

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
            onPressed: () => context.read<SeeAllCubit>().loadMore(),
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}

/// Grey placeholder posters with a shimmer while the first page loads.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: GridView.builder(
        // Nothing to scroll yet.
        physics: const NeverScrollableScrollPhysics(),
        padding: _gridPadding,
        gridDelegate: _gridDelegate,
        itemCount: 12,
        itemBuilder: (_, index) => MoviePosterCard(
          // A fake movie without a poster: nothing is downloaded.
          movie: Movie(id: index, title: '', overview: '', voteAverage: 0),
        ),
      ),
    );
  }
}
