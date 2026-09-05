// ⚛️ אטום-Dart (דרגת-חוזה) · aiAlternatives — "חלופות זולות" של מרכז-ה-AI.
// מוצא: buildsmart/app_flutter/lib/logic/ai_hub_logic.dart:202-238 (‏origin/main —
//        קו-האמת L16; הקובץ אינו בעץ-העבודה — חולץ מ-git). ‏חוק-4: גוף verbatim.
// טוהר: פונקציית top-level גנרית, אפס import, אפס דאטה-צרובה — הכול מוזרק.
//
// שקעים שהוזרקו (קריאה-לשכן/דאטה ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `kHomeProductBrands` + `_pricedSmartProduct(pb)` (‏:207-208) ⇒ שקע
//     `pricedProducts` — הקופסה ממפה את קטלוג-הטירים למוצרים-מתומחרים ומזריקה.
//   • `pb.product` (‏:213,215 — מפתח-הדדופ וגם `cat`; זהה ל-sp.cat/key שנבנה
//     ב-‏_pricedSmartProduct ‏:191-194) ⇒ שקע-ריאדר `productKey`.
//   • `sp.brands` / `b.rec` / `rec.name` / `rec.price` (‏:209-212,216-217) ⇒
//     שקעי-ריאדר `brands` / `isRec` / `brandName` / `brandPrice` (int? — null =
//     "מחיר לפי ספק", smart_tree.dart:91).
//   • `cheaperAlternativeBrand(sp, i)` (‏:211 — השכן related_info.dart:1630-1646,
//     מחזיר record ‏`({String name, int price})?`) ⇒ שקע `cheaperAlternativeBrand`
//     באותו טיפוס-record בדיוק (‏alt.price מובטח non-null — נשמר החוזה).
//   • `cheaperAlternativesAcrossCatalog()` (‏:225 — השכן contractor_tools_sheets
//     ‏.dart:125-150) ⇒ שקע-דאטה `crossCatalog` — הקופסה קוראת לשכן ומזריקה את
//     התוצאה; ריאדרים `crossProduct/RecName/RecPrice/AltName/AltPrice`
//     (‏CheaperAlt ‏:106-120 — כל השדות non-null).
//   • ‏AiAlt (‏:170-186) — טיפוס-מותאם ⇒ הוטבע verbatim בקובץ-האטום (מסלול-2).
//
// קלט:  pricedProducts · productKey · brands · isRec · brandName · brandPrice ·
//       cheaperAlternativeBrand · crossCatalog · crossProduct · crossRecName ·
//       crossRecPrice · crossAltName · crossAltPrice.
// פלט:  עד 5 [AiAlt] ממוינים לפי חיסכון-יורד; דדופ פר-מוצר (שלב-1 גובר על
//       שלב-2). מוצר בלי-חלופה או עם rec.price==null בשלב-1 — מדולג (ועדיין
//       יכול להגיע משלב-2). ⚠️ נאמן-למקור: מוצר עם רשימת-מותגים ריקה זורק
//       RangeError (‏:210 — `sp.brands[0]`); בקטלוג-האמת אין כזה.

/// שורת-חלופה — הוטבע verbatim מ-ai_hub_logic.dart:170-186 (מסלול-2).
class AiAlt {
  const AiAlt({
    required this.cat,
    required this.fromName,
    required this.fromPrice,
    required this.toName,
    required this.toPrice,
  });

  final String cat;
  final String fromName;
  final int fromPrice;
  final String toName;
  final int toPrice;

  int get save => fromPrice - toPrice;
}

/// ‏ai_hub_logic.dart:202-238 verbatim: (1) המסייע-האמיתי על כל מוצר-מתומחר —
/// המותג-המומלץ (הראשון כשאין דגל-rec) מול החלופה-הזולה; (2) מיזוג סריקת-הקטלוג
/// של דף-הבית לכל מוצר שטרם-כוסה; מיון חיסכון-יורד; top-5 (‏proto @21255).
List<AiAlt> aiAlternatives<P, B, C>({
  required List<P> pricedProducts,
  required String Function(P) productKey,
  required List<B> Function(P) brands,
  required bool Function(B) isRec,
  required String Function(B) brandName,
  required int? Function(B) brandPrice,
  required ({String name, int price})? Function(P product, int recIndex)
      cheaperAlternativeBrand,
  required List<C> crossCatalog,
  required String Function(C) crossProduct,
  required String Function(C) crossRecName,
  required int Function(C) crossRecPrice,
  required String Function(C) crossAltName,
  required int Function(C) crossAltPrice,
}) {
  final out = <AiAlt>[];
  final seen = <String>{};

  // 1) The real helper over priced catalog products (reuses cheaperAlternativeBrand).
  for (final p in pricedProducts) {
    final bs = brands(p);
    final recI = bs.indexWhere(isRec);
    final rec = bs[recI >= 0 ? recI : 0];
    final alt = cheaperAlternativeBrand(p, recI >= 0 ? recI : 0);
    final recPrice = brandPrice(rec);
    if (alt == null || recPrice == null) continue;
    if (!seen.add(productKey(p))) continue;
    out.add(AiAlt(
      cat: productKey(p),
      fromName: brandName(rec),
      fromPrice: recPrice,
      toName: alt.name,
      toPrice: alt.price,
    ));
  }

  // 2) Merge the home sheet's own cross-catalog scan (same data, sorted) for
  //    any product not already covered.
  for (final a in crossCatalog) {
    if (!seen.add(crossProduct(a))) continue;
    out.add(AiAlt(
      cat: crossProduct(a),
      fromName: crossRecName(a),
      fromPrice: crossRecPrice(a),
      toName: crossAltName(a),
      toPrice: crossAltPrice(a),
    ));
  }

  out.sort((a, b) => b.save.compareTo(a.save));
  return out.length > 5 ? out.sublist(0, 5) : out;
}
