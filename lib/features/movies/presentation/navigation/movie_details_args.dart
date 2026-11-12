import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Optional data handed to the details route through go_router's `extra`.
///
/// The URL (`/movie/:id`) is all the page really needs. These extras only
/// make the transition nicer:
/// - [heroTag] lets the poster fly from the list into the details screen.
/// - [movie] lets the page show the poster (and the Hero target) right
///   away, while the full details are still loading.
///
/// Both are `null` when the page is opened from a deep link, and the page
/// must still work then.
class MovieDetailsArgs {
  const MovieDetailsArgs({this.heroTag, this.movie});

  final Object? heroTag;
  final Movie? movie;
}

/// `context.pushMovieDetails(movie, heroTag: tag)` opens the details page.
extension MovieDetailsNavigation on BuildContext {
  Future<void> pushMovieDetails(Movie movie, {Object? heroTag}) => push(
    Routes.movieDetailsPath(movie.id),
    extra: MovieDetailsArgs(heroTag: heroTag, movie: movie),
  );
}
