// 🏗️ ניהול אתר הבנייה — runtime state for the site-hub feature track (T2).
//
// Mutable runtime state that STARTS from the B0 const seeds in
// `data/phaseb_seeds.dart` (the genesis values) — exactly as the proto's
// module-scoped `let snagList` / `inspections` / `attendanceLog` / `workDiary`
// vars start from their seed literals. The seeds themselves are NOT re-declared
// here (R6/R8 — single source of truth).
//
// Four pieces of live state (faithful ports of the proto's site functions):
//   • [siteSnagsProvider]       — snagging list (T2.2 `addSnag`/`fixSnag`,
//     proto [L19913]). Seeded from [kSnagList]; `add` unshifts, `fix` flips.
//   • [siteInspectionsProvider] — inspector reminders (T2.9 `addInspection`/
//     `completeInspection`, proto [L20111]). Seeded from [kInspections].
//   • [siteAttendanceProvider]  — GPS attendance log (T2.4 `clockAttendance`,
//     proto [L19972]). Starts EMPTY (proto `attendanceLog=[]`); clock in/out.
//   • [siteDiaryProvider]       — daily work diary (T2.5 `addDiaryEntry`,
//     proto [L20012]). Starts EMPTY (proto `workDiary=[]`); add w/ random weather.

import 'dart:math' as math;

import 'package:buildsmart/data/contractor_seeds.dart' show caToday;
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═════════════════════════════════════════════════════════════════════════════
// T2.2 — SNAGGING LIST. Seeded from [kSnagList] (2 rows, status 'פתוח').
//   proto `addSnag`/`fixSnag` @index.html:19913-19948.
// ═════════════════════════════════════════════════════════════════════════════

/// A live snag row — the [SnagItem] seed fields with a MUTABLE status.
class SiteSnag {
  const SiteSnag({
    required this.id,
    required this.what,
    required this.loc,
    required this.severity,
    required this.status,
  });
  final String id;
  final String what;
  final String loc;
  final String severity;
  final String status; // 'פתוח' | 'טופל'

  SiteSnag copyWith({String? status}) => SiteSnag(
        id: id,
        what: what,
        loc: loc,
        severity: severity,
        status: status ?? this.status,
      );
}

class SiteSnagsNotifier extends StateNotifier<List<SiteSnag>> {
  SiteSnagsNotifier()
      : super([
          for (final s in kSnagList)
            SiteSnag(
              id: s.id,
              what: s.what,
              loc: s.loc,
              severity: s.severity,
              status: s.status,
            ),
        ]);

  /// `addSnag` (proto :19921) — unshift a new snag. New id is
  /// `SNG-` + padStart(2,'0') of (len+1); loc/severity/status verbatim defaults.
  void add(String what) {
    final id = 'SNG-${(state.length + 1).toString().padLeft(2, '0')}';
    state = [
      SiteSnag(
        id: id,
        what: what.isEmpty ? 'ליקוי' : what,
        loc: 'האתר הנוכחי',
        severity: 'בינוני',
        status: 'פתוח',
      ),
      ...state,
    ];
  }

  /// `fixSnag` (proto :19940) — flip a row's status to 'טופל'.
  void fix(String id) {
    state = [
      for (final s in state) s.id == id ? s.copyWith(status: 'טופל') : s,
    ];
  }
}

final siteSnagsProvider =
    StateNotifierProvider<SiteSnagsNotifier, List<SiteSnag>>(
  (ref) => SiteSnagsNotifier(),
);

// ═════════════════════════════════════════════════════════════════════════════
// T2.9 — INSPECTION REMINDERS. Seeded from [kInspections] (2 rows, 'מתוכננת').
//   proto `addInspection`/`completeInspection` @index.html:20128-20141.
// ═════════════════════════════════════════════════════════════════════════════

/// A live inspection row — the [Inspection] seed fields with a MUTABLE status.
class SiteInspection {
  const SiteInspection({
    required this.id,
    required this.what,
    required this.due,
    required this.status,
  });
  final String id;
  final String what;
  final String due;
  final String status; // 'מתוכננת' | 'בוצעה'

  SiteInspection copyWith({String? status}) => SiteInspection(
        id: id,
        what: what,
        due: due,
        status: status ?? this.status,
      );
}

class SiteInspectionsNotifier extends StateNotifier<List<SiteInspection>> {
  SiteInspectionsNotifier()
      : super([
          for (final i in kInspections)
            SiteInspection(
              id: i.id,
              what: i.what,
              due: i.due,
              status: i.status,
            ),
        ]);

  /// `addInspection` (proto :20128) — unshift; id `INS-`+(len+1), due verbatim.
  void add(String what) {
    final id = 'INS-${state.length + 1}';
    state = [
      SiteInspection(
        id: id,
        what: what.isEmpty ? 'ביקורת' : what,
        due: 'בעוד שבוע',
        status: 'מתוכננת',
      ),
      ...state,
    ];
  }

  /// `completeInspection` (proto :20137) — flip a row's status to 'בוצעה'.
  void complete(String id) {
    state = [
      for (final i in state) i.id == id ? i.copyWith(status: 'בוצעה') : i,
    ];
  }
}

final siteInspectionsProvider =
    StateNotifierProvider<SiteInspectionsNotifier, List<SiteInspection>>(
  (ref) => SiteInspectionsNotifier(),
);

// ═════════════════════════════════════════════════════════════════════════════
// T2.4 — GPS ATTENDANCE LOG. Starts EMPTY (proto `attendanceLog=[]`).
//   proto `clockAttendance` @index.html:19999-20009.
//   C6: the geo string is now a REAL device coordinate (services/geo.dart →
//   geolocator), formatted by [formatGeo]; when the platform gives no fix it is
//   the honest [kGeoUnavailable] marker — never the old hardcoded demo point.
// ═════════════════════════════════════════════════════════════════════════════

/// Honest marker stamped on an attendance row when the device returned no GPS
/// fix (permission denied / service off / error). NOT a coordinate — the row
/// truthfully records that no location was captured.
const String kGeoUnavailable = 'מיקום לא זמין';

/// Format a live GPS fix as the attendance geo string, e.g.
/// `32.0728°N, 34.7912°E (±12מ׳)`. Mirrors the proto's display shape but with
/// the device's REAL latitude/longitude. Hemisphere letters come from the sign;
/// the optional accuracy radius is shown only when the platform reported one.
/// There is no null path here — callers pass [kGeoUnavailable] when there is no
/// fix, so a fabricated coordinate can never reach the log.
String formatGeo(double lat, double lng, {double? accuracyMeters}) {
  final latStr = '${lat.abs().toStringAsFixed(4)}°${lat >= 0 ? 'N' : 'S'}';
  final lngStr = '${lng.abs().toStringAsFixed(4)}°${lng >= 0 ? 'E' : 'W'}';
  final acc =
      accuracyMeters == null ? '' : ' (±${accuracyMeters.round()}מ׳)';
  return '$latStr, $lngStr$acc';
}

class AttendanceEntry {
  const AttendanceEntry({
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.geo,
  });
  final String date;
  final String timeIn;
  final String? timeOut; // null while the entry is open
  final String geo;

  AttendanceEntry copyWith({String? timeOut}) => AttendanceEntry(
        date: date,
        timeIn: timeIn,
        timeOut: timeOut ?? this.timeOut,
        geo: geo,
      );
}

class SiteAttendanceNotifier extends StateNotifier<List<AttendanceEntry>> {
  SiteAttendanceNotifier() : super(const []);

  /// The currently-open entry (no `out`), or null. proto `attendanceLog.find`.
  AttendanceEntry? get open {
    for (final a in state) {
      if (a.timeOut == null) return a;
    }
    return null;
  }

  /// `clockAttendance(1)` (proto :20002) — record a clock-in. [now] is
  /// `new Date().toLocaleTimeString('he-IL',{hour,minute})`.
  ///
  /// C6: [geo] is the REAL device coordinate string (formatted by the caller
  /// from the live GPS fix), or — when the platform returned no fix
  /// (permission-denied / service-off / web denial / native error) — the honest
  /// `kGeoUnavailable` marker. NEVER a fabricated coordinate. It defaults to
  /// that honest marker so a caller that has no fix records the truth, not the
  /// old hardcoded demo point.
  void clockIn(String now, {String geo = kGeoUnavailable}) {
    state = [
      AttendanceEntry(
        date: caToday(),
        timeIn: now,
        timeOut: null,
        geo: geo,
      ),
      ...state,
    ];
  }

  /// `clockAttendance(0)` (proto :20006) — close the open entry's `out`.
  /// Only the FIRST open entry (proto `attendanceLog.find`) is closed.
  void clockOut(String now) {
    var done = false;
    final next = <AttendanceEntry>[];
    for (final a in state) {
      if (!done && a.timeOut == null) {
        next.add(a.copyWith(timeOut: now));
        done = true;
      } else {
        next.add(a);
      }
    }
    state = next;
  }
}

final siteAttendanceProvider =
    StateNotifierProvider<SiteAttendanceNotifier, List<AttendanceEntry>>(
  (ref) => SiteAttendanceNotifier(),
);

// ═════════════════════════════════════════════════════════════════════════════
// T2.5 — DAILY WORK DIARY. Starts EMPTY (proto `workDiary=[]`).
//   proto `addDiaryEntry` @index.html:20030-20039. workers = 3+rand(0..5),
//   weather = random of ['בהיר ☀️','מעונן ⛅','גשום 🌧️'].
// ═════════════════════════════════════════════════════════════════════════════

/// The 3 weather options the proto picks at random (verbatim, proto :20034).
const List<String> kDiaryWeathers = ['בהיר ☀️', 'מעונן ⛅', 'גשום 🌧️'];

class DiaryEntry {
  const DiaryEntry({
    required this.date,
    required this.text,
    required this.workers,
    required this.weather,
  });
  final String date;
  final String text;
  final int workers;
  final String weather;
}

class SiteDiaryNotifier extends StateNotifier<List<DiaryEntry>> {
  SiteDiaryNotifier([math.Random? rng])
      : _rng = rng ?? math.Random(),
        super(const []);

  final math.Random _rng;

  /// `addDiaryEntry` (proto :20030) — unshift today's entry; random workers +
  /// weather. Pass deterministic values in tests via the injected [math.Random].
  void add(String text) {
    state = [
      DiaryEntry(
        date: caToday(),
        text: text.isEmpty ? 'עבודה באתר' : text,
        workers: 3 + _rng.nextInt(6), // 3 + Math.floor(random()*6) → 3..8
        weather: kDiaryWeathers[_rng.nextInt(kDiaryWeathers.length)],
      ),
      ...state,
    ];
  }
}

final siteDiaryProvider =
    StateNotifierProvider<SiteDiaryNotifier, List<DiaryEntry>>(
  (ref) => SiteDiaryNotifier(),
);

// ═════════════════════════════════════════════════════════════════════════════
// T2.7 — MATERIAL DEPENDENCIES (4, ready/blocked). proto `siteDeps` @20066.
//   Inline data (the proto declares it inside the render fn) — VERBATIM.
// ═════════════════════════════════════════════════════════════════════════════

class SiteDep {
  const SiteDep({required this.task, required this.needs, required this.ready});
  final String task;
  final String needs;
  final bool ready;
}

const List<SiteDep> kSiteDeps = [
  SiteDep(task: 'טיח וריצוף', needs: 'אינסטלציה גסה + חשמל גס', ready: true),
  SiteDep(task: 'גמר וצבע', needs: 'טיח וריצוף הושלם', ready: false),
  SiteDep(task: 'התקנת כלים סניטריים', needs: 'ריצוף + חיבורי מים', ready: false),
  SiteDep(task: 'הרכבת מטבח', needs: 'נקודות מים וחשמל מוכנות', ready: true),
];

// ═════════════════════════════════════════════════════════════════════════════
// T2.8 — BEFORE / AFTER PHOTOS (3 pairs). proto `sitePhotos` @20087.
//   Inline data (declared inside the render fn) — VERBATIM area + emoji glyphs.
// ═════════════════════════════════════════════════════════════════════════════

class SitePhotoPair {
  const SitePhotoPair({
    required this.area,
    required this.before,
    required this.after,
  });
  final String area;
  final String before;
  final String after;
}

const List<SitePhotoPair> kSitePhotoPairs = [
  SitePhotoPair(area: 'חדר רחצה — קומה 2', before: '🛠️', after: '✨'),
  SitePhotoPair(area: 'מטבח — דירה 4', before: '🧱', after: '🍳'),
  SitePhotoPair(area: 'סלון — קומה 3', before: '🪵', after: '🛋️'),
];
