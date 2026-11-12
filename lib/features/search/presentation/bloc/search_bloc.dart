import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search_event.dart';
import 'package:movie_app/features/search/presentation/bloc/search_state.dart';

export 'search_event.dart';
export 'search_state.dart';

/// Searches movies by title while the user types.
///
/// It is a `Bloc` (not a `Cubit`) because it needs an event transformer
/// to debounce typing and drop out-of-date requests.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// [debounceDuration] is how long the user must stop typing before we
  /// search. Tests pass a short value so they run fast.
  SearchBloc({
    required this._repository,
    this.debounceDuration = const Duration(milliseconds: 400),
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
    // Both events share ONE handler so that they also cancel each other:
    // typing during a retry drops the retry.
    on<SearchEvent>(_onEvent, transformer: restartable());
  }

  final MoviesRepository _repository;
  final Duration debounceDuration;

  /// The last trimmed query, used by [SearchRetried].
  String _query = '';

  Future<void> _onEvent(SearchEvent event, Emitter<SearchState> emit) async {
    switch (event) {
      case SearchQueryChanged(:final query):
        _query = query.trim();
        if (_query.isEmpty) {
          // Nothing to search: no request, no waiting.
          emit(const SearchInitial());
          return;
        }
        await Future<void>.delayed(debounceDuration);
        // A newer event cancelled this handler while we were waiting.
        if (emit.isDone) return;
      case SearchRetried():
        // The user asked explicitly, so search right away (no debounce).
        if (_query.isEmpty) return;
    }
    await _search(_query, emit);
  }

  Future<void> _search(String query, Emitter<SearchState> emit) async {
    emit(const SearchLoading());
    final result = await _repository.searchMovies(query);

    // Cancelled by a newer event (the result is stale) or the screen was
    // closed while we were waiting.
    if (emit.isDone || isClosed) return;

    switch (result) {
      case Success(:final value) when value.movies.isEmpty:
        emit(SearchEmpty(query));
      case Success(:final value):
        emit(SearchLoaded(movies: value.movies, query: query));
      case Err(:final failure):
        emit(SearchError(failure: failure, query: query));
    }
  }
}
