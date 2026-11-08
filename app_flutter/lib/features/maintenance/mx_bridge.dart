/// Maintenance module ⇄ BuildSmart core engines.
///
/// The module does NOT run its own approval queue or store-order pipeline.
/// Purchasing rides the engines BuildSmart already ships (Firestore-backed,
/// rules-tested, with push + order e-mail):
///
///   tech asks for a part   → `materialRequestsProvider.submit`
///                            (the existing worker→contractor approval queue)
///   manager approves       → `setStatus(ordered)` + `ordersEngineProvider
///                            .placeOrder` (lands on the existing store
///                            dashboard: new→preparing→ready→pickup→transit→
///                            delivered)
///   manager rejects        → `setStatus(declined)`
///   store answers by link  → `ordersEngine.setStage(preparing | ready)`
///   store advances in-app  → mirrored back into the PO ([syncPoFromStage])
///   manager receives goods → `setStage(delivered)` + `setStatus(supplied)`
///
/// [MxPurchasingPort] is the seam: production binds [MxBuildSmartPort];
/// engine-only tests run with [MxNoPort].
library;

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The org the maintenance module files requests under (the "employer" of the
/// BuildSmart material-request queue).
const String kMxEmployerId = 'mx-org';

/// Display name the store sees on orders.
const String kMxOrderWho = 'מחלקת האחזקה';

abstract class MxPurchasingPort {
  /// File the PO as a material request; returns its id.
  String submitRequest(MxDb db, MxPurchaseOrder po, {required String techName});

  /// Approve: mark the request ordered and place the store order; returns the
  /// BuildSmart order id.
  String approve(MxDb db, MxPurchaseOrder po, {required String site});

  void reject(MxPurchaseOrder po);

  /// Store answered (link page): mirror the stage onto the store order.
  void storeStage(MxPurchaseOrder po, String stage);

  /// Goods received: close both BuildSmart records.
  void received(MxPurchaseOrder po);

  /// Current stage of the BuildSmart order, or null when unknown.
  String? stageOf(String orderId);
}

/// No-op port (engine-only use and tests that do not need the core engines).
class MxNoPort implements MxPurchasingPort {
  const MxNoPort();
  @override
  String submitRequest(
    MxDb db,
    MxPurchaseOrder po, {
    required String techName,
  }) => '';
  @override
  String approve(MxDb db, MxPurchaseOrder po, {required String site}) => '';
  @override
  void reject(MxPurchaseOrder po) {}
  @override
  void storeStage(MxPurchaseOrder po, String stage) {}
  @override
  void received(MxPurchaseOrder po) {}
  @override
  String? stageOf(String orderId) => null;
}

/// One request line as the approval queue shows it: "4 × מנגנון שקע 16A [EL-SK16]".
String mxRequestLine(MxDb db, MxPoLine l) =>
    '${l.qty} × ${db.part(l.sku).name} [${l.sku}]';

/// The production port: writes into BuildSmart's own engines.
class MxBuildSmartPort implements MxPurchasingPort {
  MxBuildSmartPort(this._ref);
  final Ref _ref;

  MaterialRequestsNotifier get _requests =>
      _ref.read(materialRequestsProvider.notifier);
  OrdersEngineNotifier get _orders => _ref.read(ordersEngineProvider.notifier);

  @override
  String submitRequest(
    MxDb db,
    MxPurchaseOrder po, {
    required String techName,
  }) => _requests.submit(
    employerId: kMxEmployerId,
    workerUid: '',
    username: techName,
    workerName: techName,
    items: [for (final l in po.lines) mxRequestLine(db, l)],
    note: [
      po.id,
      if (po.note.isNotEmpty) po.note,
      db.store(po.storeId).name,
    ].join(' · '),
  );

  @override
  String approve(MxDb db, MxPurchaseOrder po, {required String site}) {
    if (po.matReqId.isNotEmpty) {
      _requests.setStatus(po.matReqId, kMatReqOrdered);
    }
    final live = po.lines.where((l) => !l.missing).toList();
    final order = _orders.placeOrder(
      who: kMxOrderWho,
      site: site,
      items: live.fold(0, (a, l) => a + l.qty),
      // The store dashboard works in whole shekels.
      sum: (po.totalAgorot / 100).round(),
      lines: [
        for (final l in live)
          OrderLineItem(
            name: '${db.part(l.sku).name} [${l.sku}]',
            emoji: '🔧',
            qty: l.qty,
            price: (l.totalAgorot / 100).round(),
          ),
      ],
      notes: '${po.id} · ${db.store(po.storeId).name}',
    );
    return order.id;
  }

  @override
  void reject(MxPurchaseOrder po) {
    if (po.matReqId.isNotEmpty) {
      _requests.setStatus(po.matReqId, kMatReqDeclined);
    }
  }

  @override
  void storeStage(MxPurchaseOrder po, String stage) {
    if (po.orderId.isNotEmpty) _orders.setStage(po.orderId, stage);
  }

  @override
  void received(MxPurchaseOrder po) {
    if (po.orderId.isNotEmpty) _orders.setStage(po.orderId, 'delivered');
    if (po.matReqId.isNotEmpty) {
      _requests.setStatus(po.matReqId, kMatReqSupplied);
    }
  }

  @override
  String? stageOf(String orderId) {
    for (final o in _ref.read(ordersEngineProvider)) {
      if (o.id == orderId) return o.stage;
    }
    return null;
  }
}

/// Human label for a BuildSmart order stage.
String mxStageLabel(String stage) => switch (stage) {
  'new' => 'חדשה',
  'preparing' => 'בהכנה',
  'ready' => 'מוכנה',
  'pickup' => 'באיסוף',
  'transit' => 'בדרך',
  'delivered' => 'נמסרה',
  _ => stage,
};

/// "ירושלים · דירה 3" for a PO opened from a work order, else the org name.
String mxPoSite(MxDb db, MxPurchaseOrder po) {
  for (final w in db.workOrders) {
    if (w.poId == po.id) {
      final r = db.room(db.point(w.pointId).roomId);
      final u = db.unit(r.unitId);
      return '${db.site(u.siteId).city} · ${u.name}';
    }
  }
  return 'מחסן האחזקה';
}
