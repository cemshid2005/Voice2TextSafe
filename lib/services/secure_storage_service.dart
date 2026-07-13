import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/ai_provider.dart';

/// Persists API keys using the cipher that flutter_secure_storage backs with
/// the Android Keystore (RSA-OAEP key wrapping + AES-GCM storage). Keys never
/// leave the device and are never logged.
///
/// Keys are stored per-provider so switching the active provider in Settings
/// does not discard a previously entered key for the other provider.
class SecureStorageService {
  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
        );

  final FlutterSecureStorage _storage;

  String _keyFor(AiProvider provider) => 'api_key_${provider.storageKey}';

  Future<String?> readApiKey(AiProvider provider) {
    return _storage.read(key: _keyFor(provider));
  }

  Future<void> writeApiKey(AiProvider provider, String apiKey) {
    return _storage.write(key: _keyFor(provider), value: apiKey.trim());
  }

  Future<void> deleteApiKey(AiProvider provider) {
    return _storage.delete(key: _keyFor(provider));
  }

  Future<bool> hasAnyApiKey() async {
    for (final provider in AiProvider.values) {
      final key = await readApiKey(provider);
      if (key != null && key.isNotEmpty) return true;
    }
    return false;
  }
}
