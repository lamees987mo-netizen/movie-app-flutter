/// Route paths. Use the helper methods to build paths with parameters,
/// e.g. `context.push(Routes.movieDetailsPath(movie.id))`.
abstract final class Routes {
  static const String home = '/';
  static const String movieDetails = '/movie/:id';
  static const String seeAll = '/see-all/:category';
  static const String search = '/search';
  static const String watchlist = '/watchlist';
  static const String account = '/account';
  static const String signIn = '/sign-in';
  static const String person = '/person/:id';

  /// Old path of the Settings tab; redirects to [account].
  static const String settings = '/settings';

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
  static const String account = 'account';
  static const String signIn = 'signIn';
  static const String person = 'person';
}
