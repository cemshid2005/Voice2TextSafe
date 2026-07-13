import 'package:flutter/material.dart';

import '../models/ai_provider.dart';
import '../models/translation_language.dart';
import '../services/secure_storage_service.dart';
import '../services/settings_service.dart';

/// App-wide settings: active provider, API keys (delegated to secure
/// storage), default translation language and theme mode.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    SettingsService? settingsService,
    SecureStorageService? secureStorageService,
  })  : _settingsService = settingsService ?? SettingsService(),
        _secureStorageService = secureStorageService ?? SecureStorageService();

  final SettingsService _settingsService;
  final SecureStorageService _secureStorageService;

  AiProvider _selectedProvider = AiProvider.openai;
  ThemeMode _themeMode = ThemeMode.system;
  TranslationLanguage? _defaultTranslationLanguage;
  bool _hasApiKeyForSelectedProvider = false;
  bool _initialized = false;

  AiProvider get selectedProvider => _selectedProvider;
  ThemeMode get themeMode => _themeMode;
  TranslationLanguage? get defaultTranslationLanguage => _defaultTranslationLanguage;
  bool get hasApiKeyForSelectedProvider => _hasApiKeyForSelectedProvider;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _selectedProvider = await _settingsService.readProvider();
    _themeMode = await _settingsService.readThemeMode();
    _defaultTranslationLanguage = await _settingsService.readDefaultTranslationLanguage();
    await _refreshHasApiKey();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _refreshHasApiKey() async {
    final key = await _secureStorageService.readApiKey(_selectedProvider);
    _hasApiKeyForSelectedProvider = key != null && key.isNotEmpty;
  }

  Future<bool> hasAnyApiKey() => _secureStorageService.hasAnyApiKey();

  Future<String?> getApiKey([AiProvider? provider]) {
    return _secureStorageService.readApiKey(provider ?? _selectedProvider);
  }

  Future<void> setProvider(AiProvider provider) async {
    if (provider == _selectedProvider) return;
    _selectedProvider = provider;
    await _settingsService.writeProvider(provider);
    await _refreshHasApiKey();
    notifyListeners();
  }

  Future<void> saveApiKey(String apiKey, {AiProvider? provider}) async {
    await _secureStorageService.writeApiKey(provider ?? _selectedProvider, apiKey);
    await _refreshHasApiKey();
    notifyListeners();
  }

  Future<void> clearApiKey({AiProvider? provider}) async {
    await _secureStorageService.deleteApiKey(provider ?? _selectedProvider);
    await _refreshHasApiKey();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsService.writeThemeMode(mode);
    notifyListeners();
  }

  Future<void> setDefaultTranslationLanguage(TranslationLanguage? language) async {
    _defaultTranslationLanguage = language;
    await _settingsService.writeDefaultTranslationLanguage(language);
    notifyListeners();
  }
}
