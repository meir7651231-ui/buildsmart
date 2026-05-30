# COACH_MODE — Steps 99 & 100 (the meta-vision)

This doc closes the SmartProduct roadmap. It is **vision + audit** — no code is
shipped here. Steps 99 and 100 are tracked in `SMARTPRODUCT_ROADMAP.md`; this
file explains what they *mean* once the rest of the card is real, and honestly
audits what we already have versus what still needs external infrastructure
(camera, TTS, AI backend, AR) before "coach mode" can stand on its own.

## Step 99 — vision (one paragraph)

**Coach mode: the card teaches the user as they go.** The SmartProduct card
already knows *what* a product is, *why* a compliance trigger fires, *how* it
mates with the next part, *how* to install it, *what it costs*, and *who sells
it*. Coach mode reframes that same knowledge as **just-in-time pedagogy**:
instead of waiting for a junior plumber to ask, the card volunteers the next
useful sentence at the moment of decision — a hint, a warning, a "next best
action" prompt — and adapts the depth to who is holding the phone (DIY,
contractor, pro). Nothing new has to be invented for the data layer; the
helpers are already shipped. Coach mode is an *orchestration* of existing
helpers behind a single "lead me through this" surface.

## Step 99 in detail — how the card would coach a junior plumber

### A. Just-in-time hints (already-shipped helpers)

When the user opens a card and selects a brand, coach mode would surface one
helper at a time, gated by context:

- **Just landed on the card** → `smartCardSummaryHe` (one-liner: name · material ·
  system · temp · price). Already rendered at the top of the 📦 section.
- **Picked a brand** → `complianceWhyHe` (↳ explanations) reads aloud the first
  trigger from `complianceTriggersFor`. The user hears *why* a check valve is
  required before they install one.
- **Looking at the stages** → `installTipsFor` (טעויות נפוצות וטיפים) surfaces
  one tip *per stage* as a coachmark, not as a static block.
- **About to add to cart** → `connectionWarningHe` ("ייתכן שנדרש מתאם") fires if
  this product has zero direct catalog mates given the current cart.
- **Hit a stage marked done** → the next acceptance check from
  `acceptanceChecklistFor` ("Test kit") becomes the active coachmark.
- **About to leave the card** → if `safetyKitItems` has anything not in the
  cart, coach mode interrupts with "🛡 ערכת בטיחות מומלצת — להוסיף?".
- **A pair of products in the cart** → `connectionNeedsHe` ("מה הקו צריך
  לחיבור") fills the gap in plain language: *"this side needs a 1″ female
  threaded coupling — here is one"*.

The pattern: **every coach line is already a function call**; coach mode is the
state machine that picks which call to render *now*.

### B. Next-best-action prompt

Coach mode would render exactly one CTA at a time, derived from the line-fit /
adapter engine:

| Context (read once per render)                                                  | CTA                                                                |
|---------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `lineFitFor(cart, product).matches == 0` and `adapterSuggestionFor(...)` exists | "🔌 הוסף את המתאם המומלץ" (the suggested adapter)                  |
| `lineFitFor(...).matches > 0` and `connectionWarningHe == null`                 | "🛒 + בטיחות לסל" (already wired — promote it to the primary CTA)  |
| `safetyKitItems` non-empty but missing from cart                                | "🛡 הוסף ערכת בטיחות"                                              |
| Stages with progress < 100%                                                     | "✅ סמן את השלב הבא" (next un-checked stage from `stageProgress`)  |
| All of the above resolved                                                       | "📋 צור הצעת מחיר" (`projectQuoteText` / `quoteTextFor`)           |

That table is the entire next-best-action policy. Coach mode is not "AI" — it
is a priority queue over helpers we already shipped.

### C. Progressive disclosure (tied to `cardDetailModeProvider`)

Step 95 already split the card into **simple / expert** via
`cardDetailModeProvider`. Coach mode reuses that switch and adds a *coaching*
overlay on top:

- **Simple mode + coach on**: a single coachmark bubble at a time. No technical
  vocabulary — `complianceWhyHe` renders without the standard number, the bore
  row is hidden, only the active stage's tip is shown.
- **Expert mode + coach on**: bubbles are inline annotations, not modal. The
  engineering spec row, standards tags, bore, and the full safety-kit list are
  visible *and* highlighted as the user touches them.
- **Coach off**: today's behaviour — nothing changes.

The gating logic is one boolean (`coachModeProvider`) ANDed with the existing
`cardDetailModeProvider`; no new render branches.

### D. Skill-level dimension (DIY / contractor / pro)

Step 57 (profession-aware depth) is the natural pair to coach mode:

| Level         | What is *always* visible                                           | What coach mode *adds*                                       |
|---------------|--------------------------------------------------------------------|--------------------------------------------------------------|
| **DIY**       | summary, price, stages, tools, tips                                | every step is a coachmark; reads aloud (step 40)             |
| **Contractor**| + standards, compliance + why, safety kit, line cost               | coach surfaces *only* warnings and next-best-action          |
| **Pro**       | + bore, ΔP, materialized chain, adapter suggestions, brand-guide   | coach is silent unless `connectionWarningHe` or compliance triggers — pros do not want hand-holding |

Each level maps to a different *threshold* in the priority queue, not to
different data. The same helpers feed all three.

## Step 100 — the convergence

> "One unified product card that knows *what · why · how it connects · how to
> install · cost · supplier* — the knowledge brain of plumbing."

### Coverage checklist

| Sub-claim   | Status | Where it lives                                                                                |
|-------------|--------|-----------------------------------------------------------------------------------------------|
| **what**    | ✅      | `smartCardSummaryHe`, `engineeringSpecFor`, `manufacturerInfoFor`, `israeliStandardsFor`      |
| **why**     | ✅      | `complianceTriggersFor` + `complianceWhyHe` (coverage-gated by `compliance_why_test`)         |
| **connects**| ✅      | `compatibleProductsFor`, `connectionExplainHe`, `connectionNeedsHe`, `adapterSuggestionFor`, `lineFitFor`, `connectionWarningHe`, `chainArrowText` |
| **install** | 🟦     | `installToolsFor`, `installEffortFor`, `installTipsFor`, `acceptanceChecklistFor`, `safetyKitItems`, `stageProgressProvider` — **missing**: video (32), AR (36), exploded view (37), PDF guide (39), voice (40) |
| **cost**    | ✅      | `priceFor`, `lineCostEstimateFor`, `cheaperAlternativeBrand`, `lineCostEstimateFor` breakdown |
| **supplier**| ⬜      | only SKU + brand today; real stock/ETA (17), multi-supplier price (41), distance/rating (44), order/payment (50) all need a backend |

Two out of six are partial / open, both for the same reason: they require
infrastructure outside the Flutter app. The card's *internal* knowledge brain
is complete; the *external* edges — supplier feeds, voice, camera, AR — are
the remaining surface.

## What is still missing for true coach-mode

Honest list of dependencies, all currently behind external-infra walls and
tracked elsewhere in `SMARTPRODUCT_ROADMAP.md`:

- **TTS / read-aloud** (step 40) — coach mode without voice is silent
  coaching. Needs a TTS package + per-platform permission; no library is
  wired today.
- **In-card AI assistant** (step 53) — free-text "what suits me?" cannot be
  answered by the helper grid alone; needs an LLM endpoint.
- **Camera barcode / image recognition** (step 55) — coach mode wants to open
  the card from a real product the user is holding. Camera permissions + a
  barcode library are missing.
- **AR overlay** (step 36) — placing the product on the wall through the
  phone camera. Needs ARCore / ARKit bindings; out of reach in a pure-Flutter
  web build.
- **Profession-aware depth** (step 57) — exists in spirit (the
  simple/expert toggle, step 95) but is not yet split three ways.
- **Voice search** (step 70) and **QR on packaging** (step 69) — both unlock
  the *entry point* into coach mode from the physical world.

Until those land, coach mode can ship in a **text-only, in-card** form using
nothing but the helpers above. The voice / AR / camera layers are upgrades to
the *delivery channel*, not to the knowledge.

## Out of scope for this doc

- **No code is delivered here.** This is a vision/roadmap doc. The work to
  implement coach mode is tracked under step 99; the convergence claim is
  step 100.
- **No new helper signatures are proposed.** Every coach interaction maps to a
  helper that is already exported by `related_info.dart` or to a provider
  that is already persisted in `lib/state/`.
- **No UI mockups.** The visual form (coachmark bubble vs inline annotation
  vs modal) is left to the implementation step; the data plumbing is the
  contract.
- **Supplier-side and AI-side dependencies** are out of scope by design —
  they live in Group C of the roadmap handoff and require user decisions on
  packages / backend.

— end —
