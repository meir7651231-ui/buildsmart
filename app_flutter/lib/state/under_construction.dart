/// Apple-readiness "build-or-hide" flag.
///
/// When `true` (the default for App Store review), every settings row / section /
/// dial-leaf / portal note that is honestly *backend-blocked* — i.e. it would
/// otherwise show a visible "בבנייה" / "בקרוב" / "עדיין לא משפיע" / "(הדגמה)" /
/// "לא זמין" placeholder — is FILTERED OUT of the visible UI.
///
/// The hide is REVERSIBLE by design: only the *rendering* is suppressed. Every
/// underlying widget, provider field, persisted setting and seed stays in the
/// code, so flipping this single `const` back to `false` re-exposes the whole
/// "under construction" surface exactly as before — the day the backend lands.
///
/// This deliberately mirrors the compile-time gate style already used for
/// `kServerCallables` / `kCloudPhotos` (see data/repositories/backend.dart):
/// one const, asserted deterministically by tests, no runtime/async branch.
///
/// Sanctioned hides that pre-date this flag (electrician/renovation professions,
/// content-less catalog categories, Arabic/English language radio options) are
/// handled by their own owner-approved guards and are NOT governed by this flag.
library;

/// Hide all backend-blocked "under construction" placeholders from the visible
/// UI (Apple review). Flip to `false` to bring them all back.
const bool kHideUnderConstruction = true;

/// Search-index entry titles that point at a now-hidden, backend-blocked
/// feature surface (the AI hub's deferred tools — they render a visible
/// "⚙️ בפרודקשן" placeholder and are filtered out of the hub grid). The live
/// search index ([kVisibleSearchIndex]) drops these while
/// [kHideUnderConstruction] is on, so a reviewer cannot search-navigate to a
/// hidden placeholder. The const entries stay in `kSearchIndex` (reversible).
const Set<String> kHiddenSearchTitles = {
  'התאמה משולשת', // AI 3-way match — needs supplier delivery-note + invoice docs
  'אוטומציית מזג אוויר', // AI weather automation — needs an external forecast API
  'זיהוי בלאי', // AI equipment-wear — needs IoT equipment-hour sensors
};
