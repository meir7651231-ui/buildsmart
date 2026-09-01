// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__budget_screen:_Field (בנייה-חכמה main) · צרור-3
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class Field extends StatelessWidget {
  const Field(
      {required this.label,
      required this.controller,
      this.number = true,
      this.validator});
  final String label;
  final TextEditingController controller;
  final bool number;

  /// task #64: optional live format check — short Hebrew error or null.
  final String? Function(String value)? validator;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: _ink),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: _muted),
            errorText: validator?.call(value.text),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      );
}

const _ink = BsTokens.inkLight;

const _muted = Color(0xFF888888);
