// ─────────────────────────────────────────────────────────────────────────────
// Org-config store — persistence + pre-runApp hydration for the giant-system
// ORG CONFIG (config/org_config.dart): WHICH org shape is in force. V1 lands
// the plumbing only — hydrate → [orgConfigProvider] — nothing consumes the
// config yet, so the app renders exactly as today.
//
// Load-order invariant: `main()` awaits [hydrateOrgConfig] BEFORE runApp —
// and before `hydrateCompanyCatalog` — then pours the result into
// [orgConfigProvider] via a ProviderScope override, so the very first frame
// already sees the resolved org.
//
// Channels: V1 feeds [resolveOrgConfig] ONLY the owner-override blob
// persisted under [kOrgConfigKey] (`ownerJson` — the V5 wizard writes it);
// the server chain later adds `companyJson`, and the resolver stays the ONE
// precedence seam (the company_catalog_store Phase-B shape).
//
// DoD: flag OFF ([kOrgConfigFlag] — every define-less build, so the whole
// test suite by construction) ⇒ [hydrateOrgConfig] exits on its FIRST line
// with ZERO I/O, every un-overridden context reads [kDefaultOrgConfig], and
// the app stays byte-identical.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart'
    show OrgConfig, decodeOrgConfig, encodeOrgConfig, kDefaultOrgConfig,
        kOrgConfigFlag, kOrgConfigKey, resolveOrgConfig;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The org config in force, app-wide.
///
/// **Defaults to [kDefaultOrgConfig]** for every context that does NOT
/// override it — notably the whole define-less test suite — the
/// `welcomeSeenProvider` idiom (state/onboarding_gate.dart): the real app
/// overrides it in `main()` with the [hydrateOrgConfig] result. A
/// `StateProvider` (not a plain `Provider`) so the V5 wizard can set the
/// config LIVE after a save, with no restart.
final orgConfigProvider = StateProvider<OrgConfig>((_) => kDefaultOrgConfig);

/// Read the persisted owner override and resolve the org config — called once
/// in `main()`, awaited BEFORE `runApp` (and before `hydrateCompanyCatalog`);
/// the caller pours the result into [orgConfigProvider].
///
/// [enabled] defaults to [kOrgConfigFlag] and is INJECTABLE because
/// `flutter test` does NOT forward --dart-define to library consts (the
/// state/feature_flags.dart note) — tests pass `enabled: true` to drive the
/// ON path. Flag OFF exits on the FIRST line with zero I/O, so a define-less
/// build stays byte-identical. A corrupt blob is IGNORED, never cleared
/// (iron-rule-1, the company_catalog_store spirit): the default stays in
/// force and the owner simply re-saves.
Future<OrgConfig> hydrateOrgConfig({
  bool enabled = kOrgConfigFlag,
  String? companyJson,
}) async {
  if (!enabled) return kDefaultOrgConfig; // flag OFF: hydration never engages
  try {
    // getInstance INSIDE the guard (the company_catalog_store precedent): a
    // missing prefs platform degrades to "the default", never a crash.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kOrgConfigKey);
    final rawValid = raw != null && decodeOrgConfig(raw) != null;
    if (raw != null && !rawValid) {
      // DO NOT clear: keep the blob for a re-save / post-mortem (iron-rule-1).
      debugPrint('OrgConfig: corrupt cache (ignored — lower lanes in force)');
    }
    // V6 — a readable blob rides the OWNER lane; the deploy-baked
    // [companyJson] (main passes [kOrgCompanyJson]) rides the COMPANY lane
    // UNDER it. Precedence lives in the ONE resolver seam: a corrupt/absent
    // owner falls to the company slice, and only then to the default — so a
    // baked channel boots branded even before the wizard ever saves.
    return resolveOrgConfig(
      ownerJson: rawValid ? raw : null,
      companyJson: companyJson,
    );
  } on Object catch (_) {
    // No prefs platform → hydration degrades to the default, never a crash.
    return kDefaultOrgConfig;
  }
}

/// Persist an org config under [kOrgConfigKey]. Returns `false` on a storage
/// failure (e.g. web quota) so the wizard can tell the owner the config won't
/// survive a restart. Deliberately does NOT touch [orgConfigProvider] — the
/// caller sets the live state explicitly, so the runtime effect never
/// silently diverges from what was (not) persisted.
Future<bool> persistOrgConfig(OrgConfig config) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kOrgConfigKey, encodeOrgConfig(config));
    return true;
  } on Object catch (e) {
    debugPrint('OrgConfig: persist failed (quota?): $e');
    return false;
  }
}

/// Forget the persisted owner override: the NEXT hydration resolves to
/// [kDefaultOrgConfig]. Like [persistOrgConfig] this deliberately does NOT
/// touch [orgConfigProvider] — the caller resets the live state explicitly.
Future<void> clearOrgConfig() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kOrgConfigKey);
  } on Object catch (_) {/* best-effort */}
}
