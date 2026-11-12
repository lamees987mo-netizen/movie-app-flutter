import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_state.dart';

export 'watchlist_toggle_state.dart';

/// Adds or removes one [movie] (the "Add to watchlist" button).
///
/// Created per screen with `sl<WatchlistToggleCubit>(param1: movie)`.
/// It calls the repository directly: `WatchlistRepository.toggle` already
/// holds the add-or-remove logic, so a `ToggleWatchlist` use case would
/// only forward the call (see CONVENTIONS.md).
class WatchlistToggleCubit extends Cubit<WatchlistToggleState> {
  WatchlistToggleCubit({required this.movie, required this._repository})
    : super(const WatchlistToggleState());

  final Movie movie;
  final WatchlistRepository _repository;

  bool _busy = false;

  /// Reads whether [movie] is already saved.
  Future<void> load() async {
    final result = await _repository.isInWatchlist(movie.id);
    if (isClosed) return;
    emit(
      switch (result) {
        Success(:final value) => WatchlistToggleState(isSaved: value),
        Err(:final failure) => WatchlistToggleState(
          isSaved: state.isSaved,
          failure: failure,
        ),
      },
    );
  }

  /// Saves the movie if missing, removes it otherwise. Taps while a toggle
  /// is still running are ignored.
  Future<void> toggle() async {
    if (_busy) return;
    _busy = true;
    // Clear an old error, so the same error can be shown again.
    if (state.failure != null) {
      emit(WatchlistToggleState(isSaved: state.isSaved));
    }

    final result = await _repository.toggle(movie);
    _busy = false;
    if (isClosed) return;
    emit(
      switch (result) {
        Success(:final value) => WatchlistToggleState(isSaved: value),
        Err(:final failure) => WatchlistToggleState(
          isSaved: state.isSaved,
          failure: failure,
        ),
      },
    );
  }
}
