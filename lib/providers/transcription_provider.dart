import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/ai_provider.dart';
import '../models/transcription_result.dart';
import '../models/translation_language.dart';
import '../services/ai/ai_service_factory.dart';
import '../utils/error_mapper.dart';

enum TranscriptionStatus { idle, loading, success, error }

/// Owns the lifecycle of a single "share -> transcribe -> translate" flow.
///
/// The shared audio file is kept only while the current flow is active (so
/// "Yenidən transkripsiya et" can reuse it) and is deleted as soon as a new
/// flow starts, the flow is dismissed, or the provider is disposed. Audio
/// and transcript text are only ever held in memory / local cache - nothing
/// is written anywhere else.
class TranscriptionProvider extends ChangeNotifier {
  File? _audioFile;
  TranscriptionStatus _status = TranscriptionStatus.idle;
  TranscriptionResult? _result;
  String? _errorMessage;
  bool _isTranslating = false;
  TranslationLanguage? _translatingLanguage;

  TranscriptionStatus get status => _status;
  TranscriptionResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get isTranslating => _isTranslating;
  TranslationLanguage? get translatingLanguage => _translatingLanguage;

  Future<void> transcribe({
    required File audioFile,
    required AiProvider provider,
    required String apiKey,
    TranslationLanguage? autoTranslateTo,
  }) async {
    await _deleteAudioFile(exceptPath: audioFile.path);

    _audioFile = audioFile;
    _status = TranscriptionStatus.loading;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      _validateFileSize(audioFile);
      final service = AiServiceFactory.create(provider, apiKey);
      final transcript = await service.transcribe(audioFile);
      _result = TranscriptionResult(
        sourceFileName: _fileNameOf(audioFile),
        transcript: transcript,
      );
      _status = TranscriptionStatus.success;
      notifyListeners();

      if (autoTranslateTo != null) {
        await translate(language: autoTranslateTo, provider: provider, apiKey: apiKey);
      }
    } catch (error) {
      _errorMessage = ErrorMapper.map(error).message;
      _status = TranscriptionStatus.error;
      notifyListeners();
    }
  }

  Future<void> retranscribe({
    required AiProvider provider,
    required String apiKey,
  }) async {
    final file = _audioFile;
    if (file == null || !(await file.exists())) {
      _errorMessage =
          'Orijinal audio fayl artıq mövcud deyil. Zəhmət olmasa faylı yenidən paylaşın.';
      _status = TranscriptionStatus.error;
      notifyListeners();
      return;
    }
    await transcribe(audioFile: file, provider: provider, apiKey: apiKey);
  }

  Future<void> translate({
    required TranslationLanguage language,
    required AiProvider provider,
    required String apiKey,
  }) async {
    final currentResult = _result;
    if (currentResult == null) return;

    _isTranslating = true;
    _translatingLanguage = language;
    notifyListeners();

    try {
      final service = AiServiceFactory.create(provider, apiKey);
      final translated = await service.translate(currentResult.transcript, language);
      final latest = _result ?? currentResult;
      _result = latest.copyWithTranslation(language, translated);
    } catch (error) {
      _errorMessage = ErrorMapper.map(error).message;
    } finally {
      _isTranslating = false;
      _translatingLanguage = null;
      notifyListeners();
    }
  }

  /// Clears in-memory state and deletes the cached audio file. Call this
  /// when the user leaves the result flow (e.g. navigates back to Home).
  Future<void> clearCurrentAudio() async {
    await _deleteAudioFile();
    _status = TranscriptionStatus.idle;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _validateFileSize(File file) {
    final size = file.lengthSync();
    if (size > AppConstants.maxAudioFileSizeBytes) {
      throw AppException(
        'Audio fayl çox böyükdür (maksimum '
        '${AppConstants.maxAudioFileSizeBytes ~/ (1024 * 1024)} MB).',
      );
    }
  }

  String _fileNameOf(File file) {
    final segments = file.uri.pathSegments;
    return segments.isNotEmpty ? segments.last : 'audio';
  }

  Future<void> _deleteAudioFile({String? exceptPath}) async {
    final file = _audioFile;
    if (file == null || file.path == exceptPath) return;
    _audioFile = null;
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup; never block the UI flow on this.
    }
  }

  @override
  void dispose() {
    _deleteAudioFile();
    super.dispose();
  }
}
