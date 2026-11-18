import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [uri] in the browser (outside the app).
///
/// Shows a SnackBar when nothing on the device can open the link.
Future<void> openExternalLink(BuildContext context, Uri uri) async {
  // Read everything that needs `context` before the `await`.
  final errorText = AppLocalizations.of(context).settingsLinkError;
  final messenger = ScaffoldMessenger.of(context);

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
