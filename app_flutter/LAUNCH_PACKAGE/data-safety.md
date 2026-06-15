# Google Play — Data Safety answers (BuildSmart)

> תשובות מוכנות-להקלדה לטופס **Data safety** ב-Play Console.
> **עדכון 2026-06-15 (B1):** הבילד הנשלח מאתחל Firebase ומפעיל **Crashlytics + Analytics**
> (collection פעיל ב-release — `lib/main.dart:185`, מגודר ב-`Firebase.apps.isNotEmpty`, לא
> בדגל-הדאטה `useFirebaseBackend`). לכן הטופס מצהיר ביושר על איסוף-טלמטריה. **תוכן-המשתמש**
> (הזמנות/פרופיל/סל) נשאר מקומי/דמו כברירת-מחדל — נכתב ל-Firestore רק כש-`USE_FIREBASE_BACKEND`
> מופעל (לא בבילד-החנות). אין חשבון/login/PII בבילד-ברירת-המחדל.
> מקור-אמת: `lib/telemetry.dart`, `lib/main.dart:71-194`, `lib/data/repositories/backend.dart`.

מקרא: ✅ = מאומת בקוד · ⬜ = דורש השלמה/אישור מהמשתמש לפני הגשה.

---

## חלק 1 — Data collection and security

| שאלה בטופס | תשובה | בסיס |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** ✅ | Firebase **Crashlytics** (דוחות-קריסה) + **Analytics** (אירועי-שימוש) נאספים ב-release ושולחים ל-Google מזהי-מכשיר + נתוני-ביצועים/שימוש. אין PII/חשבון; תוכן-המשתמש נשאר מקומי בבילד-ברירת-המחדל. |
| Is all of the user data collected by your app encrypted in transit? | **Yes** ✅ | כל תעבורת Firebase מעל TLS/HTTPS. |
| Do you provide a way for users to request that their data is deleted? | **Yes** ✅ | הסרת-האפליקציה מוחקת נתונים מקומיים; טלמטריית-Firebase פסבדונימית, נמחקת אוטומטית ב-retention וניתנת-למחיקה דרך מנגנוני Firebase/Google. ⬜ לציין כתובת-יצירת-קשר למחיקה ב-privacy-policy. |

## חלק 2 — Data types collected / shared

**Collected** (דרך Firebase; Google = processor · **לא נמכר**, לא משותף עם מפרסמים):

| Data type (קטגוריית Play) | פריט | מטרה | אופציונלי? |
|---|---|---|---|
| **App activity** | App interactions (Analytics: `screen_view`/session/אירועים אוטומטיים) | Analytics | חובה (אוטומטי) |
| **App info & performance** | Crash logs + Diagnostics (Crashlytics) | תפעול/דיווח-קריסות | חובה (אוטומטי) |
| **Device or other IDs** | Analytics app-instance ID · Crashlytics installation UUID · (FCM token — רק כאשר push פעיל, `useFirebaseBackend`) | Analytics/Crashlytics/הודעות | חובה (אוטומטי) |

**Shared:** מעובד ע"י **Google (Firebase)** כ-processor בלבד. **לא נמכר**, לא משותף לפרסום/data-brokers.

**NOT collected:**
- **Location** מדויק — לא (Analytics עשוי לגזור **אזור מקורב** מ-IP בלבד; הרשאת-מיקום באפליקציה היא runtime, לא נאספת ע"י האפליקציה).
- **Personal info** (שם/אימייל/טלפון) — אין חשבון/login בבילד-ברירת-המחדל.
- **Financial · Contacts · Photos/Videos · Messages · Audio files** — לא נאספים.

> נימוק: `SharedPreferences` = העדפות-UI/סל/מועדפים — **מקומי, ללא PII, ללא העלאה**. תוכן-משתמש
> (הזמנות/פרופיל) נכתב ל-Firestore **רק** כש-`USE_FIREBASE_BACKEND` מופעל (לא בבילד-החנות).
> מה שכן יוצא בכל בילד = **טלמטריית Crashlytics/Analytics** — מוצהר לעיל.

## חלק 3 — הרשאות (Permissions) — לא "איסוף-נתונים", אך כדאי לתעד לליסטינג

| הרשאה | שימוש | יוצא מהמכשיר? |
|---|---|---|
| `CAMERA` | סריקת ברקוד בלבד (`mobile_scanner`) — פענוח **על-המכשיר** | ❌ לא נשמר/נשלח ע״י האפליקציה ✅ |
| `RECORD_AUDIO` (מיקרופון) | חיפוש קולי (`speech_to_text`) | ❌ האפליקציה לא שומרת/שולחת אודיו. **⬜ לאמת:** שירות-הזיהוי-הקולי של מערכת-ההפעלה עשוי לעבד אודיו בענן לפי תנאי-הפלטפורמה — לנסח בהתאם. |
| `POST_NOTIFICATIONS` | הודעות-Push (FCM) | ה-FCM token = Device ID (מוצהר בחלק 2) — רק כאשר push פעיל. |
| `INTERNET` | Firebase (Crashlytics/Analytics/Firestore) + תמונות-CDN | ✅ תעבורת-טלמטריה מוצהרת לעיל; תמונות-מוצר = הורדה ציבורית בלבד. |
| `*_LOCATION` (foreground) | מיקום-משלוח runtime (`geolocator`) | ❌ לא נאסף/נשלח ע״י האפליקציה (שימוש מקומי בלבד). |

---

## ⬜ פעולות-משתמש לפני שליחת הטופס
1. **privacy-policy URL חי** שמתאר את Crashlytics/Analytics/FCM — ראה `privacy-policy.md` המעודכן.
2. **אם תבחר לכבות טלמטריה** בעתיד (לגדר `Firebase.initializeApp`+Crashlytics/Analytics מאחורי דגל
   כך שבילד-החנות offline-מלא) — להחזיר את חלק 1 ל-**No** ולנקות את חלק 2.
3. לאמת ניסוח-מיקרופון (חלק 3) מול תנאי שירות-הקול של אנדרואיד.
4. לאשר שלא יתווסף SDK-צד-שלישי (פרסום) שישנה את התשובות.

*(עודכן 2026-06-15 בעקבות B1 — אי-התאמה בין הצהרת "No" לבין Crashlytics/Analytics הפעילים בבילד.
ההחלטה: להצהיר ביושר על הטלמטריה. אם תתווסף/תוסר תלות שמשנה איסוף — לעדכן מסמך זה.)*
