// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_Card (בנייה-חכמה main) · צרור-2 · מודל-שוטח: 3 שדות · props-שורש: fallback, label, label2, status, name, detail
// התוכן: new/dart-data-bs/auto/screens__tasks_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class TasksCard extends StatelessWidget {
  TasksCard({required this.fallback, required this.label, required this.label2, required this.status, required this.name, required this.detail,  required this.onTap, this.onEdit});
  final String fallback;
  final String label;
  final String label2;
  final String status;
  final String name;
  final String detail;
  final VoidCallback onTap;

  /// Wave T2a — optional ✏️ edit tap (contractor authoring). Null → no button.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          key: ValueKey('task-${id}'),
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F5),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill)),
                      child: Text(
                        kTaskStatusLabel[status] ?? '',
                        style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5),
                      ),
                    ),
                    const Spacer(),
                    // Wave T2a — ✏️ edit affordance (contractor authoring only).
                    if (onEdit != null)
                      // composite hide: whole ✏️ edit pill gone when the org hides this element
                      CfgVisible(
                        'tasks_screen.edit',
                        child: InkWell(
                          key: ValueKey('task-edit-${id}'),
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          onTap: onEdit,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: CfgText('tasks_screen.edit', fallback,
                                style: TextStyle(
                                    color: BsTokens.brandDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: BsTokens.space2),
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
                const SizedBox(height: BsTokens.space1),
                Text(
                  '👷 ${_wk(worker)} · 📋 ${steps.length}${label}${days}${label2}',
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _wk(int i) => kWorkers[(i >= 0 && i < kWorkers.length) ? i : 0];
