// Guard for `cardFilterStateProvider` — the pure mutation behaviour.
// Persistence is dependency-injected via SharedPreferences (real prefs are
// covered by integration). We exercise set/get/clear semantics + the empty
// auto-clear invariant + JSON round-trip.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buildsmart/state/card_filter_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('cardFilterStateProvider', () {
    test('starts empty', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cardFilterStateProvider), isEmpty);
    });

    test('setType then setSize accumulates on the same product', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(cardFilterStateProvider.notifier).setType('faucet', 'מטבח');
      c.read(cardFilterStateProvider.notifier).setSize('faucet', '1/2"');
      final f = c.read(cardFilterStateProvider)['faucet']!;
      expect(f.type, 'מטבח');
      expect(f.size, '1/2"');
    });

    test('setType=null with no size auto-clears the entry', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(cardFilterStateProvider.notifier).setType('x', 'a');
      expect(c.read(cardFilterStateProvider).containsKey('x'), isTrue);
      c.read(cardFilterStateProvider.notifier).setType('x', null);
      expect(c.read(cardFilterStateProvider).containsKey('x'), isFalse);
    });

    test('setType=null preserves size if size is still set', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(cardFilterStateProvider.notifier).setType('x', 'a');
      c.read(cardFilterStateProvider.notifier).setSize('x', 's');
      c.read(cardFilterStateProvider.notifier).setType('x', null);
      final f = c.read(cardFilterStateProvider)['x']!;
      expect(f.type, isNull);
      expect(f.size, 's');
    });

    test('clear() drops the entry', () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(cardFilterStateProvider.notifier).setType('y', 'z');
      c.read(cardFilterStateProvider.notifier).clear('y');
      expect(c.read(cardFilterStateProvider).containsKey('y'), isFalse);
    });

    test('JSON round-trip is faithful', () {
      const f = CardFilterSelection(type: 'מטבח', size: '1/2"');
      final j = f.toJson();
      final r = CardFilterSelection.fromJson(j);
      expect(r.type, f.type);
      expect(r.size, f.size);
    });

    test('JSON drops null fields', () {
      const f = CardFilterSelection(type: 'מטבח');
      expect(f.toJson().containsKey('s'), isFalse);
      expect(f.toJson()['t'], 'מטבח');
    });
  });
}
