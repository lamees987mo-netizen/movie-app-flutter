import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/person/person_routes.dart';
import 'package:movie_app/features/person/presentation/cubit/person_cubit.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';
import 'package:movie_app/features/person/presentation/pages/person_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

class MockPersonCubit extends MockCubit<PersonState> implements PersonCubit {}

void main() {
  late List<int> requestedIds;

  setUp(() {
    requestedIds = [];
    sl.registerFactoryParam<PersonCubit, int, void>((personId, _) {
      requestedIds.add(personId);
      final cubit = MockPersonCubit();
      // An error state has no skeleton, so pumpAndSettle() can finish.
      when(() => cubit.state).thenReturn(const PersonError(ServerFailure()));
      when(cubit.load).thenAnswer((_) async {});
      return cubit;
    });
  });

  tearDown(sl.reset);

  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        ...personRoutes,
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
    return router;
  }

  for (final badPath in ['/person/abc', '/person/12x']) {
    testWidgets('redirects $badPath to Home', (tester) async {
      final router = await pumpRouter(tester);

      router.go(badPath);
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(requestedIds, isEmpty);
    });
  }

  testWidgets('opens the person from the path with the preview args', (
    tester,
  ) async {
    final router = await pumpRouter(tester);

    unawaited(
      router.push(
        Routes.personPath(56322),
        extra: const PersonArgs(name: 'Amy Poehler', profilePath: '/a.jpg'),
      ),
    );
    await tester.pumpAndSettle();

    final page = tester.widget<PersonPage>(find.byType(PersonPage));
    expect(page.personId, 56322);
    expect(page.preview.name, 'Amy Poehler');
    expect(page.preview.profilePath, '/a.jpg');
    expect(requestedIds, [56322]);
  });

  testWidgets('a deep link works without args', (tester) async {
    final router = await pumpRouter(tester);

    router.go(Routes.personPath(7));
    await tester.pumpAndSettle();

    final page = tester.widget<PersonPage>(find.byType(PersonPage));
    expect(page.personId, 7);
    expect(page.preview.name, isNull);
    expect(requestedIds, [7]);
  });
}
