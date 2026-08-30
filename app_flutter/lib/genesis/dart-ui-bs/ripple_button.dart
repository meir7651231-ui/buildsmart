// 🎨 חוט-תצוגה · RippleButton — כפתור-אדווה (גל-מגע מתפשט) (חוק-1/חוק-5).
// המנוע: InkWell עם splash מותאם-צבע על משטח מלא. אפס-דאטה —
// תווית · גובה · צבע-מילוי/טקסט/אדווה · onPressed מוזרקים בחיווט.
import 'package:flutter/material.dart';

class RippleButton extends StatelessWidget {
  const RippleButton({
    required this.label,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final double height, radius;
  final Color accentColor, baseColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: accentColor,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          splashColor: baseColor.withValues(alpha: 0.28),
          highlightColor: baseColor.withValues(alpha: 0.10),
          child: SizedBox(
            height: height,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: baseColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      );
}
