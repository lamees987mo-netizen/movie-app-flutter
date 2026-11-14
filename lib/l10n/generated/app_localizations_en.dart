// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Movie App';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navWatchlist => 'Watchlist';

  @override
  String get navSettings => 'Settings';

  @override
  String get moviesTrending => 'Trending';

  @override
  String get moviesTopRated => 'Top Rated';

  @override
  String get moviesUpcoming => 'Upcoming';

  @override
  String get moviesNowPlaying => 'Now Playing';

  @override
  String get moviesSeeAll => 'See all';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get commonErrorNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get commonErrorServer =>
      'The server is having trouble. Please try again later.';

  @override
  String get commonNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get commonCacheError => 'Couldn\'t read saved data on this device.';

  @override
  String get commonOfflineBanner => 'You\'re offline. Showing saved content.';

  @override
  String get commonEmpty => 'Nothing here yet.';

  @override
  String get commonShowMore => 'Show more';

  @override
  String get commonShowLess => 'Show less';

  @override
  String get detailsOverview => 'Overview';

  @override
  String get detailsCast => 'Cast';

  @override
  String get detailsPlayTrailer => 'Play trailer';

  @override
  String detailsRuntimeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get detailsReleaseDate => 'Release date';

  @override
  String get detailsNoOverview => 'No overview available.';

  @override
  String get detailsAddToWatchlist => 'Add to watchlist';

  @override
  String get detailsRemoveFromWatchlist => 'Remove from watchlist';

  @override
  String get detailsSimilar => 'Similar movies';

  @override
  String get personBiography => 'Biography';

  @override
  String get personNoBiography => 'No biography available.';

  @override
  String get personKnownFor => 'Known for';

  @override
  String personBorn(String date) {
    return 'Born $date';
  }

  @override
  String get personPlaceOfBirth => 'Place of birth';

  @override
  String get searchHint => 'Search movies';

  @override
  String get searchEmptyQuery => 'Type a movie name to start searching.';

  @override
  String searchNoResults(String query) {
    return 'No movies match \"$query\".';
  }

  @override
  String get watchlistEmptyTitle => 'Your watchlist is empty';

  @override
  String get watchlistEmptySubtitle =>
      'Movies you save will appear here, even offline.';

  @override
  String get watchlistClearAll => 'Clear all';

  @override
  String get watchlistClearConfirmTitle => 'Clear watchlist?';

  @override
  String get watchlistClearConfirmBody =>
      'This removes every movie from your watchlist.';

  @override
  String get watchlistCancel => 'Cancel';

  @override
  String get watchlistConfirm => 'Clear';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get tmdbAttribution =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';
}
