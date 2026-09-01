// ✨ GlassCard — כרטיס-זכוכית (BackdropFilter+blur) עם highlight עליון; מקבל child כתוכן
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});

  final Widget child;

  static const Color _tint = Color(0x14FFFFFF);
  static const Color _tintLow = Color(0x08FFFFFF);
  static const Color _border = Color(0x33FFFFFF);
  static const Color _highlight = Color(0x66FFFFFF);
  static const Color _glow = Color(0x337C3AED);
  static const Color _shadow = Color(0x66000000);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 30, offset: Offset(0, 18)),
            BoxShadow(color: _glow, blurRadius: 40, spreadRadius: -6),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tint, _tintLow],
                ),
                border: Border.all(color: _border, width: 1),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            _highlight,
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: child,
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
