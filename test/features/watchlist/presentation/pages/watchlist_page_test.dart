import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/pages/watchlist_page.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistCubit extends MockCubit<WatchlistState>
    implements WatchlistCubit {}

void main() {
  late MockWatchlistCubit cubit;

  setUp(() => cubit = MockWatchlistCubit());

  /// Tests [WatchlistView] with a mock cubit, so neither the service
  /// locator nor Hive is needed.
  Future<void> pumpView(WidgetTester tester, WatchlistState state) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        BlocProvider<WatchlistCubit>.value(
          value: cubit,
          child: const WatchlistView(),
        ),
      ),
    );
  }

  testWidgets('shows the title and a spinner while loading', (tester) async {
    await pumpView(tester, const WatchlistLoading());

    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state', (tester) async {
    await pumpView(tester, const WatchlistEmpty());

    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('Your watchlist is empty'), findsOneWidget);
    expect(
      find.text('Movies you save will appear here, even offline.'),
      findsOneWidget,
    );
    expect(find.byType(MoviePosterCard), findsNothing);
  });

  testWidgets('shows one poster per movie with watchlist hero tags', (
    tester,
  ) async {
    await pumpView(tester, const WatchlistLoaded([tMovie2, tMovie1]));

    final cards = tester.widgetList<MoviePosterCard>(
      find.byType(MoviePosterCard),
    );
    expect(cards.map((card) => card.movie), [tMovie2, tMovie1]);
    expect(cards.map((card) => card.heroTag), ['watchlist-2', 'watchlist-1']);
    expect(find.byType(EmptyView), findsNothing);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpView(tester, const WatchlistError(CacheFailure()));

    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });
}
