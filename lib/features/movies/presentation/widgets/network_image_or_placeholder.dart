import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Shows [url] (cached), or a flat placeholder with [icon] when there is
/// no image or it fails to load.
///
/// Pass URLs from `ImageUrl.*`, which are `null` when TMDB has no image.
class NetworkImageOrPlaceholder extends StatelessWidget {
  const NetworkImageOrPlaceholder({
    required this.url,
    this.icon = Icons.movie,
    super.key,
  });

  final String? url;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(icon: icon);
    final url = this.url;
    if (url == null) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(child: Icon(icon, color: colors.onSurfaceVariant)),
    );
  }
}
