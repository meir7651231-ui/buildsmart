// keyboard_updates_deriver — the PURE MIRROR ENGINE for the עדכונים tab.
//
// THE DERIVER IS A PURE FUNCTION: [UpdatesLocation] (+ the live data passed as
// params) -> [KbUpdatesContext], where [KbUpdatesContext] bundles BOTH halves of
// the live mirror as one atomic value: ( [KbPredRow] row , List<KbToolNode>?
// toolBase ). Bundling them is load-bearing (async-race lens): predictions and
// tools derive from the SAME location snapshot, so they can never disagree (no
// "notif chips but chats tools" mismatch).
//
// THE PURITY CONTRACT (very_good_analysis clean, unit-testable despite the
// keyboard's compile flag): [deriveUpdatesContext] takes ALL data as parameters
// (the visible threads, the selected notif section) and NEVER reads `ref` or
// `context` itself — mirroring `matchDestinations`' documented purity. The
// floating keyboard snapshots the data once in `build` (`final threads =
// ref.watch(visibleThreadsProvider)`) and passes it in, so the deriver is
// deterministic (same location + same data in => identical context out) and
// fully unit-testable with hand-built locations. The dispatch closures it
// returns DO take a `WidgetRef`/`BuildContext` — but those are supplied LATER, at
// tap time, by the keyboard; the deriver only CONSTRUCTS the closures, it never
// invokes them or reads providers itself.
//
// WHY [KbPredRow] (not the keyboard's private `_PredRow`): the floating keyboard
// owns `_PredRow` as a PRIVATE type, and a leaf file cannot import a private
// symbol from another library. So the deriver emits an equivalent PUBLIC value
// carrier with the SAME four data fields the keyboard's `_PredRow` carries
// (chips · destByChip · runByChip · the navigable-chip set); the floating
// keyboard ADAPTS a [KbPredRow] into its own `_PredRow` at the single seam in
// `_rowFor` (one trivial field-for-field copy). bs_keyboard.dart still only ever
// sees `List<String>` chips + `Set<String>` destinations — this file imports
// NOTHING into the pure keyboard.
//
// THE THIRD DISPATCH PATH. Dynamic conversation/notification chips belong to
// NEITHER of the keyboard's two existing dispatch maps (`_drillIndexByChip` /
// `_destByChip`), so the keyboard adds a THIRD map `_runByChip` (chip ->
// `void Function(WidgetRef, BuildContext)`) checked BEFORE the product-word
// fallback. This deriver is what POPULATES that map: the 6 notif type chips set
// `notifSectionProvider`; each conversation chip sets `updatesChatOpenProvider`.
// The entry section chips (שיחות/התראות) stay REAL [KbDestination]s in
// `destByChip` (they reuse the registry's existing `_openUpdatesSub` runs), so
// only the truly-dynamic per-item chips use `runByChip`. The three maps are
// pairwise-disjoint BY CONSTRUCTION here (asserted in the [KbPredRow] ctor).

import 'package:buildsmart/screens/chats_screen.dart'
    show ThreadLite, updatesChatOpenProvider;
import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbUpdatesChatsNodes, kbUpdatesNotifNodes;
import 'package:buildsmart/screens/notifications_screen.dart'
    show NotifSection, notifSectionProvider;
import 'package:buildsmart/state/updates_location.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Max conversation chips the chats arm emits — reuses the keyboard's own
/// `_kRowCap = 5` budget (thread names can duplicate, so the arm de-dups by
/// visible label first, then caps).
const int _kUpdatesRowCap = 5;

/// The DISPATCH closure shape for a truly-dynamic chip (a conversation or a
/// notif-type chip): run on tap with the floating keyboard's own `ref`/`context`,
/// KEEPING the overlay floating. Byte-identical to the keyboard's
/// `_runByChip` value type, so the keyboard copies [KbPredRow.runByChip] straight
/// into its field. Setting a provider here (notif section / open-chat id) lets
/// the SCREEN react (the keyboard never pushes a route itself — keep-floating).
typedef KbRunByChip = void Function(WidgetRef ref, BuildContext context);

/// A PUBLIC, leaf-ownable mirror of the floating keyboard's private `_PredRow`:
/// the prediction-row [chips] plus the THREE dispatch surfaces the keyboard
/// needs. The keyboard adapts this into its own `_PredRow` in `_rowFor` (a
/// field-for-field copy); it carries no `drillIndexByChip` because the deriver
/// never drills (the עדכונים row is tab/data chips, never tool-tile chips).
///
///   • [chips] — the row labels, already ordered + de-duped + capped by the
///     producing arm.
///   • [destByChip] — chip -> [KbDestination] for the entry SECTION chips
///     (שיחות/התראות): dispatch (ii) runs the registry's nav action.
///   • [runByChip] — chip -> [KbRunByChip] for the truly-dynamic chips
///     (conversation-open / notif-type): dispatch (iii), the NEW map the keyboard
///     checks before the product-word fallback.
///   • [destinationChips] — the subset of [chips] that get the nav glyph in the
///     pure keyboard. Defaults to (destByChip ∪ runByChip) keys: every עדכונים
///     chip is a one-tap nav target (a section, a type filter, or a conversation
///     open), none is a query-narrowing product word, so all are navigable.
///
/// VALUE EQUALITY (plan risk #1): `@immutable` with explicit `==`/`hashCode` over
/// the [chips] list (compared with `listEquals`) and the two map key-sets, so a
/// rebuilt-but-equal context does not churn the location provider. Map VALUES are
/// freshly-allocated closures each build (never structurally equal), so equality
/// keys on the label SETS — which is what actually determines the rendered row +
/// the dispatch routing. Lists are stored unmodifiable.
@immutable
class KbPredRow {
  KbPredRow(
    List<String> chips,
    Map<String, KbDestination> destByChip, {
    Map<String, KbRunByChip> runByChip = const <String, KbRunByChip>{},
    Set<String>? destinationChips,
  })  : chips = List<String>.unmodifiable(chips),
        destByChip = Map<String, KbDestination>.unmodifiable(destByChip),
        runByChip = Map<String, KbRunByChip>.unmodifiable(runByChip),
        _destinationChips = destinationChips == null
            ? null
            : Set<String>.unmodifiable(destinationChips) {
    // DISPATCH DISJOINTNESS (plan, lenses): the dispatch maps the keyboard checks
    // in order must be pairwise-disjoint so the fall-through stays STRUCTURAL, not
    // coincidental. The deriver never drills (no drillIndexByChip), so the only
    // pair that can collide is destByChip vs runByChip — assert it empty.
    assert(
      destByChip.keys.toSet().intersection(runByChip.keys.toSet()).isEmpty,
      'KbPredRow: destByChip and runByChip key-sets must be disjoint '
      '(a chip dispatches via exactly one map).',
    );
  }

  /// The row labels (ordered + capped by the producing arm).
  final List<String> chips;

  /// Section chips (שיחות/התראות) -> their real registry [KbDestination].
  final Map<String, KbDestination> destByChip;

  /// Dynamic chips (conversation-open / notif-type) -> their tap closure.
  final Map<String, KbRunByChip> runByChip;

  final Set<String>? _destinationChips;

  /// The chips that get the nav glyph. Defaults to every dispatchable chip
  /// (destByChip ∪ runByChip keys) — the whole עדכונים row is navigable.
  Set<String> get destinationChips =>
      _destinationChips ??
      <String>{...destByChip.keys, ...runByChip.keys};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KbPredRow &&
          listEquals(other.chips, chips) &&
          setEquals(other.destByChip.keys.toSet(), destByChip.keys.toSet()) &&
          setEquals(other.runByChip.keys.toSet(), runByChip.keys.toSet()) &&
          setEquals(other.destinationChips, destinationChips);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(chips),
        Object.hashAllUnordered(destByChip.keys),
        Object.hashAllUnordered(runByChip.keys),
        Object.hashAllUnordered(destinationChips),
      );
}

/// The atomic output of the live mirror: BOTH halves derived from ONE location
/// snapshot. [row] is the prediction row (the keyboard adapts it into its
/// `_PredRow`); [toolBase] is the THIRD stack-base node-list the keyboard
/// installs (alongside `kbHomeNodes`/`kbKbdNodes`) when no manual grid/gear drill
/// is open — null leaves the existing tool base untouched.
///
/// Value equality so a rebuilt-but-equal context does not churn: equal when the
/// [row] is equal AND the [toolBase] LABELS match (tool nodes hold non-const
/// closures, so we compare the visible label list — what the user sees + taps).
@immutable
class KbUpdatesContext {
  const KbUpdatesContext({required this.row, required this.toolBase});

  /// The prediction-row half of the mirror (adapted into the keyboard's
  /// `_PredRow`).
  final KbPredRow row;

  /// The tool half: the node-list to install as the keyboard's stack base, or
  /// null to leave the current base untouched.
  final List<KbToolNode>? toolBase;

  /// The [toolBase] labels — the stable, comparable projection of the tool nodes
  /// (their closures are never structurally equal, so equality keys on the
  /// labels the user sees).
  List<String> get _toolLabels =>
      <String>[for (final n in toolBase ?? const <KbToolNode>[]) n.label];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KbUpdatesContext &&
          other.row == row &&
          (other.toolBase == null) == (toolBase == null) &&
          listEquals(other._toolLabels, _toolLabels);

  @override
  int get hashCode =>
      Object.hash(row, toolBase == null, Object.hashAll(_toolLabels));
}

/// MEMOIZED label -> entry-section [KbDestination], built ONCE from the registry.
/// The entry chips (שיחות/התראות) are real registry destinations; `kbDestinations`
/// re-allocates the whole ~50-entry list per call, so — exactly like the floating
/// keyboard's own `_kbDestinationByLabel` — we resolve it once into a `late final`
/// map (the registry's labels are unique, so the map is total + unambiguous).
late final Map<String, KbDestination> _entrySectionByLabel =
    <String, KbDestination>{
  for (final d in kbDestinations()) d.label: d,
};

/// The two entry SECTION labels, in owner order (שיחות first), copied
/// byte-for-byte from the registry labels — the SAME pair the keyboard's
/// hardcoded `labelsByTab[2]` shows today, so flag-OFF stays byte-identical and
/// flag-ON's root predictions are unchanged from the existing tab-2 row.
const List<String> _kEntrySectionLabels = <String>['שיחות', 'התראות'];

/// One notification TYPE chip: its label + the [NotifSection] it selects. The 6
/// chips mirror `notifications_screen.dart`'s `_SectionChipsRow` VERBATIM (same
/// labels, same enum values, same order) so the floating row matches the in-list
/// pills exactly. Tapping sets `notifSectionProvider` — the SAME state the pills
/// set — so the live list re-filters and the location re-fires.
const List<({String label, NotifSection section})> _kNotifTypeChips = [
  (label: 'הכל', section: NotifSection.all),
  (label: '📦 משלוחים', section: NotifSection.shipments),
  (label: '🛒 הזמנות', section: NotifSection.orders),
  (label: '🦺 בטיחות', section: NotifSection.safety),
  (label: '💰 תקציב', section: NotifSection.budget),
  (label: '🎁 מבצעים', section: NotifSection.deals),
];

/// THE PURE DERIVER — [UpdatesLocation] (+ live data) -> [KbUpdatesContext], via
/// an EXHAUSTIVE switch over the sealed location (no default: a future location
/// is a compile error here, not a silent fall-through). Deterministic and
/// widget-free: it reads NO providers and NO context; the [threads] AND [notifs]
/// are passed in by the keyboard's `build` as ONE atomic snapshot (plan seam 8),
/// and the selected notif section already rides on the [NotifsLocation] (so the
/// location, plus [threads] + [notifs], is the whole input), and the dispatch
/// closures it returns receive `ref`/`context` LATER at tap time.
///
/// THE [notifs] SNAPSHOT (plan Q1/Q2/Q3 + seam 8): the live notification list,
/// snapshotted alongside [threads] so the two halves of the mirror can never
/// disagree (async-race lens). Phases 0-2 IGNORE its content — the [NotifsLocation]
/// arm still emits the 6 STATIC type chips — but the parameter is part of the pure
/// signature NOW so it preserves the atomic snapshot and unblocks phase 4 (the
/// per-notif Tier-1 chips) without a later signature break. Optional with a
/// `const []` default so every existing caller + unit test stays green; not
/// `required`, because `required` cannot carry a default and the prod call site is
/// owned by the keyboard, not this leaf.
///
///   • [UpdatesRoot]    -> predictions: the two section chips (real
///     [KbDestination]s in destByChip, reusing the registry's `_openUpdatesSub`
///     runs); tools: the active sub-tab's node-list (התראות tools at sub 0, chat
///     tools at sub 1). A tap on a section chip flips `updatesSubTabProvider`,
///     which re-fires the location — the mirror closes its own loop with no new
///     dispatch code.
///   • [NotifsLocation] -> predictions: the 6 TYPE chips (runByChip, each sets
///     `notifSectionProvider`); tools: mark-all-read / notif-settings. The row is
///     NEVER blank (the 6 chips are static), so it works even on the empty live
///     feed.
///   • [ChatsLocation]  -> predictions: one chip per VISIBLE thread (runByChip,
///     each sets `updatesChatOpenProvider` to the thread id; the screen performs
///     the real `_ChatPage` push), de-duped by visible label + capped at
///     [_kUpdatesRowCap]; tools: the chat tools ("בקרוב" leaves + voice). Zero
///     conversations => empty chip list => the row shows tools only (no crash).
KbUpdatesContext deriveUpdatesContext(
  UpdatesLocation location, {
  required List<ThreadLite> threads,
  // Phase-4 atomic-snapshot slot (plan seam 8): the live notif list, ignored by
  // phases 0-2 (the NotifsLocation arm emits 6 static type chips). Typed against
  // the public [NotifSection] today because a leaf file cannot define a public
  // `NotifLite` projection and the private `_Notif` record is not importable; swap
  // the element type to `List<NotifLite>` once finding #1 lands it in
  // notifications_screen.dart. Optional + const-default so every existing caller +
  // unit test stays green (not `required` — that cannot carry a default, and the
  // prod call site is owned by the keyboard, not this leaf).
  List<NotifSection> notifs = const <NotifSection>[],
}) {
  switch (location) {
    // ── Entry / root: section chips + the active sub-tab's tools ──────────────
    case UpdatesRoot(:final subTab):
      final chips = <String>[];
      final destByChip = <String, KbDestination>{};
      for (final label in _kEntrySectionLabels) {
        final d = _entrySectionByLabel[label];
        if (d == null) continue; // registry presence is guaranteed; deref-safe.
        chips.add(label);
        destByChip[label] = d;
      }
      // Tools reflect the active sub-tab (default sub 0 = התראות), so the root
      // already offers the right actions before the user picks a section.
      final toolBase =
          subTab == 1 ? kbUpdatesChatsNodes() : kbUpdatesNotifNodes();
      return KbUpdatesContext(
        row: KbPredRow(chips, destByChip),
        toolBase: toolBase,
      );

    // ── התראות: the 6 always-safe type chips + notif tools ────────────────────
    case NotifsLocation():
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      for (final chip in _kNotifTypeChips) {
        chips.add(chip.label);
        final target = chip.section;
        runByChip[chip.label] = (ref, context) =>
            ref.read(notifSectionProvider.notifier).state = target;
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbUpdatesNotifNodes(),
      );

    // ── שיחות: the real conversation chips + chat tools ───────────────────────
    case ChatsLocation():
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      for (final t in threads) {
        if (chips.length >= _kUpdatesRowCap) break;
        // De-dup by VISIBLE label: thread names can duplicate (e.g. the
        // contractor sees the same display name for several worker threads), so
        // the first chip with a given label wins and the rest collapse — the row
        // stays unambiguous and each label maps to exactly one id.
        if (runByChip.containsKey(t.name)) continue;
        final id = t.id;
        chips.add(t.name);
        runByChip[t.name] = (ref, context) =>
            ref.read(updatesChatOpenProvider.notifier).state = id;
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbUpdatesChatsNodes(),
      );
  }
}
