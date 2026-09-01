// ⚛️ אטום-Dart (דרגת-חוזה) · applyMetaPartial — מיזוג מסמך-meta מרוחק לתוך ה-DB.
// מוצא: maor/src/lib/cloud-merge.ts:106-141 · המקור: new/atoms/apply-meta-partial.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שני דינים (חוזה apply-meta-partial.contract.md):
//   (א) שדות "הענן-מנצח" (orgName·orgSite·orgDonate·orgGoal·budget·usdRate·audit·
//       notif·reports·ui·attnDone) — ערך שהוגדר (לא-undefined) ושונה מהמקומי נכתב;
//       undefined מדולג. ההשוואה = JSON (שוויון-עמוק תלוי-סדר, כמו המקור).
//   (ב) מונים רק-עולים (seq·receiptSeq·donationSeq·shopReceiptSeq) — נכתבים רק
//       כשהערך המרוחק מספר-סופי גדול מהמקומי.
//   אפס-שינויים ⇒ מוחזר אותו db (identical). ה-db הנכנס לעולם לא משוכתב.
//
// 🔧 תיקון-הסגר (null↔undefined + null↔מפתח-חסר): המקור JS מבחין בין
//   `undefined` (מדולג) לבין JSON `null` (מוקצה — ניקוי-שדה מ-Firestore).
//   ב-Dart אין `undefined`; הקונבנציה: JS-undefined ⇒ מפתח-חסר במפה; JS-null ⇒
//   מפתח-קיים עם ערך null. לכן:
//     • דילוג-undefined ⇒ `if (!meta.containsKey(k)) return;` (לא `v == null`).
//     • ההשוואה מחקה `JSON.stringify(db[k]) !== JSON.stringify(v)`: ב-JS
//       `JSON.stringify(undefined)` = הערך undefined (לא המחרוזת 'null'), ולכן
//       db חסר-המפתח ≠ null-מפורש. הבחנה מבנית: db חסר-המפתח ⇒ סנטינל (Dart-null),
//       שלעולם שונה מכל `_jsonStr` של ערך-קיים (כולל 'null'). לא מיפוי-גורף ל-'null'.
//
// הערות-המרה נוספות (מקור→Dart), חוק-4:
//   • `v > db[k]` כש-db[k] חסר: ב-JS `n > undefined` = false. ב-Dart db[k] חסר = null;
//     לכן משווים רק כאשר db[k] הוא num (אחרת דילוג = false), מקביל-התנהגות למקור.
//   • `typeof v === 'number' && Number.isFinite(v)` ⇒ `v is num && v.isFinite`
//     ('99' מחרוזת ⇒ לא num ⇒ דילוג; Infinity ⇒ num אך !isFinite ⇒ דילוג).

/// Merges a remote meta document into [db] (cloud-wins for org fields;
/// monotonic-up counters). Returns a new map on change, or the same [db]
/// reference (identical) when nothing changed. [db] is never mutated.
/// Verbatim behaviour of the JS source `applyMetaPartial`.
Map<String, Object?> applyMetaPartial(
  Map<String, Object?> db,
  Map<String, Object?> meta,
) {
  final next = Map<String, Object?>.from(db);
  var changed = false;

  // דין (א): הענן-מנצח. JS-undefined(=מפתח-חסר ב-Dart) מדולג; ערך שונה (JSON) נכתב.
  void assign(String k) {
    if (!meta.containsKey(k)) return; // JS: `if (v === undefined) return;`
    final v = meta[k];
    // JS: `JSON.stringify(db[k]) !== JSON.stringify(v)`.
    // db חסר-המפתח ⇒ JSON.stringify(undefined) = undefined (הערך) ⇒ סנטינל null,
    // ששונה מ-vStr (מחרוזת תמיד, כולל 'null'). db קיים-null ⇒ _jsonStr='null'.
    final String? dbStr = db.containsKey(k) ? _jsonStr(db[k]) : null;
    final String vStr = _jsonStr(v);
    if (dbStr != vStr) {
      next[k] = v;
      changed = true;
    }
  }

  assign('orgName');
  assign('orgSite');
  assign('orgDonate');
  assign('orgGoal');
  assign('budget');
  assign('usdRate');
  assign('audit');
  assign('notif');
  assign('reports');
  assign('ui');
  assign('attnDone');

  // דין (ב): מונים — לעולם לא מקטינים (מונע התנגשות מזהים/מספרי-קבלה בין מכשירים).
  void bumpCounter(String k) {
    final v = meta[k];
    final dbv = db[k];
    if (v is num && v.isFinite && dbv is num && v > dbv) {
      next[k] = v;
      changed = true;
    }
  }

  bumpCounter('seq');
  bumpCounter('receiptSeq');
  bumpCounter('donationSeq');
  bumpCounter('shopReceiptSeq');

  return changed ? next : db;
}

/// סריאליזציית-JSON קנונית לצורך השוואת-שוויון בלבד (מקביל ל-JSON.stringify).
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
    v.forEach((key, val) {
      if (!first) sb.write(',');
      first = false;
      sb.write(_quote(key.toString()));
      sb.write(':');
      sb.write(_jsonStr(val));
    });
    sb.write('}');
    return sb.toString();
  }
  return _quote(v.toString());
}

/// מספר בפורמט JSON.stringify: שלמים ללא ".0"; NaN/Infinity ⇒ 'null'.
String _numStr(num v) {
  if (v is int) return v.toString();
  final d = v.toDouble();
  if (d.isNaN || d.isInfinite) return 'null';
  if (d == 0) return '0'; // כולל -0.0
  final neg = d < 0;
  final ad = neg ? -d : d;
  String body;
  if (ad == ad.truncateToDouble() && ad < 1e21) {
    // שלם-ערך בטווח [1,1e21): עשרוני-מלא בלי ".0". <2^53 ⇒ int מדויק;
    // מעל ⇒ toStringAsFixed(0) (כמו jsStr המאומת).
    if (ad < 9007199254740992.0) {
      body = ad.toInt().toString();
    } else {
      body = ad.toStringAsFixed(0);
    }
  } else {
    body = ad.toString();
  }
  return neg ? '-$body' : body;
}

/// מחרוזת מצוטטת-JSON עם escaping תקני (תווים לא-ASCII נשמרים כמות-שהם).
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
