# Session Plan

Owner: this session
Scope: עדכון הפרוטוקול לפי 25 לקחים מ-SIZE_FILTER_PROTOCOL
Style: fix → verify → log lesson per step

## Rules of Engagement
- Local only — אין commit/push עד אישור מפורש מהמשתמש.
- Phase Ship מושהית עד "תדחוף".
- Re-fetch origin לפני commit (parallel sessions).

## הצעד הנוכחי

**משימה:** הטמעת 25 לקחים מ-SIZE_FILTER_PROTOCOL.md לתוך הפרוטוקול
**סטטוס:** 🟦 בתהליך

## P-Table

| # | Problem | Where | Symptom |
|---|---------|-------|---------|
| P1 | אין lessons חוצי-sessions | knowledge/ | session הבא חוזר ללקחים ישנים |
| P2 | session_plan ללא Owner/Scope | template ישן | scope creep אפשרי |
| P3 | אין visual verification phase | hook ישן | UI bugs מתגלים בייצור |
| P4 | אין sub-protocol pattern | template | משימות שמתרחבות נכתבות מחדש |
| P5 | אין audit log עם sentinels | אין | clean runs לא מתועדים |

## S — Solution Shape

חוזה: **3 קבצים + 5 שערים חדשים:**
1. `knowledge/CARRY_FORWARD.md` — לקחים קבועים
2. `knowledge/SESSION_PLAN_TEMPLATE.md` — template חדש
3. שערים 106-110 ב-pre-commit
4. עדכון stuck_log עם 5 רשומות חדשות
5. רענון ANTIPATTERNs

## Phases

### Phase A — Recon ✅
- [1] קרא SIZE_FILTER_PROTOCOL.md ✅
- [2] חלץ 25 לקחים ✅
- [3] מיין ל-קטגוריות (Process/Testing/Debug/Arch/Cross-session) ✅

### Phase B — Build (חלקית — אין tests-first ל-docs)
- [4] צור CARRY_FORWARD.md ✅
- [5] צור SESSION_PLAN_TEMPLATE.md ✅
- [6] עדכן session_plan לפורמט החדש ✅

### Phase C — Gates
- [7] שער 106 — Owner+Scope ✅
- [8] שער 107 — visual log ל-UI changes ✅
- [9] שער 108 — CARRY_FORWARD קיים ✅
- [10] שער 109 — sub-protocol → CARRY_FORWARD ✅
- [11] שער 110 — audit log לא ריק ✅

### Phase D — Integration
- [12] סנכרון hooks ✅
- [13] commit מקומי ⬜
- [14] verify gates 100-110 ⬜

### Phase G — Ship (מושהית)
- [15-20] push רק לאחר אישור ⬜

## Audit Log

| Row | Area | Pool | Outcome |
|-----|------|------|---------|
| 1 | knowledge/ | 11 קבצים | added 2 new (CARRY_FORWARD + TEMPLATE) |
| 2 | .githooks/pre-commit | 105 שערים | extended → 110 |
| 3 | stuck_log.md | 13 entries | יתעדכן אחרי commit |

## Live Log

### LL-01 — step 4 — Carry-forward distinct from per-bug stuck_log
**Problem:** stuck_log.md מצטבר באגים — קשה לראות את הלקחים החשובים.
**Solution:** קובץ נפרד CARRY_FORWARD.md עם 3-8 משפטים מזוקקים בלבד.
**Lesson:** לקחים שאמורים לנדוד לsession הבא = משפט אחד. הפרטים נשארים ב-stuck_log.

### LL-02 — step 7 — Owner+Scope catches scope creep early
**Problem:** session_plan ישן ללא Scope → קל לסחוף לדברים נוספים.
**Solution:** שער 106 דורש שתי שורות בראש הקובץ.
**Lesson:** constraint שרשום בקובץ עצמו עובד הרבה יותר טוב מ-discipline פנימית.

## Closeout (after this session)

### What will change
- knowledge/CARRY_FORWARD.md — NEW
- knowledge/SESSION_PLAN_TEMPLATE.md — NEW
- knowledge/session_plan.md — בפורמט החדש
- .githooks/pre-commit — +5 gates (106-110)

### Problems closed
- ✅ P1 — CARRY_FORWARD נוצר
- ✅ P2 — Owner/Scope אכוף בשער 106
- ✅ P3 — visual log אזהרה בשער 107
- ✅ P4 — sub-protocol pattern בtemplate
- ✅ P5 — audit log gate 110

### Pending — gated on user approval
- push אחרי שsession-מקביל מסיים
