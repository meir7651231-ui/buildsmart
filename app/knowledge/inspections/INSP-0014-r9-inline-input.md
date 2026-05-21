# INSP-0014 — R9 Inline Input (Account + Payment)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅

## Scope
- New rule **R9** in `RULES.md` — text-input leaves open an inline input row adjacent to the leaf, no prompt/sheet/modal.
- New store `app/src/store/user-profile.ts` (5 fields: name · phone · business · trade · payment, persisted to `bs.profile.v1`).
- New signal `editingLeafKey` + helpers `startEditingLeaf` / `stopEditingLeaf` in `app-store.ts`. Cleared on every state transition.
- `LeafEditor` component in `submenu-settings.tsx` — same circle + `.dial__input` pill.
- CSS `.dial__input` matches `.dial__label` shape + brand border + autofocus.
- 5 LEAF_BINDINGS added: 4 in account, 1 in delivery.

## Findings
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 (was 1, fixed) |
| MINOR | 0 |

## Resolved
**MAJOR (fixed):** `spec-label-mismatch` on `phone`. Legacy uses two different labels: menu row `'טלפון'` (index.html:6819), toast `'מספר טלפון'` (index.html:6947). Now `profileBinding` accepts both `rowLabel` and `toastLabel`.

## Rule Checks
- **R3** PASS — input is inline in dial row, no overlay.
- **R4** PASS — `LeafEditor` keeps circle + pill, two elements.
- **R6/R8** PASS — all 5 row labels verbatim from legacy (lines 6818-6821, 6861); toast labels verbatim from cfg (lines 6946-6950).
- **R9** PASS — input autofocus, Enter/blur saves, Esc cancels (cancelled-ref guard), dial stays open.

## Code-loop Scan
- `user-profile.ts` effect: reads signal, writes localStorage. No feedback.
- `LeafEditor` onBlur guarded by `cancelled` flag — Esc no longer triggers save via unmount-blur.

## Playwright Verification
`node /tmp/verify-account.mjs` → **7/7 PASS** (open input, save Enter, toast, circle--on, Esc cancels, blur saves, payment).

## Stuck-loop Scan
No recurring finding IDs from INSP-0011/0012/0013.
