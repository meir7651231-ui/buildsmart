// 🎨 חוט-תצוגה · LiveStatusDot — נקודת-סטטוס פועמת עם תווית (חוק-1/חוק-5).
// המנוע: נקודה עם הילת-פעימה מתפשטת (AnimationController) + תווית. אפס-דאטה —
// תווית · גובה · צבע-נקודה/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class LiveStatusDot extends StatefulWidget {
  const LiveStatusDot({required this.label, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String label; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<LiveStatusDot> createState() => _LiveStatusDotState();
}
class _LiveStatusDotState extends State<LiveStatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: Row(children: [
      SizedBox(width: 16, height: 16, child: AnimatedBuilder(animation: _c, builder: (context, _) => Stack(alignment: Alignment.center, children: [
        Container(width: 16 * (0.5 + _c.value * 0.5), height: 16 * (0.5 + _c.value * 0.5),
          decoration: BoxDecoration(color: widget.accentColor.withValues(alpha: (1 - _c.value) * 0.5), shape: BoxShape.circle)),
        Container(width: 9, height: 9, decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle)),
      ]))),
      const SizedBox(width: 10),
      Text(widget.label, style: TextStyle(color: widget.baseColor, fontSize: 14, fontWeight: FontWeight.w600)),
    ]));
}
