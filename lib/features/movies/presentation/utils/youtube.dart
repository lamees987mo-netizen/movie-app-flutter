import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// A YouTube video id is exactly 11 characters of letters, digits, `_`
/// and `-`, e.g. `dQw4w9WgXcQ`.
final RegExp _youtubeKeyPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

/// Whether [key] looks like a real YouTube video id. Used to reject bad
/// links such as `/trailer/abc` before they reach the player.
bool isValidYoutubeKey(String key) => _youtubeKeyPattern.hasMatch(key);

/// The normal YouTube page of a video.
Uri youtubeWatchUri(String youtubeKey) =>
    Uri.https('www.youtube.com', '/watch', {'v': youtubeKey});

/// Opens the video on YouTube (the app if installed, else the browser).
///
/// Shows a SnackBar when nothing on the device can open the link.
Future<void> openOnYoutube(BuildContext context, String youtubeKey) async {
  // Read everything that needs `context` before the `await`.
  final errorText = AppLocalizations.of(context).commonErrorGeneric;
  final messenger = ScaffoldMessenger.of(context);

  bool opened;
  try {
    opened = await launchUrl(
      youtubeWatchUri(youtubeKey),
      mode: LaunchMode.externalApplication,
    );
  } on Exception {
    opened = false;
  }
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text(errorText)));
  }
}
