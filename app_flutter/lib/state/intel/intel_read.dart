// ─────────────────────────────────────────────────────────────────────────────
// intel_read — Studio Pillar-3 · step 98 — the manager INTEL READ providers.
//
// The four manager-only read surfaces the 5th dashboard tab (screens/intel/
// intel_tab.dart) watches: the conversion FUNNEL + stuck detectors (step 95), the
// per-actor SEGMENTS (step 96), the retention COHORTS (step 96), and "who is
// connected NOW" PRESENCE (step 97). Each is a deterministic FOLD of the
// step-95/96/97 PURE logic over its source — this file is only the Riverpod wiring
// (the impure edge: it reads the wall clock ONCE per read, which the pure folds
// never do — `now` is INJECTED into them here).
//
// DEMO SOURCE — the in-memory ring buffer (`intelLogProvider`, step 88). Folding
// the LOCAL buffer means the tab is FULL OF DATA on-device WITHOUT Firebase (the
// buffer is the only always-on intel piece — consent_gate.dart): a live INTEL_LIVE
// session fills it as the user navigates; a test seeds it directly.
//
// READ-GATE isManager (R1-5): every provider returns its EMPTY value unless the
// current board session is a MANAGER (`boardAuthProvider`.role == manager). A
// worker / courier / store / logged-out reader gets nothing — the intel surface is
// owner-only, exactly like the whole manager dashboard. The gate is applied ONCE,
// in `_gatedIntelEventsProvider`, so it can never drift between the four providers.
//
// PRESENCE is CUSTOMER-ONLY (R1-5: presence is written only for customer actors —
// the anonymous / worker / courier keys are excluded) and its NAMES are resolved
// OWNER-SIDE from `managerCustomersProvider` (R1-4) — NEVER from the event's
// in-memory `displayName`. The join key is the pseudonymous uid/actorKey
// (`segmentKeyOf`); the label comes from the owner's own customer record.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/intel/funnels.dart'
    show IntelInsights, analyzeIntel;
import 'package:buildsmart/logic/intel/segments.dart'
    show
        ActorSegment,
        RetentionCohort,
        kAnonymousSegmentKey,
        retentionCohorts,
        segmentKeyOf,
        segmentsByActor;
import 'package:buildsmart/logic/manager_dashboard.dart' show ManagerCustomer;
import 'package:buildsmart/state/board_auth.dart'
    show BoardRole, boardAuthProvider;
import 'package:buildsmart/state/intel/intel_event.dart' show IntelEvent;
import 'package:buildsmart/state/intel/intel_log.dart' show intelLogProvider;
import 'package:buildsmart/state/intel/presence.dart' show presenceLive;
import 'package:buildsmart/state/orders_engine.dart'
    show managerCustomersProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The MANAGER-GATED event source (R1-5). The live ring buffer when — and only
/// when — the reader is a manager; the EMPTY list otherwise. Every derived
/// provider below folds THIS, so the isManager gate is applied exactly once and
/// identically to all four (funnel / segments / retention / presence), and a
/// non-manager reads nothing. Private: the four public providers are the surface.
final _gatedIntelEventsProvider = Provider<List<IntelEvent>>((ref) {
  final isManager =
      ref.watch(boardAuthProvider)?.role == BoardRole.manager;
  if (!isManager) return const <IntelEvent>[];
  return ref.watch(intelLogProvider);
});

/// The conversion FUNNEL + the three stuck detectors (step 95), folded over the
/// gated ring buffer with an INJECTED `now`. For a non-manager the source is empty
/// → all-zero stages and a null biggest-drop-off (the honest "no data" snapshot).
final intelInsightsProvider = Provider<IntelInsights>((ref) {
  final events = ref.watch(_gatedIntelEventsProvider);
  return analyzeIntel(events, now: DateTime.now());
});

/// Per-actor SEGMENTS (step 96), keyed by the STABLE uid/actorKey — never a
/// display label (R2-#12). Empty map for a non-manager (the gated source is empty).
final intelSegmentsProvider = Provider<Map<String, ActorSegment>>((ref) {
  final events = ref.watch(_gatedIntelEventsProvider);
  return segmentsByActor(events);
});

/// Retention COHORTS (step 96) — actors bucketed by first-seen day. Empty list
/// for a non-manager. UTC day buckets (the deterministic default) keep the read
/// machine-independent; a future owner UTC-offset can be threaded here.
final intelRetentionProvider = Provider<List<RetentionCohort>>((ref) {
  final events = ref.watch(_gatedIntelEventsProvider);
  return retentionCohorts(events);
});

/// One "מי מחובר כעת" (who-is-connected-now) row — a LIVE CUSTOMER actor.
///
/// [key] is the pseudonymous uid/actorKey (the [segmentKeyOf] merge key), [screen]
/// the last screen the actor was on, [lastSeen] its freshest event instant, and
/// [name] the label resolved OWNER-SIDE from the manager's own customer records
/// (R1-4) — NULL when the owner-side aggregate carries no matching record. The
/// in-memory event `displayName` is NEVER read into this row (R1-4).
class IntelPresenceRow {
  const IntelPresenceRow({
    required this.key,
    required this.screen,
    required this.lastSeen,
    this.name,
  });

  /// Pseudonymous stable actor key (uid ?? actorKey) — never a display label.
  final String key;

  /// Last screen the actor was seen on ('' when the event carried none).
  final String screen;

  /// The freshest event instant for this actor — the "last beat" liveness uses.
  final DateTime lastSeen;

  /// Owner-side-resolved display name (R1-4), or null when unresolved.
  final String? name;

  /// True iff a name resolved owner-side (else the UI shows the pseudonym).
  bool get named => name != null && name!.isNotEmpty;
}

/// "מי מחובר כעת" — the LIVE customer actors (R1-5 CUSTOMER-ONLY), derived by
/// FRESHNESS from the gated ring buffer via [presenceLive] (step 97): an actor is
/// live only while its freshest event is younger than `kHeartbeat * 2.5`. NAMES
/// are resolved OWNER-SIDE from [managerCustomersProvider] (R1-4) — never the event
/// `displayName`. Empty for a non-manager. Rows are sorted freshest-first.
///
/// The anonymous bucket ([kAnonymousSegmentKey]) is EXCLUDED — presence is written
/// only for IDENTIFIED customer actors, so a fully-anonymous event is never a
/// "who is connected". The `now` is INJECTED (read once here), never inside the
/// pure liveness rule.
final intelPresenceProvider = Provider<List<IntelPresenceRow>>((ref) {
  final events = ref.watch(_gatedIntelEventsProvider);
  if (events.isEmpty) return const <IntelPresenceRow>[];
  final customers = ref.watch(managerCustomersProvider);
  final now = DateTime.now();

  // Fold: the freshest event per stable actor key → its lastSeen + last screen.
  // The buffer is newest-first, but we compare instants so order-independence
  // holds regardless.
  final lastSeen = <String, DateTime>{};
  final lastScreen = <String, String>{};
  for (final e in events) {
    final k = segmentKeyOf(e);
    if (k == kAnonymousSegmentKey) continue; // identified customers only (R1-5)
    final prev = lastSeen[k];
    if (prev == null || e.at.isAfter(prev)) {
      lastSeen[k] = e.at;
      lastScreen[k] = e.screen ?? '';
    }
  }

  // Owner-side name resolution (R1-4 / R2-#12): index the manager's customer
  // records by their OWNER-supplied uid and look the actor key up there — never
  // the event `displayName`, never a display label. The derived [ManagerCustomer]
  // aggregate carries NO customer uid today (manager_dashboard.dart:313-324 —
  // `ownerId` is the OWNING MANAGER's uid, always '', NOT the customer's), so
  // [_customerUid] yields null and the row falls back to its pseudonym. Wired
  // through [managerCustomersProvider] so a future customer-uid write lights the
  // name up owner-side (the segments.dart `joinSegmentsToCustomers` join, inlined).
  final nameByKey = <String, String>{};
  for (final c in customers) {
    final id = _customerUid(c);
    if (id != null && id.isNotEmpty) nameByKey[id] = c.name;
  }

  final rows = <IntelPresenceRow>[
    for (final entry in lastSeen.entries)
      if (presenceLive(now, entry.value))
        IntelPresenceRow(
          key: entry.key,
          screen: lastScreen[entry.key] ?? '',
          lastSeen: entry.value,
          name: nameByKey[entry.key],
        ),
  ]..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
  return rows;
});

/// The OWNER-SIDE customer-uid resolver (R2-#12: join by uid, NEVER a display
/// label). The derived [ManagerCustomer] aggregate exposes NO customer uid today
/// (manager_dashboard.dart:313-324 — `ownerId` is the manager's own uid, always
/// ''), so this returns null and every presence row falls back to its pseudonym.
/// Forward-ready: when a customer-write path stamps a real customer uid, return it
/// here and the name resolves owner-side — the event `displayName` stays unused.
String? _customerUid(ManagerCustomer c) => null;
