import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/settings/presentation/pages/about_page.dart';
import 'package:movie_app/features/settings/presentation/pages/terms_page.dart';

/// Settings no longer has its own tab: its rows are on the account page.
final List<RouteBase> settingsRoutes = [
  // The old path still works (e.g. an old deep link): it opens the
  // account tab.
  GoRoute(path: Routes.settings, redirect: (_, _) => Routes.account),
  // Full-screen pages opened from the account page's "Support" group.
  // Guests can open them too.
  GoRoute(
    path: Routes.terms,
    name: RouteNames.terms,
    builder: (_, _) => const TermsPage(),
  ),
  GoRoute(
    path: Routes.about,
    name: RouteNames.about,
    builder: (_, _) => const AboutPage(),
  ),
];
