// ⚛️ אטום-Dart (דרגת-חוזה) · visibleSupportersForDesignations — סינון תורמים+תרומות לפי ייעודים.
// מוצא: maor/src/components/supporters/lib.ts:75-93 · המקור: new/atoms/visible-supporters-for-designations.mjs.
// טוהר: פונקציות top-level עצמאיות, אפס import (רק dart:core). חוק-4 — זהה-ביט למקור-ה-JS.
// השכן-הפנימי supporterVisibleForDesignations מוטמע כעוזר _ (כמו במקור — חוק-החשמלאי inline).
//
// תפקיד: allowed ריק/כוזב ⇒ הרשימה כמות-שהיא (אותה רפרנס). אחרת: רק תורמים שה-forWho
//        שלהם (אחרי trim) נמצא ברשימת-הייעודים; ולכל תורם — עותק-רדוד שבו donations
//        מסונן (purpose ריק ⇒ נשאר; purpose מלא ⇒ רק אם ברשימה).
//
// הערות-המרה (מקור→Dart) — הגארד משוחזר ביט-אחר-ביט:
//  • `!allowed || !allowed.length` — truthiness-JS (חוק-7): '' /0/-0/NaN/null כוזבים.
//    `allowed.length` = דוק-טייפינג (חוק-15): ל-1 (מספר) אין length ⇒ undefined ⇒ כוזב
//    ⇒ early-return. מיושם ב-_falsy + _lenOf (null=undefined). לכן הפרמטרים dynamic —
//    הקלטות-ה-Golden מזרימות מחרוזת/מספר ומצפות להחזרה-כמות-שהיא.
//  • `.trim()` של JS = קבוצת-ES בלבד (חוק-16): ‏U+0085/U+180E לא נגזמים (Dart.trim כן) ⇒ _trimJs.
//  • `sup.forWho ?? ''` / `d.purpose ?? ''` — גישת-מאפיין ⇒ אינדוקס-מפה; מפתח-חסר ⇒ null (כמו
//    undefined תחת ??). ‏`{...sup, donations:…}` ⇒ Map.from + השמה (סדר-מפתחות זהה: קיים
//    נשאר במקומו, חדש נוסף בסוף — כמו spread-JS).
//  • `sup.donations ?? []` — רק null/חסר ⇒ []; רשימה-ריקה נשארת ריקה. פילטר ⇒ List חדש (כמו JS).

/// JS-truthiness (חוק-7): false/null/0/-0/NaN/'' כוזבים; כל השאר אמת.
bool _falsy(dynamic v) {
  if (v == null || v == false) return true;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// דוק-טייפינג `.length` (חוק-15): מחרוזת/רשימה ⇒ האורך; אחרת null (= undefined ב-JS).
dynamic _lenOf(dynamic v) {
  if (v is String) return v.length;
  if (v is List) return v.length;
  return null;
}

/// קבוצת-הרווחים של ES (חוק-16) — בלי U+0085/U+180E.
bool _isJsWs(int c) =>
    c == 0x09 ||
    c == 0x0A ||
    c == 0x0B ||
    c == 0x0C ||
    c == 0x0D ||
    c == 0x20 ||
    c == 0xA0 ||
    c == 0x1680 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000 ||
    c == 0xFEFF;

/// String.prototype.trim של JS — גוזם אך ורק את קבוצת-ES.
String _trimJs(String s) {
  var i = 0;
  var j = s.length;
  while (i < j && _isJsWs(s.codeUnitAt(i))) {
    i++;
  }
  while (j > i && _isJsWs(s.codeUnitAt(j - 1))) {
    j--;
  }
  return s.substring(i, j);
}

/// השכן-הפנימי המוטמע (מקור: lib.ts:55-68): האם התורם גלוי תחת רשימת-הייעודים.
bool _supporterVisibleForDesignations(dynamic sup, dynamic allowed) {
  if (_falsy(allowed) || _falsy(_lenOf(allowed))) return true;
  final fw = _trimJs(((sup as Map)['forWho'] as String?) ?? '');
  if (fw.isEmpty) return false;
  final set = <String>{
    for (final s in allowed as List) _trimJs(s as String),
  };
  return set.contains(fw);
}

/// Verbatim port של new/atoms/visible-supporters-for-designations.mjs
/// (`visibleSupportersForDesignations`). ‏allowed כוזב/ריק/בלי-length ⇒ supporters
/// כמות-שהוא (אותה רפרנס — לכן dynamic); אחרת רשימה חדשה של עותקים-רדודים מסוננים.
dynamic visibleSupportersForDesignations(dynamic supporters, dynamic allowed) {
  if (_falsy(allowed) || _falsy(_lenOf(allowed))) return supporters;
  final set = <String>{
    for (final s in allowed as List) _trimJs(s as String),
  };
  final out = <dynamic>[];
  for (final sup in supporters as List) {
    if (!_supporterVisibleForDesignations(sup, allowed)) continue;
    final m = Map<String, dynamic>.from(sup as Map);
    final donations = (sup['donations'] as List?) ?? <dynamic>[];
    m['donations'] = donations.where((d) {
      final p = _trimJs(((d as Map)['purpose'] as String?) ?? '');
      return p.isEmpty || set.contains(p);
    }).toList();
    out.add(m);
  }
  return out;
}
