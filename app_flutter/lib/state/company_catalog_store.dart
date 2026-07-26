// ─────────────────────────────────────────────────────────────────────────────
// Company-catalog store — persistence + pre-runApp hydration for the owner
// IMPORT feature: ONE code, each company pours its OWN catalog into the
// `resolvedCatalogProducts` seam (data/catalog_source.dart) via
// [setCompanyCatalog].
//
// Load-order invariant: `main()` awaits [hydrateCompanyCatalog] BEFORE runApp,
// so every lazy whole-catalog snapshot (_skuIndex · _catalogByName ·
// _kCatalogProductCats) already sees the imported list on its first read.
//
// Only the 'clean' shell hydrates (the [kProfileEmptyCatalog] guard): demo /
// buildsmart exit on the first line, so their resolved universe stays the
// SAME objects as today (the stage-3 identity pin) — and the whole test suite
// is define-less ⇒ profile 'demo' ⇒ it never hydrates, by construction.
//
// Phase B swaps this LOADER for the server chain (catalog_sync); the sink —
// [setCompanyCatalog] into the one seam — stays unchanged.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_source.dart' show setCompanyCatalog;
import 'package:buildsmart/data/company_catalog_import.dart'
    show decodeCompanyCatalog, encodeCompanyCatalog;
import 'package:buildsmart/data/company_spec_bridge.dart'
    show registerCompanySpecs;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/state/app_profile.dart' show kProfileEmptyCatalog;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// Where the imported company catalog persists across launches (JSON).
const String kCompanyCatalogKey = 'bs.company-catalog.v1';

/// Read the persisted company catalog and install it as the runtime overlay —
/// called once in `main()`, awaited BEFORE `runApp`.
///
/// Clean-shell only: on demo/buildsmart the guard exits before touching prefs,
/// so their catalog stays byte-identical. A corrupt blob is IGNORED, never
/// cleared (iron-rule-1, the catalog_sync corrupt-cache spirit): the shell
/// stays empty and the owner simply re-imports.
Future<void> hydrateCompanyCatalog() async {
  if (!kProfileEmptyCatalog) return; // demo/buildsmart: overlay never engages
  try {
    // getInstance INSIDE the guard (the trades_store/share_log precedent): a
    // missing prefs platform degrades to "no overlay", never a startup crash.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kCompanyCatalogKey);
    if (raw == null) return; // nothing imported yet — the shell stays empty
    final items = decodeCompanyCatalog(raw);
    if (items == null) {
      // DO NOT clear: keep the blob for a re-import / post-mortem (iron-rule-1).
      debugPrint('CompanyCatalog: corrupt cache (ignored — awaiting re-import)');
      return;
    }
    setCompanyCatalog(items);
    // The connections brain pours in with the catalog — pre-runApp, so every engine cache sees it.
    registerCompanySpecs(items);
  } on Object catch (_) {/* no prefs platform → overlay stays OFF */}
}

/// Persist an imported catalog under [kCompanyCatalogKey]. Returns `false` on
/// a storage failure (e.g. web quota) so the import UI can tell the owner the
/// import won't survive a restart. Deliberately does NOT call
/// [setCompanyCatalog] — the caller installs the overlay explicitly, so the
/// runtime effect never silently diverges from what was (not) persisted.
Future<bool> persistCompanyCatalog(List<LipskeyCatalogProduct> items) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kCompanyCatalogKey, encodeCompanyCatalog(items));
    return true;
  } on Object catch (e) {
    debugPrint('CompanyCatalog: persist failed (quota?): $e');
    return false;
  }
}

/// Forget the imported catalog: remove the persisted blob AND drop the runtime
/// overlay — the resolved universe falls back to the profile's compile-time
/// branches on the next read.
Future<void> clearCompanyCatalog() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kCompanyCatalogKey);
  } on Object catch (_) {/* best-effort */}
  setCompanyCatalog(null); // the overlay drops even if prefs removal failed
}
