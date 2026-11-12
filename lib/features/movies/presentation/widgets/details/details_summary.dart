import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Poster, title, rating, release date and runtime, side by side.
class DetailsSummary extends StatelessWidget {
  const DetailsSummary({required this.details, this.heroTag, super.key});

  final MovieDetails details;

  /// Must match the tag of the poster that was tapped, so the Hero flies.
  final Object? heroTag;

  static const double _posterWidth = 110;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final movie = details.movie;
    final releaseDate = movie.releaseDate;
    final runtime = details.runtime;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keep the real poster even while the rest is a skeleton: it is the
        // Hero target, and we usually already have it from the list.
        Skeleton.keep(
          child: MoviePosterCard(
            movie: movie,
            heroTag: heroTag,
            width: _posterWidth,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              _InfoItem(
                icon: Icons.star_rounded,
                text: movie.voteAverage.toStringAsFixed(1),
              ),
              if (releaseDate != null)
                _InfoItem(
                  icon: Icons.calendar_today_outlined,
                  text: MaterialLocalizations.of(
                    context,
                  ).formatFullDate(releaseDate),
                  semanticLabel: l10n.detailsReleaseDate,
                ),
              if (runtime != null && runtime > 0)
                _InfoItem(
                  icon: Icons.schedule,
                  text: l10n.detailsRuntimeMinutes(runtime),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text, this.semanticLabel});

  final IconData icon;
  final String text;

  /// Read by screen readers before [text], e.g. "Release date".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = semanticLabel;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              text,
              semanticsLabel: label == null ? null : '$label: $text',
            ),
          ),
        ],
      ),
    );
  }
}
