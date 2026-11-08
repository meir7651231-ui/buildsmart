// Maintenance module ⇄ BuildSmart core engines — integration through the REAL
// providers (no port fake): a part request lands in the existing approval
// queue (materialRequestsProvider), approval places a real order on the store
// pipeline (ordersEngineProvider), a store advancing that order on its own
// dashboard moves the PO, and receipt closes both BuildSmart records.

import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 8, 10);

  late ProviderContainer c;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Build the module (starts listening to the orders engine).
    c = ProviderContainer(
      overrides: [mxClockProvider.overrideWithValue(() => now)],
    )..read(mxDbProvider);
  });
  tearDown(() => c.dispose());

  MxNotifier mx() => c.read(mxDbProvider.notifier);
  MxDb db() => c.read(mxDbProvider);
  List<MaterialRequest> requests() => c.read(materialRequestsProvider);
  List<Order> orders() => c.read(ordersEngineProvider);

  /// A WO on the jrs-3 kitchen outlet, assigned, part requested → PO id.
  String requestPartFlow() {
    final kitchen = db().roomsOf('jrs-3').firstWhere((r) => r.name == 'מטבח');
    final pid = db().pointsOf(kitchen.id).first.id;
    expect(mx().report(pid, 'ניצוצות', 'מדריך'), isNull);
    final wo = mx().lastCreatedId!;
    expect(mx().assign(wo, 'יוסי'), isNull);
    expect(mx().requestPart(wo, 4, 'יוסי'), isNull);
    return mx().lastCreatedId!;
  }

  test('part request → lands in BuildSmart material-request queue', () {
    final before = requests().length;
    final po = requestPartFlow();
    expect(requests().length, before + 1);
    final r = requests().last;
    expect(db().po(po).matReqId, r.id);
    expect(r.employerId, kMxEmployerId);
    expect(r.status, kMatReqRequested);
    expect(r.items.single, '4 × מנגנון שקע 16A [EL-SK16]');
    expect(r.note, contains(po));
  });

  test(
    'approve → request ordered + a real store order on the BuildSmart pipeline',
    () {
      final po = requestPartFlow();
      final before = orders().length;
      expect(mx().approve(po), isNull);
      expect(orders().length, before + 1);
      final o = db().po(po);
      final order = orders().firstWhere((x) => x.id == o.orderId);
      expect(order.who, kMxOrderWho);
      expect(order.site, 'ירושלים · דירה 3');
      expect(order.stage, 'new');
      expect(order.items, 4);
      expect(order.sum, 72); // 4 × ₪18
      expect(order.lines.single.name, 'מנגנון שקע 16A [EL-SK16]');
      expect(order.notes, contains(po));
      expect(
        requests().firstWhere((r) => r.id == o.matReqId).status,
        kMatReqOrdered,
      );
    },
  );

  test('store link actions move the BuildSmart order stage', () {
    final po = requestPartFlow();
    mx().approve(po);
    final token = db().po(po).token;
    expect(mx().storeConfirm(token), isNull);
    expect(
      orders().firstWhere((x) => x.id == db().po(po).orderId).stage,
      'preparing',
    );
    expect(mx().storeReady(token, invoiceNo: '77'), isNull);
    expect(
      orders().firstWhere((x) => x.id == db().po(po).orderId).stage,
      'ready',
    );
    expect(mx().storeStageOf(db().po(po)), 'ready');
  });

  test(
    'store advancing on its own BuildSmart dashboard moves the PO forward',
    () {
      final po = requestPartFlow();
      mx().approve(po);
      final orderId = db().po(po).orderId;
      c.read(ordersEngineProvider.notifier).setStage(orderId, 'preparing');
      expect(db().po(po).status, MxPoStatus.storeConfirmed);
      c.read(ordersEngineProvider.notifier).setStage(orderId, 'transit');
      expect(db().po(po).status, MxPoStatus.ready);
      // A store tap never moves stock — only the manager's receipt does.
      final had = db().qty('EL-SK16');
      c.read(ordersEngineProvider.notifier).setStage(orderId, 'delivered');
      expect(db().qty('EL-SK16'), had);
      expect(db().po(po).status, MxPoStatus.ready);
    },
  );

  test(
    'receive → stock up, order delivered, request supplied, job back to tech',
    () {
      final po = requestPartFlow();
      mx().approve(po);
      final had = db().qty('EL-SK16');
      expect(mx().receive(po), isNull);
      final o = db().po(po);
      expect(db().qty('EL-SK16'), had + 4);
      expect(orders().firstWhere((x) => x.id == o.orderId).stage, 'delivered');
      expect(
        requests().firstWhere((r) => r.id == o.matReqId).status,
        kMatReqSupplied,
      );
      expect(
        db().workOrders.firstWhere((w) => w.poId == po).status,
        MxWoStatus.assigned,
      );
    },
  );

  test('reject → request declined, no store order placed', () {
    final po = requestPartFlow();
    final before = orders().length;
    expect(mx().reject(po), isNull);
    expect(orders().length, before);
    expect(
      requests().firstWhere((r) => r.id == db().po(po).matReqId).status,
      kMatReqDeclined,
    );
  });

  test('auto reorder → one queued request per store', () {
    final before = requests().length;
    expect(mx().autoReorder(), isNull);
    final pos = db().pendingApproval;
    expect(requests().length, before + pos.length);
    expect(pos.every((p) => p.matReqId.isNotEmpty), isTrue);
  });

  test('stage mapping is forward-only', () {
    expect(mxStatusForStage('new'), isNull);
    expect(mxStatusForStage('preparing'), MxPoStatus.storeConfirmed);
    expect(mxStatusForStage('delivered'), MxPoStatus.ready);
    expect(mxStageLabel('transit'), 'בדרך');
  });
}
