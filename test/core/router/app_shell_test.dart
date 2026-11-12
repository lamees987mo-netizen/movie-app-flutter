import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/app_shell.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  /// A shell with four plain tabs, so [AppShell] is tested without the
  /// real pages (and so without the service locator). The Home tab also
  /// has a sub-page, to check that re-tapping a tab goes back to its root.
  GoRouter createRouter() {
    StatefulShellBranch branch(String path, String label) =>
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: path,
              builder: (_, _) => Text('$label page'),
              routes: [
                GoRoute(
                  path: 'sub',
                  builder: (_, _) => Text('$label sub page'),
                ),
              ],
            ),
          ],
        );

    return GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            branch('/home', 'Home'),
            branch('/search', 'Search'),
            branch('/watchlist', 'Watchlist'),
            branch('/settings', 'Settings'),
          ],
        ),
      ],
    );
  }

  Future<GoRouter> pumpShell(WidgetTester tester) async {
    final router = createRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  int selectedIndex(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  testWidgets('shows the four destinations and starts on Home', (
    tester,
  ) async {
    await pumpShell(tester);

    for (final label in ['Home', 'Search', 'Watchlist', 'Settings']) {
      expect(navLabel(label), findsOneWidget);
    }
    expect(find.text('Home page'), findsOneWidget);
    expect(selectedIndex(tester), 0);
  });

  testWidgets('tapping a destination switches tabs', (tester) async {
    await pumpShell(tester);

    const tabs = {
      'Search': 1,
      'Watchlist': 2,
      'Settings': 3,
      'Home': 0,
    };
    for (final MapEntry(key: label, value: index) in tabs.entries) {
      await tester.tap(navLabel(label));
      await tester.pumpAndSettle();

      expect(find.text('$label page'), findsOneWidget, reason: label);
      expect(selectedIndex(tester), index, reason: label);
    }
  });

  testWidgets('each tab keeps its own navigation stack', (tester) async {
    final router = await pumpShell(tester);

    router.go('/home/sub');
    await tester.pumpAndSettle();
    expect(find.text('Home sub page'), findsOneWidget);

    await tester.tap(navLabel('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search page'), findsOneWidget);

    // Back to Home from another tab: the sub page is still there.
    await tester.tap(navLabel('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Home sub page'), findsOneWidget);
  });

  testWidgets('tapping the current tab again returns to its first page', (
    tester,
  ) async {
    final router = await pumpShell(tester);

    router.go('/home/sub');
    await tester.pumpAndSettle();
    expect(find.text('Home sub page'), findsOneWidget);

    await tester.tap(navLabel('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Home page'), findsOneWidget);
    expect(find.text('Home sub page'), findsNothing);
  });
}
