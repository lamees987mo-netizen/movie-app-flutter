import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';
import 'package:movie_app/features/person/presentation/pages/person_page.dart';

/// Full-screen routes shown above the bottom navigation bar.
final List<RouteBase> personRoutes = [
  GoRoute(
    path: Routes.person,
    name: RouteNames.person,
    // A bad link like `/person/abc` goes Home instead of crashing the page.
    redirect: (context, state) => _personId(state) == null ? Routes.home : null,
    builder: (context, state) {
      // `extra` is optional (see PersonArgs): a deep link has none.
      final args = switch (state.extra) {
        final PersonArgs args => args,
        _ => const PersonArgs(),
      };
      return PersonPage(personId: _personId(state)!, preview: args);
    },
  ),
];

int? _personId(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');
