import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  /// The language-code function returns the app's current language (e.g.
  /// `ar`); it is part of the cache key, like in `LanguageInterceptor`.
  MoviesRepositoryImpl(
    this._remoteDataSource, {
    required this._localDataSource,
    required this._languageCode,
  });

  final MoviesRemoteDataSource _remoteDataSource;
  final MoviesLocalDataSource _localDataSource;
  final String Function() _languageCode;

  /// Page 1 is saved after every successful download. When there is no
  /// internet, the saved copy is returned instead of a `NetworkFailure`.
  /// Other errors (server, unknown) are returned as they are: falling back
  /// would hide a real problem.
  @override
  Future<Result<PaginatedMovies>> getMovies(
    MovieCategory category, {
    int page = 1,
  }) async {
    final languageCode = _languageCode();
    final result = await _guard(() async {
      final model = await _remoteDataSource.getMovies(category, page: page);
      if (page == 1) await _saveQuietly(category, languageCode, model);
      return model.toEntity();
    });

    if (result case Err(failure: NetworkFailure()) when page == 1) {
      final cached = _readQuietly(category, languageCode);
      if (cached != null) return Success(cached.toEntity());
    }
    return result;
  }

  /// The cache is a bonus: if saving fails, the fresh data is still shown.
  Future<void> _saveQuietly(
    MovieCategory category,
    String languageCode,
    MoviesPageModel model,
  ) async {
    try {
      await _localDataSource.cacheFirstPage(category, languageCode, model);
    } on CacheException catch (error) {
      log('Could not cache $category', error: error);
    }
  }

  /// If the cache cannot be read, behave as if there were no cache, so the
  /// user sees the normal "no internet" error.
  MoviesPageModel? _readQuietly(MovieCategory category, String languageCode) {
    try {
      return _localDataSource.getCachedFirstPage(category, languageCode);
    } on CacheException catch (error) {
      log('Could not read cached $category', error: error);
      return null;
    }
  }

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) {
    return _guard(() async {
      final model = await _remoteDataSource.getMovieDetails(movieId);
      return model.toEntity();
    });
  }

  @override
  Future<Result<PaginatedMovies>> searchMovies(
    String query, {
    int page = 1,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.searchMovies(query, page: page);
      return model.toEntity();
    });
  }

  /// Runs [action] and converts any exception into the matching [Failure].
  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on NetworkException {
      return const Err(NetworkFailure());
    } on ServerException catch (e) {
      if (e.statusCode == 404) return const Err(NotFoundFailure());
      return Err(ServerFailure(e.statusCode));
    } on CacheException {
      return const Err(CacheFailure());
    } on Object catch (error, stackTrace) {
      // E.g. unexpected JSON shape. Logged so it is not silently swallowed.
      log('Unexpected error', error: error, stackTrace: stackTrace);
      return const Err(UnknownFailure());
    }
  }
}
