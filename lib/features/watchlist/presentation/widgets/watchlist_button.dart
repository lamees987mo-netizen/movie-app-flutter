import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Add to watchlist" / "Remove from watchlist" for one [movie].
///
/// Drop it anywhere (e.g. the details screen): it creates and closes its
/// own [WatchlistToggleCubit]. [WatchlistToggleButton] is the part that
/// draws, so tests can give it a mock cubit.
class WatchlistButton extends StatelessWidget {
  const WatchlistButton({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // A new cubit when the movie changes (the key makes Flutter rebuild
      // the provider instead of keeping the old cubit).
      key: ValueKey(movie.id),
      create: (_) {
        final cubit = sl<WatchlistToggleCubit>(param1: movie);
        unawaited(cubit.load());
        return cubit;
      },
      child: const WatchlistToggleButton(),
    );
  }
}

/// Draws the button for the [WatchlistToggleCubit] above it and shows a
/// SnackBar when saving fails.
class WatchlistToggleButton extends StatelessWidget {
  const WatchlistToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<WatchlistToggleCubit, WatchlistToggleState>(
      listenWhen: (previous, current) =>
          current.failure != null && previous.failure != current.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure!.message(l10n))),
        );
      },
      builder: (context, state) => FilledButton.tonalIcon(
        onPressed: () => context.read<WatchlistToggleCubit>().toggle(),
        icon: Icon(state.isSaved ? Icons.bookmark : Icons.bookmark_border),
        label: Text(
          state.isSaved
              ? l10n.detailsRemoveFromWatchlist
              : l10n.detailsAddToWatchlist,
        ),
      ),
    );
  }
}
