// ⚛️ אטום-Dart · familyOf
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/catalog_map.dart:34-49 (חצב-בינה · מפל-מינימום · חוק-4).

/// מוצר-קטלוג (מוטבע-מינימום — רק שני השדות שהגשר נוגע בהם).
class LipskeyCatalogProduct {
  const LipskeyCatalogProduct({
    required this.categoryHe,
    required this.nameHe,
  });

  final String categoryHe;
  final String nameHe;
}

// ── consts מוטבעים verbatim (חוק-3: השכן טהור ⇒ אטום-מלא) ──────────────────
const String kPprElbows = 'ברכיים PPR';
const String kPprTees = 'מסעפים PPR';
const String kPprCouplers = 'מצמדים PPR';
const String kPprAdapters = 'מתאמים PPR';
const String kPprSaddles = 'רוכבים PPR';
const String kPprPlugs = 'פקקים PPR';
const String kPprValves = 'ברזים PPR';
const String kPprCollars = 'צווארונים ואוגנים PPR';

/// קטגוריית-קטלוג → שם-משפחת-מנוע.
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
