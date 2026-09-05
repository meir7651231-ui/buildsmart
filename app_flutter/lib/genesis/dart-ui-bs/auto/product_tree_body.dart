// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_ProductTreeBody (בנייה-חכמה main) · צרור-3 · props-שורש: fallback, label, label2, text
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class ProductTreeBody extends StatelessWidget {
  ProductTreeBody({required this.fallback, required this.label, required this.label2, required this.text, 
    required this.categoryCount,
    required this.productCount,
  });
  final String fallback;
  final String label;
  final String label2;
  final String text;

  final int categoryCount;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CfgText(
          'manager_dashboard_screen.producttree_intro',
          fallback,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        _ManageRow(label: label, value: '$productCount'),
        _ManageRow(label: label2, value: '$categoryCount'),
        _ManageHint(
          text,
        ),
      ],
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: BsTokens.space3),
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageHint extends StatelessWidget {
  const _ManageHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.mutedLight,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }
}
