// 🎨 חוט-תצוגה · SkeletonCard — כרטיס-שלד עם גל-ריצוד (חוק-1/חוק-5).
// המנוע: עיגול-אווטאר + שורות-שלד עם פס-הבהקה נע (AnimationController). אפס-דאטה —
// גובה · צבע-בסיס/הבהקה/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class SkeletonCard extends StatefulWidget {
  const SkeletonCard({required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<SkeletonCard> createState() => _SkeletonCardState();
}
class _SkeletonCardState extends State<SkeletonCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  Widget _bar(double wf, double h) => FractionallySizedBox(widthFactor: wf, alignment: Alignment.centerRight,
    child: AnimatedBuilder(animation: _c, builder: (context, _) {
      final x = ((_c.value * 2) - 1);
      return Container(height: h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(begin: Alignment(x - 1, 0), end: Alignment(x + 1, 0),
          colors: [widget.baseColor.withValues(alpha: 0.12), widget.accentColor.withValues(alpha: 0.35), widget.baseColor.withValues(alpha: 0.12)])));
    }));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedBuilder(animation: _c, builder: (context, _) => Container(width: 48, height: 48,
        decoration: BoxDecoration(color: widget.baseColor.withValues(alpha: 0.12 + 0.1 * _c.value), shape: BoxShape.circle))),
      const SizedBox(width: 14),
      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _bar(1, 12), const SizedBox(height: 10), _bar(0.7, 10), const SizedBox(height: 10), _bar(0.45, 10),
      ])),
    ]));
}
