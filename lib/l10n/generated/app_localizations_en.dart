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
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get accountSignIn => 'Sign in';

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
  String get accountPageTitle => 'Profile';

  @override
  String get accountGuestName => 'Guest';

  @override
  String get accountSectionAccount => 'Account';

  @override
  String get accountManageProfile => 'Manage profile';

  @override
  String get accountSecurity => 'Security & privacy';

  @override
  String get accountMyWatchlist => 'My watchlist';

  @override
  String get accountProfileName => 'Name';

  @override
  String get accountProfileNameRequired => 'Enter your name';

  @override
  String get accountProfileSave => 'Save';

  @override
  String get accountProfileSaved => 'Your name was saved.';

  @override
  String get accountSignInMethod => 'Sign-in method';

  @override
  String get accountSignInMethodGoogle => 'Google';

  @override
  String get accountSignInMethodEmail => 'Email and password';

  @override
  String get accountSectionSignIn => 'Sign-in';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountChangePasswordHint =>
      'We\'ll email you a link to choose a new password.';

  @override
  String accountPasswordResetSent(String email) {
    return 'We sent a link to $email to change your password.';
  }

  @override
  String get accountGooglePasswordNote =>
      'You sign in with Google, so your password is managed in your Google account.';

  @override
  String get accountSectionDanger => 'Danger zone';

  @override
  String get accountDeleteHint =>
      'Permanently delete your account and its synced watchlist.';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsHelpCenter => 'Help center';

  @override
  String get settingsTerms => 'Terms & policies';

  @override
  String get settingsAbout => 'About us';

  @override
  String get settingsLinkError => 'Couldn\'t open the link.';

  @override
  String get settingsTermsIntro =>
      'Movie App is a free portfolio project. This page explains what it stores and where.';

  @override
  String get settingsTermsDeviceTitle => 'On your device';

  @override
  String get settingsTermsDeviceBody =>
      'Your watchlist, theme and language are saved on this phone, so they work offline.';

  @override
  String get settingsTermsAccountTitle => 'If you sign in';

  @override
  String get settingsTermsAccountBody =>
      'Your email, name and watchlist are stored in Firebase (by Google), so your watchlist follows you to other devices. Deleting your account deletes them.';

  @override
  String get settingsTermsAnalyticsTitle => 'Analytics and crash reports';

  @override
  String get settingsTermsAnalyticsBody =>
      'The app sends anonymous usage events and crash reports to Firebase to help fix bugs. They don\'t include your email or name.';

  @override
  String get settingsTermsTmdbTitle => 'Movie data';

  @override
  String get settingsTermsTmdbBody =>
      'Movies, posters and trailers come from The Movie Database (TMDB) and YouTube. The app doesn\'t host or stream full movies.';

  @override
  String settingsAboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsAboutDescription =>
      'Browse trending movies, search, watch trailers and keep a watchlist, in English and Arabic.';

  @override
  String get settingsAboutSourceCode => 'Source code on GitHub';

  @override
  String get settingsAboutLicenses => 'Open-source licenses';

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

  @override
  String get trailerTitle => 'Trailer';

  @override
  String get trailerOpenInYoutube => 'Open in YouTube';

  @override
  String get trailerError => 'This trailer can\'t be played in the app.';
}
