import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Language" with the current one ("English" / "العربية"). Tapping opens
/// a bottom sheet to pick another.
class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) => SettingsTile(
        icon: Icons.translate,
        title: l10n.settingsLanguage,
        value: languageName(l10n, state.locale),
        onTap: () => unawaited(showLanguageSheet(context)),
      ),
    );
  }
}

/// Each language is written in itself ("العربية" even in English), so
/// people can find their own language whatever the app's language is.
String languageName(AppLocalizations l10n, Locale locale) =>
    locale.languageCode == 'ar' ? l10n.settingsArabic : l10n.settingsEnglish;

/// The list of languages, with a check mark on the current one.
Future<void> showLanguageSheet(BuildContext context) {
  // Read before the sheet opens: the sheet is a new route.
  final cubit = context.read<SettingsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = Theme.of(sheetContext);
      final current = cubit.state.locale.languageCode;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Text(
                l10n.settingsLanguage,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final locale in SettingsCubit.supportedLocales)
              ListTile(
                title: Text(languageName(l10n, locale)),
                selected: locale.languageCode == current,
                trailing: locale.languageCode == current
                    ? Icon(Icons.check, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  unawaited(cubit.setLocale(locale));
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    },
  );
}
