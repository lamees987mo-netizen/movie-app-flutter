import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/watchlist/data/models/saved_movie_model.dart';

import '../../../movies/movies_test_helpers.dart';

void main() {
  test('toJson is the movie JSON plus added_at, and reads back', () {
    final entry = SavedMovieModel(
      movie: MovieModel.fromEntity(tMovie1),
      addedAt: DateTime(2024, 3, 4),
    );

    final json = entry.toJson();
    expect(json['id'], tMovie1.id);
    expect(json['title'], tMovie1.title);
    expect(json['added_at'], DateTime(2024, 3, 4).millisecondsSinceEpoch);

    final back = SavedMovieModel.fromJson(json);
    expect(back.movie.toEntity(), tMovie1);
    expect(back.addedAt, DateTime(2024, 3, 4));
  });

  test('an entry without added_at sorts as the oldest', () {
    final entry = SavedMovieModel.fromJson(
      MovieModel.fromEntity(tMovie1).toJson(),
    );

    expect(entry.addedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
}
