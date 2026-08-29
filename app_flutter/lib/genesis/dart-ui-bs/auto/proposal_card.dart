// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_ProposalCard (בנייה-חכמה main) · צרור-2 · props-שורש: label, fallback, label2
// התוכן: new/dart-data-bs/auto/screens__tasks_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ProposalCard extends StatelessWidget {
  ProposalCard({required this.label, required this.fallback, required this.label2, 
    required this.id,
    required this.name,
    required this.detail,
    required this.workerLabel,
    required this.days,
    required this.onApprove,
    required this.onReject,
    super.key,
  });
  final String label;
  final String fallback;
  final String label2;
  final int id;
  final String name;
  final String detail;
  final String workerLabel;
  final int days;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          elevation: 1,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail,
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12.5)),
                ],
                const SizedBox(height: 2),
                Text('👷 $workerLabel · ⏱️ $days${label}',
                    style: const TextStyle(
                        color: BsTokens.mutedLight, fontSize: 12.5)),
                const SizedBox(height: BsTokens.space3),
                Row(children: [
                  Expanded(
                    // composite hide: whole reject button gone when the org hides this element
                    child: CfgVisible(
                      'tasks_screen.proposal_reject',
                      child: OutlinedButton(
                        key: ValueKey('proposal-reject-$id'),
                        onPressed: onReject,
                        child: CfgText('tasks_screen.proposal_reject', fallback),
                      ),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: _PrimaryBtn(
                      key: ValueKey('proposal-approve-$id'),
                      label: label2,
                      onTap: onApprove,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, super.key});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: bsOnAccent(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
        ),
      );
}
