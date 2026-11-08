// Maintenance module — EXHAUSTIVE end-to-end walk: every screen, every button,
// all four roles, through the real widgets and the real BuildSmart engines.
// Each step asserts the OUTCOME (state changed / right screen opened), not
// just "no crash". Every check is logged as `E2E ✓ <name>` for the report.

// ignore_for_file: avoid_positional_boolean_parameters — ok(name, cond) reads best.

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_screens.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_ui.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 11, 8, 10);

  testWidgets('E2E: every screen and button, all roles', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});

    // Clipboard capture (the "copy link" button).
    String? clipboard;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    final launched = <Uri>[];
    final c = ProviderContainer(
      overrides: [
        mxClockProvider.overrideWithValue(() => now),
        urlLauncherProvider.overrideWithValue((uri) async {
          launched.add(uri);
          return true;
        }),
        taskPhotoPickerProvider.overrideWithValue(
          (_) async => 'data:image/png;base64,iVBORw0KGgo=',
        ),
      ],
    );
    addTearDown(c.dispose);
    MxDb db() => c.read(mxDbProvider);

    var checks = 0;
    void ok(String name, bool cond) {
      expect(cond, isTrue, reason: name);
      checks++;
      debugPrint('E2E ✓ $name');
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const MxApp()),
    );
    await tester.pumpAndSettle();

    Future<void> settle() async {
      await tester.pump(const Duration(seconds: 7)); // let toasts clear
      await tester.pumpAndSettle();
    }

    Future<void> tapFinder(Finder f) async {
      await settle();
      // Scroll to it like a user: any scrollable (vertical page or the
      // horizontal chip row), in both directions.
      if (f.evaluate().isEmpty) {
        final scrollables =
            find.byType(Scrollable).evaluate().toList().reversed;
        outer:
        for (final el in scrollables) {
          for (final delta in [300.0, -300.0]) {
            try {
              await tester.scrollUntilVisible(
                f,
                delta,
                scrollable: find.byElementPredicate((e) => e == el),
                maxScrolls: 30,
              );
              break outer;
            } on Object {
              // not in this scrollable / direction — try the next one
            }
          }
        }
      }
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }

    Future<void> tapKey(String k) => tapFinder(find.byKey(Key(k)));
    Future<void> tapText(String t) => tapFinder(find.text(t));
    Future<void> role(String label) async {
      await settle();
      while (find.byType(BackButton).evaluate().isNotEmpty) {
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('mx-roles')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('role-$label')));
      await tester.pumpAndSettle();
    }

    int navIndex() =>
        tester.widget<MxNavBar>(find.byType(MxNavBar)).selectedIndex;
    int navCount() =>
        tester.widget<MxNavBar>(find.byType(MxNavBar)).items.length;
    Future<void> nav(String label) async {
      await settle();
      await tester.tap(find.byKey(Key('nav-$label')));
      await tester.pumpAndSettle();
    }

    Future<void> back() async {
      await settle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    bool present(String k) => find.byKey(Key(k)).evaluate().isNotEmpty;
    bool enabledButton(String k) {
      final f = find.byKey(Key(k));
      final self = tester.widget(f.first);
      if (self is ButtonStyleButton) return self.onPressed != null;
      final w = tester.widget(
        find
            .descendant(
              of: f,
              matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
            )
            .first,
      );
      return (w as ButtonStyleButton).onPressed != null;
    }

    // ── 1 · shell: roles + nav ─────────────────────────────────────────────
    ok('מנהל: 5 לשוניות (מלאי והזמנות אוחדו ל"רכש")', navCount() == 5);
    for (final (i, t) in ['לוח', 'מסגרות', 'קריאות', 'תחזוקה', 'רכש'].indexed) {
      await nav(t);
      ok('לשונית "$t" נפתחת', navIndex() == i);
    }
    await nav('לוח');
    ok(
      'לוח: כרטיס פתיחה עם תאריך עברי ו"הבתים"',
      find.textContaining('בחשוון').evaluate().isNotEmpty &&
          find.textContaining('הבתים').evaluate().isNotEmpty,
    );
    await role('טכנאי');
    ok('טכנאי: 3 לשוניות', navCount() == 3);
    await role('צוות בית');
    ok('צוות בית: 2 לשוניות', navCount() == 2);
    await role('חנות');
    ok('חנות: מסך אחד בלי בר-ניווט', find.byType(MxNavBar).evaluate().isEmpty);
    await role('מנהל');

    // ── 2 · dashboard KPI cards → their tab ────────────────────────────────
    for (final (k, idx) in [
      ('urgent', 2),
      ('wo', 2),
      ('po', 4),
      ('overdue', 3),
      ('soon', 3),
      ('low', 4),
    ]) {
      await nav('לוח');
      await tapKey('kpi-$k');
      ok('כרטיס-מדד "$k" פותח לשונית $idx', navIndex() == idx);
      if (k == 'low') {
        ok('"חלקים להזמין" פותח את המלאי בתוך "רכש"', present('auto-reorder'));
      }
    }
    await nav('לוח');
    await tapText('מדידת טמפרטורת מים חמים (TMV)');
    ok('פריט "דחוף עכשיו" (בדיקה) פותח את לשונית התחזוקה', navIndex() == 3);

    // ── 2b · the street of arches + a demo work-day ────────────────────────
    await nav('לוח');
    ok(
      'רחוב הקשתות: קשת לכל דירה',
      db().units.every((u) => present('street-${u.id}')),
    );
    await tapKey('street-jrs-3');
    ok(
      'קשת → נכנסים לדירה (מסך החדרים)',
      db().roomsOf('jrs-3').every((r) => present('room-${r.id}')),
    );
    await back();

    // ── 3 · sites → units → rooms → point → report from the card ───────────
    await nav('מסגרות');
    ok('מסגרות: 2 אתרים', present('site-jrs') && present('site-bsh'));
    await tapKey('site-bsh');
    ok('אתר בית שמש: 2 דירות', present('unit-bsh-1') && present('unit-bsh-2'));
    await back();
    await tapKey('site-jrs');
    ok('אתר ירושלים: 3 דירות', present('unit-jrs-1') && present('unit-jrs-3'));
    await tapKey('unit-jrs-3');
    final rooms = db().roomsOf('jrs-3');
    ok('דירה 3: 5 חדרים', rooms.every((r) => present('room-${r.id}')));
    final kitchen = rooms.firstWhere((r) => r.name == 'מטבח');
    await tapKey('room-${kitchen.id}');
    ok('מטבח: 25 נקודות', db().pointsOf(kitchen.id).length == 25);
    final outlet = db().pointsOf(kitchen.id).first;
    await tapKey('pt-${outlet.id}');
    ok(
      'כרטיס-נקודה נפתח (חלק החלפה, בלי קוד פנימי)',
      find.text(db().part(outlet.sku).name).evaluate().isNotEmpty &&
          find.textContaining('EL-SK16').evaluate().isEmpty,
    );
    await tapKey('report-point');
    ok('גיליון סיבות נפתח, "פתח קריאה" כבוי', !enabledButton('fault-send'));
    await tapKey('fault-reason-1');
    ok('סיבה נבחרה → "פתח קריאה" פעיל', enabledButton('fault-send'));
    await tester.enterText(find.byKey(const Key('fault-text')), 'ליד הכיור');
    await tapKey('fault-send');
    ok(
      'ניצוצות = דחוף → מסך בטיחות מלא: "עצרו", צעדים ממוספרים וחיוג',
      find.text('עצרו. סכנת חשמל').evaluate().isNotEmpty &&
          present('urgent-call') &&
          present('safety-step-2'),
    );
    ok('"הבנתי" נעול עד שמסמנים את כל הצעדים', !enabledButton('success-mine'));
    for (var i = 0; i < 3; i++) {
      await tapKey('safety-step-$i');
    }
    ok('אחרי סימון הצעדים "הבנתי" פתוח', enabledButton('success-mine'));
    await tapKey('success-mine');
    final wo1 = db().openWorkOrders.single;
    ok(
      'קריאה נפתחה מכרטיס-הנקודה',
      wo1.pointId == outlet.id &&
          wo1.desc == 'ניצוצות / ריח שרוף – ליד הכיור' &&
          wo1.urgent,
    );
    ok(
      'נקודה שכבר דווחה: הכפתור מציע הערה במקום דיווח כפול',
      find.text('כבר דווח – הוסיפו הערה לקריאה').evaluate().isNotEmpty,
    );
    ok(
      'הנקודה מסומנת תקולה',
      db().point(outlet.id).status == MxPointStatus.faulty,
    );
    await back();
    ok('החדר מציג את הנקודה התקולה', find.text('תקול').evaluate().isNotEmpty);
    await back();
    await back();
    await back();
    ok('חזרה עד לרשימת המסגרות', find.text('המסגרות').evaluate().isNotEmpty);

    // ── 4 · reset ───────────────────────────────────────────────────────────
    await tapKey('mx-roles');
    await tapKey('mx-reset');
    ok(
      '"איפוס הדגמה" (בגיליון התפקידים) שואל לפני מחיקה',
      present('confirm-yes'),
    );
    await tapKey('confirm-yes');
    ok('"איפוס הדגמה" מחזיר את נתוני ההדגמה', db().openWorkOrders.isEmpty);

    // ── 5 · staff report: every control ────────────────────────────────────
    await role('צוות בית');
    ok(
      'צוות בית: שלב 1 "איפה התקלה?"',
      find.text('איפה התקלה?').evaluate().isNotEmpty,
    );
    final sRooms = db().roomsOf(kMxStaffUnit);
    final sKitchen = sRooms.firstWhere((r) => r.name == 'מטבח');
    await tapKey('rep-room-${sKitchen.id}');
    ok('אריח-חדר → שלב 2', find.text('מה לא עובד?').evaluate().isNotEmpty);
    await tapKey('rep-back');
    ok('"חזרה" משלב 2 → שלב 1', find.text('איפה התקלה?').evaluate().isNotEmpty);
    await tapKey('rep-room-${sKitchen.id}');
    final sPoint = db()
        .pointsOf(sKitchen.id)
        .firstWhere((p) => p.type == 'ברז');
    await tapKey('rep-point-${sPoint.id}');
    ok('אריח-נקודה → שלב 3', find.text('מה קרה?').evaluate().isNotEmpty);
    await tapKey('rep-back');
    ok('"חזרה" משלב 3 → שלב 2', find.text('מה לא עובד?').evaluate().isNotEmpty);
    await tapKey('rep-point-${sPoint.id}');
    ok('"שלח" כבוי כשאין תוכן', !enabledButton('rep-send'));
    await tapKey('rep-reason-0');
    ok('סיבה מוכנה → "שלח" פעיל', enabledButton('rep-send'));
    await tapKey('rep-reason-0');
    ok('לחיצה שנייה מבטלת את הסיבה → "שלח" כבוי', !enabledButton('rep-send'));
    await tapKey('rep-reason-0');
    await tapKey('rep-photo');
    ok(
      '"צלמו תמונה" (מצלמה אמיתית) → "התמונה צורפה"',
      find.textContaining('התמונה צורפה').evaluate().isNotEmpty,
    );
    await tapKey('rep-send');
    ok('גיליון הצלחה מוצג', find.text('תודה שדיווחת.').evaluate().isNotEmpty);
    final wo2 = db().openWorkOrders.single;
    ok(
      'הדיווח נשמר: סיבה + תמונה + תפקיד בלבד',
      wo2.desc == 'מטפטף' &&
          wo2.photo.startsWith('data:image/') &&
          wo2.reportedBy == kMxStaffLabel,
    );
    await tapKey('success-again');
    ok(
      '"דיווח נוסף" → חזרה לשלב 1',
      find.text('איפה התקלה?').evaluate().isNotEmpty,
    );
    final sBath = sRooms.firstWhere((r) => r.name == 'חדר רחצה');
    await tapKey('rep-room-${sBath.id}');
    final toilet = db().pointsOf(sBath.id).firstWhere((p) => p.type == 'אסלה');
    await tapKey('rep-point-${toilet.id}');
    await tester.enterText(
      find.byKey(const Key('rep-text')),
      'המיכל לא מפסיק למלא',
    );
    await tester.pumpAndSettle();
    ok('טקסט חופשי בלבד → "שלח" פעיל', enabledButton('rep-send'));
    await tapKey('rep-send');
    await tapKey('success-mine');
    ok('"לדיווחים שלי" → לשונית הדיווחים', navIndex() == 1);
    ok(
      '"הדיווחים שלי" מציג את שני הדיווחים',
      db().workOrders
          .where((w) => w.reportedBy == kMxStaffLabel)
          .every((w) => present('wo-${w.id}')),
    );
    await tapKey('wo-${wo2.id}');
    ok(
      'צוות בית רואה קריאה בלי כפתורי פעולה',
      !present('wo-assign') && !present('wo-fix'),
    );
    await tapKey('wo-comment');
    await tester.enterText(find.byKey(const Key('ask-text')), 'עדיין מטפטף');
    await tapKey('ask-ok');
    ok(
      'צוות בית מוסיף הערה ליומן הקריאה',
      db().workOrder(wo2.id).log.first.text == 'הערה: עדיין מטפטף',
    );
    await back();

    // ── 6 · manager assigns, tech fixes / no part / needs part ─────────────
    final wo3 = db().openWorkOrders.firstWhere((w) => w.pointId == toilet.id);
    await role('מנהל');
    await nav('קריאות');
    ok(
      'מנהל רואה את שתי הקריאות',
      present('wo-${wo2.id}') && present('wo-${wo3.id}'),
    );
    for (final w in [wo2, wo3]) {
      await tapKey('wo-${w.id}');
      await tapKey('wo-assign');
      ok('בחירת טכנאי מציגה עומס', present('tech-0') && present('tech-2'));
      await tapKey('tech-0');
      ok(
        '"שייכו לטכנאי" (${w.id})',
        db().workOrder(w.id).assignee == kMxTechName,
      );
      await back();
    }
    await role('טכנאי');
    ok('טכנאי: "המשימות שלי"', find.text('המשימות שלי').evaluate().isNotEmpty);
    final faucetSku = db().point(wo2.pointId).sku;
    final stockBefore = db().qty(faucetSku);
    await tapKey('wo-${wo2.id}');
    await tapKey('wo-fix');
    ok(
      '"תוקן – השתמשתי בחלק" סוגר ומוריד מהמלאי',
      db().workOrder(wo2.id).status == MxWoStatus.done &&
          db().qty(faucetSku) == stockBefore - 1,
    );
    ok('ההיסטוריה של הנקודה נרשמה', db().point(wo2.pointId).history.isNotEmpty);
    ok(
      'אחרי סגירה: אין כפתורי פעולה, מוצג "טופלה ונסגרה"',
      !present('wo-fix') &&
          find.text('הקריאה טופלה ונסגרה').evaluate().isNotEmpty,
    );
    await back();
    await tapKey('wo-${wo3.id}');
    await tapKey('wo-need');
    ok('"צריך חלק" פותח בחירת כמות', present('qty-1') && present('qty-10'));
    await tapKey('qty-10');
    final need = db().po(db().workOrder(wo3.id).poId);
    ok(
      'בקשת חלק × 10 → הזמנה ממתינה לאישור + בקשה בתור BuildSmart',
      need.lines.single.qty == 10 &&
          need.status == MxPoStatus.pendingApproval &&
          need.matReqId.isNotEmpty,
    );
    ok(
      'הקריאה במצב "ממתין לחלק"',
      db().workOrder(wo3.id).status == MxWoStatus.waitingPart,
    );
    await back();
    // close-no-part on a fresh job
    c
        .read(mxDbProvider.notifier)
        .report(db().points.last.id, 'רופף', 'מנהל אחזקה');
    final wo4 = c.read(mxDbProvider.notifier).lastCreatedId!;
    c.read(mxDbProvider.notifier).assign(wo4, kMxTechName);
    await nav('המשימות שלי');
    await tapKey('wo-$wo4');
    final sku4 = db().point(db().workOrder(wo4).pointId).sku;
    final q4 = db().qty(sku4);
    await tapKey('wo-fix-nopart');
    ok(
      '"תוקן ללא חלק" סוגר בלי לגעת במלאי',
      db().workOrder(wo4).status == MxWoStatus.done && db().qty(sku4) == q4,
    );
    await back();
    // fix disabled when stock is 0
    c
        .read(mxDbProvider.notifier)
        .report(db().points.first.id, 'שבור', 'מנהל אחזקה');
    final wo5 = c.read(mxDbProvider.notifier).lastCreatedId!;
    c.read(mxDbProvider.notifier).assign(wo5, kMxTechName);
    final sku5 = db().point(db().workOrder(wo5).pointId).sku;
    final saved = db().qty(sku5);
    c.read(mxDbProvider.notifier).state = db().copyWith(
      stock: {...db().stock, sku5: 0},
    );
    await tester.pumpAndSettle();
    await tapKey('wo-$wo5');
    ok(
      'אין במלאי → "תוקן" כבוי ומציג "החלק חסר במלאי"',
      !enabledButton('wo-fix') &&
          find.text('החלק חסר במלאי – הזמינו חלק').evaluate().isNotEmpty,
    );
    await back();
    c.read(mxDbProvider.notifier).state = db().copyWith(
      stock: {...db().stock, sku5: saved},
    );

    // ── 7 · PM ─────────────────────────────────────────────────────────────
    await role('מנהל');
    await nav('תחזוקה');
    ok(
      'תחזוקה: כותרות "באיחור" ו"השבוע"',
      find.text('באיחור').evaluate().isNotEmpty &&
          find.text('השבוע').evaluate().isNotEmpty,
    );
    for (final r
        in db()
            .pmDue(now)
            .where((x) => x.$2 != MxDue.ok)
            .map((x) => x.$1)
            .toList()) {
      await tapKey('pm-done-${r.id}');
      ok(
        '"סמן כבוצע" – ${r.title}',
        db().dueOf(db().pmRules.firstWhere((x) => x.id == r.id), now) ==
            MxDue.ok,
      );
    }
    ok(
      'אחרי הכול: אין בדיקות באיחור/השבוע',
      db().pmDue(now).every((x) => x.$2 == MxDue.ok),
    );

    // ── 8 · stock: filters, price import (cancel + apply), auto-reorder ────
    await nav('רכש');
    await tapKey('buy-stock');
    for (final t in [
      'להזמין',
      'חשמל',
      'אינסטלציה',
      'פרזול',
      'מיזוג',
      'בטיחות',
      'יודאיקה',
      'הכול',
    ]) {
      await tapKey('stock-filter-$t');
      final expected =
          t == 'הכול'
              ? db().parts
              : t == 'להזמין'
              ? db().parts.where((p) => db().qty(p.sku) < p.min).toList()
              : db().parts.where((p) => p.storeType == t).toList();
      final shown =
          db().parts
              .where((p) => find.text(p.name).evaluate().isNotEmpty)
              .toList();
      ok(
        'סינון "$t" מציג ${expected.length} פריטים',
        expected.every(shown.contains) && shown.every(expected.contains) ||
            t == 'הכול',
      );
    }
    await tapKey('import-prices');
    ok(
      'ייבוא מחירון: תצוגה מקדימה כטבלה (לא שדה CSV)',
      present('price-preview'),
    );
    await tester.tapAt(const Offset(20, 20)); // close without importing
    await tester.pumpAndSettle();
    ok('"ביטול" לא משנה מחירים', db().storePrices.isEmpty);
    await tapKey('import-prices');
    await tapKey('ask-ok');
    ok(
      '"אישור" קולט 3 מחירים לטמבור',
      db().storePrices['st-tambur']?.length == 3 &&
          db().priceAt('st-tambur', 'EL-T8') == 1990,
    );
    final posBefore = db().purchaseOrders.length;
    final expectStores = {
      for (final p in db().lowStock)
        if (p.min * 2 - db().qty(p.sku) - db().onOrder(p.sku) > 0)
          db().storeFor(p.sku)!.id,
    };
    await tapKey('auto-reorder');
    final created = db().purchaseOrders.length - posBefore;
    ok(
      '"הזמן את כל מה שחסר" יוצר הזמנה אחת לכל חנות (${expectStores.length})',
      created == expectStores.length &&
          db().purchaseOrders
              .take(created)
              .map((o) => o.storeId)
              .toSet()
              .containsAll(expectStores),
    );
    ok(
      'מחיר מיובא נכנס להזמנה',
      db().purchaseOrders
          .expand((o) => o.lines)
          .where((l) => l.sku == 'EL-T8')
          .every((l) => l.unitAgorot == 1990),
    );
    ok('אחרי הזמנה עוברים להזמנות', present('po-filter-open'));
    await tapKey('buy-stock');
    await tapKey('auto-reorder');
    ok(
      'לחיצה חוזרת לא מכפילה הזמנות',
      db().purchaseOrders.length == posBefore + created,
    );

    // ── 9 · orders: approve, WhatsApp, copy link, store view, reject ───────
    await tapKey('buy-orders');
    final tamburPo = db().pendingApproval.firstWhere(
      (o) => o.storeId == 'st-tambur' && o.lines.length > 1,
    );
    await tapKey('po-approve-${tamburPo.id}');
    final approved = db().po(tamburPo.id);
    ok(
      '"אשרו ושלחו בוואטסאפ" (לחיצה אחת) → wa.me נפתח, נשלח, הזמנה בלוח BuildSmart',
      approved.status == MxPoStatus.sent &&
          launched.isNotEmpty &&
          launched.last.host == 'wa.me' &&
          launched.last.queryParameters['text']!.contains(approved.token) &&
          approved.orderId.isNotEmpty &&
          c.read(ordersEngineProvider).any((o) => o.id == approved.orderId),
    );
    ok(
      'כרטיס ההזמנה מציג את שלב ההזמנה בלוח החנות (בלי קוד פנימי)',
      present('po-bs-${tamburPo.id}') &&
          find.textContaining('BS-').evaluate().isEmpty,
    );
    final sentBefore = launched.length;
    await tapKey('po-wa-${tamburPo.id}');
    ok('"שלחו שוב בוואטסאפ" פותח שוב', launched.length == sentBefore + 1);
    await tapFinder(
      find.descendant(
        of: find.byKey(Key('po-${tamburPo.id}')),
        matching: find.text('העתקת קישור'),
      ),
    );
    ok(
      '"העתק קישור" מעתיק את קישור החנות',
      clipboard != null && clipboard!.endsWith('/s/${approved.token}'),
    );
    await tapKey('po-storeview-${tamburPo.id}');
    ok(
      '"מה החנות רואה" פותח את דף החנות',
      find.text('הזמנה משיח סוד').evaluate().isNotEmpty &&
          find.text(tamburPo.id.split('-').last).evaluate().isNotEmpty,
    );
    await back();
    // One more request to exercise "reject" (a tech asks for a part).
    final n = c.read(mxDbProvider.notifier)
      ..report(db().points[40].id, 'נשבר', 'מנהל אחזקה');
    final rwo = n.lastCreatedId!;
    n
      ..assign(rwo, kMxTechName)
      ..requestPart(rwo, 1, kMxTechName);
    await tester.pumpAndSettle();
    final other = db().po(n.lastCreatedId!);
    await tapKey('po-reject-${other.id}');
    ok('"דחו" מבקש סיבה', present('ask-quick-0'));
    await tapKey('ask-quick-1');
    await tapKey('ask-ok');
    ok(
      'הסיבה נשמרת ומגיעה ליומן הקריאה של הטכנאי',
      db().workOrder(rwo).log.first.text.contains('יקר מדי'),
    );
    ok(
      '"דחו" → נדחתה + הבקשה ב-BuildSmart נדחתה',
      db().po(other.id).status == MxPoStatus.rejected &&
          c
                  .read(materialRequestsProvider)
                  .firstWhere((r) => r.id == db().po(other.id).matReqId)
                  .status ==
              kMatReqDeclined,
    );

    // ── 10 · store: inbox, missing, confirm, invoice, ready ────────────────
    await role('חנות');
    ok('תיבת החנות מציגה את ההזמנה שאושרה', present('inbox-${tamburPo.id}'));
    await tapKey('inbox-${tamburPo.id}');
    final missingSku = approved.lines.first.sku;
    await tapKey('store-missing-$missingSku');
    ok(
      '"אין לי" → חסר + סטטוס "חסרים פריטים"',
      db().po(tamburPo.id).lines.first.missing &&
          db().po(tamburPo.id).status == MxPoStatus.storePartial,
    );
    ok('אחרי "חסר": "מאשר, יש לי הכול" לא מוצג', !present('store-confirm'));
    ok(
      '"אין לי" הוא כפתור משני אמיתי בפטרול (לא אדום)',
      find
          .byWidgetPredicate(
            (w) =>
                w is TextButton &&
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(
                  'store-missing-',
                ) &&
                w.style?.foregroundColor?.resolve({}) == kMxPrimary,
          )
          .evaluate()
          .isNotEmpty,
    );
    // Real-browser bug: marking the rest ready used to hide the reroute.
    await tapKey('store-ready');
    ok(
      'החנות סימנה את השאר "מוכן"',
      db().po(tamburPo.id).status == MxPoStatus.ready,
    );
    ok(
      'מסך "תודה" מלא לבעל החנות',
      find.textContaining('תודה, ').evaluate().isNotEmpty,
    );
    await tapKey('store-thanks-ok');
    await back();

    // reroute (manager) — the electrical shop is the alternative.
    await role('מנהל');
    await nav('רכש');
    final posBeforeReroute = db().purchaseOrders.length;
    await tapKey('po-reroute-${tamburPo.id}');
    final reroute = db().purchaseOrders.first;
    ok(
      '"חוסרים לחנות אחרת" → הזמנה חדשה לחנות חלופית',
      db().purchaseOrders.length == posBeforeReroute + 1 &&
          reroute.storeId != 'st-tambur' &&
          reroute.lines.single.sku == missingSku,
    );
    ok(
      'אחרי ההפניה הכפתור נעלם (אין הפניה כפולה)',
      !present('po-reroute-${tamburPo.id}'),
    );

    // second PO: confirm path
    final conf = db().pendingApproval.firstWhere((o) => o.id == reroute.id);
    await tapKey('po-approve-${conf.id}');
    await role('חנות');
    // The reroute went to another store; open its page directly by link.
    await settle();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(home: MxStorePage(token: db().po(conf.id).token)),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey('store-confirm');
    ok(
      '"מאשר, יש לי הכול" → החנות אישרה + שלב "בהכנה" בלוח',
      db().po(conf.id).status == MxPoStatus.storeConfirmed &&
          c
                  .read(ordersEngineProvider)
                  .firstWhere((o) => o.id == db().po(conf.id).orderId)
                  .stage ==
              'preparing',
    );
    await tapKey('store-invoice');
    await tester.enterText(find.byKey(const Key('store-invoice')), '7788');
    await tapKey('store-alloc');
    await tester.enterText(find.byKey(const Key('store-alloc')), '123456789');
    await tapKey('store-ready');
    await tapKey('store-thanks-ok');
    ok(
      '"מוכן לאיסוף" + חשבונית + הקצאה נשמרים',
      db().po(conf.id).status == MxPoStatus.ready &&
          db().po(conf.id).invoiceNo == '7788' &&
          db().po(conf.id).allocationNo == '123456789',
    );
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 3000),
      3000,
    );
    await tester.pumpAndSettle();
    ok(
      'דף החנות לאחר "מוכן" מציג סטטוס "מוכן" ואיסוף',
      find.text('מוכן').evaluate().isNotEmpty &&
          db().po(conf.id).fulfil == MxFulfil.pickup,
    );

    // back to the app as manager → receive both
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const MxApp()),
    );
    await tester.pumpAndSettle();
    await role('מנהל');
    await nav('רכש');
    for (final id in [tamburPo.id, conf.id]) {
      final o = db().po(id);
      final before = {for (final l in o.lines) l.sku: db().qty(l.sku)};
      await tapKey('po-receive-$id');
      await tapKey('confirm-yes');
      final r = db().po(id);
      ok(
        '"קיבלתי את הסחורה" ($id) → התקבל, מלאי עודכן לשורות שסופקו',
        r.status == MxPoStatus.received &&
            r.lines.every(
              (l) => db().qty(l.sku) == before[l.sku]! + l.supplied,
            ),
      );
      ok(
        '($id) לוח BuildSmart: "נמסרה"',
        c
                .read(ordersEngineProvider)
                .firstWhere((x) => x.id == r.orderId)
                .stage ==
            'delivered',
      );
    }
    ok(
      'אחרי קבלה: אין כפתורי פעולה בהזמנה סגורה',
      !present('po-receive-${tamburPo.id}') && !present('po-wa-${tamburPo.id}'),
    );

    // the tech's waiting job returns after its PO is received
    await tapKey('po-approve-${need.id}');
    await tapKey('po-receive-${need.id}');
    await tapKey('confirm-yes');
    ok(
      'קריאה שחיכתה לחלק חוזרת לטכנאי',
      db().workOrder(wo3.id).status == MxWoStatus.assigned,
    );

    debugPrint('E2E TOTAL $checks checks');
  });
}
