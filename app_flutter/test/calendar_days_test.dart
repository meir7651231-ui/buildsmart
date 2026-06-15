// A4 — DST-safe calendar-day idiom (lib/logic/calendar_days.dart). The gantt
// offset and both report week-charts route through these helpers; the bug they
// replace is local-midnight `.difference().inDays`, which truncates across a
// daylight-saving boundary (a 23h spring-forward day floors to one day LESS).
//
// The UTC-based assertions below are timezone-INDEPENDENT, so they never
// flaky-fail. The "time-of-day ignored" case catches a missing date-reduction
// in ANY timezone; the spring-forward cases additionally expose the off-by-one
// a local-midnight implementation produces when run in a DST-observing local TZ
// (e.g. Asia/Jerusalem — Israel springs forward the Friday before the last
// Sunday of March).
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('daysBetweenDst — whole calendar days, DST-safe', () {
    test('adjacent calendar dates are exactly 1 day apart', () {
      // Israel 2026 spring-forward: standard→DST on Fri Mar 27. A LOCAL
      // DateTime(2026,3,28).difference(DateTime(2026,3,27)).inDays is 0 there
      // (the 23h day truncates); UTC dates always give 1.
      expect(daysBetweenDst(DateTime(2026, 3, 27), DateTime(2026, 3, 28)), 1);
      // late-Oct fall-back week — a 25h day must not over-count either.
      expect(daysBetweenDst(DateTime(2026, 10, 24), DateTime(2026, 10, 25)), 1);
    });

    test('time-of-day is ignored — DATE only (TZ-independent)', () {
      // 23:59 of day N → 00:01 of day N+1 is ONE calendar day, not 0. Without a
      // date-reduction this is ~2 minutes → inDays 0 (caught in any timezone).
      expect(
        daysBetweenDst(
            DateTime(2026, 3, 27, 23, 59), DateTime(2026, 3, 28, 0, 1)),
        1,
      );
      // any two times on the SAME calendar date → 0
      expect(
        daysBetweenDst(
            DateTime(2026, 3, 27, 0, 1), DateTime(2026, 3, 27, 23, 59)),
        0,
      );
    });

    test('multi-day span across the boundary, and negative direction', () {
      expect(daysBetweenDst(DateTime(2026, 3, 25), DateTime(2026, 3, 30)), 5);
      expect(daysBetweenDst(DateTime(2026, 3, 30), DateTime(2026, 3, 25)), -5);
    });
  });

  group('startOfWeekSunday — calendar-safe week anchor (Sun..Sat)', () {
    test('lands on the Sunday opening the week, at local midnight', () {
      // 2026-03-28 is a Saturday → its week opened Sunday 2026-03-22.
      final s = startOfWeekSunday(DateTime(2026, 3, 28, 15, 30));
      expect([s.year, s.month, s.day], [2026, 3, 22]);
      expect(s.hour, 0);
      expect(s.weekday % 7, 0, reason: 'Sunday maps to bucket 0');
    });

    test('a Sunday is its own week start', () {
      final s = startOfWeekSunday(DateTime(2026, 3, 22, 9, 0)); // Sunday
      expect([s.year, s.month, s.day], [2026, 3, 22]);
    });

    test('week anchor rolls back across a month boundary correctly', () {
      // 2026-03-03 is a Tuesday → week opened Sunday 2026-03-01.
      final s = startOfWeekSunday(DateTime(2026, 3, 3));
      expect([s.year, s.month, s.day], [2026, 3, 1]);
      // 2026-03-02 is a Monday → same Sunday (Mar 1).
      expect(startOfWeekSunday(DateTime(2026, 3, 2)).day, 1);
    });
  });
}
