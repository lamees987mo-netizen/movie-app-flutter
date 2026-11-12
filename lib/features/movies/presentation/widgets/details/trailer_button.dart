import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the trailer on YouTube (the app if installed, else the browser).
class TrailerButton extends StatelessWidget {
  const TrailerButton({required this.youtubeKey, super.key});

  /// The YouTube video id, e.g. `dQw4w9WgXcQ`.
  final String youtubeKey;

  Future<void> _openTrailer(BuildContext context) async {
    // Read everything that needs `context` before the `await`.
    final errorText = AppLocalizations.of(context).commonErrorGeneric;
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.https('www.youtube.com', '/watch', {'v': youtubeKey});

    bool opened;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _openTrailer(context),
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(AppLocalizations.of(context).detailsPlayTrailer),
    );
  }
}
