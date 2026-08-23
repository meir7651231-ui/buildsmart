// Studio Pillar-3 · step 96 — PROVES the pure segments + retention cohorts on
// HAND-BUILT `List<IntelEvent>` (§5), with the CANONICAL R2-#12 invariant front
// and center: the roll-up keys on the STABLE uid/actorKey, NEVER the display
// label.
//
// PROVED HERE:
//   1. per-actor roll-up is exact (sessions / lastSeen / screensTouched /
//      stuckCount from the step-95 detectors / converted);
//   2. THE double-count case — two customers with the SAME label but DIFFERENT
//      uid stay SEPARATE (2 roll-ups, no merge), the exact bug the label-keyed
//      `mgrCustomerList` still has (shown side-by-side as the contrast);
//   3. deterministic cohort retention (a known event list → exact % on day N),
//      with the timezone offset applied CONSISTENTLY across the whole fold;
//   4. a fully anonymous event (no uid / actorKey / label) lands in its own
//      bucket, never merges into a named actor, never crashes the fold;
//   5. the join aligns a roll-up to a ManagerCustomer VIA UID (never the label).
import 'package:buildsmart/logic/intel/intel_config.dart';
import 'package:buildsmart/logic/intel/segments.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fixed, INJECTED clock — the fold is deterministic under it and no code path
/// ever reads the wall clock.
final DateTime _t0 = DateTime.utc(2026, 1, 1, 12);

/// Terse hand-built event. Carries the intel identity dimensions so the roll-up
/// key ([segmentKeyOf]) can be exercised; [atSec] offsets it from [_t0].
IntelEvent _ev(
  String name, {
  required String session,
  String? uid,
  String? actorKey,
  String? screen,
  String? displayName,
  int atSec = 0,
}) =>
    IntelEvent(
      name: name,
      uid: uid,
      actorKey: actorKey,
      sessionId: session,
      screen: screen,
      displayName: displayName,
      at: _t0.add(Duration(seconds: atSec)),
    );

/// A single screen_view for [uid] on `2026-01-[day]` at noon UTC — the cohort
/// fixtures build active-day sets from these.
IntelEvent _onDay(String uid, int day) => IntelEvent(
      name: IntelEvents.screenView,
      uid: uid,
      sessionId: 's-$uid-$day',
      screen: 'home',
      at: DateTime.utc(2026, 1, day, 12),
    );

/// The canonical UTC-midnight bucket marker for `2026-01-[day]` — the shape a
/// cohortDay carries (see `segments.dart` `_dayBucket`).
DateTime _day(int day) => DateTime.utc(2026, 1, day);

void main() {
  group('segmentsByActor — per-actor roll-up, keyed by uid/actorKey (§2)', () {
    test('sessions / screensTouched / lastSeen / converted / stuckCount exact',
        () {
      final events = <IntelEvent>[
        // session s1 — a screen + kRepeatNoResult no-results (→ stuck: s1).
        _ev(IntelEvents.screenView,
            uid: 'u-alice', session: 's1', screen: 'home'),
        for (var i = 0; i < kRepeatNoResult; i++)
          _ev(IntelEvents.searchNoResult,
              uid: 'u-alice', session: 's1', atSec: 1 + i),
        // session s2 — a second screen + a conversion.
        _ev(IntelEvents.screenView,
            uid: 'u-alice', session: 's2', screen: 'catalog', atSec: 10),
        _ev(IntelEvents.orderPlaced,
            uid: 'u-alice', session: 's2', atSec: 11),
      ];

      final segs = segmentsByActor(
        events,
        now: _t0.add(const Duration(hours: 1)),
      );

      expect(segs.keys.toList(), <String>['u-alice']);
      final a = segs['u-alice']!;
      expect(a.sessions, 2); // distinct s1, s2
      expect(a.screensTouched, 2); // home, catalog
      expect(a.converted, isTrue); // has order_placed
      expect(a.stuckCount, 1); // s1 flagged repeated_no_result; nothing else
      expect(a.lastSeen, _t0.add(const Duration(seconds: 11)));
      expect(a.isAnonymous, isFalse);
    });

    test('an empty event list yields an empty roll-up (no crash)', () {
      expect(segmentsByActor(const <IntelEvent>[]), isEmpty);
      expect(retentionCohorts(const <IntelEvent>[]), isEmpty);
    });
  });

  group('THE double-count case — same label, different uid (קנוני R2-#12)', () {
    test('uid-keying keeps two same-label customers SEPARATE (no double-count)',
        () {
      const sameLabel = 'דוד לוי';
      final events = <IntelEvent>[
        _ev(IntelEvents.screenView,
            uid: 'u-1', session: 'sa', screen: 'home', displayName: sameLabel),
        _ev(IntelEvents.orderPlaced,
            uid: 'u-1', session: 'sa', displayName: sameLabel, atSec: 1),
        _ev(IntelEvents.screenView,
            uid: 'u-2', session: 'sb', screen: 'home', displayName: sameLabel),
        _ev(IntelEvents.orderPlaced,
            uid: 'u-2', session: 'sb', displayName: sameLabel, atSec: 1),
      ];

      final segs = segmentsByActor(
        events,
        now: _t0.add(const Duration(hours: 1)),
      );

      // uid-keyed → two DISTINCT roll-ups, neither merged, no double-count.
      expect(segs.length, 2);
      expect(segs.keys.toSet(), <String>{'u-1', 'u-2'});
      expect(segs['u-1']!.converted, isTrue);
      expect(segs['u-2']!.converted, isTrue);
      expect(segs['u-1']!.sessions, 1);
      expect(segs['u-2']!.sessions, 1);
    });

    test('CONTRAST: the label-keyed mgrCustomerList MERGES them into one (bug)',
        () {
      const sameLabel = 'דוד לוי';
      // The legacy label-keyed fold folds two DIFFERENT people who share a label
      // into ONE bucket — the double-count this step fixes.
      final merged = mgrCustomerList(const <ManagerOrder>[
        ManagerOrder(
          id: 'BS-1',
          who: sameLabel,
          site: 's',
          items: 1,
          sum: 100,
          stage: 'new',
        ),
        ManagerOrder(
          id: 'BS-2',
          who: sameLabel,
          site: 's',
          items: 1,
          sum: 200,
          stage: 'new',
        ),
      ]);
      expect(merged.length, 1); // ← two collapsed to one
      expect(merged.single.orderCount, 2); // ← spend/count double-counted
      expect(merged.single.totalSpend, 300);
    });
  });

  group('retentionCohorts — deterministic cohort-by-first-seen-day (§5)', () {
    test('% returning on day N is exact', () {
      // Cohort Jan-01: u-a active days 1,2,3 · u-b active 1,2 · u-c active 1.
      // Cohort Jan-02: u-d active days 2,3 (offsets 0,1 from its first day).
      final events = <IntelEvent>[
        _onDay('u-a', 1), _onDay('u-a', 2), _onDay('u-a', 3),
        _onDay('u-b', 1), _onDay('u-b', 2),
        _onDay('u-c', 1),
        _onDay('u-d', 2), _onDay('u-d', 3),
      ];

      final cohorts = retentionCohorts(events); // default UTC offset
      expect(cohorts.length, 2);

      final d0 = cohorts[0];
      expect(d0.cohortDay, _day(1));
      expect(d0.size, 3);
      expect(d0.returning(0), 3);
      expect(d0.retentionPct(0), closeTo(100, 1e-9)); // day 0 = 100%
      expect(d0.returning(1), 2); // u-a, u-b returned day 1
      expect(d0.retentionPct(1), closeTo(200 / 3, 1e-9)); // 66.66…%
      expect(d0.returning(2), 1); // only u-a returned day 2
      expect(d0.retentionPct(2), closeTo(100 / 3, 1e-9)); // 33.33…%

      final d1 = cohorts[1];
      expect(d1.cohortDay, _day(2));
      expect(d1.size, 1); // u-d
      expect(d1.returning(1), 1); // u-d active on Jan-03 = day 1
      expect(d1.retentionPct(1), closeTo(100, 1e-9));
    });

    test('localOffset is applied CONSISTENTLY across the whole fold (tz)', () {
      // One actor, one event at 23:30 UTC on Jan-01.
      final events = <IntelEvent>[
        IntelEvent(
          name: IntelEvents.screenView,
          uid: 'u',
          sessionId: 's',
          at: DateTime.utc(2026, 1, 1, 23, 30),
        ),
      ];
      // UTC (default) → the day is Jan-01.
      expect(retentionCohorts(events).single.cohortDay, _day(1));
      // +1h offset pushes 23:30 → 00:30 next day → Jan-02, consistently.
      expect(
        retentionCohorts(events, localOffset: const Duration(hours: 1))
            .single
            .cohortDay,
        _day(2),
      );
    });
  });

  group('anonymous bucket + key precedence (§4)', () {
    test('a no-uid/no-actorKey/no-label event is anonymous and never merges', () {
      final events = <IntelEvent>[
        // Fully anonymous — no uid, no actorKey, no label.
        IntelEvent(
          name: IntelEvents.screenView,
          sessionId: 's-anon',
          screen: 'landing',
          at: _t0,
        ),
        // An identified actor right beside it.
        _ev(IntelEvents.orderPlaced,
            uid: 'u-real', session: 's-real', atSec: 5),
      ];

      final segs = segmentsByActor(
        events,
        now: _t0.add(const Duration(hours: 1)),
      );

      expect(segs.keys.toSet(), <String>{kAnonymousSegmentKey, 'u-real'});
      expect(segs.length, 2); // anon did NOT merge into the named actor
      final anon = segs[kAnonymousSegmentKey]!;
      expect(anon.isAnonymous, isTrue);
      expect(anon.sessions, 1);
      expect(anon.screensTouched, 1);
      expect(anon.converted, isFalse);
      expect(segs['u-real']!.isAnonymous, isFalse);
      expect(segs['u-real']!.converted, isTrue);
    });

    test('key precedence: uid wins, else actorKey, else anonymous', () {
      DateTime t() => _t0;
      // uid present → uid wins over actorKey.
      expect(
        segmentKeyOf(IntelEvent(
            name: IntelEvents.screenView,
            uid: 'u-x',
            actorKey: 'ak-x',
            at: t())),
        'u-x',
      );
      // empty uid → fall back to actorKey.
      expect(
        segmentKeyOf(IntelEvent(
            name: IntelEvents.screenView,
            uid: '',
            actorKey: 'ak-1',
            at: t())),
        'ak-1',
      );
      // null uid → fall back to actorKey.
      expect(
        segmentKeyOf(IntelEvent(
            name: IntelEvents.screenView, actorKey: 'ak-2', at: t())),
        'ak-2',
      );
      // both null/empty → the reserved anonymous bucket.
      expect(
        segmentKeyOf(IntelEvent(name: IntelEvents.screenView, at: t())),
        kAnonymousSegmentKey,
      );
      expect(
        segmentKeyOf(IntelEvent(
            name: IntelEvents.screenView, uid: '', actorKey: '', at: t())),
        kAnonymousSegmentKey,
      );
    });

    test('an actorKey-only actor and the anonymous bucket stay SEPARATE', () {
      final events = <IntelEvent>[
        IntelEvent(
          name: IntelEvents.screenView,
          actorKey: 'ak-1',
          sessionId: 's1',
          at: _t0,
        ),
        IntelEvent(
          name: IntelEvents.screenView,
          sessionId: 's2',
          at: _t0,
        ), // anonymous
      ];
      final segs = segmentsByActor(events);
      expect(segs.keys.toSet(), <String>{'ak-1', kAnonymousSegmentKey});
    });
  });

  group('joinSegmentsToCustomers — align by uid, NEVER label (R2-#12 DoD)', () {
    test('two same-label / different-uid customers align to their own roll-up',
        () {
      const sameLabel = 'Dana';
      final events = <IntelEvent>[
        _ev(IntelEvents.orderPlaced,
            uid: 'u-1', session: 'sa', displayName: sameLabel),
        _ev(IntelEvents.orderPlaced,
            uid: 'u-2', session: 'sb', displayName: sameLabel),
      ];
      final segs = segmentsByActor(
        events,
        now: _t0.add(const Duration(hours: 1)),
      );

      // Owner-side records — SAME label, DIFFERENT uid supplied via the resolver
      // (ManagerCustomer carries no customer-uid field, so the owner maps it).
      const c1 = ManagerCustomer(
        name: sameLabel,
        orderCount: 1,
        totalSpend: 100,
        creditLimit: 50000,
      );
      const c2 = ManagerCustomer(
        name: sameLabel,
        orderCount: 1,
        totalSpend: 200,
        creditLimit: 60000,
      );
      final uidOfCustomer = <ManagerCustomer, String>{c1: 'u-1', c2: 'u-2'};

      final joined = joinSegmentsToCustomers(
        segs,
        <ManagerCustomer>[c1, c2],
        uidOf: (c) => uidOfCustomer[c],
      );

      expect(joined.length, 2); // two separate rows — no label merge
      final r1 = joined.firstWhere((j) => j.key == 'u-1');
      final r2 = joined.firstWhere((j) => j.key == 'u-2');
      expect(r1.matched, isTrue);
      expect(r2.matched, isTrue);
      expect(identical(r1.customer, c1), isTrue); // matched by uid u-1
      expect(identical(r2.customer, c2), isTrue); // matched by uid u-2
      // Label resolved OWNER-SIDE from the joined record — never a merge key.
      expect(r1.resolvedLabel, sameLabel);
      expect(r2.resolvedLabel, sameLabel);
    });

    test('a shared label never forces a match — only the uid does', () {
      final segs = segmentsByActor(<IntelEvent>[
        _ev(IntelEvents.screenView,
            uid: 'u-lonely', session: 's', screen: 'home', displayName: 'Ghost'),
      ]);
      const other = ManagerCustomer(
        name: 'Ghost', // SAME label as the roll-up…
        orderCount: 1,
        totalSpend: 10,
        creditLimit: 1000,
      );
      // …but it resolves to a DIFFERENT uid → must stay UNMATCHED.
      final joined = joinSegmentsToCustomers(
        segs,
        const <ManagerCustomer>[other],
        uidOf: (_) => 'u-someone-else',
      );
      expect(joined.single.matched, isFalse);
      expect(joined.single.resolvedLabel, isNull);
    });
  });
}
