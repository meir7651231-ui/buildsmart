// ✨ FabAction — כפתור-פעולה צף עגול, גרדיאנט סגול→מגנטה עם זוהר ניאון כפול. מקבל icon · onTap.
import 'package:flutter/material.dart';

class FabAction extends StatelessWidget {
  const FabAction({
    super.key,
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.50),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.36),
            blurRadius: 34,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.22),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.24),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 25, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
