// ─────────────────────────────────────────────────────────────────────────────
// AppBrand — the company-identity single source (stage-3.2,
// PLAN-buildsmart-clean-master · מיתוג → config).
//
// Company #2 = change THESE constants (+ the platform-shell checklist in
// knowledge/BRAND_SWAP_CHECKLIST.md). Everything user-visible that says the
// company name routes through [AppBrand.name] via const string interpolation —
// `'מועדון ${AppBrand.name}'` is a CONSTANT expression (statics interpolate
// const), so every existing `const` widget/list stays const and the default
// build stays byte-identical.
//
// Deliberately NOT here:
//   • the visual palette — `BsTokens` (theme/tokens.dart) stays the single
//     color source (a brand recolor edits tokens, not this file);
//   • the topbar wordmark — already Studio-overridable
//     (`CfgText('home.topbar.brand')`); this file supplies the compiled
//     fallback layer Studio overrides;
//   • Firebase project / applicationId / store listing — release-engineering
//     per company (stage-4), listed in the swap checklist;
//   • the `package:buildsmart/...` import namespace — user-invisible.
//
// NOTE: the name `BrandProfile` was NOT used — `domain/brand_profile.dart`
// already owns it (product-manufacturer profiles: Polyroll/Huliot/Lipskey).
// ─────────────────────────────────────────────────────────────────────────────

/// The app's company identity. Swap per company; defaults = BuildSmart,
/// byte-identical to the pre-3.2 hardcodes.
abstract final class AppBrand {
  /// The product/company display name — interpolated into titles, the club
  /// cluster, share/export texts, PDF headers/footers and legal mentions.
  static const String name = 'BuildSmart';

  /// The share deep-link origin (product links: `$shareDomain/p/<sku>`).
  static const String shareDomain = 'https://buildsmart.app';

  /// The club cluster title (rewards/profile/keyboard/search surfaces).
  static const String club = 'מועדון $name';
}
