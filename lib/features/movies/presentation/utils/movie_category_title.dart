import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The localized title of a [MovieCategory], e.g. "Top Rated".
///
/// It lives in the presentation layer because the domain must not know
/// about translations.
extension MovieCategoryTitle on MovieCategory {
  String title(AppLocalizations l10n) => switch (this) {
    MovieCategory.trending => l10n.moviesTrending,
    MovieCategory.topRated => l10n.moviesTopRated,
    MovieCategory.upcoming => l10n.moviesUpcoming,
    MovieCategory.nowPlaying => l10n.moviesNowPlaying,
  };
}
