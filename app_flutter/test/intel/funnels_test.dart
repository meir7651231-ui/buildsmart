// Studio Pillar-3 · step 95 — the DETERMINISTIC funnel + stuck/abandon/dead-end
// detectors, proved on HAND-BUILT `List<IntelEvent>` under an INJECTED clock
// (§5). Every threshold is referenced from `intel_config.dart` — the tests build
// each detector's boundary FROM the named const, so a magic number hard-coded in
// `funnels.dart` (instead of `= kRepeatNoResult` / `= kBackLoop` / `= kIdleEnd`)
// would break the boundary and fail here (§4/§5 anti-magic-number check).
//
// PROVED HERE:
//   1. deterministic conversion % across the six stages (known list → exact %);
//   2. the biggest drop-off transition is identified correctly;
//   3. per-stage counts are MONOTONIC (a later stage never exceeds an earlier);
//   4. checkout_abandon: checkout_start + no order_placed past kIdleEnd → flagged;
//      a converted session → not; a still-active (not-yet-idle) one → not;
//   5. repeated_no_result: kRepeatNoResult no-results → flagged; fewer → not;
//   6. dead_end loop: kBackLoop oscillations → flagged; fewer → not;
//   7. the thresholds are SOURCED from intel_config.dart (each detector's default
//      boundary tracks its named const exactly).
import 'package:buildsmart/logic/intel/funnels.dart';
import 'package:buildsmart/logic/intel/intel_config.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed, INJECTED clock — the funnels/detectors are deterministic under it,
/// and no code path ever reads the wall clock.
final DateTime _t0 = DateTime.utc(2026, 1, 1, 12);

/// Terse hand-built event. [session] groups it; [screen] rides screen_view;
/// [atSec] offsets it from [_t0] so a list is chronological by construction.
IntelEvent _ev(
  String name, {
  String session = 's1',
  String? screen,
  int atSec = 0,
}) =>
    IntelEvent(
      name: name,
      sessionId: session,
      screen: screen,
      at: _t0.add(Duration(seconds: atSec)),
    );

/// A compressed alternating screen path `catalog,product,catalog,product,…` of
/// length `oscillations + 2`, which yields EXACTLY [oscillations] back-and-forth
/// returns (see `funnels.dart` `_maxOscillation`). Built off `kBackLoop` in the
/// tests so the boundary is sourced from the config const.
List<IntelEvent> _alternating(String session, int oscillations) {
  final len = oscillations + 2;
  return <IntelEvent>[
    for (var i = 0; i < len; i++)
      _ev(
        IntelEvents.screenView,
        session: session,
        screen: i.isEven ? 'catalog' : 'product',
        atSec: i,
      ),
  ];
}

/// A funnel fixture with reached = [4, 4, 4, 1, 1, 1]:
///   • three sessions (a,b,c) drop after add_to_cart;
///   • one session (z) converts all the way to order_placed.
/// → a crisp, unique biggest drop-off at add_to_cart → cart_view (lost 3).
List<IntelEvent> _funnelFixture() {
  final out = <IntelEvent>[];
  for (final s in <String>['a', 'b', 'c']) {
    out
      ..add(_ev(IntelEvents.searchSubmit, session: s))
      ..add(_ev(IntelEvents.productView, session: s))
      ..add(_ev(IntelEvents.addToCart, session: s));
  }
  const z = 'z';
  out
    ..add(_ev(IntelEvents.searchSubmit, session: z))
    ..add(_ev(IntelEvents.productView, session: z))
    ..add(_ev(IntelEvents.addToCart, session: z))
    ..add(_ev(IntelEvents.cartView, session: z))
    ..add(_ev(IntelEvents.checkoutStart, session: z))
    ..add(_ev(IntelEvents.orderPlaced, session: z));
  return out;
}

void main() {
  group('computeFunnel — deterministic step-retention (§5)', () {
    test('stages follow kIntelFunnelFlow in order', () {
      final report = computeFunnel(_funnelFixture());
      expect(
        report.stages.map((s) => s.name).toList(),
        kIntelFunnelFlow,
      );
    });

    test('per-stage reached counts are exact', () {
      final report = computeFunnel(_funnelFixture());
      expect(
        report.stages.map((s) => s.reached).toList(),
        <int>[4, 4, 4, 1, 1, 1],
      );
    });

    test('conversion % is deterministic (exact, relative to the first stage)',
        () {
      final report = computeFunnel(_funnelFixture());
      final pct = report.stages.map((s) => s.conversionPct).toList();
      expect(pct[0], closeTo(100, 1e-9)); // search_submit  4/4
      expect(pct[1], closeTo(100, 1e-9)); // product_view   4/4
      expect(pct[2], closeTo(100, 1e-9)); // add_to_cart    4/4
      expect(pct[3], closeTo(25, 1e-9)); //  cart_view      1/4
      expect(pct[4], closeTo(25, 1e-9)); //  checkout_start 1/4
      expect(pct[5], closeTo(25, 1e-9)); //  order_placed   1/4
    });

    test('step % (vs previous stage) is deterministic at the cliff', () {
      final report = computeFunnel(_funnelFixture());
      // add_to_cart → cart_view: 1 of 4 = 25 %.
      expect(report.stages[3].stepPct, closeTo(25, 1e-9));
      // cart_view → checkout_start → order_placed: 1 of 1 = 100 %.
      expect(report.stages[4].stepPct, closeTo(100, 1e-9));
      expect(report.stages[5].stepPct, closeTo(100, 1e-9));
    });

    test('per-stage counts are MONOTONIC — a later stage never exceeds earlier',
        () {
      final report = computeFunnel(_funnelFixture());
      for (var i = 1; i < report.stages.length; i++) {
        expect(
          report.stages[i].reached,
          lessThanOrEqualTo(report.stages[i - 1].reached),
          reason: '${report.stages[i].name} exceeded its predecessor',
        );
      }
    });

    test('biggest drop-off is identified correctly (add_to_cart → cart_view)',
        () {
      final drop = computeFunnel(_funnelFixture()).biggestDropOff;
      expect(drop, isNotNull);
      expect(drop!.fromStage, IntelEvents.addToCart);
      expect(drop.toStage, IntelEvents.cartView);
      expect(drop.lost, 3); // 4 reached add_to_cart, only 1 reached cart_view
      expect(drop.lostPct, closeTo(75, 1e-9)); // 3 of 4
    });

    test('an empty event list yields an all-zero funnel and no drop-off', () {
      final report = computeFunnel(const <IntelEvent>[]);
      expect(report.stages.every((s) => s.reached == 0), isTrue);
      expect(report.stages.every((s) => s.conversionPct == 0), isTrue);
      expect(report.biggestDropOff, isNull);
    });
  });

  group('detectCheckoutAbandon — DERIVED, time-INJECTED (§4)', () {
    test(
        'checkout_start + no order_placed past kIdleEnd → flagged; converted → '
        'not; still-active → not', () {
      final now = _t0.add(const Duration(hours: 1));
      final events = <IntelEvent>[
        // aband — started checkout, went silent exactly kIdleEnd ago.
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'aband',
          at: now.subtract(kIdleEnd),
        ),
        // conv — same idle window, but it placed the order.
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'conv',
          at: now.subtract(kIdleEnd),
        ),
        IntelEvent(
          name: IntelEvents.orderPlaced,
          sessionId: 'conv',
          at: now.subtract(kIdleEnd),
        ),
        // fresh — started checkout one second short of the idle horizon.
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'fresh',
          at: now.subtract(kIdleEnd).add(const Duration(seconds: 1)),
        ),
      ];

      final flagged = detectCheckoutAbandon(events, now: now);
      expect(flagged, <String>['aband']);
      expect(flagged, isNot(contains('conv')));
      expect(flagged, isNot(contains('fresh')));
    });

    test('advancing the injected clock later still only flags the abandoned one',
        () {
      final start = _t0;
      final events = <IntelEvent>[
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'aband',
          at: start,
        ),
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'conv',
          at: start,
        ),
        IntelEvent(
          name: IntelEvents.orderPlaced,
          sessionId: 'conv',
          at: start.add(const Duration(seconds: 5)),
        ),
      ];
      // Way past idle for both — but conv converted, so only aband flags.
      final now = start.add(const Duration(hours: 3));
      expect(detectCheckoutAbandon(events, now: now), <String>['aband']);
    });
  });

  group('detectRepeatedNoResult — DERIVED count (§5)', () {
    test('kRepeatNoResult no-results → flagged; one fewer → not', () {
      final events = <IntelEvent>[
        for (var i = 0; i < kRepeatNoResult; i++)
          _ev(IntelEvents.searchNoResult, session: 'stuck', atSec: i),
        for (var i = 0; i < kRepeatNoResult - 1; i++)
          _ev(IntelEvents.searchNoResult, session: 'ok', atSec: i),
      ];
      final flagged = detectRepeatedNoResult(events);
      expect(flagged, <String>['stuck']);
      expect(flagged, isNot(contains('ok')));
    });
  });

  group('detectDeadEndLoop — DERIVED oscillation (§5)', () {
    test('kBackLoop oscillations → flagged; one fewer → not', () {
      final events = <IntelEvent>[
        ..._alternating('loop', kBackLoop),
        ..._alternating('calm', kBackLoop - 1),
      ];
      final flagged = detectDeadEndLoop(events);
      expect(flagged, <String>['loop']);
      expect(flagged, isNot(contains('calm')));
    });

    test('consecutive duplicate screen_views collapse (no false oscillation)',
        () {
      // catalog,catalog,catalog… is one screen — never a back-and-forth loop.
      final events = <IntelEvent>[
        for (var i = 0; i < kBackLoop + 4; i++)
          _ev(
            IntelEvents.screenView,
            session: 'sticky',
            screen: 'catalog',
            atSec: i,
          ),
      ];
      expect(detectDeadEndLoop(events), isEmpty);
    });
  });

  group('§4/§5 thresholds are SOURCED from intel_config.dart (anti-magic)', () {
    test('the documented default thresholds are the single source', () {
      expect(kIdleEnd, const Duration(seconds: 180));
      expect(kRepeatNoResult, 3);
      expect(kBackLoop, 4);
    });

    test("each detector's default boundary tracks its named const exactly", () {
      // repeated_no_result flips at EXACTLY kRepeatNoResult.
      expect(
        detectRepeatedNoResult(<IntelEvent>[
          for (var i = 0; i < kRepeatNoResult; i++)
            _ev(IntelEvents.searchNoResult, session: 's', atSec: i),
        ]),
        <String>['s'],
      );
      expect(
        detectRepeatedNoResult(<IntelEvent>[
          for (var i = 0; i < kRepeatNoResult - 1; i++)
            _ev(IntelEvents.searchNoResult, session: 's', atSec: i),
        ]),
        isEmpty,
      );

      // dead_end flips at EXACTLY kBackLoop oscillations.
      expect(detectDeadEndLoop(_alternating('s', kBackLoop)), <String>['s']);
      expect(detectDeadEndLoop(_alternating('s', kBackLoop - 1)), isEmpty);

      // checkout_abandon flips at EXACTLY kIdleEnd of idle.
      final now = _t0.add(const Duration(hours: 1));
      expect(
        detectCheckoutAbandon(
          <IntelEvent>[
            IntelEvent(
              name: IntelEvents.checkoutStart,
              sessionId: 's',
              at: now.subtract(kIdleEnd),
            ),
          ],
          now: now,
        ),
        <String>['s'],
      );
      expect(
        detectCheckoutAbandon(
          <IntelEvent>[
            IntelEvent(
              name: IntelEvents.checkoutStart,
              sessionId: 's',
              at: now.subtract(kIdleEnd).add(const Duration(seconds: 1)),
            ),
          ],
          now: now,
        ),
        isEmpty,
      );
    });
  });

  group('analyzeIntel — one read-time snapshot (§9 forward)', () {
    test('bundles the funnel + all three detectors deterministically', () {
      final now = _t0.add(const Duration(hours: 1));
      final events = <IntelEvent>[
        ..._funnelFixture(),
        // an abandoned checkout in its own session
        IntelEvent(
          name: IntelEvents.checkoutStart,
          sessionId: 'ab',
          at: now.subtract(kIdleEnd),
        ),
        // a stuck-search session
        for (var i = 0; i < kRepeatNoResult; i++)
          _ev(IntelEvents.searchNoResult, session: 'nr', atSec: i),
        // a dead-end session
        ..._alternating('loop', kBackLoop),
      ];
      final insights = analyzeIntel(events, now: now);
      expect(insights.funnel.biggestDropOff!.toStage, IntelEvents.cartView);
      expect(insights.abandonedCheckouts, contains('ab'));
      expect(insights.repeatedNoResult, <String>['nr']);
      expect(insights.deadEndLoops, <String>['loop']);
    });
  });
}
