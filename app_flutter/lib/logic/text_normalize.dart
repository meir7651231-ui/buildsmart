// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · ליבת נרמול-טקסט משותפת — PURE Dart, אפס Flutter.
//
// port של Maor `validate.ts normSearch` — נרמול-חיפוש עברי אחיד: lowercase ·
// הסרת-ניקוד · קיפול אותיות-סופיות (ךםןףץ→כמנפצ) · הסרת גרשיים/מקפים/נקודות ·
// trim. היה מפוזר (`_normSearch` פרטי ב-workflow_engine, וריאנט חלש ב-catalog);
// זו נקודת-האמת האחת שגל-CRM (dedup·חיפוש-סובל-שגיאות) וה-workflow צורכים.
//
// שינוי-התנהגות = אפס: המימוש זהה-בייטים לפונקציה שהיה ב-workflow_engine (אותן
// בדיקות עוברות ללא-שינוי). `normName` = normSearch + הסרת **כל** רווח (מפתח-
// dedup הדוק).
// ─────────────────────────────────────────────────────────────────────────────

/// קיפול אותיות-סופיות עבריות לצורה הרגילה.
const Map<String, String> kHebrewFinalFold = {
  'ך': 'כ',
  'ם': 'מ',
  'ן': 'נ',
  'ף': 'פ',
  'ץ': 'צ',
};

/// נרמול-חיפוש: lowercase · ניקוד-מוסר · סופיות-מקופלות · פיסוק-מוסר · trim.
String normSearch(String t) {
  var s = t.toLowerCase();
  s = s.replaceAll(RegExp('[֑-ׇ]'), ''); // ניקוד עברי (U+0591..U+05C7)
  final b = StringBuffer();
  for (final ch in s.split('')) {
    b.write(kHebrewFinalFold[ch] ?? ch);
  }
  s = b.toString().replaceAll(RegExp('[\'"׳״\\-–._]'), '');
  return s.trim();
}

/// מפתח-dedup הדוק: [normSearch] + הסרת כל רווח. `'בן דוד' ≡ 'בןדוד'`.
String normName(String s) => normSearch(s).replaceAll(RegExp(r'\s'), '');
