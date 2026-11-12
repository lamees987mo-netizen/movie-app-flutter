import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';

import '../../movies_test_helpers.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late MockMoviesRepository repository;

  MovieSectionCubit buildCubit() => MovieSectionCubit(
    category: MovieCategory.trending,
    repository: repository,
  );

  void stubGetMovies(Result<PaginatedMovies> result) {
    when(
      () => repository.getMovies(MovieCategory.trending),
    ).thenAnswer((_) async => result);
  }

  setUp(() => repository = MockMoviesRepository());

  test('starts in the loading state', () {
    expect(buildCubit().state, const MovieSectionLoading());
  });

  test('ignores an older answer that arrives after a newer one', () async {
    // E.g. Arabic → English quickly: the slow Arabic answer must not win.
    const older = PaginatedMovies(movies: [tMovie1], page: 1, totalPages: 1);
    const newer = PaginatedMovies(movies: [tMovie2], page: 1, totalPages: 1);
    final first = Completer<Result<PaginatedMovies>>();
    final answers = [first.future, Future.value(const Success(newer))];
    when(
      () => repository.getMovies(MovieCategory.trending),
    ).thenAnswer((_) => answers.removeAt(0));
    final cubit = buildCubit()..emit(const MovieSectionLoaded([tMovie1]));

    final slow = cubit.refresh();
    await cubit.refresh();
    first.complete(const Success(older));
    await slow;

    expect(cubit.state, const MovieSectionLoaded([tMovie2]));
    await cubit.close();
  });

  group('load', () {
    blocTest<MovieSectionCubit, MovieSectionState>(
      'emits Loading, then Loaded with the movies of its category',
      setUp: () => stubGetMovies(const Success(tPage)),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const MovieSectionLoading(),
        MovieSectionLoaded(tPage.movies),
      ],
      verify: (_) => verify(
        () => repository.getMovies(MovieCategory.trending),
      ).called(1),
    );

    blocTest<MovieSectionCubit, MovieSectionState>(
      'emits Loading, then Error when the repository fails',
      setUp: () => stubGetMovies(const Err(NetworkFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => const [
        MovieSectionLoading(),
        MovieSectionError(NetworkFailure()),
      ],
    );

    blocTest<MovieSectionCubit, MovieSectionState>(
      'retrying after an error shows Loading, then Loaded',
      setUp: () => stubGetMovies(const Success(tPage)),
      build: buildCubit,
      seed: () => const MovieSectionError(NetworkFailure()),
      act: (cubit) => cubit.load(),
      expect: () => [
        const MovieSectionLoading(),
        MovieSectionLoaded(tPage.movies),
      ],
    );
  });

  group('refresh', () {
    blocTest<MovieSectionCubit, MovieSectionState>(
      'keeps the current movies on screen (no Loading) and then updates',
      setUp: () => stubGetMovies(const Success(tPage)),
      build: buildCubit,
      seed: () => const MovieSectionLoaded([tMovie1]),
      act: (cubit) => cubit.refresh(),
      expect: () => [MovieSectionLoaded(tPage.movies)],
    );

    blocTest<MovieSectionCubit, MovieSectionState>(
      'keeps the current movies when the refresh fails',
      setUp: () => stubGetMovies(const Err(ServerFailure(500))),
      build: buildCubit,
      seed: () => const MovieSectionLoaded([tMovie1]),
      act: (cubit) => cubit.refresh(),
      expect: () => const <MovieSectionState>[],
    );

    blocTest<MovieSectionCubit, MovieSectionState>(
      'behaves like load when there is no data yet',
      setUp: () => stubGetMovies(const Success(tPage)),
      build: buildCubit,
      seed: () => const MovieSectionError(NetworkFailure()),
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const MovieSectionLoading(),
        MovieSectionLoaded(tPage.movies),
      ],
    );
  });
}
