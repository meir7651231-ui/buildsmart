# ADR-001 — No-Window UI (R2)

**Status:** Accepted
**Date:** 2026-05-20 (Preact) → ported to Flutter 2026-05-28
**Related:** R2, `home_shell.dart`, `PROTOCOL.md §FRM-02`

## Context

הפרוטוטייפ (`/index.html`) פותח כל פיצ׳ר כחלון מלא (`position:fixed; inset:0`).
בניסיון הראשון לתרגם ל-Flutter — בנינו `SitesView` + `ProfileView` + persona dashboards
כ-Navigator.push routes ו-AppView enum. **3 ניסיונות, 3 רברטים.**

## Decision

**שום פיצ׳ר חדש לא ממלא את המסך.** הגוף הנגלה הוא הקטלוג/ה-tabs בלבד.
כל פיצ׳ר = dial-drill דרך FAB קיים.

## Rationale

1. **הניסיון הכשיל 3 פעמים** — לא כי הקוד היה שגוי, אלא כי ה-UX הפר את עקרון-הרציפות.
2. **Dial = reversible** — המשתמש תמיד יודע איפה הוא ויכול לחזור; full-screen = disorientation.
3. **Consistency** — 5 FABs = 5 נקודות-כניסה קבועות. כל full-screen שובר את המודל.

## Alternatives rejected

- `Navigator.push` לכל persona — **נדחה** (3 רברטים)
- `showModalBottomSheet` גדול — **נדחה** (מסך בפועל)
- `AppView` enum ב-shell state — **נדחה** (INSP-0018 revert)

## Consequences

- ✅ UX עקבי; המשתמש לא "אובד"
- ✅ כל פיצ׳ר נגיש מכל מקום (FAB תמיד נראה)
- ⚠️ תוכן עשיר (גאנט, תקציב) דורש יצירתיות ב-dial-drill

## Verification

`PROTOCOL.md` FRM-02, FRM-03, FRM-04 — CRITICAL.
כל commit נסרק: אסור `showDialog`/`Navigator.push`/`Scaffold` חדש.

## היתרים מאושרים (exceptions)

- `LipskeyProductSheet` — bottom sheet מוצר (אושר INSP-pre01)
- `InstallStudioScreen` — מסך install studio (אושר, R2 exception)
- `RegressionPanelScreen` — פאנל בדיקות מנהל (אושר)
