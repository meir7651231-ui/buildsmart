# INSP-0041 — Worker Task Statuses (5 verbatim leaves × 3 task groups)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
All 3 Worker task-group sections now drill into the 5 task statuses
from `taskStatusInfo` @ index.html:8048-8054. Same set reused for
each group (current / queue / submitted).

## 5 Sub-leaves (verbatim per `taskStatusInfo`)
| emoji | title |
|---|---|
| ⏳ | ממתינה |
| 🔨 | בביצוע |
| 📸 | ממתין לאישור |
| ✅ | אושר ✓ |
| ↩️ | נדחה — לתקן |

## Side fixes (TS build was breaking after node_modules wipe)
- `tsconfig.json` — added `"ignoreDeprecations": "5.0"` (TS 5.7 strict
  on baseUrl); changed `include` to `["src"]` (vite/capacitor configs
  excluded — Vite processes them via its own pipeline).
- `vite.config.ts` — typed `{ request: Request }` on 3 workbox
  urlPattern callbacks (strict mode no-implicit-any).

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- R1 PASS · R2 PASS · R3 PASS · R4 PASS · R6/R8 PASS · R7 PASS.

## Stuck-loop Scan
No recurring finding IDs from INSP-0030..0040.

## "השלד שמות" — closed
All persona BS dial drills now have at least one deepening level with
verbatim content. Remaining sections that legitimately have no clean
verbatim emoji source stay as leaves (toast-on-tap) and are documented
in earlier INSP reports.
