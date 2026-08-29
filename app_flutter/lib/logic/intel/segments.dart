// Studio Pillar-3 · step 96 — PURE customer SEGMENTS + retention COHORTS, keyed
// by the STABLE actor identity (uid, else actorKey), NEVER the display label
// (קנוני R2-#12).
//
// THE CANONICAL INVARIANT (R2-#12): the legacy manager roll-up
// (`manager_dashboard.dart` `mgrCustomerList`) keys its buyer map on the ORDER'S
// DISPLAY LABEL (the `who` field). Two DIFFERENT customers who happen to share a
// label therefore MERGE into one bucket and DOUBLE-COUNT. This file is the
// CORRECT roll-up: the merge key is the pseudonymous uid/actorKey — a stable
// identity that never collides across two different people. The display label is
// resolved OWNER-SIDE (from the joined customer record) and is NEVER a merge key.
// An event carrying NEITHER uid NOR actorKey lands in ONE reserved "anonymous"
// bucket — it never merges into an identified actor.
//
// Same pure-logic discipline as `funnels.dart` (step 95): NO Firebase, NO
// widgets, NO providers, NO wall-clock read (any "now" is INJECTED). Deterministic
// folds over a hand-buildable `List<IntelEvent>`, mirroring the buyer-fold shape
// of `manager_dashboard.dart:272-296` but with the key moved off the label onto
// the stable uid/actorKey. Dormant until step 98 wires the manager dashboard.

import 'package:buildsmart/logic/intel/funnels.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';

/// The percent unit (per-centum). NOT a tunable threshold — kept as a local
/// documented constant rather than a bare literal in the retention math, exactly
/// as `funnels.dart` keeps its `_kPercentScale`.
const int _kPercentScale = 100;

/// The reserved roll-up key for events that carry NEITHER a uid NOR an actorKey
/// (a fully anonymous, pre-identity event). Every such event shares THIS ONE
/// bucket and NEVER merges into an identified actor. It is a reserved sentinel —
/// the `__` prefix keeps it clear of any real uid/actorKey value.
const String kAnonymousSegmentKey = '__anon__';

/// The SINGLE source of truth for the per-actor merge key (R2-#12): the stable
/// [IntelEvent.uid] when present, else the pseudonymous [IntelEvent.actorKey]
/// when present, else the reserved [kAnonymousSegmentKey]. The human display
/// label is DELIBERATELY absent here — it is never a merge key. Fall back to the
/// actorKey ONLY when the uid is null/empty; when BOTH are null/empty the event
/// is anonymous.
String segmentKeyOf(IntelEvent e) {
  final uid = e.uid;
  if (uid != null && uid.isNotEmpty) return uid;
  final actorKey = e.actorKey;
  if (actorKey != null && actorKey.isNotEmpty) return actorKey;
  return kAnonymousSegmentKey;
}

/// A per-actor roll-up, keyed by the STABLE [key] ([segmentKeyOf]) — never a
/// display label. Every field is a deterministic fold over the actor's own
/// events.
class ActorSegment {
  /// Builds a roll-up row. All fields are derived by [segmentsByActor].
  const ActorSegment({
    required this.key,
    required this.sessions,
    required this.lastSeen,
    required this.screensTouched,
    required this.stuckCount,
    required this.converted,
  });

  /// The stable merge key: uid, else actorKey, else [kAnonymousSegmentKey].
  final String key;

  /// Count of DISTINCT non-empty `sessionId`s this actor was seen across.
  final int sessions;

  /// The most recent event instant for this actor (max `at`). An instant, so it
  /// is timezone-agnostic — bucketing into local days happens in
  /// [retentionCohorts], never here.
  final DateTime lastSeen;

  /// Count of DISTINCT non-empty `screen`s this actor touched.
  final int screensTouched;

  /// Total number of stuck SIGNALS the step-95 detectors raise across THIS
  /// actor's own sessions — the summed count of abandoned-checkout +
  /// repeated-no-result + dead-end-loop flags. A session flagged by two
  /// detectors contributes two (a severity tally, not a distinct-session count).
  final int stuckCount;

  /// Whether this actor has at least one `order_placed` event.
  final bool converted;

  /// True iff this is the shared anonymous bucket ([kAnonymousSegmentKey]).
  bool get isAnonymous => key == kAnonymousSegmentKey;
}

/// Per-actor roll-up of [events], keyed by [segmentKeyOf] (uid ?? actorKey ??
/// anonymous) — NEVER the display label (R2-#12). Returns one [ActorSegment] per
/// distinct key, so two different people who share a label stay SEPARATE (the
/// exact double-count the label-keyed `mgrCustomerList` suffers is impossible
/// here).
///
/// [now] is INJECTED for the abandoned-checkout detector (this function never
/// reads the wall clock). When omitted it defaults to the LATEST event instant in
/// [events] — deterministic, "as of the freshest activity in the batch". The
/// three step-95 detectors are reused verbatim, scoped to each actor's own events
/// so a stuck session is attributed to exactly the actor that owns it.
Map<String, ActorSegment> segmentsByActor(
  List<IntelEvent> events, {
  DateTime? now,
}) {
  if (events.isEmpty) return <String, ActorSegment>{};

  // First pass — bucket every event under its stable actor key (never a label).
  final byActor = <String, List<IntelEvent>>{};
  for (final e in events) {
    (byActor[segmentKeyOf(e)] ??= <IntelEvent>[]).add(e);
  }

  // now injected; fall back to the latest event instant (deterministic).
  final resolvedNow =
      now ?? events.map((e) => e.at).reduce((a, b) => a.isAfter(b) ? a : b);

  final out = <String, ActorSegment>{};
  byActor.forEach((key, evs) {
    final sessions = <String>{};
    final screens = <String>{};
    var lastSeen = evs.first.at;
    var converted = false;
    for (final e in evs) {
      final s = e.sessionId;
      if (s != null && s.isNotEmpty) sessions.add(s);
      final sc = e.screen;
      if (sc != null && sc.isNotEmpty) screens.add(sc);
      if (e.at.isAfter(lastSeen)) lastSeen = e.at;
      if (e.name == IntelEvents.orderPlaced) converted = true;
    }
    // Reuse the step-95 detectors on THIS actor's events — the stuck tally.
    final stuckCount = detectCheckoutAbandon(evs, now: resolvedNow).length +
        detectRepeatedNoResult(evs).length +
        detectDeadEndLoop(evs).length;
    out[key] = ActorSegment(
      key: key,
      sessions: sessions.length,
      lastSeen: lastSeen,
      screensTouched: screens.length,
      stuckCount: stuckCount,
      converted: converted,
    );
  });
  return out;
}

/// One first-seen cohort — the actors first observed on [cohortDay], plus how
/// many of them returned on each day-offset.
class RetentionCohort {
  /// Builds a cohort row. Populated by [retentionCohorts].
  const RetentionCohort({
    required this.cohortDay,
    required this.size,
    required this.returningByDay,
  });

  /// The cohort's first-seen calendar day, as a UTC-midnight marker of the
  /// bucketed local date (see [retentionCohorts] for the timezone assumption).
  final DateTime cohortDay;

  /// Number of DISTINCT actors first seen on [cohortDay].
  final int size;

  /// Day-offset (0-based, contiguous 0..maxObserved) → number of the cohort's
  /// actors active on `cohortDay + offset` days. `returningByDay[0] == size` by
  /// construction (every member is active on its own first day).
  final Map<int, int> returningByDay;

  /// Count of actors active on `cohortDay + [dayOffset]` days (0 if unobserved).
  int returning(int dayOffset) => returningByDay[dayOffset] ?? 0;

  /// Percent of the cohort ([returning] / [size] × 100) active on day
  /// [dayOffset]. Day 0 is always 100 (or 0 for an empty cohort).
  double retentionPct(int dayOffset) =>
      size == 0 ? 0 : returning(dayOffset) / size * _kPercentScale;
}

/// Retention COHORTS — actors bucketed by their FIRST-seen day, then the percent
/// of each cohort returning on day N. A pure date-bucket fold mirroring the
/// buyer-fold idiom of `manager_dashboard.dart:272-296`, but keyed by the stable
/// actor identity ([segmentKeyOf]) rather than a display label.
///
/// ── TIMEZONE ASSUMPTION (documented · consistent for the WHOLE fold, §4) ──
/// Every timestamp is bucketed into a calendar day at ONE, single UTC offset
/// [localOffset], applied identically to EVERY event — so no cohort ever splits
/// on timezone and the anonymous bucket is bucketed the same way as everyone
/// else. The default is [Duration.zero] (UTC), which keeps the fold PURE and
/// machine-independent (a test on the same event list yields the same %
/// everywhere). The owner passes their real local UTC offset here for
/// local-calendar-day cohorts — the local-time assumption is thus INJECTED, not
/// read from the device clock.
List<RetentionCohort> retentionCohorts(
  List<IntelEvent> events, {
  Duration localOffset = Duration.zero,
}) {
  // Per actor: the set of calendar days (at [localOffset]) it was active on.
  final daysByActor = <String, Set<DateTime>>{};
  for (final e in events) {
    (daysByActor[segmentKeyOf(e)] ??= <DateTime>{})
        .add(_dayBucket(e.at, localOffset));
  }

  // Cohort each actor under its FIRST-seen day (keyed by the stable actor
  // identity above — never a display label).
  final membersByCohort = <DateTime, List<Set<DateTime>>>{};
  daysByActor.forEach((_, days) {
    final first = days.reduce((a, b) => a.isBefore(b) ? a : b);
    (membersByCohort[first] ??= <Set<DateTime>>[]).add(days);
  });

  final cohorts = <RetentionCohort>[
    for (final entry in membersByCohort.entries)
      _buildCohort(entry.key, entry.value),
  ]..sort((a, b) => a.cohortDay.compareTo(b.cohortDay));
  return cohorts;
}

/// Fold one cohort: for each contiguous day-offset 0..maxObserved, count the
/// members active on `day + offset`. [members] is each member's active-day set.
RetentionCohort _buildCohort(DateTime day, List<Set<DateTime>> members) {
  var maxOffset = 0;
  for (final days in members) {
    for (final d in days) {
      final offset = d.difference(day).inDays;
      if (offset > maxOffset) maxOffset = offset;
    }
  }
  final returningByDay = <int, int>{};
  for (var n = 0; n <= maxOffset; n++) {
    final target = day.add(Duration(days: n));
    var count = 0;
    for (final days in members) {
      if (days.contains(target)) count++;
    }
    returningByDay[n] = count;
  }
  return RetentionCohort(
    cohortDay: day,
    size: members.length,
    returningByDay: returningByDay,
  );
}

/// The calendar day of [at] at UTC offset [offset], as a canonical UTC-midnight
/// marker. Because the marker is UTC (no DST), day-offset arithmetic via
/// `.add(Duration(days: n))` and `.difference(...).inDays` is exact.
DateTime _dayBucket(DateTime at, Duration offset) {
  final shifted = at.toUtc().add(offset);
  return DateTime.utc(shifted.year, shifted.month, shifted.day);
}

/// One joined row — an actor roll-up aligned to its owner-side [ManagerCustomer]
/// business record. The pair is matched BY UID (see [joinSegmentsToCustomers]),
/// never by the display label.
class ActorCustomerJoin {
  /// [customer] is null when the roll-up has no matching owner-side record.
  const ActorCustomerJoin({required this.segment, this.customer});

  /// The stable-identity roll-up (keyed by uid/actorKey).
  final ActorSegment segment;

  /// The owner-side customer record matched by uid, or null when unmatched.
  final ManagerCustomer? customer;

  /// The roll-up's stable key ([ActorSegment.key]).
  String get key => segment.key;

  /// True iff an owner-side record was matched by uid.
  bool get matched => customer != null;

  /// The customer label resolved OWNER-SIDE from the joined record — never a
  /// merge key (R2-#12). Null when unmatched.
  String? get resolvedLabel => customer?.name;
}

/// Align each actor roll-up in [segments] to a [ManagerCustomer] in [customers]
/// VIA THE UID KEY — never the display label (R2-#12 DoD).
///
/// ── ManagerCustomer uid reconciliation (documented) ──
/// [ManagerCustomer] (`manager_dashboard.dart:299-325`) is a DERIVED aggregate
/// over `Order.who` display labels and exposes NO customer-uid field: its only
/// identity-ish field, `ownerId`, is the OWNING MANAGER's auth.uid (and is always
/// '' on the derived path), NOT the customer's identity — so it is not a valid
/// customer join key. Therefore the customer's uid is supplied OWNER-SIDE via the
/// REQUIRED [uidOf] resolver. There is deliberately NO label fallback: a resolver
/// (not the display label) is the only way to key a customer, which makes joining
/// by label structurally impossible. Two customers who share a label but resolve
/// to different uids therefore stay SEPARATE rows.
///
/// Returns one row per roll-up (matched + unmatched), sorted by [ActorSegment.key]
/// for deterministic order.
List<ActorCustomerJoin> joinSegmentsToCustomers(
  Map<String, ActorSegment> segments,
  List<ManagerCustomer> customers, {
  required String? Function(ManagerCustomer customer) uidOf,
}) {
  // Index owner-side records by their owner-supplied uid — never the label.
  final byUid = <String, ManagerCustomer>{};
  for (final c in customers) {
    final id = uidOf(c);
    if (id == null || id.isEmpty) continue;
    byUid[id] = c; // last write wins on a duplicate uid (owner-side dedupe)
  }

  final out = <ActorCustomerJoin>[
    for (final entry in segments.entries)
      ActorCustomerJoin(segment: entry.value, customer: byUid[entry.key]),
  ]..sort((a, b) => a.key.compareTo(b.key));
  return out;
}
