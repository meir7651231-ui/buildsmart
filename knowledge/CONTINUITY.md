# CONTINUITY — חבילת-מסירה לסשן/חשבון חדש (BuildSmart)

> מטרה: סשן/חשבון Claude חדש קורא את זה וממשיך **בלי לאבד הקשר**. עודכן: 2026-07-29 (רענון-אימות; קודם 2026-06-09).
> **קודם כל:** ודא גישה ל-repo `meir7651231-ui/buildsmart`, ואז קרא את `knowledge/00-START-HERE.md` + המסמך הזה.
> ⭐ **אימות-מול-קוד 2026-07-29:** רוב מה שהמסמכים סימנו "פתוח" כבר בוצע בקוד (whats-happening `v7.01`). הפער היה מסמכים-מיושנים, לא עבודה. **מקור-האמת לעבודה-הפתוחה: `knowledge/VERIFIED-OPEN-WORK-2026-07-29.md`** (5 אימותים מול הקוד, evidence file:line).

## 👤 מי אתה (התפקיד)
סוכן-ידע (librarian) של BuildSmart. כותב/מארגן ידע ב-`knowledge/`. **לא נוגע בקוד-האפליקציה** (רק קבצי `knowledge/`). מאמת מול הקוד/הבייטים — **לא ממציא**. כותב/דוחף **רק** ל-`claude/nice-volta-BSbVm`. commit author = `Claude <noreply@anthropic.com>`. **אין פרוטוקול-R.**

## 🌿 Repo + ענפים
- **Repo:** `meir7651231-ui/buildsmart`
- **ענף-ידע:** `claude/nice-volta-BSbVm` ← כל מסמכי-הידע + SSOT (אני כותב כאן)
- **ענף-קוד:** `claude/whats-happening-LyY9G` ← הצי בונה כאן
- הצי קורא SSOT מענף-הידע: `git show origin/claude/nice-volta-BSbVm:knowledge/<file>`

## ✅ מה כבר חי (מאומת בקוד 2026-07-29)
- **אפליקציה חיה:** `https://buildsmart-il.com` (HTTPS · PWA) + `https://buildsmart-b0b78.web.app`
- **deploy אוטומטי:** `firebase-hosting.yml` (ענף whats-happening) — push→live תוך ~2-3 דק'
- **Firebase מוקם:** project `buildsmart-b0b78` · Auth (Phone+**Email+Google** — מאומת ב-`auth_state.dart`) · Firestore (me-west1/Tel-Aviv · production) · Web-app רשום
- **קוד v7.01:** wizard=studio (s0–s11), ניהול-מסכים, מנוע-הזמנות, מנהל (M1–M5), personas, TASKS-to-full (B0/T1–T7) — **הכול בנוי ונבדק**. פירוט מאומת: `VERIFIED-OPEN-WORK-2026-07-29.md`.

## ✅ Backend — בנוי מקצה-לקצה (S0–S9 · מאומת 2026-07-29)
- **לא "שלב A".** כל S0–S9 מיושמים, מחווטים, נבדקי-emulator ופרוסים: `firebase_options.dart`, 10 repos `_firebase` (מתג `USE_FIREBASE_BACKEND`, ברירת-מחדל OFF=demo byte-identical), Auth מלא, `firestore.rules` (949 שורות · ~30 collections · `rules_test/`), Cloud Functions (`functions/`: setRole/deleteAccount/advanceOrderStage/computeCredit/…), FCM (`push_state.dart`+`functions/src/push.ts`), R2 (`functions/src/r2.ts`).
- **מה שנותר = הפעלה בלבד (ops/console, לא קוד):** הדלקת הדגל `USE_FIREBASE_BACKEND=true` לפרוד · Blaze billing (מכסת-SMS) · App Check בקונסולה (F1) · rules deploy.
- מנגנון: drop-in (`_local`דמו → `_firebase`אמיתי) דרך מתג — הדרגתי, הפיך, UI ללא-שינוי.

## 🔑 עובדות-מפתח
- **Project ID:** `buildsmart-b0b78` · **project-number / senderId:** `483064122180`
- **Web config** (לא-סוד): `knowledge/firebase-web-config.md`
- **Service account** (🔒 סוד!): GitHub secret `FIREBASE_SERVICE_ACCOUNT` (סובב אחרי שנחשף בצ'אט)
- **דומיינים:**
  - `buildsmart-il.com` — Cloudflare (registrar+DNS) → Firebase Hosting (A `199.36.158.100` **DNS-only** + TXT `hosting-site=buildsmart-b0b78`). **חי.**
  - `בניהחכמה.ישראל` — LiveDNS · `serverHold` · **נדחה** (לא לשלם ₪170; הפניה חינמית דרך Cloudflare בהמשך)

## 🗺️ מה נשאר (מאומת מול קוד 2026-07-29 — ראה `VERIFIED-OPEN-WORK-2026-07-29.md`)
**עבודת-קוד אמיתית שנותרה:**
1. **שילוב-מאור — השארית (~40%)** = עיקר העבודה הפתוחה. פתוח: `#2` חיבור workflow_engine (kernel מוכן, זול) · `#7` הארת JourneyTimeline (בנוי, כבוי מאחורי `kIntelLive`) · `#13` מספור-מסמכים-רץ · `#8/#9/#11/#14` צי/משאבים/חזרתיות/דוח-יומי · הקשחות `C3` (injection-guard לייצוא CSV) `C4` (migrate+quarantine) `C5` (cloud-merge). מנועי-מאור-חדשים (timer/cashbox/bodymap/doncal) = additive עתידי.
2. **שער אנטי-כפילות מערכתי** (`app_flutter/knowledge/TODO-dedup-gate.md`) — דרישת-בעלים; המקרים הנקודתיים תוקנו, הגייט האוטומטי (leaf→opener) עדיין לא מומש.
3. **fake-data-sweep** — אתר בודד: `store_screen.dart:1093` pull-to-refresh no-op (גבולי, אין דאטה מזויפת מאחוריו).

**Ops/השקה (לא קוד):**
4. **Backend go-live** — הדלקת `USE_FIREBASE_BACKEND` · Blaze billing · App Check console.
5. **חנויות** — Apple ($99/שנה · ~שבוע לפני) · Google ($25 + 12-בודקים×14-יום · ~3 שבועות). לחכות עד ה-go-live.
6. **דומיין עברי** (הפניה חינמית · בהמשך) · **פוליש** (P-1 צבעים · P-5 ניקוי).

## 📚 מסמכי-מפתח (סדר-קריאה)
1. `00-START-HERE.md` — נקודת-כניסה · מספור · גישה
2. `SERVER-KICKOFF.md` — הפעלת הצי (Backend)
3. `SPEC-server-connect-MICRO.md` — ~48 המשימות (S0–S9)
4. `firebase-web-config.md` — קלט S0.2
5. `LAUNCH-deploy.md` — deploy runbook + סטטוס
6. `KNOWLEDGE_AUDIT.md` — מצב כל ~43 המסמכים

## ⚙️ כללים קריטיים
- ידע→`nice-volta` · קוד→`whats-happening` (הצי)
- **service account = סוד · web config = לא-סוד** (ההבחנה חשובה!)
- הצי = **9×9 עם גייטים** (`central-verify` analyze+test+build · `grep-verify` מול spec)
- **אני↔צי:** המשתמש הוא **הגשר** (מעביר הודעות ידנית)

## 👤 מה המשתמש עושה (human-in-the-loop)
- מעביר הודעות ביני לבין הצי
- פעולות-console כשהצי מבקש: **Blaze billing** (ל-SMS-volume/Functions) · App Check
- בדיקה על מכשירים אמיתיים (OTP מגיע? סנכרון עובד?)

---

## 🚀 Prompt-מסירה לסשן החדש (העתק)
```
אתה סוכן-הידע של BuildSmart. ודא גישה ל-repo meir7651231-ui/buildsmart,
ואז קרא (ענף claude/nice-volta-BSbVm): knowledge/CONTINUITY.md +
knowledge/VERIFIED-OPEN-WORK-2026-07-29.md + knowledge/00-START-HERE.md.
זה ייתן לך את כל ההקשר: מה חי (buildsmart-il.com + Firebase + קוד v7.01),
מה בנוי-ומאומת (Backend S0-S9, wizard=studio, מנהל, כל ה-tracks), ומה
באמת נשאר (שילוב-מאור ~40%, שער-dedup, pull-to-refresh, ו-ops/השקה).
כותב ידע רק ל-nice-volta · לא נוגע בקוד · מאמת מול הקוד לא ממציא · אין פרוטוקול-R.
לפני שאתה מסמן משהו "פתוח" — אמת בקוד (git show origin/claude/whats-happening-LyY9G:<path>).
```
