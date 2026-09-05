// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_reports_tab:_KpiBox (בנייה-חכמה main) · צרור-1 · props-שורש: label2
// התוכן: new/dart-data-bs/auto/screens__worker_reports_tab_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class KpiBox extends StatelessWidget {
  KpiBox({required this.label2, required this.value, required this.label, this.onTap});
  final String label2;

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inner = Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:
            onTap == null
                ? inner
                : Semantics(
                  button: true,
                  label: '$label${label2}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                      onTap: onTap,
                      child: inner,
                    ),
                  ),
                ),
      ),
    );
  }
}
