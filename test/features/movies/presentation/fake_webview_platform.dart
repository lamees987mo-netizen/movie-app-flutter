// webview_flutter_platform_interface comes with youtube_player_iframe; the
// tests only need it to replace the real WebView with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A pretend WebView, so widget tests can build `YoutubePlayer`.
///
/// Nothing is loaded or played. Tests talk to the player the way the real
/// YouTube iframe would, through [sendToPlayer].
///
/// ```dart
/// setUp(() => WebViewPlatform.instance = FakeWebViewPlatform());
/// ```
class FakeWebViewPlatform extends WebViewPlatform {
  /// Every controller created so far (one per player).
  final List<FakeWebViewController> controllers = [];

  /// Sends a message to the newest player, like the iframe does, e.g.
  /// `{'Ready': true}` or `{'PlayerError': 150}`.
  void sendToPlayer(Map<String, Object?> event) {
    final channel = controllers.last.channels.single;
    channel.onMessageReceived(
      JavaScriptMessage(
        message: jsonEncode({'playerId': channel.name, ...event}),
      ),
    );
  }

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) {
    final controller = FakeWebViewController(params);
    controllers.add(controller);
    return controller;
  }

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => _FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _FakeWebViewWidget(params);
}

/// Accepts every call and remembers the JavaScript channels.
class FakeWebViewController extends PlatformWebViewController {
  FakeWebViewController(super.params) : super.implementation();

  final List<JavaScriptChannelParams> channels = [];

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async =>
      channels.add(params);

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async =>
      channels.removeWhere((c) => c.name == javaScriptChannelName);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> setUserAgent(String? userAgent) async {}

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async => '';
}

class _FakeNavigationDelegate extends PlatformNavigationDelegate {
  _FakeNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}
}

class _FakeWebViewWidget extends PlatformWebViewWidget {
  _FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
