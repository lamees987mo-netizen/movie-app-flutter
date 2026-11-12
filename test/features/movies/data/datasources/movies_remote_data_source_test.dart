import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

import '../../../../fixtures/fixture_reader.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late MoviesRemoteDataSourceImpl dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = MoviesRemoteDataSourceImpl(dio);
  });

  /// Makes every GET answer with [data].
  void answerWith(Map<String, dynamic>? data) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (invocation) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(
          path: invocation.positionalArguments.first as String,
        ),
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
    final options = RequestOptions(path: 'movie/1');
    return DioException(
      requestOptions: options,
      error: cause,
      response: statusCode == null
          ? null
          : Response<dynamic>(requestOptions: options, statusCode: statusCode),
    );
  }

  group('getMovies', () {
    const endpoints = {
      MovieCategory.trending: 'trending/movie/week',
      MovieCategory.topRated: 'movie/top_rated',
      MovieCategory.upcoming: 'movie/upcoming',
      MovieCategory.nowPlaying: 'movie/now_playing',
    };

    for (final MapEntry(key: category, value: path) in endpoints.entries) {
      test('${category.name} calls $path with page 1 by default', () async {
        answerWith(jsonFixture('movies_page.json'));

        await dataSource.getMovies(category);

        verify(
          () => dio.get<Map<String, dynamic>>(
            path,
            queryParameters: {'page': 1},
          ),
        ).called(1);
      });
    }

    test('sends the requested page', () async {
      answerWith(jsonFixture('movies_page.json'));

      await dataSource.getMovies(MovieCategory.topRated, page: 3);

      verify(
        () => dio.get<Map<String, dynamic>>(
          'movie/top_rated',
          queryParameters: {'page': 3},
        ),
      ).called(1);
    });

    test('parses the response', () async {
      answerWith(jsonFixture('movies_page.json'));

      final page = await dataSource.getMovies(MovieCategory.trending);

      expect(page.page, 1);
      expect(page.totalPages, 500);
      expect(page.results, hasLength(2));
      expect(page.results.first.id, 1022789);
      expect(page.results.first.title, 'Inside Out 2');
    });
  });

  group('getMovieDetails', () {
    test('calls movie/{id} and appends credits and videos', () async {
      answerWith(jsonFixture('movie_details.json'));

      await dataSource.getMovieDetails(1022789);

      verify(
        () => dio.get<Map<String, dynamic>>(
          'movie/1022789',
          queryParameters: {'append_to_response': 'credits,videos'},
        ),
      ).called(1);
    });

    test('parses the details, cast and videos', () async {
      answerWith(jsonFixture('movie_details.json'));

      final details = await dataSource.getMovieDetails(1022789);

      expect(details.id, 1022789);
      expect(details.title, 'Inside Out 2');
      expect(details.genres, isNotEmpty);
      expect(details.cast, isNotEmpty);
      expect(details.videos, isNotEmpty);
    });
  });

  group('searchMovies', () {
    test('calls search/movie with the query and page 1', () async {
      answerWith(jsonFixture('movies_page.json'));

      final page = await dataSource.searchMovies('inside');

      verify(
        () => dio.get<Map<String, dynamic>>(
          'search/movie',
          queryParameters: {'query': 'inside', 'page': 1},
        ),
      ).called(1);
      expect(page.results, hasLength(2));
    });

    test('sends the requested page', () async {
      answerWith(jsonFixture('movies_page.json'));

      await dataSource.searchMovies('dune', page: 2);

      verify(
        () => dio.get<Map<String, dynamic>>(
          'search/movie',
          queryParameters: {'query': 'dune', 'page': 2},
        ),
      ).called(1);
    });
  });

  group('errors', () {
    test('rethrows the AppException set by ErrorInterceptor', () async {
      failWith(dioError(cause: const NetworkException()));

      await expectLater(
        dataSource.getMovies(MovieCategory.trending),
        throwsA(isA<NetworkException>()),
      );
    });

    test('rethrows a ServerException with its status code', () async {
      failWith(dioError(cause: const ServerException(statusCode: 404)));

      await expectLater(
        dataSource.getMovieDetails(1),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'code', 404),
        ),
      );
    });

    test('wraps any other DioException in a ServerException', () async {
      failWith(dioError(cause: Exception('raw'), statusCode: 503));

      await expectLater(
        dataSource.searchMovies('dune'),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'code', 503),
        ),
      );
    });

    test('a null body becomes a ServerException, not a TypeError', () async {
      answerWith(null);

      await expectLater(
        dataSource.getMovies(MovieCategory.trending),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
