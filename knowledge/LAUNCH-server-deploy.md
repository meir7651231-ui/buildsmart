# LAUNCH-server-deploy — הפעלת ה-Backend (אחרי code-complete S0–S9)

> כל הקוד (S0–S9) בנוי ונדחף (`1677ef2`, ענף whats-happening). מה שנשאר = **רק הצד שלך (console + deploy)** — אפס קוד חדש. UI לא משתנה.
> מקרא: 📱 console (אתה) · 🤖 CI/הצי · 💻 CLI (חלופה).
> ⚠️ **סדר קריטי:** Functions דורשות Blaze → Blaze קודם. Rules עובדות גם על Spark.

## שלב 1 — 💳 Blaze (📱 אתה)
1. Firebase → ⚙️ → **Usage and billing** → **Modify plan** → **Blaze**.
2. הוסף כרטיס-אשראי + **קבע התראת-תקציב** (חשוב!).
3. למה: Cloud Functions (S8) + SMS מעבר ל-10/יום. עלות התחלתית כמעט-אפס.

## שלב 2 — 🔒 Deploy Security Rules
- `firestore.rules` כבר בקוד. **עד שלא פרוס → ה-DB ב-deny-all** (ולכן האתר ריק על web).
- אחרי deploy → ה-RBAC האמיתי פעיל (chat=participants · credit=manager/owner · orders=transition-לפי-תפקיד).
- ⚠️ **uid-migration:** ר' אזהרה ב-`rules_test/README` — seed-ids צריכים למפות ל-auth-uids אמיתיים.
- **איך:** 🤖 **מומלץ** — הצי מוסיף CI (`firebase deploy --only firestore:rules` עם `FIREBASE_SERVICE_ACCOUNT`). 💻 חלופה: CLI.

## שלב 3 — ⚙️ Deploy Functions (אחרי Blaze)
- `functions/src/`: `advanceOrderStage` · `computeCredit` · push-triggers · `auditLog` · R2-presign.
- **R2 secrets:** `firebase functions:secrets:set` ל-creds של R2 (defineSecret) — לעולם לא ב-client.
- **איך:** 🤖 CI (`firebase deploy --only functions`) **או** 💻 CLI.

## שלב 4 — 🛡️ App Check (📱 אתה)
- reCAPTCHA v3 key ל-web → enforce על Firestore + Functions (חוסם לקוחות-לא-אפליקציה).

## שלב 5 — 🌱 דאטה + 📱 אימות-מכשיר
- seed ראשוני (או שמשתמשים יוצרים).
- בדיקות: **OTP-חי** · **push** · **דו-מכשירי** chat/orders (S4.5: A→B תוך-שניות).

## שלב 6 — 🔀 לייב-אמיתי
- ה-switch (`Firebase.apps.isNotEmpty`) כבר מפנה ל-Firebase ב-web. אחרי 1–5 → אמת ש-`buildsmart-il.com` מציג **דאטה אמיתית** (לא ריק).
- 📌 עד אז — **שקול להשאיר את הלייב על דמו** (לגדר את ה-switch) כדי שלא יראה ריק.

---

## חלוקה
- 📱 **אתה:** Blaze · App Check · R2-secrets · אימות-מכשיר.
- 🤖 **הצי/CI:** deploy rules + functions (workflow), uid-migration, חיווט-checkout→offline-queue.
- ה-creds (כרטיס, R2) — **בחשבון/secrets שלך**, לא דרכי.

## מקורות (בקוד)
`functions/README` · `rules_test/README` · `app_flutter/knowledge/offline-sync.md` · `WIRING`.
