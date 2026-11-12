import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/pages/home_page.dart';
import 'package:movie_app/features/movies/presentation/pages/movie_details_page.dart';
import 'package:movie_app/features/movies/presentation/pages/see_all_page.dart';

/// The Home tab.
final StatefulShellBranch moviesBranch = StatefulShellBranch(
  routes: [
    GoRoute(
      path: Routes.home,
      name: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);

/// Full-screen routes shown above the bottom navigation bar.
final List<RouteBase> moviesRoutes = [
  GoRoute(
    path: Routes.movieDetails,
    name: RouteNames.movieDetails,
    builder: (context, state) {
      // `extra` is optional (see MovieDetailsArgs): a deep link has none.
      final args = switch (state.extra) {
        final MovieDetailsArgs args => args,
        _ => const MovieDetailsArgs(),
      };
      return MovieDetailsPage(
        movieId: int.parse(state.pathParameters['id']!),
        heroTag: args.heroTag,
        preview: args.movie,
      );
    },
  ),
  GoRoute(
    path: Routes.seeAll,
    name: RouteNames.seeAll,
    builder: (context, state) => SeeAllPage(
      category: MovieCategory.values.byName(state.pathParameters['category']!),
    ),
  ),
];
