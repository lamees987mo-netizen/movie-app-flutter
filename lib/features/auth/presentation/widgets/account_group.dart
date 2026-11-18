import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_group.dart';
import 'package:movie_app/features/settings/presentation/widgets/settings_tile.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// "Account": Manage profile, Security & privacy and My watchlist.
///
/// Guests see the same rows (so the page looks the same), but the first two
/// open the sign-in screen, since there is no profile to manage yet.
class AccountGroup extends StatelessWidget {
  const AccountGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = context.watch<AuthCubit>().state is AuthSignedIn;

    void open(String path) =>
        unawaited(context.push(signedIn ? path : Routes.signIn));

    return SettingsGroup(
      title: l10n.accountSectionAccount,
      children: [
        SettingsTile(
          icon: Icons.person_outline,
          title: l10n.accountManageProfile,
          onTap: () => open(Routes.accountProfile),
        ),
        SettingsTile(
          icon: Icons.shield_outlined,
          title: l10n.accountSecurity,
          onTap: () => open(Routes.accountSecurity),
        ),
        const _WatchlistTile(),
      ],
    );
  }
}

/// "My watchlist" with the number of saved movies. Opens the Watchlist tab.
class _WatchlistTile extends StatelessWidget {
  const _WatchlistTile();

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
        return SettingsTile(
          icon: Icons.bookmark_border,
          title: l10n.accountMyWatchlist,
          value: count?.toString(),
          // `go`, not `push`: it switches to the tab instead of stacking
          // a second watchlist page on top of this one.
          onTap: () => context.go(Routes.watchlist),
        );
      },
    );
  }
}
