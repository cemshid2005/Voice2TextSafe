import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/transcription_provider.dart';
import '../services/share_intent_service.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _shareIntentService = ShareIntentService();
  StreamSubscription<File?>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    _shareSubscription = _shareIntentService.sharedAudioStream.listen(_handleSharedAudio);
    _checkInitialSharedAudio();
  }

  Future<void> _checkInitialSharedAudio() async {
    final file = await _shareIntentService.getInitialSharedAudio();
    if (file != null) {
      _handleSharedAudio(file);
    }
  }

  Future<void> _handleSharedAudio(File? file) async {
    if (file == null || !mounted) return;

    final settings = context.read<SettingsProvider>();
    final apiKey = await settings.getApiKey();
    if (!mounted) return;

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zəhmət olmasa əvvəlcə Ayarlar bölməsindən API Key əlavə edin.'),
        ),
      );
      return;
    }

    final transcriptionProvider = context.read<TranscriptionProvider>();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResultScreen()));
    await transcriptionProvider.transcribe(
      audioFile: file,
      provider: settings.selectedProvider,
      apiKey: apiKey,
      autoTranslateTo: settings.defaultTranslationLanguage,
    );
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice2TextSafe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.share_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'WhatsApp və digər tətbiqlərdən audio mesajı paylaşarkən '
                '"Voice2TextSafe" seçin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Aktiv provayder: ${settings.selectedProvider.displayName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Text(
                'Audio serverdə saxlanılmır. Bütün proses cihazınızda, birbaşa '
                'seçdiyiniz AI provayderi ilə aparılır.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
