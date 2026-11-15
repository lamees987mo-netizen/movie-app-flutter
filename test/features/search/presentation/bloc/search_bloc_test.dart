import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';

import '../../../movies/movies_test_helpers.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late MockMoviesRepository repository;

  /// Short debounce so the tests stay fast; [wait] is safely longer.
  const debounce = Duration(milliseconds: 20);
  const wait = Duration(milliseconds: 100);

  const emptyPage = PaginatedMovies(movies: [], page: 1, totalPages: 0);

  /// What page 1 of [tPage] (page 1 of 5) looks like for "dune".
  final dunePage1 = SearchLoaded(
    movies: tPage.movies,
    query: 'dune',
    hasReachedMax: false,
  );

  SearchBloc buildBloc() =>
      SearchBloc(repository: repository, debounceDuration: debounce);

  void stubSearch(String query, Result<PaginatedMovies> result) {
    when(
      () => repository.searchMovies(query),
    ).thenAnswer((_) async => result);
  }

  setUp(() => repository = MockMoviesRepository());

  test('starts in the initial state', () {
    expect(buildBloc().state, const SearchInitial());
  });

  group('SearchQueryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'emits Loading, then Loaded with the results',
      setUp: () => stubSearch('dune', const Success(tPage)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('dune')),
      wait: wait,
      expect: () => [
        const SearchLoading(),
        dunePage1,
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'trims the query before searching',
      setUp: () => stubSearch('dune', const Success(tPage)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('  dune  ')),
      wait: wait,
      expect: () => [
        const SearchLoading(),
        dunePage1,
      ],
      verify: (_) => verify(() => repository.searchMovies('dune')).called(1),
    );

    blocTest<SearchBloc, SearchState>(
      'sends one request with the last query when typing fast',
      setUp: () => stubSearch('dune', const Success(tPage)),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const SearchQueryChanged('d'))
        ..add(const SearchQueryChanged('du'))
        ..add(const SearchQueryChanged('dun'))
        ..add(const SearchQueryChanged('dune')),
      wait: wait,
      expect: () => [
        const SearchLoading(),
        dunePage1,
      ],
      verify: (_) {
        verify(() => repository.searchMovies('dune')).called(1);
        verifyNoMoreInteractions(repository);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'drops the result of a request that a newer query replaced',
      setUp: () {
        // The first request never answers on its own: it is still in
        // flight when the user types the second query.
        final slow = Completer<Result<PaginatedMovies>>();
        when(
          () => repository.searchMovies('inside'),
        ).thenAnswer((_) => slow.future);
        stubSearch('dune', const Success(tPage));
        addTearDown(() => slow.complete(const Success(emptyPage)));
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const SearchQueryChanged('inside'));
        await Future<void>.delayed(wait);
        bloc.add(const SearchQueryChanged('dune'));
      },
      wait: wait,
      expect: () => [
        const SearchLoading(),
        dunePage1,
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Initial without a request for an empty or blank query',
      build: buildBloc,
      seed: () => SearchLoaded(movies: tPage.movies, query: 'dune'),
      act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
      wait: wait,
      expect: () => const [SearchInitial()],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'clearing the field cancels a pending search',
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const SearchQueryChanged('dune'))
        ..add(const SearchQueryChanged('')),
      wait: wait,
      // A Bloc always emits its first state, even when it equals the
      // current one; what matters is that no request was sent.
      expect: () => const [SearchInitial()],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'emits Empty when nothing matches',
      setUp: () => stubSearch('zzzz', const Success(emptyPage)),
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('zzzz')),
      wait: wait,
      expect: () => const [SearchLoading(), SearchEmpty('zzzz')],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Error when the repository fails',
      setUp: () => stubSearch('dune', const Err(NetworkFailure())),
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('dune')),
      wait: wait,
      expect: () => const [
        SearchLoading(),
        SearchError(failure: NetworkFailure(), query: 'dune'),
      ],
    );
  });

  group('SearchRetried', () {
    blocTest<SearchBloc, SearchState>(
      'searches the last query again',
      setUp: () {
        var calls = 0;
        when(() => repository.searchMovies('dune')).thenAnswer(
          (_) async =>
              calls++ == 0 ? const Err(NetworkFailure()) : const Success(tPage),
        );
      },
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const SearchQueryChanged('dune'));
        await Future<void>.delayed(wait);
        bloc.add(const SearchRetried());
      },
      wait: wait,
      expect: () => [
        const SearchLoading(),
        const SearchError(failure: NetworkFailure(), query: 'dune'),
        const SearchLoading(),
        dunePage1,
      ],
      verify: (_) => verify(() => repository.searchMovies('dune')).called(2),
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when there is no query',
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchRetried()),
      wait: wait,
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );
  });

  group('same query', () {
    blocTest<SearchBloc, SearchState>(
      'does not search again when only spaces were added',
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc.add(const SearchQueryChanged('dune  ')),
      wait: wait,
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'does not search again after typing and deleting a letter',
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc
        ..add(const SearchQueryChanged('dunes'))
        ..add(const SearchQueryChanged('dune')),
      wait: wait,
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'searches again when the last search failed',
      setUp: () => stubSearch('dune', const Success(tPage)),
      build: buildBloc,
      seed: () => const SearchError(failure: NetworkFailure(), query: 'dune'),
      act: (bloc) => bloc.add(const SearchQueryChanged('dune')),
      wait: wait,
      expect: () => [const SearchLoading(), dunePage1],
    );
  });

  group('SearchLanguageChanged', () {
    blocTest<SearchBloc, SearchState>(
      'searches the current query again',
      setUp: () => stubSearch('dune', const Success(tPage)),
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const SearchQueryChanged('dune'));
        await Future<void>.delayed(wait);
        bloc.add(const SearchLanguageChanged());
      },
      wait: wait,
      expect: () => [
        const SearchLoading(),
        dunePage1,
        const SearchLoading(),
        dunePage1,
      ],
      verify: (_) => verify(() => repository.searchMovies('dune')).called(2),
    );

    blocTest<SearchBloc, SearchState>(
      'does nothing when there is no query',
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchLanguageChanged()),
      wait: wait,
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );
  });

  group('SearchNextPageRequested', () {
    const tMovie3 = Movie(id: 3, title: 'Wicked', overview: '', voteAverage: 7);
    // Page 2 repeats movie 2 (lists shift between requests) and is the
    // last page.
    const page2 = PaginatedMovies(
      movies: [tMovie2, tMovie3],
      page: 2,
      totalPages: 2,
    );
    final loadingMore = SearchLoaded(
      movies: tPage.movies,
      query: 'dune',
      hasReachedMax: false,
      isLoadingMore: true,
    );
    const withPage2 = SearchLoaded(
      movies: [tMovie1, tMovie2, tMovie3],
      query: 'dune',
      page: 2,
    );

    void stubPage2(Result<PaginatedMovies> result) => when(
      () => repository.searchMovies('dune', page: 2),
    ).thenAnswer((_) async => result);

    blocTest<SearchBloc, SearchState>(
      'appends the next page without duplicates',
      setUp: () => stubPage2(const Success(page2)),
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc.add(const SearchNextPageRequested()),
      expect: () => [loadingMore, withPage2],
    );

    blocTest<SearchBloc, SearchState>(
      'sends one request when asked twice quickly',
      setUp: () => stubPage2(const Success(page2)),
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc
        ..add(const SearchNextPageRequested())
        ..add(const SearchNextPageRequested()),
      verify: (_) =>
          verify(() => repository.searchMovies('dune', page: 2)).called(1),
    );

    blocTest<SearchBloc, SearchState>(
      'is ignored after the last page',
      build: buildBloc,
      seed: () => const SearchLoaded(movies: [tMovie1], query: 'dune'),
      act: (bloc) => bloc.add(const SearchNextPageRequested()),
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'is ignored when no results are shown',
      build: buildBloc,
      act: (bloc) => bloc.add(const SearchNextPageRequested()),
      expect: () => const <SearchState>[],
      verify: (_) => verifyZeroInteractions(repository),
    );

    blocTest<SearchBloc, SearchState>(
      'keeps the results on failure, and retrying works',
      setUp: () {
        var calls = 0;
        when(() => repository.searchMovies('dune', page: 2)).thenAnswer(
          (_) async =>
              calls++ == 0 ? const Err(NetworkFailure()) : const Success(page2),
        );
      },
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) async {
        bloc.add(const SearchNextPageRequested());
        await Future<void>.delayed(wait);
        bloc.add(const SearchNextPageRequested());
      },
      wait: wait,
      expect: () => [
        loadingMore,
        SearchLoaded(
          movies: tPage.movies,
          query: 'dune',
          hasReachedMax: false,
          loadMoreFailure: const NetworkFailure(),
        ),
        loadingMore,
        withPage2,
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'drops a page that arrives after a new search started',
      setUp: () {
        final slow = Completer<Result<PaginatedMovies>>();
        when(
          () => repository.searchMovies('dune', page: 2),
        ).thenAnswer((_) => slow.future);
        stubSearch('inside', const Success(tPage));
        // Answers only after the new search has finished.
        Future<void>.delayed(
          const Duration(milliseconds: 60),
          () => slow.complete(const Success(page2)),
        );
      },
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc
        ..add(const SearchNextPageRequested())
        ..add(const SearchQueryChanged('inside')),
      wait: wait,
      expect: () => [
        loadingMore,
        const SearchLoading(),
        SearchLoaded(
          movies: tPage.movies,
          query: 'inside',
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'drops a page that arrives after the field was cleared',
      setUp: () {
        final slow = Completer<Result<PaginatedMovies>>();
        when(
          () => repository.searchMovies('dune', page: 2),
        ).thenAnswer((_) => slow.future);
        Future<void>.delayed(
          const Duration(milliseconds: 20),
          () => slow.complete(const Success(page2)),
        );
      },
      build: buildBloc,
      seed: () => dunePage1,
      act: (bloc) => bloc
        ..add(const SearchNextPageRequested())
        ..add(const SearchQueryChanged('')),
      wait: wait,
      expect: () => [loadingMore, const SearchInitial()],
    );
  });
}
