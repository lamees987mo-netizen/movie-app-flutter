import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// What the app tracks: which screens people open, and a few actions.
///
/// Features depend on this interface, not on Firebase, so their tests can
/// use [NoopAnalyticsService] and never need Firebase.
abstract interface class AnalyticsService {
  /// Plug into the router so every screen change is logged.
  List<NavigatorObserver> get navigatorObservers;

  Future<void> logWatchlistChanged({required int movieId, required bool added});

  Future<void> logSearch(String query);
}

/// Sends events to Firebase Analytics.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  List<NavigatorObserver> get navigatorObservers => [
    FirebaseAnalyticsObserver(analytics: _analytics),
  ];

  @override
  Future<void> logWatchlistChanged({
    required int movieId,
    required bool added,
  }) => _analytics.logEvent(
    name: added ? 'watchlist_add' : 'watchlist_remove',
    parameters: {'movie_id': movieId},
  );

  // Firebase's standard "search" event, so it shows in the default reports.
  @override
  Future<void> logSearch(String query) =>
      _analytics.logSearch(searchTerm: query);
}

/// Does nothing. Used in tests, and when Firebase is not set up (for
/// example on iOS, which has no `GoogleService-Info.plist` in this repo).
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  List<NavigatorObserver> get navigatorObservers => const [];

  @override
  Future<void> logWatchlistChanged({
    required int movieId,
    required bool added,
  }) async {}

  @override
  Future<void> logSearch(String query) async {}
}
