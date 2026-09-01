// ⚛️ אטום-Dart (דרגת-חוזה) · roomsNow — מצב-החדרים ברגע נתון (חדר-פעיל תפוס/פנוי + החוג התופס).
// מוצא: maor/src/components/courses/lib.ts:120-147 · המקור: new/atoms/rooms-now.mjs · חוזה: rooms-now.contract.md
// טוהר: פונקציית top-level, אפס import של אטום אחר (חוק-1) — השכן sessionsOf מוזרק כשקע-פרמטר.
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS, כולל קצוות.
//
// 🔧 תיקון-הסגר (כלל-2 · roomId null↔undefined בהשוואת-דילוג):
//   חדר בלי-id מול חוג עם ‏roomId:null: ‏JS ‏null!==undefined ⇒ מדלג (חדר פנוי);
//   ‏Dart גולמי ‏null==null ⇒ בוחן (חדר תפוס — באג). התיקון: ‏_prop מבחין מפתח-חסר
//   (‏undefined ⇒ סנטינל ‏_undefined) מ-null-מפורש בשני צדי ההשוואה של ‏!==.
//
// הערות-המרה (מקור→Dart):
// • ‏JS ‏getDay() ‏(0=ראשון) ⇒ ‏Dart ‏weekday % 7 ‏(weekday: ‏1=שני..7=ראשון ⇒ ‏7%7=0 ראשון). זהה-ביט.
// • ‏truthiness (כלל-7): ‏`r.active` / ‏`!s.time` / ‏`room.slot || 60` / ‏`h || 0` / ‏`if (busyWith)`
//   ⇒ ‏_jsFalsy (הועתק מ-js-compat-reference, חוק-1 אין-import).
// • ‏Number(x) של JS (כלל-10/18): ‏_jsStrToNum (הועתק מ-js-compat-reference) — ריק/רווחים ⇒ 0,
//   לא-מספרי ⇒ NaN; ואז ‏`h || 0` ממפה גם NaN ל-0 (דרך ‏_jsFalsy).
// • פירוק ‏`const [h, m]` על מערך קצר: איבר-חסר = ‏undefined ⇒ ‏(undefined||0)=0 — משוקף בקריאת part.
// • ‏`!==` של JS על ‏day/roomId ⇒ נאמנות undefined↔null דרך ‏_prop+_undefined.
// • הפלט: ‏{room, busyWith} — המפתח ‏busyWith קיים תמיד (undefined של JS ⇒ null), זהות-רפרנס נשמרת.
// • אין לוח-עברי/Intl (חוק-11 לא נדרש) — רק שעון-מקומי מוזרק (now פרמטר, טוהר).

/// סנטינל ל-undefined של JS (מפתח-חסר) — נבדל מ-null-מפורש. מופע-const יחיד ⇒ ‏==` בזהות.
const Object _undefined = Object();

/// קריאת-מאפיין נאמנת-JS: מפתח-קיים ⇒ ערכו (כולל null מפורש); מפתח-חסר ⇒ ‏_undefined.
Object? _prop(dynamic m, String k) {
  if (m is Map && m.containsKey(k)) return m[k];
  return _undefined;
}

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת. (הועתק מ-js-compat)
bool _jsTruthy(dynamic v) {
  if (identical(v, _undefined)) return false; // ‏undefined (מפתח-חסר) = falsy
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

bool _jsFalsy(dynamic v) => !_jsTruthy(v);

/// חוק-16 · קבוצת-הרווחים של ECMAScript (trim). (הועתק מ-js-compat)
const Set<int> _esWs = {
  0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x20, 0xA0, 0x1680,
  0x2000, 0x2001, 0x2002, 0x2003, 0x2004, 0x2005, 0x2006, 0x2007,
  0x2008, 0x2009, 0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF,
};

/// חוק-16 · trim נאמן-ES. (הועתק מ-js-compat)
String _jsTrim(String s) {
  var start = 0, end = s.length;
  while (start < end && _esWs.contains(s.codeUnitAt(start))) start++;
  while (end > start && _esWs.contains(s.codeUnitAt(end - 1))) end--;
  return s.substring(start, end);
}

double _fromRadix(String digits, int radix) {
  try {
    return BigInt.parse(digits, radix: radix).toDouble();
  } catch (_) {
    return double.nan;
  }
}

/// חוק-10/18 · ToNumber של JS על מחרוזת. (הועתק מ-js-compat)
double _jsStrToNum(String raw) {
  final s = _jsTrim(raw);
  if (s.isEmpty) return 0.0;
  if (s == 'Infinity' || s == '+Infinity') return double.infinity;
  if (s == '-Infinity') return double.negativeInfinity;
  if (RegExp(r'^0[xX][0-9a-fA-F]+$').hasMatch(s)) {
    return _fromRadix(s.substring(2), 16);
  }
  if (RegExp(r'^0[oO][0-7]+$').hasMatch(s)) return _fromRadix(s.substring(2), 8);
  if (RegExp(r'^0[bB][01]+$').hasMatch(s)) return _fromRadix(s.substring(2), 2);
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) {
    return double.nan;
  }
  return double.tryParse(s) ?? double.nan;
}

/// ‏Number(x) של JS על מקטע-מחרוזת בפירוק (מחזיר NaN על undefined כמו Number(undefined)).
num _jsNumberPart(Object? s) {
  if (s == null || identical(s, _undefined)) return double.nan;
  if (s is num) return s;
  return _jsStrToNum(s.toString());
}

/// מצב-החדרים ברגע נתון: לכל חדר **פעיל** ⇒ ‏{room, busyWith} — ‏busyWith = החוג
/// הראשון שמפגש שלו בחדר חל באותו יום-שבוע והשעה בתוך ‏[start, start+slot)
/// (‏slot = ‏room.slot או 60). ‏sessionsOf — שקע: המפגשים-בפועל של חוג (חוק-1).
List<dynamic> roomsNow(dynamic db, DateTime now, dynamic sessionsOf) {
  final day = now.weekday % 7; // JS getDay(): 0=ראשון..6=שבת
  final mins = now.hour * 60 + now.minute;

  // ‏toMin של המקור: split(':').map(Number) ⇒ ‏(h||0)*60+(m||0).
  num toMin(dynamic t) {
    final parts = t.toString().split(':');
    num part(int i) {
      // איבר-חסר בפירוק-JS = undefined ⇒ Number(undefined)=NaN ⇒ (NaN||0)=0
      final v = i < parts.length ? _jsNumberPart(parts[i]) : double.nan;
      return _jsFalsy(v) ? 0 : v; // ‏(x || 0) של JS
    }

    return part(0) * 60 + part(1);
  }

  final out = <dynamic>[];
  for (final room in (db['rooms'] as List)) {
    if (_jsFalsy(_prop(room, 'active'))) continue; // filter((r) => r.active)
    dynamic busyWith;
    for (final c in (db['courses'] as List)) {
      // ‏c.roomId !== room.id — נאמנות undefined↔null דרך _prop (הבאג המקורי).
      if (_prop(c, 'roomId') != _prop(room, 'id')) continue;
      for (final s in (sessionsOf(c) as List)) {
        // ‏s.day !== day || !s.time — day תמיד int ⇒ null/undefined שניהם ≠ day (זהה-JS).
        if (_prop(s, 'day') != day || _jsFalsy(_prop(s, 'time'))) continue;
        final num start = toMin((s as Map)['time']);
        final rawSlot = _prop(room, 'slot');
        final num slot = _jsFalsy(rawSlot) ? 60 : (rawSlot as num); // room.slot || 60
        if (mins >= start && mins < start + slot) {
          busyWith = c;
          break;
        }
      }
      if (!_jsFalsy(busyWith)) break; // ‏if (busyWith) של JS
    }
    // המפתח קיים תמיד (כמו האובייקט ב-JS); ‏undefined ⇒ null.
    out.add({'room': room, 'busyWith': busyWith});
  }
  return out;
}
