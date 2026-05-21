# BuildSmart Knowledge System

This directory is the **source of truth** for how the app is built.

## Layers
| Path | What's in it |
|---|---|
| `../RULES.md` | The 8 design rules (R1–R8) |
| `inspector/` | Building Inspector protocol (replaces the old audit) |
| `inspections/` | Inspection report archive (immutable) |
| `legacy-map.md` | Legacy → modern mapping by area |
| `adr/` | Architecture Decision Records |
| `spec.json` | Machine-readable feature spec with status |
| `reporting.md` | Hebrew summary report format — Claude must follow it |
| (future) `contracts/` | Per-component contracts |

## The Building Inspector

The Inspector replaces the previous PASS/FAIL audit. Key differences:

| Old audit | Inspector |
|---|---|
| Single pass | 5 stages (foundation/frame/wiring/finish/operations) |
| PASS/FAIL only | CRITICAL / MAJOR / MINOR severity |
| Lost in chat | Reports written to `inspections/INSP-NNNN-*.md` |
| Rules only | Rules + ADRs + spec + regression + **loop detection** |
| Advisory | Authority to block commits on CRITICAL |

See `inspector/README.md` for invocation and `inspector/prompt.md` for the master prompt.
