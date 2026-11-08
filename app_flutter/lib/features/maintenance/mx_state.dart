/// Maintenance module — Riverpod state over the pure engine.
///
/// [MxNotifier] holds the [MxDb], persists it to SharedPreferences under
/// [kMxDbKey] (same versioned `bs.*.v1` idiom as the other engines), and turns
/// engine [MxError]s into a returned message for the UI (null = success).
/// The clock is injectable ([mxClockProvider]) so widget tests are stable.
///
/// Purchasing is NOT a parallel pipeline: every PO is mirrored into
/// BuildSmart's own engines through [MxPurchasingPort] (see `mx_bridge.dart`)
/// — the approval queue (`materialRequestsProvider`) and the store dashboard
/// (`ordersEngineProvider`), both Firestore-backed when the backend is on.
///
/// SERVER-SWAP: the register / PM / stock blob moves to Firestore
/// (orgs/{org}/mx/*) in the pilot; the engine and screens do not change.
library;

import 'dart:convert';

import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kMxDbKey = 'bs.mx.db.v1';

/// Base URL of the store page (`<base>/s/<token>`). Overridable per deploy.
const String kMxStoreBaseUrl = String.fromEnvironment(
  'MX_STORE_BASE',
  defaultValue: 'https://buildsmart-il.com/mx',
);

/// Organization display name used in store messages.
const String kMxOrgName = String.fromEnvironment(
  'MX_ORG_NAME',
  defaultValue: 'מחלקת האחזקה',
);

final mxClockProvider = Provider<DateTime Function()>((_) => DateTime.now);

/// Who is using the app right now (demo role switch; real auth maps roles).
final mxRoleProvider = StateProvider<MxRole>((_) => MxRole.manager);

class MxNotifier extends StateNotifier<MxDb> {
  MxNotifier(
    this._now, {
    bool persist = true,
    MxDb? initial,
    MxPurchasingPort port = const MxNoPort(),
  }) : _persist = persist,
       _port = port,
       super(initial ?? mxDemoSeed(_now())) {
    if (persist) _load();
  }

  final DateTime Function() _now;
  final bool _persist;
  final MxPurchasingPort _port;
  MxDb? _undo;

  /// Undo the last local step (fix / found part / inspection done / store
  /// marks). Steps that touched BuildSmart's engines use a confirm instead.
  bool undo() {
    final prev = _undo;
    if (prev == null) return false;
    _undo = null;
    state = prev;
    _save();
    return true;
  }

  bool _touched = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kMxDbKey);
      if (raw == null || _touched || !mounted) return;
      state = MxDb.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
    } on Object {
      // Corrupt blob → keep the in-memory db; the next write replaces it.
    }
  }

  Future<void> _save() async {
    if (!_persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kMxDbKey, jsonEncode(state.toJson()));
    } on Object {
      // Best effort — storage may be unavailable (private mode).
    }
  }

  /// Apply an engine step; returns an error message or null on success.
  String? _run(MxDb Function(MxDb db, DateTime now) step) {
    try {
      final next = step(state, _now());
      _touched = true;
      _undo = state;
      state = next;
      _save();
      return null;
    } on MxError catch (e) {
      return e.message;
    }
  }

  /// Start over from the demo seed.
  void reset() {
    _touched = true;
    state = mxDemoSeed(_now());
    _save();
  }

  String? lastCreatedId;

  String? report(
    String pointId,
    String desc,
    String by, {
    bool photo = false,
    String photoData = '',
  }) => _run((db, now) {
    final (n, id) = reportFault(
      db,
      pointId: pointId,
      desc: desc,
      reportedBy: by,
      now: now,
      hasPhoto: photo,
      photo: photoData,
    );
    lastCreatedId = id;
    return n;
  });

  String? assign(String woId, String tech) =>
      _run((db, now) => assignWorkOrder(db, woId, tech, now: now));
  String? comment(String woId, String text, String by) =>
      _run((db, now) => commentOn(db, woId, text, by: by, now: now));
  String? cancelRequest(String woId, String by) {
    final po = state.workOrder(woId).poId;
    final err = _run(
      (db, now) => cancelPartRequest(db, woId, by: by, now: now),
    );
    if (err == null && po.isNotEmpty) _port.reject(state.po(po));
    return err;
  }

  /// Part found elsewhere: close the job, cancel the pending request.
  String? foundPart(String woId, String by) {
    final po = state.workOrder(woId).poId;
    final err = _run(
      (db, now) =>
          _closeNoPartNote(db, woId, by, now, 'תוקן – החלק נמצא ממקור אחר'),
    );
    if (err == null &&
        po.isNotEmpty &&
        state.po(po).status == MxPoStatus.rejected) {
      _port.reject(state.po(po));
    }
    return err;
  }

  String? closeWithPart(String woId, String by) =>
      _run((db, now) => _closeWithPart(db, woId, by, now));
  String? closeNoPart(String woId, String by) =>
      _run((db, now) => _closeNoPart(db, woId, by, now));

  /// File every PO in [poIds] into BuildSmart's approval queue.
  void _submit(List<String> poIds, String techName) {
    var db = state;
    for (final id in poIds) {
      final reqId = _port.submitRequest(db, db.po(id), techName: techName);
      if (reqId.isNotEmpty) db = linkPo(db, id, matReqId: reqId);
    }
    if (!identical(db, state)) {
      state = db;
      _save();
    }
  }

  String? requestPart(String woId, int qty, String by, {String? sku}) {
    final err = _run((db, now) {
      final (n, id) = requestPart_(db, woId, qty, by, now, sku);
      lastCreatedId = id;
      return n;
    });
    if (err == null) _submit([lastCreatedId!], by);
    return err;
  }

  String? autoReorder() {
    var ids = <String>[];
    final err = _run((db, now) {
      final (n, created) = _autoReorder(db, now);
      if (created.isEmpty) {
        throw const MxError(
          'אין פריטים להזמין – הכול מעל המינימום או כבר בהזמנה',
        );
      }
      ids = created;
      lastCreatedId = created.first;
      return n;
    });
    if (err == null) _submit(ids, 'המערכת · מינימום מלאי');
    return err;
  }

  String? approve(String poId) {
    final err = _run((db, _) => approvePo(db, poId));
    if (err != null) return err;
    final po = state.po(poId);
    final orderId = _port.approve(state, po, site: mxPoSite(state, po));
    if (orderId.isNotEmpty) {
      state = linkPo(state, poId, orderId: orderId);
      _save();
    }
    return null;
  }

  String? reject(String poId, {String reason = ''}) {
    final err = _run((db, now) => rejectPo(db, poId, reason: reason, now: now));
    if (err == null) _port.reject(state.po(poId));
    return err;
  }

  /// The order actually left (WhatsApp opened / link delivered).
  String? markSent(String poId) => _run((db, _) => mxMarkSent(db, poId));

  String? receive(String poId) {
    final err = _run((db, now) => receivePo(db, poId, now: now));
    if (err == null) _port.received(state.po(poId));
    return err;
  }

  String? reroute(String poId) {
    final err = _run((db, now) {
      final (n, id) = rerouteMissing(db, poId, now: now);
      if (id == null) throw const MxError('אין פריטים חסרים');
      lastCreatedId = id;
      return n;
    });
    if (err == null) _submit([lastCreatedId!], 'הפניית חוסרים');
    return err;
  }

  /// Adopt stages a store set on its BuildSmart dashboard.
  void syncFromOrders(List<Order> orders) {
    final byId = {for (final o in orders) o.id: o.stage};
    var db = state;
    for (final po in db.purchaseOrders) {
      final stage = byId[po.orderId];
      if (po.orderId.isNotEmpty && stage != null) {
        db = syncPoFromStage(db, po.id, stage);
      }
    }
    if (!identical(db, state)) {
      state = db;
      _save();
    }
  }

  /// The store's link actions also move its BuildSmart order.
  String? _store(String token, MxDb Function(MxDb) step, String stage) {
    final err = _run((db, _) => step(db));
    if (err == null) {
      final po = state.poByToken(token);
      if (po != null) _port.storeStage(po, stage);
    }
    return err;
  }

  String? storeConfirm(String token) => _store(
    token,
    (db) => storeAct(db, token, MxStoreAction.confirm),
    'preparing',
  );
  String? storeReady(
    String token, {
    String invoiceNo = '',
    String allocationNo = '',
    MxFulfil? fulfil,
  }) => _store(
    token,
    (db) => storeAct(
      db,
      token,
      MxStoreAction.ready,
      invoiceNo: invoiceNo,
      allocationNo: allocationNo,
      fulfil: fulfil,
    ),
    fulfil == MxFulfil.delivery ? 'transit' : 'ready',
  );
  String? storeMissing(String token, String sku) =>
      _run((db, _) => storeMarkMissing(db, token, sku));
  String? storeSupplied(String token, String sku, int n) =>
      _run((db, _) => storeSetSupplied(db, token, sku, n));

  /// BuildSmart stage of a PO's store order (null = not placed / unknown).
  String? storeStageOf(MxPurchaseOrder po) =>
      po.orderId.isEmpty ? null : _port.stageOf(po.orderId);

  String? completePm(String ruleId) =>
      _run((db, now) => _completePm(db, ruleId, now));

  /// Import a store price list; returns (error-or-null, import report).
  (String?, MxPriceImport?) importPrices(String storeId, String csv) {
    final imp = mxParsePriceList(csv, state.parts);
    if (imp.matched.isEmpty) {
      return (
        imp.errors.isEmpty ? 'לא זוהו פריטים מתאימים' : imp.errors.first,
        imp,
      );
    }
    return (_run((db, _) => mxApplyPrices(db, storeId, imp)), imp);
  }
}

// Top-level aliases so the notifier's method names can mirror the engine's.
MxDb _closeWithPart(MxDb db, String id, String by, DateTime now) =>
    closeWithPart(db, id, by: by, now: now);
MxDb _closeNoPartNote(
  MxDb db,
  String id,
  String by,
  DateTime now,
  String note,
) => closeNoPart(db, id, by: by, now: now, note: note);
MxDb _closeNoPart(MxDb db, String id, String by, DateTime now) =>
    closeNoPart(db, id, by: by, now: now);
(MxDb, String) requestPart_(
  MxDb db,
  String id,
  int qty,
  String by,
  DateTime now,
  String? sku,
) => requestPart(db, id, qty: qty, by: by, now: now, sku: sku);
(MxDb, List<String>) _autoReorder(MxDb db, DateTime now) =>
    autoReorder(db, now: now);
MxDb _completePm(MxDb db, String id, DateTime now) =>
    completePm(db, id, now: now);

/// The seam to BuildSmart's engines (tests may override with [MxNoPort]).
final mxPurchasingPortProvider = Provider<MxPurchasingPort>(
  MxBuildSmartPort.new,
);

final mxDbProvider = StateNotifierProvider<MxNotifier, MxDb>((ref) {
  final n = MxNotifier(
    ref.watch(mxClockProvider),
    port: ref.watch(mxPurchasingPortProvider),
  );
  // A store that advances the order on its own BuildSmart dashboard moves the
  // PO forward here too.
  ref.listen<List<Order>>(
    ordersEngineProvider,
    (_, orders) => n.syncFromOrders(orders),
  );
  return n;
});
