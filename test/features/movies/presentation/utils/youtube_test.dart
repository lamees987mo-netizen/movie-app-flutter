// url_launcher_platform_interface comes with url_launcher; the test only
// needs it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/presentation/utils/youtube.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../movies_test_helpers.dart';
import '../fake_url_launcher.dart';

void main() {
  group('isValidYoutubeKey', () {
    for (final key in ['dQw4w9WgXcQ', 'a_b-C1d2E3f', '___________']) {
      test('accepts $key', () => expect(isValidYoutubeKey(key), isTrue));
    }

    for (final key in [
      '',
      'abc123', // too short
      'dQw4w9WgXcQx', // too long
      'dQw4w9WgXc!', // bad character
      'dQw4w9 WgXc', // space
      '../../etc/p', // path tricks
    ]) {
      test('rejects "$key"', () => expect(isValidYoutubeKey(key), isFalse));
    }
  });

  test('youtubeWatchUri builds the normal YouTube link', () {
    expect(
      youtubeWatchUri('dQw4w9WgXcQ').toString(),
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
  });

  group('openOnYoutube', () {
    late UrlLauncherPlatform original;
    late FakeUrlLauncher launcher;

    setUp(() {
      original = UrlLauncherPlatform.instance;
      launcher = FakeUrlLauncher();
      UrlLauncherPlatform.instance = launcher;
    });

    tearDown(() => UrlLauncherPlatform.instance = original);

    Future<void> pumpAndOpen(WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openOnYoutube(context, 'dQw4w9WgXcQ'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
    }

    testWidgets('opens the video in an external app', (tester) async {
      await pumpAndOpen(tester);

      expect(launcher.launches, hasLength(1));
      final (url, options) = launcher.launches.single;
      expect(url, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      expect(options.mode, PreferredLaunchMode.externalApplication);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('shows a SnackBar when nothing can open the link', (
      tester,
    ) async {
      launcher.result = false;

      await pumpAndOpen(tester);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a SnackBar when launching throws', (tester) async {
      launcher.error = Exception('no handler');

      await pumpAndOpen(tester);

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });
  });
}
