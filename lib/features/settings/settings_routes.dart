import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';

/// Settings no longer has its own tab: it is a section of the account
/// page. The old path still works (e.g. an old deep link) and opens the
/// account tab.
final List<RouteBase> settingsRoutes = [
  GoRoute(path: Routes.settings, redirect: (_, _) => Routes.account),
];
