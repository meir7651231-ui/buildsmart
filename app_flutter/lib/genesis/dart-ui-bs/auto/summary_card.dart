// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__store_screen:_SummaryCard (בנייה-חכמה main) · צרור-3 · props-שורש: label, label2, label3, label4, value, label5
// התוכן: new/dart-data-bs/auto/screens__store_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class SummaryCard extends StatelessWidget {
  SummaryCard({required this.label, required this.label2, required this.label3, required this.label4, required this.value, required this.label5, 
    required this.subtotal,
    required this.vat,
    required this.deliveryFee,
    required this.total,
    required this.vatInclusive,
  });
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String value;
  final String label5;

  final int subtotal;
  final int vat;
  final int deliveryFee;
  final int total;
  final bool vatInclusive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // When VAT is inclusive, show the net (pre-VAT) subtotal so the
          // lines add up to the total (net + VAT + delivery = total).
          _SummaryLine(
            label: vatInclusive ? label : label2,
            value: _price(vatInclusive ? subtotal - vat : subtotal),
          ),
          const SizedBox(height: 6),
          _SummaryLine(label: label3, value: _price(vat)),
          const SizedBox(height: 6),
          _SummaryLine(
            label: label4,
            value: deliveryFee == 0 ? value : _price(deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFF5F5F5), height: 1),
          ),
          _SummaryLine(label: label5, value: _price(total), bold: true),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style =
        bold
            ? const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            )
            : const TextStyle(color: Color(0xFF888888), fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}

String _price(int n) {
  if (n < 0) return '-${_price(-n)}';
  final s = n.toString();
  final b = StringBuffer('₪');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

/
