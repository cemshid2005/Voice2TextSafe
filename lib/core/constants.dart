class AppConstants {
  AppConstants._();

  static const String openAiTranscriptionModel = 'gpt-4o-transcribe';
  static const String openAiTextModel = 'gpt-4o-mini';
  static const String geminiModel = 'gemini-2.5-flash';

  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Conservative cap so a base64-encoded request still fits comfortably
  /// under both providers' request-size limits. Nothing above this is ever
  /// read into memory or sent anywhere.
  static const int maxAudioFileSizeBytes = 15 * 1024 * 1024; // 15 MB

  static const Duration requestTimeout = Duration(seconds: 120);
}
