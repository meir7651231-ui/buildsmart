# INSP-0028 — BsDial Drill: Manager Sub-Sections

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Pure data addition — adds `MANAGER_SECTIONS` (4 entries) to the
`PERSONA_SECTIONS` map in `bs-dial.tsx`. Same dial-only architecture
as INSP-0025/0026/0027.

## Sections (verbatim — emoji + label in the same legacy button)
| emoji | title | legacy source |
|---|---|---|
| 📊 | לוח בקרה | `<button class="adm-tab on" data-at="m-products" ...>📊 לוח בקרה</button>` @ :4213 |
| 🚚 | הזמנות | `<button class="adm-tab" data-at="m-orders" ...>🚚 הזמנות</button>` @ :4214 |
| 👥 | לקוחות | `<button class="adm-tab" data-at="m-customers" ...>👥 לקוחות</button>` @ :4215 |
| 🛠️ | ניהול | `<button class="adm-tab" data-at="m-manage" ...>🛠️ ניהול</button>` @ :4216 |

Strictest verbatim match — both emoji and label come from the same
legacy button text.

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FAB positions untouched.
- **R2** PASS — no window; BsDial L2 same dial slot.
- **R3** PASS — dial pattern preserved.
- **R4** PASS — circle + label, two separate spans.
- **R6/R8** PASS — verbatim from index.html:4213-4216.
- **R7** PASS — smoke 21/21 unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0017..0027.

## BS dial drill — 4 of 5 personas
| Persona | Sections | Source | INSP |
|---|---|---|---|
| חנות ספק | 4 | :4260-4263 | 0025 |
| שליח | 4 | :11951 + :18033 + :7762 + :18039 | 0026 |
| עובד | 3 | :8099-8102 | 0027 |
| **מנהל המערכת** | **4** | **:4213-4216** | **0028** |
| קבלן | — | (no verbatim emoji in legacy bottom tabs) | deferred |

Contractor BS drill stays back-anchor-only for now — the legacy
bottom-tab span text doesn't include emoji prefixes (uses separate
SVG icons). Adding contractor sub-sections requires a different icon
source decision.
