import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/widgets/user_avatar.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The signed-in user's photo, name and email, and how many movies their
/// watchlist has.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.displayName?.trim() ?? '';
    final email = user.email ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            UserAvatar(user: user),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email accounts may have no name: show the email only.
                  Text(
                    name.isNotEmpty ? name : email,
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (name.isNotEmpty && email.isNotEmpty)
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const _WatchlistStat(),
      ],
    );
  }
}

/// "12 saved movies - Synced with your account". Tapping opens the tab.
class _WatchlistStat extends StatelessWidget {
  const _WatchlistStat();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, state) {
        final count = switch (state) {
          WatchlistLoaded(:final movies) => movies.length,
          WatchlistEmpty() => 0,
          // Still loading, or unreadable: no number rather than a wrong one.
          WatchlistLoading() || WatchlistError() => null,
        };
        return Card(
          child: ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(
              count == null ? '' : l10n.accountWatchlistCount(count),
            ),
            subtitle: Text(l10n.accountWatchlistSynced),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.watchlist),
          ),
        );
      },
    );
  }
}
