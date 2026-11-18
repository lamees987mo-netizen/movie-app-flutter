import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/settings/presentation/pages/terms_page.dart';

import '../../../movies/movies_test_helpers.dart';

void main() {
  testWidgets('explains what is stored where, and credits TMDB', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrapWithApp(const TermsPage()));

    expect(find.text('Terms & policies'), findsOneWidget);
    for (final title in [
      'On your device',
      'If you sign in',
      'Analytics and crash reports',
      'Movie data',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    expect(find.textContaining('uses the TMDB API'), findsOneWidget);
  });
}
