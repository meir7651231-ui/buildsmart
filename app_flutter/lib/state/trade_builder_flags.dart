// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · Pillar #2 — No-Code Domain/Vertical Builder · Step 31.
//
// Three default-OFF runtime tier names that "hold the place" for the whole
// trade-builder pillar. Like [kKbLiveMirrorFlag] / 'kStudio', each is consumed via
// `featureFlagsProvider.isOn(<flag>)` at a FUTURE branch point, and each stays OFF
// because it is absent from the persisted set AND from
// `FeatureFlagsNotifier._forcedOnFlags` (which stays `{}` except the demo defines).
//
// No live branch reads any of them yet — steps 31-50 add the consumers — so a
// normal build is byte-identical / answer-equivalent. Naming them here (not inline
// string literals) keeps every call-site from stringly-typing the flag, exactly the
// `kKbLiveMirrorFlag` pattern (`feature_flags.dart:23`).
//
// OWNER-REVIEW: the trade builder is owner-gated like the Studio — never add any of
// these to `_forcedOnFlags`; the only runtime path is the owner-staged `enable(...)`.
// ─────────────────────────────────────────────────────────────────────────────

/// The no-code trade BUILDER — the authoring UX where the owner creates a new
/// trade/vertical (categories · attributes · products · rules). Read at the builder
/// entry point (Pillar-2, ~step 44+) via `featureFlagsProvider.isOn(kTradeBuilderFlag)`.
/// Default OFF.
const String kTradeBuilderFlag = 'kTradeBuilder';

/// The trade STUDIO — live, inline editing of an authored trade's
/// categories/products/connection-rules (reuses Pillar-1's R9 inline-edit idiom).
/// Read at the trade-studio entry (Pillar-2, ~step 46+). Default OFF.
const String kTradeStudioFlag = 'kTradeStudio';

/// The bulk IMPORT pipeline — CSV/sheet → authored trade rows (defers heavy
/// scale/search to Pillar-5). Read at the import entry (Pillar-2, ~step 48+).
/// Default OFF.
const String kTradeImportFlag = 'kTradeImport';
