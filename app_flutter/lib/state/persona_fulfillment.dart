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
//
// SERVER-SWAP: the fulfillment side-car (bs.fulfillment.v1 + bs.pod-photos.v1
// mirror) becomes the server's fulfillment/POD store when the backend lands;
// courierUser is then the authenticated uid.

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
    this.podSignature,
    bool podCaptured = false,
    bool podSigned = false,
    this.courierUser,
  })  : _podCaptured = podCaptured,
        _podSignedFlag = podSigned;

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

  /// Courier POD signature — the REAL captured signature as a data-URL string
  /// (`data:image/png;base64,…`), produced ON-DEVICE by the signature pad
  /// (widgets/signature_pad.dart) rasterizing the recipient's strokes to a PNG;
  /// or, when `kCloudPhotos` is ON, an uploaded `https://…` R2 URL (same dual
  /// form as [podPhoto]). Null ⇒ no signature yet, including legacy pre-pad
  /// records whose simulated boolean flag carried no image. [podSigned] is true
  /// ONLY when this is non-null (honest — never a demo).
  final String? podSignature;

  /// Round-trip backing for [podCaptured] (json `podCaptured`) — the photo
  /// bytes themselves live ONLY in the `bs.pod-photos.v1` side-map (single
  /// copy), so the compact side-car payload carries just this flag.
  final bool _podCaptured;

  /// Round-trip backing for [podSigned]. True ONLY when a real [podSignature]
  /// exists (or a hydrated legacy flag) — there is no "signed but no image"
  /// honest state for a fresh capture; the pad cannot save an empty signature.
  final bool _podSignedFlag;

  /// COURIER v2 (#86.6): username of the courier who captured the POD /
  /// marked delivered — stamped at the action points by the logged-in courier
  /// session. Null on legacy records and on non-courier flows (honest: never
  /// invented, back-compat payloads without `cu` stay null).
  final String? courierUser;

  bool get hasMissing =>
      lineStatus.values.any((s) => s == LineStatus.missing) ||
      lineStatus.values.any((s) => s == LineStatus.pendingDecision);

  int get missingCount =>
      lineStatus.values.where((s) => s == LineStatus.missing).length;

  /// True once a REAL POD photo exists — [podPhoto] is hydrated from the one
  /// stored data-URL (`bs.pod-photos.v1`), and the persisted `podCaptured`
  /// boolean keeps the fact across a round-trip where the photo bytes live
  /// only in that side-map. Every reader (courier reports/profile,
  /// delivery-job card, store delivered card) keys off the same record.
  bool get podCaptured => podPhoto != null || _podCaptured;

  /// True ONLY with a REAL signature — a captured [podSignature] data-URL (or a
  /// hydrated legacy flag from a pre-pad record). Honest: a fresh save sets this
  /// solely because an actual signature image exists; the pad cannot produce an
  /// empty/demo one. Every reader (the POD sheet pill, the store delivered card)
  /// keys off the same record.
  bool get podSigned => podSignature != null || _podSignedFlag;

  /// NOTE — `??` semantics: no field can be RESET to null/default through
  /// copyWith (e.g. [courierUser]); construct a fresh record if that is ever
  /// needed.
  Fulfillment copyWith({
    Map<int, LineStatus>? lineStatus,
    bool? heldForMissing,
    bool? missingResolved,
    int? splitInto,
    List<int>? splitPlan,
    String? podPhoto,
    String? podSignature,
    bool? podSigned,
    String? courierUser,
  }) => Fulfillment(
    lineStatus: lineStatus ?? this.lineStatus,
    heldForMissing: heldForMissing ?? this.heldForMissing,
    missingResolved: missingResolved ?? this.missingResolved,
    splitInto: splitInto ?? this.splitInto,
    splitPlan: splitPlan ?? this.splitPlan,
    podPhoto: podPhoto ?? this.podPhoto,
    podSignature: podSignature ?? this.podSignature,
    podCaptured: _podCaptured,
    // The flag follows the same `??` keep-semantics as the other fields; a
    // captured podSignature makes podSigned true via the getter regardless.
    podSigned: podSigned ?? _podSignedFlag,
    courierUser: courierUser ?? this.courierUser,
  );

  Map<String, dynamic> toJson() => {
    if (lineStatus.isNotEmpty)
      'ls': {for (final e in lineStatus.entries) '${e.key}': e.value.name},
    if (heldForMissing) 'held': true,
    if (missingResolved) 'res': true,
    if (splitInto > 1) 'split': splitInto,
    if (splitPlan.isNotEmpty) 'plan': splitPlan,
    // The photo data-URL is NOT serialized here — `bs.pod-photos.v1` holds
    // the single copy of the bytes; only the compact flag rides the side-car
    // (so a line toggle never re-serializes megabytes of photos).
    if (podCaptured) 'podCaptured': true,
    // The signature PNG is tiny (~few KB of mostly-white pixels), so unlike the
    // POD photo it rides the side-car directly — a guarded write when present
    // (like a real podPhoto would be). The boolean is only emitted for a legacy
    // signed-but-imageless record (back-compat); a fresh record's 'sig' is
    // implied by the presence of 'podSig'.
    if (podSignature != null) 'podSig': podSignature,
    if (podSigned && podSignature == null) 'sig': true,
    if (courierUser != null) 'cu': courierUser,
  };

  /// Defensive per-field decode: a malformed key/element degrades to the
  /// honest empty value for THAT field instead of throwing the whole record
  /// (and the notifier's loader additionally drops a record whose decode
  /// still throws — one corrupt entry never wipes the side-car).
  factory Fulfillment.fromJson(Map<String, dynamic> j) {
    final ls = <int, LineStatus>{};
    final rawLs = j['ls'];
    if (rawLs is Map) {
      for (final e in rawLs.entries) {
        final idx = int.tryParse('${e.key}');
        if (idx == null) continue; // corrupt line key — skip it, keep the rest
        ls[idx] = LineStatus.values.firstWhere(
          (s) => s.name == e.value,
          orElse: () => LineStatus.pending,
        );
      }
    }
    final rawPlan = j['plan'];
    return Fulfillment(
      lineStatus: ls,
      heldForMissing: j['held'] == true,
      missingResolved: j['res'] == true,
      splitInto: j['split'] is num ? (j['split'] as num).toInt() : 1,
      splitPlan: rawPlan is List
          ? [
              for (final e in rawPlan)
                if (e is num) e.toInt(),
            ]
          : const [],
      // Legacy payloads carried the data-URL under 'pod' (kept readable for
      // back-compat; new writes keep the bytes only in bs.pod-photos.v1); a
      // pre-v2 simulated boolean `true` carried no image → honest null.
      podPhoto: j['pod'] is String ? j['pod'] as String : null,
      // The real signature data-URL rides the side-car under 'podSig'; a
      // malformed/absent value → honest null (no signature).
      podSignature: j['podSig'] is String ? j['podSig'] as String : null,
      podCaptured: j['podCaptured'] == true,
      // 'sig' is the legacy pre-pad signed flag (carried no image); a fresh
      // record's podSigned is implied by 'podSig' via the getter.
      podSigned: j['sig'] == true,
      // Old payloads without 'cu' (or a wrong type) → honestly null.
      courierUser: j['cu'] is String ? j['cu'] as String : null,
    );
  }
}

const String kFulfillmentKey = 'bs.fulfillment.v1';

/// The `{orderId: dataUrl}` POD-photo side-map contract the courier reports
/// tab reads (screens/courier_reports_tab.dart `kPodPhotosKey`).
/// [FulfillmentNotifier.capturePod] is its writer, and since the single-copy
/// change it is the ONLY home of the photo bytes — `bs.fulfillment.v1` keeps
/// just a compact `podCaptured` flag and [FulfillmentNotifier._load] hydrates
/// [Fulfillment.podPhoto] back from this map.
const String _kPodPhotosKey = 'bs.pod-photos.v1';

class FulfillmentNotifier extends StateNotifier<Map<String, Fulfillment>> {
  FulfillmentNotifier({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests) skip SharedPreferences entirely.
  final bool persist;
  bool _loaded = false;

  /// True once [_load] actually finished reading `bs.fulfillment.v1` (loaded,
  /// empty or corrupt). Distinct from [_loaded], which an early mutation also
  /// sets: while the disk has NOT been read yet, [_persist] merges-on-write so
  /// a cold-start mutation cannot clobber the other orders' records on disk.
  bool _diskRead = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return; // container disposed while prefs resolved
      final raw = prefs.getString(kFulfillmentKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        _diskRead = true;
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // Defensive per-entry decode — a single corrupt record is dropped on
      // its own; it must NOT wipe every other order's POD/hold/split state
      // (the AttendanceDay.tryFromJson pattern).
      final map = <String, Fulfillment>{};
      for (final e in decoded.entries) {
        try {
          final v = e.value;
          if (v is! Map) continue;
          map[e.key] = Fulfillment.fromJson(v.cast<String, dynamic>());
        } on Object catch (_) {
          // skip just this record, keep the rest
        }
      }
      // Hydrate the photo bytes from their single home (bs.pod-photos.v1) so
      // in-memory readers (store delivered card, POD sheet, reports thumbs)
      // keep seeing the SAME stored data-URL.
      try {
        final podsRaw = prefs.getString(_kPodPhotosKey);
        if (podsRaw != null && podsRaw.isNotEmpty) {
          final pods = jsonDecode(podsRaw) as Map<String, dynamic>;
          for (final e in pods.entries) {
            final rec = map[e.key];
            final url = e.value;
            if (rec != null && rec.podPhoto == null && url is String) {
              map[e.key] = rec.copyWith(podPhoto: url);
            }
          }
        }
      } on Object catch (_) {
        // corrupt photo side-map — records keep their honest podCaptured
        // flag; the photos themselves are simply absent.
      }
      if (!mounted) return; // re-check before touching state
      if (!_loaded) {
        super.state = map;
        _loaded = true;
      } else {
        // An early mutation won the race (its _persist already merged onto
        // disk) — fold the disk records UNDER the in-memory ones so the NEXT
        // persist does not clobber them either.
        super.state = {...map, ...state};
      }
      _diskRead = true;
    } on Object catch (_) {
      _loaded = true;
      _diskRead = true;
    }
  }

  /// True when the write actually landed; false on a storage failure — most
  /// commonly the web localStorage quota. Honest (the worker_profile_store
  /// pattern): [capturePod] rolls back instead of faking success.
  Future<bool> _persist() async {
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> out = {
        for (final e in state.entries) e.key: e.value.toJson(),
      };
      if (!_diskRead) {
        // Merge-on-write: this mutation raced ahead of _load — fold the
        // records already on disk under the in-memory ones (memory wins per
        // key) instead of overwriting every other order's state.
        try {
          final raw = prefs.getString(kFulfillmentKey);
          if (raw != null && raw.isNotEmpty) {
            final onDisk = jsonDecode(raw) as Map<String, dynamic>;
            out = {...onDisk, ...out};
          }
        } on Object catch (_) {
          // corrupt disk payload — nothing mergeable, write memory as-is
        }
      }
      return await prefs.setString(kFulfillmentKey, jsonEncode(out));
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
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

  /// `capturePOD()` [L20863] — REAL photo capture, atomically attributed to
  /// the capturing courier (#86.6). Stores the [dataUrl] returned by the
  /// camera seam (`services/task_photo.dart pickTaskPhoto`, the webcam sheet
  /// on desktop web) together with [courierUser] in ONE mutation (one
  /// persist, one fan-out — never a separate side-map for the attribution),
  /// then writes the photo bytes into `bs.pod-photos.v1` — their single
  /// stored home — so the proof survives F5 and the store delivered card /
  /// manager / reports thumbs render the SAME string.
  ///
  /// Returns true only when the writes actually landed. On a storage failure
  /// (e.g. the web localStorage quota rejecting a too-large data-URL) the
  /// in-memory state is rolled back and false is returned — the caller must
  /// NOT toast success on false.
  ///
  /// [courierUser]: pass `session.username` only when a real courier session
  /// performed the capture; otherwise null — a non-courier flow (e.g. the
  /// persona portal) stays honestly un-attributed.
  Future<bool> capturePod(
    String id,
    String dataUrl, {
    String? courierUser,
  }) async {
    final before = state;
    final next = {
      ...state,
      id: of(id).copyWith(podPhoto: dataUrl, courierUser: courierUser),
    };
    // Full equivalence to the `set state` override minus its auto-persist:
    // _loaded first, then the notify.
    _loaded = true;
    super.state = next;
    final ok = await _persist();
    if (!ok) {
      if (mounted) super.state = before;
      return false; // no _mirrorPodPhoto on a failed side-car write
    }
    // The side-map is the ONLY home of the photo bytes — the rollback
    // contract applies to this write too.
    final mirrored = await _mirrorPodPhoto(id, dataUrl);
    if (!mirrored) {
      if (mounted) {
        super.state = before;
        // The compact side-car row already landed — re-persist the rolled-
        // back state (best-effort) so a reload never shows podCaptured=true
        // with no photo behind it.
        await _persist();
      }
      return false;
    }
    return true;
  }

  /// #86.6 — stamps the courier who completed the delivery on the order's
  /// record, called at the courierAdvance moments that reach `delivered`.
  /// Goes through the normal mutation path (auto-persist); never touches
  /// podPhoto/podSigned (copyWith keeps them).
  void stampCourier(String id, String username) =>
      _put(id, of(id).copyWith(courierUser: username));

  /// Writes a captured POD photo into `bs.pod-photos.v1` (`{orderId:
  /// dataUrl}` — the single stored copy of the bytes, hydrated back by
  /// [_load] and read by the courier reports tab). Returns true only when
  /// the write actually landed.
  Future<bool> _mirrorPodPhoto(String id, String dataUrl) async {
    if (!persist) return true; // tests: in-memory only, nothing can fail
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> map;
      try {
        final raw = prefs.getString(_kPodPhotosKey);
        map = raw == null || raw.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(raw) as Map<String, dynamic>;
      } on Object catch (_) {
        // corrupt side-map — rebuild it rather than block every new capture
        map = <String, dynamic>{};
      }
      map[id] = dataUrl;
      return await prefs.setString(_kPodPhotosKey, jsonEncode(map));
    } on Object catch (_) {
      return false; // quota exceeded / platform failure — nothing persisted
    }
  }

  /// `openSignature` [L20842] — REAL signature capture. Stores the [dataUrl]
  /// produced ON-DEVICE by the signature pad (widgets/signature_pad.dart
  /// rasterizing the recipient's strokes to a PNG); podSigned then reads true
  /// because a real signature image exists (the getter keys off podSignature).
  /// Honest: there is no empty-save path — the pad never hands back a blank
  /// data-URL, and a caller must not invoke this without one.
  ///
  /// A3 — mirrors [capturePod]'s await+rollback. The signature data-URL rides
  /// the MAIN side-car (`'podSig'` in [Fulfillment.toJson]), so one awaited
  /// [_persist] is the whole write (no [_mirrorPodPhoto] — that is photo-only).
  /// Returns true only when the write actually landed; on a storage failure the
  /// in-memory state is rolled back and false returned, so the caller must NOT
  /// toast success on false (it says "החתימה לא נשמרה" instead).
  Future<bool> captureSignature(String id, String dataUrl) async {
    final before = state;
    // Equivalence to the `set state` override minus its auto-persist, so the
    // single awaited _persist below is the only write (same shape as capturePod).
    _loaded = true;
    super.state = {
      ...state,
      id: of(id).copyWith(podSignature: dataUrl),
    };
    final ok = await _persist();
    if (!ok && mounted) super.state = before; // roll back a faked success
    return ok;
  }

  void clear(String id) {
    state = {...state}..remove(id);
    // Drop the photo bytes too (best-effort) — an orphaned bs.pod-photos.v1
    // entry would otherwise keep counting in podCount forever.
    _unmirrorPodPhoto(id);
  }

  /// Best-effort removal of [id]'s entry from `bs.pod-photos.v1` when the
  /// record is cleared.
  Future<void> _unmirrorPodPhoto(String id) async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPodPhotosKey);
      if (raw == null || raw.isEmpty) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map.remove(id) == null) return;
      await prefs.setString(_kPodPhotosKey, jsonEncode(map));
    } on Object catch (_) {
      // best-effort — a failed cleanup never blocks the clear itself
    }
  }
}

/// The deferred-fulfillment side-car — keyed by order id, read alongside
/// [sysOrdersProvider] by the store picking sheet, the held cards, and the
/// courier POD sheet.
final fulfillmentProvider =
    StateNotifierProvider<FulfillmentNotifier, Map<String, Fulfillment>>(
  (_) => FulfillmentNotifier(),
);
