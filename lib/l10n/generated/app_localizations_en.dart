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
  String get navAccount => 'Account';

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
  String get commonCancel => 'Cancel';

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
  String get accountSettings => 'Settings';

  @override
  String get accountGuestTitle => 'Sign in to sync your watchlist';

  @override
  String get accountGuestBody =>
      'Save your watchlist to your account and see it on every device you sign in on. You can keep using the app without an account.';

  @override
  String get accountSignIn => 'Sign in';

  @override
  String accountWatchlistCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saved movies',
      one: '1 saved movie',
      zero: 'No saved movies',
    );
    return '$_temp0';
  }

  @override
  String get accountWatchlistSynced => 'Synced with your account';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteConfirmTitle => 'Delete your account?';

  @override
  String get accountDeleteConfirmBody =>
      'This permanently deletes your account and the watchlist saved in it. This can\'t be undone.';

  @override
  String get accountDeleteConfirm => 'Delete';

  @override
  String get accountDeleted => 'Your account was deleted.';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Create account';

  @override
  String get authName => 'Name (optional)';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSwitchToSignUp => 'New here? Create an account';

  @override
  String get authSwitchToSignIn => 'Already have an account? Sign in';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String authResetEmailSent(String email) {
    return 'If an account exists for $email, we sent it a link to reset the password.';
  }

  @override
  String get authOr => 'or';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Enter a valid email address';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String authPasswordTooShort(int min) {
    return 'Use at least $min characters';
  }

  @override
  String get authErrorInvalidCredentials => 'Wrong email or password.';

  @override
  String get authErrorEmailInUse =>
      'An account with this email already exists. Try signing in.';

  @override
  String get authErrorWeakPassword =>
      'This password is too weak. Choose a longer one.';

  @override
  String get authErrorInvalidEmail => 'This email address isn\'t valid.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get authErrorRequiresRecentLogin =>
      'For your security, sign out and sign in again, then delete your account.';

  @override
  String get authErrorCancelled => 'Sign-in was cancelled.';

  @override
  String get authErrorUnavailable => 'Sign-in isn\'t available right now.';

  @override
  String get tmdbAttribution =>
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';
}
