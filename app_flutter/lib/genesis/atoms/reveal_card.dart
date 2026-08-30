// 🎨 חוט-תצוגה · RevealCard — כרטיס שנחשף בכניסה (סקייל+דהייה) (חוק-1/חוק-5).
// המנוע: כניסת scale+fade פעם-אחת (AnimationController easeOutBack). אפס-דאטה —
// כותרת · תת-כותרת · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class RevealCard extends StatefulWidget {
  const RevealCard({
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
  State<RevealCard> createState() => _RevealCardState();
}

class _RevealCardState extends State<RevealCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1).animate(anim),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.baseColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.sub,
                style: TextStyle(
                  color: widget.baseColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
