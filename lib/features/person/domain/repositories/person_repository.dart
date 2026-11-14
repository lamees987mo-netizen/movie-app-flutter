import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';

/// Loads people (actors) from TMDB. Never throws: returns a [Result].
// ignore: one_member_abstracts, an interface keeps the layers apart.
abstract interface class PersonRepository {
  Future<Result<Person>> getPerson(int personId);
}
