// 🎨 חוט-תצוגה · LinearProgress — סרגל-התקדמות מונפש עם אחוז (חוק-1/חוק-5).
// המנוע: פס-מילוי מטפס 0→pct בכניסה (AnimationController) + תווית-אחוז.
// תפר-דאטה (G21 · §20-ג): pct = האחוז האמיתי (0–100) מוזרק בחיווט — האטום לא ממציא ערך.
// עיצוב — גובה · צבע-מילוי/מסלול/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class LinearProgress extends StatefulWidget {
  const LinearProgress({required this.pct, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  /// האחוז האמיתי 0–100 (שקע-דאטה).
  final double pct;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<LinearProgress> createState() => _LinearProgressState();
}
class _LinearProgressState extends State<LinearProgress> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  @override void didUpdateWidget(LinearProgress old) { super.didUpdateWidget(old); if (old.pct != widget.pct) _c.forward(from: 0); }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: AnimatedBuilder(animation: _c, builder: (context, _) {
      final target = (widget.pct / 100).clamp(0.0, 1.0);
      final v = Curves.easeOut.transform(_c.value) * target;
      return Row(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Stack(children: [
          Container(height: 8, color: widget.baseColor.withValues(alpha: 0.15)),
          FractionallySizedBox(widthFactor: v, child: Container(height: 8,
            decoration: BoxDecoration(color: widget.accentColor,
              boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.5), blurRadius: 8)]))),
        ]))),
        const SizedBox(width: 12),
        SizedBox(width: 42, child: Text('${(v * 100).round()}%',
          textAlign: TextAlign.left, style: TextStyle(color: widget.baseColor, fontWeight: FontWeight.w800, fontSize: 13))),
      ]);
    }));
}
