# Building Inspector — Invocation

## When to run
Before every commit Claude must run inspections covering every stage touched
by the diff. At minimum: **operations** before any commit.

| Stage | Trigger |
|---|---|
| **foundation** | Changes under `src/store/`, `src/data/`, `src/test/types.ts` |
| **frame** | Changes under `src/components/`, `src/views/`, `src/app.tsx` |
| **wiring** | New/changed handlers, effects, signal mutations |
| **finish** | Changes to `src/styles/`, class names, ARIA |
| **operations** | Always — last stage before commit |

## How to invoke
Spawn an Explore agent with the prompt at `prompt.md`, substituting `{STAGE}`
with one of the five stages.

## What the inspector returns
A markdown report ending in either:
- `VERDICT: GO` → commit allowed
- `VERDICT: NO-GO` → fix the CRITICAL/MAJOR findings, re-run

## What Claude does with the report
1. Save it to `app/knowledge/inspections/INSP-NNNN-{stage}-{YYYY-MM-DD}.md`
2. If GO → proceed to commit
3. If NO-GO → fix the findings and re-run
4. If the same finding ID appears in 2+ recent reports → the Inspector
   itself escalates it to CRITICAL "stuck loop" and Claude must STOP and
   ask the owner for direction. No more retries.

## Reading the archive
Inspections are sorted by NNNN (zero-padded sequence). Each report is
standalone and immutable. The history is the audit trail.
