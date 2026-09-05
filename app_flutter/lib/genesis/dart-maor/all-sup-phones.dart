// ⚛️ אטום-Dart (דרגת-חוזה) · allSupPhones — תורם ⇒ כל טלפוניו עם סיווג-אזור.
// מוצא: maor/src/components/supporters/lib.ts:283-292 · המקור: new/atoms/all-sup-phones.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכן phoneRegion הוזרק כשקע (חוק-1/חוק-3).
//
// תפקיד: שורה-פר-טלפון של תורם. הטלפון-הראשי (sp.phone) ראשון עם primary:true ו-label/note
//        ריקים, ואז כל sp.phones (מדלג על ריקי-num), כל אחד primary:false עם label/note/wa
//        שלו. לכל שורה region=phoneRegion(num).
// קלט:  sp (Map של תורם: phone? · phones? = List של {num,label?,note?,wa?}) ·
//        השקע phoneRegion(num) ⇒ 'il'|'intl'. פלט: List<Map> בסדר: ראשי (אם קיים) ואז נוספים.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness: `if (sp.phone)` ו-`if (!p.num)` הם בדיקת-אמת של JS (מחרוזת-ריקה=false,
//    null/undefined=false). מומש ב-`_truthy` שמחקה `!!` לתחום (null/bool/String/num) —
//    כך '' של num בדוגמה 5 מדולג בדיוק כמו במקור.
//  • `!!p.wa` → `_truthy(m['wa'])` (לא `== true` בלבד — שמירה על סמנטיקת-`!!` המלאה).
//  • `p.label ?? ''` / `p.note ?? ''` → `?? ''` — ה-`??` של JS תופס רק null/undefined,
//    לא מחרוזת-ריקה; ל-`??` של Dart אותה סמנטיקה (null בלבד) ⇒ זהה.
//  • `sp.phones ?? []` → `(sp['phones'] as List?) ?? const []`.
//  • מוטביליות: `rows` הוא final (התוכן מוטבל דרך add); שאר-המקומיים final. אין locale/
//    פורמט/getMonth — הפורמט (region) חי כולו בשקע המוזרק.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/false ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// A supporter's phones as rows — primary sp.phone first (label/note empty, primary:true),
/// then each sp.phones entry (skipping empty num), primary:false with its own label/note/wa.
/// Each row carries region = phoneRegion(num). Verbatim port of new/atoms/all-sup-phones.mjs
/// (`allSupPhones`); the neighbour call `phoneRegion` is injected as a socket (Law 1/3).
List<Map<String, dynamic>> allSupPhones(
  Map<String, dynamic> sp,
  String Function(String) phoneRegion,
) {
  final rows = <Map<String, dynamic>>[];
  final phone = sp['phone'];
  if (_truthy(phone)) {
    rows.add({
      'num': phone,
      'label': '',
      'note': '',
      'wa': false,
      'region': phoneRegion(phone as String),
      'primary': true,
    });
  }
  final phones = (sp['phones'] as List?) ?? const [];
  for (final p in phones) {
    final m = p as Map<String, dynamic>;
    final num = m['num'];
    if (!_truthy(num)) continue;
    rows.add({
      'num': num,
      'label': m['label'] ?? '',
      'note': m['note'] ?? '',
      'wa': _truthy(m['wa']),
      'region': phoneRegion(num as String),
      'primary': false,
    });
  }
  return rows;
}
