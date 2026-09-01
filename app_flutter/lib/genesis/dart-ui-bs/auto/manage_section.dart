// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_ManageSection (בנייה-חכמה main) · צרור-2 · props-שורש: title2, body, label
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ManageSection extends StatelessWidget {
  ManageSection({required this.title2, required this.body, required this.label, 
    required this.sectionKey,
    required this.titleCfgId,
    required this.emoji,
    required this.title,
    required this.sub,
    required this.open,
    required this.onTap,
    required this.child,
    this.badge = 0,
  });
  final String title2;
  final String body;
  final String label;

  final String sectionKey;

  /// Studio element id for the editable section title (mirrors [_MetricTile.cfgId]):
  /// empty doc ⇒ the literal [title] verbatim with the same style ⇒ golden-identical.
  final String titleCfgId;
  final String emoji;
  final String title;
  final String sub;
  final bool open;
  final VoidCallback onTap;
  final Widget child;

  /// Optional count badge next to the title (0 = no badge) — used by the
  /// 👷 אישורי עובדים section to surface how many tasks are awaiting approval.
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            label: '$emoji $title',
            // #31 — the shared accordion-section header (opens/closes a No-Code
            // management section); in help mode the HelpTarget rings + explains
            // it. One wrapper covers every section instance of ManageSection.
            child: HelpTarget(
              title: title2,
              body:
                  body,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(BsTokens.space4),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: BsTokens.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: CfgText(
                                      titleCfgId,
                                      title,
                                      style: const TextStyle(
                                        color: BsTokens.inkLight,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (badge > 0) ...[
                                    const SizedBox(width: BsTokens.space2),
                                    _CountBadge(count: badge, label: label),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sub,
                                style: const TextStyle(
                                  color: BsTokens.mutedLight,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: BsTokens.space2),
                        Text(
                          open ? '▾' : '‹',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              // Directional (start/top/end/bottom) so RTL/LTR both lay out
              // correctly (gate 62 — no hard-coded left/right edge inset).
              padding: const EdgeInsetsDirectional.fromSTEB(
                BsTokens.space4,
                0,
                BsTokens.space4,
                BsTokens.space4,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  _CountBadge({required this.label, required this.count});
  final String label;

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${label}$count',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(minWidth: 22),
        decoration: BoxDecoration(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
        child: Text(
          '$count',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: bsOnAccent(context),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
