import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/person/domain/repositories/person_repository.dart';
import 'package:movie_app/features/person/presentation/cubit/person_state.dart';

export 'person_state.dart';

/// Loads one person. Like `MovieDetailsCubit`, the id is given once
/// (`sl<PersonCubit>(param1: personId)`), so "Retry" just calls [load].
class PersonCubit extends Cubit<PersonState> {
  PersonCubit({required this.personId, required this._repository})
    : super(const PersonLoading());

  final int personId;
  final PersonRepository _repository;

  Future<void> load() async {
    emit(const PersonLoading());
    final result = await _repository.getPerson(personId);

    // The user may have left the screen while we were waiting.
    if (isClosed) return;

    emit(
      result.fold(onSuccess: PersonLoaded.new, onFailure: PersonError.new),
    );
  }
}
