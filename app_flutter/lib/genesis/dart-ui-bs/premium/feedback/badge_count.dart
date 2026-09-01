// ✨ BadgeCount — תג-מונה עגול גרדיאנט עם זוהר; דאטה: int count (מוצג, 99+ מעל התקרה)
import 'package:flutter/material.dart';

class BadgeCount extends StatelessWidget {
  final int count;
  final int max;
  const BadgeCount({super.key, required this.count, this.max = 99});

  @override
  Widget build(BuildContext context) {
    final String text = count > max ? '$max+' : '$count';
    final bool wide = text.length > 2;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
        padding: EdgeInsets.symmetric(horizontal: wide ? 7 : 0, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEC4899), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.55),
              blurRadius: 14,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFF2F3FF),
            fontSize: 12,
            height: 1.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
