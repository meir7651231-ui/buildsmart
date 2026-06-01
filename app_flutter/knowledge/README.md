# app_flutter — Knowledge Protocol

Single source of truth for the **Flutter** app (`app_flutter/`). Read this
before touching code, even with conversation context. The legacy Preact
protocol lives in `app/knowledge/` and does **not** govern Flutter work.

## The index — by layer

> Rebuilt 2026-06-01 (Phase K · `KNOWLEDGE_AUDIT.md` rounds 2–3) to index **every**
> canonical doc (76 docs; previously 27 top-level docs were unindexed).
> Legend: ⛔ deprecated-stub (merged away) · ⚠️ superseded (deprecate pending).

### meta · index
| File | Role |
|---|---|
| `README.md` (this) | the index + the protocol |
| `STATUS.md` | current snapshot — screens, features, wiring counts, version, known-failing |
| `KNOWLEDGE_AUDIT.md` | Phase-K verdict ledger (rounds 1–3) — 4-field verdict before any doc merge/deprecate/archive |

### חוק-על · process law
| File | Role |
|---|---|
| `MASTER_PROTOCOL.md` | **consolidated process law — source of truth for *process*** (folds PROTOCOL · PLAYBOOK · CATALOG-CARD · SMARTPRODUCT_ROADMAP · AGENT_PATTERNS · SCHEMA · STATE_OVERVIEW · TESTS_OVERVIEW · HELPER_INDEX · CARD_FLOW · PROJECTS_GUIDE · COACH_MODE · BUNDLE_SPLIT · DECISIONS · CONVENTIONS). Protected by gate 88. |
| `PROTOCOL.md` | ⛔ superseded by `MASTER_PROTOCOL` — deprecated stub with section-map (2026-06-01). |
| `PLAYBOOK.md` | **continuous learning log** — every stuck→solved problem (env/git/dart/engine/refactor/persistence/UI) + PUSH POLICY. |
| `PROTOCOL_ENFORCEMENT.md` | overview of the 4 enforcement layers (git hooks · Claude hooks · auto-recovery · regression tests) |

### אימות · verification
| File | Role |
|---|---|
| **`VERIFICATION_PROTOCOL.md`** | **the single unified testing protocol** — ladder L0–L7, mutation, 100-step bug investigation, checklists, machinery registry. **Start here for verification.** |
| `TESTS_OVERVIEW.md` | per-file test index (102 files, 10 domains) — appendix to VERIFICATION |
| `mutation_log.md` | mutation-test record-keeping (enforced in sync) |
| `TESTING.md` | ⛔ merged → `VERIFICATION_PROTOCOL.md` §1/§3 (stub kept; enforced to exist) |
| `CHECKLISTS.md` | ⛔ merged → `VERIFICATION_PROTOCOL.md` §4b (stub) |
| `BUG_INVESTIGATION_PROTOCOL.md` | ⛔ merged → `VERIFICATION_PROTOCOL.md` §4 (stub) |

### ממשל-סוכנים · agent governance
| File | Role |
|---|---|
| `AGENT_COORDINATION.md` | permissions matrix for the agents + push/sync protocol + mandatory end-of-session report template + cross-agent findings |
| `AGENT_WORK_PLAN.md` | protocolist's prioritized task list |
| `AGENT_READINESS.md` | pre-handoff environment-readiness checklist |
| `AGENT_PATTERNS.md` | parallel-work playbook (disjoint paths, absolute paths, 3-agent ceiling) |
| `SESSION_REPORT_2026-06-01.md` | סיכום סשן — כל הסוכנים · v5.62 · חסמים פתוחים · עדכוני פרוטוקול |

### תוכניות-עבודה · roadmaps & fix-protocols
| File | Role |
|---|---|
| `ROADMAP.md` | 100-step full work plan to launch (grounded in prototype + Preact + current Flutter) |
| `SMARTPRODUCT_ROADMAP.md` | 100-step SmartProduct (card) plan + progress — **source of truth for *content*** |
| `SIZE_FILTER_PROTOCOL.md` | finder (בית) "גודל" axis — bug→fix→lessons protocol (P1–P10, 100-step plan, Live Log) |
| `IMPROVEMENTS_PROTOCOL.md` | round-2 improvements (I1–I10+) built on the size-filter foundation |
| `PROTOCOL_AUDIT_PLAN.md` | 100-step audit of the pre-commit gate logic itself |

### port · parity · target
| File | Role |
|---|---|
| `TARGET.md` | **prototype & target** — `index.html` prototype, parity goal, cutover, store launch |
| `PARITY.md` | **port map** — full inventory of prototype + Preact knowledge, Flutter status, phased dial-form plan. Source of truth for the parity effort; indexes `port/`. |
| `SPEC.md` | **spec map** — condensed every-screen/element/flow/status overview; points to `spec/` |
| `port/` | deep port knowledge (19 files): `proto/` (the prototype source) + `preact/` (dial-translation) + `design-system` + `COVERAGE`. Index: `port/README.md` |
| `spec/` | **full אפיון** — formal per-screen specs (9 files, 10 sections each, R8). Index: `spec/README.md` |

### ארכיטקטורה · מודל-נתונים
| File | Role |
|---|---|
| `ARCHITECTURE.md` | structure: screens / state / data / widgets, navigation, theming |
| `STATE_OVERVIEW.md` | inventory of ~28 state files + persistence keys |
| `SCHEMA.md` | data-model unification (catalog + VerifiedSpec + smart-tree + SKU bridge) |
| `HELPER_INDEX.md` | registry of ~45 data-layer helpers in `related_info.dart` |
| `CONVENTIONS.md` | light-mode, RTL, commit/version, inherited shell rules |
| `DECISIONS.md` | ADR-style log of notable decisions |
| `adr/` | formal Architecture Decision Records (ADR-001 No-Window · ADR-002 Dial). Index: `adr/README.md` |

### כרטיס-מוצר · קטלוג
| File | Role |
|---|---|
| `CATALOG-CARD-PROTOCOL.md` | step-by-step product-card building checklist (incl. §14.E recoverability) |
| `CARD_FLOW.md` | render-order walkthrough of the SmartProduct card, top-to-bottom |
| `COACH_MODE.md` | coaching vision (ROADMAP steps 99–100) |
| `PROJECTS_GUIDE.md` | "projects" feature reference (ROADMAP steps 71–80) |
| `REVIEW-product-card-nontech.md` | non-technical user feedback on the chip UX |
| `polyroll-ingest-spec.md` | Polyroll catalog ingestion spec (774 items) |

### למידה · lessons
| File | Role |
|---|---|
| `CARRY_FORWARD.md` | numbered cross-session lessons, distilled from `stuck_log` |
| `stuck_log.md` | living problem→solution→ANTIPATTERN log (append-only; gates 101/102) |

### הגדרות-תפקיד · session · build
| File | Role |
|---|---|
| `POLISH_PROTOCOL.md` | the **ליטוש** (polish) agent protocol — UI feel + knowledge-base polish (Phase K) |
| `LAUNCH_READINESS_PROTOCOL.md` | the **בנצי** (launch) agent protocol — store-readiness audit + submission package |
| `SESSION_PLAN_TEMPLATE.md` | mandatory structure for `session_plan.md` (gates 21/22/106) |
| `session_plan.md` | current-session artifact (ephemeral) |
| `BUNDLE_SPLIT.md` | web-payload code-split planning (ROADMAP step 88) |

### other · enforcement
| File | Role |
|---|---|
| `inspections/` | Flutter inspection archive (skeleton; legacy Preact INSP-0001→0044 in `port/preact/05`) |
| `../WIRING.md` | the wiring contract — every button/setting → behavior → status |
| `../test/knowledge_protocol_test.dart` | **enforcement** — fails the suite on protocol violations |

## The protocol — every change follows this

1. **Locate, don't invent.** Find the real code/string before editing. No
   feature, string, or behavior that isn't grounded in the codebase (R8).
2. **Extract logic to pure helpers** when it needs to be correct. Embedded
   widget logic (math, filters, mappings, thresholds) is moved to top-level
   pure functions so it can be unit-tested. See `cartVat`, `notifPasses`,
   `indexableWord`, `notifMutedSections`.
3. **Wire ⇒ contract ⇒ test.** Any setting/button wired to a real effect must
   be (a) listed in `../WIRING.md` with its status, and (b) covered by a check
   in `test/` (usually `gaps_test.dart` / `wiring_test.dart`). The contract and
   the tests stay in sync.
4. **Verify before commit:**
   ```bash
   export PATH="/home/user/flutter/bin:$PATH"
   cd app_flutter
   flutter analyze        # 0 errors (info/warnings from legacy dead code are tolerated)
   flutter test           # all green
   flutter build web --release
   ```
5. **Mutation-test the logic** when adding/altering a pure helper: inject a
   bug, confirm a test goes red, revert. The goal for domain logic is
   **100% caught** (see `TESTING.md`). UI-only effects are exercised through
   their underlying providers/helpers, not pixel rendering.
6. **Commit small (locally).** Target branch is `claude/whats-happening-LyY9G`.
   **Do NOT `git push` (to ANY branch) without explicit user approval each time**
   — see PLAYBOOK "PUSH POLICY". Let local commits stack; offer a push at a clean
   checkpoint, don't perform one. Bump the in-app version label
   (`home_shell.dart`) when shipping a user-visible change.

## Enforcement (the protocol has teeth)
`test/knowledge_protocol_test.dart` runs inside `flutter test` and **fails the
suite** when the protocol is violated:
- a screen regresses to a **dark surface** — `backgroundColor: Color(0xFF111111)`,
  `BsTokens.bgDark`, **or** a `ColoredBox`/`Container`/`DecoratedBox` filled with
  `0xFF111111` (text-colour use of `0xFF111111` stays allowed);
- a wired pure-helper (`cartVat`, `notifPasses`, `qtyForKey`, …) is removed/renamed;
- a knowledge doc or the `WIRING.md` contract drifts from the code.
This is verified to bite (re-injecting the dark search-panel fill turns it red).

## Status legend (used across these docs)
✅ wired (real effect) · 🚧 בבנייה (placeholder) · ⛔ blocked (needs data/server/telephony)
