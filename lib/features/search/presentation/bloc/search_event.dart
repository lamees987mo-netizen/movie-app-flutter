import 'package:equatable/equatable.dart';

/// What the user did on the Search screen.
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Events that (re)start the search from page 1.
///
/// They share one handler, so a newer one cancels an older one that is
/// still waiting or loading (see `SearchBloc`).
sealed class SearchQueryEvent extends SearchEvent {
  const SearchQueryEvent();
}

/// The text in the search field changed (sent on every keystroke).
final class SearchQueryChanged extends SearchQueryEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// The user tapped "Retry" after an error: search the last query again.
final class SearchRetried extends SearchQueryEvent {
  const SearchRetried();
}

/// The app language changed: TMDB returns titles in the app's language,
/// so search the current query again.
final class SearchLanguageChanged extends SearchQueryEvent {
  const SearchLanguageChanged();
}

/// The user scrolled near the end of the results (or tapped "Retry" below
/// them): load the next page and append it.
final class SearchNextPageRequested extends SearchEvent {
  const SearchNextPageRequested();
}
