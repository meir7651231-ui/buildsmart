// ⚛️ אטום-Dart (דרגת-חוזה) · isFitting
// מוצא: install_engine.dart:816-818 (origin/main — ‏isFitting; חוק-4, verbatim).
//        _fittingCats = install_engine.dart:801-806 · _fittingTypes = install_engine.dart:811-813.
//        אימות-עוגן: ‏install_engine.dart:816-818 =
//          `bool isFitting(p) => _fittingCats.contains(p.categoryHe) ||
//           (companyCatalogActive && _fittingTypes.contains(p.productType));`
//        — שני סעיפים (הסעיף-השני נוסף ב-main מול ה-snapshot הישן).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט).
//       ‏_fittingCats + _fittingTypes = דאטה-קבוע פנימי של האטום (רשימות-מונחים,
//       לא הקשר/זהות/סוד).
//
// שקע שהוזרק (גלובל ⇒ פרמטר-שקע · חוק-6, דיבר-3/8):
//   • companyCatalogActive  (install_engine.dart:7 — `import … show companyCatalogActive`)
//     — הדגל-הגלובלי של שכבת-הקטלוג-של-החברה קורס לשקע-פרמטר bool.
//     **ברירת-המחדל = false** ⇒ מסלול-demo/off-overlay ביט-זהה-להיום (הסעיף-השני מנוטרל).
//   • שדות-המחלקה LipskeyCatalogProduct (categoryHe/productType) ⇒ מוחזקים ב-
//     `FittingPart` — מחזיק-קלט טהור, אפס תלות (רק שני השדות שהגוף קורא).
//
// התנהגות (מקור:816-818): קטגוריות מחבר/מתאם טהורות — פטמות, בושינגים, מצמדים,
//   ברכיים, אטמים, קטעי-צינור ⇒ true (מותרים כמילוי-אוטומטי). כשקטלוג-החברה פעיל,
//   נופלים גם על שם-הסוג (productType) — אוצר-מילים חלופי לקטלוג-מיובא ששמות-
//   הקטגוריה שלו לעולם אינם תואמים ל-_fittingCats. התקנים תפקודיים (ברזים/מחלקים/
//   משאבות) אינם כאן.
//
// קלט:  p                    — FittingPart (categoryHe · productType?).
//       companyCatalogActive — שקע: bool. חסר ⇒ false (הסעיף-השני כבוי).
// פלט:  bool — האם המוצר הוא אביזר-מחבר (fitting).

/// מחזיק-קלט טהור: שני השדות ש-isFitting קורא (install_engine.dart:816-818).
class FittingPart {
  final String categoryHe;
  final String? productType;
  const FittingPart(this.categoryHe, {this.productType});
}

/// Pure connector/adapter categories — nipples, bushings, couplers, elbows,
/// gaskets, pipe segments (verbatim: install_engine.dart:801-806).
const _fittingCats = {
  'אביזרי נחושת', 'אביזרי תבריג', 'מחברי HDPE', 'מחברי NTM', 'אביזרי שקע-תקע',
  'ברכיים', 'מסעפים וחיבורי אסלה', 'אטמים ופקקים', 'מצמדים וצינורות', 'צינורות',
  'צינורות אפורות', 'צינורות PP', 'אביזרי חיבור', 'סטי הידוק וחיבורים',
  'פקקים וצינורות', 'זקיף אסלה',
};

/// Name-derived fitting nouns — the fallback vocabulary for an IMPORTED company
/// catalog, whose category names never match [_fittingCats]. Gated on
/// companyCatalogActive, so demo/off-overlay surfaces are untouched.
/// (verbatim: install_engine.dart:811-813).
const _fittingTypes = {
  'מצמד', 'מחבר', 'מופה', 'ניפל', 'בושינג', 'רקורד', 'מתאם',
  'ברך', 'זווית', 'מסעף', 'מעבר', 'אביזר',
};

/// האם המוצר הוא אביזר-מחבר — התנהגות verbatim של install_engine.dart:816-818.
bool isFitting(FittingPart p, {bool companyCatalogActive = false}) =>
    _fittingCats.contains(p.categoryHe) ||
    (companyCatalogActive && _fittingTypes.contains(p.productType));
