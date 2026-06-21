// A13 (launch server-connect) — prove the manager CREDIT display finally
// CONSUMES the `computeCredit` callable seam.
//
// THE GAP this closes (audit MED): A13 wired `computeCredit` end-to-end — the
// Cloud Function, the gateway, and `CustomersRepository.computeCredit` in every
// impl — but NO screen/provider ever called `repo.computeCredit(...)`. The
// manager credit UI still read the SYNC `creditLimit(...)` path, so even with
// `kServerCallables` ON + the functions deployed, credit never routed through
// the server. The customer-detail sheet now watches `customerCreditProvider`
// (a FutureProvider.family over `customersRepositoryProvider.computeCredit`),
// so the seam is REACHED.
//
// WHAT THIS FILE PROVES:
//   1. OPENING a customer detail sheet INVOKES `computeCredit(name)` (the
//      consumer reaches the seam — it is no longer dead);
//   2. flag OFF (default = today + the whole demo/test suite): the rendered
//      `מסגרת אשראי` figure equals the LOCAL derivation, which is BYTE-IDENTICAL
//      to the sync `creditLimit` / `contractorCredit(name)` the dashboard shows
//      today — zero-regression;
//   3. flag ON + a bound gateway: the rendered figure UPGRADES to the
//      SERVER-canonical `creditLimit` the callable returns.
//
// No Firebase: the customers repo is a real [LocalCustomersRepository] (it folds
// the live engine for the local derivation) driven by a hand-rolled fake
// [OrderFunctionsGateway] + the per-repo `serverCallables` field — the same
// define-less ON/OFF pattern as orders_credit_a13_callable_test.dart.

import 'package:buildsmart/data/repositories/customers_local.dart';
import 'package:buildsmart/data/repositories/customers_repository.dart';
import 'package:buildsmart/data/repositories/order_functions.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A hand-rolled fake [OrderFunctionsGateway] — records each `computeCredit`
/// call and returns a configurable server result (or throws). Mirrors the fake
/// in orders_credit_a13_callable_test.dart.
class _FakeFunctions implements OrderFunctionsGateway {
  final List<String> creditCalls = [];
  CreditResult? creditResult;

  @override
  Future<AdvanceStageResult> advanceOrderStage(String orderId) async =>
      AdvanceStageResult(orderId: orderId, from: 'new', to: 'preparing');

  @override
  Future<CreditResult> computeCredit(String name) async {
    creditCalls.add(name);
    return creditResult ??
        CreditResult(
          name: name,
          creditLimit: 100,
          used: 25,
          balance: 75,
          pct: 25,
          orderCount: 1,
        );
  }
}

/// A SPY over a real [LocalCustomersRepository] — records every
/// `computeCredit(name)` the CONSUMER makes and then delegates verbatim. This is
/// the direct proof the credit display REACHES `repo.computeCredit` (the A13
/// seam), independent of the repo's internal flag gate (which, OFF, returns the
/// local figure WITHOUT touching the network gateway — so a gateway spy alone
/// could not prove the consumer reached the seam when OFF).
class _SpyCustomersRepository implements CustomersRepository {
  _SpyCustomersRepository(this._inner);

  final LocalCustomersRepository _inner;

  /// names passed to `computeCredit`, in call order.
  final List<String> computeCreditCalls = [];

  @override
  List<ManagerCustomer> all() => _inner.all();

  @override
  ManagerCustomer? byName(String name) => _inner.byName(name);

  @override
  int creditLimit(String name) => _inner.creditLimit(name);

  @override
  Future<CreditResult> computeCredit(String name) {
    computeCreditCalls.add(name);
    return _inner.computeCredit(name);
  }
}

/// Thousands-grouped integer — mirrors the screen's private `_grouped`
/// (the legacy `toLocaleString()`), so a row's exact `₪…` string can be built.
String _grp(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 8]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  /// Pump the manager dashboard with `customersRepositoryProvider` overridden to
  /// a real [LocalCustomersRepository] carrying the injected flag + fake gateway
  /// (so OFF/ON is controlled without a compile-time define). Returns the fake.
  Future<_FakeFunctions> pump(
    WidgetTester t, {
    required bool serverCallables,
    CreditResult? serverResult,
  }) async {
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final fns = _FakeFunctions()..creditResult = serverResult;
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          customersRepositoryProvider.overrideWith(
            (ref) => LocalCustomersRepository(
              ref,
              serverCallables: serverCallables,
              functions: fns,
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('he'),
          home: ManagerDashboardScreen(),
        ),
      ),
    );
    await settle(t);
    return fns;
  }

  /// Like [pump], but the override is a [_SpyCustomersRepository] wrapping a real
  /// [LocalCustomersRepository] (OFF) — so we can assert the CONSUMER reached
  /// `repo.computeCredit` even when the flag is OFF (the repo then returns the
  /// local figure without a network call, so a gateway spy could not prove it).
  Future<_SpyCustomersRepository> pumpSpy(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 950));
    addTearDown(() => t.binding.setSurfaceSize(null));

    late _SpyCustomersRepository spy;
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          customersRepositoryProvider.overrideWith((ref) {
            // OFF (no serverCallables, no gateway) → byte-identical to today.
            return spy = _SpyCustomersRepository(LocalCustomersRepository(ref));
          }),
        ],
        child: const MaterialApp(
          locale: Locale('he'),
          home: ManagerDashboardScreen(),
        ),
      ),
    );
    await settle(t);
    return spy;
  }

  Future<void> openCustomersTab(WidgetTester t) async {
    await t.tap(find.text('לקוחות').first);
    await settle(t);
  }

  // The top seed buyer by spend (BS-1040, spend 3150) — its card is reliably
  // present and its credit ceiling is the deterministic `contractorCredit`.
  const buyer = 'משה אברהם';

  group('A13 · manager credit display CONSUMES computeCredit', () {
    testWidgets(
      'OFF (default): opening the detail sheet INVOKES computeCredit and renders '
      'the LOCAL ceiling — byte-identical to the sync creditLimit (today)',
      (t) async {
        final spy = await pumpSpy(t);
        await openCustomersTab(t);

        await t.tap(find.text(buyer));
        await settle(t);

        // The sheet's credit rows are on screen.
        expect(find.text('מסגרת אשראי'), findsOneWidget);

        // PROOF 1 — the consumer REACHED the seam: the detail sheet called
        // `repo.computeCredit(buyer)` (it was previously never called from
        // anywhere — the dead seam the audit flagged is now reachable).
        expect(
          spy.computeCreditCalls,
          contains(buyer),
          reason:
              'A13: the credit display now routes through repo.computeCredit '
              '(the seam is reachable — no longer dead)',
        );

        // PROOF 2 — OFF = zero-regression: the rendered ceiling equals the LOCAL
        // derivation, which is byte-identical to the sync path the dashboard
        // shows today (`creditLimit == contractorCredit(name)`). The OFF path
        // returns this WITHOUT any network call.
        final localCeiling = contractorCredit(buyer);
        expect(
          find.text('₪${_grp(localCeiling)}'),
          findsWidgets,
          reason: 'OFF: the ceiling is the local figure == today',
        );
      },
    );

    testWidgets(
      'OFF: rendering the customers LIST (no card tap) ALREADY reaches '
      'computeCredit — the list card consumes the live seam, not the seed',
      (t) async {
        final spy = await pumpSpy(t);
        await openCustomersTab(t);

        // No tap. The wave-2b fix makes _CustomerCard itself watch
        // `customerCreditProvider`, so the LIST (the first thing the manager
        // sees) reaches `repo.computeCredit` on render. Before, only the detail
        // sheet did, so the list showed the fabricated `contractorCredit` seed
        // ceiling that never updates from the server.
        expect(
          spy.computeCreditCalls,
          contains(buyer),
          reason: 'the customer LIST card now routes its ceiling through '
              'repo.computeCredit (no tap needed)',
        );
      },
    );

    testWidgets(
      'OFF: the rendered ceiling matches the repo derivation (no flicker — the '
      'sync fallback equals the resolved figure)',
      (t) async {
        // The injected fake would return creditLimit:100 IF it were ever called
        // for its result; OFF it must NOT be used as the rendered value.
        await pump(
          t,
          serverCallables: false,
          serverResult: const CreditResult(
            name: buyer,
            creditLimit: 999999, // a value that must NEVER appear OFF
            used: 0,
            balance: 999999,
            pct: 0,
            orderCount: 0,
          ),
        );
        await openCustomersTab(t);
        await t.tap(find.text(buyer));
        await settle(t);

        // OFF must show the LOCAL ceiling, never the fake server figure.
        expect(find.text('₪${_grp(contractorCredit(buyer))}'), findsWidgets);
        expect(
          find.text('₪${_grp(999999)}'),
          findsNothing,
          reason: 'OFF must ignore any server figure — local derivation only',
        );
      },
    );

    testWidgets(
      'ON + a bound gateway: the rendered ceiling UPGRADES to the '
      'server-canonical figure the callable returns',
      (t) async {
        // A distinct, recognisable server ceiling (≠ the local hash) so the row
        // proves the SERVER figure is what renders.
        const serverLimit = 88000;
        final fns = await pump(
          t,
          serverCallables: true,
          serverResult: const CreditResult(
            name: buyer,
            creditLimit: serverLimit,
            used: 12000,
            balance: 76000,
            pct: 14,
            orderCount: 3,
          ),
        );
        await openCustomersTab(t);
        await t.tap(find.text(buyer));
        await settle(t);

        // The callable was invoked…
        expect(fns.creditCalls, contains(buyer));

        // …and the SERVER-canonical ceiling is what the row now shows.
        expect(
          find.text('₪${_grp(serverLimit)}'),
          findsWidgets,
          reason: 'ON: the displayed ceiling is the server-canonical figure',
        );
        // The local hash for this buyer differs from the server figure, so the
        // upgrade is observable (guards against a false ON that still shows local).
        expect(contractorCredit(buyer), isNot(serverLimit));
      },
    );
  });
}
