/// חוט · stale-boxes — קופות-צדקה אצל משפחות שלא רוקנו ≥N יום (או מעולם).
/// חוזה: new/atoms/stale-boxes.contract.md · המקור: new/atoms/stale-boxes.mjs
/// (חולץ מ-maor/src/components/tzedaka/lib.ts:80-89). חוק-4: התנהגות זהה-ביט.
/// השכנים isoOf ו-lastCollectionIso שקעים מוזרקים (חוק-1 — אפס import של אטום אחר).
///
/// הערות-המרה (הנקודות שבהן Dart היה סוטה):
///  • ‏JS ‏`days = 90` באמצע רשימת-הפרמטרים — ברירת-המחדל נדלקת רק על פרמטר
///    שלא-הועבר/undefined (כלל-2/כלל-15). ב-Dart: קבוצת-אופציונליים עם זקיף
///    ‏`_undefined`; ‏null-מפורש ≠ ברירת-מחדל — הוא עובר קוארציית-ToNumber ל-0
///    (‏JS: ‏`getDate() - null` ⇒ ‏`getDate() - 0`), בדיוק כמו במקור.
///  • ‏`cutoff.setDate(getDate() - days)` — הזזת-יום קלנדרית עם גלישת-חודש/שנה.
///    ‏DateTime של Dart בלתי-משתנה ⇒ בנאי ‏DateTime(y, m, day - d, 12) שמנרמל
///    גלישה בדיוק כמו setDate, בלי חשיפת-DST של ‎.add(Duration)‎ (דפוס-הריפו:
///    iso-days-ago / needs-care-tzedaka / expiring-intakes).
///  • ‏days עובר ‏ToNumber-שקול (כלל-15: null⇒0, bool⇒0/1, מחרוזת-מספרית⇒מספר).
///    צמצום-טיפוס מתועד (כלל-14): ‏days שברי/NaN מחוץ לחוזה (החוזה: מספר-ימים
///    שלם, ברירת-מחדל 90) — ערך לא-שלם נחתך לשלם.
///  • ‏`lastCollectionIso(b) || b.since` — ‏|| של JS על truthiness ('' = falsy) ⇒
///    ‏`_truthy` (כלל-7; ‏`??` היה מחמיץ '' שהמקור מטפל בו).
///  • מפתח-חסר במפה (b['since'] כשאין since) ⇒ null ⇒ falsy — זהה ל-undefined
///    שנופל ב-`!!last` במקור.
///  • ‏`last <= cut` — השוואת-מחרוזות לקסיקוגרפית של JS ⇒ ‏compareTo (זהה על
///    מחרוזות; ‏last מובטח-מחרוזת אחרי שער-ה-truthy בקלטי-החוזה).
///  • ‏filter ⇒ ‏where(...).toList() — מערך חדש של אותם איברים, סדר-מקור נשמר.
dynamic staleBoxes(dynamic boxes, dynamic todayIso,
    [dynamic days = _undefined,
    dynamic isoOf = _undefined,
    dynamic lastCollectionIso = _undefined]) {
  // JS: days = 90 רק כשהפרמטר לא-הועבר/undefined (לא על null!).
  final num d = identical(days, _undefined) ? 90 : _toNum(days);
  final base = DateTime.parse('${todayIso}T12:00:00');
  // JS: cutoff.setDate(cutoff.getDate() - days) — הבנאי מנרמל גלישה כמו setDate.
  final cutoff =
      DateTime(base.year, base.month, base.day - d.toInt(), base.hour,
          base.minute, base.second, base.millisecond, base.microsecond);
  final cut = isoOf(cutoff);
  return (boxes as List).where((b) {
    if (b['status'] != 'home') return false;
    final lc = lastCollectionIso(b);
    final last = _truthy(lc) ? lc : b['since'];
    return _truthy(last) && (last as String).compareTo(cut as String) <= 0;
  }).toList();
}

/// זקיף העומד במקום undefined של JS — פרמטר-שלא-הועבר (כלל-2: null ≠ undefined).
class _Undefined {
  const _Undefined();
}

const _Undefined _undefined = _Undefined();

/// ‏ToNumber-שקול של JS על ערכי-days (כלל-15): null⇒0, bool⇒0/1, num⇒עצמו,
/// מחרוזת⇒פרסור (ריקה⇒0, לא-מספרית⇒NaN).
num _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v;
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0;
    return num.tryParse(t) ?? double.nan;
  }
  return double.nan;
}

/// truthiness של JS: null/false/0/NaN/'' = falsy; כל השאר truthy (כלל-7).
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
