// webview_flutter_platform_interface comes with youtube_player_iframe; the
// test only needs it to put the real WebView back afterwards.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/presentation/widgets/trailer/trailer_player.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../fake_webview_platform.dart';

const _key = 'dQw4w9WgXcQ';

void main() {
  late WebViewPlatform? original;
  late FakeWebViewPlatform webView;
  late int errors;
  late List<MethodCall> systemCalls;

  setUp(() {
    original = WebViewPlatform.instance;
    webView = FakeWebViewPlatform();
    WebViewPlatform.instance = webView;
    errors = 0;
    systemCalls = [];
  });

  tearDown(() {
    if (original case final original?) WebViewPlatform.instance = original;
  });

  Future<void> pumpPlayer(WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        systemCalls.add(call);
        return null;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TrailerPlayer(youtubeKey: _key, onError: () => errors++),
        ),
      ),
    );
    // The player waits a couple of frames before it shows the WebView.
    await tester.pump();
    await tester.pump();
    // Like the real iframe, tell the player it has finished loading, so
    // nothing is left waiting when the test ends.
    webView.sendToPlayer({'Ready': true});
    await tester.pump();
  }

  /// Removes the player, so it closes its controller.
  Future<void> disposePlayer(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  testWidgets('shows the YouTube player for the video', (tester) async {
    await pumpPlayer(tester);

    expect(find.byType(YoutubePlayer), findsOneWidget);
    final player = tester.widget<YoutubePlayer>(find.byType(YoutubePlayer));
    expect(player.controller.key, _key);
    expect(errors, 0);

    await disposePlayer(tester);
  });

  testWidgets('reports a player error once', (tester) async {
    await pumpPlayer(tester);

    // 150: the owner does not allow playing the video outside YouTube.
    webView.sendToPlayer({'PlayerError': 150});
    await tester.pump();
    webView.sendToPlayer({'PlayerError': 101});
    await tester.pump();

    expect(errors, 1);

    await disposePlayer(tester);
  });

  testWidgets('hides the system bars only while fullscreen', (tester) async {
    await pumpPlayer(tester);

    webView.sendToPlayer({'FullscreenButtonPressed': true});
    await tester.pump();
    expect(
      systemCalls.last,
      isMethodCall(
        'SystemChrome.setEnabledSystemUIMode',
        arguments: 'SystemUiMode.immersiveSticky',
      ),
    );

    // Leaving the page while fullscreen brings the bars back.
    await disposePlayer(tester);
    expect(
      systemCalls.last,
      isMethodCall(
        'SystemChrome.setEnabledSystemUIMode',
        arguments: 'SystemUiMode.edgeToEdge',
      ),
    );
  });
}
