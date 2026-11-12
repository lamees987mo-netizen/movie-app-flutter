import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';

import '../../movies_test_helpers.dart';

class MockGetMovieDetails extends Mock implements GetMovieDetails {}

void main() {
  late MockGetMovieDetails getMovieDetails;

  MovieDetailsCubit buildCubit() =>
      MovieDetailsCubit(movieId: 1, getMovieDetails: getMovieDetails);

  setUp(() => getMovieDetails = MockGetMovieDetails());

  test('starts in the loading state', () {
    expect(buildCubit().state, const MovieDetailsLoading());
  });

  blocTest<MovieDetailsCubit, MovieDetailsState>(
    'emits Loading, then Loaded with the details of its movie',
    setUp: () => when(
      () => getMovieDetails(1),
    ).thenAnswer((_) async => const Success(tDetails)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => const [MovieDetailsLoading(), MovieDetailsLoaded(tDetails)],
    verify: (_) => verify(() => getMovieDetails(1)).called(1),
  );

  blocTest<MovieDetailsCubit, MovieDetailsState>(
    'emits Loading, then Error when loading fails',
    setUp: () => when(
      () => getMovieDetails(1),
    ).thenAnswer((_) async => const Err(NotFoundFailure())),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => const [
      MovieDetailsLoading(),
      MovieDetailsError(NotFoundFailure()),
    ],
  );

  blocTest<MovieDetailsCubit, MovieDetailsState>(
    'retrying after an error shows Loading, then Loaded',
    setUp: () => when(
      () => getMovieDetails(1),
    ).thenAnswer((_) async => const Success(tDetails)),
    build: buildCubit,
    seed: () => const MovieDetailsError(NetworkFailure()),
    act: (cubit) => cubit.load(),
    expect: () => const [MovieDetailsLoading(), MovieDetailsLoaded(tDetails)],
  );
}
