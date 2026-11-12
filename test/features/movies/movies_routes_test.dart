import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/features/movies/movies_routes.dart';

/// Bad links must go Home instead of crashing the page builder.
void main() {
  Future<GoRouter> pumpRouter(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        ...moviesRoutes,
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    return router;
  }

  for (final badPath in [
    '/movie/abc',
    '/movie/12x',
    '/see-all/popular',
    '/see-all/TRENDING',
  ]) {
    testWidgets('redirects $badPath to Home', (tester) async {
      final router = await pumpRouter(tester);

      router.go(badPath);
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
