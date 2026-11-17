import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/firebase/firebase_options.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('iOS uses the options from GoogleService-Info.plist', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final options = AppFirebaseOptions.currentPlatform;

    expect(options, AppFirebaseOptions.ios);
    expect(options?.iosBundleId, 'com.lamees.movieApp');
    expect(options?.projectId, 'movie-app-flutter-c20b3');
  });

  test('Android uses google-services.json (no options in code)', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(AppFirebaseOptions.currentPlatform, isNull);
  });
}
