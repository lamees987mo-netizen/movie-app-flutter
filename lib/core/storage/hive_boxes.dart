import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Names of the Hive boxes and their one-time setup.
///
/// Boxes store plain JSON-like maps (e.g. `MovieModel.toJson()`), so no Hive
/// type adapters are needed.
abstract final class HiveBoxes {
  static const String watchlist = 'watchlist';
  static const String homeCache = 'home_cache';
  static const String settings = 'settings';

  /// Must run before `initDependencies()`, which reads the opened boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(watchlist),
      Hive.openBox<dynamic>(homeCache),
      Hive.openBox<dynamic>(settings),
    ]);
  }
}
