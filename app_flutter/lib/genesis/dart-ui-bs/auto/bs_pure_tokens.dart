// 🛗 טוין-Pure של קטלוג-הפיגמנטים (BsPure) — אותה API כמו BsTokens, בערכי-Pure מ-DsPure (מקור-יחיד).
// דורמנטי/הפיך (חוק-6/7): הגנרטור בוחר BsTokens (ברירת-מחדל, ביט-זהה) או BsPure (--pure). material בלבד.
import 'package:flutter/material.dart';
import '../ds/ds_pure.dart';

/// 6 שדות-הצבע שהגנרטור מזריק — ממופים ל-Pure. שאר-ה-API (מרווח/רדיוס) נשאר ב-BsTokens.
class BsPure {
  BsPure._();
  static const Color brand = DsPure.accent; // אקצנט t-indigo
  static const Color brandDark = DsPure.accentDark;
  static const Color inkLight = DsPure.ink; // דיו
  static const Color cardLight = DsPure.surface; // משטח-כרטיס
  static const Color bgLight = DsPure.canvas; // רקע
  static const Color mutedLight = DsPure.mut; // מודגש-חלש
  static const Color divider = DsPure.raised2; // קו-מפריד
}
