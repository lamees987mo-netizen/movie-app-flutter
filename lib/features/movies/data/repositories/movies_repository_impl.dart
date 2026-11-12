import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  MoviesRepositoryImpl(this._remoteDataSource);

  final MoviesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<PaginatedMovies>> getMovies(
    MovieCategory category, {
    int page = 1,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.getMovies(category, page: page);
      return model.toEntity();
    });
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
