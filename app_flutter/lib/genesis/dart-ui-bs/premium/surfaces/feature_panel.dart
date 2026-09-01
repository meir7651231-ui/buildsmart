// ✨ FeaturePanel — פאנל-פיצ'ר: אייקון-glyph זוהר, כותרת וגוף-טקסט; מקבל title/body/glyph
import 'package:flutter/material.dart';

class FeaturePanel extends StatelessWidget {
  const FeaturePanel({
    super.key,
    required this.title,
    required this.body,
    required this.glyph,
  });

  final String title;
  final String body;
  final String glyph;

  static const Color _surface = Color(0xFF101127);
  static const Color _surfaceLow = Color(0xFF0A0A18);
  static const Color _border = Color(0x1FFFFFFF);
  static const Color _title = Color(0xFFF2F3FF);
  static const Color _body = Color(0xFF9A9CC4);
  static const Color _glyphA = Color(0xFF22D3EE);
  static const Color _glyphB = Color(0xFF7C3AED);
  static const Color _glyphGlow = Color(0x4022D3EE);
  static const Color _shadow = Color(0x59000000);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_surface, _surfaceLow],
          ),
          border: Border.all(color: _border, width: 1),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 26, offset: Offset(0, 14)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_glyphA, _glyphB],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: _glyphGlow,
                      blurRadius: 22,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  glyph,
                  style: const TextStyle(fontSize: 26, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: _title,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  color: _body,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
