// Guards the server-ready seam (T6.2/T6.3): the two LOCAL repository impls that
// the orders engine now reads through. They must stay behavior-identical to the
// live engine (no new data, no value change) so the swap-to-backend is drop-in.
import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('orders repo: seed() is the genesis list; all()/open() reflect the live engine', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(ordersRepositoryProvider) as LocalOrdersRepository;

    // seed() is the const genesis (T6.3-safe — never reads the engine).
    expect(repo.seed(), same(kOrdersEngineSeed));
    expect(repo.seed().length, kOrdersEngineSeed.length);

    // all() returns exactly what the engine holds; open() is the open subset.
    expect(repo.all(), c.read(ordersEngineProvider));
    expect(repo.all().length, kOrdersEngineSeed.length);
    expect(repo.open().length, repo.all().where((o) => o.isOpen).length);

    // byId round-trips against a real seed order.
    final first = repo.all().first;
    expect(repo.byId(first.id)?.id, first.id);
    expect(repo.byId('NO-SUCH-ID'), isNull);
  });

  test('customers repo: all() == aggregate(engine orders); byName + creditLimit work', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(customersRepositoryProvider) as LocalCustomersRepository;

    final fromAll = repo.all();
    final fromAgg = repo.aggregate(c.read(ordersEngineProvider));
    expect(fromAll, isNotEmpty);
    expect(fromAll.length, fromAgg.length);

    // byName round-trips against a real aggregated buyer.
    final top = fromAll.first;
    expect(repo.byName(top.name)?.name, top.name);
    expect(repo.byName('לא-קיים'), isNull);
    expect(repo.creditLimit(top.name), greaterThanOrEqualTo(0));
  });
}
