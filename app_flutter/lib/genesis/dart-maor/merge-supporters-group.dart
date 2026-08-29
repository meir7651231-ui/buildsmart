/// חוט · merge-supporters-group — מיזוג-קבוצה אטומי: קיפול מיזוג-הזוגות מעל כל ה-losers.
/// חוזה: new/atoms/merge-supporters-group.contract.md
/// חולץ כלשונו מ-maor/src/lib/dedup.ts:388-403; השכן mergeSupporterInto (מיזוג-
/// זוג — האטום merge-supporter-into) הוזרק כשקע (חוק-1 — אפס import פנימי).
///
/// פאריטי-JS: losers.reduce(acc,l => merge(acc,l), keeper) ⇒ List.fold.
/// losers ריק ⇒ מוחזר ה-keeper עצמו (identical) — כמו-שהוא, אפס קריאות-שקע.
dynamic mergeSupportersGroup(
  dynamic keeper,
  List losers,
  dynamic Function(dynamic acc, dynamic loser) mergeSupporterInto,
) {
  return losers.fold(keeper, (acc, l) => mergeSupporterInto(acc, l));
}
