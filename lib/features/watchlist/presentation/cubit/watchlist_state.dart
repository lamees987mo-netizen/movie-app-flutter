import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The state of the Watchlist tab.
sealed class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

/// Waiting for the first list from local storage.
final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

/// At least one saved movie, most recently added first.
final class WatchlistLoaded extends WatchlistState {
  const WatchlistLoaded(this.movies);

  final List<Movie> movies;

  @override
  List<Object?> get props => [movies];
}

/// Nothing saved yet.
final class WatchlistEmpty extends WatchlistState {
  const WatchlistEmpty();
}

final class WatchlistError extends WatchlistState {
  const WatchlistError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
