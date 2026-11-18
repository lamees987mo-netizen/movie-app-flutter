import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/settings/presentation/utils/app_links.dart';
import 'package:movie_app/features/settings/presentation/utils/external_link.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Support": Help center (GitHub issues), Terms & policies and About us.
class SupportGroup extends StatelessWidget {
  const SupportGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsGroup(
      title: l10n.settingsSectionSupport,
      children: [
        SettingsTile(
          icon: Icons.help_outline,
          title: l10n.settingsHelpCenter,
          onTap: () => unawaited(openExternalLink(context, AppLinks.issues)),
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: l10n.settingsTerms,
          onTap: () => unawaited(context.push(Routes.terms)),
        ),
        SettingsTile(
          icon: Icons.info_outline,
          title: l10n.settingsAbout,
          onTap: () => unawaited(context.push(Routes.about)),
        ),
      ],
    );
  }
}
