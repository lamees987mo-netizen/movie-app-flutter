import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/settings/presentation/utils/app_links.dart';
import 'package:movie_app/features/settings/presentation/utils/external_link.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// "About us": the app's name, version and links.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  /// Read once (not on every build). The version comes from pubspec.yaml,
  /// e.g. "1.0.0 (1)", so it never has to be typed here by hand.
  late final Future<String> _version = PackageInfo.fromPlatform().then(
    (info) => info.buildNumber.isEmpty
        ? info.version
        : '${info.version} (${info.buildNumber})',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAbout)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          const SizedBox(height: AppSpacing.md),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.onPrimaryContainer,
              child: const Icon(Icons.movie_outlined, size: 44),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder<String>(
            future: _version,
            // Empty while loading (it takes a moment) or if it fails.
            builder: (context, snapshot) => Text(
              snapshot.hasData ? l10n.settingsAboutVersion(snapshot.data!) : '',
              textAlign: TextAlign.center,
              style: muted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.settingsAboutDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: Icons.code,
                title: l10n.settingsAboutSourceCode,
                onTap: () =>
                    unawaited(openExternalLink(context, AppLinks.repository)),
              ),
              SettingsTile(
                icon: Icons.article_outlined,
                title: l10n.settingsAboutLicenses,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Required by TMDB's terms of use.
          Text(l10n.tmdbAttribution, textAlign: TextAlign.center, style: muted),
        ],
      ),
    );
  }
}
