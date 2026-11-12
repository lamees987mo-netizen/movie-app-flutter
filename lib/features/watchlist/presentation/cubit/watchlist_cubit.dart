import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_state.dart';

export 'watchlist_state.dart';

/// Keeps the Watchlist tab in sync with local storage.
///
/// It listens to [WatchlistRepository.watch], so a movie saved or removed
/// anywhere in the app (e.g. on the details screen) shows up here at once.
class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({required this._repository}) : super(const WatchlistLoading());

  final WatchlistRepository _repository;
  StreamSubscription<List<Movie>>? _subscription;

  /// Starts listening. Also used for "Retry" after an error.
  Future<void> load() async {
    emit(const WatchlistLoading());
    await _subscription?.cancel();
    if (isClosed) return;
    _subscription = _repository.watch().listen(
      (movies) => emit(
        movies.isEmpty ? const WatchlistEmpty() : WatchlistLoaded(movies),
      ),
      // The repository only emits `Failure`s as errors.
      onError: (Object error) => emit(
        WatchlistError(error is Failure ? error : const UnknownFailure()),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
