import 'package:flutter/material.dart';

/// Masked text field for entering an API key. Never logs or persists
/// anything by itself - the caller decides what to do with the value.
class ApiKeyField extends StatefulWidget {
  const ApiKeyField({
    super.key,
    required this.controller,
    this.labelText = 'API Key',
  });

  final TextEditingController controller;
  final String labelText;

  @override
  State<ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<ApiKeyField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}
