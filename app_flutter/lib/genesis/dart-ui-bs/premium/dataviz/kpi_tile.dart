// ✨ KpiTile — אריח-KPI (glyph + value בגרדיאנט-טקסט + label) על כרטיס-זכוכית
import 'dart:ui';
import 'package:flutter/material.dart';

class KpiTile extends StatelessWidget {
  const KpiTile({
    super.key,
    required this.glyph,
    required this.value,
    required this.label,
  });

  final String glyph;
  final String value;
  final String label;

  static const Color _bg = Color(0xFF12132A);
  static const Color _mute = Color(0xFF8A8CB8);
  static const Color _cyan = Color(0xFF22E1FF);
  static const Color _violet = Color(0xFF7A5CFF);
  static const Color _magenta = Color(0xFFFF3DCB);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF16173063), _bg],
          ),
          color: _bg,
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: _violet.withValues(alpha: 0.14),
              blurRadius: 24,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: LinearGradient(
                  colors: [_cyan.withValues(alpha: 0.22), _magenta.withValues(alpha: 0.22)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Text(glyph, style: const TextStyle(fontSize: 20, height: 1)),
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                colors: [_cyan, _violet, _magenta],
              ).createShader(r),
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                  height: 1,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _mute,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
