import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/app.dart';
import 'package:movie_app/core/config/env.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/firebase/firebase_options.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.ensureConfigured();
  await _initFirebase();
  await HiveBoxes.init();
  initDependencies();
  runApp(const App());
}

/// Starts Firebase and sends uncaught errors to Crashlytics.
///
/// Android reads its settings from `android/app/google-services.json`, iOS
/// from [AppFirebaseOptions]. If Firebase can't start (e.g. desktop), the
/// app still runs: analytics falls back to a no-op (see `initDependencies`).
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: AppFirebaseOptions.currentPlatform);
  } on Object catch (error) {
    log('Firebase is not configured, continuing without it', error: error);
    return;
  }

  final crashlytics = FirebaseCrashlytics.instance;
  // No reports from debug runs: they would flood the dashboard while
  // developing. Profile and release builds do report.
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  // Errors inside Flutter (build, layout, paint)...
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  // ...and any other uncaught async error.
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashlytics.recordError(error, stack, fatal: true));
    return true;
  };
}
