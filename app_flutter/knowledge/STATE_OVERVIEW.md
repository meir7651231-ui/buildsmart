# State Overview — `lib/state/*.dart`

Index of every state file in the app, the type it manages, whether it
persists, the SharedPreferences key (if any), the ROADMAP step that shipped
it, and a one-line purpose. Saves the next agent/developer from spelunking.

There are ~28 state files; this doc inventories all of them.

## Inventory (alphabetical)

| File | State type | Persisted? | Key | Step | Purpose |
|---|---|---|---|---|---|
| `ab_experiments.dart` | `Map<String, String>` | ✓ JSON | `bs.ab-experiments.v1` | 92 | Deterministic A/B variant assignment per experiment name |
| `analytics_log.dart` | `List<AnalyticsEvent>` | — in-memory | — | 91 | Bounded analytics-event log (newest first), no persist |
| `app_settings.dart` | `AppSettings` record | ✓ Preact-shared | (legacy) | — | App-wide settings ported from Preact (R1 R2 R6 contract) |
| `brand_history.dart` | `Map<key, Map<brand, int>>` | ✓ JSON | `bs.brand-history.v1` | 51 | Tracks brand-pick frequency per SmartProduct |
| `card_detail_mode.dart` | enum `simple`/`expert` | ✓ string | `bs.card-detail-mode.v1` | 95 | Card depth toggle — gates the 📦 advanced rows |
| `card_projects.dart` | `List<ProjectItem>` | ✓ JSON | `bs.card-projects.v1` | 71 72 74 75 80 | Assign products to a project location + templates |
| `card_selection.dart` | `Map<key, brandName>` | ✓ JSON | `bs.card-brand-selection.v1` | 7 | Restore last picked brand per SmartProduct |
| `card_versions.dart` | `List<ConfigVersion>` | ✓ JSON | `bs.card-versions.v1` | 76 | Named snapshots of (product + brand) for comparison |
| `cart_lists_state.dart` | `Map<id, CartList>` | ✓ JSON | (own key) | — | Saved/named cart lists (legacy/cart subsystem) |
| `cart_safety.dart` | (no notifier; pure helpers) | — | — | 46 | Convert engine safety SKUs → `SmartCartAcc` for cart-add |
| `catalog_settings.dart` | `CatalogSettings` record | ✓ Preact-shared | (legacy) | — | View prefs (image size · grid · contrast · text size …) |
| `chat_settings.dart` | `ChatSettings` record | ✓ Preact-shared | (legacy) | — | Chat tab settings (bot · receipts · greeting · privacy) |
| `comparison_set.dart` | `Set<String>` cap 4 | ✓ stringList | `bs.comparison-set.v1` | 76-adj | Product keys queued for side-by-side comparison |
| `crash_log.dart` | `List<CrashEntry>` | — in-memory | — | 90 | Bounded error log; not persisted (sensitive) |
| `dial_state.dart` | enum `OpenDial` | — in-memory | — | R1 | Which FAB dial is open (only one at a time) |
| `draft_quote.dart` | `List<DraftQuote>` | ✓ JSON | `bs.draft-quotes.v1` | 48-adj | Save quote text drafts under a label |
| `feature_flags.dart` | `Set<String>` | ✓ stringList | `bs.feature-flags.v1` | 10 | Enabled feature-flag names; idempotent enable/disable |
| `hidden_catalog_sections.dart` | `Set<String>` | ✓ stringList | `bs.hidden-catalog-sections.v1` | — | Sections the user has chosen to hide (not delete) |
| `menu_state.dart` | per-tab drill lists | — in-memory | — | R1 | Drill paths inside each menu tab |
| `notif_settings.dart` | `NotifSettings` record | ✓ Preact-shared | (legacy) | — | Notifications tab settings |
| `offline_cache.dart` | `Map<key, CacheEntry>` | ✓ JSON | `bs.offline-cache.v1` | 83 | TTL'd cache primitive (get/put/sweep) |
| `product_favorites.dart` | `Set<String>` | ✓ stringList | (own key) | — | Heart-toggled product SKUs |
| `recent_searches.dart` | `List<String>` cap 8 | ✓ stringList | (own key) | 62-prereq | Recent search queries, newest first, deduped |
| `recently_viewed.dart` | `List<String>` cap 20 | ✓ stringList | `bs.recently-viewed.v1` | 66 | SmartProduct SKUs recently opened in the card |
| `saved_configs.dart` | `Set<String>` | ✓ stringList | `bs.saved-configs.v1` | 47 | Single-toggle favourite: `<productKey>#<brandName>` |
| `saved_projects.dart` | `List<SavedProject>` | ✓ JSON | (own key) | — | Install Studio's saved install plans (other subsystem) |
| `smart_cart.dart` | `List<SmartCartLine>` | ✓ JSON | (own key) | — | The smart-tree's shopping cart |
| `stage_progress.dart` | `Set<String>` | ✓ stringList | `bs.stage-progress.v1` | 31 | Install stages marked "done", keyed `key#idx` |
| `store_settings.dart` | `StoreSettings` record | ✓ Preact-shared | (legacy) | — | Store tab settings |

## Groupings

### SmartProduct card UX (10 files)
`card_detail_mode` · `card_projects` · `card_selection` · `card_versions` ·
`cart_safety` · `comparison_set` · `draft_quote` · `recently_viewed` ·
`saved_configs` · `stage_progress`. These are the persisted decisions the
SmartProduct card reads on open and writes on user action.

### History / logs (4 files)
`analytics_log` (in-memory) · `brand_history` (persisted) · `crash_log`
(in-memory) · `recent_searches` (persisted). Two persisted, two in-memory by
design (sensitive payloads not written to disk).

### Infrastructure primitives (3 files)
`feature_flags` (step 10) · `ab_experiments` (step 92) · `offline_cache`
(step 83). New foundations that future features can lean on.

### Pre-Flutter / Preact-shared settings (5 files)
`app_settings` · `catalog_settings` · `chat_settings` · `notif_settings` ·
`store_settings`. All speak the same SharedPreferences shape as the
production Preact app — touching them risks contract drift (R6).

### Cart & projects (5 files)
`smart_cart` · `cart_lists_state` · `cart_safety` · `card_projects` ·
`saved_projects`. Two cart layers (smart-tree cart + lists) and two project
layers (per-card project assignments + Install Studio plans).

### Misc (1 file)
`product_favorites` (the standalone product-favourite heart).
`hidden_catalog_sections` (catalog list management).
`dial_state` + `menu_state` (FAB / menu navigation).

## Persistence keys index

All `bs.*.v1` keys currently in use (sorted):
- `bs.ab-experiments.v1`
- `bs.brand-history.v1`
- `bs.card-brand-selection.v1`
- `bs.card-detail-mode.v1`
- `bs.card-projects.v1`
- `bs.card-versions.v1`
- `bs.comparison-set.v1`
- `bs.draft-quotes.v1`
- `bs.feature-flags.v1`
- `bs.hidden-catalog-sections.v1`
- `bs.offline-cache.v1`
- `bs.recently-viewed.v1`
- `bs.saved-configs.v1`
- `bs.stage-progress.v1`

Future migrations: when bumping a key to `.v2`, leave `.v1` for a release so
old installs don't lose data.

## API mismatch notes

A few state files were shipped by the *other* session (the Install Studio
session) with slightly different conventions than the SmartProduct card's:
- `recent_searches.dart` — uses `kMaxRecentSearches=8` (not a notifier ctor
  param) and an `add` method (not `record`). A test backfill against the
  existing API lives in `test/recent_searches_test.dart` per the
  PLAYBOOK "don't modify existing files" rule.
- `saved_projects.dart` — Install Studio plans (anchorSkus/branchSkus/
  tempC), distinct from `card_projects.dart`. Don't conflate.

When adding new card-side state, mirror the patterns in `card_*.dart` and
`recently_viewed.dart` — they're the canonical templates.
