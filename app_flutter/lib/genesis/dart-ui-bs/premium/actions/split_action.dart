// ✨ SplitAction — כפתור-פיצול: פעולה ראשית (label) + אזור-חץ משני מופרד בקו-אור. גרדיאנט כהה-ניאון. מקבל label · onMain · onMore.
import 'package:flutter/material.dart';

class SplitAction extends StatelessWidget {
  const SplitAction({
    super.key,
    required this.label,
    this.onMain,
    this.onMore,
  });

  final String label;
  final VoidCallback? onMain;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171427), Color(0xFF0E0B1A)],
        ),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.40),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMain,
                splashColor: const Color(0xFF7C3AED).withValues(alpha: 0.22),
                highlightColor: const Color(0xFFEC4899).withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFF2F3FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFEC4899).withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMore,
                splashColor: const Color(0xFFEC4899).withValues(alpha: 0.22),
                highlightColor: const Color(0xFF22D3EE).withValues(alpha: 0.08),
                child: const Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
