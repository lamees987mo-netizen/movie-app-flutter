import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/models/movies_page_model.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('MoviesPageModel', () {
    test('parses a TMDB list page into entities', () {
      final page = MoviesPageModel.fromJson(
        jsonFixture('movies_page.json'),
      ).toEntity();

      expect(page.page, 1);
      expect(page.totalPages, 500);
      expect(page.hasReachedMax, isFalse);
      expect(page.movies, hasLength(2));
      expect(
        page.movies.first,
        Movie(
          id: 1022789,
          title: 'Inside Out 2',
          overview: page.movies.first.overview,
          posterPath: '/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
          backdropPath: '/tElnmtQ6yz1PjN1kePNl8yMSb59.jpg',
          voteAverage: 7.7,
          releaseDate: DateTime(2024, 6, 11),
          genreIds: const [16, 10751, 12, 35, 18],
        ),
      );
    });

    test('handles missing images, empty date and integer rating', () {
      final movie = MoviesPageModel.fromJson(
        jsonFixture('movies_page.json'),
      ).toEntity().movies.last;

      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.releaseDate, isNull);
      expect(movie.voteAverage, 0.0);
      expect(movie.genreIds, isEmpty);
    });
  });

  group('MovieModel', () {
    test('toJson/fromJson round trip keeps the same entity', () {
      final original = MoviesPageModel.fromJson(
        jsonFixture('movies_page.json'),
      ).results.first;

      final copy = MovieModel.fromJson(original.toJson());

      expect(copy.toEntity(), original.toEntity());
    });

    test('fromEntity converts back to the same entity', () {
      final movie = MoviesPageModel.fromJson(
        jsonFixture('movies_page.json'),
      ).toEntity().movies.first;

      expect(MovieModel.fromEntity(movie).toEntity(), movie);
    });
  });

  group('MovieDetailsModel', () {
    late MovieDetails details;

    setUp(() {
      details = MovieDetailsModel.fromJson(
        jsonFixture('movie_details.json'),
      ).toEntity();
    });

    test('parses the basic movie fields', () {
      expect(details.movie.id, 1022789);
      expect(details.movie.title, 'Inside Out 2');
      expect(details.movie.genreIds, [16, 10751]);
      expect(details.runtime, 97);
      expect(details.genres, ['Animation', 'Family']);
    });

    test('parses the cast from credits', () {
      expect(details.cast, const [
        CastMember(
          name: 'Amy Poehler',
          character: 'Joy (voice)',
          profilePath: '/rwmvRmXlUxTMjxDDBFNKrcFsNN2.jpg',
        ),
        CastMember(name: 'Maya Hawke', character: 'Anxiety (voice)'),
      ]);
    });

    test('picks the official YouTube trailer', () {
      expect(details.trailerYoutubeKey, 'LEjhY15eCx0');
    });

    test('falls back to any YouTube trailer when none is official', () {
      final json = jsonFixture('movie_details.json');
      // Remove the official trailer.
      ((json['videos'] as Map<String, dynamic>)['results'] as List)
          .removeLast();

      final model = MovieDetailsModel.fromJson(json);

      expect(model.trailerYoutubeKey, 'fanTrailer456');
    });

    test('has no trailer and empty cast when sections are missing', () {
      final json = jsonFixture('movie_details.json')
        ..remove('videos')
        ..remove('credits');

      final result = MovieDetailsModel.fromJson(json).toEntity();

      expect(result.trailerYoutubeKey, isNull);
      expect(result.cast, isEmpty);
    });
  });
}
