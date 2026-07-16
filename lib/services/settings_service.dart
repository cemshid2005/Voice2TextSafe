import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_provider.dart';
import '../models/translation_language.dart';

/// Stores non-sensitive preferences only. API keys never go through this
/// service - see [SecureStorageService] for that.
class SettingsService {
  static const _kProvider = 'selected_provider';
  static const _kDefaultTranslationLanguage = 'default_translation_language';
  static const _kThemeMode = 'theme_mode';
  static const _kEnabledTranslationLanguages = 'enabled_translation_languages';

  Future<AiProvider> readProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kProvider);
    return value == null ? AiProvider.openai : AiProvider.fromStorageKey(value);
  }

  Future<void> writeProvider(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProvider, provider.storageKey);
  }

  Future<TranslationLanguage?> readDefaultTranslationLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return TranslationLanguage.fromCode(prefs.getString(_kDefaultTranslationLanguage));
  }

  Future<void> writeDefaultTranslationLanguage(TranslationLanguage? language) async {
    final prefs = await SharedPreferences.getInstance();
    if (language == null) {
      await prefs.remove(_kDefaultTranslationLanguage);
    } else {
      await prefs.setString(_kDefaultTranslationLanguage, language.code);
    }
  }

  Future<Set<TranslationLanguage>> readEnabledTranslationLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_kEnabledTranslationLanguages);
    if (stored == null) return TranslationLanguage.defaultEnabled;
    final languages = stored.map(TranslationLanguage.fromCode).whereType<TranslationLanguage>().toSet();
    return languages.isEmpty ? TranslationLanguage.defaultEnabled : languages;
  }

  Future<void> writeEnabledTranslationLanguages(Set<TranslationLanguage> languages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kEnabledTranslationLanguages,
      languages.map((language) => language.code).toList(),
    );
  }

  Future<ThemeMode> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode.name);
  }
}
