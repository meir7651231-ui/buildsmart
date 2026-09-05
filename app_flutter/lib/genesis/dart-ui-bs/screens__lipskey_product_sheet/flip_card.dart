// 🧼 אטום · FlipCard — כרטיס מתהפך (סיבוב-Y תלת-ממדי 420ms easeInOut) בין שני
// פנים. מוצא: :1470 (_HeroImage) — מנגנון-ההיפוך בלבד; הפנים עצמם מוזרקים
// כ-builders שמקבלים את callback-ההיפוך.
// התרת-סבך: reducedMotion היה ref.read(catalogSettingsProvider).reducedMotion
// ⇒ prop bool (a11y: קפיצה ישירה לפן-היעד בלי אנימציה). הקופסה תזרים מההגדרות.
import 'dart:math';

import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({
    required this.height,
    required this.reducedMotion,
    required this.frontBuilder,
    required this.backBuilder,
    super.key,
  });

  final double height;
  final bool reducedMotion;

  /// Builds the front face; call the provided callback to flip to the back.
  final Widget Function(BuildContext context, VoidCallback flip) frontBuilder;

  /// Builds the back face; call the provided callback to flip to the front.
  final Widget Function(BuildContext context, VoidCallback flip) backBuilder;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 420));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (widget.reducedMotion) {
      _ctrl.value = _showBack ? 0.0 : 1.0;
    } else if (_showBack) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final angle = _anim.value * pi;
          final showingBack = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: widget.backBuilder(context, _flip),
                  )
                : widget.frontBuilder(context, _flip),
          );
        },
      ),
    );
  }
}
