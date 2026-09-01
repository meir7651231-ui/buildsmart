// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__product_authoring_screen:_ProductTile (בנייה-חכמה main) · צרור-2 · מודל-שוטח: 2 שדות · props-שורש: label, tooltip, nameHe, id
// התוכן: new/dart-data-bs/auto/screens__trade_builder__product_authoring_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ProductTile extends StatelessWidget {
  ProductTile({required this.label, required this.tooltip, required this.nameHe, required this.id, 
    
    required this.categoryTitle,
    required this.onDelete,});
  final String label;
  final String tooltip;
  final String nameHe;
  final String id;
  final String categoryTitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$_kProductEmoji ${nameHe}',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
              child: const Text(
                _kProductEmoji,
                style: TextStyle(fontSize: 20),
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
                  const SizedBox(height: 2),
                  Text(
                    id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                  if (categoryTitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      categoryTitle,
                      maxLines: 1,
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
    );
  }
}

const String _kProductEmoji = '📦';
