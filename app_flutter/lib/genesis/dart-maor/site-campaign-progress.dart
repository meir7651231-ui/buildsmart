// חוט · site-campaign-progress — התקדמות-קמפיין וספירה-לאחור של האתר-הציבורי
// (שונה מ-campaign-progress של הקופות). המרה נאמנה מ-new/atoms/site-campaign-progress.mjs
// (חוק-4: התנהגות זהה-ביט; המקור קדוש). חוזה: site-campaign-progress.contract.md
// מוצא-המקור: maor/src/lib/publicSite.ts:218-236 (‏campaignProgress).
//
// ‏nowMs מוזרק (שקע-זמן — אפס DateTime.now, טהור/בדיק). אפס-import (dart-core בלבד).
// אובייקט-JS ⇒ Map (מוסכמת-ההמרה); ‏c?.goal ⇒ גישת-Map בטוחה-null.
//
// 🔧 תיקון-הסגר (FIXES: "Date.parse צורות-קצרות"):
//   ‏JS מבצע `Date.parse(c.end.slice(0,10) + 'T00:00:00')`. ‏V8 מקבל *חלק-תאריך
//   חלקי* לצד ה-T ובודה חודש/יום חסרים ל-1, בפרשנות *מקומית*:
//     "2027"        → "2027T00:00:00"        ⇒ חצות-מקומי 2027-01-01
//     "2026-05"     → "2026-05T00:00:00"     ⇒ חצות-מקומי 2026-05-01
//     "2026-09-11"  → "2026-09-11T00:00:00"  ⇒ חצות-מקומי 2026-09-11
//   הטיוטה השבורה דרשה אורך-10 בדיוק ⇒ צורות 4/7 החזירו null ⇒ daysLeft:null שגוי.
//   התיקון: הפרסר מקבל את שלוש הצורות ‏YYYY / YYYY-MM / YYYY-MM-DD (אחרי slice(0,10)),
//   בודה חודש/יום חסרים ל-1, מאמת חודש 01–12 ויום 01–31 לקסיקלית (13/00/32+ ⇒ null),
//   ובונה DateTime מקומי (מגלגל-יום כמו V8: 2026-09-31 ⇒ 1.10). אומת מול node ב-TZ שונה.
//
// הערות-המרה נוספות (DART-PORTING-RULES):
// - חוק-7 (truthiness): ‏`if (c?.end)` ו-`c?.currency || '₪'` ⇒ עוזר ‏_jsTruthy
//   (‏'' ריק/0/NaN/false/null = שקר, כמו JS; ‏`??` היה שוגה על '').
// - ‏Math.round/ceil/min/max של JS מחלחלים NaN ואינסוף; ‏round/ceil של Dart זורקים
//   עליהם ⇒ עוזרים ‏_jsRound/_jsCeil/_jsMin/_jsMax נאמני-JS.

/// truthiness של JS (מוזרק inline מ-js-compat-reference · jsTruthy):
/// null/false/0/-0/NaN/'' ⇒ שקר; כל השאר אמת.
bool _jsTruthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Math.round של JS — מחלחל NaN/אינסוף (round של Dart זורק עליהם).
num _jsRound(num x) {
  if (x is double && (x.isNaN || x.isInfinite)) return x;
  return x.round();
}

/// Math.ceil של JS — מחלחל NaN/אינסוף.
num _jsCeil(num x) {
  if (x is double && (x.isNaN || x.isInfinite)) return x;
  return x.ceil();
}

/// Math.min של JS — NaN בכל צד ⇒ NaN.
num _jsMin(num a, num b) {
  if (a.isNaN || b.isNaN) return double.nan;
  return a < b ? a : b;
}

/// Math.max של JS — NaN בכל צד ⇒ NaN.
num _jsMax(num a, num b) {
  if (a.isNaN || b.isNaN) return double.nan;
  return a > b ? a : b;
}

/// ‏Date.parse('<חלק-תאריך>T00:00:00') של V8 — חצות-מקומי, בדיית-חודש/יום ל-1.
/// מקבל את הצורות שאחרי slice(0,10): YYYY (4) · YYYY-MM (7) · YYYY-MM-DD (10).
/// מחזיר מילישניות-מאז-אפוך, או null (מקביל ל-NaN של JS) על צורה שבורה.
num? _parseLocalMidnightMs(String s) {
  int y, m = 1, d = 1;
  if (RegExp(r'^\d{4}$').hasMatch(s)) {
    y = int.parse(s);
  } else if (RegExp(r'^\d{4}-\d{2}$').hasMatch(s)) {
    y = int.parse(s.substring(0, 4));
    m = int.parse(s.substring(5, 7));
  } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    y = int.parse(s.substring(0, 4));
    m = int.parse(s.substring(5, 7));
    d = int.parse(s.substring(8, 10));
  } else {
    return null;
  }
  if (m < 1 || m > 12 || d < 1 || d > 31) return null;
  return DateTime(y, m, d).millisecondsSinceEpoch; // מקומי, מגלגל-יום כמו V8
}

/// התקדמות-קמפיין של האתר-הציבורי: יעד/נאסף/אחוז-חסום-ומעוגל/מטבע/ימים-נותרו/הצגה.
/// ‏c = Map (אובייקט-הקונפיג) או null/חסר; ‏nowMs = שקע-הזמן (מילישניות).
Map<String, dynamic> campaignProgress(dynamic c, dynamic nowMs) {
  final rawGoal = c == null ? null : c['goal'];
  final rawRaised = c == null ? null : c['raised'];
  final num goal = (rawGoal is num && rawGoal > 0) ? rawGoal : 0;
  final num raised = (rawRaised is num && rawRaised > 0) ? rawRaised : 0;
  final num pct =
      goal > 0 ? _jsMax(0, _jsMin(100, _jsRound((raised / goal) * 100))) : 0;
  num? daysLeft;
  final end = c == null ? null : c['end'];
  if (_jsTruthy(end)) {
    // חצות-מקומי של יום-היעד (חלק-התאריך בלבד) — ספירת ימים קלנדרית: מ-1.9 ל-11.9
    // = 10 (ולא 11 שנוצר מחישוב סוף-יום). עבר ⇒ 0.
    final s = end as String; // JS היה זורק TypeError על .slice של לא-מחרוזת
    final t = _parseLocalMidnightMs(s.length < 10 ? s : s.substring(0, 10));
    if (t != null) {
      final diff = _jsCeil((t - nowMs) / 86400000);
      daysLeft = diff > 0 ? diff : 0;
    }
  }
  final cur = c == null ? null : c['currency'];
  return {
    'goal': goal,
    'raised': raised,
    'pct': pct,
    'currency': _jsTruthy(cur) ? cur : '₪',
    'daysLeft': daysLeft,
    'show': goal > 0,
  };
}
