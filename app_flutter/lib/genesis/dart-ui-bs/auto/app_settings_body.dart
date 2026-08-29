// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_AppSettingsBody (בנייה-חכמה main) · צרור-4 · props-שורש: label, label2, label3, text, text2
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/state/catalog_settings.dart';

class AppSettingsBody extends StatelessWidget {
  AppSettingsBody({required this.label, required this.label2, required this.label3, required this.text, required this.text2});
  final String label;
  final String label2;
  final String label3;
  final String text;
  final String text2;

  /// @legacy index.html:11961 `let EXPRESS_FEE=80;` — corrected to 120 to
  /// match `deliveryFeeFor(CartDelivery.express)` in store_screen.dart.
  static const int _expressFee = 120;

  /// @legacy index.html:11963 `let creditLimit=50000;` (rendered toLocaleString).
  static const int _creditLimit = 50000;

  /// @legacy index.html:11941 `const VAT_RATE = 0.18;` → 18%. Derived from the
  /// single-source [kVatRate] so the manager's displayed rate can't drift from
  /// the catalog browse price / cart charge.
  static int get _vatPercent => (kVatRate * 100).round();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ManageRow(label: label, value: '₪$_expressFee'),
        _ManageRow(
          label: label2,
          value: '₪${_grouped(_creditLimit)}',
        ),
        _ManageRow(label: label3, value: '$_vatPercent%'),
        _ManageHint(
          '${text}$_vatPercent${text2}',
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

String _grouped(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
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
