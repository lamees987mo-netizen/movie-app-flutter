import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The state of the paginated "See all" grid of one category.
sealed class SeeAllState extends Equatable {
  const SeeAllState();

  @override
  List<Object?> get props => [];
}

/// The first page is in flight: show a skeleton grid.
final class SeeAllLoading extends SeeAllState {
  const SeeAllLoading();
}

/// The first page failed: show a full-screen error with "Retry".
final class SeeAllError extends SeeAllState {
  const SeeAllError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// At least one page is on screen.
///
/// Errors while loading the *next* page do not replace the grid: they are
/// kept in [loadMoreFailure] and shown as a small retry at the bottom.
final class SeeAllLoaded extends SeeAllState {
  const SeeAllLoaded({
    required this.movies,
    required this.page,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  /// Every movie loaded so far, without duplicates.
  final List<Movie> movies;

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
    page,
    hasReachedMax,
    isLoadingMore,
    loadMoreFailure,
  ];
}
