// url_launcher_platform_interface comes with url_launcher; the tests only
// need it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records launches instead of opening anything. Extending (not
/// implementing) [UrlLauncherPlatform] passes its token check.
///
/// ```dart
/// setUp(() => UrlLauncherPlatform.instance = FakeUrlLauncher());
/// ```
class FakeUrlLauncher extends UrlLauncherPlatform {
  /// What [launchUrl] returns, unless [error] is set.
  bool result = true;

  /// When set, [launchUrl] throws it (e.g. a `PlatformException`).
  Exception? error;

  final List<(String, LaunchOptions)> launches = [];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launches.add((url, options));
    if (error case final error?) throw error;
    return result;
  }
}
