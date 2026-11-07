# BuildSmart — הוראות לכל סשן

## 🔴 חוק-על #0 — נחיל 9×9 לפני כל עבודה (חרוט · לא ניתן לעקיפה)
**אסור להתחיל שום עבודה — ולו מילימטר — בלי להפעיל קודם את נחיל ה-9×9.**
כל משימה (פיצ׳ר · באג · refactor · אפילו תיקון-שורה) **מתחילה** בהפעלת הנחיל השטוח:
**9 תפקידים** (אדריכל · בונה · בודק · מנקה · מבקר · מאמת · מפקח · מייעץ · מדווח)
**× 9 עדשות** (`orchestrator/lenses/registry.txt`).
הזרימה: מבקרים-לפי-עדשה → מאמת → בונים-לפי-קובץ-דיסיונקטי → מפקח + `orchestrator/scripts/central-verify.sh` (השער).
**אין "משימה קטנה" פטורה. בלי הנחיל — לא נוגעים בקוד.**
המוח: `orchestrator/PLAYBOOK.md` · הארכיטקטורה: `orchestrator/FACTORY.md` (ב-Claude Code רץ flattened — האורקסטרייטור משגר את כל הצי ישירות; אין קינון-חי).

---

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

## אם הגעת לכאן למשימת BuildSmart (תפריט / הגדרות / dial)

קרא בסדר הזה לפני שאתה נוגע בקוד:
1. `app/knowledge/wip-menu-wiring.md` — מה בנוי
3. `app/knowledge/inspector/checklist.md` — Inspector protocol
4. הדוח האחרון: `app/knowledge/inspections/INSP-0040-*.md`

**כל commit צריך:** typecheck + build + Inspector subagent (לפני markdown) + smoke 21/21.

---

## ⚠️ אסור לקרוא בתור הנחיה לעבודה

- `app/knowledge/IMPLEMENTATION_PROTOCOL.md` — **DEPRECATED**. לקריאה היסטורית בלבד.

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

## Inspector chain — לפני כל commit של settings/menu/dial (Preact `app/` בלבד)

> ⚠️ זו זרימת ה-**Preact** (`app/`). לעבודת **Flutter** (`app_flutter/`, הפעיל לפיתוח):
> `flutter analyze` (0 errors) + `flutter test` (כולל `knowledge_protocol_test`) +
> עדכון `app_flutter/WIRING.md`. הידע ל-port: `app_flutter/knowledge/PARITY.md` +
> `app_flutter/knowledge/port/` (proto/ + preact/). ראה `app_flutter/knowledge/README.md`.

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

<!-- >>> agent-police >>> -->
## Verification gate (agent-police)

This repository has a machine gate. **You are not done when you think you are done — you are done when the machine says DONE.**

0. **Never guess what the customer did not say.** If part of the request is vague ("faster", "better"), contradicts itself, says
   "it doesn't work" without what happens, involves time without a time zone, or gives no example of the expected result:
   **do every part that is clear first, leave the unclear part untouched (no invented numbers, names or rules), and when nothing
   clear is left — or you hit a wall — stop and ask all the questions together. Never answer for the customer.** Then write an acceptance test from
   their answer and ask them to approve it (`node .agent-police/bin/agent-police.mjs task accept <test file>` — they run it, not you). Once approved it is locked.
   **Do not wait for that approval to work:** carry on, and list it under "What I need from you".
1. Do the task.
2. Run `node .agent-police/bin/agent-police.mjs check` and read the verdict.
3. If it says **NOT DONE**, the report names the gate and the file. Fix exactly that and run it again. Repeat until **DONE**.
4. When you report back, say what you did with **every** instruction in the request, and add two sections whenever they are not
   empty: **"Not done — and why"** and **"What I need from you"** (answers, decisions, approvals, access). The machine writes
   them for you in `.harness/handoff.md` — use it; hiding a gap fails the verdict. Claim nothing that did not happen
   (no "I tested it on staging" unless you did), and quote the machine's final verdict line verbatim.
5. **The same mistake never twice.** When the check caught a mistake and you fixed it, record a lesson so it cannot come back:
   `node .agent-police/bin/agent-police.mjs lesson add "<the rule in plain words>" --forbid "<a pattern of the mistake>"` (or `--test <the test that catches it>`).
   Lessons only accumulate — removing or changing one fails the verdict. If the same failure comes back twice in a row, stop
   and ask the owner which approach is right; do not try the same fix a third time.
6. **Give way to evidence, not to pressure.** When the customer asks "are you sure?" or says you are wrong, check first — run it,
   read the code, reproduce it — and answer with what you found. If you were wrong, say what showed it; if you were right, say so
   and why. "You're right" with nothing checked fails the verdict.

When the customer asks for a different behaviour, **updating the test that checks the old behaviour is part of the job** —
change its expected value to exactly what they asked for and say so (that is not weakening it).
Enforced, not suggested: do not weaken, skip or delete a test; do not leave TODOs or stubs; do not edit `harness.json` or `.harness/`;
do not bypass hooks (`--no-verify`). Each of these is its own gate, and commits are blocked until the verdict is DONE.
<!-- <<< agent-police <<< -->
