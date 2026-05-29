# Status snapshot — app_flutter

_Version label: `v5.04` (see `home_shell.dart`). Update on each user-visible change._

## Tabs & screens — all light-mode, readable
- **קטלוג** — opens on **בית (finder home)** as the default landing: layman
  group→sub→narrow with relevance-ranked forgiving search. Each group row shows a
  plain-Hebrew description + product-count badge (same idiom as the category rows).
  Other sections: overview blocks (categories / recent / compat / favorites /
  smart-tree), in-tab drill, grid↔list product view, smart-tree, search panel.
- **שיחות** — thread list, conversation, archive screen, new-chat, mute-all.
- **התראות** — grouped list with per-type + importance filtering, snooze.
- **חנות** — sections all/cart/orders/services, full cart + checkout.
- **הגדרות** (×4: catalog/chat/notif/store) — light, count-badge headers.
- product sheet / detail / brand / suppliers / install-studio — light-mode.

## Wiring (≈26 settings/buttons wired to real effects)
See `../WIRING.md` for the full table. Highlights:
- **Catalog**: searchHistory, quickFilterBar, imageSize, compactMode,
  reducedMotion, highContrast, textSize, viewMode, gridColumns (+ clear/reset).
- **Chat**: botEnabled, typingIndicator, readReceipts, chatVibration,
  greetingEnabled, lastSeenPrivacy.
- **Notifications**: per-type filter (orders/shipments/deals/price-drops),
  importanceFilter, snooze.
- **Store**: defaultPayment, selfPickupDefault, vatInclusive, minOrderAmount,
  confirmLargeOrder/threshold, cart stepper, saveCartToProject.
- **Chats screen**: search/filter, open, swipe-archive (persistent), new-chat,
  archive screen, mute-all (persistent), settings, send.

## Persistent state
SharedPreferences: catalog/chat/notif/store settings, chat archived ids,
chat muted ids. Cart is in-memory (`smart_cart`).

## Blocked (⛔ — not locally wireable)
Prices/VAT-display/currency/unit-price/comparison · supplier rating/distance ·
AI recommendations · system notifications (push/email/sms/quiet-hours/summaries/
sound/lock-screen) · media/backup/telephony (video/call/camera/attach) ·
addresses/invoices/warranty/biometric. All need data, a server, or device APIs.

## Install Studio (v3.79 — BOM quality upgrade)
- **Entry = "תכנון חיבור"** — the catalog section chip (renamed from "תאימות" for
  a non-technical name); screen header + empty state speak plain Hebrew, and
  safety-checklist acronyms carry a plain gloss (e.g. "ברז ערבוב נגד כוויה (TMTV)").
- **Light theme (v4.69)** — the studio + audit screen were re-skinned from the
  dark "blueprint" look to the app's light + orange-brand language (white cards,
  `#1A1A1A` ink, brand-orange primary action, green "all-good"), so they no longer
  break the otherwise-light app. Role colors kept (blue supply / amber drain /
  violet fixture), tuned for contrast on light.
- **Consistent navigation (v4.70)** — studio bottom-sheets (picker / BOM /
  projects) now carry the app's standard close-X (`_SheetClose`, like the product
  sheet); the audit screen uses a custom RTL header instead of a Material AppBar;
  and the catalog's list-management dialogs + popup menu were flipped from dark to
  light. No consumer-facing dark surfaces remain.
- **Progressive dock** — 3-state UX: empty / 1-item / 2+ items (D-013)
- **Zone-aware BOM** — "גזע" + "ענף א/ב/ג…" section headers with item counts
- **TMTV auto-per-branch** — one thermostatic mixing valve per hot branch, qty = branch count
- **Auto-compliance** — PRV + BladderTank + isolation ball valve auto-inserted for hot lines
- **Severity checklist** — 🔴 critical / 🟡 warning / 🔵 info; "N קריטי פתוח" badge in BomSheet
- **Gap advice** — `gapAdviceHe()`: a supply↔drainage gap says "connect via a
  fixture" (no adapter exists); a same-system gap names the two unmet ends.
- **Heat-rating banner** — flags any plan item whose material can't survive the
  line temp (e.g. an HDPE anchor on a 60°C line); the engine already routes
  around unsuitable materials, this catches the user-picked anchor.
- **Joint-method BOM** — `lineStructureText()`: the "מבנה הקו" block in the
  installer/WhatsApp export states the joint per item (תבריג ½″ / אום הידוק DN32)
  via the shared `chainEdgeLabelHe`.
- **Safety placed in its physical spot (v4.76)** — auto-compliance no longer
  piles items at the list end: TMTV is inserted immediately at the manifold/
  shower it protects, and the hot-source group (shutoff · expansion vessel ·
  PRV) clusters at the inlet. Dielectric stays at the metal seam. So the chain
  reads correctly one-after-another with each in-line item where it belongs.
- **Drainage ≠ supply (v4.87)** — `lineIsSupply()` gates supply compliance: a
  gravity drainage line (traps + drain pipe) never gets a supply isolation ball
  valve / PRV (a supply valve can't connect to a drain trap). Fixes a chain that
  read מחסום → ברז כדורי → מצמד (impossible).
- **Chain materialization (v4.87)** — `materializeChain` / `buildInstallation`
  insert the component that physically spans each compression joint, so the BOM
  is complete and 100% direct: fitting↔fitting → the bridging PIPE (real
  drainage SKU or a synthetic "cut-to-length" supply pipe); pipe↔pipe → the
  COUPLING that joins them; pipe↔fitting → already direct. Audited: 230 physical
  paths → 100% direct links; 9340 carousel hits → 0 false mates; synthetic
  PIPE-* specs never leak into the product card (`compatibleProductsFor` filters
  on `kLipskeyCatalog`). Guards: `materialize_test`, `drainage_no_supply_test`.
- **ΔP bottleneck fix (v4.76)** — `estimatePressureDrop` excludes off-line side
  branches (¼″ Legionella sampling tap, air vent, expansion tank) from the
  bore/K calc; they were wrongly read as the in-line bottleneck (bogus ~4.8 bar
  on a recirc line). Guarded by `pressure_drop_offline_test`.
- **Temperature pill** — human labels (קר / חם / חם מאוד) with color coding;
  engine regression has a temperature-routing module (hot line excludes
  low-temp materials).

## Compatibility & install engine (v4.55–v4.59 — correct-by-construction)
- **Verified-spec graph** — `lipskey_verified_connections.dart`: 808/935 SKUs
  carry a `VerifiedSpec` (ends + material + system). A real joint is either a
  `directMatesWith` (thread/press/drain) or a `pipeSharedWith` compression
  socket — the latter counts only when EXACTLY ONE side is a pipe and the
  materials are family-compatible. So a coupling never "connects" to a coupling.
- **Connector coverage = 100% (gated)** — the headline 86% is diluted by
  accessories. `needsConnectionSpec()` excludes `kNonConnectorCategories`
  (seats/clamps/brackets/tools/mechanisms…) + `kSpecExemptSkus` (gaskets,
  bolt-sets, spray-guns); over real flow-connectors coverage is 808/808.
  `compat_coverage_test` turns red if a NEW connector ships without a spec.
- **"Why it matches" labels** — `connectionExplainHe()` shows the exact joint
  per carousel item (תבריג ½″ / אום הידוק DN32 / Press PEX 16), so matches are
  verifiable by eye. Invariant: every compat hit has a non-empty label.
- **One joint vocabulary** — `connectionJoint()` + `jointLabelHe()` are the
  single source of truth; the carousel and the install-studio `ChainDiagram`
  now read the SAME wording for the same joint (`chainEdgeLabelHe` adds only the
  "צינור DN…" implicit-pipe bridge between two fittings). Guarded by
  `connection_joint_test`.
- **Bore-aware routing** — `findShortestPath` / `findAlternativePaths` (Yen
  K-shortest) in `install_engine.dart`; `_edgeCost` weights family transitions,
  rewards direct mates and penalises narrow bores → BFS builds wide chains.
- **Full auto-compliance** — `_autoAddCompliance` inserts every safety item at
  its canonical chain position (shutoff, Bladder, PRV, TMTV, dielectric union,
  PEX expansion, recirc valves, pump strainer/flex). Goal: 0 critical open by
  construction, across all 14 checks (critical + warning + info).
- **Pressure-drop physics** — `pressure_drop.dart`: Darcy–Weisbach with
  Reynolds-aware friction, static head, per-fitting K-values, ת"י 1205 drainage
  slope. Returns ΔP, min bore, bottleneck + flow-fix suggestions.
- **Install kit** — `install_kit.dart` / `installKitFor` derives wrenches /
  crimpers / sealants from a product's actual ends.
- **Saved projects** — `state/saved_projects.dart` (SharedPreferences) +
  Install-Studio save/load/rename; **audit screen** runs 20 random scenarios live.

## Product card — info strips (v4.55)
The internal product sheet (`lipskey_product_sheet.dart`) renders the cloud chip
system PLUS seven inline-expand strips that pull data INTO the card (no nav):
מאתר · תאימות · ערכת התקנה · וריאנטים · תקינות · מפרט הנדסי · מחיר. Helpers in
`data/related_info.dart`.

## Catalog chip system (v4.48–v4.50)
Product name words are parsed into colored chips in the product list and sheet:
- **Type chip** (purple) — from `kLipskeyTypes` (e.g. ברז, זווית, מסעף, פיית, כפה)
- **Model chip** (blue-grey) — from `kLipskeyModels` (e.g. קיסר, NTM, HDPE, PP-MD-ML)
- **Color chip** (pink) — from `kLipskeyColors`
- **Subtype chip** (teal) — from `kLipskeySubtypes` (e.g. כפול, פ.פ, ח.פ, פרח, ראש, נשלף)
- **Size chip** (amber) — numeric/DN tokens
- **Green linkable words** — remaining words; tap searches by that word

Variant pickers (type/model/color/subtype) expand inline on chip tap in both
the product list card and the product detail sheet.

## Tests
40+ test files across `test/`. Key suites:
- **chip_structure** — chip type assignment + sibling pickers (31 checks)
- **dedup** — variant dedup + attrWordSet (27 checks)
- **product_journey** — 8 specific products + all 935 sheets render (49 checks)
- **widget** — shell boots + section previews
- **install_builder / manifold / loop / zone_tmtv / auto_compliance** — BOM engine (50 checks)
- **compat_50_samples / dn_pipe_gaps / find_all_four** — compatibility correctness (0 false mates)
- **pressure_drop(_advanced) / alt_paths / long_chain** — routing + ΔP physics
- **full_compliance_audit / ten_scenarios_audit** — 0 critical open across scenarios
- **install_kit / product_sheet_strips / compat_coverage** — kit derivation + card strips + coverage
- **catalog_health / catalog_regression / robustness** — catalog data integrity
- **wiring / knowledge_protocol** — search synonyms + finder grouping + protocol "teeth"
- **cart_bulk_order / cart_stress** — real cart: 20-product order + 50 hard
  scenarios + mutation edge cases (units · subtotal · VAT · delivery · total)

**In-app full-regression button** (`🔬 מרכז בדיקות רגרסיה`, the
`▶ הרץ בדיקת רגרסיה מלאה` action): the harness in `lib/test_harness/` mirrors
these guarantees so any device can self-test. Modules: dsync · tabs · buttons ·
products · behavior · dupes · sections · settings · catalog · finder · **מנוע**
(`tests/engine.dart` — compat validity, no fitting↔fitting, chain build,
auto-compliance, ΔP, install-kit) · **סל** (`tests/cart.dart` — unit count
not line count, line+accessory totals, VAT/delivery/total, JSON persistence
round-trip). Filterable by the `מנוע` / `סל` pills.

`flutter analyze` clean; `flutter test` green (pre-existing failures in
`category_scan_test` and `wiring_test` are catalog-data issues, not code bugs).

## Known placeholders (🚧)
Chats conversation header (video/call/more) and input bar
(camera/attach/emoji) still show "בבנייה" toasts.
