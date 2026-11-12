import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the movies feature replaces this with the details screen.
class MovieDetailsPage extends StatelessWidget {
  const MovieDetailsPage({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).detailsOverview)),
    );
  }
}
