import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Terms & policies": in plain words, what the app stores and where.
class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTerms)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          Text(l10n.settingsTermsIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          _PolicySection(
            icon: Icons.phone_android_outlined,
            title: l10n.settingsTermsDeviceTitle,
            body: l10n.settingsTermsDeviceBody,
          ),
          _PolicySection(
            icon: Icons.cloud_outlined,
            title: l10n.settingsTermsAccountTitle,
            body: l10n.settingsTermsAccountBody,
          ),
          _PolicySection(
            icon: Icons.insights_outlined,
            title: l10n.settingsTermsAnalyticsTitle,
            body: l10n.settingsTermsAnalyticsBody,
          ),
          _PolicySection(
            icon: Icons.movie_outlined,
            title: l10n.settingsTermsTmdbTitle,
            body: l10n.settingsTermsTmdbBody,
          ),
          const SizedBox(height: AppSpacing.md),
          // Required by TMDB's terms of use.
          Text(l10n.tmdbAttribution, textAlign: TextAlign.center, style: muted),
        ],
      ),
    );
  }
}

/// An icon, a bold title and a paragraph.
class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
