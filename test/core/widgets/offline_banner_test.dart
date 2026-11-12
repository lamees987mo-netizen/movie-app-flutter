import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/widgets/offline_banner.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  Widget wrap({Locale locale = const Locale('en')}) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: OfflineBanner()),
    );
  }

  testWidgets('shows the offline icon and message', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(find.text("You're offline. Showing saved content."), findsOneWidget);
  });

  testWidgets('uses the tertiary container colors', (tester) async {
    await tester.pumpWidget(wrap());

    final colors = Theme.of(
      tester.element(find.byType(OfflineBanner)),
    ).colorScheme;
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(OfflineBanner),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, colors.tertiaryContainer);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.cloud_off)).color,
      colors.onTertiaryContainer,
    );
  });

  testWidgets('is translated', (tester) async {
    await tester.pumpWidget(wrap(locale: const Locale('ar')));

    expect(find.text('أنت غير متصل. يتم عرض المحتوى المحفوظ.'), findsOneWidget);
  });
}
