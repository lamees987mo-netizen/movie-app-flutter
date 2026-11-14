import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/person/data/datasources/person_remote_data_source.dart';

import '../../../../fixtures/fixture_reader.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late PersonRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = PersonRemoteDataSourceImpl(dio);
  });

  /// Makes every GET answer with [data].
  void answerWith(Map<String, dynamic>? data) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: 'person/56322'),
        statusCode: 200,
        data: data,
      ),
    );
  }

  /// Makes every GET fail with [error].
  void failWith(DioException error) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenThrow(error);
  }

  DioException dioError({Object? cause, int? statusCode}) {
    final options = RequestOptions(path: 'person/56322');
    return DioException(
      requestOptions: options,
      error: cause,
      response: statusCode == null
          ? null
          : Response<dynamic>(requestOptions: options, statusCode: statusCode),
    );
  }

  test('calls person/{id} and appends the movie credits', () async {
    answerWith(jsonFixture('person.json'));

    final person = await dataSource.getPerson(56322);

    verify(
      () => dio.get<Map<String, dynamic>>(
        'person/56322',
        queryParameters: {'append_to_response': 'movie_credits'},
      ),
    ).called(1);
    expect(person.name, 'Amy Poehler');
    expect(person.credits, hasLength(5));
  });

  test('rethrows the AppException put there by ErrorInterceptor', () {
    failWith(dioError(cause: const NetworkException()));

    expect(() => dataSource.getPerson(1), throwsA(isA<NetworkException>()));
  });

  test('turns other Dio errors into a ServerException', () {
    failWith(dioError(statusCode: 404));

    expect(
      () => dataSource.getPerson(1),
      throwsA(
        isA<ServerException>().having((e) => e.statusCode, 'status', 404),
      ),
    );
  });

  test('turns an unexpected body into a ServerException', () {
    answerWith({'id': 'not a number'});

    expect(() => dataSource.getPerson(1), throwsA(isA<ServerException>()));
  });

  test('turns an empty body into a ServerException', () {
    answerWith(null);

    expect(() => dataSource.getPerson(1), throwsA(isA<ServerException>()));
  });
}
