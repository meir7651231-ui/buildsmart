// 🧼 אטום · HopBreadcrumb — שביל-פירורים: אייקון-בית + פירורים נלחצים עם שברוני-הפרדה.
// מוצא: screens__lipskey_product_sheet.dart:655-699 (_hopBreadcrumb).
// התרת-סבך: HopStack (path/popTo/clear) ⇒ crumbLabels + onHomeTap (clear) +
// onCrumbTap(index) (popTo) — מחסנית-הקפיצות נשארת בקופסה.
import 'package:flutter/material.dart';

class HopBreadcrumb extends StatelessWidget {
  const HopBreadcrumb({
    required this.crumbLabels,
    required this.onHomeTap,
    required this.onCrumbTap,
    this.maxCrumbWidth = 90,
    super.key,
  });
  final List<String> crumbLabels;
  final VoidCallback onHomeTap;
  final void Function(int index) onCrumbTap;
  final double maxCrumbWidth;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            InkWell(
              onTap: onHomeTap,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.home_outlined, size: 14),
              ),
            ),
            for (var i = 0; i < crumbLabels.length; i++) ...[
              const Icon(Icons.chevron_left, size: 14),
              InkWell(
                onTap: () => onCrumbTap(i),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxCrumbWidth),
                  child: Text(
                    crumbLabels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == crumbLabels.length - 1
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}
