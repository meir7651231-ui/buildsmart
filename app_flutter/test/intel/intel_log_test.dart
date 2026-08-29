// Studio Pillar 3 · step 88 — the IntelLogNotifier in-memory ring buffer.
//
// PROVED HERE (§5), in the style of test/analytics_log_test.dart:
//   1. record → newest-first order (the cloned analytics_log trim);
//   2. trim-to-cap under synthetic load: length stays == cap, the OLDEST are
//      dropped and the newest `cap` survive (§8 DoD — cap enforced under load);
//   3. recent({name}) filters by name; recent({since}) filters by time window;
//      recent({name, since}) composes both — all newest-first (§6);
//   4. countByName() tallies per name (KPI tiles, §10);
//   5. clear() empties the buffer (§9 erasure);
//   6. intelLogProvider exposes the buffer the bus (step 89) will record into;
//   7. GREP-STYLE guard: the source carries NO persistence layer — never a
//      disk / key-value / durable write (§4, §8 — the payload may be sensitive
//      so it must live in RAM only).
import 'dart:io';

import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Build an event with a real name + optional timestamp / props.
IntelEvent _ev(
  String name, {
  DateTime? at,
  Map<String, String> props = const <String, String>{},
}) =>
    IntelEvent(name: name, at: at ?? DateTime.now(), props: props);

void main() {
  test('starts empty; countByName is empty', () {
    final n = IntelLogNotifier();
    expect(n.state, isEmpty);
    expect(n.recent(), isEmpty);
    expect(n.countByName(), isEmpty);
  });

  test('record prepends to the FRONT (newest-first — cloned trim)', () {
    final n = IntelLogNotifier();
    n.record(_ev(IntelEvents.sessionStart));
    n.record(_ev(IntelEvents.screenView));
    expect(n.state.first.name, IntelEvents.screenView);
    expect(n.state.last.name, IntelEvents.sessionStart);
    // recent() mirrors the buffer, newest-first.
    expect(n.recent().first.name, IntelEvents.screenView);
  });

  test('trim to cap under load: length == cap, OLDEST dropped, newest survive',
      () {
    const cap = 10;
    const load = cap + 40; // 50 records into a cap-10 buffer.
    final n = IntelLogNotifier(cap: cap);
    for (var i = 0; i < load; i++) {
      n.record(_ev(IntelEvents.screenView, props: <String, String>{'i': '$i'}));
    }
    // cap enforced under synthetic load (§8 DoD).
    expect(n.state.length, cap, reason: 'cap must hold under load');
    // newest-first: the front is the last event recorded (i == load-1).
    expect(n.state.first.props['i'], '${load - 1}');
    // the oldest survivor is i == load-cap; everything older was trimmed.
    expect(n.state.last.props['i'], '${load - cap}');
    expect(
      n.state.any((e) => e.props['i'] == '0'),
      isFalse,
      reason: 'the very oldest event must have been dropped',
    );
    expect(
      n.state.any((e) => e.props['i'] == '${load - cap - 1}'),
      isFalse,
      reason: 'every event older than the newest cap must be gone',
    );
  });

  test('recent({name}) keeps only that name, newest-first', () {
    final n = IntelLogNotifier();
    n.record(_ev(IntelEvents.screenView, props: <String, String>{'k': '1'}));
    n.record(_ev(IntelEvents.addToCart));
    n.record(_ev(IntelEvents.screenView, props: <String, String>{'k': '2'}));
    final r = n.recent(name: IntelEvents.screenView);
    expect(r.length, 2);
    expect(r.every((e) => e.name == IntelEvents.screenView), isTrue);
    expect(r.first.props['k'], '2'); // newest-first
    expect(r.last.props['k'], '1');
  });

  test('recent({since}) keeps only events after the window start', () {
    final n = IntelLogNotifier();
    final base = DateTime.utc(2026, 1, 1, 12);
    n.record(_ev(IntelEvents.screenView, at: base)); // before the window
    n.record(
      _ev(IntelEvents.screenView, at: base.add(const Duration(minutes: 5))),
    );
    n.record(
      _ev(IntelEvents.screenView, at: base.add(const Duration(minutes: 10))),
    );
    final since = base.add(const Duration(minutes: 1));
    final r = n.recent(since: since);
    expect(r.length, 2);
    expect(r.every((e) => e.at.isAfter(since)), isTrue);
    expect(r.first.at, base.add(const Duration(minutes: 10))); // newest-first
  });

  test('recent({name, since}) composes both filters', () {
    final n = IntelLogNotifier();
    final base = DateTime.utc(2026, 1, 1);
    n.record(_ev(IntelEvents.addToCart, at: base)); // wrong name, old
    n.record(_ev(IntelEvents.screenView, at: base)); // right name, old
    n.record(
      _ev(IntelEvents.screenView, at: base.add(const Duration(hours: 2))),
    ); // both match
    n.record(
      _ev(IntelEvents.addToCart, at: base.add(const Duration(hours: 2))),
    ); // wrong name, new
    final r = n.recent(
      name: IntelEvents.screenView,
      since: base.add(const Duration(hours: 1)),
    );
    expect(r.length, 1);
    expect(r.single.name, IntelEvents.screenView);
  });

  test('countByName() tallies per name', () {
    final n = IntelLogNotifier();
    n.record(_ev(IntelEvents.screenView));
    n.record(_ev(IntelEvents.screenView));
    n.record(_ev(IntelEvents.addToCart));
    final counts = n.countByName();
    expect(counts[IntelEvents.screenView], 2);
    expect(counts[IntelEvents.addToCart], 1);
    expect(counts[IntelEvents.orderPlaced], isNull); // absent, not zero
    expect(counts.values.fold<int>(0, (a, b) => a + b), 3);
  });

  test('clear() drops the whole buffer (§9 erasure)', () {
    final n = IntelLogNotifier();
    n.record(_ev(IntelEvents.screenView));
    n.record(_ev(IntelEvents.addToCart));
    n.clear();
    expect(n.state, isEmpty);
    expect(n.recent(), isEmpty);
    expect(n.countByName(), isEmpty);
  });

  test('intelLogProvider exposes the buffer the bus (step 89) records into', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(intelLogProvider), isEmpty);
    container
        .read(intelLogProvider.notifier)
        .record(_ev(IntelEvents.sessionStart));
    expect(container.read(intelLogProvider), hasLength(1));
    expect(container.read(intelLogProvider).first.name, IntelEvents.sessionStart);
  });

  test('the notifier holds NO persistence layer (in-memory only, R1 privacy)',
      () {
    // Grep-style guard mirroring the step-88 DoD: the buffer source must never
    // reference a durable store — the payload may be sensitive and must live in
    // RAM only. (Tests run with the package root as cwd.)
    final src = File('lib/state/intel/intel_log.dart').readAsStringSync();
    // anti-vacuous: prove the file WAS read and `contains` actually works.
    expect(src.contains('IntelLogNotifier'), isTrue);
    const banned = <String>[
      'shared_preferences',
      'SharedPreferences',
      'writeAsString',
      'File(',
      'prefs',
      'dart:io',
    ];
    for (final token in banned) {
      expect(
        src.contains(token),
        isFalse,
        reason: 'intel_log.dart must never persist — found "$token"',
      );
    }
  });
}
