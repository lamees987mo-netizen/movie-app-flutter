import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';

class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockBox box;
  late Locale deviceLocale;

  SettingsCubit buildCubit() =>
      SettingsCubit(box, deviceLocale: () => deviceLocale);

  setUp(() {
    box = MockBox();
    deviceLocale = const Locale('en', 'US');
    when(() => box.get(any<dynamic>())).thenReturn(null);
    when(
      () => box.put(any<dynamic>(), any<dynamic>()),
    ).thenAnswer((_) async {});
  });

  group('first state', () {
    test('defaults when nothing is saved on an English phone', () {
      expect(buildCubit().state, const SettingsState());
    });

    test('uses Arabic when nothing is saved on an Arabic phone', () {
      deviceLocale = const Locale('ar', 'EG');

      expect(buildCubit().state.locale, const Locale('ar'));
    });

    test('uses English on a phone in another language', () {
      deviceLocale = const Locale('fr', 'FR');

      expect(buildCubit().state.locale, const Locale('en'));
    });

    test('the saved language wins over the phone language', () {
      deviceLocale = const Locale('ar');
      when(() => box.get('language_code')).thenReturn('en');

      expect(buildCubit().state.locale, const Locale('en'));
    });

    test('uses the saved theme and language', () {
      when(() => box.get('theme_mode')).thenReturn('dark');
      when(() => box.get('language_code')).thenReturn('ar');

      expect(
        buildCubit().state,
        const SettingsState(themeMode: ThemeMode.dark, locale: Locale('ar')),
      );
    });

    test('ignores saved values of the wrong type', () {
      when(() => box.get('theme_mode')).thenReturn(2);
      when(() => box.get('language_code')).thenReturn(<String>['ar']);

      expect(buildCubit().state, const SettingsState());
    });

    test('ignores unknown saved values', () {
      deviceLocale = const Locale('ar');
      when(() => box.get('theme_mode')).thenReturn('purple');
      when(() => box.get('language_code')).thenReturn('fr');

      expect(buildCubit().state, const SettingsState(locale: Locale('ar')));
    });

    test('uses defaults when the box cannot be read', () {
      when(() => box.get(any<dynamic>())).thenThrow(HiveError('broken'));

      expect(buildCubit().state, const SettingsState());
    });

    test('works without an injected device locale', () {
      // Uses the real PlatformDispatcher. The language of the test machine
      // is not known, so only check that a supported one was chosen.
      expect(
        SettingsCubit.supportedLocales,
        contains(SettingsCubit(box).state.locale),
      );
    });
  });

  blocTest<SettingsCubit, SettingsState>(
    'setThemeMode saves and emits the new theme',
    build: buildCubit,
    act: (cubit) => cubit.setThemeMode(ThemeMode.light),
    expect: () => const [SettingsState(themeMode: ThemeMode.light)],
    verify: (_) => verify(() => box.put('theme_mode', 'light')).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'setLocale saves and emits the new locale',
    build: buildCubit,
    act: (cubit) => cubit.setLocale(const Locale('ar')),
    expect: () => const [SettingsState(locale: Locale('ar'))],
    verify: (_) => verify(() => box.put('language_code', 'ar')).called(1),
  );

  group('when saving fails', () {
    blocTest<SettingsCubit, SettingsState>(
      'setThemeMode still emits and does not throw',
      setUp: () => when(
        () => box.put(any<dynamic>(), any<dynamic>()),
      ).thenThrow(HiveError('disk full')),
      build: buildCubit,
      act: (cubit) => cubit.setThemeMode(ThemeMode.dark),
      expect: () => const [SettingsState(themeMode: ThemeMode.dark)],
    );

    blocTest<SettingsCubit, SettingsState>(
      'setLocale still emits when the save fails later',
      setUp: () => when(
        () => box.put(any<dynamic>(), any<dynamic>()),
      ).thenAnswer((_) => Future.error(HiveError('disk full'))),
      build: buildCubit,
      act: (cubit) => cubit.setLocale(const Locale('ar')),
      expect: () => const [SettingsState(locale: Locale('ar'))],
    );
  });
}
