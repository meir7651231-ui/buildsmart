# INSP-0025 — BsDial Multi-Level Drill (Store sub-sections)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Why this approach
Three previous attempts at building persona dashboards (ProfileView,
SitesView, Phase-0 Store/Courier/Worker skeletons) all opened **full
windows** in `<main class="content">`. The user flagged this each time
and the rule has been made absolute: **no full windows, ever**.

R2 + R3 give a single sanctioned answer: dial-only. The settings tab
already demonstrates this — multi-level dial, drill via path, back
anchors. This commit applies the **identical pattern** to the BS dial.

## What changed
- **`app/src/store/bs-store.ts`** — new `bsDrillPersona` signal +
  `drillIntoPersona` / `popBsDrill` helpers. `toggleBs` / `closeBs`
  reset the drill state.
- **`app/src/components/bs/bs-dial.tsx`** — split render into two levels:
  - **L1**: 5 personas (existing TILES). Tap → `drillIntoPersona(id)`.
  - **L2**: back anchor (`חזרה מ-<persona>`) + persona's sections.
  - `STORE_SECTIONS` (4 items verbatim from index.html:4260-4263):
    🏠 בית · 📥 הזמנות · 📦 מלאי · 🧰 פורטל
  - Each section leaf calls `showToast(`${title} — בבנייה`)`.
  - Personas without sections (Courier, Worker, Manager, Contractor)
    drill into an empty list (back anchor only) — will be filled in
    next 2 commits (Courier, Worker).

## Critical: what did NOT change
- `<main class="content">` — unchanged.
- `app.tsx` ActiveView — unchanged.
- `activePersona` / `setPersona` — drill no longer calls setPersona.
  Picking a persona at L1 drills the dial; it does NOT switch the
  main view.
- 5 FAB positions — unchanged.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FABs untouched.
- **R2** PASS — no window introduced. Dial only.
- **R3** PASS — both levels render inside `<ul class="bsdial">`.
- **R4** PASS — every row has separate circle + label spans.
- **R6/R8** PASS — all labels verbatim from legacy.
- **R7** PASS — `smoke-settings.mjs` 21/21 unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0014..0024.

## Next (planned)
1. INSP-0026 — Courier sub-sections (4 leaves)
2. INSP-0027 — Worker sub-sections (3 leaves)

Both follow the exact same pattern: add data to PERSONA_SECTIONS map.
Zero changes to architecture.
