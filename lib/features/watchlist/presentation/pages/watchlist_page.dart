import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The Watchlist tab.
///
/// This widget only creates the cubit; [WatchlistView] draws the screen,
/// so widget tests can give the view a mock cubit.
class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<WatchlistCubit>();
        // Not awaited on purpose: the cubit emits as the watchlist changes.
        unawaited(cubit.load());
        return cubit;
      },
      child: const WatchlistView(),
    );
  }
}

/// Draws the Watchlist tab for the state of the [WatchlistCubit] above it.
class WatchlistView extends StatelessWidget {
  const WatchlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navWatchlist)),
      body: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, state) => switch (state) {
          // Local storage answers almost at once, so no skeleton.
          WatchlistLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WatchlistEmpty() => EmptyView(
            title: l10n.watchlistEmptyTitle,
            subtitle: l10n.watchlistEmptySubtitle,
            icon: Icons.bookmark_border,
          ),
          WatchlistLoaded(:final movies) => _WatchlistGrid(movies: movies),
          WatchlistError(:final failure) => ErrorView(
            message: failure.message(l10n),
            onRetry: () => context.read<WatchlistCubit>().load(),
          ),
        },
      ),
    );
  }
}

class _WatchlistGrid extends StatelessWidget {
  const _WatchlistGrid({required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        // Posters are 2:3.
        childAspectRatio: 2 / 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final heroTag = 'watchlist-${movie.id}';
        return MoviePosterCard(
          key: ValueKey(movie.id),
          movie: movie,
          heroTag: heroTag,
          onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
        );
      },
    );
  }
}
