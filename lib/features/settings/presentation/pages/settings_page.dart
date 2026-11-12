import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The Settings tab: theme and language.
///
/// It uses the app-wide [SettingsCubit] that `app.dart` provides above
/// `MaterialApp`; this page never creates or closes one.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: [
            SettingsSection(
              title: l10n.settingsTheme,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l10n.settingsThemeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l10n.settingsThemeDark),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(l10n.settingsThemeSystem),
                  ),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (selection) => context
                    .read<SettingsCubit>()
                    .setThemeMode(selection.single),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: l10n.settingsLanguage,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'en',
                    label: Text(l10n.settingsEnglish),
                  ),
                  ButtonSegment(
                    value: 'ar',
                    label: Text(l10n.settingsArabic),
                  ),
                ],
                selected: {state.locale.languageCode},
                onSelectionChanged: (selection) => context
                    .read<SettingsCubit>()
                    .setLocale(Locale(selection.single)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
