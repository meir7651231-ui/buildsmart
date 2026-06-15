// 📆 DST-SAFE CALENDAR-DAY ARITHMETIC — the PURE (no widgets / Riverpod /
// Firebase / DateTime.now()) day idiom the gantt layout and the report charts
// share. The user's decision (A4): "uniform DST-safe day idiom" across the
// gantt + both reports tabs, replacing the local-midnight `.difference().inDays`
// that silently miscounts across a daylight-saving boundary.
//
// THE BUG IT REPLACES: `DateTime(y, m, d)` builds a LOCAL midnight. Differencing
// two local midnights across a DST spring-forward gives 23h (not 24h), so
// `inDays` floors to one DAY LESS than the calendar gap — a bar lands on the
// wrong day, a delivery falls in the wrong week-bucket. Israel springs forward
// on the Friday before the last Sunday of March, so this fires every spring.
//
// THE FIX: drop both ends to a UTC calendar date. UTC has no DST, so every day
// is exactly 24h and the day count is always the exact calendar gap, in any
// local timezone.

/// Whole calendar days from [from] to [to] (DATE only — time-of-day on either
/// argument is ignored), DST-safe. Negative when [to] precedes [from], 0 on the
/// same calendar date. Both ends are reduced to a UTC midnight so the
/// difference is always a clean multiple of 24h (no spring-forward truncation).
int daysBetweenDst(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// Local midnight of the Sunday that opens [d]'s week (Israeli week, Sun..Sat).
/// Built by CALENDAR arithmetic — `DateTime(y, m, d - k)` — not by
/// `subtract(Duration(days: k))`: subtracting a fixed 24h*k span across a DST
/// night drifts off the intended midnight (a fall-back week can land on 23:00
/// of the PREVIOUS calendar day), whereas constructing from year/month/day
/// always yields the correct date's local midnight. `weekday % 7` maps
/// Sun→0..Sat→6, so subtracting it walks back to the week's Sunday.
DateTime startOfWeekSunday(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday % 7));
