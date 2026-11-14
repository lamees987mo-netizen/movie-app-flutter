import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/person/data/models/person_model.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('PersonModel', () {
    test('parses the person fields', () {
      final person = PersonModel.fromJson(
        jsonFixture('person.json'),
      ).toEntity();

      expect(person.id, 56322);
      expect(person.name, 'Amy Poehler');
      // The trailing newline from TMDB is trimmed.
      expect(
        person.biography,
        'Amy Meredith Poehler is an American actress and comedian.',
      );
      expect(person.profilePath, '/rwmvRmXlUxTMjxDDBFNKrcFsNN2.jpg');
      expect(person.birthday, DateTime(1971, 9, 16));
      expect(person.placeOfBirth, 'Newton, Massachusetts, USA');
    });

    test(
      'known-for: most voted first, popularity breaks ties, no duplicates',
      () {
        final person = PersonModel.fromJson(
          jsonFixture('person.json'),
        ).toEntity();

        // 222 is in the credits twice (two roles) but listed once.
        expect(person.knownFor.map((movie) => movie.id), [
          150540,
          333,
          222,
          111,
        ]);
        expect(person.knownFor.first.title, 'Inside Out');
        expect(person.knownFor.first.releaseDate, DateTime(2015, 6, 17));
      },
    );

    test('keeps at most ${PersonModel.knownForLimit} movies', () {
      final json = jsonFixture('person.json');
      json['movie_credits'] = {
        'cast': [
          for (var id = 1; id <= 30; id++)
            {'id': id, 'title': 'Movie $id', 'vote_count': id},
        ],
      };

      final person = PersonModel.fromJson(json).toEntity();

      expect(person.knownFor, hasLength(PersonModel.knownForLimit));
      expect(person.knownFor.first.id, 30);
    });

    test('handles missing or empty optional fields', () {
      final person = PersonModel.fromJson(const {
        'id': 7,
        'name': 'Unknown',
        'biography': null,
        'birthday': null,
        'place_of_birth': '',
      }).toEntity();

      expect(person.biography, isEmpty);
      expect(person.birthday, isNull);
      expect(person.placeOfBirth, isNull);
      expect(person.profilePath, isNull);
      expect(person.knownFor, isEmpty);
    });
  });
}
