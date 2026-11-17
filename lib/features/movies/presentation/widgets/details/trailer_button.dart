import 'package:flutter/material.dart';
import 'package:movie_app/features/movies/presentation/navigation/trailer_navigation.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Opens the trailer page, which plays the video inside the app.
class TrailerButton extends StatelessWidget {
  const TrailerButton({required this.youtubeKey, this.title, super.key});

  /// The YouTube video id, e.g. `dQw4w9WgXcQ`.
  final String youtubeKey;

  /// The movie title, shown in the trailer page's app bar.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.pushTrailer(youtubeKey, title: title),
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(AppLocalizations.of(context).detailsPlayTrailer),
    );
  }
}
