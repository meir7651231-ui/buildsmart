# PROJECTS_GUIDE — Phase-8 projects features reference

Developer-facing reference for the "projects" capability shipped from the
SmartProduct card (roadmap Phase 8, steps 71–80). One stop for understanding
what is in, what is wall-blocked, and the pattern to extend it.

---

## What "projects" means in the card

The SmartProduct card lets a user assign a chosen product (at its currently
selected brand) into a **named project bucket** with a **location** (room).
A project is therefore a flat list of `ProjectItem`s — `(project, location,
product, brand, sku, qty)` — persisted across launches.

This is **deliberately separate** from the in-memory `smartCart`
(`lib/state/smart_cart.dart`), which models a single shopping line. The cart
is short-lived working state; a project is long-lived planning state that can
span many rooms and many trips back to the card. Both can co-exist for the
same product, intentionally — a contractor builds a quote-level plan
(`cardProjectsProvider`) while still iterating on the active line in cart.

Persistence key: `bs.card-projects.v1` (SharedPreferences), versioned so we
can migrate without trashing user data.

---

## The 5 shipped pieces (Phase 8)

All five live in `lib/state/card_projects.dart`. Guarded by
`test/card_projects_test.dart`.

### 71 · Add to project — `ProjectItem` + `record`/`add`
Roadmap step 71. `CardProjectsNotifier.add(ProjectItem)` calls the pure
helper `projectItemsAfterAdd`, which merges by `id` and sums `qty` when the
same `(project, location, productKey, brandName)` already exists. The UI
trigger is the "➕ הוסף לפרויקט" button in the card.

### 72 · Duplicate to many locations — `addToLocations`
Roadmap step 72. `addToLocations(template, List<String> locations)` reuses
the same `ProjectItem` template and fans it out across N rooms in one tap
("×3 חדרים" button). Each fan-out goes through the same dedupe path, so
calling it twice does not double-insert — it just bumps qty.

### 74 · Cumulative counter + full project BOM dialog
Roadmap step 74. Two surfaces:
- A running counter "📋 בפרויקט: N יחידות · M מיקומים" derived from
  `totalUnits` + `projects` getters on the notifier.
- A "📋 BOM פרויקט מלא" button that resolves every `ProjectItem.sku` to its
  catalog product (via `catalogProductForSku`), passes the resolved list as
  anchors to `buildInstallation(autoCompliance: true, 60°C)`, and shows the
  materialized BOM (with inserted pipes/couplings/compliance) in a dialog.
  Engine call path is guarded by `build_line_bom_test`.

### 75 · Customer quote — `projectQuoteText`
Roadmap step 75. Pure function: for a project name + its items, builds a
Hebrew plain-text quote (`location: brand ×qty — ~₪sub`) with a total and
a `נוצר ב-BuildSmart` signature. Unit prices come from `priceFor` on the
resolved catalog product; missing prices contribute zero (no throws).
Wired as "📋 הצעת מחיר לפרויקט" → clipboard.

### 80 · Ready project templates — `projectTemplates` + `applyTemplate`
Roadmap step 80. `_kProjectTemplates` holds two ready sets (אמבטיה
סטנדרטית, מטבח סטנדרטי) as `(name, keywords)` records. `projectTemplates()`
resolves each keyword to **exactly one** real `SmartProduct` from
`kSmartProducts` (first match by `name.contains`, deduped by `key`) — so a
template never over-pulls. `applyTemplate(project, location, products)`
inserts each product at its `recBrand`. UI: "🧩 תבניות" chips.

---

## Data flow — from card tap to BOM dialog

1. **Create.** User picks a brand on the card; "➕ הוסף לפרויקט" builds a
   `ProjectItem(project, location, productKey, brandName, sku, qty:1)`.
   The `sku` is captured from the selected brand at the moment of insertion;
   if the user later switches brands, an old `ProjectItem` still points at
   the brand-at-time-of-insertion (a feature: project history is stable).
2. **Dedupe.** `projectItemsAfterAdd(current, item)` walks `current`; if any
   existing entry shares the **id formula** `'$project|$location|$productKey|$brandName'`
   it returns a copy with `qty: e.qty + item.qty`. Otherwise the new item is
   appended. Notice the id intentionally **excludes** sku and qty — a brand
   change for the same role at the same location is a new id, but a sku
   reassignment under the same brand reuses it.
3. **Persist.** Notifier `jsonEncode`s state to SharedPreferences under
   `bs.card-projects.v1` after every mutation. `_load()` runs once in the
   ctor; the provider is global (no scoping needed).
4. **BOM resolve.** When "📋 BOM פרויקט מלא" fires:
   - For each `ProjectItem`, `catalogProductForSku(it.sku)` returns the real
     `LipskeyCatalogProduct` (or null — skipped, do not throw).
   - The resolved list becomes the anchor set for
     `buildInstallation(anchors, autoCompliance: true, tempC: 60)`.
   - The engine inserts pipes/couplings/compliance items (see PLAYBOOK §D)
     and returns a `plan` whose `items` is shown in the dialog.
   - Note: `plan.items` is a deduped BOM, **not** a physical flow sequence —
     for adjacency questions use `findShortestPath` instead (PLAYBOOK §D).

The id formula is the linchpin — change it and you break dedupe across all
five features. Treat it as a frozen interface; if a new field has to enter
the identity, add a `v2` persistence key and migrate.

---

## Adjacent shipped pieces (briefly)

- **Saved config versions (step 76)** — `lib/state/card_versions.dart`,
  `cardVersionsProvider`. Named brand snapshots per product (label collisions
  replace). Different from `smartCart` (live line), `cardSelectionProvider`
  (last brand only) and `savedConfigsProvider` (single-toggle favourite).
- **Cart + safety (step 46)** — `lib/state/cart_safety.dart`,
  `buildSafetyAccessories`. Converts engine-derived safety SKUs into
  `SmartCartAcc` for the "🛒 + בטיחות לסל" button. Pure, price lookup is
  injected.
- **Engine-derived safety kit (step 25)** — `safetyKitItems` in
  `related_info.dart`: diff of `buildInstallation` with autoCompliance true
  vs false. Surfaces as "🛡 ערכת בטיחות (auto)" inline on the card. Safety
  cart accessories (step 46) build on top of this kit.

---

## What's still ⬜ in Phase 8 (wall-blocked)

| Step | Capability | Wall |
|------|-----------|------|
| 77 | Team sharing — chat/notes on a chosen product | needs **backend** (auth + sync); no service account here |
| 78 | Gantt/tasks sync | needs **backend** (project-management API); no integration target |
| 79 | Unified procurement PDF for the whole project | needs a **PDF package** (e.g. `pdf` + `printing`) added to `pubspec.yaml`; deliverable also needs `url_launcher` for share |

These three are the only Phase 8 gaps. Everything else (71/72/73/74/75/76/80)
is shipped and tested. Do not pretend to implement them inside the card —
flag the wall and move on.

---

## For future agents — adding a new project capability

The pattern for any new project feature should mirror what shipped:

1. **Model.** Extend `ProjectItem` only if a new persisted field is needed
   (rare). Otherwise add a new pure helper in `card_projects.dart` next to
   `projectItemsAfterAdd` / `projectQuoteText`.
2. **Notifier method.** Add the user-facing mutation as a method on
   `CardProjectsNotifier` (e.g. `merge`, `moveLocation`, `recolor`). Always
   end with `_persist()`. Keep the method body 1-3 lines — delegate logic
   to a pure helper.
3. **Test first.** Add cases to `test/card_projects_test.dart` covering: the
   pure helper (dedupe edge cases), the notifier mutation, and any
   SKU-resolution path (mock with `SharedPreferences.setMockInitialValues({})`).
4. **Surface.** Wire the trigger in the SmartProduct card. Do NOT touch
   `lib/screens/catalog_screen.dart` directly when in a parallel run —
   sequence with the supervisor first (see PLAYBOOK §A "Parallel sub-agents").
5. **Roadmap.** Mark the step in `SMARTPRODUCT_ROADMAP.md` Phase 8 ✅ + bump
   the version label + local commit. No push without approval (PLAYBOOK
   §PUSH POLICY).

Keep the **id formula** invariant. Keep helpers **pure**. Keep state
**SharedPreferences-versioned** (`bs.<feature>.vN`). That's the playbook.
