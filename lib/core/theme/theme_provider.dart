import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppColorTheme>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppColorTheme> {
  ThemeNotifier() : super(AppColorTheme.solarized) {
    _loadTheme();
  }

  static const _key = 'app_color_theme';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? AppColorTheme.solarized.index; // Default to forest green (solarized)
    state = AppColorTheme.values[index];
  }

  Future<void> setTheme(AppColorTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
    state = theme;
  }

  // Legacy toggle for backward compatibility
  Future<void> toggleTheme() async {
    if (state == AppColorTheme.light) {
      await setTheme(AppColorTheme.dark);
    } else {
      await setTheme(AppColorTheme.light);
    }
  }

  bool get isDark => state == AppColorTheme.dark || state == AppColorTheme.ocean || state == AppColorTheme.solarized || state == AppColorTheme.sunset;

  ThemeData get currentThemeData {
    switch (state) {
      case AppColorTheme.light: return AppTheme.lightTheme;
      case AppColorTheme.dark: return AppTheme.darkTheme;
      case AppColorTheme.ocean: return AppTheme.oceanTheme;
      case AppColorTheme.solarized: return AppTheme.forestTheme;
      case AppColorTheme.sunset: return AppTheme.sunsetTheme;
    }
  }
}
