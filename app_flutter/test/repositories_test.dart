// Guards the server-ready seam (T6.2/T6.3): the LOCAL repository impls that the
// app now reads through (orders/customers via the engine; catalog/site/stock via
// the screens). They must stay behavior-identical to the consts (no new data, no
// value change) so the swap-to-backend is drop-in.
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/finance_local.dart';
import 'package:buildsmart/data/repositories/orders_local.dart';
import 'package:buildsmart/data/repositories/site_local.dart';
import 'package:buildsmart/data/repositories/stock_local.dart';
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

  test('catalog repo: allProducts()/catalogCategories() return the live catalog', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(catalogRepositoryProvider);
    expect(repo.allProducts(), isNotEmpty);
    expect(repo.catalogCategories(), isNotEmpty);
  });

  test('finance repo: budgetCategories() non-empty; budgetTotal() == 15000', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(financeRepositoryProvider);
    // Const budget seam stays byte-identical to the seeds (the finance hub
    // depends on the exact total: ₪15,000 → index/ROI/report all derive from it).
    expect(repo.budgetCategories(), isNotEmpty);
    expect(repo.budgetTotal(), 15000);
  });

  test('site repo: projects()/safetyTips() return the seed lists', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(siteRepositoryProvider);
    expect(repo.projects(), isNotEmpty);
    expect(repo.safetyTips(), isNotEmpty);
  });

  test('stock repo: stockDemo() is the 11-item demo map', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final repo = c.read(stockRepositoryProvider) as LocalStockRepository;
    expect(repo.stockDemo().length, 11);
    expect(repo.categoryCounts(), isNotEmpty);
  });
}
