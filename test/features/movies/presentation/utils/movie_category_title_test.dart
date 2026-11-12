import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/utils/movie_category_title.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final ar = lookupAppLocalizations(const Locale('ar'));

  test('every category has its English title', () {
    expect(
      {for (final c in MovieCategory.values) c: c.title(en)},
      {
        MovieCategory.trending: 'Trending',
        MovieCategory.topRated: 'Top Rated',
        MovieCategory.upcoming: 'Upcoming',
        MovieCategory.nowPlaying: 'Now Playing',
      },
    );
  });

  test('every category has its Arabic title', () {
    expect(
      {for (final c in MovieCategory.values) c: c.title(ar)},
      {
        MovieCategory.trending: ar.moviesTrending,
        MovieCategory.topRated: ar.moviesTopRated,
        MovieCategory.upcoming: ar.moviesUpcoming,
        MovieCategory.nowPlaying: ar.moviesNowPlaying,
      },
    );
  });
}
