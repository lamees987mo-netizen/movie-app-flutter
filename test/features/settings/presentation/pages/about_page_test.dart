// url_launcher_platform_interface comes with url_launcher; the test only
// needs it to replace the platform side with a fake.
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/settings/presentation/pages/about_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import '../../../movies/movies_test_helpers.dart';
import '../../../movies/presentation/fake_url_launcher.dart';

void main() {
  late FakeUrlLauncher launcher;

  setUp(() {
    launcher = FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    // The real version comes from the platform; tests use a fixed one.
    PackageInfo.setMockInitialValues(
      appName: 'Movie App',
      packageName: 'com.lamees.movie_app',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  testWidgets('shows the name, version, description and TMDB credit', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithApp(const AboutPage()));
    await tester.pumpAndSettle();

    expect(find.text('About us'), findsOneWidget);
    expect(find.text('Movie App'), findsOneWidget);
    expect(find.text('Version 1.2.3 (45)'), findsOneWidget);
    expect(find.textContaining('keep a watchlist'), findsOneWidget);
    expect(find.textContaining('uses the TMDB API'), findsOneWidget);
  });

  testWidgets('"Source code on GitHub" opens the repository', (tester) async {
    await tester.pumpWidget(wrapWithApp(const AboutPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Source code on GitHub'));
    await tester.pumpAndSettle();

    expect(
      launcher.launches.single.$1,
      'https://github.com/lamees987mo-netizen/movie-app-flutter',
    );
  });

  testWidgets('"Open-source licenses" opens the licenses page', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithApp(const AboutPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });
}
