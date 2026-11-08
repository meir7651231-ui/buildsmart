/// Maintenance module — the pure state machine.
///
/// Every operation takes an [MxDb] and returns a NEW [MxDb] (or throws
/// [MxError] with a Hebrew message for the UI). No I/O, no clock: callers pass
/// `now`, so every rule is unit-testable and deterministic.
///
/// Flows:
///   fault  : reportFault → assign → closeWithPart | requestPart → (PO) → close
///   stock  : closeWithPart consumes 1; receivePo adds; lowStock → autoReorder
///   buying : PO pendingApproval → approve(sent, token) → store answers via
///            link/app (confirm | missing | ready) → receivePo → stock + jobs
///   PM     : pmDue(now) classifies; completePm stamps lastDone
library;

import 'dart:math';

import 'package:buildsmart/features/maintenance/mx_model.dart';

class MxError implements Exception {
  const MxError(this.message);
  final String message;
  @override
  String toString() => 'MxError: $message';
}

/// PM urgency at a given moment.
enum MxDue { overdue, soon, ok }

/// Days ahead that count as "due soon".
const int kMxSoonDays = 7;

/// Store-side answers through the no-login link (or the store dashboard).
enum MxStoreAction { confirm, ready }

extension MxQueries on MxDb {
  MxPoint point(String id) => points.firstWhere(
    (p) => p.id == id,
    orElse: () => throw MxError('נקודה לא נמצאה: $id'),
  );
  MxRoom room(String id) => rooms.firstWhere(
    (r) => r.id == id,
    orElse: () => throw MxError('חדר לא נמצא: $id'),
  );
  MxUnit unit(String id) => units.firstWhere(
    (u) => u.id == id,
    orElse: () => throw MxError('יחידה לא נמצאה: $id'),
  );
  MxSite site(String id) => sites.firstWhere(
    (s) => s.id == id,
    orElse: () => throw MxError('אתר לא נמצא: $id'),
  );
  MxPart part(String sku) => parts.firstWhere(
    (p) => p.sku == sku,
    orElse: () => throw MxError('פריט לא נמצא: $sku'),
  );
  MxStore store(String id) => stores.firstWhere(
    (s) => s.id == id,
    orElse: () => throw MxError('חנות לא נמצאה: $id'),
  );
  MxWorkOrder workOrder(String id) => workOrders.firstWhere(
    (w) => w.id == id,
    orElse: () => throw MxError('קריאה לא נמצאה: $id'),
  );
  MxPurchaseOrder po(String id) => purchaseOrders.firstWhere(
    (o) => o.id == id,
    orElse: () => throw MxError('הזמנה לא נמצאה: $id'),
  );

  /// The PO a store link token points at, or null (unknown / revoked token).
  MxPurchaseOrder? poByToken(String token) {
    if (token.isEmpty) return null;
    for (final o in purchaseOrders) {
      if (o.token == token) return o;
    }
    return null;
  }

  int qty(String sku) => stock[sku] ?? 0;

  /// Full human path of a point: "ירושלים · דירה 3 · מטבח · שקע 3 – מעל משטח".
  String pointPath(String pointId) {
    final p = point(pointId);
    final r = room(p.roomId);
    final u = unit(r.unitId);
    final s = site(u.siteId);
    return '${s.city} · ${u.name} · ${r.name} · ${p.label}';
  }

  List<MxRoom> roomsOf(String unitId) =>
      rooms.where((r) => r.unitId == unitId).toList();
  List<MxPoint> pointsOf(String roomId) =>
      points.where((p) => p.roomId == roomId).toList();
  List<MxUnit> unitsOf(String siteId) =>
      units.where((u) => u.siteId == siteId).toList();
  int pointCountOfUnit(String unitId) {
    final ids = {for (final r in roomsOf(unitId)) r.id};
    return points.where((p) => ids.contains(p.roomId)).length;
  }

  int faultyCountOfUnit(String unitId) {
    final ids = {for (final r in roomsOf(unitId)) r.id};
    return points
        .where(
          (p) => ids.contains(p.roomId) && p.status == MxPointStatus.faulty,
        )
        .length;
  }

  /// Unit price a store charges: its imported price list, else the reference.
  int priceAt(String storeId, String sku) =>
      storePrices[storeId]?[sku] ?? part(sku).priceAgorot;

  /// The store to buy [sku] from: first store selling that store type,
  /// skipping [exclude] (used to reroute missing lines).
  MxStore? storeFor(String sku, {Set<String> exclude = const {}}) {
    final type = part(sku).storeType;
    for (final s in stores) {
      if (!exclude.contains(s.id) && s.types.contains(type)) return s;
    }
    return null;
  }

  /// Parts whose stock is below the reorder point.
  List<MxPart> get lowStock => parts.where((p) => qty(p.sku) < p.min).toList();

  /// Quantity of [sku] already on an open PO (so we never double-order).
  int onOrder(String sku) {
    var n = 0;
    for (final o in purchaseOrders.where((o) => o.isOpen)) {
      for (final l in o.lines) {
        if (l.sku == sku && !l.missing) n += l.qty;
      }
    }
    return n;
  }

  List<MxWorkOrder> get openWorkOrders =>
      workOrders.where((w) => w.isOpen).toList();
  List<MxPurchaseOrder> get pendingApproval =>
      purchaseOrders
          .where((o) => o.status == MxPoStatus.pendingApproval)
          .toList();

  MxDue dueOf(MxPmRule r, DateTime now) {
    final d = r.nextDue;
    if (d.isBefore(now)) return MxDue.overdue;
    if (d.difference(now).inDays <= kMxSoonDays) return MxDue.soon;
    return MxDue.ok;
  }

  /// PM rules ordered most-urgent first (overdue, soon, ok; then by date).
  List<(MxPmRule, MxDue)> pmDue(DateTime now) {
    final l = [for (final r in pmRules) (r, dueOf(r, now))]..sort((a, b) {
      final c = a.$2.index.compareTo(b.$2.index);
      return c != 0 ? c : a.$1.nextDue.compareTo(b.$1.nextDue);
    });
    return l;
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

List<T> _replace<T>(List<T> list, bool Function(T) where, T Function(T) f) => [
  for (final x in list) where(x) ? f(x) : x,
];

MxDb _setPoint(MxDb db, String id, MxPoint Function(MxPoint) f) =>
    db.copyWith(points: _replace(db.points, (p) => p.id == id, f));

MxDb _setWo(MxDb db, String id, MxWorkOrder Function(MxWorkOrder) f) =>
    db.copyWith(workOrders: _replace(db.workOrders, (w) => w.id == id, f));

MxDb _setPo(MxDb db, String id, MxPurchaseOrder Function(MxPurchaseOrder) f) =>
    db.copyWith(
      purchaseOrders: _replace(db.purchaseOrders, (o) => o.id == id, f),
    );

final Random _rng = Random.secure();
const String _tokenAlphabet = 'abcdefghjkmnpqrstuvwxyz23456789';

/// 20 chars from a 31-symbol alphabet ≈ 99 bits — unguessable link token.
String mxNewToken([Random? rng]) {
  final r = rng ?? _rng;
  return List.generate(
    20,
    (_) => _tokenAlphabet[r.nextInt(_tokenAlphabet.length)],
  ).join();
}

// ── work orders ──────────────────────────────────────────────────────────────

/// Open a work order on a point. Returns the new db and the work-order id.
(MxDb, String) reportFault(
  MxDb db, {
  required String pointId,
  required String desc,
  required String reportedBy,
  required DateTime now,
  bool hasPhoto = false,
}) {
  db.point(pointId); // validates
  final text = desc.trim();
  if (text.isEmpty) throw const MxError('צריך לתאר מה קרה');
  final seq = db.seq + 1;
  final id = 'WO-$seq';
  final wo = MxWorkOrder(
    id: id,
    pointId: pointId,
    desc: text,
    reportedBy: reportedBy,
    createdAt: now,
    hasPhoto: hasPhoto,
  );
  var next = db.copyWith(workOrders: [wo, ...db.workOrders], seq: seq);
  next = _setPoint(
    next,
    pointId,
    (p) => p.copyWith(status: MxPointStatus.faulty),
  );
  return (next, id);
}

MxDb assignWorkOrder(MxDb db, String woId, String tech) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  if (tech.trim().isEmpty) throw const MxError('צריך לבחור טכנאי');
  return _setWo(
    db,
    woId,
    (w) => w.copyWith(status: MxWoStatus.assigned, assignee: tech.trim()),
  );
}

/// Close a job using one unit of the point's part from stock.
MxDb closeWithPart(
  MxDb db,
  String woId, {
  required String by,
  required DateTime now,
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  final p = db.point(w.pointId);
  final have = db.qty(p.sku);
  if (have < 1) throw MxError('אין במלאי: ${db.part(p.sku).name}');
  final part = db.part(p.sku);
  var next = db.copyWith(stock: {...db.stock, p.sku: have - 1});
  next = _setWo(
    next,
    woId,
    (w) => w.copyWith(status: MxWoStatus.done, closedAt: now),
  );
  next = _setPoint(
    next,
    p.id,
    (p) => p.copyWith(
      status: MxPointStatus.ok,
      history: [
        MxEvent(
          at: now,
          text: 'תוקן – הוחלף ${part.name} ($woId)',
          by: by,
          costAgorot: part.priceAgorot,
        ),
        ...p.history,
      ],
    ),
  );
  return next;
}

/// Close a job that needed no part (adjustment, cleaning…).
MxDb closeNoPart(
  MxDb db,
  String woId, {
  required String by,
  required DateTime now,
  String note = 'תוקן ללא חלק',
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  final next = _setWo(
    db,
    woId,
    (w) => w.copyWith(status: MxWoStatus.done, closedAt: now),
  );
  return _setPoint(
    next,
    w.pointId,
    (p) => p.copyWith(
      status: MxPointStatus.ok,
      history: [MxEvent(at: now, text: '$note ($woId)', by: by), ...p.history],
    ),
  );
}

/// The tech asks for the point's part: opens a PO (pending approval) to the
/// matching store and parks the job as waiting-for-part.
(MxDb, String) requestPart(
  MxDb db,
  String woId, {
  required int qty,
  required String by,
  required DateTime now,
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  if (qty < 1) throw const MxError('כמות חייבת להיות לפחות 1');
  final sku = db.point(w.pointId).sku;
  final store = db.storeFor(sku);
  if (store == null) throw MxError('אין חנות שמוכרת ${db.part(sku).storeType}');
  final (next, poId) = _newPo(
    db,
    storeId: store.id,
    lines: [
      MxPoLine(sku: sku, qty: qty, unitAgorot: db.priceAt(store.id, sku)),
    ],
    by: by,
    now: now,
    note: 'עבור $woId',
  );
  return (
    _setWo(
      next,
      woId,
      (w) => w.copyWith(status: MxWoStatus.waitingPart, poId: poId),
    ),
    poId,
  );
}

// ── purchasing ───────────────────────────────────────────────────────────────

(MxDb, String) _newPo(
  MxDb db, {
  required String storeId,
  required List<MxPoLine> lines,
  required String by,
  required DateTime now,
  String note = '',
}) {
  final seq = db.seq + 1;
  final id = 'PO-$seq';
  final po = MxPurchaseOrder(
    id: id,
    storeId: storeId,
    lines: lines,
    requestedBy: by,
    createdAt: now,
    note: note,
  );
  return (
    db.copyWith(purchaseOrders: [po, ...db.purchaseOrders], seq: seq),
    id,
  );
}

/// One PO per store for everything below its reorder point, topping each line
/// up to 2× the minimum, minus what is already on order. Returns the new PO ids.
(MxDb, List<String>) autoReorder(MxDb db, {required DateTime now}) {
  final byStore = <String, List<MxPoLine>>{};
  for (final p in db.lowStock) {
    final want = p.min * 2 - db.qty(p.sku) - db.onOrder(p.sku);
    if (want <= 0) continue;
    final s = db.storeFor(p.sku);
    if (s == null) continue;
    (byStore[s.id] ??= []).add(
      MxPoLine(sku: p.sku, qty: want, unitAgorot: db.priceAt(s.id, p.sku)),
    );
  }
  var next = db;
  final ids = <String>[];
  for (final e in byStore.entries) {
    final (n, id) = _newPo(
      next,
      storeId: e.key,
      lines: e.value,
      by: 'המערכת · מינימום מלאי',
      now: now,
    );
    next = n;
    ids.add(id);
  }
  return (next, ids);
}

/// Manager approval: the PO is sent and gets its store-link token.
MxDb approvePo(MxDb db, String poId, {Random? rng}) {
  final o = db.po(poId);
  if (o.status != MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה לא ממתינה לאישור');
  }
  return _setPo(
    db,
    poId,
    (o) => o.copyWith(status: MxPoStatus.sent, token: mxNewToken(rng)),
  );
}

MxDb rejectPo(MxDb db, String poId, {String reason = ''}) {
  final o = db.po(poId);
  if (o.status != MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה לא ממתינה לאישור');
  }
  var next = _setPo(
    db,
    poId,
    (o) => o.copyWith(status: MxPoStatus.rejected, note: reason),
  );
  // Jobs that waited on it go back to the tech's queue.
  for (final w in next.workOrders.where((w) => w.poId == poId && w.isOpen)) {
    next = _setWo(
      next,
      w.id,
      (w) => w.copyWith(status: MxWoStatus.assigned, poId: ''),
    );
  }
  return next;
}

void _assertStoreCanAct(MxPurchaseOrder o) {
  if (o.status == MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה עוד לא אושרה');
  }
  if (o.status == MxPoStatus.received || o.status == MxPoStatus.rejected) {
    throw const MxError('ההזמנה כבר סגורה');
  }
}

/// Store answer by link token (WhatsApp) — the same call the dashboard uses.
MxDb storeAct(
  MxDb db,
  String token,
  MxStoreAction action, {
  String invoiceNo = '',
  String allocationNo = '',
}) {
  final o = db.poByToken(token);
  if (o == null) throw const MxError('הקישור לא תקף');
  _assertStoreCanAct(o);
  switch (action) {
    case MxStoreAction.confirm:
      if (o.status != MxPoStatus.sent) throw const MxError('ההזמנה כבר אושרה');
      return _setPo(
        db,
        o.id,
        (o) => o.copyWith(status: MxPoStatus.storeConfirmed),
      );
    case MxStoreAction.ready:
      return _setPo(
        db,
        o.id,
        (o) => o.copyWith(
          status: MxPoStatus.ready,
          invoiceNo: invoiceNo.trim().isEmpty ? o.invoiceNo : invoiceNo.trim(),
          allocationNo:
              allocationNo.trim().isEmpty
                  ? o.allocationNo
                  : allocationNo.trim(),
        ),
      );
  }
}

/// Store marks one line it cannot supply.
MxDb storeMarkMissing(MxDb db, String token, String sku) {
  final o = db.poByToken(token);
  if (o == null) throw const MxError('הקישור לא תקף');
  _assertStoreCanAct(o);
  if (!o.lines.any((l) => l.sku == sku)) throw MxError('הפריט לא בהזמנה: $sku');
  return _setPo(
    db,
    o.id,
    (o) => o.copyWith(
      status: MxPoStatus.storePartial,
      lines: [
        for (final l in o.lines) l.sku == sku ? l.copyWith(missing: true) : l,
      ],
    ),
  );
}

/// Send the missing lines of [poId] to another store (pending approval).
(MxDb, String?) rerouteMissing(MxDb db, String poId, {required DateTime now}) {
  final o = db.po(poId);
  final missing = o.lines.where((l) => l.missing).toList();
  if (missing.isEmpty) return (db, null);
  final alt = db.storeFor(missing.first.sku, exclude: {o.storeId});
  if (alt == null) throw const MxError('אין חנות חלופית לפריטים החסרים');
  return _newPo(
    db,
    storeId: alt.id,
    lines: [
      for (final l in missing)
        MxPoLine(sku: l.sku, qty: l.qty, unitAgorot: db.priceAt(alt.id, l.sku)),
    ],
    by: 'הפניה מ-$poId',
    now: now,
    note: 'פריטים שחסרו ב-$poId',
  );
}

/// Above this (agorot, before VAT) a supplier tax invoice must carry an
/// Israel-Invoice allocation number (₪5,000 from 1.6.2026 — verify on gov.il).
const int kMxAllocationThresholdAgorot = 500000;

bool mxNeedsAllocation(MxPurchaseOrder o) =>
    o.totalAgorot > kMxAllocationThresholdAgorot;

/// Goods received: stock += supplied lines; jobs waiting on this PO go back to
/// "assigned" so the tech can finish them.
MxDb receivePo(MxDb db, String poId) {
  final o = db.po(poId);
  if (o.status == MxPoStatus.pendingApproval ||
      o.status == MxPoStatus.rejected) {
    throw const MxError('אי אפשר לקבל הזמנה שלא נשלחה');
  }
  if (o.status == MxPoStatus.received) throw const MxError('ההזמנה כבר התקבלה');
  if (mxNeedsAllocation(o) && o.allocationNo.isEmpty) {
    throw const MxError('חשבונית מעל הסף – חסר מספר הקצאה');
  }
  final stock = {...db.stock};
  for (final l in o.lines.where((l) => !l.missing)) {
    stock[l.sku] = (stock[l.sku] ?? 0) + l.qty;
  }
  var next = _setPo(
    db.copyWith(stock: stock),
    poId,
    (o) => o.copyWith(status: MxPoStatus.received),
  );
  for (final w in next.workOrders.where(
    (w) => w.poId == poId && w.status == MxWoStatus.waitingPart,
  )) {
    next = _setWo(next, w.id, (w) => w.copyWith(status: MxWoStatus.assigned));
  }
  return next;
}

// ── preventive maintenance ───────────────────────────────────────────────────

MxDb completePm(MxDb db, String ruleId, {required DateTime now}) {
  if (!db.pmRules.any((r) => r.id == ruleId)) {
    throw MxError('בדיקה לא נמצאה: $ruleId');
  }
  return db.copyWith(
    pmRules: _replace(
      db.pmRules,
      (r) => r.id == ruleId,
      (r) => r.copyWith(lastDone: now),
    ),
  );
}

// ── formatting ───────────────────────────────────────────────────────────────

/// 123450 → "1,234.50 ₪"; whole shekels drop the decimals: 1800 → "18 ₪".
String mxShekels(int agorot) {
  final neg = agorot < 0;
  final a = agorot.abs();
  final whole = (a ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final cents = a % 100;
  final s = cents == 0 ? whole : '$whole.${cents.toString().padLeft(2, '0')}';
  return '${neg ? '-' : ''}$s ₪';
}

// ── BuildSmart link ──────────────────────────────────────────────────────────

/// Record which BuildSmart request / order a PO rides on.
MxDb linkPo(MxDb db, String poId, {String? matReqId, String? orderId}) {
  db.po(poId); // validates
  return _setPo(
    db,
    poId,
    (o) => o.copyWith(matReqId: matReqId, orderId: orderId),
  );
}

/// BuildSmart order stage → the PO status it implies (null = no change).
/// `delivered` deliberately maps to `ready`: stock is only added when the
/// manager confirms receipt ([receivePo]) — a store tap never moves stock.
MxPoStatus? mxStatusForStage(String stage) => switch (stage) {
  'preparing' => MxPoStatus.storeConfirmed,
  'ready' || 'pickup' || 'transit' || 'delivered' => MxPoStatus.ready,
  _ => null,
};

/// Adopt a stage the store set on its own BuildSmart dashboard. Only moves a
/// PO FORWARD (never undoes a manager action, never touches closed POs, never
/// overrides a store's "missing" marks with a plain confirm).
MxDb syncPoFromStage(MxDb db, String poId, String stage) {
  final o = db.po(poId);
  final next = mxStatusForStage(stage);
  if (next == null || !o.isOpen || o.status == MxPoStatus.pendingApproval) {
    return db;
  }
  const rank = {
    MxPoStatus.sent: 0,
    MxPoStatus.storeConfirmed: 1,
    MxPoStatus.storePartial: 1,
    MxPoStatus.ready: 2,
  };
  if ((rank[next] ?? 0) <= (rank[o.status] ?? 0)) return db;
  return _setPo(db, poId, (o) => o.copyWith(status: next));
}
