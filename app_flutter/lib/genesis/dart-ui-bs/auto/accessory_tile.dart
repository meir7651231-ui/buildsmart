// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__accessory_rule_editor:_AccessoryTile (בנייה-חכמה main) · צרור-4 · מודל-שוטח: 5 שדות · props-שורש: label, tooltip, price, mustHave, emoji, nameHe, whyHe, fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__accessory_rule_editor_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class AccessoryTile extends StatelessWidget {
  AccessoryTile({required this.label, required this.tooltip, required this.price, required this.mustHave, required this.emoji, required this.nameHe, required this.whyHe, required this.fallback,  required this.onDelete});
  final String label;
  final String tooltip;
  final int? price;
  final bool mustHave;
  final String emoji;
  final String nameHe;
  final String whyHe;
  final String fallback;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    late final price = price;
    late final hasPills = mustHave || price != null;
    return Semantics(
      label: '${emoji} ${nameHe}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BsTokens.brand.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameHe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (whyHe.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          whyHe,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Semantics(
                  label: label,
                  button: true,
                  child: IconButton(
                    onPressed: onDelete,
                    // A real tooltip: a semantics label for screen-readers
                    // AND a long-press hint — independent of semantics-tree
                    // timing.
                    tooltip: tooltip,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: BsTokens.mutedLight,
                    ),
                  ),
                ),
              ],
            ),
            if (hasPills) ...[
              const SizedBox(height: BsTokens.space3),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // Plan addition-B: mustHave marked visually distinct
                  // (חובה vs מומלץ) — parity to SmartAcc.must.
                  if (mustHave) _MustChip(fallback: fallback),
                  if (price != null) _PriceChip(price: price),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MustChip extends StatelessWidget {
  _MustChip({required this.fallback});
  final String fallback;

  @override
  Widget build(BuildContext context) {
    // composite hide: whole 'חובה' chip gone when the org hides this element
    return CfgVisible(
      'accessory_rule_editor.t06',
      child: Chip(
        label: CfgText(
          'accessory_rule_editor.t06',
          fallback,
          style: TextStyle(
            color: _kMustColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: _kMustColor.withValues(alpha: 0.12),
        side: BorderSide.none,
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '₪$price',
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: const BorderSide(color: Color(0xFFEDEDED)),
    );
  }
}

const Color _kMustColor = Color(0xFFB45309);
