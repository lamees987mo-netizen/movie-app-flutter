import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/presentation/cubit/account_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Shows a SnackBar for the result of an [AccountCubit] action.
///
/// Used by the account page and the "Security & privacy" page, as a
/// `BlocListener` callback, so both explain results the same way.
void showAccountFeedback(BuildContext context, AccountState state) {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  switch (state) {
    case AccountDeleted():
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountDeleted)));
    case AccountPasswordResetSent(:final email):
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountPasswordResetSent(email))),
      );
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
