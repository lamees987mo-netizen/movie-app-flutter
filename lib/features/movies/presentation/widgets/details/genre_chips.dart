import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';

/// The movie's genres as small chips that wrap onto new lines.
class GenreChips extends StatelessWidget {
  const GenreChips({required this.genres, super.key});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final genre in genres)
          Chip(label: Text(genre), visualDensity: VisualDensity.compact),
      ],
    );
  }
}
