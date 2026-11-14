import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';

/// Shared test data for the person feature. Image paths are `null`, so
/// nothing is downloaded.
const tKnownFor1 = Movie(
  id: 150540,
  title: 'Inside Out',
  overview: '',
  voteAverage: 7.9,
);

const tKnownFor2 = Movie(
  id: 333,
  title: 'Parks Movie',
  overview: '',
  voteAverage: 6.5,
);

final tPerson = Person(
  id: 56322,
  name: 'Amy Poehler',
  biography: 'Amy is an American actress and comedian.',
  birthday: DateTime(1971, 9, 16),
  placeOfBirth: 'Newton, Massachusetts, USA',
  knownFor: const [tKnownFor1, tKnownFor2],
);
