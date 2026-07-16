import 'summary_type.dart';
import 'translation_language.dart';

/// Result of a single transcription. Translations and summaries are kept
/// alongside the original transcript, which is never overwritten.
class TranscriptionResult {
  TranscriptionResult({
    required this.sourceFileName,
    required this.transcript,
    DateTime? createdAt,
    Map<TranslationLanguage, String>? translations,
    Map<SummaryType, String>? summaries,
  })  : createdAt = createdAt ?? DateTime.now(),
        translations = translations ?? const {},
        summaries = summaries ?? const {};

  final String sourceFileName;
  final String transcript;
  final DateTime createdAt;
  final Map<TranslationLanguage, String> translations;
  final Map<SummaryType, String> summaries;

  TranscriptionResult copyWithTranslation(TranslationLanguage language, String text) {
    return TranscriptionResult(
      sourceFileName: sourceFileName,
      transcript: transcript,
      createdAt: createdAt,
      translations: {...translations, language: text},
      summaries: summaries,
    );
  }

  TranscriptionResult copyWithSummary(SummaryType type, String text) {
    return TranscriptionResult(
      sourceFileName: sourceFileName,
      transcript: transcript,
      createdAt: createdAt,
      translations: translations,
      summaries: {...summaries, type: text},
    );
  }
}
