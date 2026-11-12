import 'package:equatable/equatable.dart';
import 'package:movie_app/core/error/failures.dart';

/// Whether one movie is in the watchlist.
///
/// A single class (not sealed): the button is always shown, and an error
/// only needs a short message while [isSaved] keeps its last known value.
class WatchlistToggleState extends Equatable {
  const WatchlistToggleState({this.isSaved = false, this.failure});

  final bool isSaved;

  /// Set when the last read or toggle failed; cleared on the next toggle.
  final Failure? failure;

  @override
  List<Object?> get props => [isSaved, failure];
}
