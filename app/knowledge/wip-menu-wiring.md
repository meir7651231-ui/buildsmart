# Menu Wiring — Work in Progress
Last updated: 2026-05-21 (after INSP-0014)
Branch: `claude/whats-happening-LyY9G`

This document is the single source of truth for the menu-wiring effort.
Read this BEFORE touching any settings/menu code, even if you have
conversation context — it captures the architecture, the legacy
references, the wired/unwired status, and the patterns to follow.

---

## Status snapshot

**~70 settings leaves wired** to real actions. All interactive leaves
are now functional. Smoke suite: 21/21 PASS.

### Wired (~70)
| Branch | Count | Notes |
|---|---|---|
| display | 6 | theme · textSize · reduceMotion (+ apply CSS) |
| notifications | 4 | all toggles |
| accessibility | 1 | highContrast toggle |
| region | 7 | lang · units · currency selects |
| delivery | 5 | defaultHaul · express + payment (R9) |
| about | 4 | 4 toasts verbatim from legacy |
| reset | 1 | restores DEFAULTS |
| security | 23 | 2FA · biometric · location · sessionTimeout · privacy×4 · RBAC×5 · encryption×4 · info×3 |
| support | 15 | 6 L3 toasts + 3 calc + 6 tour toasts |
| account | 4 | R9 inline input — name · phone · business · trade |

### Unwired
None of the interactive leaves remain. The remaining tree nodes are
**branches** (drill-only, no action), not leaves:
- `מרכז האבטחה` · `נעילת הפעלה` · `הצפנת נתונים` · `בקרת פרטיות` · `הרשאות גישה`
- `מרכז השירות` · `מחשבון כמויות` · `סיור היכרות`

---

## Architecture

### Stores
- **`app/src/store/app-settings.ts`** — `appSettings` signal (display,
  notif, region, delivery, accessibility, security). Persists to
  `bs.settings.v1`. Effect mirrors → `<html>` data-* attrs.
- **`app/src/store/user-profile.ts`** — `userProfile` signal (name,
  phone, business, trade, payment). Persists to `bs.profile.v1`.
  No DOM mirroring; only localStorage.
- **`app/src/store/toast-store.ts`** — `toastMsg` signal +
  `showToast(msg, ms?)`. Auto-clears after 3200ms.
- **`app/src/store/app-store.ts`** — menu state + `editingLeafKey` for
  R9 inline edit (cleared on every navigation transition).

### Bindings — `app/src/components/menu/submenu-settings.tsx`
- `LEAF_BINDINGS: Record<string, Binding>` — path-keyed map. Key
  format: `'group>label>label'`.
- `Binding` shape:
  - `action: () => void` — runs on tap for non-input leaves.
  - `isActive?: () => boolean` — drives `dial__circle--on`.
  - `input?: { get, set, label }` — present for R9 text-input leaves.
    When set, tap opens `LeafEditor` inline instead of `action()`.
- `SettingsTreeSubmenu` renderer:
  - For input bindings + matching `editingLeafKey` → renders
    `<LeafEditor>` (circle + `<input class="dial__input">`).
  - Otherwise → renders the standard `<button>` row.
  - Bound leaves stay open after action; unbound leaves close.
- `LeafEditor` — Enter or blur saves + toast; Esc cancels.
  `cancelled` ref guards onBlur-on-unmount from saving after Esc.

### CSS
- `tokens.css` — dark theme palette, text-size zoom, reduce-motion overrides.
- `global.css` — `.dial__circle--on` (brand circle), `.dial__input` (brand
  border, matches `.dial__label` shape), `.toast` (centered, above FABs).

---

## Patterns

### Adding a select/toggle leaf
1. Extend `AppSettings` type + `DEFAULTS` + `load()` validator.
2. Write a setter in `app-settings.ts`.
3. (Optional) Add `root.setAttribute('data-...', ...)` in the effect.
4. Add to `LEAF_BINDINGS` with verbatim Hebrew key.
5. Build + Inspector + commit.

### Adding a text-input leaf (R9)
1. Extend `userProfile` (or write a new field-specific store).
2. Use `profileBinding(key, rowLabel, toastLabel)`. Two labels:
   - `rowLabel` matches the dial leaf row (legacy `setLink` arg).
   - `toastLabel` matches the legacy `editAccountField` cfg label.
3. The renderer + `LeafEditor` handle everything else automatically.
4. Toast text format: `'${toastLabel} עודכן'`.

### Adding info-only leaves
- For read-only screens in the legacy (audit log, device management,
  etc.), use `showToast('<verbatim or descriptive Hebrew text>')`.
- Keep toasts under ~50 Hebrew chars to avoid wrapping.

---

## Inspector chain — required before every commit

1. Read `RULES.md` (R1–R9) and `knowledge/inspector/checklist.md`.
2. `cd app && npx tsc -b --noEmit` (pre-existing errors in
   `vite.config.ts` / `worker.tsx` are tolerated — see open MINORs).
3. `cd app && npm run build`.
4. Behavioural verify: `npx http-server app/dist -p 8123 -s &` →
   `node app/smoke-settings.mjs` (21/21 expected).
5. Spawn Explore subagent with Inspector prompt.
6. Write report to `knowledge/inspections/INSP-NNNN-*.md`.
7. Decide GO / NO-GO based on counts.

Reports through **INSP-0014**, all GO.

---

## Rules to never break (R1–R9)

- **R1**: 5 FABs — no add/remove/reorder.
- **R3**: Settings = dial only — no drawer/sheet/modal.
- **R4**: Each row = circle + label, two elements.
- **R5**: Tap behaviour — bound leaves stay open; unbound leaves close;
  branches drill; active anchor pops; backdrop closes all.
- **R6/R8**: Every label must be verbatim from `index.html`.
- **R7**: `src/test/tests/tabs.tsx` must keep passing.
- **R9**: Text-input leaves use inline `<input>` adjacent to the leaf,
  same circle + same pill shape. No prompt/sheet/modal.

---

## Open MINORs (informational only)

- INSP-0010 `accessibility-not-in-legacy-app-settings-object` —
  permitted adaptation (legacy stored only in DOM; we persist to LS).
- Pre-existing TypeScript errors in `vite.config.ts` + `worker.tsx` —
  ~~Vite ignores; not blocking.~~ **Resolved as of 2026-05-21** —
  `tsc -b --noEmit --force` returns exit 0 cleanly. Earlier reports
  were likely stale `.tsbuildinfo` cache.

---

## Suggested next steps

The interactive wiring is complete. All cleanups closed:
- ✅ TS errors — `tsc -b --noEmit --force` exit 0.
- ✅ R7 regression — `runRegression()` 236/236 PASS including tabs 5/5.
- ✅ Smoke suite — 21 tests covering all wired branches.

What's left depends on next priorities outside menu wiring:
- New persona-specific views or features outside of `הגדרות`.
- Connecting the wired info-toasts to real screens when those screens
  become R3-compliant (e.g. audit log, device management).
- Quantity calculator (`מחשבון כמויות`) and other tools currently
  surface only as toasts.
