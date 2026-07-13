import '../../models/ai_provider.dart';
import 'ai_service.dart';
import 'gemini_service.dart';
import 'openai_service.dart';

class AiServiceFactory {
  AiServiceFactory._();

  static AiService create(AiProvider provider, String apiKey) {
    switch (provider) {
      case AiProvider.openai:
        return OpenAiService(apiKey);
      case AiProvider.gemini:
        return GeminiService(apiKey);
    }
  }
}
