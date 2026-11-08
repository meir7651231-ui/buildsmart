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
    return '${s.city}\u00A0· ${u.name}\u00A0· ${r.name}\u00A0· ${p.label}';
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

// ── labels (no internal codes in front of users) ─────────────────────────────

/// "WO-1001" → "קריאה 1001".
String mxWoLabel(String id) => 'קריאה ${id.split('-').last}';

/// "PO-1003" → "הזמנה 1003".
String mxPoLabel(String id) => 'הזמנה ${id.split('-').last}';

// ── urgency ──────────────────────────────────────────────────────────────────

/// Fault words that mean a life-safety risk in housing for people with
/// intellectual disabilities: open immediately, top of every list.
const List<String> kMxUrgentWords = [
  'ניצוצות',
  'ריח שרוף',
  'נפתח יותר מדי',
  'מצפצף',
  'נפל / חסר',
  'חשמל',
  'גז',
  'הצפה',
  'עשן',
];

bool mxIsUrgentText(String text) => kMxUrgentWords.any(text.contains);

/// What staff should do right now for an urgent fault (shown on screen).
String mxSafetyInstruction(String type, String desc) {
  if (desc.contains('ניצוצות') || desc.contains('ריח שרוף') || type == 'שקע') {
    return 'לא לגעת בשקע. לנתק את המפסק בלוח החשמל, להרחיק את הדיירים מהאזור ולהתקשר למנהל האחזקה.';
  }
  if (type == 'מעצור חלון' || desc.contains('נפתח יותר מדי')) {
    return 'לסגור את החלון ולנעול אותו, להרחיק את הדיירים מהחלון ולהתקשר למנהל האחזקה.';
  }
  if (type == 'גלאי עשן') {
    return 'להגביר ערנות במטבח, לוודא שהמטף במקומו ולהתקשר למנהל האחזקה.';
  }
  return 'להרחיק את הדיירים מהמקום ולהתקשר למנהל האחזקה.';
}

/// Where a PO is delivered: the site of the job that needs it, else the
/// first site (the maintenance store room).
MxSite mxPoDeliverySite(MxDb db, MxPurchaseOrder o) {
  for (final w in db.workOrders) {
    if (w.poId == o.id) {
      return db.site(
        db.unit(db.room(db.point(w.pointId).roomId).unitId).siteId,
      );
    }
  }
  return db.sites.first;
}

/// Headline of the safety takeover ("עצרו. סכנת חשמל").
String mxSafetyTitle(String type, String desc) {
  if (desc.contains('ניצוצות') || desc.contains('ריח שרוף') || type == 'שקע') {
    return 'עצרו. סכנת חשמל';
  }
  if (type == 'מעצור חלון' || desc.contains('נפתח יותר מדי')) {
    return 'עצרו. סכנת נפילה';
  }
  if (type == 'גלאי עשן') return 'שימו לב: גלאי העשן לא תקין';
  return 'עצרו. סכנת בטיחות';
}

/// The same instruction as three numbered, tickable steps.
List<String> mxSafetySteps(String type, String desc) {
  if (desc.contains('ניצוצות') || desc.contains('ריח שרוף') || type == 'שקע') {
    return const [
      'לנתק את המפסק בלוח החשמל',
      'לא לגעת בשקע ובמכשיר שמחובר אליו',
      'להרחיק את הדיירים מהאזור',
    ];
  }
  if (type == 'מעצור חלון' || desc.contains('נפתח יותר מדי')) {
    return const [
      'לסגור את החלון ולנעול אותו',
      'להרחיק את הדיירים מהחלון',
      'לא להשאיר את החדר בלי השגחה',
    ];
  }
  if (type == 'גלאי עשן') {
    return const [
      'להגביר ערנות במטבח ובחדרים',
      'לוודא שהמטף במקומו',
      'לא להשאיר בישול בלי השגחה',
    ];
  }
  return const [
    'להרחיק את הדיירים מהמקום',
    'לסמן את המקום שלא יתקרבו',
    'לחכות לטכנאי',
  ];
}

/// Open work orders: urgent first, then newest first.
List<MxWorkOrder> mxSortedOpen(Iterable<MxWorkOrder> list) {
  final l =
      list.toList()..sort((a, b) {
        if (a.urgent != b.urgent) return a.urgent ? -1 : 1;
        return b.createdAt.compareTo(a.createdAt);
      });
  return l;
}

// ── work orders ──────────────────────────────────────────────────────────────

MxWorkOrder _logged(MxWorkOrder w, DateTime at, String text, String by) =>
    w.copyWith(log: [MxEvent(at: at, text: text, by: by), ...w.log]);

/// The open work order already on [pointId], if any (duplicate guard).
MxWorkOrder? mxOpenOnPoint(MxDb db, String pointId) {
  for (final w in db.workOrders) {
    if (w.pointId == pointId && w.isOpen) return w;
  }
  return null;
}

/// Open a work order on a point. Returns the new db and the work-order id.
/// Safety words make it urgent automatically. A point that already has an
/// open job is rejected — add a comment to that job instead ([commentOn]).
(MxDb, String) reportFault(
  MxDb db, {
  required String pointId,
  required String desc,
  required String reportedBy,
  required DateTime now,
  bool hasPhoto = false,
  bool? urgent,
  String photo = '',
}) {
  db.point(pointId); // validates
  final text = desc.trim();
  if (text.isEmpty) throw const MxError('צריך לתאר מה קרה');
  final dup = mxOpenOnPoint(db, pointId);
  if (dup != null) {
    throw MxError('כבר דווח – ${mxWoLabel(dup.id)} פתוחה על הנקודה הזו');
  }
  final seq = db.seq + 1;
  final id = 'WO-$seq';
  final wo = MxWorkOrder(
    id: id,
    pointId: pointId,
    desc: text,
    reportedBy: reportedBy,
    createdAt: now,
    hasPhoto: hasPhoto || photo.isNotEmpty,
    photo: photo,
    urgent: urgent ?? mxIsUrgentText(text),
    log: [MxEvent(at: now, text: 'דיווח: $text', by: reportedBy)],
  );
  var next = db.copyWith(workOrders: [wo, ...db.workOrders], seq: seq);
  next = _setPoint(
    next,
    pointId,
    (p) => p.copyWith(status: MxPointStatus.faulty),
  );
  return (next, id);
}

/// Add a comment to an existing job (e.g. "it got worse").
MxDb commentOn(
  MxDb db,
  String woId,
  String text, {
  required String by,
  required DateTime now,
}) {
  final w = db.workOrder(woId);
  final t = text.trim();
  if (t.isEmpty) throw const MxError('צריך לכתוב הערה');
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  return _setWo(db, woId, (w) => _logged(w, now, 'הערה: $t', by));
}

MxDb assignWorkOrder(
  MxDb db,
  String woId,
  String tech, {
  DateTime? now,
  String by = 'מנהל אחזקה',
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  if (tech.trim().isEmpty) throw const MxError('צריך לבחור טכנאי');
  return _setWo(
    db,
    woId,
    (w) => _logged(
      w.copyWith(
        status:
            w.status == MxWoStatus.waitingPart
                ? MxWoStatus.waitingPart
                : MxWoStatus.assigned,
        assignee: tech.trim(),
      ),
      now ?? w.createdAt,
      'שויך ל${tech.trim()}',
      by,
    ),
  );
}

/// Open jobs assigned to [tech] (workload in the picker).
int mxOpenCountFor(MxDb db, String tech) =>
    db.workOrders.where((w) => w.isOpen && w.assignee == tech).length;

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
    (w) => _logged(
      w.copyWith(status: MxWoStatus.done, closedAt: now),
      now,
      'תוקן – הוחלף ${part.name}',
      by,
    ),
  );
  next = _setPoint(
    next,
    p.id,
    (p) => p.copyWith(
      status: MxPointStatus.ok,
      history: [
        MxEvent(
          at: now,
          text: 'תוקן – הוחלף ${part.name} (${mxWoLabel(woId)})',
          by: by,
          costAgorot: part.priceAgorot,
        ),
        ...p.history,
      ],
    ),
  );
  return next;
}

/// Close a job that needed no part (adjustment, cleaning, part found
/// elsewhere…). A pending part request for it is cancelled.
MxDb closeNoPart(
  MxDb db,
  String woId, {
  required String by,
  required DateTime now,
  String note = 'תוקן ללא חלק',
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  var next = db;
  if (w.poId.isNotEmpty && db.po(w.poId).status == MxPoStatus.pendingApproval) {
    next = _setPo(
      next,
      w.poId,
      (o) => o.copyWith(status: MxPoStatus.rejected, note: 'בוטל – $note'),
    );
  }
  next = _setWo(
    next,
    woId,
    (w) => _logged(
      w.copyWith(status: MxWoStatus.done, closedAt: now),
      now,
      note,
      by,
    ),
  );
  return _setPoint(
    next,
    w.pointId,
    (p) => p.copyWith(
      status: MxPointStatus.ok,
      history: [
        MxEvent(at: now, text: '$note (${mxWoLabel(woId)})', by: by),
        ...p.history,
      ],
    ),
  );
}

/// The tech asks for a part (default: the point's own part): opens a PO
/// (pending approval) to the matching store and parks the job.
(MxDb, String) requestPart(
  MxDb db,
  String woId, {
  required int qty,
  required String by,
  required DateTime now,
  String? sku,
}) {
  final w = db.workOrder(woId);
  if (!w.isOpen) throw const MxError('הקריאה כבר סגורה');
  if (qty < 1) throw const MxError('כמות חייבת להיות לפחות 1');
  if (w.status == MxWoStatus.waitingPart) {
    throw const MxError('כבר יש בקשת חלק פתוחה לקריאה הזו');
  }
  final part = sku ?? db.point(w.pointId).sku;
  db.part(part); // validates
  final store = db.storeFor(part);
  if (store == null)
    throw MxError('אין חנות שמוכרת ${db.part(part).storeType}');
  final (next, poId) = _newPo(
    db,
    storeId: store.id,
    lines: [
      MxPoLine(sku: part, qty: qty, unitAgorot: db.priceAt(store.id, part)),
    ],
    by: by,
    now: now,
    note: 'עבור ${mxWoLabel(woId)}',
  );
  return (
    _setWo(
      next,
      woId,
      (w) => _logged(
        w.copyWith(status: MxWoStatus.waitingPart, poId: poId),
        now,
        'ביקש $qty × ${db.part(part).name} (${mxPoLabel(poId)})',
        by,
      ),
    ),
    poId,
  );
}

/// The tech cancels a part request that was not approved yet.
MxDb cancelPartRequest(
  MxDb db,
  String woId, {
  required String by,
  required DateTime now,
}) {
  final w = db.workOrder(woId);
  if (w.status != MxWoStatus.waitingPart || w.poId.isEmpty) {
    throw const MxError('אין בקשת חלק פתוחה');
  }
  final o = db.po(w.poId);
  if (o.status != MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה כבר אושרה – אי אפשר לבטל');
  }
  var next = _setPo(
    db,
    o.id,
    (o) => o.copyWith(status: MxPoStatus.rejected, note: 'בוטל ע״י הטכנאי'),
  );
  next = _setWo(
    next,
    woId,
    (w) => _logged(
      w.copyWith(status: MxWoStatus.assigned, poId: ''),
      now,
      'ביטל את בקשת החלק',
      by,
    ),
  );
  return next;
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

/// Manager approval: the PO gets its store-link token. It is NOT "sent" until
/// it actually leaves ([markSent]) — no false "נשלח לחנות".
MxDb approvePo(MxDb db, String poId, {Random? rng}) {
  final o = db.po(poId);
  if (o.status != MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה לא ממתינה לאישור');
  }
  return _setPo(
    db,
    poId,
    (o) => o.copyWith(status: MxPoStatus.approved, token: mxNewToken(rng)),
  );
}

/// The order really left: WhatsApp was opened / the link was delivered.
MxDb mxMarkSent(MxDb db, String poId) {
  final o = db.po(poId);
  if (o.status == MxPoStatus.pendingApproval)
    throw const MxError('ההזמנה עוד לא אושרה');
  if (o.status != MxPoStatus.approved) return db; // already further along
  return _setPo(db, poId, (o) => o.copyWith(status: MxPoStatus.sent));
}

/// Reject with a reason; jobs that waited on it go back to the tech's queue
/// with the reason in their log (the tech sees why).
MxDb rejectPo(MxDb db, String poId, {String reason = '', DateTime? now}) {
  final o = db.po(poId);
  if (o.status != MxPoStatus.pendingApproval) {
    throw const MxError('ההזמנה לא ממתינה לאישור');
  }
  final why = reason.trim();
  var next = _setPo(
    db,
    poId,
    (o) => o.copyWith(status: MxPoStatus.rejected, note: why),
  );
  for (final w in next.workOrders.where((w) => w.poId == poId && w.isOpen)) {
    next = _setWo(
      next,
      w.id,
      (w) => _logged(
        w.copyWith(status: MxWoStatus.assigned, poId: ''),
        now ?? o.createdAt,
        'בקשת החלק נדחתה${why.isEmpty ? '' : ': $why'}',
        'מנהל אחזקה',
      ),
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
/// Any store action proves the order arrived, so `approved` counts as sent.
MxDb storeAct(
  MxDb db,
  String token,
  MxStoreAction action, {
  String invoiceNo = '',
  String allocationNo = '',
  MxFulfil? fulfil,
}) {
  final o = db.poByToken(token);
  if (o == null) throw const MxError('הקישור לא תקף');
  _assertStoreCanAct(o);
  switch (action) {
    case MxStoreAction.confirm:
      if (o.status != MxPoStatus.sent && o.status != MxPoStatus.approved) {
        throw const MxError('ההזמנה כבר אושרה');
      }
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
          fulfil: fulfil ?? o.fulfil,
          invoiceNo: invoiceNo.trim().isEmpty ? o.invoiceNo : invoiceNo.trim(),
          allocationNo:
              allocationNo.trim().isEmpty
                  ? o.allocationNo
                  : allocationNo.trim(),
        ),
      );
  }
}

/// Store sets how many of a line it can supply (0 = none, qty = all).
MxDb storeSetSupplied(MxDb db, String token, String sku, int supplied) {
  final o = db.poByToken(token);
  if (o == null) throw const MxError('הקישור לא תקף');
  _assertStoreCanAct(o);
  final line = o.lines.where((l) => l.sku == sku).firstOrNull;
  if (line == null) throw MxError('הפריט לא בהזמנה: $sku');
  final n = supplied.clamp(0, line.qty);
  final lines = [
    for (final l in o.lines) l.sku == sku ? l.copyWith(supplied: n) : l,
  ];
  final anyMissing = lines.any((l) => l.missing);
  return _setPo(
    db,
    o.id,
    (o) => o.copyWith(
      lines: lines,
      status: switch (o.status) {
        MxPoStatus.ready => MxPoStatus.ready,
        _ when anyMissing => MxPoStatus.storePartial,
        MxPoStatus.storePartial => MxPoStatus.storeConfirmed,
        final s => s,
      },
    ),
  );
}

/// Store marks a whole line as unavailable.
MxDb storeMarkMissing(MxDb db, String token, String sku) =>
    storeSetSupplied(db, token, sku, 0);

/// Note stamped on a PO created by [rerouteMissing] for [poId].
String mxRerouteNote(String poId) => 'פריטים שחסרו ב${mxPoLabel(poId)}';

/// True once the missing lines of [poId] were already sent to another store.
bool mxRerouted(MxDb db, String poId) => db.purchaseOrders.any(
  (o) => o.note == mxRerouteNote(poId) && o.status != MxPoStatus.rejected,
);

/// Missing lines of an open PO that still need another store — the manager
/// can reroute them whatever the store did next (e.g. marked the rest ready).
bool mxCanReroute(MxDb db, MxPurchaseOrder o) =>
    o.isOpen && o.lines.any((l) => l.missing) && !mxRerouted(db, o.id);

/// Send the shortfall of [poId] to another store (pending approval). Jobs
/// waiting for a rerouted part follow it to the new PO.
(MxDb, String?) rerouteMissing(MxDb db, String poId, {required DateTime now}) {
  final o = db.po(poId);
  final missing = o.lines.where((l) => l.missing).toList();
  if (missing.isEmpty) return (db, null);
  if (mxRerouted(db, poId)) {
    throw const MxError('החוסרים כבר הופנו לחנות אחרת');
  }
  final alt = db.storeFor(missing.first.sku, exclude: {o.storeId});
  if (alt == null) throw const MxError('אין חנות חלופית לפריטים החסרים');
  final (next0, newId) = _newPo(
    db,
    storeId: alt.id,
    lines: [
      for (final l in missing)
        MxPoLine(
          sku: l.sku,
          qty: l.shortfall,
          unitAgorot: db.priceAt(alt.id, l.sku),
        ),
    ],
    by: 'הפניה מ${mxPoLabel(poId)}',
    now: now,
    note: mxRerouteNote(poId),
  );
  var next = next0;
  final reroutedSkus = {for (final l in missing) l.sku};
  for (final w in next.workOrders.where((w) => w.poId == poId && w.isOpen)) {
    if (reroutedSkus.contains(next.point(w.pointId).sku)) {
      next = _setWo(
        next,
        w.id,
        (w) => _logged(
          w.copyWith(poId: newId),
          now,
          'החלק הועבר ל${mxPoLabel(newId)}',
          'מנהל אחזקה',
        ),
      );
    }
  }
  return (next, newId);
}

/// Above this (agorot, before VAT) a supplier tax invoice must carry an
/// Israel-Invoice allocation number (₪5,000 from 1.6.2026 — verify on gov.il).
const int kMxAllocationThresholdAgorot = 500000;

bool mxNeedsAllocation(MxPurchaseOrder o) =>
    o.totalAgorot > kMxAllocationThresholdAgorot;

/// Goods received: stock += supplied quantities; jobs waiting on this PO whose
/// part actually arrived go back to "assigned" so the tech can finish them.
MxDb receivePo(MxDb db, String poId, {DateTime? now}) {
  final o = db.po(poId);
  if (o.status == MxPoStatus.pendingApproval ||
      o.status == MxPoStatus.rejected) {
    throw const MxError('אי אפשר לקבל הזמנה שלא נשלחה');
  }
  if (o.status == MxPoStatus.received) throw const MxError('ההזמנה כבר התקבלה');
  if (mxNeedsAllocation(o) && o.allocationNo.isEmpty) {
    throw const MxError('חשבונית מעל ‎5,000 ₪ – חסר מספר הקצאה מרשות המסים');
  }
  final stock = {...db.stock};
  for (final l in o.lines) {
    if (l.supplied > 0) stock[l.sku] = (stock[l.sku] ?? 0) + l.supplied;
  }
  var next = _setPo(
    db.copyWith(stock: stock),
    poId,
    (o) => o.copyWith(status: MxPoStatus.received),
  );
  final arrived = {
    for (final l in o.lines)
      if (l.supplied > 0) l.sku,
  };
  for (final w in next.workOrders.where(
    (w) => w.poId == poId && w.status == MxWoStatus.waitingPart,
  )) {
    if (!arrived.contains(next.point(w.pointId).sku)) continue;
    next = _setWo(
      next,
      w.id,
      (w) => _logged(
        w.copyWith(status: MxWoStatus.assigned),
        now ?? o.createdAt,
        'החלק הגיע למחסן',
        'מנהל אחזקה',
      ),
    );
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
