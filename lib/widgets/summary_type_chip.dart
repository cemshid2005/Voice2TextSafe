import 'package:flutter/material.dart';

import '../models/summary_type.dart';

class SummaryTypeChip extends StatelessWidget {
  const SummaryTypeChip({
    super.key,
    required this.type,
    required this.onPressed,
    this.loading = false,
  });

  final SummaryType type;
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
          : const Icon(Icons.notes_outlined, size: 18),
      label: Text(type.label),
      onPressed: loading ? null : onPressed,
    );
  }
}
