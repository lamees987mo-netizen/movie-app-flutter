import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_details_cubit.dart';
import 'package:movie_app/features/movies/presentation/pages/movie_details_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../movies_test_helpers.dart';

class MockMovieDetailsCubit extends MockCubit<MovieDetailsState>
    implements MovieDetailsCubit {}

void main() {
  late MockMovieDetailsCubit cubit;

  setUp(() => cubit = MockMovieDetailsCubit());

  /// Tests [MovieDetailsView] (the body of the page) with a mock cubit, so
  /// neither the service locator nor the network is needed.
  Future<void> pumpView(WidgetTester tester, MovieDetailsState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        BlocProvider<MovieDetailsCubit>.value(
          value: cubit,
          child: const MovieDetailsView(heroTag: 'trending-1'),
        ),
      ),
    );
  }

  testWidgets('shows a skeleton while loading', (tester) async {
    await pumpView(tester, const MovieDetailsLoading());
    await tester.pump();

    final skeletonizer = tester.widget<Skeletonizer>(findSkeletonizer);
    expect(skeletonizer.enabled, isTrue);
  });

  testWidgets('shows title, info, genres, overview, cast and trailer', (
    tester,
  ) async {
    await pumpView(tester, const MovieDetailsLoaded(tDetails));

    expect(find.text('Inside Out 2'), findsOneWidget);
    expect(find.text('7.6'), findsOneWidget);
    expect(find.text('97 min'), findsOneWidget);
    expect(find.text('Animation'), findsOneWidget);
    expect(find.text('Emotions.'), findsOneWidget);
    expect(find.text('Amy Poehler'), findsOneWidget);
    expect(find.text('Joy (voice)'), findsOneWidget);
    expect(find.text('Play trailer'), findsOneWidget);
  });

  testWidgets('hides the trailer button when there is no trailer', (
    tester,
  ) async {
    const noTrailer = MovieDetails(movie: tMovie1);
    await pumpView(tester, const MovieDetailsLoaded(noTrailer));

    expect(find.text('Play trailer'), findsNothing);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpView(tester, const MovieDetailsError(ServerFailure(500)));

    expect(find.textContaining('server is having trouble'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });
}
