# Architecture Decision Records (ADRs)

Each ADR documents one significant architectural decision: what we
decided, why, what we rejected, and what it costs.

## When to write one

A new ADR is required when:
- A design rule (R1–R8) needs to be added, changed, or refined.
- A pattern is chosen that conflicts with the obvious alternative
  (e.g., dial-pattern instead of drawer-pattern).
- A persistent technical decision is made (e.g., Preact vs React).
- A known violation is accepted with rationale (instead of fixed).

An ADR is **not** needed for routine refactors, bug fixes, or small
implementation choices inside a component.

## Format

```
# ADR-NNN · Title

Status:     Accepted | Rejected | Superseded by ADR-NNN
Date:       YYYY-MM-DD
Owner:      who approved
Related:    R{N}, ADR-NNN, file paths

## Context
What problem are we solving? What's the situation?

## Decision
What we decided to do, in one or two sentences.

## Rationale
Why this is the right answer. Connect to project priorities.

## Alternatives considered
For each: what it was, why we rejected it.

## Consequences
- Positive: what we gain.
- Negative: what it costs.
- Compatibility: what this breaks or constrains.

## Verification
How the inspector / tests confirm the decision is followed.
```

## Numbering

`NNN` is zero-padded three digits, monotonically increasing. Never
re-use a number. If an ADR becomes obsolete, mark it `Superseded by
ADR-XXX` — keep the file.

## Citing ADRs in code

Any code that exists **because** of an ADR may cite it in a comment:

```ts
/* @adr ADR-001 (no-window rule) */
```

The Contract Auditor (future) will scan for these references and
verify cited ADRs exist.
