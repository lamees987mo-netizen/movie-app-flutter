/// Route paths. Use the helper methods to build paths with parameters,
/// e.g. `context.push(Routes.movieDetailsPath(movie.id))`.
abstract final class Routes {
  static const String home = '/';
  static const String movieDetails = '/movie/:id';
  static const String seeAll = '/see-all/:category';
  static const String search = '/search';
  static const String watchlist = '/watchlist';
  static const String settings = '/settings';
  static const String person = '/person/:id';

  static String movieDetailsPath(int movieId) => '/movie/$movieId';

  /// [categoryName] is a `MovieCategory.name`, e.g. `topRated`.
  static String seeAllPath(String categoryName) => '/see-all/$categoryName';

  static String personPath(int personId) => '/person/$personId';
}

/// Route names, for `context.goNamed` / `context.pushNamed`.
abstract final class RouteNames {
  static const String home = 'home';
  static const String movieDetails = 'movieDetails';
  static const String seeAll = 'seeAll';
  static const String search = 'search';
  static const String watchlist = 'watchlist';
  static const String settings = 'settings';
  static const String person = 'person';
}

/// The in-app trailer player: `/trailer/<youtube video id>`.
abstract final class TrailerRoutes {
  static const String path = '/trailer/:key';
  static const String name = 'trailer';

  static String pathFor(String youtubeKey) => '/trailer/$youtubeKey';
}
