// ✨ NeonCard — כרטיס עם טבעת-גרדיאנט-ניאון זוהרת סביב גוף כהה; מקבל child כתוכן
import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({super.key, required this.child});

  final Widget child;

  static const Color _bg = Color(0xFF0B0B18);
  static const Color _ringA = Color(0xFF7C3AED);
  static const Color _ringB = Color(0xFFEC4899);
  static const Color _ringC = Color(0xFF22D3EE);
  static const Color _glowPurple = Color(0x557C3AED);
  static const Color _glowCyan = Color(0x4022D3EE);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: _glowPurple, blurRadius: 34, spreadRadius: -4),
            BoxShadow(color: _glowCyan, blurRadius: 44, spreadRadius: -8),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(1.6),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            gradient: SweepGradient(
              colors: [_ringA, _ringB, _ringC, _ringA],
              stops: [0.0, 0.4, 0.75, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(22.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
