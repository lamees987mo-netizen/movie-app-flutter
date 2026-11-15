import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/analytics/analytics_service.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search_event.dart';
import 'package:movie_app/features/search/presentation/bloc/search_state.dart';

export 'search_event.dart';
export 'search_state.dart';

/// Searches movies by title while the user types, and loads more results
/// as the user scrolls.
///
/// It is a `Bloc` (not a `Cubit`) because it needs an event transformer
/// to debounce typing and drop out-of-date requests.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// [debounceDuration] is how long the user must stop typing before we
  /// search. Tests pass a short value so they run fast.
  SearchBloc({
    required this._repository,
    this.debounceDuration = const Duration(milliseconds: 400),
    this._analytics = const NoopAnalyticsService(),
  }) : super(const SearchInitial()) {
    // Debounce + cancellation without an extra package:
    //
    // `restartable()` cancels the handler that is still running whenever
    // a new event arrives, and starts the handler for the new event.
    // The handler first waits [debounceDuration]. So while the user types
    // fast, every keystroke cancels the previous handler during its wait,
    // and only the last one gets to call the repository (= debounce).
    // If a request is already in flight when a new event comes, that
    // handler is cancelled too, so its old result is never emitted
    // (= stale requests are dropped).
    //
    // All page-1 events share ONE handler so that they also cancel each
    // other: typing during a retry drops the retry.
    on<SearchQueryEvent>(_onQueryEvent, transformer: restartable());

    // The next page has its own handler: scrolling must not cancel a
    // search. `droppable()` ignores new requests while one is running.
    on<SearchNextPageRequested>(_onNextPage, transformer: droppable());
  }

  final MoviesRepository _repository;
  final AnalyticsService _analytics;
  final Duration debounceDuration;

  /// The last trimmed query, used by [SearchRetried] and
  /// [SearchLanguageChanged].
  String _query = '';

  /// Bumped every time the results start over (new search or cleared
  /// field). A next-page request remembers the value it started with; if
  /// it changed meanwhile, the page belongs to old results and is dropped.
  /// (The page handler is not cancelled by `restartable()`, because it is
  /// a different handler.)
  int _generation = 0;

  Future<void> _onQueryEvent(
    SearchQueryEvent event,
    Emitter<SearchState> emit,
  ) async {
    switch (event) {
      case SearchQueryChanged(:final query):
        _query = query.trim();
        if (_query.isEmpty) {
          // Nothing to search: no request, no waiting.
          _generation++;
          emit(const SearchInitial());
          return;
        }
        // E.g. "dune" + space, or "dune" -> "dunes" -> "dune": the results
        // for this query are already on screen, so don't search again.
        if (_isShowingResultsFor(_query)) return;
        await Future<void>.delayed(debounceDuration);
        // A newer event cancelled this handler while we were waiting.
        if (emit.isDone) return;
      case SearchRetried():
      case SearchLanguageChanged():
        // The user (or the language switch) asked explicitly, so search
        // right away (no debounce).
        if (_query.isEmpty) return;
    }
    await _search(_query, emit);
  }

  /// Only finished results count: a search that was still loading has
  /// just been cancelled by this event, so it must run again.
  bool _isShowingResultsFor(String query) => switch (state) {
    SearchLoaded(query: final shown) ||
    SearchEmpty(query: final shown) => shown == query,
    _ => false,
  };

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    final generation = ++_generation;
    emit(const SearchLoading());
    // Logged here, after the debounce: one event per real search, not per
    // keystroke.
    unawaited(_analytics.logSearch(query));
    final result = await _repository.searchMovies(query);

    // Cancelled by a newer event (the result is stale), the screen was
    // closed, or newer results started meanwhile.
    if (emit.isDone || isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value) when value.movies.isEmpty:
        emit(SearchEmpty(query));
      case Success(:final value):
        emit(
          SearchLoaded(
            movies: _withoutDuplicates(const [], value.movies),
            query: query,
            page: value.page,
            hasReachedMax: value.hasReachedMax,
          ),
        );
      case Err(:final failure):
        emit(SearchError(failure: failure, query: query));
    }
  }

  /// Appends the next page of the results on screen.
  ///
  /// Ignored when no results are shown, while a page is already loading,
  /// and after the last page. On failure the results stay and the failure
  /// is stored in [SearchLoaded.loadMoreFailure]; requesting again retries.
  Future<void> _onNextPage(
    SearchNextPageRequested event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is! SearchLoaded ||
        current.isLoadingMore ||
        current.hasReachedMax) {
      return;
    }

    final generation = _generation;
    emit(
      SearchLoaded(
        movies: current.movies,
        query: current.query,
        page: current.page,
        hasReachedMax: current.hasReachedMax,
        isLoadingMore: true,
      ),
    );

    // The query of the results on screen, not [_query]: the user may
    // already be typing a new one that is still waiting for its debounce.
    final result = await _repository.searchMovies(
      current.query,
      page: current.page + 1,
    );
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value):
        emit(
          SearchLoaded(
            movies: _withoutDuplicates(current.movies, value.movies),
            query: current.query,
            page: value.page,
            hasReachedMax: value.hasReachedMax,
          ),
        );
      case Err(:final failure):
        emit(
          SearchLoaded(
            movies: current.movies,
            query: current.query,
            page: current.page,
            hasReachedMax: current.hasReachedMax,
            loadMoreFailure: failure,
          ),
        );
    }
  }

  /// [existing] followed by the movies of [next] that are not already in
  /// it. Results can shift between two requests, so the same movie may
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
