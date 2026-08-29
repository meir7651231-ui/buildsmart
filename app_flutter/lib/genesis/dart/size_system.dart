// ⚛️ אטום-Dart (דרגת-חוזה) · sizeSystem
// מוצא: buildsmart/app_flutter/lib/data/variant_families.dart:287-309 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית עצמאית, אפס import (רק dart:core — RegExp).
//
// קלט:  size — מחרוזת-מידה.
// פלט:  זיהוי "מערכת-המידה": אינץ' (תבריג) · HDPE מ"מ · DN ניקוז · אחר.

/// מזהה את מערכת-המידה של [size]. טהור.
String sizeSystem(String size) {
  final s = size.trim();
  if (s.contains('DN') || s.contains('dn')) return 'DN ניקוז';
  if (s.contains('"') || s.contains('½') || s.contains('¼') || s.contains('¾') ||
      RegExp(r'\d/\d').hasMatch(s)) {
    return 'תבריג (אינץ\')';
  }
  if (RegExp(r'^\d+(?:[×x]\d+)*( \d+)?$').hasMatch(s)) {
    final firstNum = int.tryParse(RegExp(r'^\d+').firstMatch(s)?.group(0) ?? '');
    if (firstNum != null) {
      if (firstNum >= 16 && firstNum <= 63) return 'HDPE (מ"מ)';
      if (firstNum >= 75) return 'DN ניקוז';
    }
  }
  return 'אחר';
}
