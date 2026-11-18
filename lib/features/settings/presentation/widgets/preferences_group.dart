import 'package:flutter/material.dart';
import 'package:movie_app/features/settings/presentation/widgets/dark_mode_tile.dart';
import 'package:movie_app/features/settings/presentation/widgets/language_tile.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Preferences": dark mode and language. Both use the app-wide
/// `SettingsCubit` that `app.dart` provides above `MaterialApp`; this
/// widget never creates or closes one.
class PreferencesGroup extends StatelessWidget {
  const PreferencesGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: AppLocalizations.of(context).settingsSectionPreferences,
      children: const [DarkModeTile(), LanguageTile()],
    );
  }
}
