// ✨ מאגר-העיצוב · עוטפי-מוֹשֶׁן (Motion Presets) — **מחולל ע"י machtzev/ds-motion.mjs.**
// אל תערוך ידנית. עוטף כל child במוֹשֶׁן-כניסה חד-שוט (TweenAnimationBuilder, בלי controller).
// הכרעה 17 (מראה-רצוי) + 19 (מפרט=דאטה). material בלבד; מכבד duration/curve מוזרקים.
import 'package:flutter/material.dart';
import 'ds_scale.dart';

// ── הופעה עדינה (opacity 0→1) — מוֹשֶׁן-כניסה לכל תוכן ──
class FadeInView extends StatelessWidget {
  const FadeInView({required this.child, this.duration = DsMotion.base, this.curve = DsMotion.standard, super.key});
  final Widget child;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        builder: (context, v, ch) => Opacity(opacity: v, child: ch),
        child: child,
      );
}

// ── החלקה מלמטה-למעלה — כניסת-כרטיס/שורה ──
class SlideUpView extends StatelessWidget {
  const SlideUpView({required this.child, this.duration = DsMotion.base, this.curve = DsMotion.standard, super.key});
  final Widget child;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        builder: (context, v, ch) => Transform.translate(offset: Offset(0, (1 - v) * 16), child: Opacity(opacity: v, child: ch)),
        child: child,
      );
}

// ── הגדלה עדינה (0.92→1) — הופעת-כפתור/אייקון ──
class ScaleInView extends StatelessWidget {
  const ScaleInView({required this.child, this.duration = DsMotion.base, this.curve = DsMotion.standard, super.key});
  final Widget child;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        builder: (context, v, ch) => Transform.scale(scale: 0.92 + v * 0.08, child: Opacity(opacity: v, child: ch)),
        child: child,
      );
}

// ── החלקה מהצד (RTL: ימין→שמאל) — כניסת-פריט-רשימה ──
class SlideInView extends StatelessWidget {
  const SlideInView({required this.child, this.duration = DsMotion.base, this.curve = DsMotion.standard, super.key});
  final Widget child;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        builder: (context, v, ch) => Transform.translate(offset: Offset((1 - v) * 24, 0), child: Opacity(opacity: v, child: ch)),
        child: child,
      );
}

// ── עלייה-מלמטה בולטת + הופעה — כניסת-הירו ──
class RiseView extends StatelessWidget {
  const RiseView({required this.child, this.duration = DsMotion.base, this.curve = DsMotion.standard, super.key});
  final Widget child;
  final Duration duration;
  final Curve curve;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        curve: curve,
        builder: (context, v, ch) => Transform.translate(offset: Offset(0, (1 - v) * 40), child: Opacity(opacity: v, child: ch)),
        child: child,
      );
}
