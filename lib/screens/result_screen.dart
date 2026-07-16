import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/summary_type.dart';
import '../models/transcription_result.dart';
import '../models/translation_language.dart';
import '../providers/settings_provider.dart';
import '../providers/transcription_provider.dart';
import '../widgets/language_chip.dart';
import '../widgets/summary_type_chip.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mətn kopyalandı')),
      );
    }
  }

  Future<void> _share(String text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _retranscribe(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final transcription = context.read<TranscriptionProvider>();
    final apiKey = await settings.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return;
    await transcription.retranscribe(provider: settings.selectedProvider, apiKey: apiKey);
  }

  Future<void> _translate(BuildContext context, TranslationLanguage language) async {
    final settings = context.read<SettingsProvider>();
    final transcription = context.read<TranscriptionProvider>();
    final apiKey = await settings.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return;
    await transcription.translate(
      language: language,
      provider: settings.selectedProvider,
      apiKey: apiKey,
    );
  }

  Future<void> _summarize(BuildContext context, SummaryType type) async {
    final settings = context.read<SettingsProvider>();
    final transcription = context.read<TranscriptionProvider>();
    final apiKey = await settings.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return;
    await transcription.summarize(
      type: type,
      provider: settings.selectedProvider,
      apiKey: apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transcription = context.watch<TranscriptionProvider>();
    final settings = context.watch<SettingsProvider>();
    final status = transcription.status;
    final result = transcription.result;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<TranscriptionProvider>().clearCurrentAudio();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nəticə')),
        body: SafeArea(
          child: switch (status) {
            TranscriptionStatus.error => _ErrorView(
                message: transcription.errorMessage ?? 'Naməlum xəta baş verdi.',
                onRetry: () => _retranscribe(context),
              ),
            TranscriptionStatus.success when result != null => _ResultView(
                result: result,
                enabledLanguages: TranslationLanguage.values
                    .where(settings.enabledTranslationLanguages.contains)
                    .toList(),
                translatingLanguages: transcription.translatingLanguages,
                summarizingTypes: transcription.summarizingTypes,
                onCopy: (text) => _copy(context, text),
                onShare: _share,
                onRetranscribe: () => _retranscribe(context),
                onTranslate: (language) => _translate(context, language),
                onSummarize: (type) => _summarize(context, type),
              ),
            _ => const _LoadingView(),
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Transkripsiya edilir...'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenidən cəhd et'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.enabledLanguages,
    required this.translatingLanguages,
    required this.summarizingTypes,
    required this.onCopy,
    required this.onShare,
    required this.onRetranscribe,
    required this.onTranslate,
    required this.onSummarize,
  });

  final TranscriptionResult result;
  final List<TranslationLanguage> enabledLanguages;
  final Set<TranslationLanguage> translatingLanguages;
  final Set<SummaryType> summarizingTypes;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onShare;
  final VoidCallback onRetranscribe;
  final ValueChanged<TranslationLanguage> onTranslate;
  final ValueChanged<SummaryType> onSummarize;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transkripsiya', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(result.transcript),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => onCopy(result.transcript),
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copy'),
            ),
            OutlinedButton.icon(
              onPressed: () => onShare(result.transcript),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share'),
            ),
            OutlinedButton.icon(
              onPressed: onRetranscribe,
              icon: const Icon(Icons.refresh),
              label: const Text('Yenidən transkripsiya et'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Xülasə', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SummaryType.values.map((type) {
            return SummaryTypeChip(
              type: type,
              loading: summarizingTypes.contains(type),
              onPressed: () => onSummarize(type),
            );
          }).toList(),
        ),
        if (result.summaries.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...result.summaries.entries.map((entry) {
            return _ResultCard(
              title: entry.key.label,
              text: entry.value,
              onCopy: () => onCopy(entry.value),
              onShare: () => onShare(entry.value),
            );
          }),
        ],
        const SizedBox(height: 24),
        Text('Tərcümə et', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: enabledLanguages.map((language) {
            return LanguageChip(
              language: language,
              loading: translatingLanguages.contains(language),
              onPressed: () => onTranslate(language),
            );
          }).toList(),
        ),
        if (result.translations.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...result.translations.entries.map((entry) {
            return _ResultCard(
              title: entry.key.nativeName,
              text: entry.value,
              onCopy: () => onCopy(entry.value),
              onShare: () => onShare(entry.value),
            );
          }),
        ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.text,
    required this.onCopy,
    required this.onShare,
  });

  final String title;
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_outlined, size: 18),
                        tooltip: 'Copy',
                        onPressed: onCopy,
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        tooltip: 'Share',
                        onPressed: onShare,
                      ),
                    ],
                  ),
                ],
              ),
              SelectableText(text),
            ],
          ),
        ),
      ),
    );
  }
}
