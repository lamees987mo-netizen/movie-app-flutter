import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';

/// The state of the person (actor) screen.
sealed class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

final class PersonLoading extends PersonState {
  const PersonLoading();
}

final class PersonLoaded extends PersonState {
  const PersonLoaded(this.person);

  final Person person;

  @override
  List<Object?> get props => [person];
}

final class PersonError extends PersonState {
  const PersonError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
