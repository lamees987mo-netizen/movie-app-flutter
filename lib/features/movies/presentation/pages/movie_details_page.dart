import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/cast_list.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/details_app_bar.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/details_summary.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/genre_chips.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/similar_movies.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/trailer_button.dart';
import 'package:movie_app/features/watchlist/presentation/widgets/watchlist_button.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// The details screen of one movie.
///
/// This widget only creates the cubit; [MovieDetailsView] draws the
/// screen. Keeping them apart lets widget tests give the view a mock
/// cubit, without the service locator or the network.
class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({
    required this.movieId,
    this.heroTag,
    this.preview,
    super.key,
  });

  final int movieId;

  /// See `MovieDetailsArgs`: both are optional extras from the list.
  final Object? heroTag;
  final Movie? preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<MovieDetailsCubit>(param1: movieId);
        // Not awaited on purpose: the cubit emits its states as it goes.
        unawaited(cubit.load());
        return cubit;
      },
      child: MovieDetailsView(heroTag: heroTag, preview: preview),
    );
  }
}

/// Draws the details screen for the state of the [MovieDetailsCubit]
/// above it.
class MovieDetailsView extends StatelessWidget {
  const MovieDetailsView({this.heroTag, this.preview, super.key});

  final Object? heroTag;

  /// The movie from the list, if any. While loading, it fills the poster,
  /// backdrop and title so the Hero animation has a target.
  final Movie? preview;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieDetailsCubit, MovieDetailsState>(
      builder: (context, state) => switch (state) {
        MovieDetailsLoading() => _DetailsScaffold(
          details: _skeletonDetails(preview),
          heroTag: heroTag,
          isLoading: true,
        ),
        MovieDetailsLoaded(:final details) => _DetailsScaffold(
          details: details,
          heroTag: heroTag,
        ),
        MovieDetailsError(:final failure) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(
            message: failure.message(AppLocalizations.of(context)),
            onRetry: () => context.read<MovieDetailsCubit>().load(),
          ),
        ),
      },
    );
  }

  /// Fake details used only to give the loading skeleton its shape. The
  /// text is never readable: Skeletonizer paints grey bones over it.
  static MovieDetails _skeletonDetails(Movie? preview) => MovieDetails(
    movie:
        preview ??
        Movie(
          id: 0,
          title: 'Movie title',
          overview: 'A placeholder overview that is long enough ' * 4,
          voteAverage: 0,
          releaseDate: DateTime(2000),
        ),
    runtime: 100,
    genres: const ['Genre', 'Genre', 'Genre'],
    cast: List.filled(
      5,
      const CastMember(id: 0, name: 'Actor name', character: 'Character'),
    ),
    // Negative ids so they never clash with a real movie.
    similar: List.generate(
      6,
      (index) => Movie(id: -1 - index, title: '', overview: '', voteAverage: 0),
    ),
  );
}

/// The same layout for "loading" (as a skeleton) and "loaded", so the
/// screen does not jump when the data arrives.
class _DetailsScaffold extends StatelessWidget {
  const _DetailsScaffold({
    required this.details,
    required this.heroTag,
    this.isLoading = false,
  });

  final MovieDetails details;
  final Object? heroTag;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Outside the Skeletonizer, so the back button works while
          // loading.
          DetailsAppBar(backdropPath: details.movie.backdropPath),
          SliverToBoxAdapter(
            child: Skeletonizer(
              enabled: isLoading,
              child: _DetailsSections(
                details: details,
                heroTag: heroTag,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsSections extends StatelessWidget {
  const _DetailsSections({
    required this.details,
    required this.heroTag,
    required this.isLoading,
  });

  final MovieDetails details;
  final Object? heroTag;
  final bool isLoading;

  /// From this width on (tablets, phones in landscape) the summary and the
  /// overview sit side by side.
  static const double _wideBreakpoint = 700;

  /// Keeps lines short enough to read on very wide screens.
  static const double _maxContentWidth = 1000;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _wideBreakpoint) {
          // Phone: everything in one column.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._summary(context),
              ..._overview(context),
              ..._lists(context),
            ],
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _summary(context),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        // Lines the title up with the top of the poster.
                        padding: const EdgeInsetsDirectional.only(
                          top: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _overview(context),
                        ),
                      ),
                    ),
                  ],
                ),
                ..._lists(context),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Poster and info, genres, and the trailer / watchlist buttons.
  List<Widget> _summary(BuildContext context) {
    final trailerKey = details.trailerYoutubeKey;
    return [
      Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: DetailsSummary(details: details, heroTag: heroTag),
      ),
      if (details.genres.isNotEmpty)
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: GenreChips(genres: details.genres),
        ),
      Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            if (trailerKey != null) TrailerButton(youtubeKey: trailerKey),
            // Only once loaded: while loading, `details` is a fake
            // skeleton movie, and saving it would store junk.
            if (!isLoading) WatchlistButton(movie: details.movie),
          ],
        ),
      ),
    ];
  }

  List<Widget> _overview(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final overview = details.movie.overview;
    return [
      _SectionTitle(l10n.detailsOverview),
      Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        child: Text(overview.isEmpty ? l10n.detailsNoOverview : overview),
      ),
    ];
  }

  /// The horizontal rows at the bottom: cast and similar movies.
  List<Widget> _lists(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      if (details.cast.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _SectionTitle(l10n.detailsCast),
        CastList(cast: details.cast),
      ],
      if (details.similar.isNotEmpty) ...[
        const SizedBox(height: AppSpacing.md),
        _SectionTitle(l10n.detailsSimilar),
        SimilarMovies(
          movies: details.similar,
          parentMovieId: details.movie.id,
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
