import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_app/app.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/result/result.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/entities/paginated_movies.dart';
import 'package:movie_app/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_app/features/watchlist/presentation/pages/watchlist_page.dart';

/// The whole app on a real device, with a fake repository instead of TMDB,
/// so the test needs no internet and no token.
///
/// Run: `flutter test integration_test -d <device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await HiveBoxes.init();
    initDependencies();
    // Replace the real repository before anything uses it (it is lazy).
    sl
      ..unregister<MoviesRepository>()
      ..registerLazySingleton<MoviesRepository>(_FakeMoviesRepository.new);
  });

  setUp(() async {
    // Start from a clean state on the device.
    await sl<Box<dynamic>>(instanceName: HiveBoxes.watchlist).clear();
    await sl<Box<dynamic>>(instanceName: HiveBoxes.settings).clear();
  });

  testWidgets('open a movie, save it, and find it in the watchlist', (
    tester,
  ) async {
    await tester.pumpWidget(const App());

    // Home: every section shows the fake movies.
    await _pumpUntilFound(tester, find.byType(MoviePosterCard));
    expect(find.text('Trending'), findsOneWidget);

    // Open the first movie.
    await tester.tap(find.byType(MoviePosterCard).first);
    await _pumpUntilFound(tester, find.text('Add to watchlist'));
    expect(find.text(_movie.title), findsOneWidget);
    expect(find.text('Integration overview.'), findsOneWidget);

    // Save it.
    await tester.tap(find.text('Add to watchlist'));
    await _pumpUntilFound(tester, find.text('Remove from watchlist'));

    // Back to Home, then the Watchlist tab.
    await tester.tap(find.byType(BackButton));
    await _pumpUntilFound(tester, find.text('Watchlist'));
    await tester.tap(find.text('Watchlist').last);

    // Only look inside the Watchlist page: the Home tab stays alive (but
    // hidden) in the navigation shell and has posters too.
    final savedPoster = find.descendant(
      of: find.byType(WatchlistPage),
      matching: find.byType(MoviePosterCard),
    );
    await _pumpUntilFound(tester, savedPoster);
    expect(savedPoster, findsOneWidget);
    expect(
      tester.widget<MoviePosterCard>(savedPoster).movie.id,
      _movie.id,
    );
  });
}

/// Pumps frames until [finder] matches, or fails after [timeout].
/// (`pumpAndSettle` cannot be used: the loading skeleton animates forever.)
Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

/// No image paths, so nothing is downloaded.
const _movie = Movie(
  id: 42,
  title: 'Integration Movie',
  overview: 'Integration overview.',
  voteAverage: 7.5,
);

class _FakeMoviesRepository implements MoviesRepository {
  @override
  Future<Result<PaginatedMovies>> getMovies(
    MovieCategory category, {
    int page = 1,
  }) async => const Success(
    PaginatedMovies(movies: [_movie], page: 1, totalPages: 1),
  );

  @override
  Future<Result<MovieDetails>> getMovieDetails(int movieId) async =>
      const Success(MovieDetails(movie: _movie, runtime: 120));

  @override
  Future<Result<PaginatedMovies>> searchMovies(
    String query, {
    int page = 1,
  }) async => const Success(
    PaginatedMovies(movies: [_movie], page: 1, totalPages: 1),
  );
}
