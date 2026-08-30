// 🎨 חוט-תצוגה · SlideSheet — גיליון-תחתית שנכנס מלמטה (חוק-1/חוק-5).
// המנוע: כרטיס עם ידית-אחיזה שמחליק+מתמוסס פנימה (AnimationController). אפס-דאטה —
// כותרת · תת-כותרת · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class SlideSheet extends StatefulWidget {
  const SlideSheet({
    required this.title,
    required this.sub,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String title, sub;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<SlideSheet> createState() => _SlideSheetState();
}

class _SlideSheetState extends State<SlideSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim),
      child: FadeTransition(
        opacity: anim,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(widget.radius * 1.6)),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42, height: 5,
                  decoration: BoxDecoration(
                    color: widget.baseColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(widget.title, style: TextStyle(color: widget.baseColor, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(widget.sub, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.7), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
