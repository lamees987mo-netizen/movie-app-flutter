import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/person/data/datasources/person_remote_data_source.dart';
import 'package:movie_app/features/person/data/models/person_model.dart';
import 'package:movie_app/features/person/data/repositories/person_repository_impl.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockPersonRemoteDataSource extends Mock
    implements PersonRemoteDataSource {}

void main() {
  late MockPersonRemoteDataSource dataSource;
  late PersonRepositoryImpl repository;

  final model = PersonModel.fromJson(jsonFixture('person.json'));

  setUp(() {
    dataSource = MockPersonRemoteDataSource();
    repository = PersonRepositoryImpl(dataSource);
  });

  test('returns the person on success', () async {
    when(() => dataSource.getPerson(56322)).thenAnswer((_) async => model);

    final result = await repository.getPerson(56322);

    expect(result, Success(model.toEntity()));
  });

  final cases = <String, (Object, Failure)>{
    'NetworkException': (const NetworkException(), const NetworkFailure()),
    'ServerException 404': (
      const ServerException(statusCode: 404),
      const NotFoundFailure(),
    ),
    'ServerException 500': (
      const ServerException(statusCode: 500),
      const ServerFailure(500),
    ),
    'any other error': (StateError('boom'), const UnknownFailure()),
  };

  for (final MapEntry(key: name, value: (error, failure)) in cases.entries) {
    test('maps $name to ${failure.runtimeType}', () async {
      when(() => dataSource.getPerson(any())).thenThrow(error);

      final result = await repository.getPerson(1);

      expect(result, Err<Person>(failure));
    });
  }
}
