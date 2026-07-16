import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../models/summary_type.dart';
import '../../models/translation_language.dart';
import '../../utils/error_mapper.dart';
import 'ai_service.dart';

/// Gemini implementation: audio is sent inline (base64) to
/// `generateContent`, guided by a prompt that asks the model to preserve
/// multi-language speech as-is; translation reuses the same endpoint with a
/// text-only prompt.
class GeminiService implements AiService {
  GeminiService(this._apiKey);

  final String _apiKey;

  Uri get _generateContentUri => Uri.parse(
        '${AppConstants.geminiBaseUrl}/models/${AppConstants.geminiModel}:generateContent'
        '?key=$_apiKey',
      );

  @override
  Future<String> transcribe(File audioFile) async {
    final bytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(bytes);
    final mimeType = _mimeTypeFor(audioFile.path);

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Transcribe this audio exactly as spoken. Automatically detect '
                  'the spoken language(s). If more than one language is used in '
                  'the recording, transcribe each part in the language it was '
                  'spoken in - do not translate or normalize into a single '
                  'language. Add natural punctuation and present the text in a '
                  'readable format. Return only the transcript, with no extra '
                  'commentary or labels.',
            },
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Audio},
            },
          ],
        },
      ],
      'generationConfig': {'temperature': 0.2},
    });

    final response = await http
        .post(
          _generateContentUri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw ErrorMapper.fromStatusCode(response.statusCode);
    }
    return _extractText(response.body, emptyMessage: 'Transkripsiya boş qayıtdı.');
  }

  @override
  Future<String> translate(String text, TranslationLanguage targetLanguage) async {
    return _generateText(
      prompt: 'Translate the following text to ${targetLanguage.promptName}. '
          'Preserve meaning and tone. Return only the translated text, '
          'with no extra commentary:\n\n$text',
      emptyMessage: 'Tərcümə boş qayıtdı.',
    );
  }

  @override
  Future<String> summarize(String text, SummaryType type) async {
    return _generateText(
      prompt: '${type.promptInstruction} Respond in the same language as the '
          'source text - do not translate it. Return only the summary, with '
          'no extra commentary:\n\n$text',
      emptyMessage: 'Xülasə boş qayıtdı.',
    );
  }

  Future<String> _generateText({required String prompt, required String emptyMessage}) async {
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.2},
    });

    final response = await http
        .post(
          _generateContentUri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(AppConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw ErrorMapper.fromStatusCode(response.statusCode);
    }
    return _extractText(response.body, emptyMessage: emptyMessage);
  }

  String _extractText(String responseBody, {required String emptyMessage}) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw AppException(emptyMessage);
    }
    final parts = (candidates.first['content']?['parts'] as List<dynamic>?) ?? const [];
    final text = parts.map((part) => part['text'] as String? ?? '').join().trim();
    if (text.isEmpty) {
      throw AppException(emptyMessage);
    }
    return text;
  }

  String _mimeTypeFor(String path) {
    final extension = path.toLowerCase().split('.').last;
    switch (extension) {
      case 'mp3':
        return 'audio/mp3';
      case 'wav':
        return 'audio/wav';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
      case 'oga':
        return 'audio/ogg';
      case 'opus':
        return 'audio/opus';
      case 'flac':
        return 'audio/flac';
      default:
        return 'audio/mpeg';
    }
  }
}
