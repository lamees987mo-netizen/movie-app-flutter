import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_state.dart';

export 'movie_section_state.dart';

/// Loads the first page of one [MovieCategory] for a Home section.
///
/// One class serves every section: Home creates one cubit per category
/// (`sl<MovieSectionCubit>(param1: MovieCategory.topRated)`).
///
/// It talks to the repository directly because there is no extra logic to
/// put in a use case (see CONVENTIONS.md).
class MovieSectionCubit extends Cubit<MovieSectionState> {
  /// `this._repository` is a private named parameter (Dart 3.12+): callers
  /// still write `repository: ...`, but the field stays private.
  MovieSectionCubit({
    required this.category,
    required this._repository,
  }) : super(const MovieSectionLoading());

  final MovieCategory category;
  final MoviesRepository _repository;

  /// Shows the skeleton, then loads. Use for the first load and for
  /// "Retry" after an error.
  Future<void> load() async {
    emit(const MovieSectionLoading());
    await _fetch(keepMoviesOnError: false);
  }

  /// For pull-to-refresh.
  ///
  /// If movies are already on screen they stay visible while the request
  /// runs (no skeleton flash), and they also stay if the refresh fails:
  /// slightly old movies are more useful than an error. Without movies on
  /// screen (error state), this behaves like [load].
  Future<void> refresh() async {
    if (state is! MovieSectionLoaded) return load();
    await _fetch(keepMoviesOnError: true);
  }

  /// Counts requests, so only the newest one may update the screen.
  int _generation = 0;

  Future<void> _fetch({required bool keepMoviesOnError}) async {
    final generation = ++_generation;
    final result = await _repository.getMovies(category);

    // Stop if the user left the screen (emitting on a closed cubit throws),
    // or if a newer request started meanwhile: e.g. after a quick
    // Arabic → English switch, a slow Arabic answer must not overwrite the
    // English one.
    if (isClosed || generation != _generation) return;

    switch (result) {
      case Success(:final value):
        emit(
          MovieSectionLoaded(value.movies, isFromCache: value.isFromCache),
        );
      case Err(:final failure):
        if (!keepMoviesOnError) emit(MovieSectionError(failure));
    }
  }
}
