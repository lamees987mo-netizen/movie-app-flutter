import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/core/network/image_url.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// A tappable movie poster with a 2:3 aspect ratio.
///
/// Pass a unique [heroTag] (e.g. `'trending-${movie.id}'`) to animate the
/// poster into the details screen. It is optional because the same movie
/// can appear in two lists on one screen, and Hero tags must be unique.
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    required this.movie,
    this.onTap,
    this.heroTag,
    this.width,
    super.key,
  });

  final Movie movie;
  final VoidCallback? onTap;
  final Object? heroTag;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final imageUrl = ImageUrl.poster(movie.posterPath);
    Widget poster = imageUrl == null
        ? const _PosterPlaceholder()
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const _PosterPlaceholder(),
            errorWidget: (context, url, error) => const _PosterPlaceholder(),
          );
    if (heroTag != null) poster = Hero(tag: heroTag!, child: poster);

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Semantics(label: movie.title, image: true, child: poster),
          ),
        ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(child: Icon(Icons.movie, color: colors.onSurfaceVariant)),
    );
  }
}
