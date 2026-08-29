// ⚛️ אטום-Dart (דרגת-חוזה) · slugify — גזירת סלאג לטיני ייחודי משם-ארגון (עברית ⇒ תעתיק)
// מוצא: maor/src/components/platform/lib.ts:21-31 (לוח-הבקרה CLOUD2 — סלאג-לידה
//        לארגון-פלטפורמה חדש). המקור-המחייב: new/atoms/slugify.mjs · חוזה: slugify.contract.md.
// טוהר: פונקציות top-level עצמאיות, אפס import של אטום-שכן; טבלת-התעתיק HEB2LAT
//        הוטבעה כקבוע-פרטי (נתון של האטום, לא קריאת-שכן — חוק-1 של המקור).
//
// תפקיד: תעתיק עברית→לטינית, אותיות-קטנות/ספרות/מקפים בלבד, אורך 2–30,
//        ייחודי מול רשימת-התפוסים (סיומת ‎-2, ‎-3 …). ריק/קצר-מדי אחרי ניקוי ⇒ 'org'.
// קלט:  orgName — שם-ארגון (String) · taken — רשימת סלאגים תפוסים (List).
// פלט:  מחרוזת-סלאג.
//
// הערות-המרה (מקור→Dart, חוק-4 — התנהגות זהה-ביט):
// • `[...str]` של JS = פריסה לפי code points ⇒ כאן `.runes` (לא code units) — כדי
//   שאות מעל-BMP תעבור כיחידה אחת בדיוק כמו ב-JS (בפועל היא קורסת ל-'-' ממילא).
// • `toLowerCase` (כלל-13): מיפוי-JS המלא כולל U+0130 'İ' ⇒ 'i'+U+0307 (שתי יחידות),
//   בעוד Dart-VM בולע את הנקודה ⇒ 'i'. העוזר _jsLower מקדים החלפת U+0130 מפורשת.
//   ה-final-sigma הקונטקסטואלי של JS (ς/σ) אינו-נצפה כאן — שתי הצורות אינן a-z0-9
//   וקורסות ל-'-' זהה; אלו שתי חריגות-ה-SpecialCasing היחידות של lowercase.
// • `trim`: קבוצת-הרווחים של JS ≠ של Dart (למשל U+0085 נגזם רק ב-Dart) — אך ההבדל
//   אינו-נצפה: רווח-קצה שלא נגזם הופך '-' ונגזם מיד ע"י ‎^-+|-+$‎, זהה-פלט.
// • replace גלובלי (‎/g‎) ⇒ replaceAll (טיוטת-ה-AST השתמשה ב-replaceFirst — באג).
// • `slice(0,30)` ⇒ substring(0,30) בטוח: מובטח base.length>30 והתוכן ASCII בלבד
//   (אחרי הניקוי base מכיל רק a-z0-9-) ⇒ אין סיכון חצי-סרוגייט ואין אינדקס-שלילי (כלל-5).
// • `base + '-' + i` ⇒ '$base-$i': ‏JS String(int) ≡ Dart int.toString לשלמים קטנים.
// • `taken.includes` ⇒ contains (השוואת-== על מחרוזות — שקול ל-=== של JS על String).
// אפס שקעים: אין לוח-עברי/Intl/locale (כלל-11 לא נדרש — התעתיק הוא טבלה מוטבעת).

/// תעתיק אות עברית → לטינית (פשוט וצפוי — הבעלים עורך את התוצאה ממילא).

/// עוזר מקומי: toLowerCase נאמן-JS (כלל-13) — U+0130 'İ' ⇒ 'i'+U+0307 לפני
/// המיפוי-הפשוט של Dart, כך שהנקודה-העילית לא נבלעת.
String _jsLower(String s) => s.replaceAll('İ', 'i̇').toLowerCase();

dynamic slugify(dynamic orgName, dynamic taken, {required Map<String, dynamic> heb2lat}) {
  final lower = _jsLower((orgName as String).trim());
  final lat =
      lower.runes.map((r) {
        final ch = String.fromCharCode(r);
        return heb2lat[ch] ?? ch;
      }).join('');
  var base = lat
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '')
      .replaceAll(RegExp(r'--+'), '-');
  if (base.length < 2) base = 'org';
  if (base.length > 30) {
    base = base.substring(0, 30).replaceAll(RegExp(r'-+$'), '');
  }
  if (!(taken as List).contains(base)) return base;
  for (var i = 2; ; i++) {
    final cand = '$base-$i';
    if (!taken.contains(cand)) return cand;
  }
}
