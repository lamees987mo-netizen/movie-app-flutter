import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Movie App'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get navWatchlist;

  /// Bottom navigation tab with sign-in, profile and settings.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @moviesTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get moviesTrending;

  /// No description provided for @moviesTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get moviesTopRated;

  /// No description provided for @moviesUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get moviesUpcoming;

  /// No description provided for @moviesNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get moviesNowPlaying;

  /// No description provided for @moviesSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get moviesSeeAll;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonErrorGeneric;

  /// No description provided for @commonErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get commonErrorNetwork;

  /// No description provided for @commonErrorServer.
  ///
  /// In en, this message translates to:
  /// **'The server is having trouble. Please try again later.'**
  String get commonErrorServer;

  /// No description provided for @commonNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get commonNotFound;

  /// No description provided for @commonCacheError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read saved data on this device.'**
  String get commonCacheError;

  /// No description provided for @commonOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved content.'**
  String get commonOfflineBanner;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get commonEmpty;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Button that expands a long, cut-off text.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get commonShowMore;

  /// Button that collapses an expanded text again.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get commonShowLess;

  /// No description provided for @detailsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get detailsOverview;

  /// No description provided for @detailsCast.
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get detailsCast;

  /// No description provided for @detailsPlayTrailer.
  ///
  /// In en, this message translates to:
  /// **'Play trailer'**
  String get detailsPlayTrailer;

  /// Movie runtime in minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String detailsRuntimeMinutes(int minutes);

  /// No description provided for @detailsReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release date'**
  String get detailsReleaseDate;

  /// No description provided for @detailsNoOverview.
  ///
  /// In en, this message translates to:
  /// **'No overview available.'**
  String get detailsNoOverview;

  /// No description provided for @detailsAddToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get detailsAddToWatchlist;

  /// No description provided for @detailsRemoveFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get detailsRemoveFromWatchlist;

  /// Title of the row of similar movies at the bottom of the details page.
  ///
  /// In en, this message translates to:
  /// **'Similar movies'**
  String get detailsSimilar;

  /// Section title above an actor's biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get personBiography;

  /// Shown when TMDB has no biography for the actor.
  ///
  /// In en, this message translates to:
  /// **'No biography available.'**
  String get personNoBiography;

  /// Section title above the movies an actor played in.
  ///
  /// In en, this message translates to:
  /// **'Known for'**
  String get personKnownFor;

  /// The actor's birthday. The date is already formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'Born {date}'**
  String personBorn(String date);

  /// Screen-reader label read before the actor's place of birth.
  ///
  /// In en, this message translates to:
  /// **'Place of birth'**
  String get personPlaceOfBirth;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search movies'**
  String get searchHint;

  /// No description provided for @searchEmptyQuery.
  ///
  /// In en, this message translates to:
  /// **'Type a movie name to start searching.'**
  String get searchEmptyQuery;

  /// Shown when a search returns no results.
  ///
  /// In en, this message translates to:
  /// **'No movies match \"{query}\".'**
  String searchNoResults(String query);

  /// No description provided for @watchlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your watchlist is empty'**
  String get watchlistEmptyTitle;

  /// No description provided for @watchlistEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Movies you save will appear here, even offline.'**
  String get watchlistEmptySubtitle;

  /// No description provided for @watchlistClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get watchlistClearAll;

  /// No description provided for @watchlistClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear watchlist?'**
  String get watchlistClearConfirmTitle;

  /// No description provided for @watchlistClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every movie from your watchlist.'**
  String get watchlistClearConfirmBody;

  /// No description provided for @watchlistCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get watchlistCancel;

  /// No description provided for @watchlistConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get watchlistConfirm;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsArabic;

  /// Title of the theme and language section on the account page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettings;

  /// No description provided for @accountGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your watchlist'**
  String get accountGuestTitle;

  /// Shown to guests on the account page, explaining why to sign in.
  ///
  /// In en, this message translates to:
  /// **'Save your watchlist to your account and see it on every device you sign in on. You can keep using the app without an account.'**
  String get accountGuestBody;

  /// No description provided for @accountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignIn;

  /// Number of movies in the signed-in user's watchlist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No saved movies} =1{1 saved movie} other{{count} saved movies}}'**
  String accountWatchlistCount(int count);

  /// No description provided for @accountWatchlistSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced with your account'**
  String get accountWatchlistSynced;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteConfirmTitle;

  /// No description provided for @accountDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and the watchlist saved in it. This can\'t be undone.'**
  String get accountDeleteConfirmBody;

  /// Confirm button of the delete-account dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted.'**
  String get accountDeleted;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get authName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Screen-reader label of the eye button in the password field.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authSwitchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authSwitchToSignUp;

  /// No description provided for @authSwitchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authSwitchToSignIn;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Shown after asking for a password reset email.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, we sent it a link to reset the password.'**
  String authResetEmailSent(String email);

  /// Between the email form and the Google button.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordRequired;

  /// Validation error when a new password is too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters'**
  String authPasswordTooShort(int min);

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Choose a longer one.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'This email address isn\'t valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For your security, sign out and sign in again, then delete your account.'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get authErrorCancelled;

  /// No description provided for @authErrorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn\'t available right now.'**
  String get authErrorUnavailable;

  /// No description provided for @tmdbAttribution.
  ///
  /// In en, this message translates to:
  /// **'This product uses the TMDB API but is not endorsed or certified by TMDB.'**
  String get tmdbAttribution;

  /// App bar title of the trailer screen when the movie title is unknown (e.g. opened from a link).
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get trailerTitle;

  /// Button and app bar action that opens the trailer in the YouTube app or the browser instead of the in-app player.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get trailerOpenInYoutube;

  /// Shown on the trailer screen when the in-app player reports an error (e.g. the owner blocked embedding).
  ///
  /// In en, this message translates to:
  /// **'This trailer can\'t be played in the app.'**
  String get trailerError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
