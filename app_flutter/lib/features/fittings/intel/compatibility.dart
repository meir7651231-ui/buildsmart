// 🧠 מנוע-אביזרים · E-lite slice 2 — תאימות-אביזרים (compatibility). **שאילתה** מעל
// גרף-החיבורים המאומת החי (`canConnect`/`connectionFailReason`, `install_engine`):
// "האם A מתחבר ל-B?" · "למה לא?" · "למה זה מתחבר?". מגודר · off-live.
//
// 🔒 טהור-שכבה · אף מסך-חי אינו מייבא `intel/` ⇒ tree-shaken ⇒ byte-identical.
// `install_engine` כבר חי ⇒ ייבוא לא מוסיף קוד-חי. אפס תלות חדשה.
//
// 🛡️ M5 — **אפס over-match ניתן-לבנייה**: כל שלוש הפונקציות **מאצילות ל-`canConnect`**
// (הנתיב-המאומת: `kVerifiedSpecs[sku].compatibleWith`, עם תיקון-M2). אין כאן חוק-
// חיבור *חדש* ואין הרחבת-קבלה — הגרוע-ביותר הוא false-negative (בטוח · לא-דולף).

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/logic/install_engine.dart'
    show canConnect, connectionFailReason;

/// האם שני אביזרים מתחברים פיזית? **האצלה ישירה ל-`canConnect`** (נתיב-מאומת · M2-fix).
/// אין ריכוך: זהה-בית ל-`canConnect(a, b)`.
bool pairCompatible(LipskeyCatalogProduct a, LipskeyCatalogProduct b) =>
    canConnect(a, b);

/// נימוק-אי-התאמה (עברית) כשלא-מתחברים, אחרת `null`. מאציל ל-`connectionFailReason`.
String? incompatibilityReason(LipskeyCatalogProduct a, LipskeyCatalogProduct b) =>
    canConnect(a, b) ? null : connectionFailReason(a, b);

/// המוצרים ב-[universe] שהאביזר [product] מתחבר אליהם — **מסונן ב-`canConnect`
/// בלבד** (בלי קבלת-יתר). מדלג את המוצר עצמו (`canConnect` מחזיר false לזהה-SKU).
List<LipskeyCatalogProduct> compatibleTargets(
  LipskeyCatalogProduct product,
  List<LipskeyCatalogProduct> universe,
) =>
    [for (final x in universe) if (canConnect(product, x)) x];
