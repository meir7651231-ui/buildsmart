// 🎨 חוט-תצוגה · GlassCard — כרטיס-זכוכית מטושטש עם כניסה מונפשת (חוק-1/חוק-5).
// המנוע: BackdropFilter (טשטוש-רקע) + כניסת fade+slide פעם-אחת. אפס-דאטה —
// כותרת · תת-כותרת · גובה · צבע-גוון/טקסט/רקע מוזרקים בחיווט.
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({
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
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.35),
                ),
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
        ),
      ),
    );
  }
}
