// ⚛️ אטום-Dart (דרגת-חוזה) · applyEntityPartial — מיזוג שינויי-אוסף מרוחקים (upsert לפי id)
// מוצא: maor/src/lib/cloud-merge.ts:73-105 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/apply-entity-partial.mjs · החוזה: apply-entity-partial.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). שלושת השכנים
//        (entityCollections/sanitizeIncoming/mergeDonationsPreserving) = שקעי-פרמטר (חוק-1).
//
// תפקיד: מיזוג שינויי-אוסף מרוחקים לרשימה מקומית — עדכונים במקומם (שומר סדר),
//        חדשים לראש-הרשימה, מחוקים (deleted) יוצאים. תוצאה ביט-זהה ⇒ אותה רפרנס-db.
//
// הערות-המרה (מקור→Dart):
//  • `JSON.stringify` להשוואת-זהות מומר ל-`_jsonStr` מקומי ששומר סדר-הכנסת-מפתחות
//    (Dart Map = LinkedHashMap ⇒ סדר-הכנסה נשמר, בדיוק כמו object של JS). אין dart:convert
//    (מגבלת-import: dart-core/dart:math בלבד) — כתבנו סריאלייזר תואם-JSON מינימלי.
//  • truthiness של `d.deleted`/`!d.deleted` מומר ל-`_truthy` (null/false/0/''/NaN ⇒ falsy),
//    כדי לשמר בדיוק את סמנטיקת-ה-JS גם למסמך בלי שדה deleted.
//  • `{ ...d.data, id: d.id }` — spread ואז השמת-id: ב-Dart השמה למפתח-קיים שומרת את
//    מיקומו המקורי (כמו JS), ולכן data שכבר מכיל id שומר על סדר-מפתחותיו (דוגמה 5).
//  • `incoming.get(x.id)` (אובייקט תמיד truthy במקור) ⇒ `containsKey` ב-Dart.
//  • אין locale/פורמט/getMonth מעורבים.

/// Merge a remote collection patch into the local DB list (upsert by id):
/// in-place updates keep order, new docs go to the front, `deleted` docs drop out.
/// Bit-identical result ⇒ same `db` reference returned (verbatim of the JS source
/// new/atoms/apply-entity-partial.mjs). Neighbours are injected as sockets (Law 1).
Map<String, dynamic> applyEntityPartial(
  Map<String, dynamic> db,
  String col,
  List<Map<String, dynamic>> docs,
  List<String> entityCollections,
  Map<String, dynamic> Function(String col, Map<String, dynamic> item)
      sanitizeIncoming,
  Map<String, dynamic> Function(
          String col, Map<String, dynamic> local, Map<String, dynamic> incoming)
      mergeDonationsPreserving,
) {
  if (!entityCollections.contains(col)) return db;
  final String key = col;
  final List list = db[key] as List;

  final Set<Object?> deleted = docs
      .where((d) => _truthy(d['deleted']))
      .map((d) => d['id'])
      .toSet();

  // סדר-הכנסה נשמר (LinkedHashMap) — מקביל ל-Map של JS על סדר-ה-docs.
  final Map<Object?, Map<String, dynamic>> incoming = {};
  for (final d in docs) {
    if (_truthy(d['deleted'])) continue;
    final Map<String, dynamic> data =
        (d['data'] as Map).cast<String, dynamic>();
    final Map<String, dynamic> withId = {...data, 'id': d['id']};
    incoming[d['id']] = sanitizeIncoming(col, withId);
  }

  // עדכונים במקומם (שומר סדר), חדשים לראש הרשימה — כמו upsertIn של ה-store.
  final List<dynamic> kept = [];
  for (final x in list) {
    final Object? xid = (x as Map)['id'];
    if (deleted.contains(xid)) continue;
    if (incoming.containsKey(xid)) {
      final Map<String, dynamic> inc = incoming[xid]!;
      incoming.remove(xid);
      // מיזוג מקומי-מול-נכנס (בקוד-המקור: איחוד-תרומות חסין-אובדן לתומכים).
      final Map<String, dynamic> merged =
          mergeDonationsPreserving(col, x.cast<String, dynamic>(), inc);
      kept.add(merged);
    } else {
      kept.add(x);
    }
  }

  final List<dynamic> next = [...incoming.values, ...kept];
  if (_jsonStr(next) == _jsonStr(list)) return db;
  return {...db, key: next};
}

// ── עזרי-טוהר פנימיים (top-level, לא-מיוצאים) ──

/// JS truthiness: null/false/0/NaN/'' ⇒ false; אחרת ⇒ true.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// סריאלייזר תואם-JSON.stringify מינימלי — שומר סדר-הכנסת-מפתחות (זהות ביט-זהה).
String _jsonStr(Object? v) {
  if (v == null) return 'null';
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) return _numStr(v);
  if (v is String) return _quote(v);
  if (v is List) {
    final sb = StringBuffer('[');
    for (var i = 0; i < v.length; i++) {
      if (i > 0) sb.write(',');
      sb.write(_jsonStr(v[i]));
    }
    sb.write(']');
    return sb.toString();
  }
  if (v is Map) {
    final sb = StringBuffer('{');
    var first = true;
    v.forEach((k, val) {
      if (!first) sb.write(',');
      first = false;
      sb.write(_quote(k.toString()));
      sb.write(':');
      sb.write(_jsonStr(val));
    });
    sb.write('}');
    return sb.toString();
  }
  return 'null';
}

String _numStr(num v) {
  if (v is int) return v.toString();
  final d = v.toDouble();
  if (d.isFinite && d == d.roundToDouble()) return d.toInt().toString();
  return d.toString();
}

String _quote(String s) {
  final sb = StringBuffer('"');
  for (final rune in s.runes) {
    switch (rune) {
      case 0x22:
        sb.write('\\"');
        break;
      case 0x5C:
        sb.write('\\\\');
        break;
      case 0x08:
        sb.write('\\b');
        break;
      case 0x0C:
        sb.write('\\f');
        break;
      case 0x0A:
        sb.write('\\n');
        break;
      case 0x0D:
        sb.write('\\r');
        break;
      case 0x09:
        sb.write('\\t');
        break;
      default:
        if (rune < 0x20) {
          sb.write('\\u');
          sb.write(rune.toRadixString(16).padLeft(4, '0'));
        } else {
          sb.write(String.fromCharCode(rune));
        }
    }
  }
  sb.write('"');
  return sb.toString();
}
