/// Maintenance module — Riverpod state over the pure engine.
///
/// [MxNotifier] holds the [MxDb], persists it to SharedPreferences under
/// [kMxDbKey] (same versioned `bs.*.v1` idiom as the other engines), and turns
/// engine [MxError]s into a returned message for the UI (null = success).
/// The clock is injectable ([mxClockProvider]) so widget tests are stable.
///
/// SERVER-SWAP: a Firestore repo (orgs/{org}/mx/*) replaces the prefs blob in
/// the pilot; the engine and screens do not change.
library;

import 'dart:convert';

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
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
  MxNotifier(this._now, {bool persist = true, MxDb? initial})
    : _persist = persist,
      super(initial ?? mxDemoSeed(_now())) {
    if (persist) _load();
  }

  final DateTime Function() _now;
  final bool _persist;
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
  }) => _run((db, now) {
    final (n, id) = reportFault(
      db,
      pointId: pointId,
      desc: desc,
      reportedBy: by,
      now: now,
      hasPhoto: photo,
    );
    lastCreatedId = id;
    return n;
  });

  String? assign(String woId, String tech) =>
      _run((db, _) => assignWorkOrder(db, woId, tech));
  String? closeWithPart(String woId, String by) =>
      _run((db, now) => _closeWithPart(db, woId, by, now));
  String? closeNoPart(String woId, String by) =>
      _run((db, now) => _closeNoPart(db, woId, by, now));

  String? requestPart(String woId, int qty, String by) => _run((db, now) {
    final (n, id) = _requestPart(db, woId, qty, by, now);
    lastCreatedId = id;
    return n;
  });

  String? autoReorder() => _run((db, now) {
    final (n, ids) = _autoReorder(db, now);
    if (ids.isEmpty) {
      throw const MxError(
        'אין פריטים להזמין – הכול מעל המינימום או כבר בהזמנה',
      );
    }
    lastCreatedId = ids.first;
    return n;
  });

  String? approve(String poId) => _run((db, _) => approvePo(db, poId));
  String? reject(String poId) => _run((db, _) => rejectPo(db, poId));
  String? receive(String poId) => _run((db, _) => receivePo(db, poId));
  String? reroute(String poId) => _run((db, now) {
    final (n, id) = rerouteMissing(db, poId, now: now);
    if (id == null) throw const MxError('אין פריטים חסרים');
    lastCreatedId = id;
    return n;
  });

  String? storeConfirm(String token) =>
      _run((db, _) => storeAct(db, token, MxStoreAction.confirm));
  String? storeReady(
    String token, {
    String invoiceNo = '',
    String allocationNo = '',
  }) => _run(
    (db, _) => storeAct(
      db,
      token,
      MxStoreAction.ready,
      invoiceNo: invoiceNo,
      allocationNo: allocationNo,
    ),
  );
  String? storeMissing(String token, String sku) =>
      _run((db, _) => storeMarkMissing(db, token, sku));

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
MxDb _closeNoPart(MxDb db, String id, String by, DateTime now) =>
    closeNoPart(db, id, by: by, now: now);
(MxDb, String) _requestPart(
  MxDb db,
  String id,
  int qty,
  String by,
  DateTime now,
) => requestPart(db, id, qty: qty, by: by, now: now);
(MxDb, List<String>) _autoReorder(MxDb db, DateTime now) =>
    autoReorder(db, now: now);
MxDb _completePm(MxDb db, String id, DateTime now) =>
    completePm(db, id, now: now);

final mxDbProvider = StateNotifierProvider<MxNotifier, MxDb>(
  (ref) => MxNotifier(ref.watch(mxClockProvider)),
);
