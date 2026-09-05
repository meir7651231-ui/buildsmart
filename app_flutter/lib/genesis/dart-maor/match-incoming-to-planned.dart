/// חוט · match-incoming-to-planned — שיוך תשלום-נכנס לחיוב-מתוכנן יחיד.
/// המרה נאמנה מ-new/atoms/match-incoming-to-planned.mjs (חוק-4: המקור קדוש).
/// חולץ מ-maor/src/lib/plannedMatch.ts:107-129 (matchIncomingToPlanned).
/// השכנים nameMatches (דמיון-שם) ו-dayDiff (מרחק-ימים) מוזרקים כשקעים (חוק-1).
/// DATE_WINDOW_DAYS = 3: ערך-הסף של האטום עצמו (טווח ±3 ימים).
/// אפס import חוץ מ-dart:math (Math.round/Math.max).
import 'dart:math' as math;

const int _dateWindowDays = 3;

Map<String, dynamic>? matchIncomingToPlanned(
  Map<String, dynamic> inc,
  List<Map<String, dynamic>> allOpen,
  bool Function(String refName, String incName) nameMatches,
  num Function(String isoA, String isoB) dayDiff,
) {
  final targetCents = ((inc['amount'] as num) * 100).round();
  // JS: (inc.at || '').slice(0, 10) — falsy⇒'' , slice סלחן על מחרוזת קצרה.
  final atRaw = inc['at'];
  final atStr = (atRaw is String && atRaw.isNotEmpty) ? atRaw : '';
  final incDate = atStr.length >= 10 ? atStr.substring(0, 10) : atStr; // ISO

  // JS: inc.name || '' — falsy (null/undefined/'')⇒''.
  final nameRaw = inc['name'];
  final incName = (nameRaw is String && nameRaw.isNotEmpty) ? nameRaw : '';

  final candidates = <Map<String, dynamic>>[];
  for (final ref in allOpen) {
    final plan = ref['plan'] as Map<String, dynamic>;
    final planCents = ((plan['amount'] as num) * 100).round();
    if (planCents != targetCents) continue;
    if (!nameMatches(ref['name'] as String, incName)) continue;

    final planDateRaw = plan['date'];
    final planDate =
        (planDateRaw is String && planDateRaw.isNotEmpty) ? planDateRaw : '';
    final bothDates = incDate.isNotEmpty && planDate.isNotEmpty;

    if (bothDates && dayDiff(incDate, planDate) > _dateWindowDays) continue;

    // ציון-דירוג לניפוי-כפולות: תאריך-קרוב = יותר-בטוח.
    final dd = bothDates ? dayDiff(incDate, planDate) : 0;
    final conf = math.max(60, 100 - dd * 10);
    candidates.add({...ref, 'incomingId': inc['id'], 'confidence': conf});
  }
  if (candidates.length != 1) return null;
  return candidates[0];
}
