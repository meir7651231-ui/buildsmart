import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// cluster #85ח · נוכחות עובד — on-device clock-in/out, one [AttendanceDay]
/// per username per calendar day. Persisted to SharedPreferences under
/// [kWorkerAttendanceKey] with the `board_auth.dart` idiom: lazy `_load()` in
/// the constructor + a one-shot `_userTouched` guard so a late prefs read can
/// never clobber a clock-in that landed before prefs resolved (ticket-#24
/// race).
///
/// SERVER-SWAP: becomes the server's attendance ledger when the backend
/// lands; until then the device is the single honest source of truth.

/// SharedPreferences key (versioned like the other `bs.*.v1` keys).
const String kWorkerAttendanceKey = 'bs.worker-attendance.v1';

/// `yyyy-MM-dd` key for [d] — the per-day identity of an [AttendanceDay].
String attendanceDateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// One worker-day: the date key plus the clock-in / clock-out instants.
/// [outTs] stays null while the worker is still clocked in.
class AttendanceDay {
  const AttendanceDay({
    required this.username,
    required this.date,
    this.inTs,
    this.outTs,
    this.inLat,
    this.inLng,
    this.outLat,
    this.outLng,
    this.employerId = '',
  });

  /// Board login username (`ran` / `omer` / `demo`) — the same identity key
  /// `boardAuthProvider` carries.
  final String username;

  /// `yyyy-MM-dd` ([attendanceDateKey]).
  final String date;

  /// Id of the contractor who EMPLOYS the worker (the worker→contractor LINK,
  /// `session.employerId`) — lets the contractor's roster scope to THEIR
  /// workers (see [attendanceForEmployer]). Default `''` (field-economy: only
  /// serialised when non-empty). Back-compat: old persisted rows carry no
  /// 'employerId' and decode as `''` (and are excluded from any non-empty
  /// employer query).
  final String employerId;

  final DateTime? inTs;
  final DateTime? outTs;

  /// Optional GPS coordinates captured at clock-in / clock-out. Null when the
  /// device had no fix (permission denied / unsupported) — we never invent a
  /// coordinate. back-compat: older rows lack these keys and decode to null.
  /// json keys: ilat / ilng / olat / olng.
  final double? inLat;
  final double? inLng;
  final double? outLat;
  final double? outLng;

  /// Completed shift length — null while the day is still open (no clock-out).
  Duration? get worked {
    final i = inTs;
    final o = outTs;
    if (i == null || o == null) return null;
    final d = o.difference(i);
    return d.isNegative ? Duration.zero : d;
  }

  AttendanceDay copyWith({
    DateTime? inTs,
    DateTime? outTs,
    double? inLat,
    double? inLng,
    double? outLat,
    double? outLng,
    String? employerId,
  }) =>
      AttendanceDay(
        username: username,
        date: date,
        inTs: inTs ?? this.inTs,
        outTs: outTs ?? this.outTs,
        inLat: inLat ?? this.inLat,
        inLng: inLng ?? this.inLng,
        outLat: outLat ?? this.outLat,
        outLng: outLng ?? this.outLng,
        employerId: employerId ?? this.employerId,
      );

  Map<String, dynamic> toJson() => {
        'username': username,
        'date': date,
        'inTs': inTs?.toIso8601String(),
        'outTs': outTs?.toIso8601String(),
        'ilat': inLat,
        'ilng': inLng,
        'olat': outLat,
        'olng': outLng,
        if (employerId.isNotEmpty) 'employerId': employerId,
      };

  /// Defensive decode — a malformed entry is dropped, never crashes the load.
  static AttendanceDay? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final username = raw['username'];
    final date = raw['date'];
    if (username is! String || date is! String) return null;
    return AttendanceDay(
      username: username,
      date: date,
      inTs: DateTime.tryParse('${raw['inTs']}'),
      outTs: DateTime.tryParse('${raw['outTs']}'),
      inLat: _tryDouble(raw['ilat']),
      inLng: _tryDouble(raw['ilng']),
      outLat: _tryDouble(raw['olat']),
      outLng: _tryDouble(raw['olng']),
      employerId: raw['employerId'] is String ? raw['employerId'] as String : '',
    );
  }

  /// Lenient numeric decode — accepts num or numeric-string, else null
  /// (missing key / malformed value → null, never throws). back-compat.
  static double? _tryDouble(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

/// Pure helper — [username]'s records in (year, month), oldest→newest. Kept
/// top-level so the screen and tests share one filter.
List<AttendanceDay> attendanceMonth(
  List<AttendanceDay> all,
  String username,
  int year,
  int month,
) {
  final prefix = '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-';
  return all
      .where((d) => d.username == username && d.date.startsWith(prefix))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
}

/// Pure helper — sum of the COMPLETED shifts in [days] (open days count 0).
Duration attendanceTotal(List<AttendanceDay> days) => days.fold(
      Duration.zero,
      (sum, d) => sum + (d.worked ?? Duration.zero),
    );

/// Pure helper — the `"lat,lng"` query string for [d]'s clock-in location,
/// suitable as a maps/navigation target, or null when no clock-in coordinate
/// was captured. Top-level so the screen, home and tests share one formatter.
String? mapsQueryForDay(AttendanceDay d) {
  final lat = d.inLat;
  final lng = d.inLng;
  if (lat == null || lng == null) return null;
  return '$lat,$lng';
}

/// Pure helper — the workers in [employerDays] currently CLOCKED IN: an OPEN
/// day (today's date, `inTs` set, `outTs` still null). [todayKey] is
/// `attendanceDateKey(now)` passed in by the caller so this stays pure (no
/// `DateTime.now()` inside) and trivially testable with fixed date strings.
/// Kept top-level so the contractor sheet and tests share one definition.
List<AttendanceDay> clockedInNow(
        List<AttendanceDay> employerDays, String todayKey) =>
    [
      for (final d in employerDays)
        if (d.date == todayKey && d.inTs != null && d.outTs == null) d,
    ];

class WorkerAttendanceNotifier extends StateNotifier<List<AttendanceDay>> {
  WorkerAttendanceNotifier({this.storageKey = kWorkerAttendanceKey})
      : super(const []) {
    _load();
  }

  /// The SharedPreferences key this notifier reads/writes. Defaults to the
  /// worker ledger; the courier board passes `'bs.courier-attendance.v1'` so
  /// the two roles never share a ledger (the shared `demo` username would
  /// otherwise leak attendance across boards).
  final String storageKey;

  /// One-shot guard (the board_auth idiom): once a clock-in/out has written
  /// state, a late `_load()` becomes non-destructive.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = prefs.getString(storageKey);
    if (raw == null || _userTouched) return;
    try {
      final list = jsonDecode(raw) as List;
      if (!mounted || _userTouched) return;
      state = [
        for (final e in list)
          if (AttendanceDay.tryFromJson(e) case final d?) d,
      ];
    } on Object catch (_) {
      // Corrupt payload — keep the empty ledger.
    }
  }

  /// Best-effort persist of the WHOLE ledger (every user, full history) on
  /// each clock-in/out — the payload grows unbounded over time (~250 rows per
  /// user per year). Acceptable at on-device demo scale because rows are tiny
  /// JSON (never add heavy fields — no photos in the ledger). SERVER-SWAP:
  /// the server's attendance ledger replaces this full-rewrite persistence.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        storageKey,
        jsonEncode([for (final d in state) d.toJson()]),
      );
    } on Object catch (_) {
      // Storage failure (e.g. web quota) — the in-memory ledger stays live;
      // tiny-JSON best-effort, never an unhandled async error.
    }
  }

  /// Today's record for [username], or null when none exists yet.
  AttendanceDay? todayFor(String username) {
    final key = attendanceDateKey(DateTime.now());
    for (final d in state) {
      if (d.username == username && d.date == key) return d;
    }
    return null;
  }

  /// Clock IN for today. `false` (no-op) when today already has a clock-in —
  /// one shift per calendar day, honest and simple. [lat]/[lng] are the GPS
  /// fix at clock-in; when null no location is stored (honest — no invented
  /// coordinate). [employerId] is the worker→contractor link (`session
  /// .employerId`) stamped onto the day this is born — it scopes the row to the
  /// employing contractor's roster ([attendanceForEmployer]); default `''`
  /// keeps existing callers (and couriers) working unchanged.
  bool clockIn(String username,
      {double? lat, double? lng, String employerId = ''}) {
    final today = todayFor(username);
    if (today != null && today.inTs != null) return false;
    _userTouched = true;
    final key = attendanceDateKey(DateTime.now());
    state = [
      for (final d in state)
        if (!(d.username == username && d.date == key)) d,
      AttendanceDay(
        username: username,
        date: key,
        inTs: DateTime.now(),
        inLat: lat,
        inLng: lng,
        employerId: employerId,
      ),
    ];
    _persist();
    return true;
  }

  /// Clock OUT for today. `false` (no-op) when there is no open clock-in.
  /// [lat]/[lng] are the GPS fix at clock-out; when null no location is stored
  /// (honest — no invented coordinate). Existing callers that pass no location
  /// keep working.
  bool clockOut(String username, {double? lat, double? lng}) {
    final today = todayFor(username);
    if (today == null || today.inTs == null || today.outTs != null) {
      return false;
    }
    _userTouched = true;
    state = [
      for (final d in state)
        if (d.username == username && d.date == today.date)
          d.copyWith(outTs: DateTime.now(), outLat: lat, outLng: lng)
        else
          d,
    ];
    _persist();
    return true;
  }
}

/// The attendance ledger — every worker-day on this device. Screens filter by
/// the logged username (the worker sees only his own rows, #66).
final workerAttendanceProvider =
    StateNotifierProvider<WorkerAttendanceNotifier, List<AttendanceDay>>(
  (ref) => WorkerAttendanceNotifier(),
);

/// The CONTRACTOR's roster — every WORKER attendance record (worker store
/// only) that names this `employerId`. Couriers use a separate provider/key
/// and are excluded by construction. The contractor's attendance sheet (Wave
/// S) watches this to see who's on-site today. Order: ledger insertion order
/// (oldest→newest, the order rows were clocked in), deterministic and free of
/// timestamp-tie instability; pair with [clockedInNow] for the live list.
final attendanceForEmployer =
    Provider.family<List<AttendanceDay>, String>((ref, employerId) {
  final all = ref.watch(workerAttendanceProvider);
  return [for (final d in all) if (d.employerId == employerId) d];
});
