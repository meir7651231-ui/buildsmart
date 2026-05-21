# לוח משימות — Deep Agent ↔ Fast Agent
<!-- מסמך חי. כל סוכן מעדכן את הסעיף שלו אחרי כל סשן. -->
<!-- אין למחוק שורות — רק להוסיף ✅ / ⏳ לפי מה שהושלם. -->

---

## ⚠️ קודם כל — קרא את R2

**אין חלון, נקודה.** כל פיצ׳ר חדש = dial. ראה `CLAUDE.md` בשורש +
`app/RULES.md` (R2).

הקובץ `app/knowledge/IMPLEMENTATION_PROTOCOL.md` הוא **DEPRECATED** —
הוא מנחה לבנות views מלאים, מה שאסור לפי R2. לא לפעול לפיו.

---

## 🔵 Deep Agent (Opus / Sonnet) — מה בוצע

### סשן 1 — Settings Menu (INSP-0009 → INSP-0014)
- ✅ INSP-0009: תצוגה end-to-end (theme · textSize · reduceMotion)
- ✅ INSP-0010: התראות · נגישות · אזור ושפה · משלוח · איפוס (22 עלים)
- ✅ INSP-0011: מידע / about — 4 toasts
- ✅ INSP-0012: אבטחה — 23 עלים
- ✅ INSP-0013: שירות ותמיכה — 15 עלים
- ✅ INSP-0014: R9 inline input — חשבון (4) + אמצעי תשלום (1)
- ✅ toast system + smoke-settings.mjs (21/21 PASS) + CLAUDE.md
- ✅ INSP-0015: רגרסיה אחרי R9 (R7 PASS)

### סשן 2 — Profile + Sites Restructure (INSP-0016 → INSP-0020)
- ❌ INSP-0016 → INSP-0017: ניסיון לבנות SitesView/ProfileView כ-`<main>` swap → **רברטו** (R2)
- ✅ INSP-0018: revert מסודר — Profile/Sites חוזרים ל-dial drill
- ✅ INSP-0019: עץ פרופיל 3 רמות (הגדרות-פרופיל / הגדרות מתקדמות)
- ✅ INSP-0020: עומק פרופיל — RANKS, achievements, isActive

### סשן 3 — BS Dial Persona Tree (INSP-0021 → INSP-0028)
- ❌ ניסיון Phase-0 dashboards כ-views → **רברטו** (R2)
- ✅ INSP-0021: BsDial labels verbatim ('מנהל המערכת', 'חנות ספק')
- ✅ INSP-0025: BsDial multi-level drill + Store sub-sections
- ✅ INSP-0026: Courier sub-sections (4 leaves)
- ✅ INSP-0027: Worker sub-sections (3 leaves)
- ✅ INSP-0028: Manager sub-sections (4 leaves)

### סשן 4 — Deepening (INSP-0029 → INSP-0040)
- ✅ INSP-0029: arbitrary-depth tree walk + Manager לוח בקרה (5)
- ✅ INSP-0030: Manager ניהול (4)
- ✅ INSP-0031: Store בית (3) + פורטל (8)
- ✅ INSP-0032: Courier vehicle (3) + portal (6)
- ✅ INSP-0033: Menu Catalog tab (11 קטגוריות)
- ✅ INSP-0034: Menu Cart tab (2 + 6 שירותי שרשרת)
- ✅ INSP-0035: Menu Home tab (4 כלי בית)
- ✅ INSP-0036: Home AI hub (9 כלים)
- ✅ INSP-0037: Home Site hub (10 כלים)
- ✅ INSP-0038: Profile מועדון BuildSmart (7 פריטים)
- ✅ INSP-0039: Projects Finance hub (10 כלים)
- ✅ INSP-0040: Home scan (4) + stock (2)

**סיכום:** ~200+ leaves verbatim, 6/6 hubs בלגאסי מוטמעים, אפס חלונות.

### ✅ הושלמו (היו ⏳ פעם, כבר לא)
- ✅ ~~Store Dashboard view~~ — **לא נבנה (R2)** → BS dial drill במקום
- ✅ ~~Courier Dashboard view~~ — **לא נבנה (R2)** → BS dial drill במקום
- ✅ ~~Worker Dashboard view~~ — **לא נבנה (R2)** → BS dial drill במקום
- ✅ ~~Smoke tests for above~~ — לא רלוונטי (אין dashboards)
- ✅ חשבון (4 שדות) + אמצעי תשלום (1) — INSP-0014

### ⏳ אופציות פתוחות לעתיד (לא דחוף)
- ⏳ סקציות BS dial שנדחו (אין emoji verbatim): Manager הזמנות/לקוחות,
  Store הזמנות/מלאי, Courier pickup/active, קבלן (כל ה-tab)
- ⏳ FAB חיפוש: לוודא שעובד
- ⏳ FAB עגלה (top): לוודא שעובד
- ⏳ TypeScript pre-existing errors (vite.config / worker — Vite מתעלם)

---

## 🟡 Fast Agent (Haiku / Sonnet-fast)

### ✅ TASK-001 — הושלמה
הסוכן המהיר ניסה לכתוב `smoke-settings.mjs` ונתקע. ה-Deep Agent כתב
גרסה משלו (aria-label selectors), 21/21 PASS. הסוכן המהיר דחף גרסה
מקבילה עם `button:has-text` — שתי הגרסאות פעלו.

### הוראות הפעלה (אם רוצים להריץ סמוק טסט מקומית):
```bash
cd /home/user/buildsmart/app && npm run build && cd /home/user/buildsmart
npx http-server app/dist -p 8123 -s &
sleep 2
node app/smoke-settings.mjs   # 21/21 PASS צפוי
```

### כללי הסוכן המהיר
- קרא `CLAUDE.md` בשורש לפני הכל. **R2 אבסולוטי — אין חלון.**
- אל תקרא את `IMPLEMENTATION_PROTOCOL.md` בתור הנחיה. הוא DEPRECATED.
- אל תיגע ב: `app/src/components/menu/` · `app/src/components/bs/` ·
  `app/src/store/app-settings.ts` · `app/src/store/bs-store.ts` ·
  `app/src/store/toast-store.ts` · `app/src/store/user-profile.ts` ·
  `app/knowledge/inspections/` · `app/RULES.md` · `CLAUDE.md`
- אם אתה לא בטוח משהו — עצור ושאל.
