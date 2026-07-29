# BuildSmart — הוראות לכל סשן

## ענף עבודה
`claude/architect-minimum-100-percent-ctk3w5` — כל עבודה על ענף זה.
אין push ל-main ללא אישור מפורש מהמשתמש.
(הענף הקודם `claude/whats-happening-LyY9G` מוזג ונמחק; אזכורים שלו בקבצי CI הם היסטוריה.)

## דרך העבודה — 100% זה המינימום
- כל commit עובר שער מלא בפקודה אחת: `bash scripts/verify-flutter.sh` (Flutter) או `bash scripts/verify-preact.sh` (Preact).
- הסטנדרט: **0 שגיאות analyze · 0 אזהרות analyze · כל הטסטים ירוקים · build עובר · smoke 21/21**.
- סביבה טרייה מתאתחלת לבד: `.claude/hooks/session-start.sh` ← `scripts/bootstrap-env.sh` (מוריד Flutter לפי `FLUTTER_VERSION` אם חסר, מתקין תלויות). אין להניח ש-Flutter "כבר קיים".
- גרסת Flutter מוצמדת בקובץ `FLUTTER_VERSION` (3.29.3, Dart 3.7.2). ⚠️ חלק מקבצי ה-CI עדיין מצמידים 3.29.0/3.44.0 — איחוד שלהם דורש החלטת משתמש (משפיע על deploy).

---

## ⚠️ שני פרויקטים מקבילים בריפו

| תיקייה | סטאק | סטטוס |
|---|---|---|
| `app_flutter/` | Flutter 3.29 + Dart 3.7 + Riverpod | **🟢 פעיל לפיתוח חדש.** feature parity ל-Preact הושלמה (~270 leaves verbatim). נטיב iOS+Android+Web — מטרה ל-launch בחנויות. |
| `app/` | Preact + TypeScript + Vite + PWA | 🟡 **חי בפרודקשן** ב-GitHub Pages. reference. תיקוני באגים בלבד עד שה-Flutter יוצב — אז cutover. |

**כללי עבודה:**
1. כל פיצ׳ר חדש = `app_flutter/` בלבד.
2. תיקון באג ב-`app/` מותר (זה ה-live).
3. אם הוספת string חדש ב-`app/` — להעתיק verbatim ל-`app_flutter/`.

**Flutter dev loop:**
```bash
bash scripts/bootstrap-env.sh          # מתקין Flutter אם חסר + תלויות (רץ אוטומטית ב-session start)
export PATH="/home/user/flutter/bin:$PATH"
bash scripts/verify-flutter.sh         # השער המלא: analyze (0/0) + test + build web
bash scripts/verify-flutter.sh --fast  # analyze + test בלי build (ללולאת פיתוח)
# baseline מאומת 2026-07-29: analyze 0 שגיאות/0 אזהרות · 986 טסטים ב-133 קבצים · main.dart.js ‎5.4MB
cd app_flutter && flutter run -d chrome   # dev
```

---

## אם הגעת לכאן למשימת BuildSmart (תפריט / הגדרות / dial)

קרא בסדר הזה לפני שאתה נוגע בקוד:
1. `app/knowledge/wip-menu-wiring.md` — מה בנוי
3. `app/knowledge/inspector/checklist.md` — Inspector protocol
4. הדוח האחרון: `app/knowledge/inspections/INSP-0044-*.md` (הארכיון INSP-0001→0044, ישן = immutable)

**כל commit צריך:** typecheck + build + Inspector subagent (לפני markdown) + smoke 21/21.

---

## ⚠️ אסור לקרוא בתור הנחיה לעבודה

- `app/knowledge/IMPLEMENTATION_PROTOCOL.md` — **DEPRECATED**. לקריאה היסטורית בלבד.

---

## אם הגעת לכאן למשימה אחרת (לא BuildSmart)

עבודת תפריט-וחיווט BuildSmart הושלמה ומוזגה (הארכיון: INSP-0001→0044). הקבצים הבאים עדיין רגישים:

**אל תיגע בקבצים האלה אלא אם התבקשת מפורשות:**
- `app/src/components/menu/`
- `app/src/components/bs/`
- `app/src/store/app-settings.ts`
- `app/src/store/bs-store.ts`
- `app/src/store/toast-store.ts`
- `app/knowledge/`
- `app/RULES.md`

לכל שאר המשימות (בגים, features אחרים, שאלות) — תחבור ישר לעבודה.

---

## Inspector chain — לפני כל commit של settings/menu/dial (Preact `app/` בלבד)

> ⚠️ זו זרימת ה-**Preact** (`app/`). לעבודת **Flutter** (`app_flutter/`, הפעיל לפיתוח):
> `flutter analyze` (0 errors) + `flutter test` (כולל `knowledge_protocol_test`) +
> עדכון `app_flutter/WIRING.md`. הידע ל-port: `app_flutter/knowledge/PARITY.md` +
> `app_flutter/knowledge/port/` (proto/ + preact/). ראה `app_flutter/knowledge/README.md`.

```bash
bash scripts/verify-preact.sh        # שער אחד: typecheck + build + הגשה על :8123 + smoke 21/21
# (ידני: cd app && npx tsc -b --noEmit && npm run build ואז
#  npx http-server app/dist -p 8123 -s &  ←  ה-smoke לא מרים שרת בעצמו!
#  node app/smoke-settings.mjs)
# spawn Explore subagent עם prompt פתוח (לא מצדיק)
# המתן ל-GO לפני שכותבים markdown
# כתוב דוח ל-app/knowledge/inspections/INSP-NNNN-*.md
```

---

## קבצי ליבה

| קובץ | תפקיד |
|------|--------|
| `app/src/store/app-settings.ts` | settings signal + persist + DOM effect |
| `app/src/store/bs-store.ts` | persona + BS dial drill state |
| `app/src/store/user-profile.ts` | user profile fields |
| `app/src/store/toast-store.ts` | toast system |
| `app/src/components/menu-speed-dial.tsx` | menu FAB dial — 4 tabs |
| `app/src/components/bs/bs-dial.tsx` | BS FAB dial — 5 personas × sub-trees |
| `app/src/components/menu/submenu-settings.tsx` | all submenu data + components |
| `app/src/styles/tokens.css` · `global.css` | dark theme + dial styling |

---

## מה עובד כרגע (Menu FAB · BS FAB · Settings tree — sealed)

**Menu FAB — 4 tabs, כולם dial:**
- 🏠 בית → 4 כלים (📐 / 📦 / 🤖 / 📋), כל אחד עם sub-tree
- 🏗️ הפרויקטים → 3 פרויקטים + 📊 מרכז פיננסים (10 leaves)
- 🛒 רכש → 🛒 הסל שלי + 📦 הזמנות → 6 שירותי שרשרת אספקה
- ⚙️ הגדרות → פרופיל tree (כרטיס/דרגות + 🎮 מועדון 7 leaves) + הגדרות מתקדמות (10 קטגוריות, ~70 leaves)

**Search FAB — 5 כלים, כולם dial:**
- 🎤 קולי · 📷 ברקוד · ⚙️ פילטרים · ↕️ מיון · ▦ קטלוג (11 קטגוריות verbatim)

**BS FAB — 5 personas, 4 מתוכן עם sub-trees:**
- 👷 קבלן — (deferred — אין emoji verbatim)
- 👔 מנהל המערכת — 4 sections (לוח בקרה 5 / הזמנות / לקוחות / ניהול 4)
- 🏪 חנות ספק — 4 (בית 3 / הזמנות / מלאי / פורטל 8)
- 🛵 שליח — 4 (הרכב 3 / pickup / active / פורטל 6)
- 🦺 עובד — 3 task groups

**6 מתוך 6 hubs של הלגאסי מוטמעים** (openAIHub · openSiteHub · openFinanceHub · openRewardsHub · openSecurityHub · openServiceHub).

**~200+ leaves verbatim עם emoji מלגאסי.** INSP-0009 → INSP-0040, כולם GO.
