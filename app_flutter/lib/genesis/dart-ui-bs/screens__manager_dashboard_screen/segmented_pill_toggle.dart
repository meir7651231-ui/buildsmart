// 🧼 אטום · SegmentedPillToggle — מתג-גלולות עליון (emoji+תווית פר-טאב).
// מוצא: _ManagerToggle. התרת-סבך: managerTabProvider (קריאה+כתיבה) ⇒
// activeIndex+onSelect; orgConfigProvider/kIntelLive ⇒ הקופסה קובעת את items;
// עטיפת-HelpTarget פר-גלולה (#31) ⇒ סלוט wrapPill של הקופסה.
import 'package:flutter/material.dart';

class SegmentedPillToggle extends StatelessWidget {
  const SegmentedPillToggle({
    required this.items, required this.activeIndex, required this.onSelect,
    required this.surfaceColor, required this.activeFillColor,
    required this.activeTextColor, required this.inkColor,
    required this.pillRadius, required this.halfGap, required this.rowPadding,
    this.wrapPill, super.key,
  });

  final List<({String emoji, String label})> items;
  final int activeIndex;
  final void Function(int index) onSelect;
  final Color surfaceColor, activeFillColor, activeTextColor, inkColor;
  final double pillRadius;

  /// BsTokens.space2 / 2 במקור — חצי-רווח על כל שפה פנימית.
  final double halfGap;

  /// EdgeInsetsDirectional.fromSTEB(space3, space2, space3, space3) במקור.
  final EdgeInsetsGeometry rowPadding;

  /// סלוט-קופסה: עטיפת כל גלולה (למשל בעזרת-#31) לפי אינדקס.
  final Widget Function(int index, Widget pill)? wrapPill;

  @override
  Widget build(BuildContext context) {
    Widget seg(int i, String emoji, String label) {
      final on = activeIndex == i;
      final pill = Material(
        color: on ? activeFillColor : surfaceColor,
        borderRadius: BorderRadius.circular(pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(pillRadius),
          onTap: () => onSelect(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: on ? activeTextColor : inkColor,
                      fontSize: 13.5,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: i == 0 ? 0 : halfGap,
            end: i == items.length - 1 ? 0 : halfGap,
          ),
          child: wrapPill == null ? pill : wrapPill!(i, pill),
        ),
      );
    }

    return Container(
      color: surfaceColor,
      padding: rowPadding,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            seg(i, items[i].emoji, items[i].label),
        ],
      ),
    );
  }
}
