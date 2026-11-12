import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_section.dart';

import '../../movies_test_helpers.dart';

class MockMovieSectionCubit extends MockCubit<MovieSectionState>
    implements MovieSectionCubit {}

void main() {
  late MockMovieSectionCubit cubit;

  setUp(() => cubit = MockMovieSectionCubit());

  /// Shows a [MovieSection] whose cubit is stuck in [state].
  Future<void> pumpSection(WidgetTester tester, MovieSectionState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        Scaffold(
          body: BlocProvider<MovieSectionCubit>.value(
            value: cubit,
            child: const MovieSection(category: MovieCategory.trending),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the title and See all button', (tester) async {
    await pumpSection(tester, const MovieSectionLoaded([tMovie1]));

    expect(find.text('Trending'), findsOneWidget);
    expect(find.text('See all'), findsOneWidget);
  });

  testWidgets('shows a skeleton while loading', (tester) async {
    await pumpSection(tester, const MovieSectionLoading());

    // Skeletonizer animates forever, so use pump(), not pumpAndSettle().
    await tester.pump();

    expect(findSkeletonizer, findsOneWidget);
  });

  testWidgets('shows one poster per movie with unique hero tags', (
    tester,
  ) async {
    await pumpSection(tester, const MovieSectionLoaded([tMovie1, tMovie2]));

    final cards = tester.widgetList<MoviePosterCard>(
      find.byType(MoviePosterCard),
    );
    expect(cards.map((card) => card.heroTag), ['trending-1', 'trending-2']);
    expect(findSkeletonizer, findsNothing);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpSection(tester, const MovieSectionError(NetworkFailure()));

    expect(find.textContaining('No internet connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });
}
