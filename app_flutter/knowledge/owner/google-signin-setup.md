# הפעלת "כניסה עם Google" למנהל — מדריך בעלים (3 צעדים)

המנהל (חשבון הבעלים) נכנס לאפליקציה עם **חשבון Google**. הקוד מוכן; כדי שזה
יעבוד צריך 3 הגדרות חד-פעמיות ב-Firebase Console. בלעדיהן כפתור
"המשך עם Google" ייכשל (גוגל לא תאשר את הכניסה).

פרויקט: **buildsmart-b0b78** · חשבון הבעלים: **meir7651231@gmail.com**

## 1. הפעלת ספק Google ב-Authentication
1. Firebase Console → הפרויקט → **Authentication** → לשונית **Sign-in method**.
2. **Add new provider** → **Google** → **Enable**.
3. בחר **Project support email** (meir7651231@gmail.com) → **Save**.

## 2. SHA-1 / SHA-256 לאנדרואיד (חובה לכניסת-Google בנייד)
בלי טביעת-האצבע של מפתח-החתימה, Google Sign-In בנייד נכשל (ApiException: 10).
1. הפק SHA-1 + SHA-256 של מפתח-החתימה:
   - debug: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   - release: מה-keystore של החנות, או מ-Play Console → Setup → App signing → SHA-1.
2. Firebase Console → **Project settings** → **Your apps** → אפליקציית האנדרואיד → **Add fingerprint** → הדבק SHA-1 (וגם SHA-256) → **Save**.
3. הורד מחדש את **google-services.json** המעודכן והחלף ב-android/app/.

## 3. דומיין מורשה (web בלבד — אם משתמשים בגרסת web)
1. Authentication → **Settings** → **Authorized domains** → **Add domain**.
2. הוסף את הדומיין של ה-web. (לנייד/Play — לא צריך.)

## איך לבדוק שזה עובד
1. בנה והתקן את האפליקציה (נייד).
2. "מי אתה?" → **מנהל המערכת** → **המשך עם Google** → בחר את חשבון הבעלים.
3. אמור להיכנס ל"מרכז השליטה". חשבון Google אחר → "רק חשבון הבעלים יכול להיכנס כמנהל".

## אבטחה — מה כן ומה עדיין לא (כנות)
- ✅ אין סיסמה במכשיר; גוגל מאמתת (כולל 2FA אם מוגדר בחשבון Google).
- ✅ רק חשבון הבעלים מתקבל כמנהל.
- ⏳ **שלב 4 (אבטחת-שרת מלאה):** custom-claim של admin/manager שמוקצה לבעלים ע"י Cloud Function ונאכף ב-firestore.rules — זה מה שיהפוך את ההגנה ל"מאומתת-שרת". היום (בילד-דמו) השער הוא client-side להצגת-ה-UI; אין עדיין נתוני-שרת להגן עליהם.
- 🔁 להוסיף בעלים נוסף: ערוך את kOwnerEmails ב-lib/data/board_accounts_local.dart.
