// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_profile_screen:_StatsCard (בנייה-חכמה main) · צרור-2 · props-שורש: fallback, label, label2, label3
// התוכן: new/dart-data-bs/auto/screens__worker_profile_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class StatsCard extends StatelessWidget {
  StatsCard({required this.fallback, required this.label, required this.label2, required this.label3, 
    required this.done,
    required this.inReview,
    required this.rejected,
    required this.total,
  });
  final String fallback;
  final String label;
  final String label2;
  final String label3;

  final int done;
  final int inReview;
  final int rejected;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CfgText(
                  'worker.profile.tasks_title',
                  fallback,
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '$done/$total',
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              _Stat(value: '$done', label: label),
              _Stat(value: '$inReview', label: label2),
              _Stat(value: '$rejected', label: label3),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
