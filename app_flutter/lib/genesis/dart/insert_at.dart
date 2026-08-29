// ⚛️ אטום-Dart · insertAt — הכנסת פריט-ציות לעומק שרשרת-התקנה (מוטציה מוצהרת על שקעי-אוסף).
// מוצא (קדוש, חוק-4): buildsmart/app_flutter/lib/logic/install_engine.dart:1019-1036
// (הגוף-המוגן, ענפי-העבודה למשל origin/claude/align-main; ב-main הגוף זהה בלי גארד-האורך,
// שם :828-836 — שתי הגרסאות זהות-ביט לכל שרשרת עם ≥2 פריטים; הטיוטה = הגוף-המוגן).
// הכרעת-קידום 🔌 (חוק-1/3): הסגירוֹת (closure) של המקור הפכו שקעי-פרמטר:
//   • items — שרשרת-המוצרים (List<T> גנרית; במקור List<LipskeyCatalogProduct>) — נכתבת.
//   • skus  — קבוצת-המק"טים הנוכחית בשרשרת (Set<String>) — נקראת ומעודכנת.
//   • qty   — כמויות פר-מק"ט (Map<String, int>) — נכתבת.
//   • skuOf — שקע-פותר: מק"ט ⇒ מוצר-קטלוג או null (במקור `_skuOf`; דאטה-הקטלוג לא במנוע).
//
// קלט:  position · alternatives · preferred · ארבעת השקעים.
// פלט:  מוטציה — הכנסת המוצר לאינדקס clamp(position,1,len-1), qty[preferred]=1,
//        skus+=preferred; או אפס-שינוי באחד משלושת תנאי-היציאה (ראה חוזה).

/// Insert the [preferred] compliance part at [position] (clamped to the chain
/// interior) — unless any of [alternatives] is already present, the chain has
/// no interior slot, or the resolver finds no product. Verbatim מהמקור.
void insertAt<T>(
  int position,
  Set<String> alternatives,
  String preferred, {
  required List<T> items,
  required Set<String> skus,
  required Map<String, int> qty,
  required T? Function(String sku) skuOf,
}) {
  // A compliance part is inserted BETWEEN two existing pieces; a chain with
  // fewer than 2 items has no interior slot. Guard first: otherwise
  // `clamp(1, items.length - 1)` becomes `clamp(1, 0)` (or `clamp(1, -1)`)
  // and Dart's clamp throws ArgumentError when lowerLimit > upperLimit —
  // a latent crash on `buildInstallation([oneSupplyProduct], autoCompliance: true)`.
  if (items.length < 2) return;
  if (alternatives.any(skus.contains)) return;
  final p = skuOf(preferred);
  if (p == null) return;
  final clamped = position.clamp(1, items.length - 1).toInt();
  items.insert(clamped, p);
  qty[preferred] = 1;
  skus.add(preferred);
}
