import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_state.dart';

export 'movie_details_state.dart';

/// Loads the details of one movie.
///
/// The movie id is given once, when the cubit is created
/// (`sl<MovieDetailsCubit>(param1: movieId)`), so [load] needs no
/// arguments and "Retry" can simply call it again.
class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  MovieDetailsCubit({
    required this.movieId,
    required this._getMovieDetails,
  }) : super(const MovieDetailsLoading());

  final int movieId;
  final GetMovieDetails _getMovieDetails;

  /// Loads (or reloads after an error) the details.
  Future<void> load() async {
    emit(const MovieDetailsLoading());
    final result = await _getMovieDetails(movieId);

    // The user may have popped the screen while we were waiting.
    if (isClosed) return;

    emit(
      result.fold(
        onSuccess: MovieDetailsLoaded.new,
        onFailure: MovieDetailsError.new,
      ),
    );
  }
}
