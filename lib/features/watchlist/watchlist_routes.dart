import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/watchlist/presentation/pages/watchlist_page.dart';

/// The Watchlist tab.
final StatefulShellBranch watchlistBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.watchlist,
      name: RouteNames.watchlist,
      builder: (context, state) => const WatchlistPage(),
    ),
  ],
);

/// Full-screen routes shown above the bottom navigation bar (none yet).
final List<RouteBase> watchlistRoutes = [];
