# ADR-001 · No-Window UI

Status:     Accepted
Date:       2026-05-20
Owner:      Owner
Related:    R2, R3, R4, R5, ADR-002 (dial-pattern), `RULES.md`

## Context

The legacy prototype (`index.html`) opens drawers, modals, sheets and
overlays liberally — including for the role drawer, the regression
test results, the product detail, and several smaller pop-ups. Each
window blocks the rest of the screen, requires an explicit close
action, and steals focus.

Construction-site users — the target audience — work with dirty
hands, on small screens, often single-handed, often interrupted. Each
extra modal/drawer is a friction point that breaks the flow.

The owner stated the rule early in the project, multiple times:
> "אף אחד מהם לא פותח חלון. נקודה."

When Claude initially built features that opened windows
(`bs-panel.tsx` drawer, search submenus as `sheet`s), they had to be
rebuilt — that's the cost of not honoring this constraint up front.

## Decision

UI patterns must not open a full-window overlay. Specifically:

- No drawer that slides in from a side and fills the height.
- No bottom sheet or top sheet that pushes content underneath.
- No `role="dialog" aria-modal="true"` on tool menus.
- No backdrop that darkens the page beyond a light "active-mode" tint
  (≤45% opacity, ≤3px blur).

Two narrow exceptions are documented and bounded:
- `product-sheet` — focused product detail, a documented exception.
- Light backdrops on the menu speed-dial and search panel — only to
  signal "active mode", not to block flow.

When the legacy app opens a window, we translate it to the **dial**
pattern (see ADR-002).

## Rationale

1. **Speed**: dial items react to the next tap immediately. A window
   requires a close gesture first.
2. **Cognitive load**: nothing is hidden behind a modal. The current
   screen is always the answer to "where am I?"
3. **Single-hand operation**: dials live close to the FAB; users
   never reach for an X in the corner.
4. **Recovery**: every action is reversible by re-tapping the same
   button. No accidental-modal-trap.

## Alternatives considered

- **Port the legacy windows as-is.** Rejected: defeats the project
  goal of optimizing for stressed users.
- **Use windows but with auto-dismiss timers.** Rejected: punishes
  slow taps, infuriates users.
- **Hybrid: windows for "settings" only.** Rejected: ambiguous —
  who decides what counts as settings? Better to ban universally.

## Consequences

**Positive**
- Predictable interaction model: every primary button has a dial.
- Consistent visual grammar across personas.
- Lower implementation cost: one dial pattern reused across BS,
  search, menu, and any future control surface.

**Negative**
- Complex sub-menus (e.g., the legacy "smart product tree" with rich
  multi-section content) need a different presentation. We use the
  `product-sheet` exception for that one case and accept the cost.
- Designers who join later will instinctively reach for modals;
  this ADR + R2 + the Inspector enforce the rule.

**Compatibility**
- Existing components were rewritten once already (bs-panel →
  bs-dial). Cost is fixed.

## Verification

- Inspector stage `frame` item FRM-02 scans for `position: fixed;
  inset: 0;` patterns and flags new ones as CRITICAL.
- Inspector stage `finish` item FRM-06 checks backdrop opacity/blur.
- RULES.md R2 is the human-readable form of this ADR.
