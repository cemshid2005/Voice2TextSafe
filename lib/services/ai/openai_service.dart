import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../models/summary_type.dart';
import '../../models/translation_language.dart';
import '../../utils/error_mapper.dart';
import 'ai_service.dart';

/// OpenAI implementation: `audio/transcriptions` for speech-to-text and
/// `chat/completions` for translation of the resulting transcript.
class OpenAiService implements AiService {
  OpenAiService(this._apiKey);

  final String _apiKey;

  @override
  Future<String> transcribe(File audioFile) async {
    final uri = Uri.parse('${AppConstants.openAiBaseUrl}/audio/transcriptions');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $_apiKey'
      ..fields['model'] = AppConstants.openAiTranscriptionModel
      ..fields['response_format'] = 'json'
      ..fields['prompt'] =
          'Transcribe the speech exactly as spoken. Keep every language that '
          'is used, do not translate anything, add natural punctuation.'
      ..files.add(await http.MultipartFile.fromPath('file', audioFile.path));

    final streamedResponse = await request.send().timeout(AppConstants.requestTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw ErrorMapper.fromStatusCode(response.statusCode);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = (decoded['text'] as String?)?.trim();
    if (text == null || text.isEmpty) {
      throw AppException('Transkripsiya boş qayıtdı.');
    }
    return text;
  }

  @override
  Future<String> translate(String text, TranslationLanguage targetLanguage) async {
    final content = await _chatComplete(
      systemPrompt: 'You are a precise translator. Translate the user text to '
          '${targetLanguage.promptName}. Preserve meaning and tone. '
          'Return only the translated text, with no extra commentary.',
      userContent: text,
    );
    if (content.isEmpty) {
      throw AppException('Tərcümə boş qayıtdı.');
    }
    return content;
  }

  @override
  Future<String> summarize(String text, SummaryType type) async {
    final content = await _chatComplete(
      systemPrompt: '${type.promptInstruction} Respond in the same language as '
          'the source text - do not translate it. Return only the summary, '
          'with no extra commentary.',
      userContent: text,
    );
    if (content.isEmpty) {
      throw AppException('Xülasə boş qayıtdı.');
    }
    return content;
  }

  Future<String> _chatComplete({
    required String systemPrompt,
    required String userContent,
  }) async {
    final uri = Uri.parse('${AppConstants.openAiBaseUrl}/chat/completions');
    final response = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': AppConstants.openAiTextModel,
            'temperature': 0.2,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userContent},
            ],
          }),
        )
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw ErrorMapper.fromStatusCode(response.statusCode);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    final content = (choices != null && choices.isNotEmpty)
        ? (choices.first['message']?['content'] as String?)?.trim()
        : null;
    return content ?? '';
  }
}
