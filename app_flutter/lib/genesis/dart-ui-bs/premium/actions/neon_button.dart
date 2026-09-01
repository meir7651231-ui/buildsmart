// ✨ NeonButton — טבעת-conic-ניאון (סגול·מגנטה·ציאן) סביב מילוי כהה עם זוהר. מקבל label · onTap · icon אופציונלי.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.30),
            blurRadius: 26,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.28),
            blurRadius: 26,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.6),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: SweepGradient(
            startAngle: 0,
            endAngle: math.pi * 2,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFFEC4899),
              Color(0xFF22D3EE),
              Color(0xFF7C3AED),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ),
        ),
        child: Material(
          color: const Color(0xFF0B0B16),
          borderRadius: BorderRadius.circular(16.4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFF22D3EE).withValues(alpha: 0.18),
            highlightColor: const Color(0xFF7C3AED).withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 19,
                      color: const Color(0xFF22D3EE),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFF2F3FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
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
