# CONTINUITY — חבילת-מסירה לסשן/חשבון חדש (BuildSmart)

> מטרה: סשן/חשבון Claude חדש קורא את זה וממשיך **בלי לאבד הקשר**. עודכן: 2026-06-09.
> **קודם כל:** ודא גישה ל-repo `meir7651231-ui/buildsmart`, ואז קרא את `knowledge/00-START-HERE.md` + המסמך הזה.

## 👤 מי אתה (התפקיד)
סוכן-ידע (librarian) של BuildSmart. כותב/מארגן ידע ב-`knowledge/`. **לא נוגע בקוד-האפליקציה** (רק קבצי `knowledge/`). מאמת מול הקוד/הבייטים — **לא ממציא**. כותב/דוחף **רק** ל-`claude/nice-volta-BSbVm`. commit author = `Claude <noreply@anthropic.com>`. **אין פרוטוקול-R.**

## 🌿 Repo + ענפים
- **Repo:** `meir7651231-ui/buildsmart`
- **ענף-ידע:** `claude/nice-volta-BSbVm` ← כל מסמכי-הידע + SSOT (אני כותב כאן)
- **ענף-קוד:** `claude/whats-happening-LyY9G` ← הצי בונה כאן
- הצי קורא SSOT מענף-הידע: `git show origin/claude/nice-volta-BSbVm:knowledge/<file>`

## ✅ מה כבר חי (הושג — 06-09)
- **אפליקציה חיה:** `https://buildsmart-il.com` (HTTPS · PWA) + `https://buildsmart-b0b78.web.app`
- **deploy אוטומטי:** `firebase-hosting.yml` (ענף whats-happening · commit `db920f2`) — push→live תוך ~2-3 דק'
- **Firebase מוקם:** project `buildsmart-b0b78` · Auth (Phone+Email) · Firestore (me-west1/Tel-Aviv · production) · Web-app רשום

## 🔥 בתהליך — Backend (השרת)
- הצי (**9×9 · LAW #0**) בונה את חיבור-השרת לפי `knowledge/SERVER-KICKOFF.md`.
- **נמצא ב-שלב A** (S0.2 `flutterfire configure` — משתמש ב-`knowledge/firebase-web-config.md`).
- מסלול: **A** (SDK) → **B** (auth) + **C** (6 repos מקבילי) + **E** → **D** (Security Rules) **לפני launch**.
- מנגנון: drop-in (`_local`דמו → `_firebase`אמיתי) דרך מתג — הדרגתי, הפיך, UI ללא-שינוי.

## 🔑 עובדות-מפתח
- **Project ID:** `buildsmart-b0b78` · **project-number / senderId:** `483064122180`
- **Web config** (לא-סוד): `knowledge/firebase-web-config.md`
- **Service account** (🔒 סוד!): GitHub secret `FIREBASE_SERVICE_ACCOUNT` (סובב אחרי שנחשף בצ'אט)
- **דומיינים:**
  - `buildsmart-il.com` — Cloudflare (registrar+DNS) → Firebase Hosting (A `199.36.158.100` **DNS-only** + TXT `hosting-site=buildsmart-b0b78`). **חי.**
  - `בניהחכמה.ישראל` — LiveDNS · `serverHold` · **נדחה** (לא לשלם ₪170; הפניה חינמית דרך Cloudflare בהמשך)

## 🗺️ מה נשאר
1. **Backend** (בתהליך · ~2-3 שבועות)
2. **חנויות** — Apple ($99/שנה · ~שבוע לפני) · Google ($25 + 12-בודקים×14-יום · ~3 שבועות לפני). **לחכות עד שהשרת מוכן.**
3. **דומיין עברי** (הפניה חינמית · בהמשך)
4. **פוליש** (P-1 צבעים · P-5 ניקוי)

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
ואז קרא: knowledge/CONTINUITY.md + knowledge/00-START-HERE.md (ענף claude/nice-volta-BSbVm).
זה ייתן לך את כל ההקשר: מה חי (buildsmart-il.com + Firebase), מה בתהליך
(הצי בונה Backend לפי SERVER-KICKOFF, שלב A), ומה נשאר.
כותב ידע רק ל-nice-volta · לא נוגע בקוד · לא ממציא · אין פרוטוקול-R.
המשך מאיפה שעצרנו.
```
