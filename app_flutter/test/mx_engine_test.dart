// Maintenance module (אחזקה ורכש) — engine coverage.
// Pins the whole flow: point-level register → fault → assign → close with part
// (stock −1, history) | request part → PO → approve (token) → store answers
// by link → receive (stock +, job back to the tech); low-stock auto-reorder
// grouped per store with no double ordering; reroute of missing lines;
// allocation-number guard; PM classification; JSON round-trip.

import 'dart:convert';
import 'dart:math';

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 8, 10);
  MxDb seed() => mxDemoSeed(now);

  /// First point of [type] in the kitchen of jrs-3.
  String kitchenPoint(MxDb db, String type) {
    final kitchen = db.roomsOf('jrs-3').firstWhere((r) => r.name == 'מטבח');
    return db.pointsOf(kitchen.id).firstWhere((p) => p.type == type).id;
  }

  group('register — point level', () {
    test('every template line becomes individual numbered points', () {
      final (rooms, points) = mxBuildUnit('u1');
      expect(rooms.map((r) => r.name), kMxRoomTemplates.keys);
      final expected = kMxRoomTemplates.values
          .expand((l) => l)
          .fold<int>(0, (a, t) => a + t.$3);
      expect(points.length, expected);
      final kitchen = rooms.first.id;
      final outlets = points.where(
        (p) => p.roomId == kitchen && p.type == 'שקע',
      );
      expect(outlets.map((p) => p.num), [for (var i = 1; i <= 10; i++) i]);
      expect(
        points.map((p) => p.id).toSet().length,
        points.length,
        reason: 'ids unique',
      );
    });

    test('every point references a part that exists in the catalog', () {
      final skus = {for (final p in kMxParts) p.sku};
      final (_, points) = mxBuildUnit('u1');
      expect(points.where((p) => !skus.contains(p.sku)), isEmpty);
    });

    test('demo seed: 5 units, each with the full template', () {
      final db = seed();
      expect(db.units.length, 5);
      final perUnit = mxBuildUnit('x').$2.length;
      for (final u in db.units) {
        expect(db.pointCountOfUnit(u.id), perUnit);
      }
      expect(
        db.pointPath(kitchenPoint(db, 'שקע')),
        'ירושלים\u00A0· דירה 3\u00A0· מטבח\u00A0· שקע 1 – מעל משטח',
      );
    });
  });

  group('work orders', () {
    test('report → point faulty, WO open with role label only', () {
      final db0 = seed();
      final pid = kitchenPoint(db0, 'שקע');
      final (db, id) = reportFault(
        db0,
        pointId: pid,
        desc: ' ניצוצות ',
        reportedBy: 'מדריך – דירה 3',
        now: now,
        hasPhoto: true,
      );
      final wo = db.workOrder(id);
      expect(wo.desc, 'ניצוצות');
      expect(wo.status, MxWoStatus.open);
      expect(wo.hasPhoto, isTrue);
      expect(db.point(pid).status, MxPointStatus.faulty);
      expect(db.openWorkOrders.length, 1);
      expect(
        db0.point(pid).status,
        MxPointStatus.ok,
        reason: 'input db untouched (immutable)',
      );
    });

    test('empty description and unknown point are rejected', () {
      final db = seed();
      expect(
        () => reportFault(
          db,
          pointId: kitchenPoint(db, 'שקע'),
          desc: '  ',
          reportedBy: 'x',
          now: now,
        ),
        throwsA(isA<MxError>()),
      );
      expect(
        () => reportFault(
          db,
          pointId: 'nope',
          desc: 'x',
          reportedBy: 'x',
          now: now,
        ),
        throwsA(isA<MxError>()),
      );
    });

    test(
      'assign → close with part: stock −1, point ok, history entry with cost',
      () {
        var (db, id) = reportFault(
          seed(),
          pointId: kitchenPoint(seed(), 'שקע'),
          desc: 'שרוף',
          reportedBy: 'm',
          now: now,
        );
        db = assignWorkOrder(db, id, 'יוסי');
        expect(db.workOrder(id).assignee, 'יוסי');
        final before = db.qty('EL-SK16');
        db = closeWithPart(db, id, by: 'יוסי', now: now);
        expect(db.qty('EL-SK16'), before - 1);
        final p = db.point(db.workOrder(id).pointId);
        expect(p.status, MxPointStatus.ok);
        expect(p.history.first.text, contains(mxWoLabel(id)));
        expect(p.history.first.costAgorot, 1800);
        expect(db.workOrder(id).status, MxWoStatus.done);
        expect(
          () => closeWithPart(db, id, by: 'x', now: now),
          throwsA(isA<MxError>()),
          reason: 'no double close',
        );
      },
    );

    test('close with part fails honestly when stock is 0', () {
      var db = seed();
      db = db.copyWith(stock: {...db.stock, 'EL-SK16': 0});
      final (db2, id) = reportFault(
        db,
        pointId: kitchenPoint(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      expect(
        () => closeWithPart(db2, id, by: 't', now: now),
        throwsA(isA<MxError>()),
      );
    });

    test('close without part', () {
      final (db, id) = reportFault(
        seed(),
        pointId: kitchenPoint(seed(), 'סיפון'),
        desc: 'סתום',
        reportedBy: 'm',
        now: now,
      );
      final db2 = closeNoPart(db, id, by: 't', now: now, note: 'נוקה');
      expect(db2.workOrder(id).status, MxWoStatus.done);
      expect(db2.qty('PL-SIF'), db.qty('PL-SIF'));
      expect(
        db2.point(db.workOrder(id).pointId).history.first.text,
        startsWith('נוקה'),
      );
    });
  });

  group('purchasing — request part → approve → store link → receive', () {
    test('full loop', () {
      var db = seed();
      final (db1, wo) = reportFault(
        db,
        pointId: kitchenPoint(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      db = assignWorkOrder(db1, wo, 'יוסי');
      final (db2, po) = requestPart(db, wo, qty: 4, by: 'יוסי', now: now);
      db = db2;
      expect(db.workOrder(wo).status, MxWoStatus.waitingPart);
      expect(db.workOrder(wo).poId, po);
      final o = db.po(po);
      expect(o.status, MxPoStatus.pendingApproval);
      expect(o.storeId, 'st-tambur');
      expect(o.lines.single.qty, 4);
      expect(o.totalAgorot, 4 * 1800);
      expect(o.token, isEmpty, reason: 'no link before approval');

      db = approvePo(db, po, rng: Random(1));
      final token = db.po(po).token;
      expect(token.length, 20);
      expect(
        db.po(po).status,
        MxPoStatus.approved,
        reason: 'approved is NOT sent until it actually leaves',
      );
      db = mxMarkSent(db, po);
      expect(db.po(po).status, MxPoStatus.sent);

      db = storeAct(db, token, MxStoreAction.confirm);
      expect(db.po(po).status, MxPoStatus.storeConfirmed);
      db = storeAct(db, token, MxStoreAction.ready, invoiceNo: ' 5531 ');
      expect(db.po(po).status, MxPoStatus.ready);
      expect(db.po(po).invoiceNo, '5531');

      final before = db.qty('EL-SK16');
      db = receivePo(db, po);
      expect(db.qty('EL-SK16'), before + 4);
      expect(db.po(po).status, MxPoStatus.received);
      expect(
        db.workOrder(wo).status,
        MxWoStatus.assigned,
        reason: 'job returns to the tech',
      );
      expect(
        () => receivePo(db, po),
        throwsA(isA<MxError>()),
        reason: 'no double receive',
      );
      expect(
        () => storeAct(db, token, MxStoreAction.ready),
        throwsA(isA<MxError>()),
        reason: 'closed PO',
      );
    });

    test('store cannot act before approval; bad token rejected', () {
      final (db, ids) = autoReorder(seed(), now: now);
      final po = db.po(ids.first);
      expect(
        () => storeAct(db, 'bogus', MxStoreAction.confirm),
        throwsA(isA<MxError>()),
      );
      expect(db.poByToken(''), isNull);
      expect(po.token, isEmpty);
    });

    test('reject → waiting job returns to the tech', () {
      var db = seed();
      final (db1, wo) = reportFault(
        db,
        pointId: kitchenPoint(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      final (db2, po) = requestPart(
        assignWorkOrder(db1, wo, 't'),
        wo,
        qty: 1,
        by: 't',
        now: now,
      );
      db = rejectPo(db2, po, reason: 'יש במחסן המרכזי');
      expect(db.po(po).status, MxPoStatus.rejected);
      expect(db.workOrder(wo).status, MxWoStatus.assigned);
      expect(db.workOrder(wo).poId, '');
      expect(() => approvePo(db, po), throwsA(isA<MxError>()));
      expect(() => receivePo(db, po), throwsA(isA<MxError>()));
    });

    test(
      'missing line → partial; receive adds only supplied lines; reroute',
      () {
        var db = seed();
        final (db1, ids) = autoReorder(db, now: now);
        db = db1;
        final po = db.purchaseOrders.firstWhere(
          (o) => o.storeId == 'st-tambur' && o.lines.length > 1,
        );
        db = approvePo(db, po.id);
        final token = db.po(po.id).token;
        final missingSku = po.lines.first.sku;
        db = storeMarkMissing(db, token, missingSku);
        expect(db.po(po.id).status, MxPoStatus.storePartial);
        expect(
          () => storeMarkMissing(db, token, 'NOT-IN-PO'),
          throwsA(isA<MxError>()),
        );

        // With no other store of that type → honest error.
        final onlyTambur = db.copyWith(
          stores: db.stores.where((s) => s.id == 'st-tambur').toList(),
        );
        expect(
          () => rerouteMissing(onlyTambur, po.id, now: now),
          throwsA(isA<MxError>()),
        );
        // The seed's electrical store is the alternative for an electrical line.
        if (db.part(missingSku).storeType == 'חשמל') {
          final (dbE, altE) = rerouteMissing(db, po.id, now: now);
          expect(dbE.po(altE!).storeId, 'st-electric');
        }
        // Add an explicit alternative store and reroute to it.
        final type = db.part(missingSku).storeType;
        db = onlyTambur.copyWith(
          stores: [
            ...onlyTambur.stores,
            MxStore(
              id: 'st-alt',
              name: 'חלופי',
              types: {type},
              phone: '0521111111',
            ),
          ],
        );
        final (db2, alt) = rerouteMissing(db, po.id, now: now);
        db = db2;
        expect(db.po(alt!).storeId, 'st-alt');
        expect(db.po(alt).lines.single.sku, missingSku);
        expect(db.po(alt).status, MxPoStatus.pendingApproval);

        final before = db.qty(missingSku);
        final otherSku = po.lines[1].sku;
        final otherBefore = db.qty(otherSku);
        db = receivePo(db, po.id);
        expect(
          db.qty(missingSku),
          before,
          reason: 'missing line not added to stock',
        );
        expect(db.qty(otherSku), otherBefore + po.lines[1].qty);
      },
    );

    test('allocation number required above the threshold', () {
      var db = seed();
      final big = MxPurchaseOrder(
        id: 'PO-X',
        storeId: 'st-tambur',
        lines: const [
          MxPoLine(sku: 'SF-EXT', qty: 30, unitAgorot: 19000),
        ], // 5,700 ₪
        requestedBy: 'm',
        createdAt: now,
      );
      db = db.copyWith(purchaseOrders: [big]);
      expect(mxNeedsAllocation(big), isTrue);
      db = approvePo(db, 'PO-X');
      final token = db.po('PO-X').token;
      db = storeAct(db, token, MxStoreAction.ready, invoiceNo: '77');
      expect(() => receivePo(db, 'PO-X'), throwsA(isA<MxError>()));
      db = storeAct(db, token, MxStoreAction.ready, allocationNo: '123456789');
      expect(
        db.po('PO-X').invoiceNo,
        '77',
        reason: 'empty field keeps earlier value',
      );
      db = receivePo(db, 'PO-X');
      expect(db.po('PO-X').status, MxPoStatus.received);
    });
  });

  test(
    'reroute still possible after the store marked the rest ready; never twice',
    () {
      var db = seed();
      final (db1, ids) = autoReorder(db, now: now);
      db = approvePo(db1, ids.first);
      final po = db.po(ids.first);
      db = storeMarkMissing(db, po.token, po.lines.first.sku);
      db = storeAct(db, po.token, MxStoreAction.ready);
      expect(db.po(po.id).status, MxPoStatus.ready);
      expect(
        mxCanReroute(db, db.po(po.id)),
        isTrue,
        reason: 'missing line still needs a store',
      );
      final (db2, alt) = rerouteMissing(db, po.id, now: now);
      expect(alt, isNotNull);
      expect(
        mxCanReroute(db2, db2.po(po.id)),
        isFalse,
        reason: 'already rerouted',
      );
      expect(
        () => rerouteMissing(db2, po.id, now: now),
        throwsA(isA<MxError>()),
      );
      // A rejected reroute can be rerouted again.
      final db3 = rejectPo(db2, alt!);
      expect(mxCanReroute(db3, db3.po(po.id)), isTrue);
    },
  );

  group('critique fixes', () {
    String pointOf(MxDb db, String type) {
      final k = db.roomsOf('jrs-3').firstWhere((r) => r.name == 'מטבח');
      return db.pointsOf(k.id).firstWhere((p) => p.type == type).id;
    }

    test('safety words make a job urgent; urgent sorts first', () {
      var db = seed();
      final (db1, drip) = reportFault(
        db,
        pointId: pointOf(db, 'ברז'),
        desc: 'מטפטף',
        reportedBy: 'x',
        now: now,
      );
      final (db2, sparks) = reportFault(
        db1,
        pointId: pointOf(db1, 'שקע'),
        desc: 'ניצוצות / ריח שרוף',
        reportedBy: 'x',
        now: now.subtract(const Duration(hours: 1)),
      );
      db = db2;
      expect(db.workOrder(sparks).urgent, isTrue);
      expect(db.workOrder(drip).urgent, isFalse);
      expect(
        mxSortedOpen(db.openWorkOrders).first.id,
        sparks,
        reason: 'older but urgent',
      );
      expect(mxSafetyInstruction('שקע', 'ניצוצות'), contains('המפסק'));
    });

    test('duplicate report on the same point is refused; comment instead', () {
      final (db, id) = reportFault(
        seed(),
        pointId: pointOf(seed(), 'סיפון'),
        desc: 'סתום',
        reportedBy: 'a',
        now: now,
      );
      expect(
        () => reportFault(
          db,
          pointId: db.workOrder(id).pointId,
          desc: 'שוב',
          reportedBy: 'b',
          now: now,
        ),
        throwsA(
          isA<MxError>().having(
            (e) => e.message,
            'msg',
            contains(mxWoLabel(id)),
          ),
        ),
      );
      final db2 = commentOn(db, id, 'החמיר', by: 'b', now: now);
      expect(db2.workOrder(id).log.first.text, 'הערה: החמיר');
      expect(db2.workOrder(id).log.length, 2, reason: 'report + comment');
    });

    test('reject reason reaches the tech log', () {
      var db = seed();
      final (db1, wo) = reportFault(
        db,
        pointId: pointOf(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      final (db2, po) = requestPart(
        assignWorkOrder(db1, wo, 't'),
        wo,
        qty: 1,
        by: 't',
        now: now,
      );
      db = rejectPo(db2, po, reason: 'יש במחסן המרכזי', now: now);
      expect(
        db.workOrder(wo).log.first.text,
        'בקשת החלק נדחתה: יש במחסן המרכזי',
      );
    });

    test('cancel request / found part', () {
      var db = seed();
      final (db1, wo) = reportFault(
        db,
        pointId: pointOf(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      final (db2, po) = requestPart(
        assignWorkOrder(db1, wo, 't'),
        wo,
        qty: 2,
        by: 't',
        now: now,
      );
      expect(
        () => requestPart(db2, wo, qty: 1, by: 't', now: now),
        throwsA(isA<MxError>()),
        reason: 'one request at a time',
      );
      db = cancelPartRequest(db2, wo, by: 't', now: now);
      expect(db.po(po).status, MxPoStatus.rejected);
      expect(db.workOrder(wo).status, MxWoStatus.assigned);
      final (db3, po2) = requestPart(db, wo, qty: 1, by: 't', now: now);
      db = closeNoPart(
        db3,
        wo,
        by: 't',
        now: now,
        note: 'תוקן – החלק נמצא ממקור אחר',
      );
      expect(db.workOrder(wo).status, MxWoStatus.done);
      expect(
        db.po(po2).status,
        MxPoStatus.rejected,
        reason: 'pending request cancelled',
      );
    });

    test(
      'partial supply: receive adds only supplied; reroute takes the shortfall and moves the job',
      () {
        var db = seed();
        final (db1, wo) = reportFault(
          db,
          pointId: pointOf(db, 'שקע'),
          desc: 'x',
          reportedBy: 'm',
          now: now,
        );
        final (db2, po) = requestPart(
          assignWorkOrder(db1, wo, 't'),
          wo,
          qty: 10,
          by: 't',
          now: now,
        );
        db = approvePo(db2, po);
        final token = db.po(po).token;
        db = storeSetSupplied(db, token, 'EL-SK16', 0);
        expect(db.po(po).status, MxPoStatus.storePartial);
        final (db3, alt) = rerouteMissing(db, po, now: now);
        db = db3;
        expect(db.po(alt!).lines.single.qty, 10);
        expect(
          db.workOrder(wo).poId,
          alt,
          reason: 'the waiting job follows the rerouted part',
        );
        final before = db.qty('EL-SK16');
        db = receivePo(db, po);
        expect(db.qty('EL-SK16'), before);
        expect(
          db.workOrder(wo).status,
          MxWoStatus.waitingPart,
          reason: 'part did not arrive yet',
        );

        // partial quantity on another order
        final (db4, ids) = autoReorder(seed(), now: now);
        var d = approvePo(db4, ids.first);
        final o = d.po(ids.first);
        final l = o.lines.first;
        d = storeSetSupplied(d, o.token, l.sku, l.qty - 2);
        expect(d.po(o.id).lines.first.shortfall, 2);
        final had = d.qty(l.sku);
        d = receivePo(d, o.id);
        expect(d.qty(l.sku), had + l.qty - 2);
      },
    );

    test('store may act on an approved (not yet marked sent) order', () {
      final (db0, ids) = autoReorder(seed(), now: now);
      var db = approvePo(db0, ids.first);
      db = storeAct(db, db.po(ids.first).token, MxStoreAction.confirm);
      expect(db.po(ids.first).status, MxPoStatus.storeConfirmed);
    });

    test('labels hide internal codes', () {
      expect(mxWoLabel('WO-1001'), 'קריאה 1001');
      expect(mxPoLabel('PO-1003'), 'הזמנה 1003');
    });
  });

  group('stock — auto reorder', () {
    test('one PO per store, every low line topped up to 2×min', () {
      final db0 = seed();
      final low = db0.lowStock;
      expect(low, isNotEmpty);
      final (db, ids) = autoReorder(db0, now: now);
      final stores = {for (final id in ids) db.po(id).storeId};
      expect(stores.length, ids.length, reason: 'one PO per store');
      for (final p in low) {
        final line = db.purchaseOrders
            .expand((o) => o.lines)
            .firstWhere((l) => l.sku == p.sku);
        expect(line.qty, p.min * 2 - db0.qty(p.sku));
      }
      expect(
        ids.every((id) => db.po(id).status == MxPoStatus.pendingApproval),
        isTrue,
      );
    });

    test('running it twice does not double-order', () {
      final (db1, _) = autoReorder(seed(), now: now);
      final (db2, ids2) = autoReorder(db1, now: now);
      expect(ids2, isEmpty);
      expect(db2.purchaseOrders.length, db1.purchaseOrders.length);
    });

    test('imported store price overrides the reference price', () {
      var db = seed();
      db = db.copyWith(
        storePrices: {
          'st-tambur': {'EL-T8': 1990},
        },
      );
      final (db2, _) = autoReorder(db, now: now);
      final line = db2.purchaseOrders
          .expand((o) => o.lines)
          .firstWhere((l) => l.sku == 'EL-T8');
      expect(line.unitAgorot, 1990);
    });
  });

  group('preventive maintenance', () {
    test('classification + most-urgent-first ordering', () {
      final db = seed();
      final due = db.pmDue(now);
      expect(due.first.$2, MxDue.overdue);
      final idx = due.map((d) => d.$2.index).toList();
      expect(idx, [...idx]..sort(), reason: 'overdue → soon → ok');
      final rule = db.pmRules.firstWhere((r) => r.id == 'hotwater');
      expect(db.dueOf(rule, now), MxDue.overdue);
      expect(
        db.dueOf(db.pmRules.firstWhere((r) => r.id == 'elevator'), now),
        MxDue.soon,
      );
      expect(rule.isLegal, isTrue);
      expect(db.pmRules.firstWhere((r) => r.id == 'windows').isLegal, isFalse);
    });

    test('legal intervals match the verified research', () {
      int days(String id) => kMxPmCatalog.firstWhere((r) => r.$1 == id).$3;
      expect(days('elevator'), lessThanOrEqualTo(183)); // ≤ 6 months
      expect(days('hoist'), lessThanOrEqualTo(426)); // ≤ 14 months
      expect(days('rcd'), lessThanOrEqualTo(31)); // monthly
      expect(days('gas'), lessThanOrEqualTo(1827)); // ≤ 5 years
    });

    test('complete → next due moves a full interval ahead', () {
      var db = seed();
      db = completePm(db, 'hotwater', now: now);
      final r = db.pmRules.firstWhere((r) => r.id == 'hotwater');
      expect(r.nextDue, now.add(const Duration(days: 30)));
      expect(db.dueOf(r, now), MxDue.ok);
      expect(() => completePm(db, 'nope', now: now), throwsA(isA<MxError>()));
    });
  });

  group('persistence + formatting', () {
    test('JSON round-trip preserves everything after a full flow', () {
      var db = seed();
      final (db1, wo) = reportFault(
        db,
        pointId: kitchenPoint(db, 'שקע'),
        desc: 'x',
        reportedBy: 'm',
        now: now,
      );
      final (db2, po) = requestPart(
        assignWorkOrder(db1, wo, 't'),
        wo,
        qty: 2,
        by: 't',
        now: now,
      );
      db = approvePo(db2, po);
      db = db.copyWith(
        storePrices: {
          'st-tambur': {'EL-SK16': 1750},
        },
      );
      final back = MxDb.fromJson(
        (jsonDecode(jsonEncode(db.toJson())) as Map).cast<String, Object?>(),
      );
      expect(jsonEncode(back.toJson()), jsonEncode(db.toJson()));
      expect(back.poByToken(db.po(po).token)?.id, po);
    });

    test('unknown enum values fall back safely', () {
      final p = MxPoint.fromJson({
        'id': 'a',
        'roomId': 'r',
        'type': 't',
        'sku': 's',
        'status': 'weird',
      });
      expect(p.status, MxPointStatus.ok);
    });

    test('shekel formatting', () {
      expect(mxShekels(1800), '18 ₪');
      expect(mxShekels(123450), '1,234.50 ₪');
      expect(mxShekels(5), '0.05 ₪');
      expect(mxShekels(-250), '-2.50 ₪');
    });

    test('tokens are 20 chars from the unambiguous alphabet and distinct', () {
      final a = mxNewToken();
      final b = mxNewToken();
      expect(a, matches(RegExp(r'^[a-hjkmnp-z2-9]{20}$')));
      expect(a == b, isFalse);
    });
  });
}
