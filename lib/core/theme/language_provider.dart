import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi, odia, tamil }

extension AppLanguageExt on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.english: return 'English';
      case AppLanguage.hindi: return 'हिन्दी (Hindi)';
      case AppLanguage.odia: return 'ଓଡ଼ିଆ (Odia)';
      case AppLanguage.tamil: return 'தமிழ் (Tamil)';
    }
  }

  String get code {
    switch (this) {
      case AppLanguage.english: return 'en';
      case AppLanguage.hindi: return 'hi';
      case AppLanguage.odia: return 'or';
      case AppLanguage.tamil: return 'ta';
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  static const _key = 'app_language';

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    state = AppLanguage.values[index];
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, language.index);
    state = language;
  }
}
