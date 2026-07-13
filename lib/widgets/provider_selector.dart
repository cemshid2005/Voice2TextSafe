import 'package:flutter/material.dart';

import '../models/ai_provider.dart';

class ProviderSelector extends StatelessWidget {
  const ProviderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final AiProvider selected;
  final ValueChanged<AiProvider> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AiProvider>(
      segments: AiProvider.values
          .map((provider) => ButtonSegment(value: provider, label: Text(provider.displayName)))
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
    );
  }
}
