// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__budget_screen:_NumBox (בנייה-חכמה main) · צרור-3
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class NumBox extends StatelessWidget {
  const NumBox(
      {required this.value,
      required this.label,
      required this.onTap,
      this.color = _ink});
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ),
          ),
        ),
      );
}

const _ink = BsTokens.inkLight;

const _muted = Color(0xFF888888);
