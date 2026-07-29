# VERIFIED OPEN-WORK — אימות מול קוד (2026-07-29)

> **מקור-האמת לעבודה-הפתוחה של BuildSmart.** לא נכתב מהמסמכים — נכתב מ**אימות ישיר של הקוד** בענף `claude/whats-happening-LyY9G` (`v7.01`), ע"י 5 סוכני-אימות שקראו/grepped את `app_flutter/lib` ודיווחו evidence file:line.
> **הרקע:** המסמכים (CONTINUITY 06-09, session_plan, TASKS-to-full) סימנו הרבה כ"פתוח" — אך ברוב המקרים העבודה **בוצעה בקוד והמסמך פשוט לא עודכן**. מסמך זה מפריד "פתוח באמת" מ"מסמך-מיושן".
> **חוק לסוכן-הידע הבא:** לפני סימון פריט "פתוח" — אמת בקוד (`git show origin/claude/whats-happening-LyY9G:<path>`). אל תסמוך על המסמך לבדו.

---

## 1. תמונת-אמת — נטען-פתוח מול מאומת-בקוד

| תחום | נטען במסמכים | אמת בקוד (v7.01) | פסק-דין |
|---|---|---|---|
| Backend / שרת | "שלב A · flutterfire configure" (CONTINUITY 06-09) | כל S0–S9 בנוי+מחווט+נבדק-emulator+פרוס | ✅ סגור (מיושן ~7 שב') |
| wizard/studio + ניהול-מסכים | דירקטיבות פעילות | s0–s11 סגורים · owner-gated · בדיקות | ✅ סגור |
| TASKS-to-full (B0,T1–T7) | "מה שנשאר לבנות" | הכול בנוי (Finance/Site Hub, tasks, projects, personas, 6 repos) | ✅ סגור |
| fake-data-sweep | S1/S3/M2/H1 פתוחים | 23/24 אתרים תוקנו | ✅ כמעט-סגור |
| שילוב-מאור | "~60% בפנים" | ~60% מדויק; החלק בעל-הערך-הגבוה בוצע | 🟡 ~40% פתוח |

---

## 2. העבודה הפתוחה האמיתית (מאומת · לפי עדיפות)

### 🥇 שילוב-מאור — השארית (~40%) · עיקר העבודה
מקור: `DIRECTIVE-maor-full-integration.md` + `MAOR-REUSE-MAP.md`. מאומת מול הקוד:
- **`#2` חיבור `workflow_engine`** — ה-kernel בנוי (`logic/workflow_engine.dart`) אך מיובא **רק** ב-`test/workflow_engine_test.dart`, אפס צרכן ב-lib. **הזול והמשתלם ביותר.**
- **`#7` הארת JourneyTimeline** — בנוי אך כבוי: `JourneyTimeline` (`manager_dashboard_screen.dart:3003`) + `screens/intel/journey_labels.dart`, גדור מאחורי `kIntelLive`(const-false, tree-shaken) + `_resolveCustomerKey→null`. צריך: להאיר דגל + join-key חי.
- **`#13` מספור-מסמכים-רץ** — `invoice.dart:46`/`delivery_note.dart:41` משתמשים ב-`order.id`; אין `receiptSeq` פר-סדרה (יש מוני-seq אחרים).
- **`#4b` credit עם יומן** — יש תקרה/ניצול/הסבר-AI; חסר `cred.log` (דלתא+סיבה) ו-tiers אשראי.
- **`#8/#9/#11/#14`** — לוח-משאבים+חסימת-חג · מכסה-נגרעת · חזרתיות+דאבל-בוקינג · דוח-הרחבה-יומי (מנוי→שורות-יום). **אין בקוד.**
- **הקשחות:** `C3` injection-guard לייצוא CSV (יש לייבוא, חסר לייצוא) · `C4` `migrate()`+versioning+quarantine · `C5` cloud-merge (counter-max/list-sanitize בין-מכשירים).
- **מנועי-מאור-חדשים** (timer-חיוב / cashbox-POS / bodymap / doncal-heatmap) — **additive עתידי**, לא נספר ב-60%.

### 🥈 שער אנטי-כפילות מערכתי · דרישת-בעלים
מקור: `app_flutter/knowledge/TODO-dedup-gate.md` (בעל-המוצר 06-07: "חייב טיפול"). המקרים הנקודתיים תוקנו (`_PlanScan`/`_Alternatives` נמחקו, נעול ב-`ai_hub_dedup_test.dart`), **אך הגייט האוטומטי** (מיפוי leaf-id→opener מול אינדקס openers ב-hooks) **לא מומש** — `dedup_test`/`no_duplicate_specs_test` הם catalog-only. פתוח מהותית.

### 🥉 fake-data-sweep — אתר בודד
`store_screen.dart:1093-1094` — pull-to-refresh = `Future.delayed(800ms)` no-op. סומן "גבולי" בהנחיה; `storeOrdersProvider` כבר ריאקטיבי ⇒ אין דאטה מזויפת מאחוריו.

### Ops / השקה (לא עבודת-קוד)
- **Backend go-live:** הדלקת `USE_FIREBASE_BACKEND=true` לפרוד · Blaze billing (SMS) · App Check console (F1) · rules deploy.
- **חנויות:** Apple ($99/שנה) · Google ($25 + 12-בודקים×14-יום). אחרי go-live.
- **דומיין עברי** (הפניה חינמית) · **פוליש** P-1 צבעים / P-5 ניקוי.

---

## 3. מסמכים מיושנים לתיקון (חוב-תיעוד, לא-חוסם)
- `CONTINUITY.md` — תוקן ברענון הזה (Backend "שלב A"→בנוי).
- `TASKS-to-full.md` — T6 מוצג כלא-מסומן בעוד שהוא מיושם מלא (עודכן באנר).
- `app_flutter/knowledge/session_plan.md` (ענף-קוד) — fake-data-sweep מוצג פתוח בעוד 23/24 תוקנו. *(ענף-קוד — לא בסמכות סוכן-הידע; דיווח לצי.)*
- `app_flutter/knowledge/TODO-worktree-hooks.md` — 3.5/4 באגים תוקנו, מסומן OPEN. *(ענף-קוד.)*
- הערת `app_flutter/lib/data/huliot_smartlock_catalog.dart:50-56` — אומרת "not yet uploaded to R2" בעוד P10 סגור והדגלים `false`. *(ענף-קוד.)*

---

## 4. ראיות מלאות
5 דוחות-האימות המלאים (עם evidence file:line לכל פריט) נאספו בסשן-הידע של 2026-07-29:
Backend (S0–S9) · wizard/studio (s0–s11) · TASKS-to-full (B0–T7) · fake-data-sweep (24 אתרים) · שילוב-מאור (19 פריטים). המפתח לכל פריט הוא הנתיב ב-`app_flutter/lib` שצוין לעיל — לאימות-חוזר: `git show origin/claude/whats-happening-LyY9G:<path>`.
