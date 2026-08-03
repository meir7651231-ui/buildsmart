// 🔌 גשר קטלוג→מנוע (פאזה 0, שלבים 5–6): `familyOf` + `odOf` ממפים מוצר-קטלוג
// אוניברסלי ל-{משפחה, OD} שהמנוע (`fitting_dims.generate`) יודע לחשב. מרחיב את
// `_portCountFor`/`_parsePprDn` שב-`data/polyroll_specs.dart` — אותה קריאה, אבל
// פולטת את *שם-המשפחה של המנוע* (כמו `pure_engine.ENGINE`) במקום ספירת-פורטים.
//
// טהור: אין state/async/I/O. תלוי רק במודל-המוצר. `fitting_dims.dart` נשאר
// חופשי-מקטלוג — לכן הגשר יושב כאן ולא שם.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';

/// קטגוריית-קטלוג → שם-משפחת-מנוע (מפתח ב-`kFittingFamilies`/`ENGINE`).
/// משפחות דו-משמעיות (ברך 90/45 · מצמד/מצרה) מוכרעות ב-[familyOf] מהשם.
const Map<String, String> _kCategoryFamily = {
  kPprCouplers: 'מצמד', // מוכרע ל-'מצרה' אם השם דו-קוטרי
  kPprElbows: 'ברך 90°', // מוכרע ל-'ברך 45°' אם '45' בשם
  kPprTees: 'מסעף (טי)',
  kPprAdapters: 'מתאם תבריג',
  kPprSaddles: 'רוכב',
  kPprPlugs: 'פקק',
  kPprValves: 'ברז כדורי',
  kPprCollars: 'צווארון',
};

/// זיהוי מצרה (reducer) — שני קטרים שונים בשם/מידה: "50x40" · "50×40".
final RegExp _kReducer = RegExp(r'(\d{2,3})\s*[×xX]\s*(\d{2,3})');

/// זיהוי זווית 45° בשם הברך (אחרת 90°).
bool _is45(String name) => name.contains('45');

/// משפחת-המנוע של מוצר-קטלוג, או `null` כשאין התאמה (צינור · אומגה · כלי ·
/// ריתוך-חשמלי · קטגוריה לא-אביזרית). `null` = **fallback כן**, לא כשל-מנוע (M1).
String? familyOf(LipskeyCatalogProduct p) {
  final base = _kCategoryFamily[p.categoryHe];
  if (base == null) return null; // צינור/אומגה/כלי/electrofusion → fallback
  if (base == 'מצמד') {
    // מצרה = מצמד דו-קוטרי (שני קטרים נבדלים). מצמד ישר = קוטר יחיד.
    final m = _kReducer.firstMatch(p.nameHe);
    if (m != null && m.group(1) != m.group(2)) return 'מצרה';
    return 'מצמד';
  }
  if (base == 'ברך 90°' && _is45(p.nameHe)) return 'ברך 45°';
  return base;
}

/// ה-OD (DN נומינלי) של מוצר-קטלוג כמספר שלם שהמנוע תומך בו, או `null`.
/// מרחיב את הפרסור של `_parsePprDn`: dims מפורשים → מידה → DN-נגרר → דו-קוטרי,
/// ומחזיר int במקום String. עבור מצרה = הקוטר הראשון (הגדול), כמו במנוע.
int? odOf(LipskeyCatalogProduct p) {
  // 1. dims מפורשים (מדויק ביותר).
  for (final key in const [
    'dn נומינלי',
    'מידה נומינלית',
    'd',
    'de קוטר חיצוני',
    'D',
  ]) {
    final v = p.dims?[key]?.toString();
    if (v != null && v.isNotEmpty) {
      final n = double.tryParse(v);
      if (n != null) return n.toInt();
    }
  }
  // 2. dims['מידה'] = "50x40" → 50.
  final size = p.dims?['מידה']?.toString();
  if (size != null) {
    final m = RegExp(r'(\d{2,3})').firstMatch(size);
    if (m != null) return int.tryParse(m.group(1)!);
  }
  // 3. דו-קוטרי בשם: "50x40" · "20×2.8" → 50/20 (הקוטר הראשון). **לפני** ה-DN-
  //    הנגרר: אחרת "50x40" היה תופס את ה-40 הנגרר במקום ה-50 הראשי.
  final m2 = RegExp(r'(\d{2,3})\s*[×xX]').firstMatch(p.nameHe);
  if (m2 != null) return int.tryParse(m2.group(1)!);
  // 4. DN-נגרר בשם: "ברך PPR 45° פ.פ 20" → 20.
  final m = RegExp(r'(\d{2,3})\s*$').firstMatch(p.nameHe.replaceAll('°', ''));
  return m == null ? null : int.tryParse(m.group(1)!);
}

/// הקוטר השני של מצרה (הקטן), או `null` אם לא דו-קוטרי.
int? od2Of(LipskeyCatalogProduct p) {
  final m = _kReducer.firstMatch(p.nameHe) ??
      _kReducer.firstMatch(p.dims?['מידה']?.toString() ?? '');
  if (m == null || m.group(1) == m.group(2)) return null;
  return int.tryParse(m.group(2)!);
}

/// המנוע יכול לגזור מידות למוצר הזה? (משפחה מוכרת + OD בטבלת-העומק).
/// `false` ⇒ fallback-לתמונה, לעולם לא 3D-שגוי (M1).
bool engineCanRender(LipskeyCatalogProduct p) {
  final fam = familyOf(p);
  final od = odOf(p);
  if (fam == null || od == null) return false;
  if (fam == 'ברך מחותכת') return true; // גדולה — טווח נפרד
  return kDepth.containsKey(od); // אביזר-ריתוך רגיל: OD חייב להיות בטבלת DIN
}
