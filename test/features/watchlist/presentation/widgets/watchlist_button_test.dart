import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/watchlist/presentation/cubit/watchlist_toggle_cubit.dart';
import 'package:movie_app/features/watchlist/presentation/widgets/watchlist_button.dart';

import '../../../movies/movies_test_helpers.dart';

class MockWatchlistToggleCubit extends MockCubit<WatchlistToggleState>
    implements WatchlistToggleCubit {}

void main() {
  late MockWatchlistToggleCubit cubit;

  setUp(() => cubit = MockWatchlistToggleCubit());

  Future<void> pumpButton(WidgetTester tester) {
    return tester.pumpWidget(
      wrapWithApp(
        Scaffold(
          body: BlocProvider<WatchlistToggleCubit>.value(
            value: cubit,
            child: const WatchlistToggleButton(),
          ),
        ),
      ),
    );
  }

  testWidgets('offers to add a movie that is not saved', (tester) async {
    when(() => cubit.state).thenReturn(const WatchlistToggleState());
    await pumpButton(tester);

    expect(find.text('Add to watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
  });

  testWidgets('offers to remove a saved movie', (tester) async {
    when(
      () => cubit.state,
    ).thenReturn(const WatchlistToggleState(isSaved: true));
    await pumpButton(tester);

    expect(find.text('Remove from watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
  });

  testWidgets('tapping calls toggle', (tester) async {
    when(() => cubit.state).thenReturn(const WatchlistToggleState());
    when(() => cubit.toggle()).thenAnswer((_) async {});
    await pumpButton(tester);

    await tester.tap(find.text('Add to watchlist'));

    verify(() => cubit.toggle()).called(1);
  });

  testWidgets('shows a SnackBar when saving fails', (tester) async {
    whenListen(
      cubit,
      Stream.value(const WatchlistToggleState(failure: CacheFailure())),
      initialState: const WatchlistToggleState(),
    );
    await pumpButton(tester);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
  });
}
