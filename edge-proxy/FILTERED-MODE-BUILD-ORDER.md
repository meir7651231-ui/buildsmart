# מצב-מסונן · ליעוס-בנייה (12.8.2026)

**הכרעת-בעלים:** לקוח על קו-מסונן חייב להתחבר ולעבוד — **הכול דרך הדומיין,
אפס בקשות מהסינון**. שיטת-ההתחברות: **מייל+סיסמה** (היחידה שנתיבה ל-REST יחיד;
גוגל/SMS נוגעים בכמה דומייני-גוגל ⇒ מחוץ להיקף).

## הממצא שקובע את הארכיטקטורה
- ✅ **Firestore-SDK דרך המתווך עובד** (אומת 12.8: הנתונים נטענים דרך
  `fs.buildsmart-il.com`) — כשיש סשן-Auth תקין של ה-SDK.
- ❌ **Auth-SDK אי-אפשר להפנות:** ‏`useAuthEmulator` של flutterfire כופה
  `http://` ⇒ נחסם ב-https. אין הפניית-host ל-firebase_auth.
- **מסקנה:** בקו-מסונן אין סשן-SDK של Auth ⇒ גם ה-Firestore-SDK חסר-טוקן.
  לכן **מצב-מסונן = שכבת-REST מקבילה** (Auth + נתונים) דרך המתווך, מאחורי
  תפרי-האפליקציה הנקיים.

## שלבי-הבנייה (כל שלב = בר-בדיקה, מאחורי מצב-מסונן ריצתי)

### שלב A · לקוח-REST של Auth  ← **מתחילים כאן**
`lib/data/edge/rest_auth.dart` — טהור (בונה-בקשה + מפענח-תשובה, בלי רשת):
- `signInWithPassword(email, password)` ⇒ POST ל-
  `https://idt.buildsmart-il.com/v1/accounts:signInWithPassword?key={apiKey}`
  ⇒ ‏`{idToken, refreshToken, localId, expiresIn}`.
- `signUp` (`accounts:signUp`), `refresh` (‏`token.buildsmart-il.com` —
  `grant_type=refresh_token`), מיפוי-שגיאות ל-Hebrew (‏EMAIL_NOT_FOUND /
  INVALID_PASSWORD / EMAIL_EXISTS / WEAK_PASSWORD).
- **בדיקות-יחידה:** בניית-URL, גוף-JSON, פענוח-הצלחה, מיפוי-כל-שגיאה. אפס רשת.

### שלב B · ניהול-סשן ריצתי
`FilteredSession` — מחזיק idToken+refreshToken+localId, רענון-אוטומטי לפני
פקיעה (expiresIn), התמדה ב-localStorage (מפתח פר-מקור), ניקוי ב-signOut.

### שלב C · ‏AuthGateway פר-מצב-מסונן
`FilteredAuthGateway implements AuthGateway` — ‏signInWithEmailPassword /
createUser / signOut / currentUser / authStateChanges מעל שלבים A+B. ‏sendOtp/
signInWithGoogle ⇒ זורקים "לא-זמין-במצב-מסונן". החלפה בשורש הספק לפי הדגל
הריצתי (כמו החלפת-הספק הקיימת של Firebase-vs-local).

### שלב D · מאגרי-Firestore ב-REST
מאגרי-הקריאה/כתיבה של הנתונים (קטלוג/הזמנות/…) — גרסת-REST מול
`https://fs.buildsmart-il.com/v1/projects/buildsmart-b0b78/databases/(default)/documents/...`
עם `Authorization: Bearer {idToken}`. ממופה ל-JSON של Firestore-REST (values-typed).
מוחלף באותו דפוס-ספק לפי מצב-מסונן.

### שלב E · UI מצב-מסונן
- מתג "אני על אינטרנט מסונן" (מסך-כניסה/הגדרות) ⇒ ‏localStorage ⇒ נקרא
  ב-startup לפני אתחול-Firebase. דלוק: מציג **רק מייל+סיסמה** (מסתיר גוגל/SMS),
  ומחליף את הספקים לגרסאות-ה-REST.
- כבוי (ברירת-מחדל) ⇒ ביט-זהה להיום.

### שלב F · אימות-שטח (שער-סופי)
build ⇒ הלקוח על קו-מסונן: מתג-מסונן ⇒ התחברות-מייל ⇒ נתונים זורמים. אפס
כתובת-גוגל ב-Network. זה השער שאי-אפשר לדמות מקומית.

## אבטחה/גבולות
- ה-apiKey הוא web-key ציבורי (כבר ב-bundle) — אין סוד חדש.
- ה-idToken ב-localStorage פר-מקור (כמו Firebase-SDK עצמו). ‏HTTPS בלבד.
- אפס נגיעה בזרימת-ה-SDK הרגילה (לא-מסונן) — מצב-מסונן הוא ענף-ספק נפרד.
- ‏Rules של Firestore נאכפות כרגיל (ה-REST נושא את אותו idToken).

**סטטוס:** שלב A בבנייה. שלבים B–F בהמשך, כל אחד PR נפרד עם בדיקות.
