import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/settings/presentation/pages/settings_page.dart';

/// The Settings tab.
final StatefulShellBranch settingsBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.settings,
      name: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

/// Full-screen routes shown above the bottom navigation bar (none yet).
final List<RouteBase> settingsRoutes = [];
