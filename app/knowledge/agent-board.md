# לוח משימות — Deep Agent ↔ Fast Agent
<!-- מסמך חי. כל סוכן מעדכן את הסעיף שלו אחרי כל סשן. -->
<!-- אין למחוק שורות — רק להוסיף ✅ / ⏳ לפי מה שהושלם. -->

---

## 🔵 Deep Agent (Opus / Sonnet) — מה בוצע

### סשן קודם — 2026-05-21 (Settings Menu)
- ✅ INSP-0009: תצוגה end-to-end (theme · textSize · reduceMotion)
- ✅ INSP-0010: התראות · נגישות · אזור ושפה · משלוח · איפוס (22 עלים)
- ✅ INSP-0011: מידע / about — 4 toasts (26 עלים)
- ✅ INSP-0012: אבטחה — 23 עלים
- ✅ INSP-0013: שירות ותמיכה — 15 עלים
- ✅ toast system + CLAUDE.md + agent-board.md + smoke tests

### סשן הנוכחי — 2026-05-21 (Dashboards Deep Dives + Protocol)
- ✅ **צלילות המלא — 6 חלקים:**
  - `UI_ARCHITECTURE.md` — Contractor Dashboard (master index)
  - `ROLE_DRAWER_SYSTEM.md` — 5 roles + entry system
  - `SYSTEM_MANAGER_DASHBOARD.md` — 4-tab manager interface
  - `STORE_DASHBOARD.md` — 4-tab supplier store (NEW)
  - `COURIER_DASHBOARD.md` — Single-pane delivery hub (NEW)
  - `WORKER_DASHBOARD.md` — Task management interface (NEW)
- ✅ **IMPLEMENTATION_PROTOCOL.md** — פרוטוקול טמעון מפורט לשלוש Views החדשות
  - Stage 1: Store Dashboard (4-tab, high complexity)
  - Stage 2: Courier Dashboard (1-pane, medium complexity)
  - Stage 3: Worker Dashboard (task list, medium complexity)
  - בדיקה מפורשת (FND/FRM/WIR/FIN/OPS)
  - Pre-commit checklist
  - Validation criteria

### ענפים שנותרו ל-Deep Agent או Fast Agent
- ⏳ **Implement Store Dashboard** (app/src/views/store.tsx + components)
- ⏳ **Implement Courier Dashboard** (app/src/views/courier.tsx + components)
- ⏳ **Implement Worker Dashboard** (app/src/views/worker.tsx + components)
- ⏳ **Create smoke tests** (app/smoke-store.mjs, app/smoke-courier.mjs, app/smoke-worker.mjs)
- ⏳ חשבון (4 שדות עריכה) — דורש R9 inline input
- ⏳ אמצעי תשלום (1) — דורש R9 inline input

---

## 🟡 Fast Agent (Haiku / Sonnet-fast) — משימה נוכחית

### ✅ TASK-001 — הושלמה ב-Deep Agent
הסוכן המהיר ניסה לכתוב `smoke-settings.mjs` אך נתקע.
ה-Deep Agent כתב והריץ 12/12 PASS בגרסת `aria-label` selectors.
הסוכן המהיר דחף גרסה עם `button:has-text` selectors — אפשרי להשאיר.

### הוראות הפעלה לסוכן המהיר (עדכני)
```bash
# שלב 1 — בנה dist/ (פעם אחת לכל container חדש)
cd /home/user/buildsmart/app && npm run build && cd /home/user/buildsmart

# שלב 2 — הפעל שרת
npx http-server app/dist -p 8123 -s &
sleep 2

# שלב 3 — הרץ smoke-test
node app/smoke-settings.mjs
```
**שגיאות TypeScript הן pre-existing — אל תריץ `tsc`, רק `npm run build`.**

### מה הסוכן המהיר ביצע
- ✅ כתב `app/smoke-settings.mjs` (גרסה עם `button:has-text` locators)
- ✅ הריץ builds + playwright בסביבתו

### כללי הסוכן המהיר
- קרא `CLAUDE.md` בשורש לפני הכל
- אל תיגע ב: `app/src/components/menu/` · `app/src/store/app-settings.ts` · `app/src/store/toast-store.ts` · `app/knowledge/`
- אחרי שגמרת — עדכן את סעיף "מה הסוכן המהיר ביצע" בקובץ הזה
- אם אתה לא בטוח משהו — עצור ושאל

---

## 📋 מצב כולל — עלי הגדרות

| ענף | עלים | סטטוס |
|-----|------|--------|
| תצוגה | 6 | ✅ מחובר |
| התראות | 4 | ✅ מחובר |
| נגישות | 1 | ✅ מחובר |
| אזור ושפה | 7 | ✅ מחובר |
| משלוח ותשלום | 4/5 | ✅ מחובר (חסר תשלום) |
| מידע | 4 | ✅ מחובר |
| איפוס | 1 | ✅ מחובר |
| אבטחה | 23/27 | ✅ מחובר (4 read-only) |
| שירות ותמיכה | 15/17 | ✅ מחובר (2 branches = drill בלבד) |
| חשבון | 4 | ⏳ Deep Agent — דורש input UI |
| תשלום | 1 | ⏳ Deep Agent — דורש input UI |
| **סה"כ** | **~65/84** | |
