import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/widgets/user_avatar.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The top of the account page, centered: the avatar, the name and the
/// email. A guest ([user] is `null`) sees "Guest" and a "Sign in" button.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = this.user;
    final name = user?.displayName?.trim() ?? '';
    final email = user?.email ?? '';
    // Email accounts may have no name: then the email is the title.
    final title = user == null
        ? l10n.accountGuestName
        : (name.isNotEmpty ? name : email);
    return Column(
      children: [
        UserAvatar(user: user),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (user == null)
          FilledButton.tonal(
            onPressed: () => unawaited(context.push(Routes.signIn)),
            child: Text(l10n.accountSignIn),
          )
        else if (name.isNotEmpty && email.isNotEmpty)
          Text(
            email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
