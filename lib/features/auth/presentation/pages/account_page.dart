import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/auth/presentation/widgets/account_feedback.dart';
import 'package:movie_app/features/auth/presentation/widgets/account_group.dart';
import 'package:movie_app/features/auth/presentation/widgets/profile_header.dart';
import 'package:movie_app/features/settings/presentation/widgets/preferences_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/features/settings/presentation/widgets/support_group.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The Account tab, laid out like a phone's Settings app: the profile at
/// the top, then groups of rows (Account, Preferences, Support), and
/// "Sign out" at the bottom for signed-in users.
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
        // Reused from the watchlist feature, for the "My watchlist" count.
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
    return Scaffold(
      // A tab: no back button.
      appBar: AppBar(title: Text(l10n.accountPageTitle)),
      body: BlocListener<AccountCubit, AccountState>(
        listener: showAccountFeedback,
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, auth) {
            final user = switch (auth) {
              AuthSignedIn(:final user) => user,
              AuthSignedOut() => null,
            };
            return ListView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              children: [
                const SizedBox(height: AppSpacing.sm),
                ProfileHeader(user: user),
                const SizedBox(height: AppSpacing.lg),
                const AccountGroup(),
                const SizedBox(height: AppSpacing.lg),
                const PreferencesGroup(),
                const SizedBox(height: AppSpacing.lg),
                const SupportGroup(),
                if (user != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const _SignOutGroup(),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "Sign out", in red, on its own at the bottom.
///
/// No "Are you sure?" dialog: signing out loses nothing (the watchlist is
/// saved in the account and comes back on the next sign-in), and it is
/// easy to sign in again.
class _SignOutGroup extends StatelessWidget {
  const _SignOutGroup();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final busy = state is AccountBusy;
        return SettingsGroup(
          children: [
            SettingsTile(
              icon: Icons.logout,
              title: l10n.accountSignOut,
              destructive: true,
              trailing: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              // Taps while signing out are ignored.
              onTap: busy ? null : context.read<AccountCubit>().signOut,
            ),
          ],
        );
      },
    );
  }
}
