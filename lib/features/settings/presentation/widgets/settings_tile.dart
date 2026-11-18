import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';

/// One row of a `SettingsGroup`: an outlined icon, a title, an optional
/// value on the end side (e.g. "English") and a chevron.
///
/// The chevron is `Icons.chevron_right`, which Flutter mirrors by itself in
/// right-to-left languages, so it points the right way in Arabic too.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
    super.key,
  });

  final IconData icon;
  final String title;

  /// A second line under the title, for longer text (e.g. an email).
  final String? subtitle;

  /// A short value shown before the chevron, e.g. "Dark" or "12".
  final String? value;

  /// Replaces the chevron, e.g. with a `Switch` or a spinner.
  final Widget? trailing;

  /// `null` makes the row read-only (and it has no chevron).
  final VoidCallback? onTap;

  /// Red icon and text, for "Sign out" and "Delete account".
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final subtitle = this.subtitle;
    final showChevron = trailing == null && onTap != null && !destructive;
    final end = [
      if (value case final value?)
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ?trailing,
      if (showChevron)
        Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
    ];
    return ListTile(
      leading: Icon(
        icon,
        color: destructive ? colors.error : colors.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: destructive ? TextStyle(color: colors.error) : null,
      ),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: end.isEmpty
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.xs,
              children: end,
            ),
      onTap: onTap,
    );
  }
}
