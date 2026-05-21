# INSP-0029 — BsDial Arbitrary-Depth Drill (Manager Dashboard Deepening)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Generalize the BsDial drill from a fixed 2-level structure to an
arbitrary-depth tree walk — same pattern as the profile tree we built
earlier (settings → profile → card/ranks → leaves). First user of the
new depth: Manager → לוח בקרה now drills into 5 metric leaves.

## Architecture changes
- **`app/src/store/bs-store.ts`** — added `bsDrillPath: Signal<string[]>`
  + `pushBsDrill(label)` / `popBsDrillPathTo(depth)`. Reset (along with
  `bsDrillPersona`) on `closeBs` / `toggleBs(false)` / `drillIntoPersona`
  / `popBsDrill`.
- **`app/src/components/bs/bs-dial.tsx`** — extended `Section` type with
  optional `children: Section[]`. Added `walkBsDrill(persona, path)`
  helper. Renderer now emits the persona anchor + one anchor per drill
  step + the current items at the deepest depth. Tap with `children`
  pushes the drill; tap on a leaf toasts.

## New L3 leaves (Manager → לוח בקרה — verbatim from `mdMetric()` calls)
| emoji | title | legacy source |
|---|---|---|
| 🚚 | הזמנות פתוחות | `mdMetric('🚚',a.openOrders,'הזמנות פתוחות',…)` @ :12160 |
| 📦 | מוצרים בקטלוג | `mdMetric('📦',a.catalogCount,'מוצרים בקטלוג',…)` @ :12161 |
| 🧰 | אביזרים נלווים | `mdMetric('🧰',a.accCount,'אביזרים נלווים',…)` @ :12162 |
| ✅ | זמינים כעת | `mdMetric('✅',a.avail,'זמינים כעת',…)` @ :12163 |
| 🏪 | חנויות פעילות | `mdMetric('🏪',…,'חנויות פעילות',…)` @ :12164 |

Both emoji and label are the verbatim args of each `mdMetric()` call.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FABs untouched.
- **R2** PASS — no window. `<main>` and `ActiveView` unchanged.
- **R3** PASS — every depth renders inside `<ul class="bsdial">`.
- **R4** PASS — circle + label, two separate spans, at every depth.
- **R6/R8** PASS — all 5 new leaves verbatim from legacy.
- **R7** PASS — smoke 21/21 unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0018..0028.

## What this enables
Any persona section can now be turned into a branch by adding a
`children` array. Future deepening commits will just add data; the
walker handles unlimited depth.
