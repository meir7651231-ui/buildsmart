// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_today_strip:_StageRow (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 1 שדות · props-שורש: title, body, label, title2, body2, label2, message, onTap, name
// התוכן: new/dart-data-bs/auto/screens__worker_today_strip_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'bs_tokens.dart';

class StageRow extends StatelessWidget {
  StageRow({required this.title, required this.body, required this.label, required this.title2, required this.body2, required this.label2, required this.message, required this.name, required this.onTap, 
    
    required this.tag,
    required this.emphasized,
    this.onMarkDone,});
  final String title;
  final String body;
  final String label;
  final String title2;
  final String body2;
  final String label2;
  final String message;
  final String name;
  final VoidCallback onTap;
  final String tag;
  final bool emphasized;
  final VoidCallback? onMarkDone;

  @override
  Widget build(BuildContext context) {
    final ink = emphasized ? BsTokens.inkLight : BsTokens.mutedLight;
    return Row(
      children: [
        Expanded(
          child: HelpTarget(
            title: title,
            body:
                body,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              // #71 reuse — the same detail sheet a task card opens (same id
              // space: both §6 and §7 are built from kPersonaTasks).
              onTap:
                  onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: BsTokens.space1),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            emphasized
                                ? const Color(0xFFFFF0E3)
                                : const Color(0xFFF2F3F5),
                        borderRadius: BorderRadius.circular(
                          BsTokens.radiusPill,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color:
                              emphasized
                                  ? BsTokens.brandDark
                                  : BsTokens.mutedLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ink,
                              fontWeight:
                                  emphasized
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            '${dayTag} · ${steps.length}${label}',
                            style: const TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (onMarkDone != null)
          HelpTarget(
            title: title2,
            body:
                body2,
            child: Semantics(
              button: true,
              label: label2,
              child: Tooltip(
                message: message,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onMarkDone,
                  // ≥48dp tap target (a11y).
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: BsTokens.brand,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
