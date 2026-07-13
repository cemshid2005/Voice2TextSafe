/// Supported AI providers. All requests go straight from the device to the
/// provider's public API - there is no backend in between.
enum AiProvider {
  openai,
  gemini;

  String get storageKey => switch (this) {
        AiProvider.openai => 'openai',
        AiProvider.gemini => 'gemini',
      };

  String get displayName => switch (this) {
        AiProvider.openai => 'OpenAI',
        AiProvider.gemini => 'Google Gemini',
      };

  static AiProvider fromStorageKey(String key) => AiProvider.values.firstWhere(
        (provider) => provider.storageKey == key,
        orElse: () => AiProvider.openai,
      );
}
