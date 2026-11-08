// Maintenance module — end-to-end widget flows through the real screens, all
// four roles: home staff reports a point (urgent → safety sheet) → manager
// assigns from the tech picker → tech fixes with a part (stock −1) → manager
// auto-reorders + approves-and-sends in one tap (fake WhatsApp launcher) →
// store confirms + marks ready from its link page → manager confirms receipt
// (stock +). Plus one test per critique fix (undo, reject reason, partial
// supply, duplicate report, search, filters, small phone, a11y).

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_screens.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime(2026, 11, 8, 10);

/// A test harness: the real app on a phone-sized view with fake seams.
class _H {
  _H(this.tester, this.container);
  final WidgetTester tester;
  final ProviderContainer container;
  final launched = <Uri>[];
  bool launchOk = true;

  MxDb get db => container.read(mxDbProvider);
  MxNotifier get n => container.read(mxDbProvider.notifier);

  static Future<_H> start(
    WidgetTester tester, {
    MxRole role = MxRole.manager,
    void Function(MxNotifier n, MxDb Function() db)? seed,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    late final _H h;
    final container = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => _now),
        urlLauncherProvider.overrideWithValue((uri) async {
          h.launched.add(uri);
          return h.launchOk;
        }),
        taskPhotoPickerProvider.overrideWithValue(
          (_) async => 'data:image/png;base64,iVBORw0KGgo=',
        ),
      ],
    );
    addTearDown(container.dispose);
    h = _H(tester, container);
    seed?.call(h.n, () => h.db);
    container.read(mxRoleProvider.notifier).state = role;
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MxApp()),
    );
    await tester.pumpAndSettle();
    return h;
  }

  /// Let toasts (6 s) clear, as a real user would.
  Future<void> settle() async {
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();
  }

  Future<void> role(String label) async {
    await settle();
    while (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('mx-roles')),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tab(String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(String key, {bool wait = true}) async {
    if (wait) await settle();
    final f = find.byKey(Key(key));
    if (f.evaluate().isEmpty) {
      // Long pages build lazily: scroll the page (vertical) like a user.
      await tester.scrollUntilVisible(
        f,
        300,
        scrollable:
            find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                )
                .last,
      );
    }
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  /// The button under [key] is enabled.
  bool enabled(String key) {
    final b = tester.widget<ButtonStyleButton>(
      find.descendant(
        of: find.byKey(Key(key)),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    return b.onPressed != null;
  }
}

void main() {
  testWidgets('full maintenance loop across roles', (tester) async {
    final h = await _H.start(tester);

    // Dashboard: urgent KPI first, no internal codes anywhere.
    expect(find.byKey(const Key('kpi-urgent')), findsOneWidget);
    expect(find.textContaining('WO-'), findsNothing);

    // ── home staff reports a kitchen outlet (urgent) ──
    await h.role('צוות בית');
    final kitchen = h.db
        .roomsOf(kMxStaffUnit)
        .firstWhere((r) => r.name == 'מטבח');
    final outlet = h.db.pointsOf(kitchen.id).first;
    await h.tap('rep-room-${kitchen.id}');
    await h.tap('rep-point-${outlet.id}');
    expect(h.enabled('rep-send'), isFalse, reason: 'nothing said yet');
    await h.tap('rep-reason-1'); // 'ניצוצות / ריח שרוף'
    expect(
      find.text('זו תקלה דחופה'),
      findsOneWidget,
      reason: 'safety banner as soon as an urgent reason is picked',
    );
    await tester.enterText(
      find.byKey(const Key('rep-text')),
      'מהשקע ליד הכיור',
    );
    await h.tap('rep-photo');
    await h.tap('rep-send');
    expect(find.text('הדיווח נשלח כדחוף'), findsOneWidget);
    expect(find.textContaining('לנתק את המפסק'), findsOneWidget);
    // The call button dials the manager.
    await h.tap('urgent-call', wait: false);
    expect(h.launched.last.scheme, 'tel');
    final wo = h.db.openWorkOrders.single;
    expect(wo.desc, 'ניצוצות / ריח שרוף – מהשקע ליד הכיור');
    expect(wo.urgent, isTrue);
    expect(wo.photo, startsWith('data:image/'));
    expect(wo.reportedBy, kMxStaffLabel);

    // ── manager: urgent on top, assigns via the tech picker ──
    await h.role('מנהל');
    expect(find.byKey(Key('urgent-${wo.id}')), findsOneWidget);
    await h.tab('קריאות');
    await h.tap('wo-${wo.id}');
    await h.tap('wo-assign');
    expect(find.text('פנוי, אין קריאות פתוחות'), findsWidgets);
    await h.tap('tech-0', wait: false);
    expect(h.db.workOrder(wo.id).assignee, kMxTechs.first);

    // ── tech fixes with a part ──
    await h.role('טכנאי');
    final before = h.db.qty('EL-SK16');
    await h.tap('wo-${wo.id}');
    await h.tap('wo-fix');
    expect(h.db.workOrder(wo.id).status, MxWoStatus.done);
    expect(h.db.qty('EL-SK16'), before - 1);

    // ── manager: auto reorder → approve & send in one tap ──
    await h.role('מנהל');
    await h.tab('רכש');
    await h.tap('buy-stock');
    await h.tap('auto-reorder');
    final po = h.db.pendingApproval.firstWhere((o) => o.storeId == kMxStoreId);
    await h.tap('po-filter-pending');
    await h.tap('po-approve-${po.id}');
    expect(h.db.po(po.id).status, MxPoStatus.sent, reason: 'sent only now');
    final text = h.launched.last.queryParameters['text']!;
    expect(h.launched.last.host, 'wa.me');
    expect(text, contains(mxPoLabel(po.id)));
    expect(text, contains(h.db.po(po.id).token));
    expect(text, contains('כתובת: '));
    // The approval rode BuildSmart: request ordered + a real store order.
    final orderId = h.db.po(po.id).orderId;
    expect(
      h.container.read(ordersEngineProvider).any((o) => o.id == orderId),
      isTrue,
    );
    expect(
      h.container
          .read(materialRequestsProvider)
          .firstWhere((r) => r.id == h.db.po(po.id).matReqId)
          .status,
      kMatReqOrdered,
    );

    // ── store answers from its link page (partial + ready for pickup) ──
    await h.role('חנות');
    await h.tap('inbox-${po.id}');
    final l0 = h.db.po(po.id).lines.first;
    await h.tap('store-confirm');
    expect(h.db.po(po.id).status, MxPoStatus.storeConfirmed);
    await h.tap('store-sup-${l0.sku}-minus');
    expect(h.db.po(po.id).lines.first.supplied, l0.qty - 1);
    expect(h.db.po(po.id).status, MxPoStatus.storePartial);
    await tester.enterText(find.byKey(const Key('store-invoice')), '5531');
    await h.tap('store-ready');
    expect(h.db.po(po.id).status, MxPoStatus.ready);
    expect(h.db.po(po.id).fulfil, MxFulfil.pickup);
    expect(h.db.po(po.id).invoiceNo, '5531');

    // ── manager receives (with a confirm) → stock up by what was supplied ──
    await h.role('מנהל');
    await h.tab('רכש');
    await h.tap('buy-orders');
    final had = h.db.qty(l0.sku);
    await h.tap('po-receive-${po.id}');
    expect(find.text('לקלוט את הסחורה למלאי?'), findsOneWidget);
    await h.tap('confirm-yes', wait: false);
    expect(h.db.po(po.id).status, MxPoStatus.received);
    expect(h.db.qty(l0.sku), had + l0.qty - 1);
    expect(
      h.container
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == orderId)
          .stage,
      'delivered',
    );

    // ── PM: done, then undo from the toast ──
    await h.tab('תחזוקה');
    expect(find.textContaining('חובה:'), findsWidgets);
    MxDue hot() =>
        h.db.dueOf(h.db.pmRules.firstWhere((r) => r.id == 'hotwater'), _now);
    final was = hot();
    await h.tap('pm-done-hotwater');
    expect(hot(), MxDue.ok);
    await tester.tap(find.byKey(const Key('toast-undo')));
    await tester.pumpAndSettle();
    expect(hot(), was, reason: 'undo restores the inspection');
  });

  testWidgets('approve without WhatsApp stays honest: approved, not sent', (
    tester,
  ) async {
    final h = await _H.start(tester, seed: (n, db) => n.autoReorder());
    h.launchOk = false;
    final po = h.db.pendingApproval.first;
    await h.tab('רכש');
    await h.tap('po-approve-${po.id}');
    expect(h.db.po(po.id).status, MxPoStatus.approved);
    expect(find.text('אושר – טרם נשלח'), findsWidgets);
    h.launchOk = true;
    await h.tap('po-wa-${po.id}');
    expect(h.db.po(po.id).status, MxPoStatus.sent);
  });

  testWidgets('reject needs a reason, and the tech sees it', (tester) async {
    late String woId;
    final h = await _H.start(
      tester,
      seed: (n, db) {
        final kitchen = db()
            .roomsOf('jrs-3')
            .firstWhere((r) => r.name == 'מטבח');
        final faucet = db()
            .pointsOf(kitchen.id)
            .firstWhere((p) => p.type == 'ברז');
        n.report(faucet.id, 'מטפטף', kMxStaffLabel);
        woId = n.lastCreatedId!;
        n
          ..assign(woId, kMxTechName)
          ..requestPart(woId, 2, kMxTechName);
      },
    );
    final poId = h.db.workOrder(woId).poId;
    await h.tab('רכש');
    await h.tap('po-reject-$poId');
    await h.tap('ask-quick-0', wait: false); // 'יש במחסן'
    await h.tap('ask-ok', wait: false);
    expect(h.db.po(poId).status, MxPoStatus.rejected);
    await h.role('טכנאי');
    await h.tap('wo-$woId');
    expect(find.text('בקשת החלק נדחתה: יש במחסן'), findsWidgets);
  });

  testWidgets('tech waiting for a part can cancel the request', (tester) async {
    late String woId;
    final h = await _H.start(
      tester,
      role: MxRole.tech,
      seed: (n, db) {
        n.report(db().points.first.id, 'לא עובד', kMxStaffLabel);
        woId = n.lastCreatedId!;
        n
          ..assign(woId, kMxTechName)
          ..requestPart(woId, 1, kMxTechName);
      },
    );
    await h.tap('wo-filter-waiting');
    await h.tap('wo-$woId');
    await h.tap('wo-cancel-req');
    await h.tap('confirm-yes', wait: false);
    expect(h.db.workOrder(woId).status, MxWoStatus.assigned);
    expect(h.db.workOrder(woId).poId, isEmpty);
    expect(find.byKey(const Key('wo-fix')), findsOneWidget);
  });

  testWidgets('tech fix can be undone from the toast', (tester) async {
    late String woId;
    final h = await _H.start(
      tester,
      role: MxRole.tech,
      seed: (n, db) {
        n.report(db().points.first.id, 'לא עובד', kMxStaffLabel);
        woId = n.lastCreatedId!;
        n.assign(woId, kMxTechName);
      },
    );
    await h.tap('wo-$woId');
    await h.tap('wo-fix-nopart');
    expect(h.db.workOrder(woId).status, MxWoStatus.done);
    await tester.tap(find.byKey(const Key('toast-undo')));
    await tester.pumpAndSettle();
    expect(h.db.workOrder(woId).status, MxWoStatus.assigned);
  });

  testWidgets('a point already reported: add to the open job, no duplicate', (
    tester,
  ) async {
    late String woId;
    late MxPoint pt;
    final h = await _H.start(
      tester,
      role: MxRole.staff,
      seed: (n, db) {
        final kitchen = db()
            .roomsOf('jrs-3')
            .firstWhere((r) => r.name == 'מטבח');
        pt = db().pointsOf(kitchen.id).firstWhere((p) => p.type == 'ברז');
        n.report(pt.id, 'מטפטף', kMxStaffLabel);
        woId = n.lastCreatedId!;
      },
    );
    await h.tap('rep-room-${pt.roomId}');
    await h.tap('rep-point-${pt.id}');
    expect(find.byKey(const Key('rep-existing')), findsOneWidget);
    expect(find.text('הוסיפו לקריאה הקיימת'), findsOneWidget);
    await h.tap('rep-reason-1');
    await h.tap('rep-send');
    expect(h.db.workOrders.where((w) => w.pointId == pt.id).length, 1);
    expect(h.db.workOrder(woId).log.first.text, contains('לא יוצאים מים'));
  });

  testWidgets('"something else": a general room exists in every apartment', (
    tester,
  ) async {
    final h = await _H.start(tester, role: MxRole.staff);
    final general = h.db
        .roomsOf(kMxStaffUnit)
        .where((r) => r.name.startsWith('כללי'));
    expect(general, hasLength(1));
    await h.tap('rep-room-${general.single.id}');
    expect(find.text('משהו אחר 1'), findsOneWidget);
  });

  testWidgets('sites search finds points across apartments', (tester) async {
    final h = await _H.start(tester);
    await h.tab('מסגרות');
    await tester.enterText(find.byKey(const Key('site-search')), 'גלאי עשן');
    await tester.pumpAndSettle();
    final hits = h.db.points.where((p) => p.label.contains('גלאי עשן'));
    expect(hits, isNotEmpty);
    expect(find.byKey(Key('find-${hits.first.id}')), findsOneWidget);
  });

  testWidgets('badges are role-scoped', (tester) async {
    final h = await _H.start(
      tester,
      role: MxRole.staff,
      seed: (n, db) {
        // Another home's report: not this home's badge.
        n.report(db().points.last.id, 'לא עובד', 'צוות הבית – דירה אחרת');
      },
    );
    final badges = tester.widgetList<Badge>(find.byType(Badge));
    expect(badges.every((b) => !b.isLabelVisible), isTrue);
    expect(h.db.openWorkOrders, hasLength(1));
  });

  testWidgets('reset asks before wiping the demo', (tester) async {
    final h = await _H.start(
      tester,
      seed: (n, db) => n.report(db().points.first.id, 'לא עובד', 'x'),
    );
    await h.tap('mx-reset', wait: false);
    await h.tap('confirm-no', wait: false);
    expect(h.db.openWorkOrders, hasLength(1));
    await h.tap('mx-reset', wait: false);
    await h.tap('confirm-yes', wait: false);
    expect(h.db.openWorkOrders, isEmpty);
  });

  testWidgets('a11y: tiles and the role switch work with a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _H.start(tester, role: MxRole.staff);
    expect(find.text('איפה התקלה?'), findsOneWidget);
    // Activate the kitchen tile the way TalkBack/VoiceOver does.
    tester.semantics.tap(find.semantics.byLabel(RegExp('^מטבח, ')));
    await tester.pumpAndSettle();
    expect(find.text('מה לא עובד?'), findsOneWidget);
    tester.semantics.tap(find.semantics.byLabel('מנהל'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('kpi-urgent')), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
    'small phone (320×640): every role and tab renders without overflow',
    (tester) async {
      final h = await _H.start(
        tester,
        size: const Size(320, 640),
        seed: (n, db) {
          n
            ..report(db().points.first.id, 'ניצוצות', kMxStaffLabel)
            ..assign(n.lastCreatedId!, kMxTechName)
            ..requestPart(n.lastCreatedId!, 4, kMxTechName)
            ..autoReorder();
          n.approve(db().purchaseOrders.last.id);
        },
      );
      for (final role in MxRole.values) {
        h.container.read(mxRoleProvider.notifier).state = role;
        await tester.pumpAndSettle();
        final bar = find.byType(NavigationBar);
        final count =
            bar.evaluate().isEmpty
                ? 1
                : tester.widget<NavigationBar>(bar).destinations.length;
        for (var i = 0; i < count; i++) {
          if (bar.evaluate().isNotEmpty) {
            await tester.tap(
              find
                  .descendant(
                    of: bar,
                    matching: find.byType(NavigationDestination),
                  )
                  .at(i),
            );
            await tester.pumpAndSettle();
          }
          expect(tester.takeException(), isNull, reason: '$role tab $i');
        }
      }
      // Detail pages with sticky bars too.
      await h.role('טכנאי');
      await h.tap('wo-${h.db.workOrders.first.id}', wait: false);
      expect(tester.takeException(), isNull, reason: 'work order page');
      await h.role('חנות');
      final po = h.db.purchaseOrders.lastWhere((o) => o.token.isNotEmpty);
      await tester.tap(find.byKey(Key('inbox-${po.id}')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'store page');
      expect(find.byKey(const Key('store-ready')), findsOneWidget);
    },
  );

  testWidgets('point card: report by quick reason; tech picks part quantity', (
    tester,
  ) async {
    final h = await _H.start(tester);
    final kitchen = h.db.roomsOf('jrs-3').firstWhere((r) => r.name == 'מטבח');
    final faucet = h.db.pointsOf(kitchen.id).firstWhere((p) => p.type == 'ברז');
    await h.tab('מסגרות');
    await h.tap('site-jrs');
    await h.tap('unit-jrs-3');
    await h.tap('room-${kitchen.id}');
    await h.tap('pt-${faucet.id}');
    await h.tap('report-point');
    await h.tap('fault-reason-0', wait: false); // 'מטפטף'
    await h.tap('fault-send', wait: false);
    final wo = h.db.openWorkOrders.single;
    expect(wo.pointId, faucet.id);
    expect(wo.desc, 'מטפטף');
    expect(
      find.text('כבר דווח – הוסיפו הערה לקריאה'),
      findsOneWidget,
      reason: 'the point now offers a comment instead of a duplicate',
    );

    h.n.assign(wo.id, kMxTechName);
    await h.role('טכנאי');
    await h.tap('wo-${wo.id}');
    await h.tap('wo-need');
    // Custom quantity with the stepper.
    await h.tap('qty-plus', wait: false);
    await h.tap('qty-plus', wait: false);
    await h.tap('qty-ok', wait: false);
    final po = h.db.po(h.db.workOrder(wo.id).poId);
    expect(po.lines.single.qty, 3);
    expect(po.lines.single.sku, faucet.sku);
  });

  testWidgets('store link page: no back arrow when opened from WhatsApp', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => _now),
        mxDbProvider.overrideWith(
          (ref) =>
              MxNotifier(() => _now, persist: false, initial: mxDemoSeed(_now)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: MxStorePage(token: 'not-a-real-token', fromLink: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('הקישור לא תקף'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
  });
}
