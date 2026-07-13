/// Languages the user can translate a transcript into. The original
/// transcript is never modified by a translation.
enum TranslationLanguage {
  azerbaijani,
  english,
  turkish;

  String get code => switch (this) {
        TranslationLanguage.azerbaijani => 'az',
        TranslationLanguage.english => 'en',
        TranslationLanguage.turkish => 'tr',
      };

  /// Shown in the UI.
  String get nativeName => switch (this) {
        TranslationLanguage.azerbaijani => 'Azərbaycan',
        TranslationLanguage.english => 'English',
        TranslationLanguage.turkish => 'Türkçe',
      };

  /// Used inside AI prompts, in English, for reliable model behavior.
  String get promptName => switch (this) {
        TranslationLanguage.azerbaijani => 'Azerbaijani',
        TranslationLanguage.english => 'English',
        TranslationLanguage.turkish => 'Turkish',
      };

  static TranslationLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final language in TranslationLanguage.values) {
      if (language.code == code) return language;
    }
    return null;
  }
}
