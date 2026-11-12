import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
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
        SearchLoaded(movies: tPage.movies, query: 'dune'),
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
        SearchLoaded(movies: tPage.movies, query: 'dune'),
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
        SearchLoaded(movies: tPage.movies, query: 'dune'),
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
        SearchLoaded(movies: tPage.movies, query: 'dune'),
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
        SearchLoaded(movies: tPage.movies, query: 'dune'),
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
}
