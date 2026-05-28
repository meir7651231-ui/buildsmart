# 05 — Preact Build History & The "Building Inspector" Process

> **Scope.** Faithful, complete capture of the **build history and the process discipline**
> under which the live Preact app at `/home/user/buildsmart/app/` was produced — namely the
> **43 inspection reports** (`knowledge/inspections/INSP-0001…INSP-0044`, note INSP-0012 has
> no file), the **Building Inspector protocol** (`knowledge/inspector/{checklist,loops,prompt,README}.md`),
> the **Hebrew reporting format** (`knowledge/reporting.md`), the **agent board / WIP wiring**
> docs, the **knowledge README**, the two **ADRs** (`adr/001-no-window.md`, `adr/002-dial-pattern.md`,
> + `adr/README.md`), and the **DEPRECATED** `IMPLEMENTATION_PROTOCOL.md`.
>
> This is a Flutter-port reference. **Nothing here was edited; this only reads source.** All cited
> files live under `/home/user/buildsmart/app/`. Companion docs: `01-shell-dials-components-trees.md`
> (the dials this history built), `02-data-stores-history.md` (the data/stores), `03-persona-dashboards.md`
> (the four persona specs), `04-ui-architecture-role-system.md`.
>
> **The one-line thesis of this whole history:** *the build is the story of learning to obey R2
> ("אין חלון, נקודה" — no window, period). Three times Claude built a full-screen view; three times
> it was reverted; the dial pattern is what survived.*

---

## Part 0 — How the process worked (the loop)

Every commit to the Preact app passed through a fixed gate, documented in
`inspector/README.md` and `wip-menu-wiring.md`:

1. Read `RULES.md` (R1–R9) + `inspector/checklist.md` + `inspector/loops.md`.
2. `cd app && npx tsc -b --noEmit` (typecheck).
3. `cd app && npm run build` (vite + PWA).
4. Behavioural verify: `npx http-server app/dist -p 8123 -s &` → `node app/smoke-settings.mjs` (**21/21 expected**).
5. **Spawn an Explore subagent** with the master Inspector prompt (`inspector/prompt.md`), substituting `{STAGE}`.
6. The subagent returns a markdown report ending in `VERDICT: GO` or `VERDICT: NO-GO`.
7. Claude writes that report to `knowledge/inspections/INSP-NNNN-{stage}-{date}.md`.
8. GO → commit. NO-GO → fix findings, re-run. **Same finding ID in 2+ of last 3 reports → STOP, escalate to owner (stuck loop).**

The Inspector "reports to the owner, **not to Claude**." Its authority:
**CRITICAL → commit blocked · MAJOR → needs owner approval · MINOR → recorded only.**

A hard-won process lesson recurs in the early reports: **the Inspector subagent must run
BEFORE the markdown report is written.** INSP-0014, 0015, 0016 each carry a "process note"
admitting the first GO was issued without re-running the subagent after a fix; from INSP-0018
onward every report states the subagent "ran before this markdown."

---

# PART 1 — THE 43 INSPECTIONS (complete, faithful)

Format/number history: early reports (0001–0011) use the strict `inspector/prompt.md` template
(`# Inspection #NNNN`, Counts, Findings, Stuck-loop check, VERDICT). From 0013 the reports adopt
a lighter `# INSP-NNNN — Title` style with a findings table. **INSP-0012 has no file** (the
agent-board records it as "אבטחה — 23 עלים" / security, 23 leaves — the work happened, the report
file is missing).

## 1.1 Per-inspection table

Legend: **C/M/Mi** = CRITICAL / MAJOR / MINOR counts at final verdict. "↺" marks a revert or a
NO-GO→fix→re-check cycle.

| # | Title | What it built / changed | Findings (severity) | Verdict |
|---|---|---|---|---|
| 0001 | operations | First inspection. Baseline of 6 files (5930 ins) — knowledge scaffold. | 0/0/0 | GO |
| 0002 | operations | ADRs 001+002, adr/README, legacy-map, spec.json (283 lines). | 0/0/**2 Mi** | GO |
| 0003 | operations | RULES.md +23, reporting.md (new, 106 lines). OPS-01/02/03 PASS. | 0/0/0 | GO |
| 0004 | frame+ops | Menu speed-dial scaffolding (5 FAB tabs, no submenus yet). | 0/0/**1 Mi** | GO |
| 0005 | frame+ops | Settings drill L1: tap "הגדרות" → 10 setting rows (renderSettings order). | 0/0/0 | GO |
| 0006 | frame+ops | Settings drill L2: 9 groups with children (e.g. חשבון → 4 fields). | 0/0/0 ↺ (1 C caught+fixed mid-inspection) | GO |
| 0007 | frame+ops | Settings drill L3/L4: data model → `SubRow{label,children?}`; 33 leaves on 8 branches. | 0/0/0 | GO |
| 0008 | frame+ops | Settings drill L4/L5: recursive `Node`; `menuActiveSettingsPath:string[]`; 6 branches/26 leaves. | 0/0/0 | GO |
| 0009 | frame+ops | **First end-to-end wiring.** `app-settings.ts` store + persist + DOM effect; display branch (theme/textSize/reduceMotion). | 0/0/0 | GO |
| 0010 | frame+ops | +16 wired leaves (notifications/accessibility/region/delivery/reset) → 22 total. | 0/0/**1 Mi** | GO |
| 0011 | frame+ops | Toast system (`toast-store.ts` + `toast.tsx`); about branch (4 toasts) → 26 leaves. | 0/0/0 | GO |
| **0012** | *(no file)* | Security branch — **23 leaves** (per agent-board.md). Report file missing. | — | (recorded GO) |
| 0013 | support-hub | Support/service branch — 15 LEAF_BINDINGS (calc 3, tour 6, hub 6). | 0/0/0 | GO |
| 0014 | r9-inline-input | **R9 introduced.** `user-profile.ts` store; inline `LeafEditor`; account(4)+payment(1). | C0/M0(was 1)/Mi0 ↺ | GO |
| 0015 | regression-check | R7 regression after R9/support/security; smoke 12→21; in-app 236/236. | 0/0/**1 Mi** ↺ | GO |
| 0016 | sites-view | **R2 VIOLATION (1st).** Built `SitesView` as full `<section>` page swap. | C0(was 1)/M0/Mi0 ↺ | GO (later superseded) |
| 0017 | profile-restructure | **R2 VIOLATION (2nd).** Built `ProfileView` (10 sections) as a page. | 0/0/0 | GO (later superseded) |
| 0018 | dial-only-restructure | **THE REVERT.** Deletes profile.tsx + sites.tsx; rebuilds same content inside the dial. | 0/0/0 | GO |
| 0019 | profile-tree | Profile dial as 3-level tree (כרטיס קבלן / דרגות הקבלן). | 0/0/**1 Mi** (user-authored label) | GO |
| 0020 | profile-deepening | Real identity data: RANKS, identityStats, 6 achievements, isActive states. | C0/M0/Mi0(was 1, R4) ↺ | GO |
| 0021 | bs-dial-labels | BsDial 5-persona labels restored verbatim ('מנהל המערכת','חנות ספק'). | 0/0/0 | GO |
| 0022 | store-skeleton | **R2 VIOLATION (3rd, retroactively).** Store dashboard skeleton as a view. | 0/0/0 | GO (retro-flagged R2) |
| 0023 | courier-skeleton | Courier dashboard skeleton (same `.dash__*` block). | 0/0/0 | GO (retro-flagged R2) |
| 0024 | worker-skeleton | Worker dashboard skeleton; "Phase 0 — DONE". | 0/0/0 | GO (retro-flagged R2) |
| 0025 | bs-dial-store-drill | **THE PIVOT.** BsDial multi-level drill; Store sub-sections moved into the dial (not a view). | 0/0/0 | GO |
| 0026 | bs-dial-courier-drill | Courier sub-sections (4) into BsDial. | 0/0/0 ↺ (false-positive C → re-check) | GO |
| 0027 | bs-dial-worker-drill | Worker sub-sections (3); "BS dial drill — COMPLETE". | 0/0/0 | GO |
| 0028 | bs-dial-manager-drill | Manager sub-sections (4: 📊🚚👥🛠️). 4 of 5 personas now drilled. | 0/0/0 | GO |
| 0029 | bs-dial-tree-walk | **Arbitrary-depth tree walk** generalized (`bsDrillPath`, `walkBsDrill`); Manager לוח בקרה 5 leaves. | 0/0/0 | GO |
| 0030 | bs-dial-manage-leaves | Manager → ניהול 4 leaves (mmSection). 2 sections deferred (no verbatim emoji). | 0/0/0 | GO |
| 0031 | bs-dial-store-deepening | Store בית (3) + פורטל (8) = 11 leaves. | 0/0/0 | GO |
| 0032 | bs-dial-courier-deepening | Courier vehicle (3) + portal (6) = 9 leaves. | 0/0/0 | GO |
| 0033 | menu-catalog-dial | Menu קטלוג tab → 11 category leaves (verbatim CATALOG). | 0/0/0 | GO |
| 0034 | menu-cart-dial | Menu רכש tab → 2-level dial (הסל שלי + 6 supply-chain services). | 0/0/0 | GO |
| 0035 | menu-home-dial | Menu בית tab → 4 home-unique tools. **All 5 menu tabs wired.** | 0/0/0 | GO |
| 0036 | home-ai-drill | Home → 🤖 → 9 AI hub tools (openAIHub). | 0/0/0 | GO |
| 0037 | home-tasks-site-hub | Home → 📋 → 10 site-hub tools (openSiteHub). | 0/0/0 | GO |
| 0038 | profile-rewards-hub | Profile → מועדון BuildSmart → 7 rewards items (openRewardsHub). | 0/0/0 | GO |
| 0039 | projects-finance-hub | Projects tab → 3 projects + 📊 מרכז פיננסים (10 finance-hub items). | 0/0/0 | GO |
| 0040 | home-scan-stock | Home → 📐 (4 PLAN_TYPES) + 📦 (2 stock tabs). **Home dial DONE.** | 0/0/0 | GO |
| 0041 | worker-statuses | Worker 3 task groups → 5 taskStatusInfo leaves each; + TS build fixes. | 0/0/0 | GO |
| 0042 | worker-statuses-refined | Narrows each worker group to its legacy-filtered statuses. | 0/0/0 | GO |
| 0043 | final-deepening | Fills 5 deferred BS sections (16 leaves), emoji from sibling legacy contexts. "השלד שמות — COMPLETE". | 0/0/0 | GO |
| 0044 | catalog-moved-to-search | Catalog relocated: menu FAB 5→4 tabs, search FAB 4→5 tools. | C0/**M1**/Mi0 (stale CLAUDE.md, fixed in-commit) | GO |

**Tally:** 43 report files (0001–0044 minus 0012). All ended **GO**. No report ever ended NO-GO
as its final state — but several reached GO only via a NO-GO→fix→re-check cycle (0006, 0014, 0016,
0020, 0026), and three (0016/0017 then 0022/0023/0024) record R2-violating work that was later
**reverted or superseded** rather than carried forward.

## 1.2 The phase arc (the narrative behind the table)

The agent-board.md groups the work into four sessions; the inspections trace this exactly:

- **Session 1 — Settings menu (0009→0015):** the settings tab grew from a flat 10-row list into a
  recursive `Node` tree (5 levels deep), then got wired end-to-end (store → persist → DOM effect),
  then got the toast system and R9 inline input, then a regression pass. **~70 settings leaves** total.
- **Session 2 — Profile + Sites (0016→0020):** the **first R2 crisis**. INSP-0016 (SitesView) and
  INSP-0017 (ProfileView) built full-window page swaps. The owner flagged it
  (`אני פתיחת חלון חסום נקודה` / "window-opening is blocked, period"). INSP-0018 reverted both into
  dial drills. 0019–0020 then deepened the profile dial with real RANKS/achievements data.
- **Session 3 — BS-dial persona tree (0021→0028):** a **second R2 attempt** (Phase-0 dashboards as
  views, 0022/0023/0024) was likewise abandoned; INSP-0025 established the canonical answer — the
  five personas live as **BsDial drills**, not views. 0026/0027/0028 filled Store/Courier/Worker/Manager.
- **Session 4 — Deepening (0029→0044):** arbitrary-depth tree walk generalized (0029); every menu tab,
  persona section, and the 6 legacy hubs (AI · Site · Finance · Rewards · Security · Service) populated
  with verbatim leaves; final cleanup moved catalog into the search FAB (0044).

**Result, per agent-board.md:** *~200+ leaves verbatim, 6/6 legacy hubs embedded, **zero windows**.*

## 1.3 Findings that mattered (the non-zero reports)

Most reports are 0/0/0. The ones that carry findings are the instructive ones — capture them faithfully:

- **INSP-0002 — 2× MINOR.** (a) `spec-fabs-missing-adrs-field` — cosmetic JSON field omission, fixed
  pre-commit. (b) `spec-invented-features-disclosed` — two features (`FEAT-search-filters`,
  `FEAT-search-recent`) **absent from the legacy prototype**; one "invented but documented", one
  "added per owner request". Accepted as a *transparent record*, not a hidden invention (R7). Owner to confirm.
- **INSP-0004 — 1× MINOR `tab-id-mismatch-profile-vs-settings`.** Internal id `'settings'` vs legacy
  `data-tab="profile"`. Cosmetic, no runtime use yet; recurs as "not relevant" in 0005–0010 stuck-loop scans.
- **INSP-0006 — CRITICAL caught mid-inspection.** `subsub-text-mismatch-delivery`: wrote
  `'משלוח אקספרס כברירת מחדל'` instead of the legacy `'ברירת מחדל — משלוח אקספרס'` (R6/R8). Fixed
  immediately + a second fix `'מצב ניגודיות גבוהה'` → `'מצב ניגודיות גבוהה (לשמש)'` (`index.html:6842`).
  Demonstrates the verbatim-Hebrew discipline catching a one-word drift.
- **INSP-0010 — 1× MINOR `accessibility-not-in-legacy-app-settings-object`.** Legacy `resetSettings()`
  stored high-contrast **only in the DOM** (`data-contrast`), never persisted. The port adds
  `accessibility.highContrast` to state + localStorage. Inspector marked this a **"permitted adaptation"**
  — *"the legacy didn't persist the preference — that's a bug in the legacy. We improve by persisting."*
  This is the canonical example of an allowed deviation from verbatim, with a documented reason.
- **INSP-0014 — MAJOR (fixed) `spec-label-mismatch` on `phone`.** Legacy uses **two** labels: menu row
  `'טלפון'` (`:6819`) and toast `'מספר טלפון'` (`:6947`). Fix: `profileBinding` accepts both `rowLabel`
  and `toastLabel`. Establishes the two-label pattern for R9 fields.
- **INSP-0015 — 1× MINOR `unrelated-404`** (PWA manifest/SW probe, pre-existing). Also a *process note*:
  first written without the subagent; an Explore re-inspection caught a **number mismatch** ("security×4"
  vs actual 5 smoke tests) — the 21-total was right, the per-branch breakdown was reconciled.
- **INSP-0016 — CRITICAL (resolved) `incomplete-view-routing`.** First pass mapped catalog/cart tabs to
  views that did not exist; default fell back to `<HomeView>` → silent route desync. Fixed by narrowing
  `VIEW_MAP` to only `home`+`projects`. (This report itself was soon superseded by the 0018 revert.)
- **INSP-0019 — 1× MINOR `r6-user-authored-label`.** The grouping label `"הגדרות-פרופיל"` is **not**
  verbatim — the owner authored it to consolidate level-1 into 2 items. Documented exception in the
  `PROFILE_TREE` comment.
- **INSP-0020 — MINOR (resolved) `r4-emoji-in-label`.** Labels carried emoji prefixes ("📦 הזמנות").
  Fixed by moving the emoji into a separate `.dial__circle-emoji` slot inside the circle, leaving the
  label plain — restores R4's two-element structure. (This is *why* emoji live in the circle, not the label.)
- **INSP-0026 — CRITICAL false positive.** Inspector claimed 🛵 had no verbatim source; it had not read
  `index.html:11951` (`HAUL_TYPES`). Re-run with the line quoted as evidence → GO. Lesson: **the Inspector
  must read the cited line before flagging a verbatim miss.**
- **INSP-0044 — MAJOR (fixed in-commit) stale `CLAUDE.md`.** Documentation drift: "Menu FAB — 5 tabs"
  was no longer true after catalog moved to search. The Inspector treats **doc drift as a MAJOR finding** —
  documentation is part of the audited surface.

## 1.4 The stuck-loop machinery (P-01)

Every report ends with a **Stuck-loop scan** of the previous ~3 reports. The mechanism (from
`loops.md` P-01 and `prompt.md`): each finding gets a stable kebab-case **finding ID** derived from
its first line; if the same ID appears in **2+ of the last 3 reports**, the Inspector promotes it to
CRITICAL, labels it `stuck-loop`, prints the Hebrew sentence
**"המפקח חוזר על אותו ממצא — חייבת התערבות הבעלים, לא ניסיון נוסף"** ("the inspector is repeating the
same finding — owner intervention required, not another attempt"), returns `VERDICT: NO-GO (stuck loop)`,
**stops listing other findings**, and Claude must **stop fixing and ask the owner**.

Across all 43 reports the scan returned "no recurring finding IDs" every time — **the stuck-loop trap
never actually fired.** It exists as a tripwire; the R2 reverts were caught by the *owner*, not by the
automated loop detector (the violating reports each individually passed). That gap — process passes,
human catches the real problem — is itself part of the history.

---

# PART 2 — THE PROCESS / PROTOCOL DOCS (substance of each)

## 2.1 `inspector/checklist.md` — the staged checks (IDs + severities)

The checklist is organized by **five stages**; only the stage(s) touched by a diff are audited.
Captured in full:

**Foundation (FND) — schemas, types, data, store**
| ID | Check (Hebrew gist) | Severity |
|---|---|---|
| FND-01 | TS schemas valid — `npm run typecheck` PASS | CRITICAL |
| FND-02 | no duplicate ID in `PRODUCTS` | CRITICAL |
| FND-03 | no duplicate ID in `CATEGORIES` | CRITICAL |
| FND-04 | no duplicate fn name in `BUTTON_REGISTRY` | MAJOR |
| FND-05 | `PRODUCTS/CATEGORIES/VARIANTS/SUPPLIERS` not empty | CRITICAL |
| FND-06 | every `STORE_PRICING` SKU exists in `VARIANTS.opts[].sku` | MAJOR |
| FND-07 | every `VARIANTS` key maps to a product in `PRODUCTS` | MAJOR |
| FND-08 | new signals have explicit default values | MINOR |
| FND-09 | localStorage keys use `bs.{thing}.v{N}` pattern | MINOR |

**Frame (FRM) — components, layout, visual rules (this is where R1–R5 live)**
| ID | Check | Severity |
|---|---|---|
| FRM-01 (R1) | 5 FABs keep fixed position — no position-shifting class | CRITICAL |
| FRM-02 (R2) | no new `position:fixed; inset:0` full-screen `<div>` beyond product-sheet/search-panel/menu-speed-dial/bs-dial-scrim | CRITICAL |
| FRM-03 (R3) | tools open as a dial — no new list/drawer | CRITICAL |
| FRM-04 (R4) | dial item = separate `circle` + separate `label` pill with gap — not a unified container | CRITICAL |
| FRM-05 (R5) | on tool select: others collapse, selected stays in slot 1, sub-menu in parent dial's style | MAJOR |
| FRM-06 (R2 exception) | existing backdrops: opacity ≤ 0.45 and blur ≤ 3px | MAJOR |
| FRM-07 | persona views render without crash — `testTabs` PASS | CRITICAL |

**Wiring (WIR) — handlers, signals, side-effects**
| ID | Check | Severity |
|---|---|---|
| WIR-01 | behavioural tests restore state after mutation (`save→call→assert→restore`) | MAJOR |
| WIR-02 | `cartCount.value === sum(cart.value.qty)` invariant holds | CRITICAL |
| WIR-03 | no infinite useEffect loop (see loops.md) | CRITICAL |
| WIR-04 | no signal mutation inside an effect that depends on the same signal | CRITICAL |
| WIR-05 | no state setter in component render body | CRITICAL |
| WIR-06 | every new interactive button registered in `BUTTON_REGISTRY` | MAJOR |
| WIR-07 | event handlers are stable references (no inline fns in big loops) | MINOR |

**Finish (FIN) — CSS, RTL, accessibility**
| ID | Check | Severity |
|---|---|---|
| FIN-01 (R8) | home/search icons on right (`inset-inline-start` RTL); store/cart on left (`inset-inline-end`) | MAJOR |
| FIN-02 | `safe-area-inset-top/bottom` honored on every edge-fixed element | MAJOR |
| FIN-03 | Hebrew `aria-label` on every text-less button | MAJOR |
| FIN-04 | `aria-expanded` on toggles (BS, menu, search) | MINOR |
| FIN-05 | touch targets ≥ 44×44 px | MAJOR |
| FIN-06 | no `outline:none` without a `:focus-visible` replacement | MAJOR |
| FIN-07 | text colors meet WCAG AA (4.5:1) | MINOR |

**Operations (OPS) — build / tests / regression / process-loop (always run, last before commit)**
| ID | Check | Severity |
|---|---|---|
| OPS-01 | `npm run typecheck` clean | CRITICAL |
| OPS-02 | `npm run build` clean | CRITICAL |
| OPS-03 | regression suite (manager view or runner) — no FAIL | CRITICAL |
| OPS-04 | commit message cites `@rule`/`@adr`/`@legacy` when relevant | MINOR |
| OPS-05 | new ADR ⇒ matching entry in `spec.json` | MAJOR |
| OPS-06 | **process-loop**: same finding ID not in 2+ of last 3 reports (mandatory) | CRITICAL |

## 2.2 `inspector/loops.md` — loop patterns L-01 … L-08 (+ P-01/P-02)

Treats infinite loops as the highest-value bug ("a render storm or a frozen tab"). Every wiring
inspection greps for these; operations also checks the process-loop. Captured:

| ID | Pattern | Severity |
|---|---|---|
| **L-01** | `useEffect` with a setter + empty/missing deps that re-mounts. OK if deps `[]`; finding if deps array missing (runs every render). | MAJOR |
| **L-02** | `useEffect` sets a value listed in its **own** deps → classic loop. | CRITICAL |
| **L-03** | `effect()` that writes `signalX.value = …` **and** reads `signalX.value` → re-runs forever. | CRITICAL |
| **L-04** | state setter called in component **render body** (not in effect/handler) → infinite re-render. | CRITICAL |
| **L-05** | `signal.value =` at top level of component body (same problem as L-04, signals). | CRITICAL |
| **L-06** | recursive setter chain (A→sets X→effect calls B→sets Y→effect calls A). Heuristic, not greppable. | MAJOR |
| **L-07** | `while(true)` / `for(;;)` / unbounded recursion. | CRITICAL |
| **L-08** | render-time `fetch(`/`axios(` without a cancellable effect/abort. | MAJOR |

The reports' "Code-loop scan (L-01..L-08): PASS" line is where this is exercised. The recurring
verdict in the wiring reports is that all setters are called **only inside `onClick` handlers**, and
the single `effect()` in each store **writes to `document`+localStorage but never back to its own
signal** — so there is no feedback loop (explicitly noted for `app-settings.ts`, `toast-store.ts`,
`user-profile.ts`).

**Process loops:** **P-01 Stuck-loop** (CRITICAL escalation, mechanism in §1.4 above). **P-02
Inspection-frequency anomaly** (MAJOR/informational): 5+ inspections in 10 minutes for the same stage
= thrashing, flag even if each passes. Loop detection explicitly is **not** lint style, perf tuning of
legit recursion, or intentional React re-renders.

## 2.3 `inspector/prompt.md` — the master Inspector prompt (verbatim discipline)

The prompt run by the Explore subagent, `{STAGE}` ∈ `foundation/frame/wiring/finish/operations`.
Key clauses:

- Persona: *"You are the Building Inspector… You report to the owner, **not to Claude**. Be strict."*
  CRITICAL blocks, MAJOR needs approval, MINOR recorded.
- **Pre-flight (mandatory reads):** `RULES.md`, `checklist.md`, `loops.md`, and `ls inspections/`
  (read the **last 3** for stuck-loop).
- **Diff context:** `git -C /home/user/buildsmart diff HEAD~1 -- app/src` (whole `app/src` if `HEAD~1`
  unavailable).
- Apply **only** this stage's checklist items; do not re-audit other stages.
- **Output format is rigid:** `# Inspection #NNNN`, `## Counts`, `## Findings` (CRITICAL/MAJOR/MINOR,
  each with `קובץ:`/`ממצא:`/`כלל:`/`פעולה:`), `## Stuck-loop check`, `## VERDICT: GO|NO-GO`. Findings
  that PASS produce **no entry**. `NNNN` = next zero-padded sequence.
- Closing instruction: *"End your response with the VERDICT line and nothing else. Do not recommend,
  do not explain, do not editorialize. The report **is** the output."*

## 2.4 `inspector/README.md` — invocation

When to run each stage: **foundation** (changes under `src/store`, `src/data`, `src/test/types.ts`),
**frame** (`src/components`, `src/views`, `src/app.tsx`), **wiring** (new handlers/effects/signal
mutations), **finish** (`src/styles`, class names, ARIA), **operations** (always, last before commit).
Invoke = spawn an Explore agent with `prompt.md`. Report ends GO (commit allowed) or NO-GO (fix +
re-run). Claude saves it to `inspections/INSP-NNNN-{stage}-{date}.md`; on a 2+-recurrence the Inspector
escalates to CRITICAL stuck-loop and Claude **must STOP and ask the owner — no more retries**.
*"Each report is standalone and immutable. The history is the audit trail."*

## 2.5 `reporting.md` — the 7-section Hebrew owner-report format

After every significant action (commit, inspection, decision, discovery) Claude must give a Hebrew
summary in a **fixed format — deviation forbidden**. Required after: a `git commit`; any Inspector
NO-GO/stuck-loop; a discovery needing an owner decision; the end of a 5+-file series; any choice among
options. *Not* required for internal clarifications, throwaway sub-checks, or routine green typecheck/build.

The fixed 7-section template (verbatim headers):
1. **`## ✅ סיכום — {שם הפעולה}`** (title)
2. **מה עשיתי** — one or two plain-Hebrew sentences, no jargon.
3. **איך הלך** — inspection result: ✓ GO / ✗ NO-GO + the CRITICAL/MAJOR/MINOR counts.
4. **שינויים שאתה רואה** — up to 3 bullets of what the user sees on screen/in files.
5. **סיכונים** — risks; *never* say "no risk" if something is known; if truly none, write "אין סיכון מהותי" explicitly.
6. **מצב נוכחי** — material numbers in one line (e.g. "19/29 מיופים").
7. **מה הלאה** — up to 3 next options.
8. **צריך החלטה ממך?** — a specific question, or "לא — אני ממשיך".

Writing rules: **plain Hebrew** (translate "scaffold/stub/API"); **numbers, not vagueness** ("19/29"
beats "most features"); **short** (≤ 200 words, compress if longer); **end with a question or proposal,
never with "that's it"**; **risks always**. The doc includes a "good (short)" example and a "bad (avoid)"
example — the bad one is English, vague, no numbers, no risks, no question.

## 2.6 `agent-board.md` — the live two-agent task board

A living doc (`<!-- מסמך חי -->`) split between **Deep Agent** (Opus/Sonnet) and **Fast Agent**
(Haiku/Sonnet-fast). It opens with **"⚠️ קודם כל — קרא את R2"** and the warning that
`IMPLEMENTATION_PROTOCOL.md` is DEPRECATED. The Deep-Agent section is the session-by-session ledger
that mirrors the inspection arc (§1.2), **including the two ❌ reverted attempts** (SitesView/ProfileView;
Phase-0 dashboards) recorded as `→ רברטו (R2)`. It marks the three persona dashboards as
**"✅ ~~Dashboard view~~ — לא נבנה (R2) → BS dial drill במקום"** ("not built (R2) → BS dial drill instead").
The Fast-Agent section records TASK-001 (the smoke-test writing handoff) and a **do-not-touch list**:
`components/menu/`, `components/bs/`, `app-settings.ts`, `bs-store.ts`, `toast-store.ts`,
`user-profile.ts`, `inspections/`, `RULES.md`, `CLAUDE.md` — *"if unsure, stop and ask."*

## 2.7 `wip-menu-wiring.md` — the menu-wiring source of truth

*"Read this BEFORE touching any settings/menu code, even if you have conversation context."* Captures:
the status snapshot (**~70 settings leaves wired**, smoke 21/21), the wired-branch table (display 6,
notifications 4, accessibility 1, region 7, delivery 5, about 4, reset 1, security 23, support 15,
account 4), the store/binding architecture (`app-settings.ts` → `bs.settings.v1` + DOM effect;
`user-profile.ts` → `bs.profile.v1`, no DOM; `toast-store.ts` 3200 ms auto-clear; `app-store.ts`
`editingLeafKey` cleared on every transition; `LEAF_BINDINGS` keyed `'group>label>label'` with
`{action, isActive?, input?}`), the three reusable **patterns** (add a select/toggle leaf; add an R9
text-input leaf with `profileBinding(key,rowLabel,toastLabel)`; add an info-only toast leaf), the
required Inspector chain, and the open MINORs (INSP-0010 accessibility adaptation; the pre-existing
`vite.config.ts`/`worker.tsx` TS errors — later resolved, `tsc -b --noEmit --force` exit 0, blamed on
stale `.tsbuildinfo`). It restates R1/R3/R4/R5/R6/R8/R7/R9 as "rules to never break".

## 2.8 `knowledge/README.md` — the knowledge-system map

Declares the directory the **source of truth** for how the app is built. Layer map: `../RULES.md`
(the rules), `inspector/` (protocol), `inspections/` (immutable archive), `legacy-map.md`,
`adr/`, `spec.json`, `reporting.md`, future `contracts/`. Frames the Building Inspector as the
**replacement for an older PASS/FAIL audit**, with a comparison table: *single pass → 5 stages;
PASS/FAIL → CRITICAL/MAJOR/MINOR; lost-in-chat → written reports; rules-only → rules+ADRs+spec+
regression+loop-detection; advisory → authority to block commits.*

## 2.9 `adr/001-no-window.md` — ADR-001 No-Window UI (Accepted, 2026-05-20)

**Context:** the legacy `index.html` opens drawers/modals/sheets/overlays liberally; construction-site
users work "dirty-handed, small screens, single-handed, interrupted" — every modal is friction. The
owner stated the rule early and repeatedly: **"אף אחד מהם לא פותח חלון. נקודה."** ("none of them opens
a window. period."). Early window builds (`bs-panel.tsx` drawer, search submenus as sheets) had to be
rebuilt — "the cost of not honoring this constraint up front."
**Decision:** no full-window overlay — no side-drawer filling the height, no bottom/top sheet pushing
content, no `role="dialog" aria-modal="true"` on tool menus, no backdrop darker than a light
active-mode tint (**≤45% opacity, ≤3px blur**). **Two bounded exceptions:** `product-sheet` (focused
product detail) and the light menu/search backdrops (signal "active mode" only). When the legacy opens
a window, **translate it to the dial** (ADR-002).
**Rationale:** speed (dial reacts to the next tap; a window needs a close first), cognitive load
(nothing hidden), single-hand reach, reversibility (re-tap to undo). **Rejected alternatives:** port
windows as-is; windows with auto-dismiss timers; "windows for settings only" (ambiguous — who decides
what's a setting? ban universally).
**Verification:** Inspector FRM-02 (scans `position:fixed; inset:0`, new ones CRITICAL) + FRM-06
(backdrop opacity/blur). RULES.md **R2 is the human-readable form of this ADR.**

## 2.10 `adr/002-dial-pattern.md` — ADR-002 The Dial Pattern (Accepted, 2026-05-20)

**Context:** once ADR-001 banned windows, an alternative was needed to reveal a primary button's tools.
The answer is the **dial** — a vertical column of compact buttons dropping below / rising above the
parent, on the same side. **Decision (concrete rules):**
1. Dial opens on the **same side** as its parent (BS top-right drops down/right; search bottom-right
   rises up/right; menu bottom-left rises up/left; cart top-left drops down/left).
2. Each item is **two separate elements** — a ~48px circle (icon, own bg+shadow) and a pill (label, own
   bg+shadow) with a **~10px visible gap**; *not packaged in one container*.
3. Active item highlights **both** pieces in brand teal; inactive = white pill + teal icon.
4. Tapping an item with a sub-menu collapses the others; the selected stays in slot 1; its sub-menu
   opens in the same two-element style.
5. Re-tapping the selected item (or the parent) returns to the full dial.
**Rationale:** visual consistency with the no-window rule; the **two-element gap lets the bathroom
background show through** (part of the look-and-feel) — this is the explicit reason single-chip items
were rejected; same-side anchoring keeps everything thumb-reachable. **Rejected:** single-chip items
(too heavy, hides background); side-drawer; bottom sheet; horizontal dial above the FAB (less reachable).
**Verification:** Inspector FRM-03/04/05; RULES.md R3/R4/R5; regression buttons exercise
`toggleBs/toggleMenu/toggleSearch`.

## 2.11 `adr/README.md` — ADR conventions

A new ADR is required when: a rule (R1–R9) is added/changed/refined; a pattern conflicting with the
obvious alternative is chosen (dial vs drawer); a persistent technical decision is made (Preact vs
React); or a known violation is **accepted with rationale instead of fixed**. *Not* needed for routine
refactors/bug-fixes/small in-component choices. Fixed template (Status/Date/Owner/Related · Context ·
Decision · Rationale · Alternatives · Consequences[+/−/compat] · Verification). Numbering: zero-padded
three digits, monotonic, never re-used; obsolete ones marked `Superseded by ADR-XXX` (keep the file).
Code that exists *because* of an ADR may cite `/* @adr ADR-001 (no-window rule) */`; a future Contract
Auditor will verify cited ADRs exist.

## 2.12 `IMPLEMENTATION_PROTOCOL.md` — ⛔ DEPRECATED (what it prescribed, and why it's banned)

The file opens with a banner: **"⛔ DEPRECATED — אל תפעל לפי המסמך הזה"** ("do not act on this
document"), status **בוטל (cancelled) 2026-05-21** by the absolute R2 rule.

**What it prescribed (the substance):** a full implementation guide to convert the three placeholder
persona views (Store / Courier / Worker) into **full-featured dashboards** that fill
`<main class="content">`. It laid out:
- A new file structure: `store/courier/worker-role.ts` stores + `components/{store,courier,worker}/`
  folders (login, dashboard, home, orders, stock, portal, picker, summary, tasks, list, detail) + per-role
  `.css` files + **replacing** the placeholder `views/{store,courier,worker}.tsx`.
- Per-role stages mapped to the Inspector's FND/FRM/WIR/FIN/OPS, with concrete code: e.g.
  `activeStoreIndex = signal<0|1|2|null>(null)`, `storeLogin/storeLogout/storeAdvance/toggleStoreStock`,
  a `StoreView` that returns `<StoreLoginScreen/>` or `<StoreDashboard/>`, a `StoreDashboard` with a
  `<nav class="store-dashboard__tabs">` and a `<main class="store-dashboard__pane">` swapping
  `s-home/s-orders/s-stock/s-portal` — i.e. **a 4-tab full-screen dashboard**.
- A pre-commit checklist, a git-commit template citing `@rule/@adr/@legacy`, per-role validation tables,
  and a Q&A.

**Why it's DEPRECATED (the R2 violation):** it directs building Store/Courier/Worker dashboards as
**full views that fill `<main>`** — a direct breach of **R2 ("אין חלון מלא, נקודה")**. The banner
states **3 attempts to follow it were pushed and reverted** (it cites INSP-0016, INSP-0017, and
INSP-0022/0023/0024). The correct pattern is that persona functions live in the **BS-dial drill**
(see INSP-0025 onward), **not in views**. The file is *kept only for history (immutable per the
Inspector protocol)* and must **not** be read as a working instruction. Both `agent-board.md` and
`wip-menu-wiring.md` repeat this warning; the root `CLAUDE.md` lists it under "אסור לקרוא בתור הנחיה
לעבודה" ("forbidden to read as a work instruction").

> **Irony worth preserving:** the deprecated doc is itself *evidence for ADR-001/R2*. It is the
> best-written artifact of the wrong approach, and the reason the dial pattern won. Its FND/FRM/WIR/FIN/OPS
> mapping is sound; only its **target shape (a window)** is forbidden.

---

# → Relevance to the Flutter port

**Mirror the process; freeze the Preact-specific mechanics.**

**Mirror (port the discipline):**
- **The five-stage gate** (FND/FRM/WIR/FIN/OPS) ports cleanly to Flutter as
  `analyze → build → test → widget-render → behaviour`. The Flutter equivalents of OPS-01/02/03 are
  `flutter analyze` (clean), `flutter build web --release`, `flutter test` (10/10) — already the
  documented Flutter dev loop in the root `CLAUDE.md`. Keep the rule: **operations stage always runs,
  last before commit.**
- **Severity model + commit-blocking authority** (CRITICAL blocks / MAJOR needs approval / MINOR
  recorded) and the **immutable, numbered report archive** ("the history is the audit trail") are
  pattern-level and should carry over. The Flutter knowledge base already has `STATUS.md`/`PARITY.md`/
  `CHECKLISTS.md`/`TESTING.md`; an inspections-style ledger would be the natural continuation.
- **The 7-section Hebrew owner report** (`reporting.md`) is product/owner-facing, not stack-specific —
  keep it verbatim. The owner reads Hebrew; the format (numbers-not-vagueness, risks-always,
  end-with-a-question) is a communication contract, not a Preact artifact.
- **Stuck-loop (P-01) and the loop catalogue's *intent*** port over, but the **concrete patterns
  L-01..L-08 are Preact/`@preact/signals`-specific** (`useEffect` deps, `signal.value =` in render body,
  `effect()` self-feedback). In Flutter the equivalents are: `setState`/notifier writes during `build`,
  a `ChangeNotifier`/Riverpod provider that writes back to a value it watches, `addListener` cycles,
  unbounded `while(true)` in `build`. **Rewrite the patterns for Riverpod; keep the discipline of
  grepping for them every wiring change** and the P-01 escalation ("owner intervention, not another retry").
- **ADR-001 (no-window) and ADR-002 (dial-pattern) are the load-bearing decisions** and apply to the
  Flutter port *unchanged in spirit* — they are *why* R2 exists. The Flutter port's `DECISIONS.md`/
  `TARGET.md` should treat them as inherited. The verification hooks change form (a Flutter "FRM-02"
  scans for full-screen `Stack`/`Overlay`/`showModalBottomSheet`/`Dialog` widgets instead of
  `position:fixed; inset:0`), but the bright line is identical.

**Freeze (Preact-only, do not re-port as a process):**
- **The 43 inspection reports themselves** are the historical audit trail of the *Preact* app. They are
  reference (the *what was built and why* of ~270 leaves, the verbatim-string discipline, the three R2
  reverts), **not** a backlog to re-execute. Capture, don't replay.
- **`IMPLEMENTATION_PROTOCOL.md` is doubly frozen:** deprecated even within Preact, and its target shape
  (full-screen persona dashboards) is exactly what the Flutter port must *also* avoid. Read it only to
  understand *why* the dial pattern won. Do **not** let its plausible FND/FRM/WIR/FIN/OPS scaffolding
  tempt a "just this once" dashboard view.
- **`wip-menu-wiring.md`, `agent-board.md`, and the `bs.*.v1` localStorage / `LEAF_BINDINGS` /
  `'group>label>label'` mechanics** describe the *Preact implementation* of the dials. Their *content*
  (which leaves exist, which are deferred, the verbatim Hebrew) is gold for parity; their *code shapes*
  (signals, path-keyed binding maps, `LeafEditor`) are Preact and superseded by the Flutter
  trees/widgets documented in `01-shell-dials-components-trees.md`.

**The single most important inheritance:** R2 was *not* enforced by the automated Inspector — every
R2-violating report individually passed FND/FRM/WIR/FIN/OPS. It was the **owner** who caught all three
window builds. The Flutter port must therefore treat **"no window, every feature is a dial"** as a
human-owned invariant first and a checklist item second — the same lesson that cost the Preact app three
reverts.
