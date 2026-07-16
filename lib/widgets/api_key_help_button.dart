import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ai_provider.dart';

/// Help icon that opens a dialog explaining how to obtain an API key for
/// [provider], with a shortcut to open the provider's key-management page.
class ApiKeyHelpButton extends StatelessWidget {
  const ApiKeyHelpButton({super.key, required this.provider});

  final AiProvider provider;

  Future<void> _openPortal(BuildContext context) async {
    final uri = Uri.parse(provider.apiKeyPortalUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keçid açıla bilmədi: ${provider.apiKeyPortalUrl}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'API Key necə əldə edilir?',
      onPressed: () => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('${provider.displayName} API Key necə əldə edilir?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, step) in provider.apiKeyHelpSteps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text(step)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Bağla'),
            ),
            FilledButton.icon(
              onPressed: () => _openPortal(dialogContext),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Saytı aç'),
            ),
          ],
        ),
      ),
    );
  }
}
