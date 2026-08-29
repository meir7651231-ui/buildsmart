// Guard tests for #86.2-4 · courier HR — lib/state/courier_hr.dart.
// The courier reuses the worker NOTIFIERS re-keyed to its own versioned
// bs.courier-*.v1 storage (the F-7 `storageKey` ctor seam). The contract
// under test: the three courier providers write ONLY to the courier keys and
// never pollute the worker ledgers — with the SAME username ('demo' is
// shared across every board, the exact leak the separate keys prevent) —
// plus the courier constants the screens rely on (the 3 cert preset chips
// and the attendance-report chat thread that must exist in the seed).
import 'dart:convert';

import 'package:buildsmart/data/chat_seeds.dart' show kChatThreads;
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/state/sys_chat.dart' show BsRole;
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 60));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('המפתחות courier-scoped, מגורסים v1, ושונים ממפתחות העובד', () {
    expect(kCourierAttendanceKey, 'bs.courier-attendance.v1');
    expect(kCourierFormsKey, 'bs.courier-forms.v1');
    expect(kCourierCertsKey, 'bs.courier-certs.v1');
    final all = {
      kCourierAttendanceKey,
      kCourierFormsKey,
      kCourierCertsKey,
      kWorkerAttendanceKey,
      kWorkerFormsKey,
      kWorkerCertsKey,
    };
    expect(all.length, 6,
        reason: 'no courier key may collide with another courier key or '
            'with a worker key — separate keys are the whole isolation');
  });

  test(
      'נוכחות — clockIn של שליח demo נכתב ל-bs.courier-attendance.v1 בלבד '
      'ולא דולף לעובד (אותו username!)', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(courierAttendanceProvider.notifier).clockIn('demo'), true);
    await _settle(); // let _persist() land

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCourierAttendanceKey);
    expect(raw, isNotNull, reason: 'the courier ledger must persist');
    final list = jsonDecode(raw!) as List;
    expect(list, hasLength(1));
    expect((list.single as Map)['username'], 'demo');
    expect(prefs.getString(kWorkerAttendanceKey), isNull,
        reason: 'a courier clock-in must never touch the worker ledger');

    // Same container, same username — the WORKER provider stays empty.
    c.read(workerAttendanceProvider); // lazy — start its _load()
    await _settle();
    expect(c.read(workerAttendanceProvider), isEmpty,
        reason: 'demo-the-courier must not appear in demo-the-worker\'s '
            'attendance');
    expect(c.read(workerAttendanceProvider.notifier).todayFor('demo'), isNull);
  });

  test('נוכחות — הכיוון ההפוך: clockIn עובד demo לא מופיע אצל השליח', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(workerAttendanceProvider.notifier).clockIn('demo'), true);
    await _settle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kWorkerAttendanceKey), isNotNull);
    expect(prefs.getString(kCourierAttendanceKey), isNull,
        reason: 'a worker clock-in must never touch the courier ledger');

    c.read(courierAttendanceProvider);
    await _settle();
    expect(c.read(courierAttendanceProvider), isEmpty,
        reason: 'demo-the-worker must not appear in demo-the-courier\'s '
            'attendance');
    expect(
        c.read(courierAttendanceProvider.notifier).todayFor('demo'), isNull);
  });

  test('ספר הנוכחות של השליח נטען חזרה מה-courier key (ריסטרט מדומה)',
      () async {
    SharedPreferences.setMockInitialValues({
      kCourierAttendanceKey: jsonEncode([
        AttendanceDay(
          username: 'demo',
          date: '2026-06-01',
          inTs: DateTime(2026, 6, 1, 8),
          outTs: DateTime(2026, 6, 1, 17),
        ).toJson(),
      ]),
    });
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(courierAttendanceProvider); // lazy — start both _load()s
    c.read(workerAttendanceProvider);
    await _settle();

    expect(c.read(courierAttendanceProvider), hasLength(1),
        reason: 'the courier provider hydrates from ITS key');
    expect(c.read(courierAttendanceProvider).single.username, 'demo');
    expect(c.read(courierAttendanceProvider).single.worked,
        const Duration(hours: 9));
    expect(c.read(workerAttendanceProvider), isEmpty,
        reason: 'the seeded courier ledger must not hydrate the worker '
            'provider — same username, different key');
  });

  test('טפסים — saveForm101 של שליח נכתב ל-bs.courier-forms.v1 בלבד',
      () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    c.read(courierFormsProvider.notifier).saveForm101(Form101(
          username: 'demo',
          year: 2026,
          fullName: 'שליח דמו',
          idNumber: '012345678',
          phone: '0501234567',
          specialty: 'שליחויות',
          maritalStatus: 'רווק/ה',
          savedTs: DateTime.now(),
        ));
    await _settle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kCourierFormsKey), isNotNull,
        reason: 'the courier forms store must persist under its own key');
    expect(prefs.getString(kWorkerFormsKey), isNull,
        reason: 'a courier 101 form must never touch the worker store');

    expect(c.read(courierFormsProvider).form101For('demo', 2026), isNotNull);
    c.read(workerFormsProvider); // lazy — same container, same username
    await _settle();
    expect(c.read(workerFormsProvider).forms, isEmpty);
    expect(c.read(workerFormsProvider).form101For('demo', 2026), isNull,
        reason: 'demo-the-courier\'s 101 must not appear for '
            'demo-the-worker');
  });

  test('תעודות — add של שליח נכתב ל-bs.courier-certs.v1 בלבד', () async {
    SharedPreferences.setMockInitialValues({});
    final c = ProviderContainer();
    addTearDown(c.dispose);

    final cert = await c.read(courierCertsProvider.notifier).add(
          username: 'demo',
          name: kCourierCertPresets.first, // the preset chip pre-fills NAME
          issuer: 'משרד התחבורה',
          expiry: DateTime(2027, 1, 1),
        );
    expect(cert, isNotNull, reason: 'a healthy add reports the created cert');
    await _settle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kCourierCertsKey), isNotNull,
        reason: 'the courier wallet must persist under its own key');
    expect(prefs.getString(kWorkerCertsKey), isNull,
        reason: 'a courier cert must never touch the worker wallet');

    expect(c.read(courierCertsProvider), hasLength(1));
    expect(c.read(courierCertsProvider).single.username, 'demo');
    c.read(workerCertsProvider); // lazy — same container, same username
    await _settle();
    expect(c.read(workerCertsProvider), isEmpty,
        reason: 'demo-the-courier\'s cert never leaks into '
            'demo-the-worker\'s wallet');
  });

  test('kCourierCertPresets — בדיוק 3 צ׳יפים, שמות-בלבד, בלי כפילויות', () {
    expect(kCourierCertPresets, hasLength(3));
    expect(kCourierCertPresets, ['רישיון נהיגה', 'ביטוח רכב', 'רישיון רכב']);
    expect(kCourierCertPresets.toSet(), hasLength(3),
        reason: 'preset chips must be distinct');
    for (final p in kCourierCertPresets) {
      expect(p.trim(), isNotEmpty);
      expect(p.trim(), p, reason: 'no stray whitespace in a chip label');
    }
  });

  test(
      'kCourierAttendanceReportThreadId — th-store-courier-pickups קיים '
      'ב-kChatThreads עם audience "store" ושני המשתתפים הנכונים', () {
    expect(kCourierAttendanceReportThreadId, 'th-store-courier-pickups');
    final matches = kChatThreads
        .where((t) => t.id == kCourierAttendanceReportThreadId)
        .toList();
    expect(matches, hasLength(1),
        reason: 'send() is a silent no-op on an unknown thread — the '
            'report target must exist (exactly once) in the seed');
    final t = matches.single;
    expect(t.audience, 'store',
        reason: 'the report lands in the SUPPLIER\'s chat tab (#86.2), '
            'not the contractor\'s');
    expect(t.participants, contains(BsRole.store));
    expect(t.participants, contains(BsRole.courier),
        reason: 'the courier sees the thread via the F-25 store↔courier '
            'audience pairing');
  });
}
