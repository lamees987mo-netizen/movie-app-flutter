import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
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
  /// internet, the saved copy is returned instead of a `NetworkFailure`,
  /// marked with `isFromCache` so Home can show the offline banner.
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
      if (page == 1) {
        await _saveQuietly(
          '$category',
          () => _localDataSource.cacheFirstPage(category, languageCode, model),
        );
      }
      return model.toEntity();
    });

    if (result case Err(failure: NetworkFailure()) when page == 1) {
      final cached = _readQuietly(
        '$category',
        () => _localDataSource.getCachedFirstPage(category, languageCode),
      );
      if (cached != null) return Success(cached.toEntity(isFromCache: true));
    }
    return result;
  }

  /// Works like [getMovies]: every successful download is saved (per movie
  /// and language), and without internet the saved copy is returned.
  /// Because the user opens the details before adding a movie to the
  /// watchlist, watchlist movies can be opened offline too.
  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async {
    final languageCode = _languageCode();
    final result = await _guard(() async {
      final model = await _remoteDataSource.getMovieDetails(movieId);
      await _saveQuietly(
        'details of $movieId',
        () => _localDataSource.cacheMovieDetails(languageCode, model),
      );
      return model.toEntity();
    });

    if (result case Err(failure: NetworkFailure())) {
      final cached = _readQuietly(
        'details of $movieId',
        () => _localDataSource.getCachedMovieDetails(movieId, languageCode),
      );
      if (cached != null) return Success(cached.toEntity());
    }
    return result;
  }

  /// The cache is a bonus: if saving fails, the fresh data is still shown.
  Future<void> _saveQuietly(String what, Future<void> Function() save) async {
    try {
      await save();
    } on CacheException catch (error) {
      log('Could not cache $what', error: error);
    }
  }

  /// If the cache cannot be read, behave as if there were no cache, so the
  /// user sees the normal "no internet" error.
  T? _readQuietly<T>(String what, T? Function() read) {
    try {
      return read();
    } on CacheException catch (error) {
      log('Could not read cached $what', error: error);
      return null;
    }
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
