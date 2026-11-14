import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';
import 'package:movie_app/features/person/presentation/cubit/person_cubit.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';
import 'package:movie_app/features/person/presentation/pages/person_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../movies/movies_test_helpers.dart';
import '../../person_test_helpers.dart';

class MockPersonCubit extends MockCubit<PersonState> implements PersonCubit {}

void main() {
  late MockPersonCubit cubit;

  setUp(() => cubit = MockPersonCubit());

  Future<void> pumpView(
    WidgetTester tester,
    PersonState state, {
    PersonArgs preview = const PersonArgs(),
  }) {
    when(() => cubit.state).thenReturn(state);
    return tester.pumpWidget(
      wrapWithApp(
        BlocProvider<PersonCubit>.value(
          value: cubit,
          child: PersonView(preview: preview),
        ),
      ),
    );
  }

  testWidgets('shows a skeleton with the preview name while loading', (
    tester,
  ) async {
    await pumpView(
      tester,
      const PersonLoading(),
      preview: const PersonArgs(name: 'Amy Poehler'),
    );
    // Skeletonizer animates forever, so pump() instead of pumpAndSettle().
    await tester.pump();

    expect(tester.widget<Skeletonizer>(findSkeletonizer).enabled, isTrue);
    expect(find.text('Amy Poehler'), findsOneWidget);
  });

  testWidgets('shows name, birth info, biography and movies', (tester) async {
    await pumpView(tester, PersonLoaded(tPerson));

    expect(tester.widget<Skeletonizer>(findSkeletonizer).enabled, isFalse);
    expect(find.text('Amy Poehler'), findsOneWidget);
    expect(find.text('Born Thursday, September 16, 1971'), findsOneWidget);
    expect(find.text('Newton, Massachusetts, USA'), findsOneWidget);
    expect(find.text('Biography'), findsOneWidget);
    expect(find.text(tPerson.biography), findsOneWidget);
    expect(find.text('Known for'), findsOneWidget);
    expect(find.byType(MoviePosterCard), findsNWidgets(2));
    // A short biography needs no "Show more" button.
    expect(find.text('Show more'), findsNothing);
  });

  testWidgets('says so when there is no biography and hides empty movies', (
    tester,
  ) async {
    await pumpView(
      tester,
      const PersonLoaded(Person(id: 1, name: 'Nobody', biography: '')),
    );

    expect(find.text('No biography available.'), findsOneWidget);
    expect(find.text('Known for'), findsNothing);
    expect(find.byType(MoviePosterCard), findsNothing);
  });

  testWidgets('a long biography can be expanded and collapsed', (
    tester,
  ) async {
    final longBio = List.filled(80, 'A very long biography line.').join(' ');
    // Tall enough to keep the button on screen when the text is expanded.
    tester.view
      ..physicalSize = const Size(800, 3000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpView(
      tester,
      PersonLoaded(Person(id: 1, name: 'Writer', biography: longBio)),
    );

    Text bioText() => tester.widget<Text>(find.text(longBio));
    expect(bioText().maxLines, 5);

    await tester.tap(find.text('Show more'));
    await tester.pump();
    expect(bioText().maxLines, isNull);
    expect(find.text('Show less'), findsOneWidget);

    await tester.tap(find.text('Show less'));
    await tester.pump();
    expect(bioText().maxLines, 5);
  });

  testWidgets('shows the error and retries on tap', (tester) async {
    when(() => cubit.load()).thenAnswer((_) async {});
    await pumpView(tester, const PersonError(NetworkFailure()));

    expect(find.textContaining('No internet connection'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    verify(() => cubit.load()).called(1);
  });

  testWidgets('tapping a movie opens its details with the movie as args', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(PersonLoaded(tPerson));
    Object? openedExtra;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<PersonCubit>.value(
            value: cubit,
            child: const PersonView(),
          ),
        ),
        GoRoute(
          path: '/movie/:id',
          builder: (_, state) {
            openedExtra = state.extra;
            return Text('movie ${state.pathParameters['id']}');
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

    await tester.tap(find.byType(MoviePosterCard).first);
    await tester.pumpAndSettle();

    expect(find.text('movie ${tKnownFor1.id}'), findsOneWidget);
    final args = openedExtra! as MovieDetailsArgs;
    expect(args.movie, tKnownFor1);
    expect(args.heroTag, 'person-${tPerson.id}-${tKnownFor1.id}');
  });
}
