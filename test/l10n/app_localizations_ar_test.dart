import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

void main() {
  test('Arabic runtime uses the correct plural form', () {
    final ar = lookupAppLocalizations(const Locale('ar'));

    expect(ar.detailsRuntimeMinutes(1), 'دقيقة واحدة');
    expect(ar.detailsRuntimeMinutes(2), 'دقيقتان');
    expect(ar.detailsRuntimeMinutes(5), '5 دقائق'); // 3–10: plural form
    expect(ar.detailsRuntimeMinutes(97), '97 دقيقة');
    expect(ar.detailsRuntimeMinutes(120), '120 دقيقة');
  });
}
