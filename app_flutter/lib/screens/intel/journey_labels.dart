// ─────────────────────────────────────────────────────────────────────────────
// journey_labels — Studio Pillar-3 · step 99 (PART A) — the PURE per-customer
// JOURNEY helpers behind the manager "מסע הלקוח" timeline (JourneyTimeline in
// manager_dashboard_screen.dart).
//
// ONE place for the journey's label/emoji "he-map", its relative-time format, its
// per-actor FOLD (JOINED BY the stable uid/actorKey via `segmentKeyOf` — NEVER a
// display label, R2-#12), and its per-row STUCK rule. Kept PURE (no widgets, no
// Firebase, no providers, no wall-clock read — `now` is INJECTED) so every rule is
// unit-testable independently of the widget, mirroring the pure-logic discipline of
// funnels.dart / segments.dart.
//
// R1-4 / R2-#12: the join key is the pseudonymous uid/actorKey; the customer's
// human NAME is resolved OWNER-SIDE by the caller and is NEVER read from
// `IntelEvent.displayName` here (this file never touches `displayName`).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/intel/segments.dart' show segmentKeyOf;
import 'package:buildsmart/state/intel/intel_event.dart' show IntelEvent;
import 'package:buildsmart/state/intel/intel_events.dart' show IntelEvents;

/// Upper bound on rows the journey timeline folds for one customer — keeps the
/// read O(window) rather than O(all-history) (§4) even on a long-lived buffer.
const int kJourneyWindow = 50;

/// Hebrew label for an intel event [name] — keyed by the `IntelEvents` wire
/// constants (never a raw literal) so the timeline strings never drift from the
/// taxonomy. Honors the step-99 spec labels verbatim (screen_view→"צפייה במסך",
/// search_submit→"חיפוש", add_to_cart→"הוספה לסל", checkout_start→"התחלת תשלום",
/// order_placed→"הזמנה בוצעה"). An unknown name falls back to the raw name (honest,
/// never a crash).
String intelEventHe(String name) => _he[name] ?? name;

const Map<String, String> _he = <String, String>{
  IntelEvents.sessionStart: 'תחילת סשן',
  IntelEvents.sessionHeartbeat: 'פעילות',
  IntelEvents.sessionEnd: 'סיום סשן',
  IntelEvents.identify: 'זיהוי',
  IntelEvents.screenView: 'צפייה במסך',
  IntelEvents.searchSubmit: 'חיפוש',
  IntelEvents.searchNoResult: 'חיפוש ללא תוצאות',
  IntelEvents.productView: 'צפייה במוצר',
  IntelEvents.addToCart: 'הוספה לסל',
  IntelEvents.cartView: 'צפייה בסל',
  IntelEvents.checkoutStart: 'התחלת תשלום',
  IntelEvents.checkoutStep: 'שלב בתשלום',
  IntelEvents.orderPlaced: 'הזמנה בוצעה',
};

/// An emoji glyph for an intel event [name] — the timeline node marker. Unknown
/// names fall back to a neutral bullet.
String intelEventEmoji(String name) => _emoji[name] ?? '•';

const Map<String, String> _emoji = <String, String>{
  IntelEvents.sessionStart: '🟢',
  IntelEvents.sessionHeartbeat: '💓',
  IntelEvents.sessionEnd: '⚪',
  IntelEvents.identify: '🪪',
  IntelEvents.screenView: '👁️',
  IntelEvents.searchSubmit: '🔍',
  IntelEvents.searchNoResult: '🚫',
  IntelEvents.productView: '📦',
  IntelEvents.addToCart: '🛒',
  IntelEvents.cartView: '🧺',
  IntelEvents.checkoutStart: '💳',
  IntelEvents.checkoutStep: '🧾',
  IntelEvents.orderPlaced: '✅',
};

/// The one customer's events, JOINED BY the stable [customerKey] (uid/actorKey via
/// [segmentKeyOf]) — NEVER the display label (R2-#12): two customers who share a
/// NAME but resolve to DIFFERENT keys therefore see disjoint journeys, no
/// cross-contamination. A null/empty key yields the EMPTY list (the honest "no key
/// resolvable" path — the caller shows an empty state, never joins by name).
/// Sorted newest-first and capped to [max] ([kJourneyWindow]) so the fold is
/// O(window). `now` is not read here — pass instants already on the events.
List<IntelEvent> journeyEventsFor(
  List<IntelEvent> events,
  String? customerKey, {
  int max = kJourneyWindow,
}) {
  if (customerKey == null || customerKey.isEmpty) return const <IntelEvent>[];
  final mine = <IntelEvent>[
    for (final e in events)
      if (segmentKeyOf(e) == customerKey) e,
  ]..sort((a, b) => b.at.compareTo(a.at)); // newest-first
  return mine.length <= max ? mine : mine.sublist(0, max);
}

/// True iff this customer's [events] contain at least one `order_placed` — the
/// conversion flag the per-row stuck rule reads (an un-converted checkout is
/// "stuck").
bool journeyConverted(List<IntelEvent> events) =>
    events.any((e) => e.name == IntelEvents.orderPlaced);

/// Whether one journey row [e] is a STUCK signal worth highlighting: a dead-end
/// search (`search_no_result`) always, and a `checkout_start` that the customer
/// never [converted] past (an abandoned checkout). Mirrors the friction the
/// step-95 detectors surface, reduced to a per-row flag for the timeline.
bool journeyRowStuck(IntelEvent e, {required bool converted}) {
  if (e.name == IntelEvents.searchNoResult) return true;
  if (e.name == IntelEvents.checkoutStart && !converted) return true;
  return false;
}

/// Relative Hebrew time from [at] to [now] for a journey row (a simple helper —
/// the intel_tab.dart `_relTime` is library-private, so the same shape is provided
/// here). Guards a future/negative delta to 0.
String journeyRelTime(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inSeconds < 60) return 'לפני ${d.inSeconds < 0 ? 0 : d.inSeconds} שנ׳';
  if (d.inMinutes < 60) return 'לפני ${d.inMinutes} דק׳';
  if (d.inHours < 24) return 'לפני ${d.inHours} שע׳';
  return 'לפני ${d.inDays} ימ׳';
}
