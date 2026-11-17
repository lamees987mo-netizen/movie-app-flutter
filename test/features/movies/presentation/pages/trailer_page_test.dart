// url_launcher_platform_interface comes with url_launcher; the test only
// needs it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/presentation/pages/trailer_page.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../movies_test_helpers.dart';
import '../fake_url_launcher.dart';

const _key = 'dQw4w9WgXcQ';
const _youtubeUrl = 'https://www.youtube.com/watch?v=$_key';
const _errorText = "This trailer can't be played in the app.";

void main() {
  late UrlLauncherPlatform original;
  late FakeUrlLauncher launcher;

  /// Lets a test make the fake player fail, like YouTube would.
  late VoidCallback failPlayer;

  setUp(() {
    original = UrlLauncherPlatform.instance;
    launcher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
  });

  tearDown(() => UrlLauncherPlatform.instance = original);

  /// A real WebView cannot run in widget tests, so the page gets a fake
  /// player (the real one is tested in `trailer_player_test.dart`).
  Widget fakePlayer(BuildContext context, String key, VoidCallback onError) {
    failPlayer = onError;
    return Text('player $key');
  }

  Future<void> pumpPage(WidgetTester tester, {String? title}) async {
    await tester.pumpWidget(
      wrapWithApp(
        TrailerPage(youtubeKey: _key, title: title, playerBuilder: fakePlayer),
      ),
    );
  }

  testWidgets('shows the player and the movie title', (tester) async {
    await pumpPage(tester, title: 'Inside Out 2');

    expect(find.text('player $_key'), findsOneWidget);
    expect(find.text('Inside Out 2'), findsOneWidget);
    expect(find.text(_errorText), findsNothing);
  });

  testWidgets('says "Trailer" when the title is unknown', (tester) async {
    await pumpPage(tester);

    expect(find.text('Trailer'), findsOneWidget);
  });

  testWidgets('the app bar action opens the video on YouTube', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Open in YouTube'));
    await tester.pump();

    final (url, options) = launcher.launches.single;
    expect(url, _youtubeUrl);
    expect(options.mode, PreferredLaunchMode.externalApplication);
  });

  testWidgets('when the player fails, offers YouTube instead', (
    tester,
  ) async {
    await pumpPage(tester);

    failPlayer();
    await tester.pump();

    expect(find.text('player $_key'), findsNothing);
    expect(find.text(_errorText), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Open in YouTube'));
    await tester.pump();

    expect(launcher.launches.single.$1, _youtubeUrl);
  });

  testWidgets('shows a SnackBar when YouTube cannot be opened', (
    tester,
  ) async {
    launcher.result = false;
    await pumpPage(tester);

    await tester.tap(find.byTooltip('Open in YouTube'));
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}
