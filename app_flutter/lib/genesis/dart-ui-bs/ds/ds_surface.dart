// ✨ מאגר-העיצוב · וריאנטי-משטח (Surface Variants) — **מחולל ע"י machtzev/ds-variants.mjs.**
// אל תערוך ידנית. כל וריאנט עוטף child בעיצוב מטוקני-הליבה (הכרעה 19: מטריצה=דאטה).
// material בלבד; המחולל בוחר סגנון לפי "המראה שאני רוצה" (הכרעה 17).
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'ds.dart';
import 'ds_scale.dart';

// ── כרטיס-מוגבה — משטח לבן, צל-e2, פינות-lg (ברירת-המחדל) ──
class DsCardElevated extends StatelessWidget {
  const DsCardElevated({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(DsSpace.lg),
        decoration: BoxDecoration(
          color: DsTokens.card,
          borderRadius: BorderRadius.circular(DsRadii.lg),
          boxShadow: DsElev.e2,
        ),
        child: child,
      );
}

// ── כרטיס-מתאר — קו-גבול עדין, בלי-צל, שטוח ──
class DsCardOutlined extends StatelessWidget {
  const DsCardOutlined({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(DsSpace.lg),
        decoration: BoxDecoration(
          color: DsTokens.card,
          borderRadius: BorderRadius.circular(DsRadii.lg),
          border: Border.all(color: DsTokens.line),
        ),
        child: child,
      );
}

// ── כרטיס-זכוכית — שקיפות+טשטוש-רקע, מסגרת-אור (glassmorphism) ──
class DsCardGlass extends StatelessWidget {
  const DsCardGlass({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(DsRadii.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(DsSpace.lg),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(DsRadii.lg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: child,
          ),
        ),
      );
}

// ── כרטיס-גרדיאנט — רקע גרדיאנט-מבטא, טקסט-בהיר ──
class DsCardGradient extends StatelessWidget {
  const DsCardGradient({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(DsSpace.lg),
        decoration: BoxDecoration(
          gradient: DsGradient.accent,
          borderRadius: BorderRadius.circular(DsRadii.lg),
          boxShadow: DsElev.e2,
        ),
        child: DefaultTextStyle.merge(style: const TextStyle(color: Colors.white), child: child),
      );
}
