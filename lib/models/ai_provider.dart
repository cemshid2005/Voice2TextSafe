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

  /// Page where the user can create/copy an API key for this provider.
  String get apiKeyPortalUrl => switch (this) {
        AiProvider.openai => 'https://platform.openai.com/api-keys',
        AiProvider.gemini => 'https://aistudio.google.com/apikey',
      };

  /// Short, numbered steps (Azerbaijani) shown in the in-app help dialog.
  List<String> get apiKeyHelpSteps => switch (this) {
        AiProvider.openai => const [
            'platform.openai.com saytına daxil olun və ya qeydiyyatdan keçin.',
            'Sol menyudan "API keys" bölməsinə keçin.',
            '"Create new secret key" düyməsini basın və ada bir ad verin.',
            'Yaranan açarı kopyalayın (bir daha göstərilməyəcək) və bu ekrana yapıştırın.',
            'Qeyd: API açarından istifadə etmək üçün OpenAI hesabınızda balans/billing aktiv olmalıdır.',
          ],
        AiProvider.gemini => const [
            'aistudio.google.com saytına Google hesabınızla daxil olun.',
            '"Get API key" və ya "Create API key" düyməsini basın.',
            'İstəyə görə yeni və ya mövcud bir Google Cloud layihəsi seçin.',
            'Yaranan açarı kopyalayın və bu ekrana yapıştırın.',
          ],
      };

  static AiProvider fromStorageKey(String key) => AiProvider.values.firstWhere(
        (provider) => provider.storageKey == key,
        orElse: () => AiProvider.openai,
      );
}
