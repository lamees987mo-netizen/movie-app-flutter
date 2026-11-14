import 'dart:developer';

import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/person/data/datasources/person_remote_data_source.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';
import 'package:movie_app/features/person/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  PersonRepositoryImpl(this._remoteDataSource);

  final PersonRemoteDataSource _remoteDataSource;

  /// Converts exceptions into failures, like `MoviesRepositoryImpl`.
  @override
  Future<Result<Person>> getPerson(int personId) async {
    try {
      final model = await _remoteDataSource.getPerson(personId);
      return Success(model.toEntity());
    } on NetworkException {
      return const Err(NetworkFailure());
    } on ServerException catch (e) {
      if (e.statusCode == 404) return const Err(NotFoundFailure());
      return Err(ServerFailure(e.statusCode));
    } on Object catch (error, stackTrace) {
      log('Unexpected error', error: error, stackTrace: stackTrace);
      return const Err(UnknownFailure());
    }
  }
}
