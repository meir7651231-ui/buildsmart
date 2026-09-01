// ✨ StatHero — מספר-ענק בגרדיאנט-טקסט (ShaderMask) עם תווית מתחת; מקבל value/label
import 'package:flutter/material.dart';

class StatHero extends StatelessWidget {
  const StatHero({super.key, required this.value, required this.label});

  final String value;
  final String label;

  static const Color _shaderA = Color(0xFF22D3EE);
  static const Color _shaderB = Color(0xFF7C3AED);
  static const Color _shaderC = Color(0xFFEC4899);
  static const Color _label = Color(0xFF9A9CC4);

  static const Gradient _grad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [_shaderA, _shaderB, _shaderC],
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => _grad.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            blendMode: BlendMode.srcIn,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: _label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
