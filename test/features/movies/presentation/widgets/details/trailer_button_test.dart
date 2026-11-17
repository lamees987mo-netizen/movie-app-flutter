import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/trailer_button.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  /// The trailer route is a stub that shows what it received, so this
  /// test checks only the button, not the real player.
  Future<void> pumpButton(WidgetTester tester, {String? title}) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: TrailerButton(youtubeKey: 'dQw4w9WgXcQ', title: title),
          ),
        ),
        GoRoute(
          path: TrailerRoutes.path,
          builder: (_, state) => Text(
            'trailer ${state.pathParameters['key']} ${state.extra}',
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('shows a play button', (tester) async {
    await pumpButton(tester);

    expect(find.text('Play trailer'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('opens the trailer page with the key and title', (
    tester,
  ) async {
    await pumpButton(tester, title: 'Inside Out 2');

    await tester.tap(find.text('Play trailer'));
    await tester.pumpAndSettle();

    expect(find.text('trailer dQw4w9WgXcQ Inside Out 2'), findsOneWidget);
  });

  testWidgets('works without a title', (tester) async {
    await pumpButton(tester);

    await tester.tap(find.text('Play trailer'));
    await tester.pumpAndSettle();

    expect(find.text('trailer dQw4w9WgXcQ null'), findsOneWidget);
  });
}
