# INSP-0042 — Worker Statuses Refined (Per-Group Filter)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
INSP-0041 gave all 3 Worker task groups the SAME 5 task statuses.
That was logically incorrect — in legacy, each task group is filtered
to specific statuses. INSP-0042 narrows each group's children to
match.

## Legacy filtering (@index.html:8095-8098)
```
const current=mine.find(t=>t.status==='active'||t.status==='rejected');
const queue=mine.filter(t=>t.status==='pending');
const submitted=mine.filter(t=>t.status==='review'||t.status==='done');
```

## Mapped per-group
| Group | Statuses |
|---|---|
| 🔨 המשימה הנוכחית שלך | 🔨 בביצוע · ↩️ נדחה — לתקן |
| ⏳ הבאות בתור | ⏳ ממתינה |
| 📋 שהגשת | 📸 ממתין לאישור · ✅ אושר ✓ |

All 5 status emoji + title pairs come from `taskStatusInfo` @ :8048-8054 (verbatim).

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Stuck-loop Scan
No recurring finding IDs from INSP-0030..0041.
