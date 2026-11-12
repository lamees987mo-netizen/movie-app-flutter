import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/data/datasources/movies_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movies_remote_data_source.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockMoviesRemoteDataSource extends Mock
    implements MoviesRemoteDataSource {}

class MockMoviesLocalDataSource extends Mock implements MoviesLocalDataSource {}

void main() {
  late MockMoviesRemoteDataSource dataSource;
  late MockMoviesLocalDataSource localDataSource;
  late String languageCode;
  late MoviesRepositoryImpl repository;

  final pageModel = MoviesPageModel.fromJson(jsonFixture('movies_page.json'));
  final detailsModel = MovieDetailsModel.fromJson(
    jsonFixture('movie_details.json'),
  );

  setUpAll(() {
    registerFallbackValue(MovieCategory.trending);
    registerFallbackValue(pageModel);
  });

  setUp(() {
    dataSource = MockMoviesRemoteDataSource();
    localDataSource = MockMoviesLocalDataSource();
    languageCode = 'en';
    repository = MoviesRepositoryImpl(
      dataSource,
      localDataSource: localDataSource,
      languageCode: () => languageCode,
    );
    when(
      () => localDataSource.cacheFirstPage(any(), any(), any()),
    ).thenAnswer((_) async {});
    when(() => localDataSource.getCachedFirstPage(any(), any())).thenReturn(
      null,
    );
  });

  group('getMovies offline cache', () {
    void goOffline() => when(
      () => dataSource.getMovies(any(), page: any(named: 'page')),
    ).thenThrow(const NetworkException());

    test('saves page 1 with the current language', () async {
      languageCode = 'ar';
      when(
        () => dataSource.getMovies(MovieCategory.trending),
      ).thenAnswer((_) async => pageModel);

      await repository.getMovies(MovieCategory.trending);

      verify(
        () => localDataSource.cacheFirstPage(
          MovieCategory.trending,
          'ar',
          pageModel,
        ),
      ).called(1);
    });

    test('does not save later pages', () async {
      when(
        () => dataSource.getMovies(any(), page: 2),
      ).thenAnswer((_) async => pageModel);

      await repository.getMovies(MovieCategory.trending, page: 2);

      verifyNever(() => localDataSource.cacheFirstPage(any(), any(), any()));
    });

    test('still succeeds when saving fails', () async {
      when(
        () => dataSource.getMovies(any()),
      ).thenAnswer((_) async => pageModel);
      when(
        () => localDataSource.cacheFirstPage(any(), any(), any()),
      ).thenThrow(const CacheException());

      final result = await repository.getMovies(MovieCategory.trending);

      expect(result, Success(pageModel.toEntity()));
    });

    test('returns the saved page when offline', () async {
      goOffline();
      when(
        () => localDataSource.getCachedFirstPage(MovieCategory.upcoming, 'en'),
      ).thenReturn(pageModel);

      final result = await repository.getMovies(MovieCategory.upcoming);

      expect(result, Success(pageModel.toEntity()));
    });

    test('reads the cache of the current language', () async {
      goOffline();
      languageCode = 'ar';

      await repository.getMovies(MovieCategory.trending);

      verify(
        () => localDataSource.getCachedFirstPage(MovieCategory.trending, 'ar'),
      ).called(1);
    });

    test('returns NetworkFailure when offline with no cache', () async {
      goOffline();

      final result = await repository.getMovies(MovieCategory.trending);

      expect((result as Err).failure, const NetworkFailure());
    });

    test('returns NetworkFailure when the cache cannot be read', () async {
      goOffline();
      when(
        () => localDataSource.getCachedFirstPage(any(), any()),
      ).thenThrow(const CacheException());

      final result = await repository.getMovies(MovieCategory.trending);

      expect((result as Err).failure, const NetworkFailure());
    });

    test('does not use the cache for server errors', () async {
      when(
        () => dataSource.getMovies(any(), page: any(named: 'page')),
      ).thenThrow(const ServerException(statusCode: 500));
      when(
        () => localDataSource.getCachedFirstPage(any(), any()),
      ).thenReturn(pageModel);

      final result = await repository.getMovies(MovieCategory.trending);

      expect((result as Err).failure, const ServerFailure(500));
    });

    test('does not use the cache for later pages', () async {
      goOffline();
      when(
        () => localDataSource.getCachedFirstPage(any(), any()),
      ).thenReturn(pageModel);

      final result = await repository.getMovies(
        MovieCategory.trending,
        page: 2,
      );

      expect((result as Err).failure, const NetworkFailure());
    });
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
