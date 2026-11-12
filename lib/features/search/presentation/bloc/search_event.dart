import 'package:equatable/equatable.dart';

/// What the user did on the Search screen.
sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// The text in the search field changed (sent on every keystroke).
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// The user tapped "Retry" after an error: search the last query again.
final class SearchRetried extends SearchEvent {
  const SearchRetried();
}
