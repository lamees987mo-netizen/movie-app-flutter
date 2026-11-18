import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/features/auth/presentation/widgets/account_feedback.dart';
import 'package:movie_app/features/auth/presentation/widgets/delete_account_dialog.dart';
import 'package:movie_app/features/auth/presentation/widgets/signed_in_guard.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Security & privacy": change the password (email accounts only) and
/// delete the account.
///
/// Like `AccountPage`, it only creates the cubit; [SecurityView] draws
/// the screen.
class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>(),
      child: const SecurityView(),
    );
  }
}

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).accountSecurity)),
      // After "Delete account", the guard goes back to the account tab and
      // this listener's "Your account was deleted." SnackBar stays visible
      // (SnackBars belong to the whole app, not to one page).
      body: BlocListener<AccountCubit, AccountState>(
        listener: showAccountFeedback,
        child: SignedInGuard(builder: (_, user) => _SecurityList(user: user)),
      ),
    );
  }
}

class _SecurityList extends StatelessWidget {
  const _SecurityList({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        final busy = state is AccountBusy;
        final cubit = context.read<AccountCubit>();
        final email = user.email;
        return ListView(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          children: [
            // Only email accounts have a password here. Google accounts
            // change it at Google, so they get a short note instead.
            if (user.signInMethod == SignInMethod.email && email != null)
              SettingsGroup(
                title: l10n.accountSectionSignIn,
                children: [
                  SettingsTile(
                    icon: Icons.lock_reset_outlined,
                    title: l10n.accountChangePassword,
                    subtitle: l10n.accountChangePasswordHint,
                    onTap: busy
                        ? null
                        : () => unawaited(cubit.sendPasswordReset(email)),
                  ),
                ],
              )
            else if (user.signInMethod == SignInMethod.google)
              SettingsGroup(
                title: l10n.accountSectionSignIn,
                children: [
                  SettingsTile(
                    icon: Icons.info_outline,
                    title: l10n.accountSignInMethodGoogle,
                    subtitle: l10n.accountGooglePasswordNote,
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.lg),
            SettingsGroup(
              title: l10n.accountSectionDanger,
              children: [
                SettingsTile(
                  icon: Icons.delete_forever_outlined,
                  title: l10n.accountDelete,
                  subtitle: l10n.accountDeleteHint,
                  destructive: true,
                  onTap: busy
                      ? null
                      : () async {
                          if (await confirmDeleteAccount(context)) {
                            await cubit.deleteAccount();
                          }
                        },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
