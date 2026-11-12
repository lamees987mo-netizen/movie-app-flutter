import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_cubit.dart';

import '../../movies_test_helpers.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

const tMovie3 = Movie(id: 3, title: 'Wicked', overview: '', voteAverage: 7);

/// Page 2 of 5. It repeats [tMovie2] from page 1, like TMDB sometimes does.
const tPage2 = PaginatedMovies(
  movies: [tMovie2, tMovie3],
  page: 2,
  totalPages: 5,
);

void main() {
  late MockMoviesRepository repository;

  SeeAllCubit buildCubit() =>
      SeeAllCubit(category: MovieCategory.topRated, repository: repository);

  void stubPage(int page, Result<PaginatedMovies> result) {
    when(
      () => repository.getMovies(MovieCategory.topRated, page: page),
    ).thenAnswer((_) async => result);
  }

  /// Page 1 ([tPage]) is on screen.
  const loadedPage1 = SeeAllLoaded(
    movies: [tMovie1, tMovie2],
    page: 1,
    hasReachedMax: false,
  );

  setUp(() => repository = MockMoviesRepository());

  test('starts in the loading state', () {
    expect(buildCubit().state, const SeeAllLoading());
  });

  group('loadFirstPage', () {
    blocTest<SeeAllCubit, SeeAllState>(
      'emits Loading, then Loaded with page 1',
      setUp: () => stubPage(1, const Success(tPage)),
      build: buildCubit,
      act: (cubit) => cubit.loadFirstPage(),
      expect: () => const [SeeAllLoading(), loadedPage1],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'emits Loading, then Error when page 1 fails',
      setUp: () => stubPage(1, const Err(NetworkFailure())),
      build: buildCubit,
      act: (cubit) => cubit.loadFirstPage(),
      expect: () => const [SeeAllLoading(), SeeAllError(NetworkFailure())],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'retrying after an error shows Loading, then Loaded',
      setUp: () => stubPage(1, const Success(tPage)),
      build: buildCubit,
      seed: () => const SeeAllError(NetworkFailure()),
      act: (cubit) => cubit.loadFirstPage(),
      expect: () => const [SeeAllLoading(), loadedPage1],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'marks hasReachedMax when page 1 is the only page',
      setUp: () => stubPage(
        1,
        const Success(
          PaginatedMovies(movies: [tMovie1], page: 1, totalPages: 1),
        ),
      ),
      build: buildCubit,
      act: (cubit) => cubit.loadFirstPage(),
      expect: () => const [
        SeeAllLoading(),
        SeeAllLoaded(movies: [tMovie1], page: 1, hasReachedMax: true),
      ],
    );
  });

  group('loadMore', () {
    blocTest<SeeAllCubit, SeeAllState>(
      'appends page 2 without the movie it repeats from page 1',
      setUp: () => stubPage(2, const Success(tPage2)),
      build: buildCubit,
      seed: () => loadedPage1,
      act: (cubit) => cubit.loadMore(),
      expect: () => const [
        SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        SeeAllLoaded(
          movies: [tMovie1, tMovie2, tMovie3],
          page: 2,
          hasReachedMax: false,
        ),
      ],
      verify: (_) => verify(
        () => repository.getMovies(MovieCategory.topRated, page: 2),
      ).called(1),
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'sets hasReachedMax after the last page',
      setUp: () => stubPage(
        2,
        const Success(
          PaginatedMovies(movies: [tMovie3], page: 2, totalPages: 2),
        ),
      ),
      build: buildCubit,
      seed: () => loadedPage1,
      act: (cubit) => cubit.loadMore(),
      skip: 1,
      expect: () => const [
        SeeAllLoaded(
          movies: [tMovie1, tMovie2, tMovie3],
          page: 2,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'is ignored while a page is already loading (one request)',
      setUp: () => stubPage(2, const Success(tPage2)),
      build: buildCubit,
      seed: () => loadedPage1,
      act: (cubit) => Future.wait([cubit.loadMore(), cubit.loadMore()]),
      expect: () => const [
        SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        SeeAllLoaded(
          movies: [tMovie1, tMovie2, tMovie3],
          page: 2,
          hasReachedMax: false,
        ),
      ],
      verify: (_) => verify(
        () => repository.getMovies(MovieCategory.topRated, page: 2),
      ).called(1),
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'is ignored after the last page',
      build: buildCubit,
      seed: () =>
          const SeeAllLoaded(movies: [tMovie1], page: 3, hasReachedMax: true),
      act: (cubit) => cubit.loadMore(),
      expect: () => const <SeeAllState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'is ignored before the first page has loaded',
      build: buildCubit,
      act: (cubit) => cubit.loadMore(),
      expect: () => const <SeeAllState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'keeps the movies on failure, then a second call retries',
      setUp: () {
        var calls = 0;
        when(
          () => repository.getMovies(MovieCategory.topRated, page: 2),
        ).thenAnswer(
          (_) async => calls++ == 0
              ? const Err<PaginatedMovies>(NetworkFailure())
              : const Success(tPage2),
        );
      },
      build: buildCubit,
      seed: () => loadedPage1,
      act: (cubit) async {
        await cubit.loadMore();
        await cubit.loadMore();
      },
      expect: () => const [
        SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          loadMoreFailure: NetworkFailure(),
        ),
        // The retry clears the failure while it runs.
        SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        SeeAllLoaded(
          movies: [tMovie1, tMovie2, tMovie3],
          page: 2,
          hasReachedMax: false,
        ),
      ],
    );

    test('drops a page that arrives after a refresh started over', () async {
      final page2 = Completer<Result<PaginatedMovies>>();
      when(
        () => repository.getMovies(MovieCategory.topRated, page: 2),
      ).thenAnswer((_) => page2.future);
      stubPage(1, const Success(tPage));
      final cubit = buildCubit()..emit(loadedPage1);

      final more = cubit.loadMore();
      await cubit.refresh();
      page2.complete(const Success(tPage2));
      await more;

      expect(cubit.state, loadedPage1);
      await cubit.close();
    });
  });

  group('refresh', () {
    blocTest<SeeAllCubit, SeeAllState>(
      'replaces the grid with page 1 without showing Loading',
      setUp: () => stubPage(1, const Success(tPage)),
      build: buildCubit,
      seed: () => const SeeAllLoaded(
        movies: [tMovie1, tMovie2, tMovie3],
        page: 2,
        hasReachedMax: false,
      ),
      act: (cubit) => cubit.refresh(),
      expect: () => const [loadedPage1],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'keeps the grid when the refresh fails',
      setUp: () => stubPage(1, const Err(ServerFailure(500))),
      build: buildCubit,
      seed: () => loadedPage1,
      act: (cubit) => cubit.refresh(),
      expect: () => const <SeeAllState>[],
    );

    blocTest<SeeAllCubit, SeeAllState>(
      'behaves like loadFirstPage when nothing is loaded',
      setUp: () => stubPage(1, const Success(tPage)),
      build: buildCubit,
      seed: () => const SeeAllError(NetworkFailure()),
      act: (cubit) => cubit.refresh(),
      expect: () => const [SeeAllLoading(), loadedPage1],
    );
  });
}
