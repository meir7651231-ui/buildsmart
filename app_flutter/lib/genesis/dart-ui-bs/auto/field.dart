// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — מחובר-לחריץ (retrofit-תפר): קורא skin.* מ-DsSeam.
// מוצא: screens__budget_screen:_Field (בנייה-חכמה main) · צרור-3
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

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
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context); // מלוא-העיצוב מהחריץ (חוק-7)
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: skin.ink),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: skin.mut),
          errorText: validator?.call(value.text),
          filled: true,
          fillColor: skin.raised,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
