import 'package:flutter/material.dart';
import 'package:movie_app/core/network/image_url.dart';
import 'package:movie_app/features/movies/presentation/widgets/network_image_or_placeholder.dart';

/// A collapsing app bar (a sliver) with the movie's backdrop image.
class DetailsAppBar extends StatelessWidget {
  const DetailsAppBar({required this.backdropPath, super.key});

  final String? backdropPath;

  static const double _expandedHeight = 220;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: _expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: NetworkImageOrPlaceholder(
          url: ImageUrl.backdrop(backdropPath),
        ),
      ),
    );
  }
}
