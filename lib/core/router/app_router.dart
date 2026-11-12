import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/app_shell.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/movies_routes.dart';
import 'package:movie_app/features/search/search_routes.dart';
import 'package:movie_app/features/settings/settings_routes.dart';
import 'package:movie_app/features/watchlist/watchlist_routes.dart';

/// Builds the app's router.
///
/// Each feature owns its routes in `<feature>_routes.dart`:
/// - `xBranch`: the tab's routes, shown inside the bottom navigation shell.
/// - `xRoutes`: full-screen routes pushed above the shell (e.g. details).
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        // The order must match the destinations in AppShell.
        branches: [moviesBranch, searchBranch, watchlistBranch, settingsBranch],
      ),
      ...moviesRoutes,
      ...searchRoutes,
      ...watchlistRoutes,
      ...settingsRoutes,
    ],
  );
}
