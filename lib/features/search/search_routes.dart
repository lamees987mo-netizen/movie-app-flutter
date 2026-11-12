import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/search/presentation/pages/search_page.dart';

/// The Search tab.
final StatefulShellBranch searchBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.search,
      name: RouteNames.search,
      builder: (context, state) => const SearchPage(),
    ),
  ],
);

/// Full-screen routes shown above the bottom navigation bar (none yet).
final List<RouteBase> searchRoutes = [];
