import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/features/person/domain/repositories/person_repository.dart';
import 'package:movie_app/features/person/presentation/cubit/person_cubit.dart';

import '../../person_test_helpers.dart';

class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  late MockPersonRepository repository;

  PersonCubit buildCubit() =>
      PersonCubit(personId: 56322, repository: repository);

  setUp(() => repository = MockPersonRepository());

  test('starts in the loading state', () {
    expect(buildCubit().state, const PersonLoading());
  });

  blocTest<PersonCubit, PersonState>(
    'emits Loading, then Loaded with its person',
    setUp: () => when(
      () => repository.getPerson(56322),
    ).thenAnswer((_) async => Success(tPerson)),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const PersonLoading(), PersonLoaded(tPerson)],
    verify: (_) => verify(() => repository.getPerson(56322)).called(1),
  );

  blocTest<PersonCubit, PersonState>(
    'emits Loading, then Error when loading fails',
    setUp: () => when(
      () => repository.getPerson(56322),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => const [PersonLoading(), PersonError(NetworkFailure())],
  );

  test('does not emit after being closed', () async {
    when(
      () => repository.getPerson(56322),
    ).thenAnswer((_) async => Success(tPerson));
    final cubit = buildCubit();

    final loading = cubit.load();
    await cubit.close();

    // Emitting after close() would throw a StateError here.
    await expectLater(loading, completes);
  });
}
