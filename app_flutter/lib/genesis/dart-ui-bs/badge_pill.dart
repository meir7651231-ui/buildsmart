// 🎨 חוט-תצוגה · BadgePill — תג-גלולה קטן עם נקודה (חוק-1/חוק-5).
// המנוע: גלולה עם נקודת-מבטא פועמת + תווית. אפס-דאטה —
// תווית · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class BadgePill extends StatefulWidget {
  const BadgePill({required this.label, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String label; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<BadgePill> createState() => _BadgePillState();
}
class _BadgePillState extends State<BadgePill> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Align(alignment: Alignment.centerRight, child: Container(
    height: widget.height, padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(widget.height),
      border: Border.all(color: widget.accentColor.withValues(alpha: 0.4))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _c, builder: (context, _) => Container(width: 8, height: 8,
        decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: 0.5 + 0.5 * _c.value), shape: BoxShape.circle))),
      const SizedBox(width: 8),
      Text(widget.label, style: TextStyle(color: widget.baseColor, fontSize: 13, fontWeight: FontWeight.w700)),
    ])));
}
