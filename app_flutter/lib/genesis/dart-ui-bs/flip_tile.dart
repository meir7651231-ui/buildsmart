// 🎨 חוט-תצוגה · FlipTile — כרטיס שמתהפך במגע (3D rotateY) (חוק-1/חוק-5).
// המנוע: הקשה מסובבת את הכרטיס ב-180° (Matrix4.rotateY); מתחת לחצי — פנים, מעל — גב.
// אפס-דאטה — טקסט-פנים · טקסט-גב · גובה · צבע-פנים/גב/טקסט מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipTile extends StatefulWidget {
  const FlipTile({
    required this.front,
    required this.back,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final String front, back;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  void _flip() {
    if (_c.value < 0.5) {
      _c.forward();
    } else {
      _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final angle = _c.value * math.pi;
            final showBack = _c.value > 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(angle),
              child: Container(
                height: widget.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: showBack ? widget.accentColor : widget.fillColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(showBack ? math.pi : 0),
                  child: Text(
                    showBack ? widget.back : widget.front,
                    style: TextStyle(
                      color: showBack ? widget.fillColor : widget.baseColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}
