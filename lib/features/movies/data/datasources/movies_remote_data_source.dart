import 'package:dio/dio.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/network/api_endpoints.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

/// Talks to the TMDB API. Throws an [AppException] on any error.
abstract interface class MoviesRemoteDataSource {
  Future<MoviesPageModel> getMovies(MovieCategory category, {int page = 1});

  Future<MovieDetailsModel> getMovieDetails(int movieId);

  Future<MoviesPageModel> searchMovies(String query, {int page = 1});
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  MoviesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<MoviesPageModel> getMovies(MovieCategory category, {int page = 1}) {
    return _get(
      category.endpoint,
      MoviesPageModel.fromJson,
      queryParameters: {'page': page},
    );
  }

  @override
  Future<MovieDetailsModel> getMovieDetails(int movieId) {
    return _get(
      ApiEndpoints.movieDetails(movieId),
      MovieDetailsModel.fromJson,
      queryParameters: {
        'append_to_response': ApiEndpoints.detailsAppendToResponse,
      },
    );
  }

  @override
  Future<MoviesPageModel> searchMovies(String query, {int page = 1}) {
    return _get(
      ApiEndpoints.searchMovies,
      MoviesPageModel.fromJson,
      queryParameters: {'query': query, 'page': page},
    );
  }

  /// Sends a GET request and parses the JSON body with [fromJson].
  ///
  /// `ErrorInterceptor` has already put an [AppException] inside the
  /// [DioException]; here we simply rethrow it.
  Future<T> _get<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data ?? const {});
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppException) throw error;
      throw ServerException(statusCode: e.response?.statusCode);
    }
  }
}

/// Maps each category to its TMDB endpoint.
extension MovieCategoryEndpoint on MovieCategory {
  String get endpoint => switch (this) {
    MovieCategory.trending => ApiEndpoints.trending,
    MovieCategory.topRated => ApiEndpoints.topRated,
    MovieCategory.upcoming => ApiEndpoints.upcoming,
    MovieCategory.nowPlaying => ApiEndpoints.nowPlaying,
  };
}
