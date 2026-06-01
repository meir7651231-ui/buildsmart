# Google Play — Data Safety answers (BuildSmart)

> תשובות מוכנות-להקלדה לטופס **Data safety** ב-Play Console.
> מבוסס על אודיט-אבטחה (פאזה H ב-`knowledge/LAUNCH_READINESS.md`): האפליקציה **offline מלאה,
> 0 קריאות-backend, 0 secrets, 0 PII נשמר**. כל הנתונים מקומיים למכשיר.
> מקור-אמת: `lib/state/*` (SharedPreferences), `lib/services/voice.dart`, `lib/screens/barcode_scanner.dart`.

מקרא: ✅ = תשובה ודאית (מאומתת בקוד) · ⬜ = דורש אישור/השלמה מהמשתמש לפני הגשה.

---

## חלק 1 — Data collection and security

| שאלה בטופס | תשובה | בסיס |
|---|---|---|
| Does your app collect or share any of the required user data types? | **No** ✅ | אין רשת/שרת/SDK-אנליטיקה; אין login/חשבון. הנתון היחיד שיוצא = מחרוזת deep-link שנבנית מקומית ולא נשלחת (`related_info.dart`). |
| Is all of the user data collected by your app encrypted in transit? | **N/A** ✅ | לא נאסף/נשלח מידע — אין תעבורה. |
| Do you provide a way for users to request that their data is deleted? | **N/A** ✅ | לא נאסף מידע בשרת. נתוני-אפליקציה מקומיים נמחקים בהסרת-האפליקציה. |

## חלק 2 — Data types collected / shared

**Collected:** ללא ❌ · **Shared:** ללא ❌
(לא Location · לא Personal info · לא Financial · לא Messages · לא Photos/Videos ·
לא Audio files · לא Contacts · לא App activity/analytics · לא Device IDs.)

> נימוק: `SharedPreferences` מאחסן **רק העדפות-UI** (theme/size/view), סל-קניות, מועדפים,
> חיפושים-אחרונים, פרויקטים — הכול **מקומי, ללא PII, ללא העלאה**. logים של crash/analytics
> הם **in-memory בלבד** ולא נשמרים/נשלחים (`crash_log.dart`/`analytics_log.dart`).

## חלק 3 — הרשאות (Permissions) — לא "איסוף-נתונים", אך כדאי לתעד לליסטינג

| הרשאה | שימוש | יוצא מהמכשיר? |
|---|---|---|
| `CAMERA` | סריקת ברקוד בלבד (`mobile_scanner`) — פענוח **על-המכשיר** | ❌ לא נשמר/נשלח ע״י האפליקציה ✅ |
| `RECORD_AUDIO` (מיקרופון) | חיפוש קולי (`speech_to_text`) | ❌ האפליקציה לא שומרת/שולחת אודיו. **⬜ לאמת:** שירות-הזיהוי-הקולי של מערכת-ההפעלה (Android) עשוי לעבד אודיו בענן לפי תנאי-הפלטפורמה — לנסח בהתאם בליסטינג/מדיניות. |
| `INTERNET` | ברירת-מחדל של Flutter/plugins | ❌ אומת: **0 קריאות-רשת בקוד**. |

---

## ⬜ פעולות-משתמש לפני שליחת הטופס
1. **לאמת את הניסוח על המיקרופון** (חלק 3) מול תנאי שירות-הקול של אנדרואיד — אם מערכת-ההפעלה
   שולחת אודיו לזיהוי-ענן, ייתכן שצריך לציין זאת ב-privacy-policy (לא בהכרח כ"איסוף ע״י האפליקציה").
2. לאשר שאין SDK-צד-שלישי שיתווסף בעתיד (פרסום/אנליטיקה) שישנה את התשובות.

*(נוצר ע״י בנצי/משיק — פאזה I, צעד 99. אם תתווסף תלות שאוספת נתונים — לעדכן מסמך זה.)*
