// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__stock_screen:_StockRow (בנייה-חכמה main) · צרור-3 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__stock_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StockRow extends StatelessWidget {
  StockRow({required this.label, required this.label2, 
    required this.name,
    required this.info,
    required this.warehouse,
    required this.onMove,
  });
  final String label;
  final String label2;
  final String name;
  final ({String img, String why}) info;
  final bool warehouse;
  final VoidCallback onMove;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEAEAEA)),
    ),
    child: Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(info.img, style: const TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              if (info.why.isNotEmpty)
                Text(
                  info.why,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onMove,
          style: OutlinedButton.styleFrom(
            foregroundColor: BsTokens.brand,
            side: const BorderSide(color: BsTokens.brand),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(
            warehouse ? label : label2,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

const _ink = BsTokens.inkLight;

const _muted = Color(0xFF888888);
