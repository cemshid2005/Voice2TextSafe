import 'translation_language.dart';

/// Result of a single transcription. Translations are kept alongside the
/// original transcript, which is never overwritten.
class TranscriptionResult {
  TranscriptionResult({
    required this.sourceFileName,
    required this.transcript,
    DateTime? createdAt,
    Map<TranslationLanguage, String>? translations,
  })  : createdAt = createdAt ?? DateTime.now(),
        translations = translations ?? const {};

  final String sourceFileName;
  final String transcript;
  final DateTime createdAt;
  final Map<TranslationLanguage, String> translations;

  TranscriptionResult copyWithTranslation(TranslationLanguage language, String text) {
    return TranscriptionResult(
      sourceFileName: sourceFileName,
      transcript: transcript,
      createdAt: createdAt,
      translations: {...translations, language: text},
    );
  }
}
