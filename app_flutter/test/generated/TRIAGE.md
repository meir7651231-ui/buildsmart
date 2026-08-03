# Generated-suite triage — frozen

> **Opt-in, NON-blocking.** Every file self-skips unless run with
> `flutter test test/generated/ --dart-define=atomgen=true`. A red test here is a
> **triage signal**, never a CI blocker. The main swarm gate stays green.
> Regenerate: `dart run atom_testgen` (tools/atom/testgen).

## Frozen numbers (tab-walk run · `triage5`)

| | |
|---|---:|
| screens | 62 |
| generated tests | 1001 |
| **verified PASS** | **509** |
| **reported FAIL** | **492** |
| compile-fail | 0 |
| **force-pass** | **0** |

`pass = verified · fail = reported`. Nothing here is forced green.

### Levers applied (generic, one mechanism each — not per-screen seeds)

| lever | net conversions | note |
|---|---:|---|
| tall RTL surface + overflow drain | (baseline) | overflow is layout-noise, drained; content is asserted |
| board-role seed (`_SeededBoard`) | **+29** | role screens gate their whole body on `boardAuthProvider.role` |
| **tab-walk (`findAcrossTabs`)** | **0** | honest: the app uses **custom tab rows**, not Material `Tab`, so `find.byType(Tab)` matches nothing. Kept as future-proof infra for any Material-tab screen; it changed no result vs the pre-tab-walk run (0 regressed / 0 improved). |

**The number is now frozen.** Per decision, we stop chasing it here and split the
492 into the two lists below rather than descending into per-screen data-seeds
(diminishing returns + gaming risk).

---

## The 492, split by *what threw*

Each failing test is attributed to the exception that actually failed it
(`… was thrown running a test`):

| class | count | meaning |
|---|---:|---|
| **A** — widget threw at build/layout | **264** | the screen itself raised a runtime exception → **real discovery** |
| **B** — our `expect(…, isTrue)` | **228** | element simply not present in the default pump → **uncovered** (needs interaction/data/nav) |

---

## LIST A — real discoveries (worklist for the code team)

Tool-surfaced runtime exceptions, sorted by blast radius. These are **not**
force-passable; each is a genuine signal that a composer raised during
build/layout when pumped in isolation.

**Dominant root-cause: Material-ancestor / `InkResponse` (240 of 264).**
The failure is a cascade of *"No Material widget found — InkWell/InkResponse
require a Material ancestor"* (surfaced as `Multiple exceptions … running a
test`, plus 24 raw `No Material widget found`). It splits two ways:

- **Body-only screens with no `Scaffold` of their own** (e.g. `catalog_screen` —
  0 Scaffold, 22 Ink surfaces): they assume an ancestor `Scaffold` supplied by
  their shell. Latent structural coupling — verify each is *always* mounted under
  a shell that provides one, else it will throw the same way in a real nav state.
- **Scaffold-bearing screens** (e.g. `store_screen` — 5 Scaffold, still 85 fails):
  the failing Ink surfaces live **outside** the screen's own Material subtree
  (sheets/dialogs/pre-mount sub-widgets). Smaller but real.

| screen | count | pattern |
|---|---:|---|
| store_screen | 85 | Ink outside own Scaffold subtree |
| catalog_screen | 77 | body-only, no Scaffold (22 Ink) |
| courier_profile_screen | 35 | Ink/Material-ancestor |
| chats_screen | 22 | Ink/Material-ancestor |
| worker_profile_screen | 21 | Ink/Material-ancestor |
| notifications_screen | 18 | raw `No Material widget found` |
| finder_screen | 4 | raw `No Material widget found` |
| studio_rules_screen | 2 | raw `No Material widget found` |

**Candidate generic lever (NOT applied — awaiting approval):** wrap the
`selfContained` composer body in a bare `Material` in `pumpScreen`. Estimated to
convert most of the 264 to real passes in one harness line — the same shape as
the role-seed lever. Held back deliberately: it is a *new* generic lever beyond
the agreed tab-walk stopping point, and for the Scaffold-bearing cases (store_screen)
it could mask a real "Ink escapes Scaffold" signal. Flagging it for a decision
rather than silently applying it.

---

## LIST B — intentionally uncovered (228, self-skipped, never force-passed)

Clean `element-not-present-in-default-state` failures — the composer built fine,
but the asserted text/registry element only appears after per-screen setup the
generic harness deliberately does **not** perform (a specific tab tap on a custom
tab row, a data seed, a scroll, a prior interaction, or a feature flag). Low
value / high setup cost per screen. These stay **self-skipped** (the `atomgen`
guard) and are **never** forced green.

Spread across 41 screens (top slice):

| screen | count |
|---|---:|
| manager_dashboard_screen | 17 |
| worker_app_screen | 15 |
| chat_settings_screen | 15 |
| catalog_settings_screen | 13 |
| budget_screen | 13 |
| tasks_screen | 11 |
| notif_settings_screen | 11 |
| store_dashboard_screen | 10 |
| worker_safety_screen | 9 |
| store_settings_screen | 9 |
| welcome_screen | 8 |
| … 30 more screens | ≤6 each |

**Notable flag-gated discovery (correct behaviour, not a bug):**
`manager_profile_screen.t02` — the element is absent because it sits behind
`kHideUnderConstruction`. The generated test correctly detects the flag is
hiding it. This is the tool working (a gated element reads as "not present"),
not an app defect. Left in List B, not List A.

---

## Invariants held

- generated-suite stays **NON-blocking** (62/62 files carry the `atomgen` return-guard)
- main swarm gate **green** (generated tests self-skip in the default run)
- **zero force-pass** — every green is a real assertion against real widget output
- numbers reported are the raw run tally (`+509 -492`), not massaged
