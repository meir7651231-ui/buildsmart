// keyboard_dept_deriver — the PURE MIRROR ENGINE for the מחלקות tab, mirroring
// keyboard_updates_deriver.dart / keyboard_store_deriver.dart EXACTLY (the
// proven, gate-green pattern).
//
// THE DERIVER IS A PURE FUNCTION: [DeptLocation] -> [KbUpdatesContext], where
// [KbUpdatesContext] (REUSED from keyboard_updates_deriver.dart — NOT
// re-declared) bundles BOTH halves of the live mirror as one atomic value:
// ( [KbPredRow] row , List<KbToolNode>? toolBase ). Bundling them is load-bearing
// (async-race lens): predictions and tools derive from the SAME location
// snapshot, so they can never disagree.
//
// THE PURITY CONTRACT (very_good_analysis clean, unit-testable despite the
// keyboard's compile flag): [deriveDeptContext] takes its location as the only
// parameter and NEVER reads `ref` or `context` itself — mirroring
// `deriveUpdatesContext`/`deriveStoreContext`'s documented purity. The four
// department surfaces are STATIC (no live data to pass — unlike the store cart /
// orders or the updates threads), so the location alone is the whole input and
// the deriver is trivially deterministic (same location in => identical context
// out) and fully unit-testable with a hand-built location. The dispatch actions
// it returns ride on the registry's [KbDestination.run] closures — those take a
// `WidgetRef`/`BuildContext`, but they are supplied LATER, at tap time, by the
// keyboard; the deriver only RESOLVES the destinations, it never invokes them or
// reads providers itself.
//
// TYPE REUSE (plan invariant — do NOT duplicate): [KbPredRow] and
// [KbUpdatesContext] are IMPORTED from keyboard_updates_deriver.dart (the SAME
// carriers the store/updates derivers emit), so the keyboard adapter (`_rowFor`
// field-for-field copy into `_PredRow`) is IDENTICAL for all three tabs — one
// adapter, three derivers. This arm never POPULATES the dynamic `runByChip` map
// (the department chips are static [KbDestination]s, like the עדכונים section
// chips), so it does not even import `KbRunByChip` — the reused [KbPredRow]
// defaults that map to const-empty. This file adds NO new carrier types; it only
// adds the department arm.
//
// THE DISPATCH PATH (same as the עדכונים/חנות ROOTS). The four department chips
// are REAL [KbDestination]s in `destByChip` (dispatch (ii) — the keyboard runs
// the registry's nav action, which is `_openDepartment`: homeDepartmentProvider =
// name + tab 1 + reset the catalog drill). They are NOT dynamic runByChip chips
// (they have a static, verified nav target — exactly like the עדכונים entry
// section chips שיחות/התראות or the חנות section chips), so this arm fills ONLY
// `destByChip` and leaves `runByChip` empty. The maps are pairwise-disjoint BY
// CONSTRUCTION here (asserted in the reused [KbPredRow] ctor).

import 'package:buildsmart/screens/keyboard_destinations.dart'
    show KbDestination, companyDeptDestinations, kbDestinations;
import 'package:buildsmart/state/app_profile.dart' show kProfileRawShell;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode, kbDeptNodes;
import 'package:buildsmart/screens/keyboard_updates_deriver.dart'
    show KbPredRow, KbUpdatesContext;
import 'package:buildsmart/state/dept_location.dart';

/// The four LIVE department labels, in owner order — copied byte-for-byte from
/// the registry labels (the SAME `live == true` quartet
/// `DepartmentsScreen.departments` exposes and the keyboard's hardcoded
/// `labelsByTab[1]` shows today), so flag-OFF stays byte-identical and flag-ON's
/// root predictions are unchanged from the existing tab-1 row. Each owns a real
/// [KbDestination] in keyboard_destinations.dart (reusing `_openDepartment`), so
/// tapping a chip navigates to that department exactly as a department tile does.
///
/// STATIC (no cap): these four are a FIXED set (like the 6 חנות service chips or
/// the 6 עדכונים notif-type chips) — they ALWAYS all render. There is no dynamic
/// list to cap here (the per-department PRODUCT content is the CATALOG phase, not
/// this thin departments-entry scope).
///
// CRITICAL: These 4 labels MUST stay synchronized with: (1)
// keyboard_destinations.dart _openDepartment destinations, (2)
// departments_screen.dart departments list (live == true), (3)
// floating_card_keyboard.dart labelsByTab[1] hardcoded. A rename in ANY source
// breaks the other two. No shared const = no automatic sync. (Future: extract
// these four into a single shared const so all sites derive from one source.)
const List<String> _kDeptLabels = <String>[
  'אינסטלציה',
  'ברזים וסניטריים',
  'כלי עבודה ידני',
  'כלי עבודה חשמלי',
];

/// MEMOIZED label -> department [KbDestination], built ONCE from the registry —
/// identical idiom to `keyboard_updates_deriver.dart`'s `_entrySectionByLabel`,
/// `keyboard_store_deriver.dart`'s `_storeSectionByLabel`, and the floating
/// keyboard's `_kbDestinationByLabel`. The four department chips are real
/// registry destinations; `kbDestinations` re-allocates the whole ~50-entry list
/// per call, so we resolve it once into a `late final` map (the registry's labels
/// are unique, so the map is total + unambiguous).
late final Map<String, KbDestination> _deptByLabel = <String, KbDestination>{
  for (final d in kbDestinations()) d.label: d,
};

/// THE PURE DERIVER — [DeptLocation] -> [KbUpdatesContext], via an EXHAUSTIVE
/// switch over the sealed location (no default: a future location is a compile
/// error here, not a silent fall-through). A future per-department drill would be
/// a new [DeptLocation] subclass + a new arm here + a new deriver branch output,
/// all visible at compile time — no silent fall-through. Deterministic and
/// widget-free: it
/// reads NO providers and NO context; the four department surfaces are static, so
/// the location alone is the whole input, and the dispatch actions it resolves
/// (the registry's `run` closures) receive `ref`/`context` LATER at tap time.
///
///   • [DeptRoot] -> predictions: the four department chips (real [KbDestination]s
///     in destByChip, reusing the registry's `_openDepartment` runs by label);
///     tools: the department node-list ([kbDeptNodes] — עץ חכם / מאתר / מסלול
///     עבודה). A tap on a department chip sets `homeDepartmentProvider` (+ tab 1 +
///     catalog-drill reset) via the registry run; the keyboard keeps floating and
///     the screen underneath opens that department. The four are static (always
///     render, NO cap — like the 6 חנות service / 6 עדכונים notif chips).
KbUpdatesContext deriveDeptContext(DeptLocation location) {
  switch (location) {
    // ── Root: the four department chips + department tools ─────────────────────
    case DeptRoot():
      final chips = <String>[];
      final destByChip = <String, KbDestination>{};
      // Raw shell: the four const departments are gated OUT of the registry
      // (R6), so the by-construction guarantee below no longer holds there —
      // the loud throw would crash the bare shell. The company's derived
      // departments (self-gated: empty pre-import) are the row instead.
      if (kProfileRawShell) {
        for (final d in companyDeptDestinations()) {
          chips.add(d.label);
          destByChip[d.label] = d;
        }
        return KbUpdatesContext(
          row: KbPredRow(chips, destByChip),
          toolBase: kbDeptNodes(),
        );
      }
      for (final label in _kDeptLabels) {
        // Registry presence is guaranteed BY CONSTRUCTION (every live department
        // owns a KbDestination in keyboard_destinations.dart). Fail LOUD rather
        // than silently dropping the chip: if a future live department is added to
        // DepartmentsScreen.departments but NOT to the registry, a missing
        // destination here would make that department UNREACHABLE from the keyboard
        // root — so surface it at deriver-call time instead of invisibly skipping
        // it. This mirrors keyboard_store_deriver.dart's StoreRoot throw-on-miss
        // EXACTLY (same StateError-on-`null` idiom).
        //
        // DELIBERATE DIVERGENCE from keyboard_updates_deriver.dart's UpdatesRoot,
        // which on a registry miss does `if (d == null) continue;` (defensive,
        // non-throwing). All three roots resolve a STATIC, byte-from-registry label
        // list (_kDeptLabels here / _kStoreSectionLabels / _kEntrySectionLabels)
        // whose presence is equally guaranteed, so neither branch can actually fire
        // — the difference is purely the error STRATEGY, not behavior. dept+store
        // throw (loud: a programmer error becomes a crash, not a vanished chip);
        // the updates root `continue`s (quiet). The loud form is preferred for the
        // department/store roots because a silently dropped chip there breaks
        // navigation invisibly; the updates root's quiet `continue` is acceptable
        // and intentionally left as-is. Both are correct; this arm follows the
        // store root.
        // Labels are compile-time constants from _kDeptLabels; the interpolation
        // is safe and aids debugging this rare programmer error.
        final d = _deptByLabel[label] ??
            (throw StateError(
                'PROGRAMMER ERROR: live department "$label" has no KbDestination '
                'in the registry (keyboard_destinations.dart)'));
        chips.add(label);
        destByChip[label] = d;
      }
      return KbUpdatesContext(
        row: KbPredRow(chips, destByChip),
        toolBase: kbDeptNodes(),
      );
  }
}
