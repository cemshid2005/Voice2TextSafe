import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/ai_provider.dart';
import '../models/summary_type.dart';
import '../models/transcription_result.dart';
import '../models/translation_language.dart';
import '../services/ai/ai_service_factory.dart';
import '../utils/error_mapper.dart';

enum TranscriptionStatus { idle, loading, success, error }

/// Owns the lifecycle of a single "share -> transcribe -> translate /
/// summarize" flow.
///
/// This is a single app-wide instance shared by every screen, so every
/// mutating operation is guarded by a monotonically increasing [_requestId]:
/// each `transcribe()` call captures the id current at its start, and only
/// applies its outcome if that id is still the latest one when it completes.
/// A share that arrives while a previous one is still in flight therefore
/// always wins cleanly - the older call's eventual result (success, error,
/// or a broken read because its file was cleaned up) is silently discarded
/// instead of clobbering the newer, currently-visible state.
///
/// The same guard is used for `translate()` / `summarize()`, so a
/// translation/summary started against an older transcript can never get
/// attached after a newer share has replaced it.
class TranscriptionProvider extends ChangeNotifier {
  File? _audioFile;
  TranscriptionStatus _status = TranscriptionStatus.idle;
  TranscriptionResult? _result;
  String? _errorMessage;
  int _requestId = 0;

  final Set<TranslationLanguage> _translatingLanguages = {};
  final Set<SummaryType> _summarizingTypes = {};

  TranscriptionStatus get status => _status;
  TranscriptionResult? get result => _result;
  String? get errorMessage => _errorMessage;
  Set<TranslationLanguage> get translatingLanguages => _translatingLanguages;
  Set<SummaryType> get summarizingTypes => _summarizingTypes;

  bool isTranslating(TranslationLanguage language) => _translatingLanguages.contains(language);
  bool isSummarizing(SummaryType type) => _summarizingTypes.contains(type);

  Future<void> transcribe({
    required File audioFile,
    required AiProvider provider,
    required String apiKey,
    TranslationLanguage? autoTranslateTo,
  }) async {
    final requestId = ++_requestId;
    final previousFile = _audioFile;

    _audioFile = audioFile;
    _status = TranscriptionStatus.loading;
    _errorMessage = null;
    _result = null;
    _translatingLanguages.clear();
    _summarizingTypes.clear();
    notifyListeners();

    try {
      _validateFileSize(audioFile);
      final service = AiServiceFactory.create(provider, apiKey);
      final transcript = await service.transcribe(audioFile);

      if (requestId != _requestId) {
        // A newer share superseded us while we were transcribing - this
        // file is now orphaned, clean it up and discard our result.
        await _safeDelete(audioFile);
        return;
      }

      _result = TranscriptionResult(
        sourceFileName: _fileNameOf(audioFile),
        transcript: transcript,
      );
      _status = TranscriptionStatus.success;
      // Only now, once we know we're still current, is it safe to retire
      // the previous file - any older in-flight request still reading it
      // will simply detect it has been superseded and no-op.
      await _safeDelete(previousFile, exceptPath: audioFile.path);
      notifyListeners();

      if (autoTranslateTo != null) {
        await translate(language: autoTranslateTo, provider: provider, apiKey: apiKey);
      }
    } catch (error) {
      if (requestId != _requestId) {
        await _safeDelete(audioFile);
        return;
      }
      await _safeDelete(previousFile, exceptPath: audioFile.path);
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
    final requestId = _requestId;
    final currentResult = _result;
    if (currentResult == null) return;

    _translatingLanguages.add(language);
    notifyListeners();

    try {
      final service = AiServiceFactory.create(provider, apiKey);
      final translated = await service.translate(currentResult.transcript, language);
      if (requestId != _requestId) return; // superseded by a newer share

      final latest = _result ?? currentResult;
      _result = latest.copyWithTranslation(language, translated);
    } catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = ErrorMapper.map(error).message;
    } finally {
      if (requestId == _requestId) {
        _translatingLanguages.remove(language);
        notifyListeners();
      }
    }
  }

  Future<void> summarize({
    required SummaryType type,
    required AiProvider provider,
    required String apiKey,
  }) async {
    final requestId = _requestId;
    final currentResult = _result;
    if (currentResult == null) return;

    _summarizingTypes.add(type);
    notifyListeners();

    try {
      final service = AiServiceFactory.create(provider, apiKey);
      final summary = await service.summarize(currentResult.transcript, type);
      if (requestId != _requestId) return; // superseded by a newer share

      final latest = _result ?? currentResult;
      _result = latest.copyWithSummary(type, summary);
    } catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = ErrorMapper.map(error).message;
    } finally {
      if (requestId == _requestId) {
        _summarizingTypes.remove(type);
        notifyListeners();
      }
    }
  }

  /// Clears in-memory state and deletes the cached audio file. Call this
  /// when the user leaves the result flow (e.g. navigates back to Home).
  Future<void> clearCurrentAudio() async {
    _requestId++; // invalidate any request still in flight for this session
    await _safeDelete(_audioFile);
    _audioFile = null;
    _status = TranscriptionStatus.idle;
    _result = null;
    _errorMessage = null;
    _translatingLanguages.clear();
    _summarizingTypes.clear();
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

  Future<void> _safeDelete(File? file, {String? exceptPath}) async {
    if (file == null || file.path == exceptPath) return;
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup; never let this affect the visible UI flow.
    }
  }

  @override
  void dispose() {
    _safeDelete(_audioFile);
    super.dispose();
  }
}
