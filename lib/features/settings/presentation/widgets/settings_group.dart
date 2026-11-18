import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';

/// A rounded card of rows with a small title above it, like the groups in
/// the phone's own Settings app.
///
/// Thin dividers are added between the [children] automatically.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, this.title, super.key});

  /// `null` for a group without a title (e.g. "Sign out" at the bottom).
  final String? title;
  final List<Widget> children;

  /// Where a divider starts: after the leading icon, so the icons look
  /// like one column (as on iOS).
  static const double _dividerIndent = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = this.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          // One step lighter than the page background, in both themes.
          color: theme.brightness == Brightness.dark
              ? colors.surfaceContainerHigh
              : colors.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (final (index, child) in children.indexed) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    indent: _dividerIndent,
                    color: colors.outlineVariant,
                  ),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
