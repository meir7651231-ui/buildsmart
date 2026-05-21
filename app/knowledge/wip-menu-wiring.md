# Menu Wiring — Work in Progress
Last updated: 2026-05-21 (after INSP-0010)
Branch: `claude/whats-happening-LyY9G`

This document is the single source of truth for the menu-wiring effort.
Read this BEFORE touching any settings/menu code, even if you have
conversation context — it captures the architecture, the legacy
references, the wired/unwired status, and the patterns to follow.

---

## Status snapshot

**22 / ~84 settings leaves wired** to real actions. The rest still
fall through to `closeMenu()` (legacy behaviour) until each branch
gets its own UI affordance.

### Wired (22)
| Branch | Count | Notes |
|---|---|---|
| display | 6 | theme · textSize · reduceMotion (+ apply CSS) |
| notifications | 4 | all toggles |
| accessibility | 1 | highContrast (toggle) |
| region | 7 | lang · units · currency (3 selects) |
| delivery | 4 of 5 | defaultHaul · express — payment-method NOT yet |
| reset | 1 | restores DEFAULTS, closes the menu |

### Unwired (~62)
| Branch | Count | Why not yet |
|---|---|---|
| account | 4 | each leaf needs a prompt/edit sheet |
| delivery.אמצעי תשלום | 1 | same — needs a prompt |
| about | 4 | 3 toasts + 1 static version label — needs a toast component |
| security hub | 10 + 17 sub | each hub item opens its own screen |
| support hub | 8 + 9 sub | same — each opens its own screen |

---

## Architecture

### Store — `app/src/store/app-settings.ts`
- `appSettings: Signal<AppSettings>` — single nested object with
  `display`, `notif`, `region`, `delivery`, `accessibility`.
- Persists to `localStorage` under `bs.settings.v1`.
- A single top-level `effect()` mirrors signal → `<html>` data-* attrs:
  `data-theme`, `data-text-size`, `data-reduce-motion`, `data-lang`,
  `data-units`, `data-currency`, `data-haul`, `data-express`,
  `data-contrast`. Effect is one-way (signal → DOM + localStorage);
  never writes back to the signal.
- All setters use shallow cloning: `appSettings.value = { ...s, ... }`.
- `resetSettings()` assigns `appSettings.value = DEFAULTS`.
- `load()` validates each field against an enum allowlist (`pick()`
  helper) so a corrupt localStorage payload falls back to defaults.

### Bindings — `app/src/components/menu/submenu-settings.tsx`
- `LEAF_BINDINGS: Record<string, { action, isActive? }>` — path-keyed
  map. Key format: `'group>label>label'` (drill path joined with `>`).
- The renderer (`SettingsTreeSubmenu`) takes `pathPrefix: string[]`,
  computes `leafKey(group, pathPrefix, node.label)` per row, looks up
  the binding, and:
  - if found → `onClick` runs `action()`; if `isActive()` is true the
    row gets `dial__item--leaf-on` + `dial__circle--on` (brand-tinted
    circle, label pill stays white).
  - if not → `onClick` falls back to `closeMenu()` (legacy).
- Branches (non-leaf) still call `pushSettingsPath()`.
- Bound leaves intentionally **stay open** after the action so the
  user can see the effect and pick a different value.

### Renderer — `app/src/components/menu-speed-dial.tsx`
- Passes `pathPrefix={path}` down to `SettingsTreeSubmenu`.

### CSS
- `tokens.css` — `[data-theme='dark']` palette (pre-existing),
  `[data-text-size='small'|'large'] body { zoom }`,
  `[data-reduce-motion='true'] * { animation/transition ~ 0ms }`.
- `global.css` — `.dial__circle--on { background: var(--brand); }`.

---

## Pattern: adding a new leaf binding (select or toggle)

1. **Extend the schema** in `app-settings.ts`:
   - Add the field to `AppSettings` type.
   - Add the default to `DEFAULTS` — match the legacy
     `resetSettings()` at `index.html:6962-6968`.
   - Add allowlist validation in `load()`.
2. **Write a setter** (shallow clone, no mutation).
3. **Mirror to DOM** (optional) — if the setting affects CSS, add a
   `root.setAttribute('data-...', ...)` line inside `effect()`.
4. **Add to `LEAF_BINDINGS`** — key must be the verbatim Hebrew label
   from the legacy. Run a final grep against `index.html` to confirm.
5. **Add CSS** (only if the new data-attr drives styling).
6. Build + Inspector + commit.

## Pattern: hub items (security / support) — NOT YET STARTED

These differ from selects/toggles. Each hub item in the legacy
opens its own screen with content + back button (e.g. בקרת הרשאות,
מחשבון כמויות). The protocol-compliant path is:

- A new component (e.g. `<SecurityHubSheet />`) overlaid on the dial.
- R3 says we **don't** create a drawer/sheet/modal. So this needs
  protocol clarification before we build it — OR we render the hub
  content as a temporary dial-level (the dial itself shows the
  content). Discuss with the user before implementing.

---

## Inspector chain — required before every commit

1. Read `RULES.md` (R1–R8) and `knowledge/inspector/checklist.md`.
2. Run typecheck: `cd app && npx tsc -b --noEmit`.
3. Run build: `cd app && npm run build`.
4. (Optional) Behavioural verify via playwright — chromium at
   `/opt/pw-browsers/chromium-1194/chrome-linux/chrome`. Static
   server: `npx http-server dist -p 8123 -s` (then
   `curl http://localhost:8123/`).
5. Spawn an Explore subagent with the Inspector prompt (see existing
   INSP reports for the format).
6. Write the report to `knowledge/inspections/INSP-NNNN-*.md`.
7. Decide GO / NO-GO based on counts.

Reports so far: INSP-0001 through INSP-0010, all GO or self-closing.
No stuck loops detected (same finding-id across 2+ reports).

---

## Rules to never break

- **R1**: 5 FABs (BS, search, BS-mode, menu, BS) — no add/remove/reorder.
- **R3**: Settings is a 4-level dial — no drawer/sheet/modal/page.
- **R4**: Each row = circle (icon span) + pill (label span), separate.
- **R5**: Tap behaviour — leaf with binding runs action and stays open;
  leaf without binding closes; branch drills; active anchor pops;
  backdrop closes all.
- **R6/R8**: Every label must be verbatim from `index.html`. If you
  don't see it in the legacy, **don't add it**.
- **R7**: `testTabs` in `src/test/tests/tabs.tsx` must keep passing.

---

## Open MINORs (informational only)

- INSP-0010 `accessibility-not-in-legacy-app-settings-object` —
  `accessibility.highContrast` is now persisted via localStorage,
  while the legacy used the DOM attribute only. Permitted adaptation
  (we're improving on a legacy gap). No fix needed.

---

## Suggested next steps (pick one)

1. **about (4 leaves)** — easiest. Build a tiny `<Toast />` component
   (≤30 lines), wire 3 leaves to show their text + auto-dismiss, plus
   1 static "גרסה" leaf. Stays open / closes per legacy intent.
2. **account (4 leaves)** + **delivery.payment (1 leaf)** — needs an
   inline prompt component (browser `prompt()` would be simplest but
   ugly; a styled input overlay would be R3-edge-of-compliant). Ask
   the user for direction before building.
3. **security hub (10 + 17 sub)** — biggest. R3 makes this a design
   conversation. The legacy renders each hub item as a screen with
   back button. Translating that into the dial paradigm needs the
   user's input.
4. **support hub (8 + 9 sub)** — same shape as security; one of these
   (`מחשבון כמויות`) is interactive and would need real logic.
