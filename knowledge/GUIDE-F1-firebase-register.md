# GUIDE — F1: לרשום iPhone + Android בקונסול Firebase

> הצעד שמחבר את **גרסת‑הטלפון** לשרת הקיים. ~10–15 דק' בדפדפן. **עשה במחשב** (קל יותר מטלפון).
> פרטים מאומתים מהקוד: פרויקט `buildsmart-b0b78` · package/bundle = `com.buildsmart.buildsmart`.

## מה שצריך
- דפדפן, מחובר לחשבון‑Google שבבעלותו פרויקט‑ה‑Firebase (אותו אחד שיצר את האתר).

## אנדרואיד (5 דק')
1. `console.firebase.google.com` → פתח פרויקט **buildsmart-b0b78**.
2. גלגל‑שיניים ⚙️ → **Project settings** → לשונית **Your apps** → לחץ אייקון **Android** (Add app).
3. **Android package name** = `com.buildsmart.buildsmart` (בדיוק, אות‑באות).
4. כינוי (App nickname) = "BuildSmart Android". **SHA‑1 — דלג** (אפשר להוסיף אח"כ).
5. **Register app** → **הורד את `google-services.json`**.
6. את שלבי‑ה‑gradle/SDK — **דלג** (הצי עושה אותם). לחץ Next עד הסוף.

## iPhone (5 דק')
1. אותו **Project settings → Your apps** → לחץ אייקון **Apple** (Add app).
2. **Apple bundle ID** = `com.buildsmart.buildsmart` (בדיוק).
3. כינוי = "BuildSmart iOS". App Store ID — דלג.
4. **Register app** → **הורד את `GoogleService-Info.plist`**.
5. שלבי‑ה‑Xcode/pods — **דלג** (הצי עושה).

## אחרי שהורדת את 2 הקבצים
מסור אותם לצי — הכי פשוט: **לצרף אותם ל‑repo** (הם **לא סודיים** — קונפיג‑לקוח, בטוח לשמור ב‑git). הצי אז:
- שם `google-services.json` ב‑`android/app/` · `GoogleService-Info.plist` ב‑`ios/Runner/`.
- מוסיף את ה‑plugin של google‑services + את אופציות‑הנייטיב ל‑`firebase_options.dart` (מסיר את ה‑throw).
- מחווט App Check נייטיב.
- **תוצאה:** הטלפון מתחבר לאותו שרת שה‑web משתמש בו.

## ⚠️ הערות‑אמת
- **2 הקבצים = קונפיג‑לקוח (לא סוד)** — מותר לשמור ב‑git. ⛔ מה ש**אסור** לשמור: קובץ ה‑service‑account (המפתח‑הסודי של השרת) — זה אחר לגמרי.
- **`com.buildsmart.buildsmart` ננעל לתמיד** ברגע שמגישים לחנויות. זה תקין — רק תאשר שזה השם שאתה רוצה.
- אם אין לך גישה לקונסול — צריך את חשבון‑Google שיצר את הפרויקט.

## DoD
האפליקציה על מכשיר/אמולטור **מתחברת לשרת** (לא נופלת לדמו), Firebase מאותחל נייטיב.
