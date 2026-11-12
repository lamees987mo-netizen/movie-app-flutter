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

  setUp(() {
    box = MockBox();
    when(() => box.get(any<dynamic>())).thenReturn(null);
    when(
      () => box.put(any<dynamic>(), any<dynamic>()),
    ).thenAnswer((_) async {});
  });

  test('starts with defaults when nothing is saved', () {
    expect(SettingsCubit(box).state, const SettingsState());
  });

  test('starts with the saved theme and language', () {
    when(() => box.get('theme_mode')).thenReturn('dark');
    when(() => box.get('language_code')).thenReturn('ar');

    expect(
      SettingsCubit(box).state,
      const SettingsState(themeMode: ThemeMode.dark, locale: Locale('ar')),
    );
  });

  blocTest<SettingsCubit, SettingsState>(
    'setThemeMode saves and emits the new theme',
    build: () => SettingsCubit(box),
    act: (cubit) => cubit.setThemeMode(ThemeMode.light),
    expect: () => const [SettingsState(themeMode: ThemeMode.light)],
    verify: (_) => verify(() => box.put('theme_mode', 'light')).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'setLocale saves and emits the new locale',
    build: () => SettingsCubit(box),
    act: (cubit) => cubit.setLocale(const Locale('ar')),
    expect: () => const [SettingsState(locale: Locale('ar'))],
    verify: (_) => verify(() => box.put('language_code', 'ar')).called(1),
  );
}
