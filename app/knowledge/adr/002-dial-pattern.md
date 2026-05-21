# ADR-002 · The Dial Pattern

Status:     Accepted
Date:       2026-05-20
Owner:      Owner
Related:    R3, R4, R5, ADR-001 (no-window), `RULES.md`

## Context

Once ADR-001 forbade full-window overlays, an alternative was needed
for revealing the tools/options attached to a primary button (BS,
search FAB, menu FAB, cart, ...). The legacy app used drawers and
modals — those are out.

The chosen alternative is the **dial**: a vertical column of compact
buttons that drops below (or rises above) the primary control, on the
same side of the screen.

## Decision

A dial is the canonical way to expand the tools of any primary
button. Concrete rules:

1. The dial opens on the **same side** as the parent button.
   - BS (top-right) → dial drops downward, anchored to the right wall.
   - Search FAB (bottom-right) → dial rises upward, anchored right.
   - Menu FAB (bottom-left) → dial rises upward, anchored left.
   - Cart (top-left) → dial drops downward, anchored left.

2. Each dial item is **two separate elements**:
   - A circle (icon, ~48px) with its own background and shadow.
   - A pill (text label) with its own background and shadow.
   - A visible gap (~10px) between them. They are not packaged in a
     single container.

3. The active item highlights both pieces in brand color (teal).
   Inactive items are white pills with a teal icon.

4. Tapping a dial item with a sub-menu collapses the other tools.
   The selected item stays in slot 1 (closest to the parent button).
   Its sub-menu opens above (for bottom-anchored dials) or below
   (for top-anchored dials), using the same two-element style.

5. Tapping the selected item again, or the parent button, returns to
   the full dial.

## Rationale

1. **Visual consistency** with no-window rule (ADR-001) — the dial is
   the canonical answer.
2. **Two separate elements** were chosen over "a single chip with icon
   + text" because the dial has to share visual space with the bathroom
   background; the gap between icon and pill lets the background show
   through, which is part of the look-and-feel.
3. **Same-side anchoring** keeps everything reachable by thumb from
   the same hand position. Right-side primary → right-side dial.

## Alternatives considered

- **Single-chip items** (icon + label in one rounded container).
  Rejected after the owner saw the prototype: visually too heavy, and
  hides the bathroom background.
- **Side-drawer with icons** (like the legacy hamburger).
  Rejected per ADR-001.
- **Bottom sheet with the same content.**
  Rejected per ADR-001.
- **Horizontal dial above the FAB.**
  Rejected: less reachable, hides products underneath.

## Consequences

**Positive**
- Same visual grammar across BS, search, menu (and any future
  control). Users learn once, apply everywhere.
- The dial's animations (`dial-in` keyframe) are reusable across all
  primary buttons.

**Negative**
- Sub-menus inside the dial must follow the same two-element pattern;
  more complex options (multi-line, with values) need creative use of
  the pill (e.g., wider labels with secondary text).
- Long labels constrain dial item width.

**Compatibility**
- `bs-dial.tsx`, `tools-dial.tsx` (search), `menu-speed-dial.tsx` all
  implement the pattern. New control surfaces (cart, persona-specific
  dials in the future) must follow it.

## Verification

- Inspector frame items FRM-03 (no list/drawer for tools), FRM-04
  (separate circle + label pill), FRM-05 (sub-menu in same style).
- RULES.md R3 / R4 / R5 are the human-readable form.
- Regression buttons test `toggleBs`, `toggleMenu`, `toggleSearch`
  exercise the dial open/close behavior.
