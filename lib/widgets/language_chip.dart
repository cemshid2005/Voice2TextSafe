import 'package:flutter/material.dart';

import '../models/translation_language.dart';

class LanguageChip extends StatelessWidget {
  const LanguageChip({
    super.key,
    required this.language,
    required this.onPressed,
    this.loading = false,
  });

  final TranslationLanguage language;
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.translate, size: 18),
      label: Text(language.nativeName),
      onPressed: loading ? null : onPressed,
    );
  }
}
