import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';

import '../../movies_test_helpers.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

void main() {
  late MockMoviesRepository repository;
  late GetMovieDetails getMovieDetails;

  setUp(() {
    repository = MockMoviesRepository();
    getMovieDetails = GetMovieDetails(repository);
  });

  test('returns the repository result for the given id', () async {
    when(
      () => repository.getMovieDetails(1),
    ).thenAnswer((_) async => const Success(tDetails));

    final result = await getMovieDetails(1);

    expect(result, const Success<MovieDetails>(tDetails));
    verify(() => repository.getMovieDetails(1)).called(1);
  });

  test('passes failures through unchanged', () async {
    when(
      () => repository.getMovieDetails(1),
    ).thenAnswer((_) async => const Err(NotFoundFailure()));

    final result = await getMovieDetails(1);

    expect(result, const Err<MovieDetails>(NotFoundFailure()));
  });
}
