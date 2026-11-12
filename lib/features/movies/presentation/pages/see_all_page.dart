import 'package:flutter/material.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the movies feature replaces this with the paginated grid.
class SeeAllPage extends StatelessWidget {
  const SeeAllPage({required this.category, super.key});

  final MovieCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).moviesSeeAll)),
    );
  }
}
