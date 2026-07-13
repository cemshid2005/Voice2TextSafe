import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/translation_language.dart';
import '../providers/settings_provider.dart';
import '../widgets/api_key_field.dart';
import '../widgets/provider_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _saving = false;
  String? _message;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey(SettingsProvider settings) async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.length < 10) {
      setState(() => _message = 'API Key düzgün formatda deyil.');
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    await settings.saveApiKey(apiKey);
    _apiKeyController.clear();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = 'API Key yadda saxlanıldı.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('AI Provider', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ProviderSelector(
              selected: settings.selectedProvider,
              onChanged: (provider) => settings.setProvider(provider),
            ),
            const SizedBox(height: 24),
            Text('API Key', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              settings.hasApiKeyForSelectedProvider
                  ? '${settings.selectedProvider.displayName} üçün API Key təyin olunub.'
                  : '${settings.selectedProvider.displayName} üçün API Key təyin olunmayıb.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ApiKeyField(controller: _apiKeyController, labelText: 'Yeni API Key'),
            if (_message != null) ...[
              const SizedBox(height: 8),
              Text(_message!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _saving ? null : () => _saveApiKey(settings),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Saxla'),
              ),
            ),
            const Divider(height: 32),
            Text('Default tərcümə dili', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'İstəyə bağlı: transkripsiya bitdikdən sonra bu dilə avtomatik tərcümə ediləcək.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Yoxdur'),
                  selected: settings.defaultTranslationLanguage == null,
                  onSelected: (_) => settings.setDefaultTranslationLanguage(null),
                ),
                ...TranslationLanguage.values.map((language) {
                  return ChoiceChip(
                    label: Text(language.nativeName),
                    selected: settings.defaultTranslationLanguage == language,
                    onSelected: (_) => settings.setDefaultTranslationLanguage(language),
                  );
                }),
              ],
            ),
            const Divider(height: 32),
            Text('Görünüş', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (mode) => settings.setThemeMode(mode!),
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(title: Text('Sistem'), value: ThemeMode.system),
                  RadioListTile<ThemeMode>(title: Text('İşıqlı'), value: ThemeMode.light),
                  RadioListTile<ThemeMode>(title: Text('Qaranlıq'), value: ThemeMode.dark),
                ],
              ),
            ),
            const Divider(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Məxfilik: Audio və mətn heç vaxt serverdə saxlanılmır. API Key '
                'yalnız bu cihazda, Android Keystore ilə şifrələnmiş şəkildə '
                'saxlanılır. Tətbiq heç bir analitika və ya istifadəçi məlumatı '
                'toplamır.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
