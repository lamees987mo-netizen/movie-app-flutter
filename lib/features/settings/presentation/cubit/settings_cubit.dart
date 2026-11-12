import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';

/// Holds the theme mode and language, and saves them in the Hive
/// `settings` box so they survive app restarts.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._box) : super(_readSaved(_box));

  final Box<dynamic> _box;

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _box.put(_themeModeKey, themeMode.name);
    emit(state.copyWith(themeMode: themeMode));
  }

  Future<void> setLocale(Locale locale) async {
    await _box.put(_languageCodeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  /// Builds the first state from saved values, falling back to defaults.
  static SettingsState _readSaved(Box<dynamic> box) {
    const defaults = SettingsState();
    final themeName = box.get(_themeModeKey) as String?;
    final languageCode = box.get(_languageCodeKey) as String?;
    return SettingsState(
      themeMode: ThemeMode.values.asNameMap()[themeName] ?? defaults.themeMode,
      locale: languageCode == null ? defaults.locale : Locale(languageCode),
    );
  }
}
