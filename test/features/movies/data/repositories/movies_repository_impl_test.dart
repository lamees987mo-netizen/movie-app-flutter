import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockMoviesRemoteDataSource extends Mock
    implements MoviesRemoteDataSource {}

void main() {
  late MockMoviesRemoteDataSource dataSource;
  late MoviesRepositoryImpl repository;

  final pageModel = MoviesPageModel.fromJson(jsonFixture('movies_page.json'));
  final detailsModel = MovieDetailsModel.fromJson(
    jsonFixture('movie_details.json'),
  );

  setUpAll(() => registerFallbackValue(MovieCategory.trending));

  setUp(() {
    dataSource = MockMoviesRemoteDataSource();
    repository = MoviesRepositoryImpl(dataSource);
  });

  group('getMovies', () {
    test(
      'returns Success with entities when the data source succeeds',
      () async {
        when(
          () => dataSource.getMovies(MovieCategory.trending, page: 2),
        ).thenAnswer((_) async => pageModel);

        final result = await repository.getMovies(
          MovieCategory.trending,
          page: 2,
        );

        expect(result, Success(pageModel.toEntity()));
        verify(() => dataSource.getMovies(MovieCategory.trending, page: 2));
      },
    );

    test('returns ServerFailure on ServerException', () async {
      when(
        () => dataSource.getMovies(any(), page: any(named: 'page')),
      ).thenThrow(const ServerException(statusCode: 500));

      final result = await repository.getMovies(MovieCategory.topRated);

      expect((result as Err).failure, const ServerFailure(500));
    });

    test('returns NetworkFailure on NetworkException', () async {
      when(
        () => dataSource.getMovies(any(), page: any(named: 'page')),
      ).thenThrow(const NetworkException());

      final result = await repository.getMovies(MovieCategory.upcoming);

      expect((result as Err).failure, const NetworkFailure());
    });

    test('returns UnknownFailure on an unexpected error', () async {
      when(
        () => dataSource.getMovies(any(), page: any(named: 'page')),
      ).thenThrow(const FormatException('bad json'));

      final result = await repository.getMovies(MovieCategory.nowPlaying);

      expect((result as Err).failure, const UnknownFailure());
    });
  });

  group('getMovieDetails', () {
    test(
      'returns Success with details when the data source succeeds',
      () async {
        when(
          () => dataSource.getMovieDetails(1022789),
        ).thenAnswer((_) async => detailsModel);

        final result = await repository.getMovieDetails(1022789);

        expect(result, Success(detailsModel.toEntity()));
      },
    );

    test('returns NotFoundFailure when the server answers 404', () async {
      when(
        () => dataSource.getMovieDetails(any()),
      ).thenThrow(const ServerException(statusCode: 404));

      final result = await repository.getMovieDetails(0);

      expect((result as Err).failure, const NotFoundFailure());
    });
  });

  group('searchMovies', () {
    test('passes the query and page to the data source', () async {
      when(
        () => dataSource.searchMovies('inside', page: 3),
      ).thenAnswer((_) async => pageModel);

      final result = await repository.searchMovies('inside', page: 3);

      expect(result.isSuccess, isTrue);
      verify(() => dataSource.searchMovies('inside', page: 3)).called(1);
    });

    test('returns NetworkFailure on NetworkException', () async {
      when(
        () => dataSource.searchMovies(any(), page: any(named: 'page')),
      ).thenThrow(const NetworkException());

      final result = await repository.searchMovies('inside');

      expect((result as Err).failure, const NetworkFailure());
    });
  });
}
