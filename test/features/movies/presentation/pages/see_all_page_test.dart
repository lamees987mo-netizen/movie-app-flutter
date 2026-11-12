import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/see_all_cubit.dart';
import 'package:movie_app/features/movies/presentation/pages/see_all_page.dart';

import '../../movies_test_helpers.dart';

class MockSeeAllCubit extends MockCubit<SeeAllState> implements SeeAllCubit {}

void main() {
  late MockSeeAllCubit cubit;

  setUp(() {
    cubit = MockSeeAllCubit();
    when(() => cubit.isClosed).thenReturn(false);
    when(() => cubit.loadFirstPage()).thenAnswer((_) async {});
    when(() => cubit.loadMore()).thenAnswer((_) async {});
    when(() => cubit.refresh()).thenAnswer((_) async {});
  });

  /// Shows a [SeeAllView] whose cubit is stuck in [state].
  Future<void> pumpView(WidgetTester tester, SeeAllState state) async {
    when(() => cubit.state).thenReturn(state);
    await tester.pumpWidget(
      wrapWithApp(
        BlocProvider<SeeAllCubit>.value(
          value: cubit,
          child: const SeeAllView(category: MovieCategory.topRated),
        ),
      ),
    );
    // Runs the post-frame callbacks (where loadMore may be requested).
    // Skeletonizer animates forever, so use pump(), not pumpAndSettle().
    await tester.pump();
  }

  testWidgets('shows the category title and a skeleton while loading', (
    tester,
  ) async {
    await pumpView(tester, const SeeAllLoading());

    expect(find.text('Top Rated'), findsOneWidget);
    expect(findSkeletonizer, findsOneWidget);
  });

  testWidgets('shows one poster per movie with unique hero tags', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SeeAllLoaded(
        movies: [tMovie1, tMovie2],
        page: 1,
        hasReachedMax: true,
      ),
    );

    final cards = tester.widgetList<MoviePosterCard>(
      find.byType(MoviePosterCard),
    );
    expect(cards.map((card) => card.heroTag), [
      'seeAll-topRated-1',
      'seeAll-topRated-2',
    ]);
    expect(findSkeletonizer, findsNothing);
    // The last page is on screen: nothing more to load.
    verifyNever(() => cubit.loadMore());
  });

  testWidgets('asks for the next page when the end of the grid is built', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SeeAllLoaded(
        movies: [tMovie1, tMovie2],
        page: 1,
        hasReachedMax: false,
      ),
    );

    verify(() => cubit.loadMore()).called(greaterThanOrEqualTo(1));
  });

  testWidgets('shows a spinner below the grid while loading more', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SeeAllLoaded(
        movies: [tMovie1, tMovie2],
        page: 1,
        hasReachedMax: false,
        isLoadingMore: true,
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verifyNever(() => cubit.loadMore());
  });

  testWidgets('shows the first-page error and retries on tap', (
    tester,
  ) async {
    await pumpView(tester, const SeeAllError(NetworkFailure()));

    expect(find.textContaining('No internet connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.loadFirstPage()).called(1);
  });

  testWidgets(
    'keeps the grid when loading more failed and retries only on tap',
    (tester) async {
      await pumpView(
        tester,
        const SeeAllLoaded(
          movies: [tMovie1, tMovie2],
          page: 1,
          hasReachedMax: false,
          loadMoreFailure: NetworkFailure(),
        ),
      );

      expect(find.byType(MoviePosterCard), findsNWidgets(2));
      expect(find.textContaining('No internet connection'), findsOneWidget);
      // No automatic retry loop.
      verifyNever(() => cubit.loadMore());

      await tester.tap(find.text('Retry'));
      verify(() => cubit.loadMore()).called(1);
    },
  );

  testWidgets('shows the empty message when the category has no movies', (
    tester,
  ) async {
    await pumpView(
      tester,
      const SeeAllLoaded(movies: [], page: 1, hasReachedMax: true),
    );

    expect(find.text('Nothing here yet.'), findsOneWidget);
  });
}
