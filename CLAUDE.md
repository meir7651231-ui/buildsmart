# BuildSmart — הוראות לכל סשן

## ענף עבודה
`claude/whats-happening-LyY9G` — כל עבודה על ענף זה.
אין push ל-main ללא אישור מפורש מהמשתמש.

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
4. R1–R9 חלים על שני הפרויקטים.

**Flutter dev loop:**
```bash
export PATH="/home/user/flutter/bin:$PATH"   # already extracted to /home/user/flutter
cd app_flutter
flutter pub get
flutter analyze              # clean
flutter test                 # 10/10 PASS
flutter build web --release  # 2.0 MB main.dart.js
flutter run -d chrome        # dev
```

---

## ⚠️ הכלל המוחלט — R2: אין חלון, נקודה.

**שום קומפוננטה לא ממלאת את `<main class="content">` עבור פיצ׳ר חדש.**
כל פעולה חדשה = **dial**, ולא משנה מה כתוב בלגאסי.

- ❌ אסור: views חדשים שמחליפים את ה-main
- ❌ אסור: `<section class="dashboard">` מלא מסך
- ❌ אסור: dashboards לפי persona (Store/Courier/Worker יישארו placeholder מינימלי)
- ✅ מותר: dial רב-רמתי דרך FAB (BS / menu / search)
- ✅ העיקרון: כשהאב-טיפוס פותח חלון מלא — אנחנו מתרגמים אותו ל-**dial**

**הפרת R2 שלוש פעמים גרמה ל-3 רברטים. אל תתחיל לקוד dashboard view לפני שאישרת מפורשות.**

---

## אם הגעת לכאן למשימת BuildSmart (תפריט / הגדרות / dial)

קרא בסדר הזה לפני שאתה נוגע בקוד:
1. `app/RULES.md` — R1–R9 (R2 אבסולוטי)
2. `app/knowledge/wip-menu-wiring.md` — מה בנוי
3. `app/knowledge/inspector/checklist.md` — Inspector protocol
4. הדוח האחרון: `app/knowledge/inspections/INSP-0040-*.md`

**כל commit צריך:** typecheck + build + Inspector subagent (לפני markdown) + smoke 21/21.

---

## ⚠️ אסור לקרוא בתור הנחיה לעבודה

- `app/knowledge/IMPLEMENTATION_PROTOCOL.md` — **DEPRECATED**. מנחה לבנות
  dashboards כ-views, וזה הפרת R2. לקריאה היסטורית בלבד.

---

## אם הגעת לכאן למשימה אחרת (לא BuildSmart)

עבודת תפריט-וחיווט BuildSmart **בעיצומה** על ענף `claude/whats-happening-LyY9G`.

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

## כללים קריטיים — תקציר R1–R9

| # | כלל | עיקרון |
|---|-----|--------|
| **R1** | 5 FABs בדיוק | BS · חיפוש · BS-mode · תפריט · BS — לא לשנות |
| **R2** | **אין חלון, נקודה** | persona views = placeholder. כל פיצ׳ר = dial |
| **R3** | הגדרות = dial בלבד | אסור drawer / sheet / modal |
| **R4** | כל שורת dial = circle + label | שני elements נפרדים תמיד |
| **R6** | טקסטים עבריים = verbatim | חייב לבוא מ-index.html, לא המצאה |
| **R7** | regression לא נשבר | `src/test/tests/tabs.tsx` חייב לעבור |
| **R8** | אין המצאה | אם אתה לא רואה את זה בלגאסי, אל תוסיף |
| **R9** | שדות טקסט = inline input | שורת הקלדה צמודה לעלה, לא prompt/sheet/modal |

---

## Inspector chain — לפני כל commit של settings/menu/dial

```bash
cd app && npx tsc -b --noEmit       # typecheck
cd app && npm run build              # build
node app/smoke-settings.mjs          # 21/21 PASS חובה
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
| `app/src/store/user-profile.ts` | user profile fields (R9) |
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
