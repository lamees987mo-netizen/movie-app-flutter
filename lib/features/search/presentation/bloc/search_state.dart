import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The state of the Search screen.
///
/// `sealed` means these are the only possible states, so a
/// `switch (state)` in the UI must handle all of them.
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// The query is empty: invite the user to type.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

/// A request is in flight: show a skeleton.
final class SearchLoading extends SearchState {
  const SearchLoading();
}

/// At least one page of results is on screen.
///
/// Like the "See all" grid, an error while loading the *next* page does
/// not replace the results: it is kept in [loadMoreFailure] and shown as
/// a small retry below them. The defaults describe a single, last page.
final class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.movies,
    required this.query,
    this.page = 1,
    this.hasReachedMax = true,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  /// Every result loaded so far, without duplicates.
  final List<Movie> movies;
  final String query;

  /// The last page that was loaded (1-based).
  final int page;

  /// `true` when there is no next page to request.
  final bool hasReachedMax;

  /// `true` while the next page is being requested.
  final bool isLoadingMore;

  /// Why the last attempt to load the next page failed, if it did.
  final Failure? loadMoreFailure;

  @override
  List<Object?> get props => [
    movies,
    query,
    page,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailure,
  ];
}

/// The search worked but found nothing for [query].
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchError extends SearchState {
  const SearchError({required this.failure, required this.query});

  final Failure failure;
  final String query;

  @override
  List<Object?> get props => [failure, query];
}
