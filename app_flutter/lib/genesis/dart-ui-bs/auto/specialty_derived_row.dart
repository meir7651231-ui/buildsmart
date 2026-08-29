// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_profile_screen:_SpecialtyDerivedRow (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, label, fallback2
// התוכן: new/dart-data-bs/auto/screens__worker_profile_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class SpecialtyDerivedRow extends StatelessWidget {
  SpecialtyDerivedRow({required this.fallback, required this.label, required this.fallback2, required this.specialty});
  final String fallback;
  final String label;
  final String fallback2;

  final String specialty;

  @override
  Widget build(BuildContext context) {
    final has = specialty.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔧', style: TextStyle(fontSize: 16)),
              const SizedBox(width: BsTokens.space2),
              CfgText(
                'worker.profile.specialty_label',
                fallback,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  has ? specialty : label,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: has ? BsTokens.inkLight : BsTokens.mutedLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Honest pointer to the single source of truth (no second editor).
          CfgText(
            'worker_profile_screen.specialty_hint',
            fallback2,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
