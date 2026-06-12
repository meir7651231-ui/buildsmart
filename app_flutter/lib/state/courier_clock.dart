// #86 · COURIER CLOCK WRITER (F-10, ADJUST) — the single shared writer for
// the `bs.courier-clock.v1` side-map, which until now had NO writer anywhere
// in the repo (a dead key: streak, first-delivery %, deliveries-per-day and
// "נמסרו היום (נמדד)" in the courier reports all read it).
//
// [stampCourierClock] is called at ALL THREE courier advance points:
//   • courier_dashboard_screen._advance
//   • courier_delivery_detail_sheet._advance
//   • persona_pod_sheet — the "אישור מסירה" button
// pickup→transit stamps `pickedUpAt`; transit→delivered stamps `deliveredAt`
// (honest wall-clock capture at the moment of the advance).
//
// BYTE-COMPATIBLE with the read-only consumer `courierClockProvider` in
// `screens/courier_reports_tab.dart` (:86-109):
//   {orderId: {'pickedUpAt': iso8601, 'deliveredAt': iso8601, 'attempts': n}}
// `attempts` is NEVER written here — the reader treats null/absent as 1, and
// it may only ever be incremented by a real failed-attempt flow (none exists
// today; אין המצאות).
//
// SERVER-SWAP: this side-map becomes the server's delivery-clock ledger when
// the backend lands (stamps then come from the server's authoritative clock);
// the helper's call sites stay the swap seam.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// `bs.courier-clock.v1` — kept private to avoid clashing with the reader's
/// own `kCourierClockKey` const in `screens/courier_reports_tab.dart` (the
/// string values MUST stay identical).
const String _kCourierClockKey = 'bs.courier-clock.v1';

/// Stamp the delivery clock for [orderId]: `pickedUp: true` writes
/// `pickedUpAt` (pickup→transit), `delivered: true` writes `deliveredAt`
/// (transit→delivered). Read-modify-write on `bs.courier-clock.v1`.
///
/// Each stamp is write-once: an already-valid stamp is preserved, so a
/// double call can never falsify the first honest wall-clock capture
/// (the stage machine never revisits a stage anyway).
///
/// Best-effort by design: a storage failure (e.g. web localStorage quota)
/// must never break the delivery advance itself — the reports then honestly
/// show the entry as unmeasured, exactly like the pre-clock era.
Future<void> stampCourierClock(
  String orderId, {
  bool pickedUp = false,
  bool delivered = false,
}) async {
  if (!pickedUp && !delivered) return; // nothing to stamp
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCourierClockKey);
    Map<String, dynamic> map;
    try {
      map = raw == null || raw.isEmpty
          ? <String, dynamic>{}
          : (jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (_) {
      // Corrupt payload — the reader already yields {} for it (honest "no
      // measurements"), so starting fresh loses nothing readable and
      // repairs the key for the stamps from here on.
      map = <String, dynamic>{};
    }
    // Preserve whatever the entry already carries (stamps written by the
    // other advance points, a future attempts field) — only add our stamp.
    final entry = map[orderId] is Map
        ? Map<String, dynamic>.from(map[orderId] as Map)
        : <String, dynamic>{};
    final now = DateTime.now().toIso8601String();
    if (pickedUp && DateTime.tryParse('${entry['pickedUpAt']}') == null) {
      entry['pickedUpAt'] = now;
    }
    if (delivered && DateTime.tryParse('${entry['deliveredAt']}') == null) {
      entry['deliveredAt'] = now;
    }
    // NOTE: 'attempts' is intentionally NOT stamped — no re-attempt flow
    // exists; the reader defaults absent to 1 (F-10 ADJUST).
    map[orderId] = entry;
    await prefs.setString(_kCourierClockKey, jsonEncode(map));
  } on Object catch (_) {
    // Swallowed by design — see the doc comment (best-effort measurement).
  }
}
