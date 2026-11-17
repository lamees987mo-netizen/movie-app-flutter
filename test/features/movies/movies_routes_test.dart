// webview_flutter_platform_interface comes with youtube_player_iframe; the
// test only needs it to put the real WebView back afterwards.
// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/features/movies/movies_routes.dart';
import 'package:movie_app/features/movies/presentation/pages/trailer_page.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'presentation/fake_webview_platform.dart';

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
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    return router;
  }

  for (final badPath in [
    '/movie/abc',
    '/movie/12x',
    '/see-all/popular',
    '/see-all/TRENDING',
    '/trailer/abc123', // too short for a YouTube id
    '/trailer/dQw4w9WgXcQx', // too long
    '/trailer/dQw4w9WgXc!', // bad character
  ]) {
    testWidgets('redirects $badPath to Home', (tester) async {
      final router = await pumpRouter(tester);

      router.go(badPath);
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  group('trailer route', () {
    late WebViewPlatform? original;
    late FakeWebViewPlatform webView;

    setUp(() {
      original = WebViewPlatform.instance;
      webView = FakeWebViewPlatform();
      WebViewPlatform.instance = webView;
    });

    tearDown(() {
      if (original case final original?) WebViewPlatform.instance = original;
    });

    /// Opens [path] and lets the (fake) player finish loading.
    Future<GoRouter> openTrailer(
      WidgetTester tester,
      String path, {
      Object? extra,
    }) async {
      final router = await pumpRouter(tester);
      unawaited(router.push(path, extra: extra));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // page transition
      webView.sendToPlayer({'Ready': true});
      await tester.pump();
      return router;
    }

    /// Leaves the page, so the player closes before the test ends.
    Future<void> goHome(WidgetTester tester, GoRouter router) async {
      router.go('/');
      await tester.pumpAndSettle();
    }

    testWidgets('plays a valid key with the title from extra', (
      tester,
    ) async {
      final router = await openTrailer(
        tester,
        '/trailer/dQw4w9WgXcQ',
        extra: 'Inside Out 2',
      );

      final page = tester.widget<TrailerPage>(find.byType(TrailerPage));
      expect(page.youtubeKey, 'dQw4w9WgXcQ');
      expect(page.title, 'Inside Out 2');
      expect(find.byType(YoutubePlayer), findsOneWidget);

      await goHome(tester, router);
    });

    testWidgets('ignores an extra that is not a title', (tester) async {
      final router = await openTrailer(
        tester,
        '/trailer/a_b-C1d2E3f',
        extra: 42,
      );

      expect(find.byType(TrailerPage), findsOneWidget);
      expect(find.text('Trailer'), findsOneWidget);

      await goHome(tester, router);
    });
  });
}
