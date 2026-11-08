/// Maintenance module (אחזקה ורכש) — the data model.
///
/// Point-level asset register: org → site → unit (apartment) → room → point
/// (every outlet, faucet, window stop is its own [MxPoint]). Work orders,
/// preventive-maintenance rules, spare-part stock and purchase orders to
/// independent stores hang off it.
///
/// Pure Dart, immutable, JSON round-trippable. No Flutter import — the engine
/// (`mx_engine.dart`) and the tests run without a widget binding.
/// Money is integer agorot (1 ₪ = 100) — never doubles.
library;

/// Who is acting. `store` = the independent hardware-store owner (טמבור).
enum MxRole { manager, tech, staff, store }

/// A point's physical state.
enum MxPointStatus { ok, faulty }

/// Work order (קריאת שירות) lifecycle.
enum MxWoStatus { open, assigned, waitingPart, done, cancelled }

/// Purchase order lifecycle. A store answers through its link (WhatsApp) or
/// its dashboard; the manager approves and receives.
enum MxPoStatus {
  pendingApproval, // requested by a tech / by the low-stock rule
  sent, // approved by the manager and sent to the store
  storeConfirmed, // the store confirmed it can supply everything
  storePartial, // the store marked one or more lines missing
  ready, // ready for pickup / out for delivery
  received, // goods received → stock updated
  rejected, // manager rejected
}

/// How a store receives orders.
enum MxStoreChannel { whatsapp, app, both }

T _enumByName<T extends Enum>(List<T> values, Object? raw, T fallback) {
  if (raw is! String) return fallback;
  for (final v in values) {
    if (v.name == raw) return v;
  }
  return fallback;
}

DateTime? _date(Object? raw) => raw is String ? DateTime.tryParse(raw) : null;

class MxSite {
  const MxSite({required this.id, required this.name, required this.city});

  factory MxSite.fromJson(Map<String, Object?> j) => MxSite(
    id: j['id']! as String,
    name: j['name']! as String,
    city: (j['city'] ?? '') as String,
  );
  final String id;
  final String name;
  final String city;

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'city': city};
}

/// An apartment / unit inside a site.
class MxUnit {
  const MxUnit({required this.id, required this.siteId, required this.name});

  factory MxUnit.fromJson(Map<String, Object?> j) => MxUnit(
    id: j['id']! as String,
    siteId: j['siteId']! as String,
    name: j['name']! as String,
  );
  final String id;
  final String siteId;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'siteId': siteId, 'name': name};
}

class MxRoom {
  const MxRoom({required this.id, required this.unitId, required this.name});

  factory MxRoom.fromJson(Map<String, Object?> j) => MxRoom(
    id: j['id']! as String,
    unitId: j['unitId']! as String,
    name: j['name']! as String,
  );
  final String id;
  final String unitId;
  final String name;

  Map<String, Object?> toJson() => {'id': id, 'unitId': unitId, 'name': name};
}

/// One event in a point's history (repair, replacement, inspection).
class MxEvent {
  const MxEvent({
    required this.at,
    required this.text,
    required this.by,
    this.costAgorot = 0,
  });

  factory MxEvent.fromJson(Map<String, Object?> j) => MxEvent(
    at: _date(j['at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    text: (j['text'] ?? '') as String,
    by: (j['by'] ?? '') as String,
    costAgorot: (j['cost'] ?? 0) as int,
  );
  final DateTime at;
  final String text;
  final String by;
  final int costAgorot;

  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'text': text,
    'by': by,
    'cost': costAgorot,
  };
}

/// A single physical point: "שקע 3 – מעל משטח" in the kitchen of apartment 3.
class MxPoint {
  const MxPoint({
    required this.id,
    required this.roomId,
    required this.type,
    required this.num,
    required this.loc,
    required this.spec,
    required this.sku,
    this.pm = '',
    this.status = MxPointStatus.ok,
    this.history = const [],
  });

  factory MxPoint.fromJson(Map<String, Object?> j) => MxPoint(
    id: j['id']! as String,
    roomId: j['roomId']! as String,
    type: j['type']! as String,
    num: (j['num'] ?? 1) as int,
    loc: (j['loc'] ?? '') as String,
    spec: (j['spec'] ?? '') as String,
    sku: j['sku']! as String,
    pm: (j['pm'] ?? '') as String,
    status: _enumByName(MxPointStatus.values, j['status'], MxPointStatus.ok),
    history: [
      for (final e in (j['history'] as List? ?? const []))
        MxEvent.fromJson((e as Map).cast<String, Object?>()),
    ],
  );

  final String id;
  final String roomId;

  /// Kind of point, e.g. 'שקע', 'ברז', 'מעצור חלון'.
  final String type;

  /// Running number of this type inside its room (שקע 1, שקע 2…).
  final int num;

  /// Free-text location inside the room ('מעל משטח').
  final String loc;
  final String spec;

  /// The replacement part ([MxPart.sku]) this point consumes when repaired.
  final String sku;

  /// Human-readable PM note ('בדיקה חודשית').
  final String pm;
  final MxPointStatus status;
  final List<MxEvent> history;

  String get label => loc.isEmpty ? '$type $num' : '$type $num – $loc';

  MxPoint copyWith({MxPointStatus? status, List<MxEvent>? history}) => MxPoint(
    id: id,
    roomId: roomId,
    type: type,
    num: num,
    loc: loc,
    spec: spec,
    sku: sku,
    pm: pm,
    status: status ?? this.status,
    history: history ?? this.history,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'roomId': roomId,
    'type': type,
    'num': num,
    'loc': loc,
    'spec': spec,
    'sku': sku,
    'pm': pm,
    'status': status.name,
    'history': [for (final e in history) e.toJson()],
  };
}

/// A spare part / consumable kept in stock.
class MxPart {
  const MxPart({
    required this.sku,
    required this.name,
    required this.storeType,
    required this.min,
    required this.priceAgorot,
  });

  factory MxPart.fromJson(Map<String, Object?> j) => MxPart(
    sku: j['sku']! as String,
    name: j['name']! as String,
    storeType: j['storeType']! as String,
    min: (j['min'] ?? 0) as int,
    priceAgorot: (j['price'] ?? 0) as int,
  );
  final String sku;
  final String name;

  /// Which kind of store sells it: 'חשמל', 'אינסטלציה', 'פרזול'…
  final String storeType;

  /// Reorder point: stock below this triggers a purchase request.
  final int min;

  /// Reference price (agorot) until a store price list overrides it.
  final int priceAgorot;

  Map<String, Object?> toJson() => {
    'sku': sku,
    'name': name,
    'storeType': storeType,
    'min': min,
    'price': priceAgorot,
  };
}

/// An independent store (טמבור / חנות חשמל / אינסטלציה).
class MxStore {
  const MxStore({
    required this.id,
    required this.name,
    required this.types,
    required this.phone,
    this.channel = MxStoreChannel.both,
  });

  factory MxStore.fromJson(Map<String, Object?> j) => MxStore(
    id: j['id']! as String,
    name: j['name']! as String,
    types: {for (final t in (j['types'] as List? ?? const [])) t as String},
    phone: (j['phone'] ?? '') as String,
    channel: _enumByName(
      MxStoreChannel.values,
      j['channel'],
      MxStoreChannel.both,
    ),
  );
  final String id;
  final String name;

  /// Store types it supplies — matched against [MxPart.storeType].
  final Set<String> types;

  /// Israeli mobile, any common format ('050-1234567').
  final String phone;
  final MxStoreChannel channel;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'types': types.toList(),
    'phone': phone,
    'channel': channel.name,
  };
}

class MxWorkOrder {
  const MxWorkOrder({
    required this.id,
    required this.pointId,
    required this.desc,
    required this.reportedBy,
    required this.createdAt,
    this.status = MxWoStatus.open,
    this.assignee = '',
    this.hasPhoto = false,
    this.poId = '',
    this.closedAt,
  });

  factory MxWorkOrder.fromJson(Map<String, Object?> j) => MxWorkOrder(
    id: j['id']! as String,
    pointId: j['pointId']! as String,
    desc: (j['desc'] ?? '') as String,
    reportedBy: (j['reportedBy'] ?? '') as String,
    createdAt: _date(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    status: _enumByName(MxWoStatus.values, j['status'], MxWoStatus.open),
    assignee: (j['assignee'] ?? '') as String,
    hasPhoto: (j['photo'] ?? false) as bool,
    poId: (j['poId'] ?? '') as String,
    closedAt: _date(j['closedAt']),
  );
  final String id;
  final String pointId;
  final String desc;

  /// Role label only (e.g. 'מדריך – דירה 3') — never a resident's name.
  final String reportedBy;
  final DateTime createdAt;
  final MxWoStatus status;
  final String assignee;
  final bool hasPhoto;

  /// The purchase order waiting for this job's part, if any.
  final String poId;
  final DateTime? closedAt;

  bool get isOpen =>
      status != MxWoStatus.done && status != MxWoStatus.cancelled;

  MxWorkOrder copyWith({
    MxWoStatus? status,
    String? assignee,
    String? poId,
    DateTime? closedAt,
  }) => MxWorkOrder(
    id: id,
    pointId: pointId,
    desc: desc,
    reportedBy: reportedBy,
    createdAt: createdAt,
    status: status ?? this.status,
    assignee: assignee ?? this.assignee,
    hasPhoto: hasPhoto,
    poId: poId ?? this.poId,
    closedAt: closedAt ?? this.closedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'pointId': pointId,
    'desc': desc,
    'reportedBy': reportedBy,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'assignee': assignee,
    'photo': hasPhoto,
    'poId': poId,
    'closedAt': closedAt?.toIso8601String(),
  };
}

/// A preventive-maintenance / mandatory-inspection rule.
class MxPmRule {
  const MxPmRule({
    required this.id,
    required this.title,
    required this.scope,
    required this.intervalDays,
    required this.lastDone,
    this.legalBasis = '',
  });

  factory MxPmRule.fromJson(Map<String, Object?> j) => MxPmRule(
    id: j['id']! as String,
    title: j['title']! as String,
    scope: (j['scope'] ?? '') as String,
    intervalDays: (j['intervalDays'] ?? 30) as int,
    lastDone: _date(j['lastDone']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    legalBasis: (j['legal'] ?? '') as String,
  );
  final String id;
  final String title;

  /// Where it applies, human readable ('ירושלים · כל הבניין').
  final String scope;
  final int intervalDays;
  final DateTime lastDone;

  /// Non-empty ⇒ required by law/standard (shown with ⚖ and never skippable).
  final String legalBasis;

  bool get isLegal => legalBasis.isNotEmpty;
  DateTime get nextDue => lastDone.add(Duration(days: intervalDays));

  MxPmRule copyWith({DateTime? lastDone}) => MxPmRule(
    id: id,
    title: title,
    scope: scope,
    intervalDays: intervalDays,
    lastDone: lastDone ?? this.lastDone,
    legalBasis: legalBasis,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'scope': scope,
    'intervalDays': intervalDays,
    'lastDone': lastDone.toIso8601String(),
    'legal': legalBasis,
  };
}

class MxPoLine {
  const MxPoLine({
    required this.sku,
    required this.qty,
    required this.unitAgorot,
    this.missing = false,
  });

  factory MxPoLine.fromJson(Map<String, Object?> j) => MxPoLine(
    sku: j['sku']! as String,
    qty: (j['qty'] ?? 0) as int,
    unitAgorot: (j['unit'] ?? 0) as int,
    missing: (j['missing'] ?? false) as bool,
  );
  final String sku;
  final int qty;
  final int unitAgorot;

  /// Marked by the store: cannot supply this line.
  final bool missing;

  int get totalAgorot => missing ? 0 : qty * unitAgorot;

  MxPoLine copyWith({bool? missing}) => MxPoLine(
    sku: sku,
    qty: qty,
    unitAgorot: unitAgorot,
    missing: missing ?? this.missing,
  );

  Map<String, Object?> toJson() => {
    'sku': sku,
    'qty': qty,
    'unit': unitAgorot,
    'missing': missing,
  };
}

class MxPurchaseOrder {
  const MxPurchaseOrder({
    required this.id,
    required this.storeId,
    required this.lines,
    required this.requestedBy,
    required this.createdAt,
    this.status = MxPoStatus.pendingApproval,
    this.token = '',
    this.invoiceNo = '',
    this.allocationNo = '',
    this.note = '',
    this.matReqId = '',
    this.orderId = '',
  });

  factory MxPurchaseOrder.fromJson(Map<String, Object?> j) => MxPurchaseOrder(
    id: j['id']! as String,
    storeId: j['storeId']! as String,
    lines: [
      for (final l in (j['lines'] as List? ?? const []))
        MxPoLine.fromJson((l as Map).cast<String, Object?>()),
    ],
    requestedBy: (j['requestedBy'] ?? '') as String,
    createdAt: _date(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    status: _enumByName(
      MxPoStatus.values,
      j['status'],
      MxPoStatus.pendingApproval,
    ),
    token: (j['token'] ?? '') as String,
    invoiceNo: (j['invoiceNo'] ?? '') as String,
    allocationNo: (j['allocationNo'] ?? '') as String,
    note: (j['note'] ?? '') as String,
    matReqId: (j['matReqId'] ?? '') as String,
    orderId: (j['orderId'] ?? '') as String,
  );
  final String id;
  final String storeId;
  final List<MxPoLine> lines;
  final String requestedBy;
  final DateTime createdAt;
  final MxPoStatus status;

  /// Unguessable token for the store's no-login link. Empty until approved.
  final String token;

  /// Store's tax-invoice number and Israel-Invoice allocation number (מספר הקצאה).
  final String invoiceNo;
  final String allocationNo;
  final String note;

  /// BuildSmart material-request id (the approval queue) — '' until submitted.
  final String matReqId;

  /// BuildSmart order id (`BS-####`, the store dashboard) — '' until approved.
  final String orderId;

  int get totalAgorot => lines.fold(0, (a, l) => a + l.totalAgorot);
  bool get isOpen =>
      status != MxPoStatus.received && status != MxPoStatus.rejected;

  MxPurchaseOrder copyWith({
    MxPoStatus? status,
    List<MxPoLine>? lines,
    String? token,
    String? invoiceNo,
    String? allocationNo,
    String? note,
    String? matReqId,
    String? orderId,
  }) => MxPurchaseOrder(
    id: id,
    storeId: storeId,
    lines: lines ?? this.lines,
    requestedBy: requestedBy,
    createdAt: createdAt,
    status: status ?? this.status,
    token: token ?? this.token,
    invoiceNo: invoiceNo ?? this.invoiceNo,
    allocationNo: allocationNo ?? this.allocationNo,
    note: note ?? this.note,
    matReqId: matReqId ?? this.matReqId,
    orderId: orderId ?? this.orderId,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'storeId': storeId,
    'lines': [for (final l in lines) l.toJson()],
    'requestedBy': requestedBy,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'token': token,
    'invoiceNo': invoiceNo,
    'allocationNo': allocationNo,
    'note': note,
    'matReqId': matReqId,
    'orderId': orderId,
  };
}

/// The whole maintenance database for one organization.
class MxDb {
  const MxDb({
    this.sites = const [],
    this.units = const [],
    this.rooms = const [],
    this.points = const [],
    this.parts = const [],
    this.stock = const {},
    this.stores = const [],
    this.storePrices = const {},
    this.workOrders = const [],
    this.pmRules = const [],
    this.purchaseOrders = const [],
    this.seq = 0,
  });

  factory MxDb.fromJson(Map<String, Object?> j) {
    List<T> list<T>(String k, T Function(Map<String, Object?>) f) => [
      for (final x in (j[k] as List? ?? const []))
        f((x as Map).cast<String, Object?>()),
    ];
    return MxDb(
      sites: list('sites', MxSite.fromJson),
      units: list('units', MxUnit.fromJson),
      rooms: list('rooms', MxRoom.fromJson),
      points: list('points', MxPoint.fromJson),
      parts: list('parts', MxPart.fromJson),
      stock: {
        for (final e in ((j['stock'] as Map?) ?? const {}).entries)
          e.key as String: e.value as int,
      },
      stores: list('stores', MxStore.fromJson),
      storePrices: {
        for (final e in ((j['storePrices'] as Map?) ?? const {}).entries)
          e.key as String: {
            for (final p in (e.value as Map).entries)
              p.key as String: p.value as int,
          },
      },
      workOrders: list('workOrders', MxWorkOrder.fromJson),
      pmRules: list('pmRules', MxPmRule.fromJson),
      purchaseOrders: list('purchaseOrders', MxPurchaseOrder.fromJson),
      seq: (j['seq'] ?? 0) as int,
    );
  }

  final List<MxSite> sites;
  final List<MxUnit> units;
  final List<MxRoom> rooms;
  final List<MxPoint> points;
  final List<MxPart> parts;

  /// sku → quantity on hand.
  final Map<String, int> stock;
  final List<MxStore> stores;

  /// storeId → (our sku → agorot) from an imported price list.
  final Map<String, Map<String, int>> storePrices;
  final List<MxWorkOrder> workOrders;
  final List<MxPmRule> pmRules;
  final List<MxPurchaseOrder> purchaseOrders;

  /// Monotonic counter for human ids (WO-1001, PO-1001).
  final int seq;

  MxDb copyWith({
    List<MxSite>? sites,
    List<MxUnit>? units,
    List<MxRoom>? rooms,
    List<MxPoint>? points,
    List<MxPart>? parts,
    Map<String, int>? stock,
    List<MxStore>? stores,
    Map<String, Map<String, int>>? storePrices,
    List<MxWorkOrder>? workOrders,
    List<MxPmRule>? pmRules,
    List<MxPurchaseOrder>? purchaseOrders,
    int? seq,
  }) => MxDb(
    sites: sites ?? this.sites,
    units: units ?? this.units,
    rooms: rooms ?? this.rooms,
    points: points ?? this.points,
    parts: parts ?? this.parts,
    stock: stock ?? this.stock,
    stores: stores ?? this.stores,
    storePrices: storePrices ?? this.storePrices,
    workOrders: workOrders ?? this.workOrders,
    pmRules: pmRules ?? this.pmRules,
    purchaseOrders: purchaseOrders ?? this.purchaseOrders,
    seq: seq ?? this.seq,
  );

  Map<String, Object?> toJson() => {
    'v': 1,
    'sites': [for (final x in sites) x.toJson()],
    'units': [for (final x in units) x.toJson()],
    'rooms': [for (final x in rooms) x.toJson()],
    'points': [for (final x in points) x.toJson()],
    'parts': [for (final x in parts) x.toJson()],
    'stock': stock,
    'stores': [for (final x in stores) x.toJson()],
    'storePrices': storePrices,
    'workOrders': [for (final x in workOrders) x.toJson()],
    'pmRules': [for (final x in pmRules) x.toJson()],
    'purchaseOrders': [for (final x in purchaseOrders) x.toJson()],
    'seq': seq,
  };
}
