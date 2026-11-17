import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/movies/presentation/pages/home_page.dart';
import 'package:movie_app/features/movies/presentation/pages/movie_details_page.dart';
import 'package:movie_app/features/movies/presentation/pages/see_all_page.dart';
import 'package:movie_app/features/movies/presentation/pages/trailer_page.dart';
import 'package:movie_app/features/movies/presentation/utils/youtube.dart';

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
    // A bad link like `/movie/abc` goes Home instead of crashing the page.
    redirect: (context, state) => _movieId(state) == null ? Routes.home : null,
    builder: (context, state) {
      // `extra` is optional (see MovieDetailsArgs): a deep link has none.
      final args = switch (state.extra) {
        final MovieDetailsArgs args => args,
        _ => const MovieDetailsArgs(),
      };
      return MovieDetailsPage(
        movieId: _movieId(state)!,
        heroTag: args.heroTag,
        preview: args.movie,
      );
    },
  ),
  GoRoute(
    path: Routes.seeAll,
    name: RouteNames.seeAll,
    // Same for an unknown category like `/see-all/popular`.
    redirect: (context, state) => _category(state) == null ? Routes.home : null,
    builder: (context, state) => SeeAllPage(category: _category(state)!),
  ),
  GoRoute(
    path: TrailerRoutes.path,
    name: TrailerRoutes.name,
    // Only real YouTube ids (11 characters) reach the player.
    redirect: (context, state) =>
        _youtubeKey(state) == null ? Routes.home : null,
    builder: (context, state) => TrailerPage(
      youtubeKey: _youtubeKey(state)!,
      // The movie title, when opened from the details page.
      title: switch (state.extra) {
        final String title => title,
        _ => null,
      },
    ),
  ),
];

int? _movieId(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '');

MovieCategory? _category(GoRouterState state) =>
    MovieCategory.values.asNameMap()[state.pathParameters['category']];

String? _youtubeKey(GoRouterState state) =>
    switch (state.pathParameters['key']) {
      final String key when isValidYoutubeKey(key) => key,
      _ => null,
    };
