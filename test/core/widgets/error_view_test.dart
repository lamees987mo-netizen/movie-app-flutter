import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('shows the message and calls onRetry when tapped', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      wrap(ErrorView(message: 'Oops', onRetry: () => retries++)),
    );

    expect(find.text('Oops'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
  });

  testWidgets('hides the retry button without onRetry', (tester) async {
    await tester.pumpWidget(wrap(const ErrorView(message: 'Oops')));

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('uses the Arabic label in Arabic', (tester) async {
    await tester.pumpWidget(
      wrap(
        ErrorView(message: 'خطأ', onRetry: () {}),
        locale: const Locale('ar'),
      ),
    );

    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}
