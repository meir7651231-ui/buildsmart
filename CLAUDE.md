# BuildSmart — הוראות לכל סשן

## ענף עבודה
`claude/whats-happening-LyY9G` — כל עבודה על ענף זה.
אין push ל-main ללא אישור מפורש מהמשתמש.

---

## אם הגעת לכאן למשימת BuildSmart (תפריט / הגדרות)

קרא בסדר הזה לפני שאתה נוגע בקוד:
1. `app/knowledge/wip-menu-wiring.md` — מה כבר בנוי ומה נותר (26/84 עלים)
2. `app/RULES.md` — R1–R8 (חובה)
3. `app/knowledge/inspector/checklist.md` — Inspector protocol
4. הדוח האחרון: `app/knowledge/inspections/INSP-0011-*.md`

**כל commit צריך:** typecheck + build + Inspector subagent + דוח INSP.

---

## אם הגעת לכאן למשימה אחרת (לא BuildSmart)

עבודת תפריט-וחיווט BuildSmart **בעיצומה** על ענף `claude/whats-happening-LyY9G`.

**אל תיגע בקבצים האלה אלא אם התבקשת מפורשות:**
- `app/src/components/menu/`
- `app/src/store/app-settings.ts`
- `app/src/store/toast-store.ts`
- `app/knowledge/`
- `app/RULES.md`

לכל שאר המשימות (בגים, features אחרים, שאלות) — תחבור ישר לעבודה.

---

## כללים קריטיים — תקציר R1–R8

| # | כלל | עיקרון |
|---|-----|--------|
| R1 | 5 FABs בדיוק | BS · חיפוש · BS-mode · תפריט · BS — קיים, לא לשנות |
| R3 | הגדרות = dial בלבד | אסור drawer / sheet / modal |
| R4 | כל שורת dial = circle + label | שני elements נפרדים תמיד |
| R6 | טקסטים עבריים = verbatim | חייב לבוא מ-index.html, לא המצאה |
| R8 | אין המצאה | אם אתה לא רואה את זה בלגאסי, אל תוסיף |
| R7 | regression לא נשבר | `src/test/tests/tabs.tsx` חייב לעבור |

---

## Inspector chain — לפני כל commit של settings/menu

```bash
cd app && npx tsc -b --noEmit      # typecheck
cd app && npm run build             # build
# אחר כך: spawn Explore subagent עם Inspector prompt
# כתוב דוח ל-app/knowledge/inspections/INSP-NNNN-*.md
# GO = תתקדם | NO-GO = תקן קודם
```

---

## קבצי ליבה שכדאי להכיר

| קובץ | תפקיד |
|------|--------|
| `app/src/store/app-settings.ts` | signal + persist + DOM effect |
| `app/src/components/menu/submenu-settings.tsx` | LEAF_BINDINGS (26 כניסות) |
| `app/src/components/menu-speed-dial.tsx` | renderer + pathPrefix |
| `app/src/store/toast-store.ts` | toast system |
| `app/src/styles/tokens.css` | CSS variables + dark theme |

---

## מה עובד כרגע (26/~84 עלים)

✅ תצוגה · התראות · נגישות · אזור ושפה · משלוח · מידע · איפוס

⏳ חשבון (4) · תשלום (1) · אבטחה (27) · שירות ותמיכה (17)
