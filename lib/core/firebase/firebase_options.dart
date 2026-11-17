import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase settings per platform.
///
/// Android reads its settings from `android/app/google-services.json`
/// (through the Gradle plugin), so it needs no options here.
/// iOS gets them from code instead of `ios/Runner/GoogleService-Info.plist`,
/// because adding that file to the Xcode project needs a Mac. The values
/// come from that plist; they are not secrets (they identify the app).
abstract final class AppFirebaseOptions {
  /// `null` means "use the platform's own config file".
  static FirebaseOptions? get currentPlatform =>
      switch (defaultTargetPlatform) {
        TargetPlatform.iOS => ios,
        _ => null,
      };

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBP8i-A4LQB6JfiVWhmTOlBfu1d1zzD2SU',
    appId: '1:764841872920:ios:26310ee592f2d72b2abd6d',
    messagingSenderId: '764841872920',
    projectId: 'movie-app-flutter-c20b3',
    storageBucket: 'movie-app-flutter-c20b3.firebasestorage.app',
    iosBundleId: 'com.lamees.movieApp',
  );
}
