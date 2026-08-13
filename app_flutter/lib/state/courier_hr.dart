// #86.2-4 · COURIER HR (F-7, consumer side) — the courier board's own
// attendance / forms / certificates providers.
//
// NO model duplication: the COURIER reuses the worker MODELS + helpers as-is
// ([AttendanceDay] + attendanceMonth/attendanceTotal, [Form101]/[SickNote],
// [WorkerCert] + statusAt) and re-instantiates the worker NOTIFIERS with the
// courier's own versioned storage keys (the notifiers' optional `storageKey`
// ctor parameter — F-7 contract; default keeps the worker untouched).
//
// Separate keys are MANDATORY, not cosmetic: the demo username `demo` is
// shared across every role (board_auth enterDemo), so pointing the courier at
// `bs.worker-*.v1` would leak a demo-courier's attendance/forms/certs into
// the demo-worker's ledgers and vice-versa. Per-username isolation inside
// each ledger stays the models' own `username` field, exactly like the worker.
//
// Vacation requests intentionally do NOT get a courier clone — the shared
// `vacationRequestsProvider` is reused as-is (SPEC #86.3; the manager sees
// one queue; the courier submits with role: 'courier' — F-26).
//
// SERVER-SWAP: each ledger below becomes the corresponding server store
// (attendance / forms / certificates) when the backend lands — only the
// storage keys are courier-scoped; the provider surfaces stay identical to
// the worker's.

import 'package:buildsmart/data/repositories/worker_attendance_repository.dart';
import 'package:buildsmart/data/repositories/worker_certs_repository.dart';
import 'package:buildsmart/data/repositories/worker_forms_repository.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// One import serves the courier screens: the providers below + the shared
// models/helpers they expose (no duplicated model code anywhere).
export 'package:buildsmart/state/worker_attendance.dart'
    show AttendanceDay, attendanceDateKey, attendanceMonth, attendanceTotal;
export 'package:buildsmart/state/worker_certs.dart'
    show CertExpiryStatus, WorkerCert;
export 'package:buildsmart/state/worker_forms.dart'
    show Form101, SickNote, WorkerFormsState;

// ─── courier-scoped storage keys (versioned like every other bs.*.v1) ───────

/// Courier clock-in/out ledger — same payload shape as bs.worker-attendance.v1.
const String kCourierAttendanceKey = 'bs.courier-attendance.v1';

/// Courier 101 forms + sick-note uploads — same shape as bs.worker-forms.v1.
const String kCourierFormsKey = 'bs.courier-forms.v1';

/// Courier driver-certificate wallet — same shape as bs.worker-certs.v1.
const String kCourierCertsKey = 'bs.courier-certs.v1';

// ─── courier constants (#86.2, #86.4) ────────────────────────────────────────

/// Quick-add presets for the driver-certificate wallet (#86.4). The preset
/// chips pre-fill the NAME field ONLY — issuer and expiry stay user input
/// (אין המצאות: no invented issuer, no invented dates).
const List<String> kCourierCertPresets = [
  'רישיון נהיגה',
  'ביטוח רכב',
  'רישיון רכב',
];

/// The chat thread the courier's monthly attendance report is sent to —
/// "שלח דוח נוכחות לחנות" (#86.2), sent as `BsRole.courier` (NOT to the
/// contractor). The thread exists in `data/chat_seeds.dart` (audience
/// 'store', participants [store, courier]) — the report therefore lands in
/// the supplier's chat tab, which is exactly the intended recipient. A
/// sender must still guard for the thread's existence before sending
/// (`send` on an unknown thread is a silent no-op).
const String kCourierAttendanceReportThreadId = 'th-store-courier-pickups';

// ─── providers (the worker notifiers, courier-keyed) ─────────────────────────

/// The courier attendance ledger (#86.2) — every courier-day on this device,
/// persisted under [kCourierAttendanceKey]. Screens filter by the logged
/// username; report totals come from the shared attendanceMonth /
/// attendanceTotal helpers only.
final courierAttendanceProvider =
    StateNotifierProvider<WorkerAttendanceNotifier, List<AttendanceDay>>(
  (ref) => WorkerAttendanceNotifier(
    storageKey: kCourierAttendanceKey,
    repo: ref.watch(courierAttendanceRepositoryProvider),
  ),
);

/// The courier forms store (#86.3) — 101 forms per year + sick-note uploads,
/// persisted under [kCourierFormsKey]. Vacation requests live in the SHARED
/// vacationRequestsProvider (role: 'courier'), not here.
final courierFormsProvider =
    StateNotifierProvider<WorkerFormsNotifier, WorkerFormsState>(
  (ref) => WorkerFormsNotifier(
    storageKey: kCourierFormsKey,
    repo: ref.watch(courierFormsRepositoryProvider),
  ),
);

/// The courier driver-certificate wallet (#86.4) — persisted under
/// [kCourierCertsKey]; expiry traffic-light via [WorkerCert.statusAt] as-is.
final courierCertsProvider =
    StateNotifierProvider<WorkerCertsNotifier, List<WorkerCert>>(
  (ref) => WorkerCertsNotifier(
    storageKey: kCourierCertsKey,
    repo: ref.watch(courierCertsRepositoryProvider),
  ),
);
