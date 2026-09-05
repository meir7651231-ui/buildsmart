// 🧼 אטום · InfoStripRow — שורת-רצועה: ריבוע-גליף גווני + תווית: + ערך + שברון מסתובב.
// מוצא: screens__lipskey_product_sheet.dart:2345-2363 (_StripDef, שדות שטוחים כאן)
// + 2365-2446 (_StripRow/_StripRowState — מצב-לחיצה פנימי נשמר).
// icon גובר על emoji (עקיפת-canvaskit לגליפי-אינסטלציה, I1-followup במקור); label/value
// מוזרמים מ-content/מנועים דרך הקופסה (stripDefs); tint = פיגמנט פר-רצועה.
import 'package:flutter/material.dart';

class InfoStripRow extends StatefulWidget {
  const InfoStripRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.tint,
    required this.expanded,
    required this.onTap,
    required this.labelColor,
    required this.valueColor,
    this.icon,
    super.key,
  });
  final String emoji, label, value;
  final Color tint;
  final bool expanded;
  final VoidCallback onTap;
  final Color labelColor, valueColor;
  final IconData? icon;

  @override
  State<InfoStripRow> createState() => _InfoStripRowState();
}

class _InfoStripRowState extends State<InfoStripRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: w.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: w.expanded
            ? w.tint.withValues(alpha: 0.12)
            : (_pressed ? w.tint.withValues(alpha: 0.18) : Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: w.tint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: w.icon != null
                  ? Icon(w.icon, size: 16, color: w.tint)
                  : Text(w.emoji, style: const TextStyle(fontSize: 15)),
            ),
            const SizedBox(width: 10),
            Text(
              '${w.label}:',
              style: TextStyle(
                color: w.labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                w.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: w.valueColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            AnimatedRotation(
              turns: w.expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.chevron_left, size: 16, color: w.tint),
            ),
          ],
        ),
      ),
    );
  }
}
