# ADR-002 — The Dial Pattern (R3/R4)

**Status:** Accepted
**Date:** 2026-05-20 (Preact) → ported to Flutter 2026-05-28
**Related:** R3, R4, R5, ADR-001, `PROTOCOL.md §FRM-05/06`

## Context

לאחר ADR-001 אסר חלונות — נדרש מנגנון חלופי לגילוי כלים מ-FAB.

## Decision

**Dial** = עמודה אנכית של כפתורים קומפקטיים שצומחת מה-FAB, באותו צד.

כללים קונקרטיים:
1. Dial נפתח מ**אותו צד** כמו ה-FAB (BS — ימין-למעלה; search — ימין-למטה; menu — שמאל-למטה)
2. כל פריט = **שני widgets נפרדים**: עיגול ~48px (icon) + pill (label) עם gap ≥ 8px
3. פריט פעיל — גם עיגול **וגם** pill מודגשים בצבע brand
4. לחיצה על פריט עם sub-menu → האחרים מתכווים; הנבחר נשאר ב-slot 1; ה-sub-menu נפתח באותו סגנון
5. לחיצה חוזרת על הנבחר (או על ה-FAB) → חזרה ל-dial המלא

## Rationale

- **Gap בין עיגול לפיל** = הרקע נראה דרכו → חלק מה-look-and-feel
- **שני-elements-נפרדים** → single-chip ידחה כ"כבד מדי" (נדחה ב-Preact design review)
- **Same-side anchoring** = thumb-reachable (קריטי ל-mobile)

## Alternatives rejected

- Single chip (עיגול+label container אחד) — **נדחה** (מחביא רקע, ה look-and-feel נאבד)
- Side-drawer — **נדחה** (ADR-001)
- Bottom sheet — **נדחה** (ADR-001)
- Horizontal dial מעל FAB — **נדחה** (פחות thumb-reachable ב-RTL)

## Consequences

- ✅ עקבי עם R2; לא יוצר "מסך" חדש
- ✅ כל עלה נגיש ב-2–3 הקשות
- ⚠️ dial עמוק (3+ רמות) → navigation דורש breadcrumb/back anchor ברור

## Verification

`PROTOCOL.md` FRM-05 (שני widgets נפרדים), FRM-06 (gap ≥ 8px).
