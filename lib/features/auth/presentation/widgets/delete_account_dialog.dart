import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Asks "Delete your account?". Returns `true` only if the user confirms.
Future<bool> confirmDeleteAccount(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final colors = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(l10n.accountDeleteConfirmTitle),
        content: Text(l10n.accountDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          // Red, because it can't be undone.
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.accountDeleteConfirm),
          ),
        ],
      );
    },
  );
  // Tapping outside the dialog returns null: treat it as "Cancel".
  return confirmed ?? false;
}
