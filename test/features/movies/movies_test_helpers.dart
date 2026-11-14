import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shared test data for the movies feature.
///
/// Every image path is `null`, so widgets show placeholders and
/// `cached_network_image` never tries to download anything.
const tMovie1 = Movie(
  id: 1,
  title: 'Inside Out 2',
  overview: 'Emotions.',
  voteAverage: 7.6,
);

const tMovie2 = Movie(
  id: 2,
  title: 'Dune: Part Two',
  overview: 'Spice.',
  voteAverage: 8.2,
);

const tPage = PaginatedMovies(
  movies: [tMovie1, tMovie2],
  page: 1,
  totalPages: 5,
);

const tDetails = MovieDetails(
  movie: tMovie1,
  runtime: 97,
  genres: ['Animation', 'Family'],
  cast: [CastMember(id: 56322, name: 'Amy Poehler', character: 'Joy (voice)')],
  trailerYoutubeKey: 'abc123',
);

/// Wraps [child] in a localized [MaterialApp], like the real app.
Widget wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

/// Finds Skeletonizer widgets. `find.byType` does not work here because
/// the `Skeletonizer(...)` constructor builds a private subclass.
final Finder findSkeletonizer = find.byWidgetPredicate(
  (widget) => widget is Skeletonizer,
);
