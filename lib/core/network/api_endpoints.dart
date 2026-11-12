/// TMDB REST paths, relative to [baseUrl].
///
/// Paths have no leading slash so Dio appends them to the `/3/` base path.
abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.themoviedb.org/3/';

  static const String trending = 'trending/movie/week';
  static const String topRated = 'movie/top_rated';
  static const String upcoming = 'movie/upcoming';
  static const String nowPlaying = 'movie/now_playing';
  static const String searchMovies = 'search/movie';

  static String movieDetails(int movieId) => 'movie/$movieId';

  /// Lets one details request also return the cast and the videos.
  static const String detailsAppendToResponse = 'credits,videos';
}
