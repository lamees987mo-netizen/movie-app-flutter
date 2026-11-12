import 'package:flutter/material.dart';

/// Spacing scale used across the app, so paddings stay consistent.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Material 3 light and dark themes generated from one seed color.
abstract final class AppTheme {
  static const Color _seedColor = Color(0xFF01B4E4); // TMDB blue

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      cardTheme: const CardThemeData(clipBehavior: Clip.antiAlias),
    );
  }
}
