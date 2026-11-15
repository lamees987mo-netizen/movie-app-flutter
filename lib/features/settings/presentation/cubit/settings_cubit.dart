import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';

/// Holds the theme mode and language, and saves them in the Hive
/// `settings` box so they survive app restarts.
class SettingsCubit extends Cubit<SettingsState> {
  /// [deviceLocale] returns the phone's language. It defaults to the real
  /// one; tests pass their own so they don't depend on the test machine.
  SettingsCubit(this._box, {Locale Function()? deviceLocale})
    : super(_readSaved(_box, deviceLocale ?? _platformLocale));

  final Box<dynamic> _box;

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static Locale _platformLocale() => PlatformDispatcher.instance.locale;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    emit(state.copyWith(themeMode: themeMode));
    await _save(_themeModeKey, themeMode.name);
  }

  Future<void> setLocale(Locale locale) async {
    emit(state.copyWith(locale: locale));
    await _save(_languageCodeKey, locale.languageCode);
  }

  /// The new setting is emitted first, so the screen changes right away.
  /// If saving fails (e.g. the disk is full), the app keeps working with
  /// the new setting; it is only forgotten after a restart.
  Future<void> _save(String key, String value) async {
    try {
      await _box.put(key, value);
    } on Object catch (error, stackTrace) {
      log('Could not save $key', error: error, stackTrace: stackTrace);
    }
  }

  /// Builds the first state from saved values, falling back to defaults.
  ///
  /// Saved values are checked, not cast: a value of the wrong type or an
  /// unknown language (e.g. from an older app version) is ignored instead
  /// of crashing the app on start.
  static SettingsState _readSaved(
    Box<dynamic> box,
    Locale Function() deviceLocale,
  ) {
    final themeName = _readString(box, _themeModeKey);
    final languageCode = _readString(box, _languageCodeKey);
    return SettingsState(
      themeMode:
          ThemeMode.values.asNameMap()[themeName] ??
          const SettingsState().themeMode,
      locale: _supported(languageCode) ?? _defaultLocale(deviceLocale),
    );
  }

  static String? _readString(Box<dynamic> box, String key) {
    try {
      final value = box.get(key);
      return value is String ? value : null;
    } on Object catch (error) {
      log('Could not read $key', error: error);
      return null;
    }
  }

  /// The supported locale with this language code, or `null`.
  static Locale? _supported(String? languageCode) {
    for (final locale in supportedLocales) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }

  /// First start: use the phone's language if the app has it (an Arabic
  /// phone opens in Arabic), otherwise English.
  static Locale _defaultLocale(Locale Function() deviceLocale) =>
      _supported(deviceLocale().languageCode) ?? const Locale('en');
}
