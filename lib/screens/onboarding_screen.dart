import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/api_key_field.dart';
import '../widgets/provider_selector.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _apiKeyController = TextEditingController();
  AiProvider _selectedProvider = AiProvider.openai;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.length < 10) {
      setState(() => _error = 'API Key düzgün formatda deyil.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final settings = context.read<SettingsProvider>();
    await settings.setProvider(_selectedProvider);
    await settings.saveApiKey(apiKey);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.mic_none_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                'Voice2TextSafe-ə xoş gəlmisiniz',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Server yoxdur, database yoxdur, login yoxdur. Bütün sorğular '
                'birbaşa cihazınızdan seçdiyiniz AI provayderinə göndərilir və '
                'API Key yalnız cihazınızda, Android Keystore ilə şifrələnmiş '
                'şəkildə saxlanılır.',
              ),
              const SizedBox(height: 32),
              Text('AI Provider', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ProviderSelector(
                selected: _selectedProvider,
                onChanged: (provider) => setState(() => _selectedProvider = provider),
              ),
              const SizedBox(height: 24),
              Text('API Key', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ApiKeyField(controller: _apiKeyController),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Davam et'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
