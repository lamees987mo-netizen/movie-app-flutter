import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_state.dart';

export 'see_all_state.dart';

/// Loads every page of one [MovieCategory] for the "See all" grid.
///
/// Created per screen with `sl<SeeAllCubit>(param1: category)`.
class SeeAllCubit extends Cubit<SeeAllState> {
  SeeAllCubit({
    required this.category,
    required this._repository,
  }) : super(const SeeAllLoading());

  final MovieCategory category;
  final MoviesRepository _repository;

  /// Bumped every time the list starts over (first load, retry, refresh).
  ///
  /// A request remembers the value it started with; if the value changed
  /// while it was waiting, its result belongs to an old list and is
  /// dropped. This stops a slow "page 3" from being appended to a list
  /// that was just refreshed back to page 1.
  int _generation = 0;

  /// Shows the skeleton, then loads page 1. Use for the first load and for
  /// "Retry" after a first-page error.
  Future<void> loadFirstPage() async {
    final generation = ++_generation;
    emit(const SeeAllLoading());

    final result = await _repository.getMovies(category);
    // The screen may be gone, or a newer load may have started.
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value):
        emit(
          SeeAllLoaded(
            movies: _withoutDuplicates(const [], value.movies),
            page: value.page,
            hasReachedMax: value.hasReachedMax,
          ),
        );
      case Err(:final failure):
        emit(SeeAllError(failure));
    }
  }

  /// For pull-to-refresh: reloads page 1 while the current grid stays on
  /// screen (no skeleton). If the refresh fails, the current grid is kept.
  /// Without a grid on screen, this behaves like [loadFirstPage].
  Future<void> refresh() async {
    if (state is! SeeAllLoaded) return loadFirstPage();

    final generation = ++_generation;
    final result = await _repository.getMovies(category);
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value):
        emit(
          SeeAllLoaded(
            movies: _withoutDuplicates(const [], value.movies),
            page: value.page,
            hasReachedMax: value.hasReachedMax,
          ),
        );
      case Err():
        // Keep the grid. But a `loadMore` that was running when this
        // refresh started has been dropped (its generation is stale), so
        // clear its spinner; otherwise pagination would stay stuck.
        final current = state;
        if (current is SeeAllLoaded && current.isLoadingMore) {
          emit(
            SeeAllLoaded(
              movies: current.movies,
              page: current.page,
              hasReachedMax: current.hasReachedMax,
            ),
          );
        }
    }
  }

  /// Appends the next page.
  ///
  /// Ignored when nothing is loaded yet, while a page is already loading,
  /// and after the last page. On failure the movies stay and the failure
  /// is stored in [SeeAllLoaded.loadMoreFailure]; calling this again
  /// retries.
  Future<void> loadMore() async {
    final current = state;
    if (current is! SeeAllLoaded ||
        current.isLoadingMore ||
        current.hasReachedMax) {
      return;
    }

    final generation = _generation;
    // Emitting synchronously (before the await) is what makes a second,
    // quick call see `isLoadingMore` and return early.
    emit(
      SeeAllLoaded(
        movies: current.movies,
        page: current.page,
        hasReachedMax: current.hasReachedMax,
        isLoadingMore: true,
      ),
    );

    final result = await _repository.getMovies(
      category,
      page: current.page + 1,
    );
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value):
        emit(
          SeeAllLoaded(
            movies: _withoutDuplicates(current.movies, value.movies),
            page: value.page,
            hasReachedMax: value.hasReachedMax,
          ),
        );
      case Err(:final failure):
        emit(
          SeeAllLoaded(
            movies: current.movies,
            page: current.page,
            hasReachedMax: current.hasReachedMax,
            loadMoreFailure: failure,
          ),
        );
    }
  }

  /// [existing] followed by the movies of [next] that are not already in
  /// it. TMDB lists can shift between two requests, so the same movie may
  /// come back on two pages; showing it twice would also break Hero tags.
  static List<Movie> _withoutDuplicates(
    List<Movie> existing,
    List<Movie> next,
  ) {
    final seenIds = {for (final movie in existing) movie.id};
    return [
      ...existing,
      for (final movie in next)
        if (seenIds.add(movie.id)) movie,
    ];
  }
}
