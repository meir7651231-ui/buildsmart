// חוט · makeup-eligibility — זכאות-השלמה לחיסור. חוזה: makeup-eligibility.contract.md
// המרה מ-JS (new/atoms/makeup-eligibility.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// תיקוני-מנוע: המנוע פלט `justified ?? earlyCancel` (null-coalesce) — אך המקור הוא
// `justified || earlyCancel` (OR-לוגי, שני האופרנדים בוליאניים בחוזה); וכן `_falsy(eligible)`
// לא-מוגדר הוחלף ל-`!eligible`. אפס-import (dart-core בלבד).
Map<String, bool> makeupEligibility(String kind, bool justified, num? rawHrs) {
  if (kind == 'noshow') return {'eligible': false, 'dropsPunch': true};
  final earlyCancel = rawHrs != null && rawHrs >= 48;
  final eligible = justified || earlyCancel;
  return {'eligible': eligible, 'dropsPunch': !eligible};
}
