# Pillar 4 — AI Co-Editor + Behavior / Component Builder

> **Branch:** `claude/whats-happening-LyY9G` · **Project:** `app_flutter/` (Flutter 3.29 · Dart 3.7 · Riverpod)
> **Status:** BUILD PLAN (grounded on the live code as of 2026-06-23). Nothing here is implemented yet.
> **Owner of THIS pillar:** the NL→config-diff bridge · the action-catalog · the component-palette · the rules/automation engine · preview/confirm/undo · safety/validation.
> **NOT owned here (coordinate, do not design):** Pillar 1 owns the **config-engine / element registry / wrapper API / draft→publish store**. Pillar 5 owns **backend / cost / rate-limit**. This pillar PRODUCES validated **diffs** into Pillar 1's draft and CALLS Pillar 5's `askClaude` seam.

---

## 0. The one-paragraph thesis

The Hebrew non-coder owner speaks a change — *"תהפוך את כל הכפתורים לירוקים"*, *"תסתיר את לשונית-הרכש מהשליחים"*, *"תוסיף כפתור 'הזמן שוב' בכל כרטיס-הזמנה"* — and the system turns it into a **validated config-diff** against Pillar 1's registry, shows a **preview**, and applies it on **confirm**, reversible by **undo**. The model NEVER writes config directly and NEVER emits a free-form id/action/color. Exactly like the four closed-set validators already shipped (`matchRecipe`, `matchCategory`, `matchAssistantCategory`, `matchAssistantRecipeKey`), the model may only NAME keys from a CLOSED SET that Pillar 1's registry defines; deterministic Dart turns those keys into the diff. A hallucinated id degrades to a harmless "couldn't understand" — never a wrong write. This is the same anti-hallucination posture the app already lives by, lifted from "classify a request into one recipe" to "classify a request into one validated config operation."

---

## 1. What already exists (the seams we build ON — cited)

### 1.1 The Claude seam (Pillar 5's territory — we are a caller)
- **`lib/data/repositories/claude_functions.dart`** — the injectable `ClaudeGateway` port (`ask({prompt, system?, model?, maxTokens?}) → ClaudeResult{text, model}`), the neutral `ClaudeException(code, message?)`, the real `FirebaseClaudeGateway` (lazy Functions resolution, 30s timeout), and `claudeGatewayProvider` (`claude_functions.dart:133-136` — null unless `useFirebaseBackend && kClaudeAi`). **We reuse this verbatim. We add no new gateway.**
- **`functions/src/claude.ts`** — the server proxy. Already enforces: auth (`claude.ts:117-119`), per-uid fixed-window rate limit 40/min (`claude.ts:49-50,75-103`), model allowlist `{haiku-4-5 default, sonnet-4-6}` (`claude.ts:35-38`), `kMaxPromptChars=8000` (`claude.ts:40,127-132`), `kMaxTokensCap=2048` (`claude.ts:41`), `maxInstances:10` + `timeoutSeconds:30` (`claude.ts:115`). **Our prompts must fit 8000 chars — this is the central cost/scale constraint (see §9).**

### 1.2 The anti-hallucination pattern we MUST reuse (the load-bearing reuse)
Four shipped closed-set validators — each: exact-match first, then **longest-contained** match (prefix-collision guard), else `null` → degrade. We copy this discipline 1:1.
- `matchRecipe` — `lib/screens/describe_to_cart_screen.dart:50-67`
- `matchCategory` — `lib/screens/ai_finder_screen.dart:53-69`
- `matchAssistantCategory` / `matchAssistantRecipeKey` — `lib/logic/assistant_intent.dart:58-95`
- The TOTAL JSON parser+validator `parseAssistantIntent` — `lib/logic/assistant_intent.dart:168-210` — ANY malformed / unknown-action / out-of-set reply → `AssistantIntent.answer` (never throws, never acts). **This is the exact shape of our `parseConfigEdit`.**
- The defense-in-depth sanitizer `promptSafeText({maxLen, collapseWhitespace})` — `lib/logic/prompt_sanitize.dart:19-27` — collapse newlines + cap untrusted free-text before interpolation. **We use it on the owner's utterance and on any owner-authored label/text that flows into a prompt.**

### 1.3 The propose → preview → confirm pattern (we generalize it)
- `DescribeToCartScreen._find()` proposes (`describe_to_cart_screen.dart:98-125`), validates via `matchRecipe`, shows the resolved kit; the cart write is a SEPARATE confirm tap.
- `AiAssistantScreen` — the canonical gated-mutation: a proposed kit is carried on the turn; the **only** write path is `_confirmAdd` behind an explicit button, tracked by `_confirmedKitTurns` (`ai_assistant_screen.dart:69-71, 208-229, 328-344`). **Our preview→confirm→apply mirrors this exactly, with the diff playing the role of the kit.**

### 1.4 The 4-rung honest off-state ladder
- `lib/widgets/ai_result_states.dart` — `AiOffState` / `AiLoadingState` / `AiFailedState(onRetry)` (`ai_result_states.dart:18-62`). Every AI screen gates on `ref.watch(claudeGatewayProvider) != null` and shows `AiOffState` when null. **Studio reuses this ladder verbatim — when the gateway is off, the co-editor shows an honest "requires connection" and the manual builder (no model) still works.**

### 1.5 Gating
- `lib/data/repositories/backend.dart` — `kClaudeAi` (`backend.dart:138`), `useFirebaseBackend` (`backend.dart:16-17`), `kUseFirebaseBackendFlag`, `kUidScopedQueries`, `kServerCallables`, `kCloudPhotos`, `kSeedFreshBackend`. **We add ONE new build flag `kStudioCoEditor` (§8) so the whole pillar ships dark and the demo build stays byte-identical (the established zero-regression invariant).**

### 1.6 The role model (the closed set for visibility-targeting)
- `enum BsRole { contractor, store, courier, worker, manager, bot }` — `lib/state/sys_chat.dart:45`.
- `enum BoardRole { worker, courier, store, manager }` — `lib/state/board_auth.dart:24`.
- **"תסתיר … מהשליחים" resolves `שליח → BsRole.courier` against THIS enum** — never a free-form role string. Visibility is keyed by `BsRole` (closed set).

### 1.7 Where Studio lives (the manager surface)
- `lib/screens/manager_dashboard_screen.dart` — cockpit hero `_CopilotHero` (~`:420`) opens `ManagerCopilotScreen`. AppBar already exposes a **No-Code** settings entry whose help text says *"שליטת No-Code על הפרמטרים שכל הקבלנים רואים"* (`manager_dashboard_screen.dart:181-198`), pushing `CatalogSettingsScreen.route(showProfileRow:false)`. **Studio is a NEW cockpit hero card next to the Co-Pilot hero (manager-only), opening `StudioScreen`.** Route pattern: `static Route<void> route()` + `Navigator.of(context).push(...)` (the universal pattern, e.g. `manager_copilot_screen.dart:32`).

### 1.8 Persistence pattern (how Pillar 1's draft will look — we conform to it)
- `lib/state/feature_flags.dart` — versioned key (`'bs.feature-flags.v1'`), `_load()` in ctor, `_persist()` on mutation (`feature_flags.dart:41,66-72,82-87`).
- `lib/state/smart_cart.dart` — `toJson`/`fromJson` per line. **Our diff/op model is JSON-serializable in the same idiom so Pillar 1 can stage it in the draft.**

---

## 2. The closed-world contract with Pillar 1 (the registry — the keystone)

**Everything downstream depends on this.** Pillar 1 owns it; this section is the **interface we require** and design against. If Pillar 1's shape differs, only the thin adapter in §3.1 changes.

The registry is the single source of truth of "what exists." From it we derive every closed set the model is allowed to name:

```
ElementRegistry (Pillar 1, read-only to us)
  elements:  List<RegisteredElement>
    id            : String         // stable, e.g. "tab.purchasing", "card.order", "btn.reorder"
    kind          : ElementKind    // tab | screen | card | button | section | text | form
    editableProps : Set<PropKey>   // which props this element exposes (closed set per element)
    allowedActions: Set<ActionId>? // for buttons: which catalog actions are legal here
    container     : String?        // parent id (for "in every order card")
    roleScoped    : bool           // may this element's visibility be role-targeted?
  props:        the typed prop schema per PropKey  (color | bool | enum<values> | text | actionRef)
  actionCatalog: List<ActionDescriptor>   // §4 — the closed set of "what a button DOES"
  componentPalette: List<ComponentTemplate> // §5 — the closed set of "what you can ADD"
```

Three derived **closed sets** (the model may ONLY name from these), each exposed by a registry query we call at prompt-build time and re-validate against on parse:
1. **`elementIds()`** — every real element id.
2. **`propKeysFor(id)`** + **`allowedValues(id, propKey)`** — per-element editable props and (for enums/colors) the legal value set.
3. **`actionIds()`** / **`actionIdsFor(elementId)`** — legal actions (§4).
4. **`componentTypes()`** — palette templates (§5).

> **Anti-hallucination invariant (the whole pillar in one line):** the model output is validated against these sets BEFORE any diff is built. An id/prop/value/action/component the registry doesn't contain is dropped → the op degrades. Identical posture to `matchRecipe` dropping a non-existent recipe key.

---

## 3. Architecture: NL → validated config-diff

### 3.1 New layer map (all PURE + testable, mirroring `assistant_intent.dart`)

| New file | Role |
|---|---|
| `lib/logic/studio/registry_view.dart` | **Thin read-only adapter** over Pillar 1's `ElementRegistry`. Exposes `elementIds()`, `propKeysFor`, `allowedValues`, `actionIds(For)`, `componentTypes()`, and `matchElementId/matchPropKey/matchValue/matchActionId/matchComponentType` — each an exact-then-longest-contained closed-set resolver returning `null` on miss (copy of `matchRecipe`). The ONLY place that knows Pillar 1's concrete types. |
| `lib/logic/studio/config_op.dart` | The **closed operation model** (`ConfigOp` sealed set, §3.3) + JSON (`toJson`/`fromJson`) so Pillar 1 can stage it. Pure data. |
| `lib/logic/studio/edit_intent.dart` | `parseConfigEdit(String raw, RegistryView) → List<ConfigOp>` — the **TOTAL parser+validator** (copy of `parseAssistantIntent`): extract JSON, validate every field against the registry, drop invalid ops, never throw. The anti-hallucination core. |
| `lib/logic/studio/edit_prompt.dart` | `studioEditPrompt(...)` + `studioEditSystem` — the **grounded prompt builder** that embeds the closed sets (the chunking + budget logic of §9 lives here). |
| `lib/logic/studio/action_catalog.dart` | The static `ActionDescriptor` list (§4) — the closed catalog of what a button can DO, each mapped to a deterministic Dart effect. |
| `lib/logic/studio/component_palette.dart` | The static `ComponentTemplate` list (§5) — closed set of addable components + their required-prop schema. |
| `lib/logic/studio/rules_model.dart` | The `Rule` model (trigger/condition/action — all closed sets) + `parseRule` (§6). |
| `lib/logic/studio/diff_preview.dart` | `summarizeDiff(List<ConfigOp>, RegistryView) → List<DiffLine>` — pure, Hebrew, human-readable preview rows (no model). |
| `lib/logic/studio/edit_safety.dart` | `validateSafe(List<ConfigOp>, RegistryView) → SafetyVerdict` — the §7 guardrails (nav/auth immutability, role-floor, etc.). Pure. |
| `lib/screens/studio_screen.dart` | The manager-only Studio entry (chat-like co-editor + tabs for manual builder/rules). Mirrors `ManagerCopilotScreen` UI + the gated-confirm of `AiAssistantScreen`. |
| `lib/screens/studio_component_builder.dart` | Manual (no-model) component/action wiring UI driven by the palette + catalog (the "click it" path that ALWAYS works, even gateway-off). |
| `lib/screens/studio_rules_screen.dart` | Manual + NL rules builder. |

**Why pure logic separate from screens:** every shipped AI feature keeps the prompt/validate logic in `lib/logic/*` so tests drive it with a hand-rolled fake gateway and zero widget pump (`assistant_intent_test.dart`, `manager_copilot_test.dart`). We do the same — grounding is provable without rendering.

### 3.2 The runtime flow (one utterance → applied diff)

```
owner speaks/types  →  promptSafeText(utterance, maxLen:600)         [defense-in-depth, prompt_sanitize.dart]
        │
        ▼
studioEditPrompt(utterance, registryView)   [embeds the closed sets + ops grammar, edit_prompt.dart]
        │   system = studioEditSystem ("name ops from the closed lists; never invent an id/prop/value")
        ▼
claudeGatewayProvider.ask(prompt, system, model: pinned, maxTokens)   [the SHARED seam, unchanged]
        │   reply = strict JSON: {"ops":[ {op,target,prop,value,...}, ... ]}
        ▼
parseConfigEdit(reply, registryView)         [TOTAL: validate EVERY field vs registry, drop invalid, never throw]
        │   → List<ConfigOp>   (already closed-set-clean; invalid entries silently dropped)
        ▼
validateSafe(ops, registryView)              [§7 guardrails: nav/auth, role-floor, prop-type]
        │   → SafetyVerdict { applied: List<ConfigOp>, blocked: List<(op, reasonHe)> }
        ▼
summarizeDiff(applied, registryView)          [pure Hebrew preview rows + "X שינויים נחסמו: …"]
        │
        ▼  ── PREVIEW SHOWN, awaiting confirm (no write yet) ──
        ▼
[owner taps "אשר ופרסם לטיוטה"]  →  Pillar1.draft.apply(applied)   [WE produce the diff; PILLAR 1 stages it]
        ▼
Pillar 1 draft updated → live PREVIEW re-renders via the wrapper API (Pillar 1)
        ▼
[undo]  →  Pillar1.draft.revertLast()   (we keep an op-stack mirror for our own UI; truth is Pillar 1's)
```

Key correctness carry-overs from the shipped screens:
- **Stale-response race guard** (`|| _loading` in `describe_to_cart_screen.dart:104`, `ai_finder_screen.dart:121`): re-submit mid-flight is blocked so a late reply can't overwrite a newer preview.
- **200-empty → honest retry** (not a blank box) — `reject_reason_screen.dart:92-93`, `quote_polish_screen.dart:91-92`.
- **`mounted` guard after every await** (all screens).
- **Confirm is a separate, explicit, tracked tap** (`ai_assistant_screen.dart` `_confirmedKitTurns`). The model NEVER triggers `apply`.

### 3.3 The closed operation model (`ConfigOp`)

A small sealed family. **Each op's every field is validated against the registry** before it becomes a `ConfigOp`. (Concrete prop/value names are illustrative; the registry defines the real closed set.)

```
sealed ConfigOp
  SetProp     { target: ElementId, prop: PropKey, value: PropValue }   // "כפתורים → ירוק" → many SetProp(color)
  SetVisible  { target: ElementId, role: BsRole?, visible: bool }      // "הסתר רכש מהשליחים"
  AddComponent{ container: ElementId, template: ComponentType,
                props: Map<PropKey,PropValue>, action: ActionId? }     // "הוסף כפתור 'הזמן שוב' בכרטיס-הזמנה"
  SetAction   { target: ElementId(button), action: ActionId,
                args: Map<String,String> }                             // wire what a button DOES
  SetText     { target: ElementId, text: String }                     // "כתוב מחדש כותרת"  (text = promptSafeText'd)
  AddRule     { rule: Rule }                                           // "כשהזמנה תקועה >2 ימים → התרע למנהל"
```

- **Batch/broadcast** ("כל הכפתורים", "בכל כרטיס-הזמנה"): the model returns a `scope` token from a CLOSED scope set (`all-buttons`, `every:card.order`, `single:<id>`); `parseConfigEdit` **expands scope to concrete ids by querying the registry** (`elementIds().where(kind==button)`), NOT by trusting the model to enumerate ids. Expansion is deterministic Dart over real ids → fully grounded, and a broadcast that hits 40 buttons is 40 validated `SetProp` ops, each individually safe.
- **`SetText` value** is the one place model PROSE becomes content; it is `promptSafeText`'d and (per §7) cannot target nav/auth labels.

---

## 4. The Action Catalog (what a button DOES)

A static, closed list — the universe of behaviors a button may be wired to. Sourced from the app's REAL navigation/sheet surface (Explore survey): `static Route<void> route()` screens and `open*Sheet`/`show*Sheet` helpers. The model may ONLY name an `ActionId` from this list; `matchActionId` validates it.

```
ActionDescriptor { id, he, kind, argSchema }
```

Initial catalog (each maps to a deterministic Dart effect; ids are stable):
| ActionId | Hebrew | Effect (grounded in real code) |
|---|---|---|
| `nav.screen` | מעבר למסך | `Navigator.push(<Screen>.route(args))` — target screen picked from a **closed screen-id set** derived from the registry's known routes (e.g. `manager_copilot_screen.dart:32`, `ai_finder_screen.dart:83`). |
| `open.sheet` | פתח חלונית | `showModalBottomSheet(...)` via a registered opener (e.g. `openScanPlanSheet`/`openCheaperAlternativesSheet`, `contractor_tools_sheets.dart:26,39`). |
| `cart.add` | הוסף לסל | the canonical `smartCartProvider.notifier.add(SmartCartLine(...))` write (the ONLY cart-write idiom, `ai_assistant_screen.dart:210-222`). Used by "הזמן שוב". |
| `cart.open` | פתח סל | switch to cart tab (`mainTabProvider`, `ai_hub_screen.dart:113`). |
| `rule.run` | הפעל אוטומציה | run a saved `Rule` (§6) on demand. |
| `share.text` | שתף/העתק | `Clipboard.setData` + snackbar (the `reject_reason_screen.dart:110-117` idiom). |
| `noop` | ללא פעולה | safe default for a new placeholder button. |

- **`nav.screen` target is itself a closed set** — the registry enumerates which screens are navigable; the model names a `screenId`, validated by `matchScreenId`. A button can never navigate to a screen that doesn't exist.
- **Args are typed + closed** (`argSchema`): e.g. `cart.add` takes a `productKey` validated against the catalog (reuse `matchRecipe`/SKU lookup). No free-form args reach an effect.
- **No catalog action mutates auth/role/nav-structure** — those are not in the catalog at all (closed by omission; §7).

---

## 5. The Component Palette (what you can ADD)

A static, closed set of templates the owner can instantiate. The model (or the manual builder) names a `ComponentType`; each template declares a **required-prop schema** so the produced `AddComponent` op is fully typed and validated.

```
ComponentTemplate { type, he, allowedContainers: Set<ElementKind>,
                    requiredProps: Map<PropKey,PropType>, optionalAction: bool }
```

Initial palette:
| ComponentType | Hebrew | Allowed containers | Required props |
|---|---|---|---|
| `button` | כפתור | card · section · screen | `label:text`, (`action:actionRef` optional) |
| `textBlock` | טקסט | card · section · screen | `text:text` |
| `badge` | תווית/מדבקה | card | `text:text`, `tone:enum{info,warn,danger}` |
| `divider` | מפריד | section · screen | — |
| `infoCard` | כרטיס-מידע | screen · section | `title:text`, `body:text` |
| `linkRow` | שורת-קישור | section · screen | `label:text`, `action:actionRef` |

- **`allowedContainers`** is enforced against the target's `kind` from the registry: "הוסף כפתור בכרטיס-הזמנה" only validates if `card.order.kind == card` and `button` lists `card`. A request to add a button "into auth" fails validation (auth element kind not in `allowedContainers`, and §7 blocks it regardless).
- **Rendering is Pillar 1's wrapper job.** We only emit the validated `AddComponent` op (type + typed props + optional validated action). Pillar 1's wrapper renders palette components from config — we never construct widgets here.
- **`label`/`text` props** pass through `promptSafeText` (owner-authored, may carry an injection lever if the owner later edits another element via NL whose label echoes back).

---

## 6. The Rules / Automation model

Simple **when → (if) → then**, every slot a closed set. No free-form code, ever.

```
Rule { id, trigger: TriggerId, condition: Condition?, action: RuleActionId, args: Map<String,String> }
TriggerId   (closed):  order.stuck | order.created | order.delivered | credit.high | stock.low
Condition   (closed):  field ∈ {stage, ageDays, creditPct, qty}  op ∈ {>,>=,<,==}  value:num
RuleActionId(closed):  notify.manager | notify.role(BsRole) | flag.order | suggest.reorder
```

- *"כשהזמנה תקועה >2 ימים → התרע למנהל"* → `Rule(trigger:order.stuck, condition:(ageDays>2), action:notify.manager)`. Every token validated: `order.stuck ∈ TriggerId`, `ageDays ∈ Condition.field`, `notify.manager ∈ RuleActionId`. A hallucinated trigger/action drops the rule (degrade to "couldn't build that automation").
- **Evaluation is deterministic Dart** over the live engines (e.g. `ordersEngineProvider`, `managerAnalyticsProvider` — the same providers the copilot folds, `manager_copilot_screen.dart:53-64`). Phase 1 rules are **read-only / advisory** (compute + surface a notice/toast) — they do not mutate orders. The mutating actions (`flag.order`, `suggest.reorder`) follow the SAME confirm gate as every other write and ship in a later phase.
- Rules persist in Pillar 1's draft like any config (JSON via `rules_model.dart` `toJson`).

---

## 7. Safety / validation (the AI can't break the app)

Layered, defense-in-depth. **The model is structurally incapable of most damage because the dangerous operations are not in any closed set it can name.** `validateSafe` (`edit_safety.dart`) is the explicit backstop on top.

1. **Closed-set grounding (primary).** Unknown id/prop/value/action/component/trigger → dropped at `parseConfigEdit`. Mirrors `parseAssistantIntent` (`assistant_intent.dart:185-204`). Grounding tests (§10) prove invented inputs degrade.
2. **Nav/auth immutability (hard floor).** Elements whose `id` is in a registry-declared `kImmutable` set (the role-picker, login boards, the manager's own session controls, the bottom-nav structure) reject EVERY op (`SetVisible`, `SetProp`, `AddComponent` into them, `SetText` on their labels). The owner cannot hide the login, delete a nav tab, or relabel "יציאה". Rationale grounded in the existing product rule "המנהל לא מתנתק" (`manager_dashboard_screen.dart:200-209`) and the board isolation SPEC §2.5 (`sys_chat.dart:13-15`).
3. **Role-visibility floor.** `SetVisible` may hide an element from SOME `BsRole`s but a registry `kRoleFloor` map guarantees a minimum: e.g. a manager-critical surface can't be hidden from `manager`; a tab can't be hidden from EVERY role (orphaning it). Prevents "הסתר הכל מכולם."
4. **Prop-type + value validation.** `SetProp(color)` only accepts a value in `allowedValues(id,'color')` (a closed palette — no arbitrary hex from the model; "ירוק" maps to the brand-green token, validated). Enums validated against `allowedValues`. Type mismatch → dropped.
5. **Action legality per element.** `SetAction`/`AddComponent.action` validated against `allowedActions` for that element (`actionIdsFor(id)`). A button in a read-only context can't be wired to a mutation it isn't allowed.
6. **Batch ceiling.** A broadcast op expanding to > `kStudioMaxBatch` (e.g. 80) targets is rejected with an honest "השינוי נרחב מדי — צמצם" rather than silently rewriting the whole app (DoS/foot-gun guard; cost guard too).
7. **Draft-only, never live, never auth-write.** We emit diffs into Pillar 1's **draft**; publish to live is Pillar 1's gated step (their governance). This pillar performs NO Firestore/auth write directly. Honors the established "client proposes, server/owner-gate sanctions" posture (`backend.dart:66` `kServerCallables` philosophy).
8. **Preview + explicit confirm + undo.** No diff applies without the confirm tap (the `_confirmAdd` gate, `ai_assistant_screen.dart:208-229`). Undo reverts the last applied batch (op-stack mirror; Pillar 1 is the source of truth). Blocked ops are SHOWN ("נחסמו 2 שינויים: …") so the owner understands, never silently swallowed.
9. **Prompt-injection defense-in-depth.** Owner utterance + any owner-authored label that re-enters a prompt are `promptSafeText`'d (collapse newlines + cap) — `prompt_sanitize.dart`. Even a crafted utterance can only ever yield closed-set ops; injection cannot manufacture a new id/action.

> **Governance #84 (no-HR / no-governance-bypass):** Studio edits PRESENTATION + BEHAVIOR wiring + advisory automations only. It exposes NO HR field, NO credit/role-grant control, NO ability to bypass auth or the board-isolation model. The action-catalog and component-palette simply do not contain any such capability (closed by omission). The role-floor (#3) and nav/auth immutability (#2) make the isolation model un-editable by the co-editor.

---

## 8. Gating & off-state

- New build flag **`kStudioCoEditor`** in `backend.dart` (`bool.fromEnvironment('STUDIO_CO_EDITOR')`, default OFF) — the whole pillar ships dark; demo/test build byte-identical (the established invariant of `kClaudeAi`/`kCloudPhotos`/`kServerCallables`).
- A `studioCoEditorProvider` exposes `(enabled: kStudioCoEditor && useFirebaseBackend, ai: claudeGatewayProvider != null)`.
- **Honest off-states (two independent axes):**
  - Pillar off (`kStudioCoEditor` false) → no Studio hero on the manager cockpit at all (byte-identical dashboard).
  - Pillar on but **gateway off** (`claudeGatewayProvider == null`) → Studio opens, the **manual** builder/rules work fully (no model needed), and the NL co-editor pane shows `AiOffState('💡 העריכה-החכמה בדיבור דורשת חיבור לשרת.')` (`ai_result_states.dart:18-28`). This is the key design choice: **the no-code builder is useful even with no AI** — speech is the upgrade, not the dependency.
- Manager-only: Studio renders only when `boardAuthProvider?.role == BoardRole.manager` (the dashboard's own guard idiom, `manager_dashboard_screen.dart:73-75`).

---

## 9. Cost / rate-limit notes (the scale constraint)

- **The 8000-char prompt cap (`claude.ts:40`) is the binding constraint.** A large app's full registry (hundreds of element ids + props) will NOT fit in one prompt. Strategy:
  1. **Two-stage / retrieval grounding.** Stage A: a tiny prompt classifies the utterance to a **scope** (which element-kind / area — e.g. "buttons", "the purchasing tab", "order cards") from a small closed set. Stage B: build the edit prompt with ONLY that scope's element ids/props (a few dozen, well under 8000). This keeps grounding exact while bounded — and most utterances ("כל הכפתורים…") need only the relevant slice.
  2. **Compact registry encoding** — `id=he` one-liners (the `kSmartProducts.map((r)=>'${r.key}=${r.name}')` idiom, `describe_to_cart_screen.dart:34`), not verbose JSON.
  3. **`maxTokens` pinned small** — an ops reply is short JSON; pin ~256 (like the assistant, `ai_assistant_screen.dart:108`), never near the 2048 cap.
- **Model tier.** Default `claude-haiku-4-5` (`claude.ts:31`) handles closed-set classification well (proven by the shipped finder/assistant). Allow opt-in to `claude-sonnet-4-6` (the only stronger allowed tier) for the harder "rewrite all headings in a friendly tone" rephrase op — pinned per-call, still within the allowlist (`claude.ts:35-38`).
- **Rate limit is already enforced server-side** (40/min/uid, `claude.ts:75-103`). Studio is a single-owner, low-frequency surface (a few edits per session), so it sits far under the limit. No new limiter needed; we INHERIT Pillar 5's. **Coordinate with Pillar 5** only if a future "rewrite ALL headings" fans out to many calls — that should batch into ONE call (all headings in one prompt), not N calls.
- **Preview is free** (`summarizeDiff` is pure Dart, no model). Re-previewing a tweak costs nothing.

---

## 10. Gate & test strategy (100-gate protocol + grounding tests)

**Per the project protocol every commit:** `flutter analyze` (0 errors, gate #31) · `flutter test` (0 regressions, gate #32) · `flutter build web` clean (#33) · `knowledge_protocol_test` green (#94) · update `WIRING.md` (#24) · Hebrew strings & emoji from legacy only (#61/#64) · RTL no hard left/right (#62/#63) · WCAG AA colors (the `dangerDark` lesson, `ai_result_states.dart:15`).

**New gate to register** (GATE_REGISTRY next-free = **#118**): *"studio diffs validated against the registry — `parseConfigEdit` drops every invented id/prop/value/action/component (grounding test green)."* Add to `.githooks/pre-commit`, bump next-free to 119 (per the GATE_REGISTRY add-protocol).

**Test files (pure-logic, hand-rolled fake registry + fake `ClaudeGateway` — the established style of `assistant_intent_test.dart`, `manager_copilot_test.dart`, `ai_finder_test.dart`):**

1. `test/studio_edit_intent_test.dart` — the grounding core (mirror `assistant_intent_test.dart:28-54`):
   - A valid op against a REAL element id/prop/value parses and carries the validated fields.
   - An **invented element id** → op dropped (degrade), like `findProduct` with an invented category (`assistant_intent_test.dart:28-33`).
   - An **invented prop / out-of-palette color / invented action / invented component type / invented trigger** → each dropped.
   - **Malformed / non-JSON / partial / `{}` / prose-wrapped** → empty op list, never throws (mirror `assistant_intent_test.dart:40-61`).
   - **Longest-contained match** wins on a wrapped reply (prefix-collision guard, mirror `assistant_intent_test.dart:121-146`).
2. `test/studio_edit_prompt_test.dart` — the prompt embeds the closed element/prop/action/component sets + demands strict JSON ops + caps the utterance (mirror `manager_copilot_test.dart` cap test). Verify the two-stage scope prompt stays under 8000 chars for a large synthetic registry.
3. `test/studio_safety_test.dart` — `validateSafe`: nav/auth element rejects all ops; can't hide a tab from EVERY role; can't hide from `manager`; batch over ceiling rejected; blocked ops carry a Hebrew reason; **NO op can touch an HR/role/auth capability** (governance #84 assertion — assert those ids/actions are absent from every closed set).
4. `test/studio_diff_preview_test.dart` — `summarizeDiff` produces correct Hebrew rows; a broadcast renders "N שינויים"; blocked count shown.
5. `test/studio_rules_test.dart` — `parseRule` validates trigger/condition/action closed sets; "הזמנה תקועה >2 ימים → התרע למנהל" round-trips; invented trigger/action drops.
6. `test/studio_action_catalog_test.dart` — every `ActionId` resolves to an effect; `nav.screen` targets only registry-known screen ids; args validate; no catalog action is a mutation outside the confirm gate.
7. `test/studio_screen_behavior_test.dart` — widget test (mirror `manager_copilot_screen_behavior_test.dart`): gateway-null → `AiOffState` + manual builder still usable; a confirmed diff calls Pillar 1's draft.apply exactly once; preview shows before any apply; undo reverts.
8. `test/studio_gating_test.dart` — `kStudioCoEditor` false → no Studio hero (byte-identical dashboard); manager-only guard.

**Injection / sanitize tests** — assert owner utterance + owner-authored labels are `promptSafeText`'d (collapse newline, cap) before interpolation (mirror `manager_copilot_test.dart:75-93`).

---

## 11. Phased build plan (numbered)

**Phase 0 — Coordinate the registry contract (BLOCKING, with Pillar 1).**
0.1 Agree the `ElementRegistry` query surface (§2) + the draft `apply/revertLast` API + the JSON op shape Pillar 1 stages. 0.2 Stub `registry_view.dart` against an in-memory fake registry so this pillar can build/test BEFORE Pillar 1 lands (the fake-gateway discipline, applied to the registry). Deliverable: a frozen interface doc + the fake.

**Phase 1 — Closed model + validators (pure, no UI, no model).**
1.1 `config_op.dart` (sealed ops + JSON). 1.2 `action_catalog.dart` + `component_palette.dart` (static closed sets, grounded in real routes/sheets). 1.3 `registry_view.dart` matchers (copy `matchRecipe`). 1.4 `edit_intent.dart` `parseConfigEdit` (TOTAL, copy `parseAssistantIntent`). 1.5 `edit_safety.dart` `validateSafe`. 1.6 `diff_preview.dart`. Gate: tests 1,3,4,6 green. **This phase delivers the entire anti-hallucination spine with zero AI calls.**

**Phase 2 — Manual (no-model) builder UI.**
2.1 `studio_screen.dart` shell as a manager cockpit hero + route. 2.2 `studio_component_builder.dart` — pick element → edit prop / set visibility-by-role / add palette component / wire action — all driving `ConfigOp`s through `validateSafe` → preview → confirm → Pillar 1 draft. 2.3 Undo. Gate: tests 7,8 + the protocol gate set. **Ships a working no-code builder even with `kClaudeAi` OFF.**

**Phase 3 — NL co-editor (add the model).**
3.1 `edit_prompt.dart` (grounded prompt + two-stage scope, §9). 3.2 Wire the co-editor pane in `studio_screen.dart` through the SHARED `claudeGatewayProvider` with the propose→preview→confirm flow (§3.2), reusing the race/empty/mounted guards. 3.3 `AiOffState` when gateway null. Gate: tests 2 + grounding suite; new gate #118 registered. **"speak it, don't click" goes live behind `kStudioCoEditor && kClaudeAi`.**

**Phase 4 — Rules / automation.**
4.1 `rules_model.dart` + `parseRule`. 4.2 `studio_rules_screen.dart` (manual + NL). 4.3 Deterministic read-only evaluation over live engines → advisory notices. Gate: test 5. Mutating rule-actions deferred to a later phase behind the same confirm gate.

**Phase 5 — Polish / scale / coordinate Pillar 5.**
5.1 Batch the "rewrite ALL X" fan-out into single calls (cost). 5.2 Confirm the inherited rate-limit headroom with Pillar 5; add a client-side debounce if needed. 5.3 a11y/RTL pass on every new surface; visual_log (#107/#116).

---

## 12. Risks & mitigations

| Risk | Mitigation |
|---|---|
| **Registry doesn't fit in 8000-char prompt** at scale | Two-stage scope retrieval (§9.1) + compact `id=he` encoding; only the relevant slice is grounded per utterance. |
| **Pillar 1 interface churn** | All Pillar-1 knowledge isolated in `registry_view.dart`; build/test against a fake registry (Phase 0). Only the adapter changes if their shape moves. |
| **Model invents an id/action** | Structurally impossible to ACT on — `parseConfigEdit` drops it (closed-set, proven by grounding tests #1). Same guarantee as `matchRecipe`. |
| **Owner hides login / breaks nav / bypasses auth** | nav/auth immutability + role-floor (§7.2-3); those capabilities are absent from every closed set (governance #84). |
| **Broadcast rewrites whole app by accident** | Batch ceiling (§7.6) + preview shows "N שינויים" before confirm + undo. |
| **Color/text injection via NL** | `allowedValues` closed palette for colors; `promptSafeText` on all owner free-text (§7.9). |
| **Cost runaway from a "rewrite everything" loop** | Inherited server limiter (40/min, `claude.ts`) + single-batched calls + small `maxTokens` + maxInstances ceiling. |
| **Confusion: preview vs applied vs published** | Three explicit states in UI (draft-preview / applied-to-draft / Pillar-1-publish); Studio only ever touches the DRAFT. |
| **Demo/test build regression** | `kStudioCoEditor` default OFF → byte-identical dashboard; gating test #8. |

---

## 13. New files & touched seams (summary)

**New (this pillar):** `lib/logic/studio/{registry_view, config_op, edit_intent, edit_prompt, action_catalog, component_palette, rules_model, diff_preview, edit_safety}.dart` · `lib/screens/{studio_screen, studio_component_builder, studio_rules_screen}.dart` · `test/studio_*` (8 files).
**Touched (additive only):** `lib/data/repositories/backend.dart` (+`kStudioCoEditor`) · `lib/screens/manager_dashboard_screen.dart` (+Studio cockpit hero, ~`:420`, manager-only) · `WIRING.md` (#24) · `knowledge/GATE_REGISTRY.md` + `.githooks/pre-commit` (+gate #118) · `STATUS.md`/`ROADMAP.md` (#92/#93).
**Reused unchanged:** `claude_functions.dart` (the gateway), `functions/src/claude.ts` (the proxy + limits), `prompt_sanitize.dart`, `ai_result_states.dart`, the `BsRole`/`BoardRole` enums, the propose→confirm idiom.
**Coordinated (NOT built here):** Pillar 1's `ElementRegistry` + draft `apply/revertLast` + wrapper render; Pillar 5's backend/rate-limit.

---

## 🔧 תיקוני Red-Team R1 (מחייב — מחליף סעיפים סותרים)

> מקור: `RED-TEAM-R1.md` (סבב-1, 2026-06-23). הסעיפים כאן **גוברים** על כל ניסוח קודם במסמך זה.
> כל פריט: *מה משתנה · §-מוחלף · שלב מושפע.* התמה המרכזית של R1 ל-P4: **התפר P1↔P4 תת-מוגדר** ו-**אכיפת-הבטיחות חייבת לרוץ בשרת** — ה-client הוא advisory בלבד.

### R1-1 · אכיפה-בשרת — `validateSafe` רץ **שוב** ב-`publishConfig` (C10 · R1 §36-37)
**מה משתנה:** `validateSafe` ב-`edit_safety.dart` הוא **advisory-בלבד ועקיף** בצד ה-client. כל חמשת הבדיקות — **role-floor · action-legality · critical-lock · contrast · batch-ceiling** — חייבות **לרוץ מחדש בשרת בתוך `publishConfig`** (טריטוריית P5/P1). client שעבר אינו ערובה; פרסום שלא עבר את האימות-בשרת **נדחה** (fail-closed). ה-diff שנשלח לפרסום מאומת-מחדש מול אותו רישום-קפוא (R1-2), לא מול מצב-client.
**§-מוחלף:** §7.7 ("Draft-only … client proposes, server/owner-gate sanctions") — מורחב: לא רק *write* עובר לשרת אלא **כל לוגיקת-ה-validateSafe**. §3.2 שורת-הפרסום (`Pillar1.draft.apply`) מקבלת שכבת-אימות-שרת לפני שידור. §12 ("preview vs applied vs published") — published = **אחרי אימות-שרת חוזר**, לא רק auth+טרנזקציה.
**שלב מושפע:** Phase 3 (NL co-editor) + תיאום P5/P1 ב-Phase 0 (חוזה `publishConfig`). gate חדש **#119 = P4 AI-grounded-config** (R1 §62; לא #118 — ראה R1-fix-gate למטה).

### R1-2 · תלות-רישום מפורשת + fail-closed (A1 · R1 §14-15)
**מה משתנה:** כל closed-set ש-P4 מקרקע מולו — `editableProps`/`allowedActions`/`allowedValues`/`kImmutable`/`kRoleFloor`/`ElementKind` — חייב להיות **מוצהר ב-`ElementDescriptor` של P1 ב-Phase-0**. כיום `ElementDescriptor` = `axes`/`critical`/`personas` בלבד → `validateSafe` יוצא **ירוק-ריק (vacuous)** ומאשר הכל. עד ש-P1 מרחיב את החוזה ומקפיא אותו (לפני step-30), **`validateSafe` כשהשדה חסר = fail-closed** (חוסם, לא מאשר). חוזה-הרישום **קפוא** לפני הקפאת-ה-seams.
**§-מוחלף:** §2 (חוזה-הרישום) — מסומן כעת כ-**תלות-Phase-0-חוסמת**, לא הנחה. §7.1 ("Closed-set grounding") — מובהר: grounding ריק = drop-all, לא pass-all. §12 שורת "Pillar 1 interface churn" — מוסיף את התנאי שהרישום-המורחב קפוא-לפני-בנייה.
**שלב מושפע:** Phase 0 (BLOCKING) — Deliverable: `ElementDescriptor` מורחב + frozen-interface-doc. בלי זה Phase 1 לא מתחיל.

### R1-3 · מודל-פרסונה יחיד — `roleProvider` (String?), לא `BsRole` (A2 · R1 §16-17)
**מה משתנה:** מקור-האמת-היחיד לפרסונה = **`roleProvider` (String?, null = קבלן)**, החי. `SetVisible` עובד מול `roleProvider`, **לא** מול `BsRole`. ה-enums (`BsRole`/`BoardRole`) הם **מיפוי-תצוגה דרך adapter** בלבד, לא מקור-אמת. הרצפה "הסתר מכל הפרסונות" (R1-5/role-floor) מוגדרת **מעל מפת-הפרסונה-האמיתית** של `roleProvider` (כולל קבלן=null), לא מעל ה-enum החלקי שמשמיט קבלן → אחרת עריכה פר-קבלן = "נשמר, כלום לא קורה".
**§-מוחלף:** §1.6 ("Visibility is keyed by `BsRole`") + §3.3 חתימת `SetVisible{role: BsRole?}` → **`SetVisible{roleProvider: String?, visible}`** (null=קבלן). §7.3 (role-floor) מחושב מעל מפת-`roleProvider`. דוגמת "תסתיר מהשליחים" = `שליח → roleProvider token` (closed-set מהרישום), לא enum.
**שלב מושפע:** Phase 1 (`config_op.dart` חתימת-op) + Phase 0 (adapter `roleProvider`↔enum מוסכם מול P1).

### R1-4 · draft-op-API — `applyOps`+undo של P1, לא apply משלנו (A3 · R1 §18-19)
**מה משתנה:** P4 כותב **אך ורק** דרך ה-API מבוסס-op של P1: **`applyOps(List<ConfigOp>)` + undo-stack של P1**. אנחנו **לא ממציאים** `apply` משלנו. `editDraft(id, CfgNode Fn)` הוא primitive-פנימי של P1 — לא נוגעים בו. ה-op-stack שלנו ל-UI הוא **מראה (mirror)** בלבד; מקור-האמת = ה-undo-stack של P1.
**§-מוחלף:** §3.2 שורת `Pillar1.draft.apply(applied)` → **`Pillar1.applyOps(applied)`**; שורת `[undo] → Pillar1.draft.revertLast()` → **undo דרך undo-stack של P1**. §1.8/§13 ("draft `apply/revertLast`") → **`applyOps`+undo-stack**.
**שלב מושפע:** Phase 0 (חוזה ה-API מוסכם+קפוא מול P1) + Phase 2/3 (קריאות-הכתיבה).

### R1-5 · nav מוגבל ל-~38 מסכי-no-arg; typed-arg out-of-v1 ומוצהר (B8 · R1 §30-31)
**מה משתנה:** `nav.screen` תקף **רק ל-~38 מסכי-no-arg**. 11 המסכים עם typed-args **אינם נתמכים ב-v1** — הם דורשים **arg-builders פר-מסך** שאינם קיימים, ולכן **out-of-v1 ומוצהרים מפורשות**. `matchScreenId` מקרקע מול ה-closed-set של מסכי-ה-no-arg בלבד; מסך-typed-arg = drop (degrade), לא ניחוש-arg.
**§-מוחלף:** §4 שורת `nav.screen` ("target screen picked from a closed screen-id set") + §4 הערה "`nav.screen` target is itself a closed set" — מצומצם ל-**38 no-arg בלבד**; נוספת הצהרת out-of-v1 ל-11 typed-arg + הפניה ל-arg-builders עתידיים.
**שלב מושפע:** Phase 1 (`action_catalog.dart` — רשימת מסכי-ה-no-arg). test #6 מאמת ש-typed-arg-screen → drop.

### R1-6 · legal-but-harmful — floor `criticalBusiness` + contrast **בתוך** `validateSafe` (C/AI#6 · R1 §35,37)
**מה משתנה:** מעבר ל-nav/auth-immutability (§7.2) קיים floor חדש **`criticalBusiness`**: פעולות **חוקיות-אך-מזיקות** נחסמות גם הן — **אי-אפשר להסתיר מחיר**, **אי-אפשר לשנות/להסתיר "אשר הזמנה"**, **אי-אפשר ליצור כשל-ניגודיות (contrast-fail)**. ה-**contrast-check רץ בתוך `validateSafe`** (לא רק לינט-CI): `SetProp(color)`/`SetText` שמוריד ניגודיות מתחת WCAG-AA על element קריטי → blocked עם נימוק-עברית. `criticalBusiness` הוא חלק מחמשת-הבדיקות שרצות-שוב-בשרת (R1-1).
**§-מוחלף:** §7.2 (nav/auth immutability) — מורחב ב-floor `criticalBusiness` נפרד. §7.4 (prop/value) — contrast-check נכנס פנימה ל-`validateSafe`, לא נשען על ה-gate של #61/#64. §10 שורת WCAG-AA — מועברת מ-"לינט" ל-runtime-validation.
**שלב מושפע:** Phase 1 (`edit_safety.dart` — בדיקת-ניגודיות + `kCriticalBusiness` מהרישום). test #3 מוסיף assertion ל-hide-price/approve-order/contrast.

### R1-7 · Stage-A closed-set scope + "מעורפל→שאל" + scope ב-preview (AI#5 · R1 §12 תמה-A)
**מה משתנה:** מסַווג-ה-scope (Stage A, §9.1) **חייב** להחזיר **closed-set token מהרישום** (לא string חופשי על אזור). utterance **מעורפל → "שאל הבהרה"** (לא ניחוש-scope). ה-scope-שזוהה **מוצג ב-preview** לאישור-היעד: *"מתוך: לשונית רכש"* / *"מתוך: כל הכפתורים"* — כדי שהבעלים יאשר שהמערכת כיוונה לאזור-הנכון לפני שמסתכלים על השינויים.
**§-מוחלף:** §9.1 (Two-stage grounding) — Stage A מוגדר כעת כ-closed-set-classifier עם ענף "ambiguous→clarify", לא חלוקת-טקסט-חופשי. §3.2 (runtime flow) — `summarizeDiff` כולל שורת-scope בראש ה-preview. §3.3 שורת ה-`scope` token — מקורקעת מפורשות ל-closed scope-set מהרישום.
**שלב מושפע:** Phase 3 (`edit_prompt.dart` Stage-A) + `diff_preview.dart` (שורת-scope). test #2 מאמת scope closed-set + ambiguous-path.

### R1-8 · batch session-budget מצטבר + guard ">K% מהרישום" (AI#8 · R1 §44 מעקות)
**מה משתנה:** `kStudioMaxBatch` (§7.6) הוא per-utterance בלבד — לא מספיק. נוסף **תקציב-מצטבר לכל draft/session** (`kStudioSessionBudget` — סך-ה-ops המצטבר על-פני utterances באותו draft) + **guard מבני**: אם ה-diff המצטבר **נוגע ב->K% מהרישום** (`kStudioMaxRegistryFraction`, למשל 25%) → blocked עם "השינוי נרחב מדי לסשן". זה מעקה-עלות (R1 §44) וגם foot-gun-guard מול "שכתב-הכל". התקרה-המצטברת נאכפת **גם בשרת ב-`publishConfig`** (R1-1).
**§-מוחלף:** §7.6 (Batch ceiling) — מורחב מ-per-op ל-**per-session + registry-fraction**. §9 (cost) — שורת "rewrite ALL" מקבלת תקרת-סשן, לא רק batched-call. §12 שורת "Broadcast rewrites whole app" — מוסיף את ה-session-budget.
**שלב מושפע:** Phase 1 (`edit_safety.dart` — counters מצטברים) + Phase 5 (תיאום P5 על התקרה-בשרת). test #3 מוסיף over-session-budget + over-fraction.

### R1-9 · `SetProp(color)` — subset-טוקנים פר-element-kind (AI#7 · R1 תמה-C)
**מה משתנה:** `SetProp(color)` **לא** מקבל כל `BsTokens`/כל פלטת-המותג — אלא **subset-טוקנים מוגבל פר-element-kind**. כפתור, badge, טקסט-קריטי וכו' — לכל אחד ה-subset-החוקי-שלו דרך `allowedValues(id,'color')` (שמקורקע ב-`editableProps` של הרישום, R1-2). "ירוק" על כפתור-רגיל ≠ token-חוקי על element קריטי אם ה-subset-שלו אוסר. מונע יצירת contrast-fail (R1-6) דרך טוקן-לגיטימי-אך-לא-מתאים.
**§-מוחלף:** §3.3 הערת `SetProp(color)`. §7.4 ("a closed palette") — מובהר: הפלטה **לא גלובלית** אלא **פר-element-kind**, חיתוך של `BsTokens`. §5 ("label/text props") — נשאר; הצבע מצומצם.
**שלב מושפע:** Phase 1 (`registry_view.dart` `allowedValues` פר-kind) + R1-2 (הרישום מצהיר את ה-subsets). test #1 מאמת color out-of-subset-for-kind → drop.

### R1-10 · זיהוי JSON קטוע (truncation) → "לא הצלחתי", לא preview-חלקי (AI#10 · R1 תמה-AI)
**מה משתנה:** `parseConfigEdit` חייב **לזהות תשובת-JSON קטועה** — `finish_reason` שאינו `stop`/`end_turn` (truncated by `maxTokens`), או `}` חסר / סוגריים לא-מאוזנים — ולהחזיר **"לא הצלחתי לבנות את השינוי, נסה שוב"** במקום לבנות **preview-חלקי** מ-ops חלקיים. תשובה-קטועה ≠ ops-תקפים-חלקית; היא נדחית כיחידה. זה מעבר ל-malformed-tolerance הקיים (שמטפל ב-non-JSON) — כאן הסכנה היא JSON-**תקף-תחבירית-אך-קטוע** שנפרס חלקית.
**§-מוחלף:** §3.2 (200-empty→honest retry) — מורחב לכלול truncated→honest-fail. §3.3/§7.1 — `parseConfigEdit` מוסיף truncation-guard לפני ולידציית-שדות. §10 test #1 שורת "Malformed / partial" — מובהר ש-**truncated-valid-JSON** הוא מקרה-בדיקה נפרד (לא רק non-JSON).
**שלב מושפע:** Phase 1 (`edit_intent.dart` truncation-detect; ה-gateway כבר מחזיר model/text — נצרף finish-signal דרך P5). test #1 מוסיף truncated-JSON → empty+fail.

### תיאום-gate (R1 §61-62)
**`#118` שמור ל-P1** (config-registry: `id ⊆ registry`). gate-ה-grounding של P4 = **`#119` = P4 AI-grounded-config** (P3 analytics-PII = #120). §10 ("New gate #118") ו-§11 Phase-3 ("gate #118 registered") — **מתוקנים ל-#119**. שלוש השורות נרשמות מראש ב-`GATE_REGISTRY.md` (P1 בבנייה).
