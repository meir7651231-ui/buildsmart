// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__category_tree_editor:_CategoryTile (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 2 שדות · props-שורש: label, tooltip, emoji, titleHe
// התוכן: new/dart-data-bs/auto/screens__trade_builder__category_tree_editor_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class CategoryTile extends StatelessWidget {
  CategoryTile({required this.label, required this.tooltip, required this.emoji, required this.titleHe, 
    
    required this.onTap,
    required this.onDelete,});
  final String label;
  final String tooltip;
  final String emoji;
  final String titleHe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${emoji} ${titleHe}',
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        child: InkWell(
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              border: Border.all(color: const Color(0xFFEDEDED))),
            child: Row(
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
                  child: Text(
                    titleHe,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Semantics(
                  label: label,
                  button: true,
                  child: IconButton(
                    onPressed: onDelete,
                    // A real tooltip: a semantics label for screen-readers AND
                    // a long-press hint — independent of semantics-tree timing.
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
          ),
        ),
      ),
    );
  }
}
