// T5 — DEFERRED PERSONA FULFILLMENT STATE (store picking · missing-item hold ·
// split shipments · courier POD). These are the per-order *runtime* fields the
// prototype carried directly on each `SYS_ORDERS` element
// (proto 06 §1.2 [L11970]: `hasMissing`, `heldForMissing`, `missingResolved`,
// per-line `picked`/`missing`/`pendingDecision`/`cancelled`/`replaced`,
// `splitInto`, `splitPlan`, `podPhoto`, …) but which the slim shared engine
// `Order` (state/orders_engine.dart) deliberately does NOT model — it keeps only
// the cross-role stage so the manager numbers stay byte-for-byte identical.
//
// Rather than widen the shared engine (a T6/keystone surface), this notifier
// holds the deferred fields in a SIDE-CAR map keyed by order id. The store
// picking sheet, the missing-item hold loop, split derivation and the courier
// POD all read/write THROUGH here while the canonical stage advance still flows
// through `sysOrdersProvider` → `ordersEngineProvider` (so store/courier/manager
// stay one source of truth — T5 builds ON the live two-step hand-off, it does
// not rebuild it).
//
// T5.5 persistence: the fulfillment side-car persists to its own
// SharedPreferences key (`bs.fulfillment.v1`) — the same best-effort JSON
// pattern the orders engine + store out-of-stock set use — so a half-picked
// order, a held-for-missing flag, a split plan and a captured POD all survive an
// app restart (the order stages themselves already persist via the engine's
// `bs.orders.v1`).

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-line picking status — proto `renderSpLine` [L17495] status text:
/// `✓ לוקט` / `✕ חסר` / `⏳ ממתין לבחירת הקבלן` / `✕ בוטל ע״י הקבלן` /
/// `🔁 הוחלף ע״י הקבלן` / (pending = no decoration yet).
enum LineStatus { pending, picked, missing, pendingDecision, cancelled, replaced }

/// The deferred fulfillment record for a single order. All fields default to the
/// "nothing happened yet" state so an order with no record behaves exactly like
/// the pre-T5 build.
class Fulfillment {
  const Fulfillment({
    this.lineStatus = const {},
    this.heldForMissing = false,
    this.missingResolved = false,
    this.splitInto = 1,
    this.splitPlan = const [],
    this.podPhoto,
    this.podSigned = false,
  });

  /// line-index → status. Absent index ⇒ [LineStatus.pending].
  final Map<int, LineStatus> lineStatus;

  /// The hold gate (proto `o.heldForMissing` [L17597]) — set when a line is
  /// flagged missing and still awaits the contractor's decision; blocks advance.
  final bool heldForMissing;

  /// Set once the contractor resolves a missing line (proto `o.missingResolved`).
  final bool missingResolved;

  /// Number of shipments the order is split into (proto `o.splitInto`, 1 = none).
  final int splitInto;

  /// line-index → shipment-group (1-based), proto `o.splitPlan`. Empty ⇒ no split.
  final List<int> splitPlan;

  /// Courier POD photo — the REAL captured shot as a data-URL string (proto
  /// `o.podPhoto`; COURIER v2 (a): the `services/task_photo.dart pickTaskPhoto`
  /// seam — webcam sheet on desktop web). Null ⇒ no proof yet, including
  /// legacy pre-v2 records whose simulated boolean flag carried no image
  /// (fromJson honestly drops those).
  final String? podPhoto;

  /// Courier POD signature captured (proto `openSignature`, simulated).
  final bool podSigned;

  bool get hasMissing =>
      lineStatus.values.any((s) => s == LineStatus.missing) ||
      lineStatus.values.any((s) => s == LineStatus.pendingDecision);

  int get missingCount =>
      lineStatus.values.where((s) => s == LineStatus.missing).length;

  /// True once a REAL POD photo exists — derived from [podPhoto] so every
  /// reader (courier reports/profile, delivery-job card, store delivered
  /// card) keys off the one stored data-URL; no separate flag to drift.
  bool get podCaptured => podPhoto != null;

  Fulfillment copyWith({
    Map<int, LineStatus>? lineStatus,
    bool? heldForMissing,
    bool? missingResolved,
    int? splitInto,
    List<int>? splitPlan,
    String? podPhoto,
    bool? podSigned,
  }) => Fulfillment(
    lineStatus: lineStatus ?? this.lineStatus,
    heldForMissing: heldForMissing ?? this.heldForMissing,
    missingResolved: missingResolved ?? this.missingResolved,
    splitInto: splitInto ?? this.splitInto,
    splitPlan: splitPlan ?? this.splitPlan,
    podPhoto: podPhoto ?? this.podPhoto,
    podSigned: podSigned ?? this.podSigned,
  );

  Map<String, dynamic> toJson() => {
    if (lineStatus.isNotEmpty)
      'ls': {for (final e in lineStatus.entries) '${e.key}': e.value.name},
    if (heldForMissing) 'held': true,
    if (missingResolved) 'res': true,
    if (splitInto > 1) 'split': splitInto,
    if (splitPlan.isNotEmpty) 'plan': splitPlan,
    if (podPhoto != null) 'pod': podPhoto,
    if (podSigned) 'sig': true,
  };

  factory Fulfillment.fromJson(Map<String, dynamic> j) => Fulfillment(
    lineStatus: (j['ls'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(
            int.parse(k),
            LineStatus.values.firstWhere(
              (s) => s.name == v,
              orElse: () => LineStatus.pending,
            ),
          ),
        ) ??
        const {},
    heldForMissing: j['held'] == true,
    missingResolved: j['res'] == true,
    splitInto: (j['split'] as num?)?.toInt() ?? 1,
    splitPlan: (j['plan'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? const [],
    // 'pod' holds the photo data-URL since COURIER v2 (a); a legacy boolean
    // `true` (pre-v2 simulated capture) carried no image → honest null.
    podPhoto: j['pod'] is String ? j['pod'] as String : null,
    podSigned: j['sig'] == true,
  );
}

const String kFulfillmentKey = 'bs.fulfillment.v1';

/// The `{orderId: dataUrl}` POD-photo side-map contract the courier reports
/// tab reads (screens/courier_reports_tab.dart `kPodPhotosKey` /
/// `podPhotosProvider`). [FulfillmentNotifier.capturePod] is its writer —
/// mirrored at capture time so the reports-history thumbs see the same photo.
const String _kPodPhotosKey = 'bs.pod-photos.v1';

class FulfillmentNotifier extends StateNotifier<Map<String, Fulfillment>> {
  FulfillmentNotifier({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests) skip SharedPreferences entirely.
  final bool persist;
  bool _loaded = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kFulfillmentKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final map = (jsonDecode(raw) as Map<String, dynamic>).map(
        (id, v) => MapEntry(id, Fulfillment.fromJson(v as Map<String, dynamic>)),
      );
      if (!_loaded) {
        super.state = map;
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kFulfillmentKey,
        jsonEncode({for (final e in state.entries) e.key: e.value.toJson()}),
      );
    } on Object catch (_) {}
  }

  @override
  set state(Map<String, Fulfillment> value) {
    _loaded = true;
    super.state = value;
    _persist();
  }

  /// Current record for [id] (default empty — behaves as pre-T5).
  Fulfillment of(String id) => state[id] ?? const Fulfillment();

  void _put(String id, Fulfillment f) => state = {...state, id: f};

  // ── Picking (T5.1) ─────────────────────────────────────────────────────────

  /// `storePickLine(i)` [L17576] — toggle a line "picked" (clears missing). If
  /// un-picking, return to pending. Clears the hold if no line still pends a
  /// decision (proto un-flag path).
  void pickLine(String id, int line) {
    final f = of(id);
    final cur = f.lineStatus[line] ?? LineStatus.pending;
    final next = {...f.lineStatus};
    next[line] = cur == LineStatus.picked ? LineStatus.pending : LineStatus.picked;
    final stillPending =
        next.values.any((s) => s == LineStatus.pendingDecision);
    _put(id, f.copyWith(lineStatus: next, heldForMissing: stillPending));
  }

  /// `storeMissLine(i)` [L17585] — toggle a line "missing"; on a *newly* flagged
  /// missing line set `hasMissing=heldForMissing=true` and mark the line
  /// `pendingDecision` (the order is now held until the contractor decides).
  /// Un-flagging clears `pendingDecision`/`heldForMissing`.
  /// Returns true if this flag newly held the order (so the UI can pop the
  /// missing-item notice).
  bool missLine(String id, int line) {
    final f = of(id);
    final cur = f.lineStatus[line] ?? LineStatus.pending;
    final next = {...f.lineStatus};
    final nowMissing =
        cur != LineStatus.missing && cur != LineStatus.pendingDecision;
    if (nowMissing) {
      next[line] = LineStatus.pendingDecision;
    } else {
      next[line] = LineStatus.pending;
    }
    final stillPending =
        next.values.any((s) => s == LineStatus.pendingDecision);
    _put(id, f.copyWith(lineStatus: next, heldForMissing: stillPending));
    return nowMissing;
  }

  // ── Missing-item decision loop (T5.2, contractor side) ───────────────────────

  /// `missingProceedWithout(lineIdx)` [L17701] — contractor cancels the missing
  /// line; it becomes `cancelled`, order is no longer held, `missingResolved`.
  void proceedWithout(String id, int line) {
    final f = of(id);
    final next = {...f.lineStatus}..[line] = LineStatus.cancelled;
    _put(
      id,
      f.copyWith(
        lineStatus: next,
        heldForMissing:
            next.values.any((s) => s == LineStatus.pendingDecision),
        missingResolved: true,
      ),
    );
  }

  /// `missingReplace(lineIdx)` [L17717] / `notifyStoreOfDecision('replaced')`
  /// [L17680] — contractor replaces the missing line; it becomes `replaced`,
  /// order released, `missingResolved`.
  void replaceLine(String id, int line) {
    final f = of(id);
    final next = {...f.lineStatus}..[line] = LineStatus.replaced;
    _put(
      id,
      f.copyWith(
        lineStatus: next,
        heldForMissing:
            next.values.any((s) => s == LineStatus.pendingDecision),
        missingResolved: true,
      ),
    );
  }

  // ── Split shipments (T5.3) ───────────────────────────────────────────────────

  /// Split an [lineCount]-line order into [groups] shipments, round-robin
  /// (proto `splitPlan` derivation §1.5). `groups<=1` clears any split.
  void split(String id, int lineCount, int groups) {
    final f = of(id);
    if (groups <= 1) {
      _put(id, f.copyWith(splitInto: 1, splitPlan: const []));
      return;
    }
    final plan = [for (var i = 0; i < lineCount; i++) (i % groups) + 1];
    _put(id, f.copyWith(splitInto: groups, splitPlan: plan));
  }

  // ── Courier POD (T5.4 · COURIER v2 (a) real capture) ─────────────────────────

  /// `capturePOD()` [L20863] — REAL photo capture: stores the [dataUrl]
  /// returned by the camera seam (`services/task_photo.dart pickTaskPhoto`,
  /// the webcam sheet on desktop web) on the record — persisted with the
  /// side-car (`bs.fulfillment.v1`) so the proof survives F5 and the store
  /// delivered card / manager render the SAME string — and mirrors it into
  /// the `bs.pod-photos.v1` side-map the courier reports tab reads.
  void capturePod(String id, String dataUrl) {
    _put(id, of(id).copyWith(podPhoto: dataUrl));
    _mirrorPodPhoto(id, dataUrl);
  }

  /// Best-effort mirror of a captured POD photo into `bs.pod-photos.v1`
  /// (`{orderId: dataUrl}` — read by `podPhotosProvider` in
  /// screens/courier_reports_tab.dart, which re-reads on every mutation of
  /// this notifier). Once the write lands the state is re-notified (same
  /// content, new identity) so that join re-reads AFTER the photo is actually
  /// stored — the thumbs never race the capture.
  Future<void> _mirrorPodPhoto(String id, String dataUrl) async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPodPhotosKey);
      final map = raw == null || raw.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      map[id] = dataUrl;
      await prefs.setString(_kPodPhotosKey, jsonEncode(map));
      if (mounted) super.state = Map.of(state);
    } on Object catch (_) {}
  }

  /// `openSignature` [L20842] — simulated signature capture.
  void captureSignature(String id) =>
      _put(id, of(id).copyWith(podSigned: true));

  void clear(String id) => state = {...state}..remove(id);
}

/// The deferred-fulfillment side-car — keyed by order id, read alongside
/// [sysOrdersProvider] by the store picking sheet, the held cards, and the
/// courier POD sheet.
final fulfillmentProvider =
    StateNotifierProvider<FulfillmentNotifier, Map<String, Fulfillment>>(
  (_) => FulfillmentNotifier(),
);
