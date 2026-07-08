// Studio Pillar-3 · step 95 — DETERMINISTIC conversion funnel + stuck / abandon
// / dead-end detectors, as PURE functions over a hand-buildable
// `List<IntelEvent>`.
//
// Same pure-logic discipline as `manager_dashboard.dart` / `install_engine.dart`
// (§7): NO Firebase, NO widgets, NO providers, and — critically — NO wall-clock
// read. Every function is a deterministic fold of
// (events, config, injected-now); the current time is passed IN (a fake clock in
// the tests) so a flaky client can neither fake nor suppress a derived signal
// (§4). Every threshold comes from `intel_config.dart` — there is no magic number
// in this file (§2/§4). Dormant until step 98 wires the manager dashboard.

import 'package:buildsmart/logic/intel/intel_config.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';

/// The ordered conversion funnel — mirrors the `kManagerOrderFlow` list idiom
/// (`manager_dashboard.dart:29`). A shopper passes these stages IN ORDER, so the
/// count that reaches stage N can never exceed stage N-1 (monotonic by
/// construction — see [computeFunnel]). Every entry is an `IntelEvents` name, so
/// the stage strings never drift from the call-sites (steps 93-94) or the
/// dashboard (step 98).
const List<String> kIntelFunnelFlow = <String>[
  IntelEvents.searchSubmit,
  IntelEvents.productView,
  IntelEvents.addToCart,
  IntelEvents.cartView,
  IntelEvents.checkoutStart,
  IntelEvents.orderPlaced,
];

/// The percent unit (per-centum). This is NOT a tunable threshold — every real
/// threshold lives in `intel_config.dart` (§4) — so it stays a local, documented
/// constant rather than a bare numeric literal in the math below.
const int _kPercentScale = 100;

/// One stage of the [computeFunnel] step-retention fold.
class FunnelStage {
  const FunnelStage({
    required this.name,
    required this.reached,
    required this.conversionPct,
    required this.stepPct,
  });

  /// The stage's `IntelEvents` name (an entry of [kIntelFunnelFlow]).
  final String name;

  /// Number of DISTINCT sessions that reached this stage — contiguously from the
  /// funnel top. Monotonic: never greater than the previous stage's [reached].
  final int reached;

  /// Cumulative conversion — [reached] as a percentage of the FIRST stage's
  /// reach (0..100). The top stage is 100 whenever any session entered.
  final double conversionPct;

  /// Step conversion — [reached] as a percentage of the PREVIOUS stage's reach
  /// (0..100). The top stage is 100 by definition.
  final double stepPct;
}

/// The single biggest step-to-step loss in a funnel — the transition where the
/// most sessions dropped out ([lost] sessions between [fromStage] and
/// [toStage]). Ties resolve to the EARLIEST transition (deterministic).
class FunnelDropOff {
  const FunnelDropOff({
    required this.fromStage,
    required this.toStage,
    required this.lost,
    required this.lostPct,
  });

  /// The upstream stage of the transition.
  final String fromStage;

  /// The downstream stage of the transition.
  final String toStage;

  /// Sessions lost across this transition (`reached[from] - reached[to]`).
  final int lost;

  /// [lost] as a percentage of the from-stage reach (0..100).
  final double lostPct;
}

/// The result of [computeFunnel] — per-stage retention plus the biggest drop-off.
class FunnelReport {
  const FunnelReport({required this.stages, required this.biggestDropOff});

  /// One entry per [kIntelFunnelFlow] stage, in funnel order.
  final List<FunnelStage> stages;

  /// The transition that lost the most sessions, or null when no session entered
  /// the funnel (nothing to drop between).
  final FunnelDropOff? biggestDropOff;
}

/// MONOTONIC step-retention fold over [flow] (defaults to [kIntelFunnelFlow]).
///
/// A session "reaches" stage `i` iff it has at least one event for stage `i` AND
/// it reached stage `i-1` — i.e. it completed the contiguous prefix
/// `stage[0..i]`. That makes the per-stage [FunnelStage.reached] counts monotonic
/// BY CONSTRUCTION (the set of sessions at stage `i` is a subset of the set at
/// stage `i-1`), so a later stage can never exceed an earlier one. Pure +
/// deterministic: the result is a function of [events] alone (grouped by
/// `sessionId`), with no clock and no I/O.
FunnelReport computeFunnel(
  List<IntelEvent> events, {
  List<String> flow = kIntelFunnelFlow,
}) {
  // Stage names each session has emitted (only funnel stages are retained).
  final flowSet = flow.toSet();
  final bySession = <String, Set<String>>{};
  for (final e in events) {
    if (!flowSet.contains(e.name)) continue;
    (bySession[e.sessionId ?? ''] ??= <String>{}).add(e.name);
  }

  // reached[i] = number of sessions holding the contiguous prefix stage[0..i].
  final reached = List<int>.filled(flow.length, 0);
  for (final stages in bySession.values) {
    for (var i = 0; i < flow.length; i++) {
      if (!stages.contains(flow[i])) break; // contiguous progression stops here
      reached[i]++;
    }
  }

  final base = flow.isEmpty ? 0 : reached[0];
  final stages = <FunnelStage>[
    for (var i = 0; i < flow.length; i++)
      FunnelStage(
        name: flow[i],
        reached: reached[i],
        conversionPct:
            base == 0 ? 0 : reached[i] / base * _kPercentScale,
        stepPct: (i == 0 ? base : reached[i - 1]) == 0
            ? 0
            : reached[i] / (i == 0 ? base : reached[i - 1]) * _kPercentScale,
      ),
  ];

  // Biggest drop-off — the transition losing the most sessions; earliest wins
  // ties. Only meaningful once at least one session entered the funnel.
  FunnelDropOff? biggest;
  if (base > 0) {
    for (var i = 1; i < flow.length; i++) {
      final lost = reached[i - 1] - reached[i];
      if (biggest == null || lost > biggest.lost) {
        biggest = FunnelDropOff(
          fromStage: flow[i - 1],
          toStage: flow[i],
          lost: lost,
          lostPct: reached[i - 1] == 0
              ? 0
              : lost / reached[i - 1] * _kPercentScale,
        );
      }
    }
  }

  return FunnelReport(stages: stages, biggestDropOff: biggest);
}

/// checkout_abandon — DERIVED · deterministic · time-INJECTED.
///
/// A session is an abandoned checkout when it emitted a `checkout_start` but NO
/// `order_placed`, AND it has since gone idle past [idleEnd] relative to the
/// INJECTED [now] (its last event is at least [idleEnd] before [now]). Because
/// the signal is COMPUTED from the presence / absence of real funnel events at
/// read time — never emitted by the client — a flaky or malicious client can
/// neither fake nor suppress it (§4). Returns the flagged `sessionId`s, sorted
/// (deterministic order).
///
/// [now] is REQUIRED and INJECTED: this function never reads the wall clock.
List<String> detectCheckoutAbandon(
  List<IntelEvent> events, {
  required DateTime now,
  Duration idleEnd = kIdleEnd,
}) {
  final bySession = <String, List<IntelEvent>>{};
  for (final e in events) {
    (bySession[e.sessionId ?? ''] ??= <IntelEvent>[]).add(e);
  }
  final flagged = <String>[];
  for (final entry in bySession.entries) {
    final evs = entry.value;
    final hasStart = evs.any((e) => e.name == IntelEvents.checkoutStart);
    if (!hasStart) continue;
    final converted = evs.any((e) => e.name == IntelEvents.orderPlaced);
    if (converted) continue;
    final last = evs
        .map((e) => e.at)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (now.difference(last) >= idleEnd) flagged.add(entry.key);
  }
  flagged.sort();
  return flagged;
}

/// repeated_no_result — DERIVED · deterministic.
///
/// Flags each session with at least [threshold] (`kRepeatNoResult`)
/// `search_no_result` events — a shopper stuck searching for something the
/// catalog can't answer. A pure count over the event list grouped by
/// `sessionId`; no clock is involved. Returns the flagged `sessionId`s, sorted.
List<String> detectRepeatedNoResult(
  List<IntelEvent> events, {
  int threshold = kRepeatNoResult,
}) {
  final counts = <String, int>{};
  for (final e in events) {
    if (e.name != IntelEvents.searchNoResult) continue;
    final k = e.sessionId ?? '';
    counts[k] = (counts[k] ?? 0) + 1;
  }
  final flagged = <String>[
    for (final entry in counts.entries)
      if (entry.value >= threshold) entry.key,
  ]..sort();
  return flagged;
}

/// dead_end / back_loop — DERIVED · deterministic.
///
/// Flags each session whose navigation ping-pongs between the SAME two screens at
/// least [threshold] (`kBackLoop`) times. Within a session the `screen_view`
/// screens are read in chronological order and de-duplicated (consecutive repeats
/// collapse), then the longest run of A → B → A → B… alternation between a single
/// pair is measured; each return to the screen viewed two views earlier counts as
/// one oscillation (see [_maxOscillation]). A pure function of the event list
/// (grouped by `sessionId`) — the timestamps only ORDER the views; no wall
/// clock is read. Returns the flagged `sessionId`s, sorted.
List<String> detectDeadEndLoop(
  List<IntelEvent> events, {
  int threshold = kBackLoop,
}) {
  final bySession = <String, List<IntelEvent>>{};
  for (final e in events) {
    if (e.name != IntelEvents.screenView) continue;
    (bySession[e.sessionId ?? ''] ??= <IntelEvent>[]).add(e);
  }
  final flagged = <String>[];
  for (final entry in bySession.entries) {
    // Stable chronological order (ties broken by original position).
    final indexed = <(int, IntelEvent)>[
      for (var i = 0; i < entry.value.length; i++) (i, entry.value[i]),
    ]..sort((a, b) {
        final c = a.$2.at.compareTo(b.$2.at);
        return c != 0 ? c : a.$1.compareTo(b.$1);
      });
    // Compressed screen path — drop consecutive duplicate screens.
    final path = <String>[];
    for (final p in indexed) {
      final s = p.$2.screen ?? '';
      if (path.isEmpty || path.last != s) path.add(s);
    }
    if (_maxOscillation(path) >= threshold) flagged.add(entry.key);
  }
  flagged.sort();
  return flagged;
}

/// Longest single-pair back-and-forth run in [path]: the count of positions
/// `i >= 2` where `path[i] == path[i-2]` (a return to the screen two views back)
/// within one uninterrupted alternation. The run RESETS whenever the alternation
/// breaks, so a switch to a different screen pair never merges into the streak.
/// A compressed alternating path `A,B,A,B,…` of length `n` yields exactly `n-2`
/// oscillations. Used by [detectDeadEndLoop].
int _maxOscillation(List<String> path) {
  var best = 0;
  var run = 0;
  for (var i = 2; i < path.length; i++) {
    if (path[i] == path[i - 2] && path[i] != path[i - 1]) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}

/// A read-time snapshot of the funnel + the three stuck detectors, for the
/// manager dashboard (step 98). Every field is DERIVED from the events with the
/// INJECTED `now`; nothing here is emitted by the client.
class IntelInsights {
  const IntelInsights({
    required this.funnel,
    required this.abandonedCheckouts,
    required this.repeatedNoResult,
    required this.deadEndLoops,
  });

  /// The conversion funnel with its biggest drop-off.
  final FunnelReport funnel;

  /// Session ids with an abandoned checkout (see [detectCheckoutAbandon]).
  final List<String> abandonedCheckouts;

  /// Session ids stuck searching (see [detectRepeatedNoResult]).
  final List<String> repeatedNoResult;

  /// Session ids caught in a navigation dead-end (see [detectDeadEndLoop]).
  final List<String> deadEndLoops;
}

/// Compute the full [IntelInsights] snapshot from [events] with the INJECTED
/// [now]. Pure + deterministic + time-INJECTED — the single entry point step 98
/// reads. Never reads the wall clock.
IntelInsights analyzeIntel(
  List<IntelEvent> events, {
  required DateTime now,
}) {
  return IntelInsights(
    funnel: computeFunnel(events),
    abandonedCheckouts: detectCheckoutAbandon(events, now: now),
    repeatedNoResult: detectRepeatedNoResult(events),
    deadEndLoops: detectDeadEndLoop(events),
  );
}
