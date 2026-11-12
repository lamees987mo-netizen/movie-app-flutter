import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The state of the Search screen.
///
/// `sealed` means these are the only possible states, so a
/// `switch (state)` in the UI must handle all of them.
sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// The query is empty: invite the user to type.
final class SearchInitial extends SearchState {
  const SearchInitial();
}

/// A request is in flight: show a skeleton.
final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({required this.movies, required this.query});

  final List<Movie> movies;
  final String query;

  @override
  List<Object?> get props => [movies, query];
}

/// The search worked but found nothing for [query].
final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchError extends SearchState {
  const SearchError({required this.failure, required this.query});

  final Failure failure;
  final String query;

  @override
  List<Object?> get props => [failure, query];
}
