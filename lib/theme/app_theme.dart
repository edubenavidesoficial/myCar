import 'package:flutter/material.dart';

abstract class AppTheme {
  static const teal = Color(0xFF00AFA5);
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: teal, brightness: brightness, surface: dark ? const Color(0xFF101817) : const Color(0xFFF7F9F8));
    return ThemeData(colorScheme: scheme, brightness: brightness, useMaterial3: true, scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: scheme.surface, elevation: 0, surfaceTintColor: Colors.transparent),
      cardTheme: CardThemeData(elevation: 0, color: dark ? const Color(0xFF182321) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))));
  }
}
