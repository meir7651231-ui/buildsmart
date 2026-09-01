// ✨ SkeletonBlock — טוען-שלד עם shimmer נע; דאטה: double width, height (מידות בלבד)
import 'package:flutter/material.dart';

class SkeletonBlock extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const SkeletonBlock({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final double t = _c.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                begin: Alignment(-1 + t * 2 - 0.6, 0),
                end: Alignment(-1 + t * 2 + 0.6, 0),
                colors: const [
                  Color(0xFF1B1730),
                  Color(0xFF2E2650),
                  Color(0xFF1B1730),
                ],
                stops: const [0.25, 0.5, 0.75],
              ),
            ),
          );
        },
      ),
    );
  }
}
