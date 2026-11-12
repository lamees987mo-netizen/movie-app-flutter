import 'package:flutter/material.dart';
import 'package:movie_app/app.dart';
import 'package:movie_app/core/config/env.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/storage/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.ensureConfigured();
  await HiveBoxes.init();
  initDependencies();
  runApp(const App());
}
