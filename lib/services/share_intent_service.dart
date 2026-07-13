import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Bridges the Android Share Intent (`ACTION_SEND` / `ACTION_SEND_MULTIPLE`
/// with `audio/*`) to a plain [File] the rest of the app works with.
///
/// Shared files are copied into a dedicated, prefixed cache location so they
/// can be reliably identified and cleaned up later (see [clearCache] and
/// `TranscriptionProvider`) without touching files owned by other apps.
class ShareIntentService {
  static const String cachePrefix = 'v2ts_audio_';

  static const List<String> _audioExtensions = [
    '.mp3', '.wav', '.m4a', '.aac', '.ogg', '.oga', '.opus', '.flac', '.wma', '.3gp', '.amr',
  ];

  final ReceiveSharingIntent _receiveSharingIntent = ReceiveSharingIntent.instance;

  /// Audio shared while the app was closed (cold start).
  Future<File?> getInitialSharedAudio() async {
    final files = await _receiveSharingIntent.getInitialMedia();
    final audio = await _firstAudioFile(files);
    await _receiveSharingIntent.reset();
    return audio;
  }

  /// Audio shared while the app is already running (hot start).
  Stream<File?> get sharedAudioStream {
    return _receiveSharingIntent.getMediaStream().asyncMap(_firstAudioFile);
  }

  Future<File?> _firstAudioFile(List<SharedMediaFile> files) async {
    for (final file in files) {
      if (_looksLikeAudio(file)) {
        return _copyToCache(File(file.path));
      }
    }
    return null;
  }

  bool _looksLikeAudio(SharedMediaFile file) {
    final mimeType = file.mimeType?.toLowerCase();
    if (mimeType != null && mimeType.startsWith('audio/')) return true;

    final path = file.path.toLowerCase();
    return _audioExtensions.any(path.endsWith);
  }

  Future<File> _copyToCache(File source) async {
    final cacheDir = await getTemporaryDirectory();
    final dotIndex = source.path.lastIndexOf('.');
    final extension = dotIndex != -1 ? source.path.substring(dotIndex) : '';
    final fileName = '$cachePrefix${DateTime.now().microsecondsSinceEpoch}$extension';
    final destinationPath = '${cacheDir.path}${Platform.pathSeparator}$fileName';
    return source.copy(destinationPath);
  }

  /// Deletes any cached audio left behind by a previous, possibly abnormally
  /// terminated session. Safe to call at app startup; only ever touches
  /// files with [cachePrefix] inside the app's own cache directory.
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      for (final entry in cacheDir.listSync()) {
        if (entry is File && entry.uri.pathSegments.last.startsWith(cachePrefix)) {
          await entry.delete();
        }
      }
    } catch (_) {
      // Best-effort cleanup only; never block app startup on this.
    }
  }
}
