// ✨ ElevatedCard — כרטיס-כהה עם ראמפת-צל-עמוקה כפולה ותאורת-קצה עדינה; מקבל child כתוכן
import 'package:flutter/material.dart';

class ElevatedCard extends StatelessWidget {
  const ElevatedCard({super.key, required this.child});

  final Widget child;

  static const Color _surface = Color(0xFF101127);
  static const Color _surfaceLow = Color(0xFF0B0B1A);
  static const Color _edge = Color(0x22FFFFFF);
  static const Color _shadowDeep = Color(0x99000000);
  static const Color _shadowMid = Color(0x4D000000);
  static const Color _ambient = Color(0x1A7C3AED);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_surface, _surfaceLow],
          ),
          border: Border.all(color: _edge, width: 1),
          boxShadow: const [
            BoxShadow(color: _shadowDeep, blurRadius: 40, offset: Offset(0, 24)),
            BoxShadow(color: _shadowMid, blurRadius: 16, offset: Offset(0, 8)),
            BoxShadow(color: _ambient, blurRadius: 50, spreadRadius: -12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: child,
        ),
      ),
    );
  }
}
