# Loop Detection — patterns to grep + assess

The Inspector treats infinite-loop patterns as **CRITICAL**. They turn an
app into either a render storm or a frozen tab. Every wiring inspection
must scan for these patterns; operations inspection must also check the
**process-loop** condition (same finding ID across recent reports).

---

## Code loops

### L-01 · `useEffect` with state setter and empty deps that triggers re-mount
**Severity**: MAJOR (usually intentional, but flag for verification)
**Pattern** (grep):
```
useEffect\(\s*\(\)\s*=>\s*\{[^}]*\bset[A-Z][a-zA-Z]*\(
```
Then check: is the dep array `[]`? If yes — typically OK on mount.
If deps array is missing entirely → the effect runs on every render →
finding.

### L-02 · `useEffect` setter for a value listed in its own deps
**Severity**: CRITICAL
**Pattern**:
```
useEffect\(\s*\(\)\s*=>\s*\{[^}]*\bset([A-Z][a-zA-Z]*)\([^)]*\)[^}]*\}\s*,\s*\[[^\]]*\1
```
The state being set appears in the same effect's deps. Classic loop.

### L-03 · Signal mutation inside `effect()` that reads the same signal
**Severity**: CRITICAL
**Pattern**:
```
effect\(\s*\(\)\s*=>\s*\{[^}]*([a-zA-Z_]+)\.value\s*=[^=][^}]*\b\1\.value\b
```
The same `signalX.value = …` is written and read in the same effect.
The effect re-runs whenever `signalX` changes, and it changes
`signalX` — therefore it re-runs forever.

### L-04 · State setter called in component render body (not in effect/handler)
**Severity**: CRITICAL
**Pattern**:
```
^export function [A-Z][a-zA-Z]+\(\)[^{]*\{[^}]*\bset[A-Z][a-zA-Z]*\(
```
Then verify the setter is not wrapped in a callback or effect. If it
runs at every render it causes an infinite re-render loop.

### L-05 · Signal `.value =` at top level of component body
**Severity**: CRITICAL
**Pattern**:
```
^export function [A-Z][a-zA-Z]+\(\)[^{]*\{[^}]*([a-zA-Z_]+Signal|[a-zA-Z_]+)\.value\s*=
```
Same problem as L-04 but with signals.

### L-06 · Recursive setter chain
**Severity**: MAJOR
**Heuristic**: function A sets X, X listener (effect) calls B, B sets Y,
Y listener calls A. Not easy to grep — flag any non-trivial chain you
spot.

### L-07 · `while (true)` / `for(;;)` / unbounded recursion
**Severity**: CRITICAL
**Pattern**:
```
while\s*\(\s*(true|1)\s*\)
for\s*\(\s*;\s*;\s*\)
```
Plus recursive function calls without a base case.

### L-08 · Render-time fetch / async without abort signal
**Severity**: MAJOR
**Pattern**: `fetch(` or `axios(` at top level of a component without
being wrapped in a cancellable effect.

---

## Process loops (across inspection runs)

### P-01 · Stuck-loop detection
**Severity**: CRITICAL (escalation rule, see `prompt.md`)

When Claude runs the same fix → re-runs the inspector → gets the same
finding → fixes again → same finding → ... that's a stuck loop.

**How to detect**:
1. List `app/knowledge/inspections/` and pick the most recent **3**
   reports.
2. For each finding the current inspection is about to record, take its
   ID (stable kebab-case derived from the first line of the finding —
   e.g. `R2-overlay-cart-sheet`).
3. If this same ID appears in **2 or more** of the last 3 reports →
   this finding is a stuck loop.

**What the inspector does**:
- Promotes the finding to CRITICAL.
- Adds the label `stuck-loop` next to the ID.
- Adds the text: `המפקח חוזר על אותו ממצא — חייבת התערבות הבעלים, לא ניסיון נוסף`
- Returns `VERDICT: NO-GO (stuck loop)`.
- **Does not list other findings.** Stops at the stuck-loop discovery.

**What Claude does**:
- **Stops fixing immediately.** Does not attempt another retry.
- Reports the stuck loop to the owner in plain Hebrew, citing the
  inspection IDs that repeated.
- Awaits explicit owner direction: change the rule, escalate the fix,
  or accept the violation with an ADR.

### P-02 · Inspection frequency anomaly
**Severity**: MAJOR (not CRITICAL — informational)

If 5+ inspections happen within 10 minutes for the **same stage** —
Claude is thrashing. Flag for review even if every report individually
passes. This is a softer signal than P-01 but worth surfacing.

---

## What loop detection is NOT

- Linting style (`@typescript-eslint/no-loops` etc.) — that's a separate
  concern.
- Performance tuning of legitimately recursive algorithms.
- React re-renders that are intentional (e.g., responding to props).

The Inspector's job is to catch **unintentional infinite loops** that
break the app and **process tarpits** where Claude is going in circles.
