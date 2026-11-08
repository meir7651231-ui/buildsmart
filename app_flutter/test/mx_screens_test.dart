// Maintenance module — end-to-end widget flow through the real screens, all
// four roles: staff reports a point → manager assigns → tech fixes with a part
// (stock −1) → manager auto-reorders + approves → WhatsApp link opened (fake
// launcher) → store confirms + ready by link page → manager receives (stock +).

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_screens.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 11, 8, 10);

  testWidgets('full maintenance loop across roles', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final launched = <Uri>[];
    // REAL providers end-to-end: purchasing rides BuildSmart's own engines.
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => now),
        urlLauncherProvider.overrideWithValue((uri) async {
          launched.add(uri);
          return true;
        }),
      ],
    );
    addTearDown(container.dispose);
    MxDb db() => container.read(mxDbProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MxApp()),
    );
    await tester.pumpAndSettle();

    Future<void> role(String label) async {
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

    Future<void> tapKey(String key) async {
      // Let any confirmation toast clear, as a real user would.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      final f = find.byKey(Key(key));
      // Long pages build lazily: scroll down to it like a user would.
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          f,
          300,
          scrollable: find.byType(Scrollable).last,
        );
      }
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    // Dashboard: point-level register count.
    expect(find.text('${db().points.length}'), findsOneWidget);

    // ── staff reports a kitchen outlet ──
    await role('מדריך');
    // 3 taps, no typing: room tile → point tile → quick reason chip.
    final kitchen = db()
        .roomsOf(kMxStaffUnit)
        .firstWhere((r) => r.name == 'מטבח');
    final outlet = db().pointsOf(kitchen.id).first;
    await tapKey('rep-room-${kitchen.id}');
    await tapKey('rep-point-${outlet.id}');
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const Key('rep-send')),
              matching: find.byWidgetPredicate((w) => w is FilledButton),
            ),
          )
          .onPressed,
      isNull,
      reason: 'send stays disabled until something is said',
    );
    await tapKey('rep-reason-1'); // 'ניצוצות / ריח שרוף'
    await tester.enterText(
      find.byKey(const Key('rep-text')),
      'מהשקע ליד הכיור',
    );
    await tapKey('rep-photo');
    await tapKey('rep-send');
    expect(
      find.text('הדיווח נשלח'),
      findsOneWidget,
      reason: 'calm success sheet',
    );
    await tapKey('success-mine');
    expect(
      db().openWorkOrders.single.desc,
      'ניצוצות / ריח שרוף – מהשקע ליד הכיור',
    );
    expect(db().openWorkOrders.single.pointId, outlet.id);
    expect(db().openWorkOrders.single.reportedBy, kMxStaffLabel);
    expect(db().openWorkOrders.single.hasPhoto, isTrue);
    final woId = db().openWorkOrders.single.id;
    expect(
      find.text('$woId · ניצוצות / ריח שרוף – מהשקע ליד הכיור'),
      findsOneWidget,
      reason: 'staff lands on "my reports"',
    );

    // ── manager assigns ──
    await role('מנהל');
    await tab('קריאות');
    await tapKey('wo-$woId');
    await tapKey('wo-assign');
    expect(db().workOrder(woId).assignee, kMxTechName);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ── tech fixes with a part ──
    await role('טכנאי');
    final before = db().qty('EL-SK16');
    await tapKey('wo-$woId');
    await tapKey('wo-fix');
    expect(db().workOrder(woId).status, MxWoStatus.done);
    expect(db().qty('EL-SK16'), before - 1);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ── manager: auto reorder → approve → WhatsApp ──
    await role('מנהל');
    await tab('מלאי');
    await tapKey('auto-reorder');
    final pos = db().pendingApproval;
    expect(pos, isNotEmpty);
    final po = pos.firstWhere((o) => o.storeId == kMxStoreId);
    await tab('הזמנות');
    await tapKey('po-approve-${po.id}');
    expect(db().po(po.id).status, MxPoStatus.sent);
    // The approval rode BuildSmart: request ordered + a real store order.
    final orderId = db().po(po.id).orderId;
    expect(
      container.read(ordersEngineProvider).any((o) => o.id == orderId),
      isTrue,
    );
    expect(
      container
          .read(materialRequestsProvider)
          .firstWhere((r) => r.id == db().po(po.id).matReqId)
          .status,
      kMatReqOrdered,
    );
    expect(find.byKey(Key('po-bs-${po.id}')), findsOneWidget);
    await tapKey('po-wa-${po.id}');
    expect(launched.single.host, 'wa.me');
    expect(launched.single.queryParameters['text'], contains(po.id));
    expect(
      launched.single.queryParameters['text'],
      contains(db().po(po.id).token),
    );

    // ── store answers from its inbox / link page ──
    await role('חנות');
    await tapKey('inbox-${po.id}');
    await tapKey('store-confirm');
    expect(db().po(po.id).status, MxPoStatus.storeConfirmed);
    await tester.enterText(find.byKey(const Key('store-invoice')), '5531');
    await tapKey('store-ready');
    expect(db().po(po.id).status, MxPoStatus.ready);
    expect(db().po(po.id).invoiceNo, '5531');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ── manager receives → stock up ──
    await role('מנהל');
    await tab('הזמנות');
    final line = db().po(po.id).lines.first;
    final had = db().qty(line.sku);
    await tapKey('po-receive-${po.id}');
    expect(db().po(po.id).status, MxPoStatus.received);
    expect(db().qty(line.sku), had + line.qty);
    expect(
      container
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == orderId)
          .stage,
      'delivered',
    );

    // ── PM: mark an overdue legal check done ──
    await tab('תחזוקה');
    expect(find.textContaining('חובה:'), findsWidgets);
    await tapKey('pm-done-hotwater');
    expect(
      db().dueOf(db().pmRules.firstWhere((r) => r.id == 'hotwater'), now),
      MxDue.ok,
    );
  });

  testWidgets('a11y: tiles are operable by a screen reader (semantic tap)', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [mxClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    container.read(mxRoleProvider.notifier).state = MxRole.staff;
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MxApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('איפה התקלה?'), findsOneWidget);
    // Activate the kitchen tile the way TalkBack/VoiceOver does.
    tester.semantics.tap(find.semantics.byLabel(RegExp(r'^מטבח, ')));
    await tester.pumpAndSettle();
    expect(find.text('מה לא עובד?'), findsOneWidget);
    handle.dispose();
  });

  testWidgets(
    'small phone (320×640): every role and tab renders without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(640, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer(
        overrides: [mxClockProvider.overrideWithValue(() => now)],
      );
      addTearDown(container.dispose);
      // Some open work + orders so every screen has content to lay out.
      final n = container.read(mxDbProvider.notifier);
      final db0 = container.read(mxDbProvider);
      n.report(db0.points.first.id, 'בדיקה', kMxStaffLabel);
      n.assign(n.lastCreatedId!, kMxTechName);
      n.requestPart(n.lastCreatedId!, 4, kMxTechName);
      n.autoReorder();
      n.approve(container.read(mxDbProvider).purchaseOrders.last.id);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MxApp()),
      );
      await tester.pumpAndSettle();
      for (final role in MxRole.values) {
        container.read(mxRoleProvider.notifier).state = role;
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
    },
  );

  testWidgets('point card: report by quick reason; tech picks part quantity', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [mxClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    MxDb db() => container.read(mxDbProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MxApp()),
    );
    await tester.pumpAndSettle();
    Future<void> tapKey(String key) async {
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      final f = find.byKey(Key(key));
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(
          f,
          300,
          scrollable: find.byType(Scrollable).last,
        );
      }
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    final kitchen = db().roomsOf('jrs-3').firstWhere((r) => r.name == 'מטבח');
    final faucet = db().pointsOf(kitchen.id).firstWhere((p) => p.type == 'ברז');
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('מסגרות'),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey('site-jrs');
    await tapKey('unit-jrs-3');
    await tapKey('room-${kitchen.id}');
    await tapKey('pt-${faucet.id}');
    await tapKey('report-point');
    await tapKey('fault-reason-0'); // 'מטפטף'
    await tapKey('fault-send');
    final wo = db().openWorkOrders.single;
    expect(wo.pointId, faucet.id);
    expect(wo.desc, 'מטפטף');

    container.read(mxDbProvider.notifier).assign(wo.id, kMxTechName);
    // Back to the root and switch to the tech the way a user does.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    while (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('mx-roles')),
        matching: find.text('טכנאי'),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey('wo-${wo.id}');
    await tapKey('wo-need');
    await tapKey('qty-2');
    final po = db().po(db().workOrder(wo.id).poId);
    expect(po.lines.single.qty, 2);
    expect(po.lines.single.sku, faucet.sku);
  });

  testWidgets('invalid store link shows an honest message', (tester) async {
    final container = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => now),
        mxDbProvider.overrideWith(
          (ref) =>
              MxNotifier(() => now, persist: false, initial: mxDemoSeed(now)),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MxStorePage(token: 'not-a-real-token')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('הקישור לא תקף'), findsOneWidget);
  });
}
