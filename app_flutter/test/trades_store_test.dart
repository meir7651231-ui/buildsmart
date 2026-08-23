// Pins the Pillar-2 authored-trade store (step 34): it starts EMPTY (no published
// trade ⇒ byte-identical), upsert is idempotent (no churn on an unchanged write),
// remove/clear work, and the doc survives a persist→reload round-trip. Fake prefs.
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 10));

const _t = Trade(
  id: 't.elec',
  nameHe: 'חשמל',
  emoji: '⚡',
  color: 0xFF112233,
  personaId: 'p.elec',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts empty (no published trade ⇒ byte-identical)', () async {
    SharedPreferences.setMockInitialValues({});
    final n = TradesStoreNotifier();
    await _settle();
    expect(n.state, TradesDoc.empty);
    expect(n.state.isEmpty, isTrue);
  });

  test('upsertTrade adds; an unchanged upsert is a no-op (idempotent)', () async {
    SharedPreferences.setMockInitialValues({});
    final n = TradesStoreNotifier();
    await _settle();

    n.upsertTrade(_t);
    expect(n.state.trades, [_t]);

    final before = n.state;
    n.upsertTrade(_t); // identical ⇒ no state churn
    expect(identical(n.state, before), isTrue);

    // a real change to the same id replaces in place.
    n.upsertTrade(const Trade(
      id: 't.elec',
      nameHe: 'חשמלאות',
      emoji: '⚡',
      color: 0xFF112233,
      personaId: 'p.elec',
    ));
    expect(n.state.trades.single.nameHe, 'חשמלאות');
  });

  test('removeTrade + clear', () async {
    SharedPreferences.setMockInitialValues({});
    final n = TradesStoreNotifier();
    await _settle();
    n.upsertTrade(_t);
    n.removeTrade('t.elec');
    expect(n.state.trades, isEmpty);
    n
      ..upsertTrade(_t)
      ..clear();
    expect(n.state.isEmpty, isTrue);
  });

  test('persists across a fresh notifier (reload round-trip)', () async {
    SharedPreferences.setMockInitialValues({});
    final a = TradesStoreNotifier();
    await _settle();
    a.upsertTrade(_t);
    await _settle(); // let _persist write

    final b = TradesStoreNotifier();
    await _settle(); // _load reads it back
    expect(b.state.trades, [_t]);
  });
}
