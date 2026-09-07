// 🎨 חוט-תצוגה · MiniCalendar — לוח-חודש מוקטן עם היום המודגש (חוק-1/חוק-5).
// המנוע: רשת 7×5, ימים-מסומנים מהדאטה, "היום" בהילה פועמת (AnimationController).
// תפר-דאטה (G21 · §20-ג): today = תא-היום (0–34) · marked = תאי-הימים-המסומנים — מוזרקים בחיווט, לא מומצאים.
// עיצוב — גובה · צבע-היום/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class MiniCalendar extends StatefulWidget {
  const MiniCalendar({
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    required this.today,
    required this.marked,
    super.key,
  });
  /// תא-היום ברשת 7×5 (שקע-דאטה).
  final int today;
  /// תאי-הימים-המסומנים (שקע-דאטה).
  final Set<int> marked;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2),
            itemCount: 35,
            itemBuilder: (context, i) {
              final today = i == widget.today;
              final marked = widget.marked.contains(i);
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: today ? widget.accentColor.withValues(alpha: 0.4 + 0.5 * _c.value) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: today ? widget.fillColor : (marked ? widget.accentColor : widget.baseColor.withValues(alpha: 0.35)),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ),
      );
}
