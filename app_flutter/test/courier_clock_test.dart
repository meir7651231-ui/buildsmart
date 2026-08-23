// Guard tests for #86 F-10 · the courier delivery clock — BOTH sides of the
// bs.courier-clock.v1 side-map contract:
//   writer: stampCourierClock (lib/state/courier_clock.dart) — stamps
//           pickedUpAt (pickup→transit) / deliveredAt (transit→delivered)
//           at the courierAdvance moments;
//   reader: courierClockProvider (lib/screens/courier_reports_tab.dart) —
//           the reports tab's read-only view of the same key.
// Covered: writer→reader round-trip (the reader parses the writer's exact
// bytes), write-once semantics (an existing valid stamp is never re-stamped),
// the corrupt-payload paths on both sides (reader → {} honestly, writer
// repairs the key instead of crashing), foreign-field preservation
// (attempts / the other advance point's stamp), and the no-flags no-op.
import 'dart:convert';

import 'package:buildsmart/screens/courier_reports_tab.dart'
    show courierClockProvider, kCourierClockKey;
import 'package:buildsmart/state/courier_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'round-trip — שתי החותמות של הכותב נקראות אחת-לאחת ע"י '
      'courierClockProvider של טאב-הדוחות', () async {
    SharedPreferences.setMockInitialValues({});
    expect(kCourierClockKey, 'bs.courier-clock.v1',
        reason: 'the shared side-map key is part of the contract');

    await stampCourierClock('BS-1040', pickedUp: true);
    // Real wall-clock gap so deliveredAt is strictly after pickedUpAt.
    await Future<void>.delayed(const Duration(milliseconds: 15));
    await stampCourierClock('BS-1040', delivered: true);

    // Byte-level: the writer's payload is exactly the documented contract —
    // ISO-8601 strings under the reader's key, and NO attempts field (the
    // reader treats absent as 1; F-10 ADJUST — אין המצאות).
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCourierClockKey);
    expect(raw, isNotNull, reason: 'writer and reader must share ONE key');
    final entryJson =
        (jsonDecode(raw!) as Map<String, dynamic>)['BS-1040'] as Map;
    expect(DateTime.tryParse('${entryJson['pickedUpAt']}'), isNotNull,
        reason: 'pickedUpAt is written as a parseable ISO-8601 string');
    expect(DateTime.tryParse('${entryJson['deliveredAt']}'), isNotNull,
        reason: 'deliveredAt is written as a parseable ISO-8601 string');
    expect(entryJson.containsKey('attempts'), isFalse,
        reason: 'attempts is never invented by the writer');

    // Reader-level: the reports tab provider decodes the same bytes.
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final clock = await c.read(courierClockProvider.future);
    final entry = clock['BS-1040'];
    expect(entry, isNotNull, reason: 'the reader sees the stamped order');
    expect(entry!.pickedUpAt, isNotNull);
    expect(entry.deliveredAt, isNotNull);
    expect(entry.attempts, isNull,
        reason: 'absent attempts stays null (the reader defaults it to 1)');
    expect(entry.pickupToDelivered, isNotNull,
        reason: 'ordered stamps expose the pickup→delivered duration');
    expect(entry.pickupToDelivered!.inMicroseconds, greaterThan(0));
    expect(entry.deliveredAt!.isAfter(entry.pickedUpAt!), isTrue,
        reason: 'the stamps preserve the real advance order');
  });

  test('write-once — חותמת קיימת לעולם לא נדרסת בקריאה כפולה', () async {
    SharedPreferences.setMockInitialValues({});
    await stampCourierClock('o1', pickedUp: true);
    final prefs = await SharedPreferences.getInstance();
    String stampOf(String field) =>
        '${(jsonDecode(prefs.getString(kCourierClockKey)!) as Map<String, dynamic>)['o1'][field]}';
    final firstPickedUp = stampOf('pickedUpAt');

    // A later double-call would write a DIFFERENT iso string if it re-stamped.
    await Future<void>.delayed(const Duration(milliseconds: 15));
    await stampCourierClock('o1', pickedUp: true);
    expect(stampOf('pickedUpAt'), firstPickedUp,
        reason: 'the first honest wall-clock capture must be preserved');

    await stampCourierClock('o1', delivered: true);
    final firstDelivered = stampOf('deliveredAt');
    await Future<void>.delayed(const Duration(milliseconds: 15));
    await stampCourierClock('o1', pickedUp: true, delivered: true);
    expect(stampOf('deliveredAt'), firstDelivered,
        reason: 'deliveredAt is write-once too');
    expect(stampOf('pickedUpAt'), firstPickedUp,
        reason: 'a combined re-stamp call overwrites neither stamp');
  });

  test('payload פגום — הקורא מחזיר {} בכנות והכותב לא קורס אלא מתקן את המפתח',
      () async {
    SharedPreferences.setMockInitialValues({kCourierClockKey: '{not json'});

    // Reader side: honest "no measurements" — never a throw.
    final c1 = ProviderContainer();
    expect(await c1.read(courierClockProvider.future), isEmpty,
        reason: 'a corrupt side-map reads as zero measurements');
    c1.dispose();

    // Writer side: completes without throwing, repairs the key.
    await stampCourierClock('BS-X', pickedUp: true);
    final prefs = await SharedPreferences.getInstance();
    final m = jsonDecode(prefs.getString(kCourierClockKey)!)
        as Map<String, dynamic>;
    expect(DateTime.tryParse('${(m['BS-X'] as Map)['pickedUpAt']}'), isNotNull,
        reason: 'the stamp after the repair is a valid ISO-8601 string');

    // And the reader decodes the repaired key.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    final clock = await c2.read(courierClockProvider.future);
    expect(clock['BS-X']?.pickedUpAt, isNotNull,
        reason: 'after the repair the reader sees the fresh stamp');
  });

  test('entry קיים נשמר — חותמת delivered לא מוחקת pickedUpAt/attempts זרים',
      () async {
    SharedPreferences.setMockInitialValues({
      kCourierClockKey: jsonEncode({
        'o9': {'pickedUpAt': '2026-06-01T08:00:00.000', 'attempts': 7},
      }),
    });
    await stampCourierClock('o9', delivered: true);

    final prefs = await SharedPreferences.getInstance();
    final entry = (jsonDecode(prefs.getString(kCourierClockKey)!)
        as Map<String, dynamic>)['o9'] as Map;
    expect(entry['pickedUpAt'], '2026-06-01T08:00:00.000',
        reason: 'the stamp written by another advance point is preserved '
            'byte-for-byte');
    expect(entry['attempts'], 7,
        reason: 'a future failed-attempt count must survive the merge');
    expect(DateTime.tryParse('${entry['deliveredAt']}'), isNotNull,
        reason: 'only OUR stamp was added');

    // The reader exposes all three through CourierClockEntry.
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final read = (await c.read(courierClockProvider.future))['o9'];
    expect(read, isNotNull);
    expect(read!.pickedUpAt, DateTime.parse('2026-06-01T08:00:00.000'));
    expect(read.attempts, 7);
    expect(read.deliveredAt, isNotNull);
  });

  test('חותמת קיימת לא-חוקית מוחלפת בחותמת אמת; entry בלי אף חותמת חוקית מושמט',
      () async {
    SharedPreferences.setMockInitialValues({
      kCourierClockKey: jsonEncode({
        'o2': {'pickedUpAt': 'garbage'},
      }),
    });

    // Reader: an entry with no parseable stamp is dropped (honest empty map).
    final c1 = ProviderContainer();
    expect(await c1.read(courierClockProvider.future), isEmpty,
        reason: 'an unparsable-only entry is not a measurement');
    c1.dispose();

    // Writer: 'garbage' is absent-equivalent — a real stamp replaces it
    // (write-once protects only VALID stamps).
    await stampCourierClock('o2', pickedUp: true);
    final prefs = await SharedPreferences.getInstance();
    final entry = (jsonDecode(prefs.getString(kCourierClockKey)!)
        as Map<String, dynamic>)['o2'] as Map;
    expect(DateTime.tryParse('${entry['pickedUpAt']}'), isNotNull,
        reason: 'an unparsable stamp is not write-once-locked');
  });

  test('קריאה בלי דגלים היא no-op — המפתח לא נוצר כלל', () async {
    SharedPreferences.setMockInitialValues({});
    await stampCourierClock('o1'); // neither pickedUp nor delivered
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(kCourierClockKey), isNull,
        reason: 'nothing to stamp → nothing written');
  });
}
