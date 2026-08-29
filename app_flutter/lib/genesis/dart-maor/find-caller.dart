// ⚛️ אטום-Dart (דרגת-חוזה) · findCaller — זיהוי-מתקשר לפי מספר (screen-pop).
// מוצא: maor/src/lib/callerId.ts:70-112 · המקור: new/atoms/find-caller.mjs.
// חוזה: new/atoms/find-caller.contract.md.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: התאמת מספר-מתקשר לאיש-קשר שמור, בסדר-עדיפות קשיח:
//        משפחה (ראשי/נוסף) → בן-משפחה → תורם → מתנדב → רכז. מפתח < 6 ⇒ null.
// שקע (חוק-1): phoneKey(raw) ⇒ מחרוזת — מפתח-השוואת-טלפון (השכן שהוזרק כפרמטר).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//   • truthiness (כלל-7): ‏JS `!!p`, `f.phone || f.phone2`, `db.volunteers || []`
//     נאמנים דרך `_truthy` (מחרוזת-ריקה/null = כוזב) ו-`_or`. השדות ה"נדרשים"
//     (families/supporters) ניגשים ישירות כמו במקור; ה"רשות" (members/volunteers/
//     tzCoordinators) עם נפילת-`[]` בדיוק כמו ה-`|| []` של המקור.
//   • שקע-הצבה בלבד; אין locale/פורמט/getMonth/תאריך-מגלגל/substring-שלילי כאן.

/// JS-truthiness for the values this atom meets (strings from the db).
/// Empty string and null are falsy; a non-empty string is truthy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is String) return v.isNotEmpty;
  if (v is bool) return v;
  if (v is num) return v != 0;
  return true;
}

/// Mirrors JS `a || b`: yields `a` when truthy, otherwise `b`.
Object? _or(Object? a, Object? b) => _truthy(a) ? a : b;

/// Identify an incoming caller by number. Verbatim behaviour of the JS source
/// `findCaller`: family (primary/secondary) → member → supporter → volunteer →
/// coordinator; a key shorter than 6 digits, or no match, yields null.
Map<String, Object?>? findCaller(
  Map<String, Object?> db,
  String raw,
  String Function(String) phoneKey,
) {
  final key = phoneKey(raw);
  if (key.length < 6) {
    return null; // קצר מדי = לא בר-התאמה בטוחה (הימנעות מ-false-positive)
  }

  bool hit(Object? p) => _truthy(p) && phoneKey(p as String) == key;

  final families = db['families'] as List;
  for (final f in families) {
    final fm = f as Map;
    if (hit(fm['phone']) || hit(fm['phone2'])) {
      return {
        'kind': 'family',
        'name': fm['name'],
        'phone': _or(fm['phone'], fm['phone2']),
        'id': fm['id'],
        'view': 'families',
        'famId': fm['id'],
      };
    }
  }
  for (final f in families) {
    final fm = f as Map;
    final members = (fm['members'] as List?) ?? const [];
    for (final m in members) {
      final mm = m as Map;
      if (hit(mm['phone']) || hit(mm['phone2'])) {
        return {
          'kind': 'member',
          'name': '${mm['first']} · ${fm['name']}',
          'phone': _or(mm['phone'], mm['phone2']),
          'id': mm['id'],
          'view': 'families',
          'famId': fm['id'],
        };
      }
    }
  }
  final supporters = db['supporters'] as List;
  for (final s in supporters) {
    final sm = s as Map;
    if (hit(sm['phone'])) {
      return {
        'kind': 'supporter',
        'name': sm['name'],
        'phone': sm['phone'],
        'id': sm['id'],
        'view': 'supporters',
      };
    }
  }
  final volunteers = (db['volunteers'] as List?) ?? const [];
  for (final v in volunteers) {
    final vm = v as Map;
    if (hit(vm['phone'])) {
      return {
        'kind': 'volunteer',
        'name': vm['name'],
        'phone': vm['phone'],
        'id': vm['id'],
        'view': 'shop7',
      };
    }
  }
  final coords = (db['tzCoordinators'] as List?) ?? const [];
  for (final c in coords) {
    final cm = c as Map;
    if (hit(cm['phone'])) {
      return {
        'kind': 'coordinator',
        'name': cm['name'],
        'phone': cm['phone'],
        'id': cm['id'],
        'view': 'tzedaka',
      };
    }
  }
  return null;
}
