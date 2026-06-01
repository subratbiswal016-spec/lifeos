import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppColorTheme { light, dark, ocean, solarized }

extension AppColorThemeExt on AppColorTheme {
  String get displayName {
    switch (this) {
      case AppColorTheme.light: return '☀️ Light';
      case AppColorTheme.dark: return '🌑 Dark';
      case AppColorTheme.ocean: return '🌊 Deep Ocean';
      case AppColorTheme.solarized: return '🌿 Forest Green';
    }
  }
}

class AppTheme {
  // Light Palette
  static const Color primary = Color(0xFFFF9F1C);
  static const Color secondary = Color(0xFF2EC4B6);

  // Ocean Palette
  static const Color oceanPrimary = Color(0xFF0096C7);
  static const Color oceanSecondary = Color(0xFF48CAE4);

  // Solarized (Forest Green) Palette
  static const Color forestPrimary = Color(0xFF2D6A4F);
  static const Color forestSecondary = Color(0xFF52B788);

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    primary: primary,
    secondary: secondary,
    background: const Color(0xFFFAFAFA),
    surface: const Color(0xFFFFFFFF),
    onBackground: const Color(0xFF1A1A24),
    textThemeBase: ThemeData.light().textTheme,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: primary,
    secondary: secondary,
    background: const Color(0xFF0F0F13),
    surface: const Color(0xFF1C1C24),
    onBackground: const Color(0xFFE0E0E0),
    textThemeBase: ThemeData.dark().textTheme,
  );

  static ThemeData get oceanTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: oceanPrimary,
    secondary: oceanSecondary,
    background: const Color(0xFF03045E),
    surface: const Color(0xFF023E8A),
    onBackground: const Color(0xFFCAF0F8),
    textThemeBase: ThemeData.dark().textTheme,
  );

  static ThemeData get forestTheme => _buildTheme(
    brightness: Brightness.dark,
    primary: forestPrimary,
    secondary: forestSecondary,
    background: const Color(0xFF081C15),
    surface: const Color(0xFF1B4332),
    onBackground: const Color(0xFFD8F3DC),
    textThemeBase: ThemeData.dark().textTheme,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color onBackground,
    required TextTheme textThemeBase,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        onBackground: onBackground,
      ),
      textTheme: GoogleFonts.outfitTextTheme(textThemeBase),
      cardTheme: const CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
