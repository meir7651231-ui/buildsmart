// ⚛️ אטום-Dart (דרגת-חוזה) · donationPartitionDiff — diff מסמכי-תרומה בין שתי רשימות-תומכים.
// מוצא: maor/src/lib/donationPartition.ts:103-120 · המקור: new/atoms/donation-partition-diff.mjs
//        החוזה: donation-partition-diff.contract.md (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השכן explodeSupporter
//        הוזרק כשקע-פרמטר (חוק-1/חוק-3) — בדיוק כמו במקור.
//
// תפקיד: משווה שתי רשימות-תומכים ברמת מסמכי-התרומה (id⇒doc). מסמך חדש/משתנה ⇒ sets;
//        מסמך שהיה ונעלם ⇒ deletes (מזהה בלבד). מעבר-תומך = set ולא-מחיקה (ה-id נשמר).
// קלט:  prev · next (רשימות-תומכים) · השקע explodeSupporter(sp) ⇒ List<doc> כש-doc.id ייחודי.
// פלט:  { sets: List<doc>, deletes: List<id> }.
//
// הערות-המרה (מקור→Dart):
//  • `new Map()` ⇒ Dart Map (LinkedHashMap) — שומר סדר-הכנסה, בדיוק כמו Map של JS.
//    ‏`for (const [id, doc] of nextDocs)` ⇒ `forEach` על סדר-ההכנסה ⇒ סדר-sets זהה (דוגמה 1).
//  • `!before` — before הוא doc (תמיד truthy) או undefined (המפתח חסר). ב-Dart `prevDocs[id]`
//    מחזיר null כשחסר; לפיכך `before == null` ≡ `!before` (חוק-2 של DART-PORTING: כאן
//    המסמך לעולם אינו null-מפורש, ולכן null ⇒ 'לא-קיים' — התנהגות זהה).
//  • `JSON.stringify(a) !== JSON.stringify(b)` ⇒ `_jsonStr` מקומי ששומר סדר-מפתחות
//    (אין dart:convert — מגבלת-import dart-core/dart:math; סריאלייזר תואם-JSON מינימלי).
//  • `m.set(doc.id, doc)` / `map.get(id)` / `map.has(id)` ⇒ `m[k]=v` / `m[k]` / `containsKey`.
//  • מוטביליות: sets/deletes = List צומחת (add). אין locale/פורמט/getMonth/truthiness מעורבים.

/// Diff donation documents between two supporter lists. A new-or-changed document
/// lands in `sets`; a document that vanished lands in `deletes` (id only). A donation
/// that moved between supporters is a set, not a delete (its id survives).
/// Verbatim port of new/atoms/donation-partition-diff.mjs (`donationPartitionDiff`).
/// The neighbour `explodeSupporter` is injected as a socket (Law 1/3).
Map<String, dynamic> donationPartitionDiff(
  Iterable prev,
  Iterable next,
  Iterable<Map<String, dynamic>> Function(dynamic sp) explodeSupporter,
) {
  Map<dynamic, Map<String, dynamic>> index(Iterable list) {
    final m = <dynamic, Map<String, dynamic>>{};
    for (final sp in list) {
      for (final doc in explodeSupporter(sp)) {
        m[doc['id']] = doc;
      }
    }
    return m;
  }

  final prevDocs = index(prev);
  final nextDocs = index(next);

  final sets = <Map<String, dynamic>>[];
  nextDocs.forEach((id, doc) {
    final before = prevDocs[id];
    if (before == null || _jsonStr(before) != _jsonStr(doc)) sets.add(doc);
  });

  final deletes = <dynamic>[];
  for (final id in prevDocs.keys) {
    if (!nextDocs.containsKey(id)) deletes.add(id);
  }

  return {'sets': sets, 'deletes': deletes};
}

// ── עזרי-טוהר פנימיים (top-level, לא-מיוצאים) ──

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
