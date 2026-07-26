// keyboard_store_deriver — the PURE MIRROR ENGINE for the חנות tab, mirroring
// keyboard_updates_deriver.dart EXACTLY (the proven, gate-green עדכונים pattern).
//
// THE DERIVER IS A PURE FUNCTION: [StoreLocation] (+ the live store data passed
// as params) -> [KbUpdatesContext], where [KbUpdatesContext] (REUSED from
// keyboard_updates_deriver.dart — NOT re-declared) bundles BOTH halves of the
// live mirror as one atomic value: ( [KbPredRow] row , List<KbToolNode>?
// toolBase ). Bundling them is load-bearing (async-race lens): predictions and
// tools derive from the SAME location snapshot, so they can never disagree (no
// "cart chips but orders tools" mismatch).
//
// THE PURITY CONTRACT (very_good_analysis clean, unit-testable despite the
// keyboard's compile flag): [deriveStoreContext] takes ALL data as parameters
// (the cart lines, the orders) and NEVER reads `ref` or `context` itself —
// mirroring `deriveUpdatesContext`'s documented purity. The floating keyboard
// snapshots the data once in `build` (`final cart = ref.watch(smartCartProvider)`
// etc.) and passes it in, so the deriver is deterministic (same location + same
// data in => identical context out) and fully unit-testable with hand-built
// locations. The dispatch closures it returns DO take a `WidgetRef`/`BuildContext`
// — but those are supplied LATER, at tap time, by the keyboard; the deriver only
// CONSTRUCTS the closures, it never invokes them or reads providers itself.
//
// TYPE REUSE (plan invariant — do NOT duplicate): [KbPredRow], [KbUpdatesContext]
// and [KbRunByChip] are IMPORTED from keyboard_updates_deriver.dart so the
// keyboard adapter (`_rowFor` field-for-field copy into `_PredRow`, `_runByChip`
// persistence) is IDENTICAL for both tabs — one adapter, two derivers. This file
// adds NO new carrier types; it only adds the store-flavored arms.
//
// THE SECOND DISPATCH PATH (same as עדכונים). Dynamic cart/order/service chips
// are not static registry destinations, so they belong to NEITHER the keyboard's
// `_destByChip` map nor the product-word fallback; they ride the SECOND map
// `_runByChip` (chip -> `void Function(WidgetRef, BuildContext)`) the keyboard
// checks after `_destByChip` and before the product-word fallback. The entry
// SECTION chips at the root (הסל שלי /
// ההזמנות שלי / שירותים) stay REAL [KbDestination]s in `destByChip` (they reuse
// the registry's existing store-section runs), so only the truly-dynamic per-item
// chips use `runByChip`. The maps are pairwise-disjoint BY CONSTRUCTION here
// (asserted in the reused [KbPredRow] ctor).

import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, kbDestinations;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbStoreNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbPredRow, KbRunByChip, KbUpdatesContext;
import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/orders_engine.dart' show Order;
import 'package:buildsmart/state/smart_cart.dart' show SmartCartLine;
import 'package:buildsmart/state/store_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Max dynamic chips any store arm emits — reuses the keyboard's own
/// `_kRowCap = 5` budget (cart/order labels can duplicate, so each arm de-dups
/// by visible label first, then caps), identical to the chats arm's
/// `_kUpdatesRowCap`.
const int _kStoreRowCap = 5; // Shared budget; matches floating_card_keyboard._kRowCap

/// The three entry SECTION labels at the store root, in owner order — copied
/// byte-for-byte from the registry labels (the SAME triple the keyboard's
/// hardcoded `labelsByTab[3]` shows today, so flag-OFF stays byte-identical and
/// flag-ON's root predictions are unchanged from the existing tab-3 row).
const List<String> _kStoreSectionLabels = <String>[
  'הסל שלי',
  'ההזמנות שלי',
  'שירותים',
];

/// One static SERVICE chip's label — the 6 mirror store_screen.dart's `_kServices`
/// VERBATIM (same labels, same order) so the floating row matches the in-list
/// service rows exactly. The services surface is static (backend-blocked), so —
/// like the עדכונים notif-type chips — these are emitted from a const list. Each
/// has no public per-service opener yet, so tapping is a SAFE keep-floating no-op
/// (re-assert the services section; see [_keepInServices]).
const List<String> _kServiceLabels = <String>[
  'השכרת כלים',
  'פקדונות',
  'החזרה חדשה',
  'מכרז ספקים',
  'גיליונות בטיחות',
  'השוואת מחירים',
];

/// Map an engine [Order] stage to its Hebrew label — REPRODUCED byte-for-byte
/// from store_screen.dart's PRIVATE `_stageLabelFor` (a leaf file cannot import a
/// file-private fn). Single place here so the chip stage text never drifts from
/// the in-list `_Order.stageLabel`. Used to build a readable order chip label
/// ("BS-1042 · בדרך 🚛").
//
// COPIED FROM store_screen.dart _stageLabelFor — NOT shared (a leaf file cannot
// import a file-private fn). Do not edit the cases below without updating
// store_screen.dart's _stageLabelFor in lockstep; if store_screen adds a new
// order stage and this map is not updated, the chip falls back to the raw stage
// string (honest, crash-free) but the label silently diverges from the in-list
// row. A unit test guards label consistency.
String _stageLabelFor(String stage) => switch (stage) {
      'new' => 'התקבלה 🆕',
      'preparing' => 'בהכנה 🔧',
      'ready' => 'מוכן 📦',
      'pickup' => 'ממתין לאיסוף 🏪',
      'transit' => 'בדרך 🚛',
      'delivered' => 'נמסר ✓',
      _ => stage,
    };

/// MEMOIZED label -> entry-section [KbDestination], built ONCE from the registry
/// — identical idiom to `keyboard_updates_deriver.dart`'s `_entrySectionByLabel`
/// and the floating keyboard's `_kbDestinationByLabel`. The entry chips (הסל שלי /
/// ההזמנות שלי / שירותים) are real registry destinations; `kbDestinations`
/// re-allocates the whole ~50-entry list per call, so we resolve it once into a
/// `late final` map (the registry's labels are unique, so the map is total +
/// unambiguous).
late final Map<String, KbDestination> _storeSectionByLabel =
    <String, KbDestination>{
  for (final d in kbDestinations()) d.label: d,
};

/// A SAFE keep-floating tap for a dynamic chip with no real per-item opener yet
/// (a cart line, an order, a service): re-assert the [section] provider. This is
/// a structural no-op when already on that section (the StateProvider skips the
/// notify when the value is unchanged), so the overlay simply STAYS FLOATING and
/// the screen underneath is untouched — the honest "keep-floating" deferral the
/// plan calls for ("runByChip -> a safe action, e.g. scroll-to/keep-floating"),
/// never a route push from the keyboard and never a crash. Wired to a real
/// per-item opener (scroll-to-line / open-order-detail) once those expose a seam.
void Function(WidgetRef, BuildContext) _keepInSection(StoreSection section) =>
    (ref, context) =>
        ref.read(storeSectionProvider.notifier).state = section;

/// An HONEST deferred tap for a dynamic ITEM chip (a cart line / an order) with
/// no real per-item opener yet: surface a brief "בקרוב" hint so the tap does
/// something OBSERVABLE and truthful — NEVER a silent no-op behind an
/// actionable-looking chip. It never navigates, never pushes a route, and never
/// crashes (`maybeOf` is null when there is no ScaffoldMessenger). Swap for the
/// real opener once a per-line / order-detail seam is exposed.
void Function(WidgetRef, BuildContext) _comingSoon(String what) =>
    (ref, context) => ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('$what — בקרוב'),
            duration: const Duration(seconds: 2),
          ),
        );

/// THE PURE DERIVER — [StoreLocation] (+ live data) -> [KbUpdatesContext], via an
/// EXHAUSTIVE switch over the sealed location (no default: a future location is a
/// compile error here, not a silent fall-through). Deterministic and widget-free:
/// it reads NO providers and NO context; the [cart] AND [orders] are passed in by
/// the keyboard's `build` as ONE atomic snapshot, and the dispatch closures it
/// returns receive `ref`/`context` LATER at tap time.
///
/// THE [cart] / [orders] SNAPSHOTS: the live cart lines (`smartCartProvider`) and
/// the live order list, snapshotted together so the two halves of the mirror can
/// never disagree (async-race lens). Both optional with a `const []` default so
/// every existing caller + unit test stays green; not `required`, because
/// `required` cannot carry a default and the prod call site is owned by the
/// keyboard, not this leaf (mirroring `deriveUpdatesContext`'s `notifs` slot).
///
///   • [StoreRoot]      -> predictions: the three section chips (real
///     [KbDestination]s in destByChip, reusing the registry's store-section runs);
///     tools: the section's node-list ([kbStoreNodes]). A tap on a section chip
///     sets `storeSectionProvider`, which re-fires the location — the mirror
///     closes its own loop with no new dispatch code.
///   • [CartLocation]   -> predictions: one chip per CART LINE (runByChip; de-dup
///     by visible label + capped at [_kStoreRowCap]); tools: cart tools (לקופה /
///     רוקן / כספים via [kbStoreNodes]). Empty cart => empty chip list => the row
///     shows tools only (no crash). De-dup by visible label: if two cart lines
///     share the same emoji+name+qty triple they collapse to ONE chip (the first
///     wins); a per-line opener — once exposed — can break the de-dup by keying on
///     a line-index or SKU identifier instead of the collapsible label.
///   • [OrdersLocation] -> predictions: one chip per recent ORDER ("id · stage";
///     runByChip), de-duped + capped; tools: order tools. De-dup by visible
///     label: if two orders share the same id+stage pair only the first is shown.
///     This should never occur in live data (order IDs are unique), but it guards
///     against a corrupted order list (e.g. two "BS-1 · unknown" entries when a
///     stage is unrecognized and falls back to the raw string).
///   • [ServicesLocation]-> predictions: the 6 static SERVICE chips (runByChip,
///     safe keep-floating); tools: service tools. The row is NEVER blank (static),
///     so it works regardless of backend state.
KbUpdatesContext deriveStoreContext(
  StoreLocation location, {
  List<SmartCartLine> cart = const <SmartCartLine>[],
  List<Order> orders = const <Order>[],
  // ORG-GATE (giant-system V2): is the org's `orders.services` feature on? A
  // PURE boolean — the keyboard's build computes `featureOn(cfg, 'orders',
  // 'services')` from its single orgConfigProvider watch and passes the VALUE
  // in, so this leaf stays widget-free and no config object ever reaches (or
  // bakes into) the deriver. Default true ⇒ every existing caller + unit test
  // is byte-identical (absent=on). False drops the שירותים chip from the
  // [StoreRoot] row.
  bool servicesOn = true,
}) {
  switch (location) {
    // ── Root / 'all' hub: section chips + the section's tools ──────────────────
    case StoreRoot(:final section):
      final chips = <String>[];
      final destByChip = <String, KbDestination>{};
      for (final label in _kStoreSectionLabels) {
        // ORG-GATE: a dark services feature drops the שירותים chip — filtered
        // HERE, BEFORE the throwing lookup below (the dept-deriver raw-arm
        // precedent: the LABEL LIST is what narrows, the registry is never
        // filtered, and the loud throw stays for real programmer errors only —
        // a gated-off label can never fire it).
        if (!servicesOn && label == 'שירותים') continue;
        // Registry presence is guaranteed BY CONSTRUCTION (every store-section
        // label owns a KbDestination in keyboard_destinations.dart). Fail LOUD
        // rather than silently dropping the chip: if a future StoreSection is
        // added to the enum but NOT to the registry, a missing destination here
        // would make that section UNREACHABLE from the keyboard root — so
        // surface it at deriver-call time instead of invisibly skipping it.
        final d = _storeSectionByLabel[label] ??
            (throw StateError(
                'PROGRAMMER ERROR: store section "$label" has no KbDestination '
                'in the registry (keyboard_destinations.dart)'));
        chips.add(label);
        destByChip[label] = d;
      }
      return KbUpdatesContext(
        row: KbPredRow(chips, destByChip),
        toolBase: kbStoreNodes(section),
      );

    // ── 🛒 הסל: the real cart-line chips + cart tools ──────────────────────────
    case CartLocation():
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      for (final line in cart) {
        if (chips.length >= _kStoreRowCap) break;
        // A readable, owner-style label: emoji + product name (+ ×qty when >1),
        // matching the cart row's own "<emoji> <name> × <qty>" rendering.
        final label = line.productQty > 1
            ? '${line.productEmoji} ${line.productName} ×${line.productQty}'
            : '${line.productEmoji} ${line.productName}';
        // De-dup by VISIBLE label: the first chip with a given label wins and the
        // rest collapse — the row stays unambiguous.
        if (runByChip.containsKey(label)) continue;
        chips.add(label);
        // No public per-line opener (the cart rows live in private widgets); an
        // HONEST "בקרוב" hint until a per-line seam exists — never a dead no-op.
        runByChip[label] = _comingSoon('פתיחת פריט');
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbStoreNodes(StoreSection.cart),
      );

    // ── 📦 הזמנות: the recent-order chips + order tools ─────────────────────────
    case OrdersLocation():
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      for (final o in orders) {
        if (chips.length >= _kStoreRowCap) break;
        // "BS-1042 · בדרך 🚛" — the id plus the live Hebrew stage label.
        final label = '${o.id} · ${_stageLabelFor(o.stage)}';
        if (runByChip.containsKey(label)) continue;
        chips.add(label);
        // No public per-order opener exposed yet; an HONEST "בקרוב" hint until an
        // order-detail seam exists — never a dead no-op.
        runByChip[label] = _comingSoon('פתיחת הזמנה');
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbStoreNodes(StoreSection.orders),
      );

    // ── 🔧 שירותים: the 6 always-safe service chips + service tools ─────────────
    case ServicesLocation():
      final chips = <String>[];
      final runByChip = <String, KbRunByChip>{};
      for (final label in _kServiceLabels) {
        // _kServiceLabels is a FIXED set of 6 static services (like the 6 notif
        // type chips) — they ALWAYS all render, NO cap (_kStoreRowCap is only for
        // the DYNAMIC cart / orders lists). The de-dup below is structurally dead
        // here (unique labels); kept to mirror the cart/orders arm shape.
        if (runByChip.containsKey(label)) continue;
        chips.add(label);
        runByChip[label] = _keepInSection(StoreSection.services);
      }
      return KbUpdatesContext(
        row: KbPredRow(
          chips,
          const <String, KbDestination>{},
          runByChip: runByChip,
        ),
        toolBase: kbStoreNodes(StoreSection.services),
      );
  }
}
