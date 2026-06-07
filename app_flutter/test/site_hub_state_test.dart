// Track T2 (ניהול אתר) — runtime-state DoD guard for the site-hub notifiers.
// Verifies the CRUD ports faithfully mirror the prototype's site functions
// (addSnag/fixSnag · addInspection/completeInspection · clockAttendance ·
// addDiaryEntry) and that the inline dep/photo data is verbatim.
//
// Sources: prototype `index.html` line anchors noted per group.
import 'dart:math' as math;

import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/site_hub_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('T2.1 — gantt span [L19889]', () {
    test('span = max(start+len) = 27', () {
      expect(ganttSpan(), 27);
      expect(kGanttTasks, hasLength(6));
    });
  });

  group('T2.2 — snag CRUD [L19913]', () {
    test('seeds from kSnagList (2, both פתוח)', () {
      final n = SiteSnagsNotifier();
      expect(n.state, hasLength(2));
      expect(n.state.every((s) => s.status == 'פתוח'), isTrue);
      expect(n.state.first.id, 'SNG-01');
    });

    test('add unshifts with SNG-NN id + verbatim defaults', () {
      final n = SiteSnagsNotifier();
      n.add('סדק בקיר חדש');
      expect(n.state, hasLength(3));
      expect(n.state.first.id, 'SNG-03'); // padStart(2,'0') of len+1
      expect(n.state.first.what, 'סדק בקיר חדש');
      expect(n.state.first.loc, 'האתר הנוכחי');
      expect(n.state.first.severity, 'בינוני');
      expect(n.state.first.status, 'פתוח');
    });

    test('empty text falls back to ליקוי', () {
      final n = SiteSnagsNotifier()..add('');
      expect(n.state.first.what, 'ליקוי');
    });

    test('fix flips a row to טופל, leaves others', () {
      final n = SiteSnagsNotifier()..fix('SNG-01');
      expect(n.state.firstWhere((s) => s.id == 'SNG-01').status, 'טופל');
      expect(n.state.firstWhere((s) => s.id == 'SNG-02').status, 'פתוח');
    });
  });

  group('T2.9 — inspection CRUD [L20111]', () {
    test('seeds from kInspections (2, מתוכננת)', () {
      final n = SiteInspectionsNotifier();
      expect(n.state, hasLength(2));
      expect(n.state.every((i) => i.status == 'מתוכננת'), isTrue);
      expect(n.state.first.id, 'INS-1');
    });

    test('add unshifts INS-(len+1) with due בעוד שבוע', () {
      final n = SiteInspectionsNotifier()..add('ביקורת מהנדס');
      expect(n.state, hasLength(3));
      expect(n.state.first.id, 'INS-3');
      expect(n.state.first.what, 'ביקורת מהנדס');
      expect(n.state.first.due, 'בעוד שבוע');
      expect(n.state.first.status, 'מתוכננת');
    });

    test('complete flips a row to בוצעה', () {
      final n = SiteInspectionsNotifier()..complete('INS-1');
      expect(n.state.firstWhere((i) => i.id == 'INS-1').status, 'בוצעה');
      expect(n.state.firstWhere((i) => i.id == 'INS-2').status, 'מתוכננת');
    });
  });

  group('T2.4 — GPS attendance [L19972]', () {
    test('starts empty (proto attendanceLog=[])', () {
      expect(SiteAttendanceNotifier().state, isEmpty);
    });

    test('clockIn opens an entry with demo geo; clockOut closes it', () {
      final n = SiteAttendanceNotifier();
      n.clockIn('08:00');
      expect(n.state, hasLength(1));
      expect(n.open, isNotNull);
      expect(n.state.first.timeIn, '08:00');
      expect(n.state.first.timeOut, isNull);
      expect(n.state.first.geo, '32.07°N, 34.79°E (±12מ׳)');

      n.clockOut('17:30');
      expect(n.open, isNull);
      expect(n.state.first.timeOut, '17:30');
    });

    test('clockOut closes only the open entry', () {
      final n = SiteAttendanceNotifier();
      n.clockIn('08:00');
      n.clockOut('12:00'); // close first
      n.clockIn('13:00'); // open a second
      n.clockOut('17:00'); // should close only the second
      expect(n.state.where((a) => a.timeOut == null), isEmpty);
      expect(n.state.map((a) => a.timeOut).toList(), ['17:00', '12:00']);
    });
  });

  group('T2.5 — work diary [L20012]', () {
    test('starts empty (proto workDiary=[])', () {
      expect(SiteDiaryNotifier().state, isEmpty);
    });

    test('add unshifts with workers 3..8 and a weather from the 3 options', () {
      // Deterministic RNG → reproducible workers/weather.
      final n = SiteDiaryNotifier(math.Random(1))..add('יציקת רצפה');
      expect(n.state, hasLength(1));
      expect(n.state.first.text, 'יציקת רצפה');
      expect(n.state.first.workers, inInclusiveRange(3, 8));
      expect(kDiaryWeathers, contains(n.state.first.weather));
      expect(kDiaryWeathers, ['בהיר ☀️', 'מעונן ⛅', 'גשום 🌧️']);
    });

    test('empty text falls back to עבודה באתר', () {
      final n = SiteDiaryNotifier(math.Random(2))..add('');
      expect(n.state.first.text, 'עבודה באתר');
    });
  });

  group('T2.7 — material dependencies [L20066]', () {
    test('4 deps, 2 ready / 2 blocked, verbatim', () {
      expect(kSiteDeps, hasLength(4));
      expect(kSiteDeps.where((d) => d.ready).length, 2);
      expect(kSiteDeps.first.task, 'טיח וריצוף');
      expect(kSiteDeps.first.needs, 'אינסטלציה גסה + חשמל גס');
      expect(kSiteDeps.first.ready, isTrue);
      expect(kSiteDeps[1].task, 'גמר וצבע');
      expect(kSiteDeps[1].ready, isFalse);
    });
  });

  group('T2.8 — before/after photos [L20087]', () {
    test('3 pairs, verbatim area + glyphs', () {
      expect(kSitePhotoPairs, hasLength(3));
      expect(kSitePhotoPairs.first.area, 'חדר רחצה — קומה 2');
      expect(kSitePhotoPairs.first.before, '🛠️');
      expect(kSitePhotoPairs.first.after, '✨');
      expect(kSitePhotoPairs[1].after, '🍳');
      expect(kSitePhotoPairs[2].before, '🪵');
    });
  });

  group('T2.3 / T2.10 — read-only seeds present', () {
    test('site tree 3 floors / archive 3 projects', () {
      expect(kSiteTree, hasLength(3));
      expect(kArchivedProjects, hasLength(3));
    });
  });
}
