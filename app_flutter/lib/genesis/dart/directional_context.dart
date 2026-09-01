// ⚛️ אטום-Dart (דרגת-חוזה) · directionalContext
// מוצא: install_engine.dart:181-188 (origin/main — ‏_directionalContext; חוק-4, verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//
// שקע (שדה-מחלקה ⇒ קלט-מינימלי · דיבר-3, חוק-2):
//   • במקור הפרמטר הוא `List<LipskeyCatalogProduct> chain`, והגוף קורא אך-ורק את
//     `chain[k].nameHe`. לכן ה-chain קורס לרשימת-השמות `names` (names[k]==chain[k].nameHe)
//     — היחידה-הקטנה-ביותר עם קלט/פלט מוגדרים (כלל-העצירה L14).
//
// התנהגות (מקור:181-188): היכן יושב התקן חד-כיווני שבאינדקס [i] בשרשרת, מנוסח לפי
//   שכניו — כדי שהמתקין יֵדע בדיוק איזה שסתום, ובין אילו שני חלקים, לכוון לזרימה
//   (הדרכה מוחשית תמיד-נכונה; המנוע אינו יכול לחשב את כיוון-הזרימה בעצמו כי שני
//   קצות-השסתום ממודלים כזהים).
//     יש up ויש down ⇒ 'בין "$up" ל-"$down"'
//     רק down (i==0)        ⇒ 'בכניסת הקו (לפני "$down")'
//     רק up (i==אחרון)      ⇒ 'ביציאת הקו (אחרי "$up")'
//     אין שכנים (יחיד)      ⇒ 'בקו'
//
// קלט:  names — רשימת-שמות (nameHe פר-פריט בשרשרת, לפי-סדר).
//       i     — אינדקס ההתקן החד-כיווני בשרשרת.
// פלט:  String — ניסוח-המיקום לפי-השכנים.

/// Where a directional device at [i] sits, named by its neighbours —
/// verbatim install_engine.dart:181-188 (chain collapsed to its nameHe list).
String directionalContext(List<String> names, int i, {required String Function(String) term}) {
  final up = i > 0 ? names[i - 1] : null;
  final down = i < names.length - 1 ? names[i + 1] : null;
  if (up != null && down != null) return '${term('xi_byn')}$up${term('xi_l')}$down"';
  if (down != null) return '${term('xi_bknyst-hkv-lpny')}$down")';
  if (up != null) return '${term('xi_bytsyat-hkv-achry')}$up")';
  return term('bkv');
}
