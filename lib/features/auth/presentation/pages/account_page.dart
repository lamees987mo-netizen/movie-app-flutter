import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/widgets/delete_account_dialog.dart';
import 'package:movie_app/features/auth/presentation/widgets/guest_card.dart';
import 'package:movie_app/features/auth/presentation/widgets/profile_header.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_panel.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The Account tab: the profile (or "Sign in" for guests), the settings,
/// and "Sign out" / "Delete account".
///
/// This widget only creates the screen's cubits; [AccountView] draws it,
/// so widget tests can give the view mock cubits. The user comes from the
/// app-wide `AuthCubit` provided in `app.dart`.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AccountCubit>()),
        // Reused from the watchlist feature, for the "N saved movies" line.
        BlocProvider(
          create: (_) {
            final cubit = sl<WatchlistCubit>();
            unawaited(cubit.load());
            return cubit;
          },
        ),
      ],
      child: const AccountView(),
    );
  }
}

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAccount)),
      body: BlocListener<AccountCubit, AccountState>(
        listener: _showResult,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, auth) => ListView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            children: [
              switch (auth) {
                AuthSignedOut() => const GuestCard(),
                AuthSignedIn(:final user) => ProfileHeader(user: user),
              },
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.accountSettings, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              const SettingsPanel(),
              if (auth is AuthSignedIn) ...[
                const SizedBox(height: AppSpacing.xl),
                const _AccountActions(),
              ],
              const SizedBox(height: AppSpacing.xl),
              // Required by TMDB's terms of use.
              Text(
                l10n.tmdbAttribution,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showResult(BuildContext context, AccountState state) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    switch (state) {
      case AccountDeleted():
        messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
      case AccountError(:final failure):
        messenger.showSnackBar(
          SnackBar(
            content: Text(failure.message(l10n)),
            // The message says "sign out and sign in again": one tap.
            action: failure == const AuthFailure(AuthError.requiresRecentLogin)
                ? SnackBarAction(
                    label: l10n.accountSignOut,
                    onPressed: () => context.read<AccountCubit>().signOut(),
                  )
                : null,
          ),
        );
      case AccountIdle() || AccountBusy():
        break;
    }
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final busy = state is AccountBusy;
        final cubit = context.read<AccountCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: busy ? null : cubit.signOut,
              icon: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(l10n.accountSignOut),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: colors.error),
              onPressed: busy
                  ? null
                  : () async {
                      if (await confirmDeleteAccount(context)) {
                        await cubit.deleteAccount();
                      }
                    },
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(l10n.accountDelete),
            ),
          ],
        );
      },
    );
  }
}
