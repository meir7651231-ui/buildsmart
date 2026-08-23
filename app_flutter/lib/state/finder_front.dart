// finder_front — the "salesperson leads on open" front-door decision.
//
// OWNER pivot (the whole keyboard debate, 2-3/7): opening the floating keyboard
// on the קטלוג tab must LEAD with the product-finder ("the salesperson"), NOT a
// grid of navigation tools — while the full navigation/long-tail stays reachable
// and the user never "chooses a mode". The swarm design that all three judgment
// panels converged on ("Context Picks the Lead", see New folder/
// KEYBOARD-COMPLETE-MAP.md) makes this STRUCTURAL, not a ranking: the host reads
// its once-per-build "where am I?" snapshot ([catalogLocationProvider]) and a
// PURE classifier picks WHICH layer leads.
//
// This file is the spine of that design: ONE compile flag + ONE pure exhaustive
// classifier. Both fold away when the flag is OFF, so a plain production build is
// byte-identical (the mirror row renders exactly as today).

import 'package:buildsmart/state/catalog_location.dart';

/// Compile flag: when ON, the floating keyboard's קטלוג (tab 0) surface LEADS
/// with the product-finder ("the salesperson") on browse/landing locations,
/// instead of the live-mirror tool row. Turned on per-build with
/// `--dart-define=FINDER_FRONT=true`.
///
/// DEFAULT OFF (`bool.fromEnvironment`, absent define ⇒ const-false): every
/// touchpoint is gated on this const, so dart2js folds the branch out and the
/// keyboard is byte-identical to today (the mirror row + tools). The owner
/// cut-over (flipping it on for all users) is a SEPARATE explicit step —
/// exactly like `kKbLiveMirror` / KB_GLOBAL.
const bool kFinderFront = bool.fromEnvironment('FINDER_FRONT');

/// PURE: does the קטלוג surface at [loc] LEAD with the finder (the salesperson),
/// or with the live-mirror navigation row?
///
/// The rule (owner-reviewable, one deliberate arm per the swarm's ownerQuestion
/// Q1): lead with the FINDER only on a BROWSE / LANDING surface — the smart-home
/// landing ([CatalogHome]) and the smart-tree GRID ([CatalogSmartTree] with no
/// category picked). Everywhere the user is ALREADY browsing a concrete list —
/// a user list section ([CatalogSection]), a picked smart-tree category
/// ([CatalogSmartTree] with `smartCat != null`), or an open drill
/// ([CatalogDrill]) — lead with the MIRROR, because there the mirror is the
/// right lead (you are mid-browse, the finder would fight the list).
///
/// EXHAUSTIVE switch over the sealed [CatalogLocation] (no default): a future
/// fifth location is a compile error here, not a silent mislead. So the
/// "which layer leads" decision moves ONLY when the user navigates — the same
/// gesture that already re-derives the mirror — and is never a control the user
/// throws (the "no mode choice" guarantee, by construction).
bool catalogLeadsWithFinder(CatalogLocation loc) => switch (loc) {
      CatalogHome() => true,
      CatalogSmartTree(:final smartCat) => smartCat == null,
      CatalogSection() => false,
      CatalogDrill() => false,
    };
