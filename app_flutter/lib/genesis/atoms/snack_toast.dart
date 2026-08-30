// 🎨 חוט-תצוגה · SnackToast — חיווי-הצלחה מרחף (חוק-1/חוק-5).
// המנוע: פס-חיווי עם אייקון-וי שנכנס מלמטה וחוזר במחזור (AnimationController).
// אפס-דאטה — תווית · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class SnackToast extends StatefulWidget {
  const SnackToast({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String label;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<SnackToast> createState() => _SnackToastState();
}

class _SnackToastState extends State<SnackToast> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final v = _c.value;
            final show = v < 0.8 ? Curves.easeOut.transform((v / 0.15).clamp(0.0, 1.0)) : Curves.easeIn.transform(1 - (v - 0.8) / 0.2);
            return Opacity(
              opacity: show.clamp(0.0, 1.0),
              child: Transform.translate(offset: Offset(0, (1 - show) * 16), child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
              boxShadow: [BoxShadow(color: widget.accentColor.withValues(alpha: 0.2), blurRadius: 16)],
            ),
            child: Row(
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
                  child: Icon(Icons.check, size: 16, color: widget.fillColor),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.label, style: TextStyle(color: widget.baseColor, fontSize: 14, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
        ),
      );
}
