// 🎨 חוט-תצוגה · StepFlow — פס-שלבים שמתקדם אוטומטית (חוק-1/חוק-5).
// המנוע: N עיגולי-שלב + מחברים; השלב-הפעיל מתקדם במחזור (AnimationController).
// אפס-דאטה — גובה · מספר-שלבים · צבע-פעיל/כבוי/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class StepFlow extends StatefulWidget {
  const StepFlow({
    required this.height,
    required this.steps,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height;
  final int steps;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<StepFlow> createState() => _StepFlowState();
}

class _StepFlowState extends State<StepFlow> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = widget.steps < 1 ? 1 : widget.steps;
    final d = widget.height.clamp(24.0, 44.0);
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final active = (_c.value * n).floor().clamp(0, n - 1);
          return Row(
            children: [
              for (var i = 0; i < n; i++) ...[
                Container(
                  width: d, height: d,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i <= active ? widget.accentColor : widget.fillColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.accentColor.withValues(alpha: i <= active ? 1 : 0.4)),
                  ),
                  child: Text('${i + 1}',
                      style: TextStyle(color: i <= active ? widget.fillColor : widget.baseColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w800, fontSize: d * 0.4)),
                ),
                if (i < n - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i < active ? widget.accentColor : widget.baseColor.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
