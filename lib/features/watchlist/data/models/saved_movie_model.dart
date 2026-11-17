import 'package:movie_app/features/movies/data/models/movie_model.dart';

/// One watchlist entry: the movie and when it was saved.
///
/// Stored the same way in Hive (a value of the `watchlist` box) and in
/// Firestore (the document `users/{uid}/watchlist/{movieId}`):
/// `MovieModel.toJson()` plus an `added_at` field in milliseconds since
/// epoch. It is one flat map, so `MovieModel.fromJson` can read it directly
/// (it ignores the extra field).
///
/// Written by hand instead of with `json_serializable`, because the movie's
/// fields are flattened into the same map instead of nested.
class SavedMovieModel {
  const SavedMovieModel({required this.movie, required this.addedAt});

  factory SavedMovieModel.fromJson(Map<String, dynamic> json) =>
      SavedMovieModel(
        movie: MovieModel.fromJson(json),
        // Entries saved without a date sort last.
        addedAt: DateTime.fromMillisecondsSinceEpoch(
          (json[addedAtKey] as num?)?.toInt() ?? 0,
        ),
      );

  static const String addedAtKey = 'added_at';

  final MovieModel movie;
  final DateTime addedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
    ...movie.toJson(),
    addedAtKey: addedAt.millisecondsSinceEpoch,
  };
}
