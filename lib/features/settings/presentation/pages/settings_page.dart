import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the settings feature adds the theme and language controls
/// (backed by `SettingsCubit`, which is already provided in `app.dart`).
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navSettings)),
    );
  }
}
