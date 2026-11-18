import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Dark mode" with a switch: on = dark theme, off = light theme.
class DarkModeTile extends StatelessWidget {
  const DarkModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // The theme on screen right now, not the saved setting: when the app
    // follows the system, the switch still shows what the user sees.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void setDark({required bool dark}) => unawaited(
      context.read<SettingsCubit>().setThemeMode(
        dark ? ThemeMode.dark : ThemeMode.light,
      ),
    );

    // One semantics node, so screen readers read the row as one switch.
    return MergeSemantics(
      child: SettingsTile(
        icon: Icons.dark_mode_outlined,
        title: l10n.settingsDarkMode,
        value: isDark ? l10n.settingsThemeDark : l10n.settingsThemeLight,
        trailing: Switch(
          value: isDark,
          onChanged: (value) => setDark(dark: value),
        ),
        onTap: () => setDark(dark: !isDark),
      ),
    );
  }
}
