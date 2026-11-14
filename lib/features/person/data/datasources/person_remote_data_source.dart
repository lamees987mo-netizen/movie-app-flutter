import 'package:dio/dio.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/network/api_endpoints.dart';
import 'package:movie_app/features/person/data/models/person_model.dart';

/// Talks to the TMDB API. Throws an [AppException] on any error.
// An interface (not a function) so tests can mock it and it matches the
// other data sources.
// ignore: one_member_abstracts
abstract interface class PersonRemoteDataSource {
  Future<PersonModel> getPerson(int personId);
}

class PersonRemoteDataSourceImpl implements PersonRemoteDataSource {
  PersonRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  /// Same error handling as `MoviesRemoteDataSourceImpl._get`.
  @override
  Future<PersonModel> getPerson(int personId) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.personDetails(personId),
        queryParameters: {
          'append_to_response': ApiEndpoints.personAppendToResponse,
        },
      );
    } on DioException catch (e) {
      // ErrorInterceptor has already put an AppException inside.
      final error = e.error;
      if (error is AppException) throw error;
      throw ServerException(statusCode: e.response?.statusCode);
    }

    // A broken body is the server's fault: only AppExceptions leave here.
    try {
      return PersonModel.fromJson(response.data ?? const {});
    } on Object catch (error) {
      throw ServerException(
        statusCode: response.statusCode,
        message: 'Unexpected response: $error',
      );
    }
  }
}
