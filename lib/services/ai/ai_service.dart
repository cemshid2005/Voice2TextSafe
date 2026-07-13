import 'dart:io';

import '../../models/translation_language.dart';

/// Common interface implemented by each AI provider. Implementations talk
/// directly (HTTPS) to the provider's public API - there is no backend.
abstract class AiService {
  /// Transcribes [audioFile], auto-detecting the spoken language(s) and
  /// preserving any code-switching as-is, without translating.
  Future<String> transcribe(File audioFile);

  /// Translates [text] into [targetLanguage]. Never mutates the original
  /// transcript - callers are expected to keep both around.
  Future<String> translate(String text, TranslationLanguage targetLanguage);
}
