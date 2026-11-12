// url_launcher_platform_interface comes with url_launcher; the test only
// needs it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/presentation/widgets/details/trailer_button.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../movies_test_helpers.dart';

/// Records launches instead of opening anything. Extending (not
/// implementing) [UrlLauncherPlatform] passes its token check.
class _FakeUrlLauncher extends UrlLauncherPlatform {
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

void main() {
  late UrlLauncherPlatform original;
  late _FakeUrlLauncher launcher;

  setUp(() {
    original = UrlLauncherPlatform.instance;
    launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  tearDown(() => UrlLauncherPlatform.instance = original);

  Future<void> pumpAndTap(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const Scaffold(body: TrailerButton(youtubeKey: 'abc123')),
      ),
    );
    await tester.tap(find.text('Play trailer'));
    await tester.pump();
  }

  testWidgets('shows a play button', (tester) async {
    await tester.pumpWidget(
      wrapWithApp(
        const Scaffold(body: TrailerButton(youtubeKey: 'abc123')),
      ),
    );

    expect(find.text('Play trailer'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('opens the YouTube video in an external app', (tester) async {
    await pumpAndTap(tester);

    expect(launcher.launches, hasLength(1));
    final (url, options) = launcher.launches.single;
    expect(url, 'https://www.youtube.com/watch?v=abc123');
    expect(options.mode, PreferredLaunchMode.externalApplication);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('shows a SnackBar when nothing can open the link', (
    tester,
  ) async {
    launcher.result = false;

    await pumpAndTap(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a SnackBar when launching throws', (tester) async {
    launcher.error = Exception('no handler');

    await pumpAndTap(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}
