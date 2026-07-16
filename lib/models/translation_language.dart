/// Languages the user can translate a transcript into. The original
/// transcript is never modified by a translation.
///
/// Only a user-selected subset is shown as quick-translate chips (see
/// `SettingsProvider.enabledTranslationLanguages`); `azerbaijani`, `english`
/// and `turkish` are enabled by default.
enum TranslationLanguage {
  azerbaijani,
  english,
  turkish,
  russian,
  arabic,
  german,
  french,
  spanish,
  persian,
  chinese;

  String get code => switch (this) {
        TranslationLanguage.azerbaijani => 'az',
        TranslationLanguage.english => 'en',
        TranslationLanguage.turkish => 'tr',
        TranslationLanguage.russian => 'ru',
        TranslationLanguage.arabic => 'ar',
        TranslationLanguage.german => 'de',
        TranslationLanguage.french => 'fr',
        TranslationLanguage.spanish => 'es',
        TranslationLanguage.persian => 'fa',
        TranslationLanguage.chinese => 'zh',
      };

  /// Shown in the UI.
  String get nativeName => switch (this) {
        TranslationLanguage.azerbaijani => 'Azərbaycan',
        TranslationLanguage.english => 'English',
        TranslationLanguage.turkish => 'Türkçe',
        TranslationLanguage.russian => 'Русский',
        TranslationLanguage.arabic => 'العربية',
        TranslationLanguage.german => 'Deutsch',
        TranslationLanguage.french => 'Français',
        TranslationLanguage.spanish => 'Español',
        TranslationLanguage.persian => 'فارسی',
        TranslationLanguage.chinese => '中文',
      };

  /// Used inside AI prompts, in English, for reliable model behavior.
  String get promptName => switch (this) {
        TranslationLanguage.azerbaijani => 'Azerbaijani',
        TranslationLanguage.english => 'English',
        TranslationLanguage.turkish => 'Turkish',
        TranslationLanguage.russian => 'Russian',
        TranslationLanguage.arabic => 'Arabic',
        TranslationLanguage.german => 'German',
        TranslationLanguage.french => 'French',
        TranslationLanguage.spanish => 'Spanish',
        TranslationLanguage.persian => 'Persian',
        TranslationLanguage.chinese => 'Chinese',
      };

  static TranslationLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final language in TranslationLanguage.values) {
      if (language.code == code) return language;
    }
    return null;
  }

  static const Set<TranslationLanguage> defaultEnabled = {
    TranslationLanguage.azerbaijani,
    TranslationLanguage.english,
    TranslationLanguage.turkish,
  };
}
