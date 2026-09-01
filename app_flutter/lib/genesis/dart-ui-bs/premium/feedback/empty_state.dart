// ✨ EmptyState — מצב-ריק עם אייקון בעיגול-כהה זוהר; דאטה: String glyph + String message
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String glyph;
  final String message;
  const EmptyState({super.key, required this.glyph, required this.message});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF211B3A), Color(0xFF120E22)],
              ),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.35), width: 1),
              boxShadow: [
                BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.30), blurRadius: 28, spreadRadius: 1),
              ],
            ),
            child: Text(glyph, style: const TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFF2F3FF).withValues(alpha: 0.72),
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
