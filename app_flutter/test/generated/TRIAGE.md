# Generated-suite triage — frozen

> **Opt-in, NON-blocking.** Every file self-skips unless run with
> `flutter test test/generated/ --dart-define=atomgen=true`. A red test here is a
> **triage signal**, never a CI blocker. The main swarm gate stays green.
> Regenerate: `dart run atom_testgen` (tools/atom/testgen).

## Frozen numbers (after worker_profile pilot fix · `triage7`)

| | `triage6` | after pilot (`triage7`) |
|---|---:|---:|
| screens | 62 | 62 |
| generated tests | 1001 | 1001 |
| **verified PASS** | 596 | **612** |
| **reported FAIL** | 405 | **389** |
| compile-fail | 0 | 0 |
| **force-pass** | 0 | **0** |

`pass = verified · fail = reported`. Nothing here is forced green. The pilot fix
(worker_profile app code) converted 16 crash-failures to verified passes; the
remaining 5 on that screen are honest not-founds (dialog content). Global
`+612 -389` is the raw `triage7` tally (verified, not arithmetic); `ink-hidden`
is now 0 globally. Main app suite stays green (5572 pass / 12 skip / 0 fail).

### Levers applied (generic, one mechanism each — not per-screen seeds)

| lever | net | note |
|---|---:|---|
| tall RTL surface + overflow drain | (baseline) | overflow is layout-noise, drained; content is asserted |
| board-role seed (`_SeededBoard`) | +29 | role screens gate their whole body on `boardAuthProvider.role` |
| tab-walk (`findAcrossTabs`) | 0 | honest: the app uses **custom tab rows**, not Material `Tab`, so `find.byType(Tab)` matches nothing. Kept as future-proof infra. |
| **Material-ancestor wrap (body-only screens)** | **+87** | detect the screen's **real** `Scaffold` from source; a body-only screen (0 real Material `Scaffold`) is pumped inside a `Scaffold` so its `InkWell`s have a Material ancestor — as they do in the real app's shell. |

Total: **509 → 596 verified pass**. The Material lever also **reclassified ~89**
former *crash* failures into honest *not-present-in-default* (they now render
without throwing; the specific element just isn't in the default view). Net: the
264-strong Material-ancestor cascade collapsed to **87 genuine remainders**.

**The number is now frozen.** We stop chasing it and split the remaining 405
into the two lists below — no per-screen data-seeds.

---

## Discriminator — real `Scaffold` vs. custom (why store_screen moved)

The lever wraps a screen **only** when its source has **no real Material
`Scaffold`** (regex `\bScaffold\s*\(`; the name-heuristic is the fallback when the
source can't be located, which keeps the goldens byte-stable).

- **Correction on an earlier report:** `store_screen` was previously called
  "Scaffold-bearing (5)". That count came from a naive `grep "Scaffold("` — all 5
  were **`_SheetScaffold`**, a *custom* widget (it returns a `Padding`, no
  Material). `store_screen` has **zero** real Material `Scaffold` → it is
  body-only, exactly like `catalog_screen`, and is now correctly wrapped. This
  implements the agreed principle faithfully (real Scaffold ⇒ keep flagged; none
  ⇒ wrap), the naive grep did not.
- Screens with a **real** Material `Scaffold` are **not** wrapped, so a genuine
  "Ink escapes the screen's own Scaffold" crash stays visible as a signal (List A).

---

## LIST A — real discoveries (worklist for the code team)

Per-finding investigation (real-render-path repros: the real Screen widget; a
realistic 390×844 viewport in a normal route) proved these are **real**, not
pump-isolation artifacts. **One shared Flutter anti-pattern:** a tappable
(`ListTile`/`InkWell`) inside a **decorated card** (`Container`/`DecoratedBox`
with a bg colour) **without its own `Material`** → in debug the framework asserts
("ListTile ink may be invisible" / "No Material widget found"); in release the
assert is stripped and the tap ripple is hidden by the card (cosmetic — or, for
the true "No Material" cases, `Material.of` is null). Fix = give the card content
its own transparent `Material` (or lift a `Material` above the decoration).

### ✅ FIXED — worker_profile_screen (pilot)

Surgical, no refactor: wrapped `_PersonalAreaRow`'s `ListTile` and `_ActionsCard`'s
tile `Column` in `Material(type: MaterialType.transparency)` — the card bg still
shows (from the `Container`), the tiles now have an ink surface above it. Matches
the file's existing correct pattern (the status-pill `Material`).

Result (verified, `--dart-define=atomgen=true`): **21 crashes → 16 verified pass
+ 5 honest not-found** (the 5 are `_RoleSwitchCodeDialog` content that only
renders when the dialog is opened — bucket B, self-skipped, never force-passed).
0 `No Material` / 0 ink-hidden / 0 `InkResponse` remain.

### Remaining — 66 on 3 screens (same anti-pattern, not yet fixed)

**Not** force-passable. Recommended fix order (per plan): the true `No Material`
cases first (chats, reorder — potentially worse than cosmetic in release), then
the cosmetic ink-hidden case (courier_profile).

| screen | count | real-render-path assertion |
|---|---:|---|
| courier_profile_screen | 35 | real `CourierProfileScreen` → "ListTile ink hidden" (the bare-`Body` "No Material" masks it) |
| chats_screen | 22 | "No Material" — persists at 390×844 in a normal route |
| home_content_reorder | 9 | `InkResponse` "No Material" — `ReorderableListView` items, persists at normal size |

---

## LIST B — intentionally uncovered (317, self-skipped, never force-passed)

Clean `element-not-present-in-default-state` failures — the composer built fine
(no crash), but the asserted text/registry element only appears after per-screen
setup the generic harness deliberately does **not** perform (a tab tap on a custom
tab row, a data seed, a scroll, a prior interaction, or a feature flag). Low value
/ high setup cost per screen. These stay **self-skipped** (the `atomgen` guard)
and are **never** forced green.

Spread across 44 screens (top slice — note store/catalog are now here, as clean
not-founds rather than crashes):

| screen | count |
|---|---:|
| store_screen | 46 |
| catalog_screen | 38 |
| manager_dashboard_screen | 17 |
| worker_app_screen | 15 |
| chat_settings_screen | 15 |
| catalog_settings_screen | 13 |
| budget_screen | 13 |
| notif_settings_screen | 11 |
| tasks_screen | 10 |
| store_dashboard_screen | 10 |
| worker_safety_screen | 9 |
| store_settings_screen | 9 |
| … 32 more screens | ≤8 each |

**Notable flag-gated discovery (correct behaviour, not a bug):**
`manager_profile_screen.t02` — absent because it sits behind
`kHideUnderConstruction`. The generated test correctly detects the flag is hiding
it. Tool working as intended; left in List B, not List A.

---

## Invariants held

- generated-suite stays **NON-blocking** (62/62 files carry the `atomgen` return-guard)
- main swarm gate **green** (generated tests self-skip in the default run)
- **zero force-pass** — every green is a real assertion against real widget output
- goldens **byte-stable** — the Material-lever falls back to the name heuristic when
  a screen source can't be located (the decompose golden dir), so `dart test` in
  tools/atom stays 4/4 + 8/8
- numbers reported are the raw run tally (`+596 -405`), not massaged
