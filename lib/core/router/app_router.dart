import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/app_shell.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/features/movies/movies_routes.dart';
import 'package:movie_app/features/person/person_routes.dart';
import 'package:movie_app/features/search/search_routes.dart';
import 'package:movie_app/features/settings/settings_routes.dart';
import 'package:movie_app/features/watchlist/watchlist_routes.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Builds the app's router.
///
/// Each feature owns its routes in `<feature>_routes.dart`:
/// - `xBranch`: the tab's routes, shown inside the bottom navigation shell.
/// - `xRoutes`: full-screen routes pushed above the shell (e.g. details).
///
/// [observers] watch screen changes, e.g. to log them to analytics.
GoRouter createAppRouter({List<NavigatorObserver> observers = const []}) {
  return GoRouter(
    initialLocation: Routes.home,
    observers: observers,
    // Unknown paths: a localized "not found" screen instead of go_router's
    // default English page.
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: ErrorView(message: AppLocalizations.of(context).commonNotFound),
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        // The order must match the destinations in AppShell.
        branches: [moviesBranch, searchBranch, watchlistBranch, settingsBranch],
      ),
      ...moviesRoutes,
      ...personRoutes,
      ...searchRoutes,
      ...watchlistRoutes,
      ...settingsRoutes,
    ],
  );
}
