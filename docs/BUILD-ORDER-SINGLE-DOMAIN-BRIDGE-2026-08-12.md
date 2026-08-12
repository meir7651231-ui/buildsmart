# BUILD-ORDER · גשר-דומיין-אחד לבנייה חכמה (12.8.2026)

**המטרה:** לקוח על קו מסונן (נטפרי/רימון/אתרוג) פוגש **דומיין אחד ויחיד —
`buildsmart-il.com` המאושר** — גם לטעינת האתר (כבר עובד: Firebase Hosting),
גם לתמונות, וגם לנתונים. ‏Blaze פעיל ✓ (אושר ע"י הבעלים 12.8).

**רקע-תקרית (12.8, לקחים 18–20 במאור):** האתר תמיד הוגש מהדומיין ישירות;
מה שנחסם למסוננים הוא הקריאות היוצאות — googleapis ‏(Auth/Firestore) ותמונות
`pub-…r2.dev`. הגשר סוגר בדיוק את אלו.

---

## שלב 1 · תמונות-הקטלוג → cdn.buildsmart-il.com — ✅ **באוויר 12.8 ‏(PR ‏#25, פריסה 00:26)**

1. **בעלים (קליק ב-Cloudflare):** ‏R2 ← המחסן `buildsmart-images` ← ‏Settings
   ← ‏Custom Domains ← ‏Connect ← ‏`cdn.buildsmart-il.com` (קלאודפלייר מוסיף
   את רשומת-ה-DNS לבד — אותו חשבון).
2. **קוד:** החלפת `https://pub-51f8c6ddf2de47e6b63e0f9588211cba.r2.dev/…` ⇒
   ‏`https://cdn.buildsmart-il.com/…` — גרפ מלא על `app_flutter/lib` +
   ‏`app/src/data` (2 מופעים ידועים ב-lib + נתוני-קטלוג). ⚠️ **תיאום עם זרם
   internal-card** — הקבצים חמים אצלו; להציע לו לבצע בעצמו כחלק מהסבב.
3. **אימות:** האפליקציה נטענת עם תמונות; ‏r2.dev לא מופיע ב-Network.
4. הרחבה לסנן: לבקש פתיחת `cdn.buildsmart-il.com` (תת-דומיין של מאושר — קל).

## שלב 1.5 · קטלוג/קונפיג דרך הדומיין — ✅ **באוויר 12.8 ‏(PR ‏#26, פריסה 08:37)**

הקבוע + 4 ה-workflows הוחלפו מ-firebaseapp.com לדומיין; ‏same-origin. מזג-אוויר: אומת נופל-רך (kWeather seed) — אין פעולה.

## שלב 2 · Firestore דרך הדומיין (הלב)

**העיקרון:** ל-SDK של Firestore יש דריסת-host רשמית (משמשת אמולטורים):
`FirebaseFirestore.instance.settings = Settings(host: 'buildsmart-il.com/db', sslEnabled: true)`
— ומאחורי הנתיב `/db/**` שמים proxy באותו דומיין.

1. **firebase.json (Hosting rewrites):**
   ```json
   { "source": "/db/**", "run": { "serviceId": "fsproxy", "region": "us-central1" } }
   ```
   ‏proxy כ-**Cloud Run/Functions v2** (‏v2 = Cloud Run ⇒ תומך streaming —
   קריטי ל-listen/long-polling של Firestore).
2. **ה-proxy:** מעביר ל-`firestore.googleapis.com` עם אותם headers/body;
   ‏passthrough טהור, בלי לגעת בתוכן. חובה לתמוך ב-gRPC-web + long-polling.
3. **קליינט:** מצב-מסונן (דגל/אוטו-זיהוי כשל): מדליק את דריסת-ה-host +
   ‏`webExperimentalForceLongPolling` (streams דרך proxy = שביר; long-polling יציב).
4. **אימות:** טסט-אינטגרציה מול פרויקט-בדיקה; ‏Network מציג רק את הדומיין.
5. **סיכונים:** ‏gRPC-web דרך rewrite — לאמת מוקדם עם PoC לפני חיווט מלא;
   עלות Cloud Run פר-תעבורה (זניח בנפחים הנוכחיים).

## שלב 3 · Auth דרך הדומיין (R&D — לא מובטח)

‏firebase_auth **אין** דריסת-host ציבורית (רק useAuthEmulator). מסלולי בדיקה:
1. ‏PoC ‏useAuthEmulator('buildsmart-il.com', 443) מול proxy שמתחזה — לבדוק
   אם ה-SDK כופה http/מזהה-אמולטור (חשד: כן ⇒ נפסל).
2. חלופה: זרימת-כניסה עצמאית ב-REST דרך `/auth/**` proxy (הפונקציה מדברת עם
   identitytoolkit מהשרת — לשרת אין סינון) + ניהול-סשן עצמאי ל-Firestore-proxy
   (טוקן עובר ב-header ל-proxy שמאמת ומחתים מחדש). עמוק — רק אם שלב 2 הצליח
   וההצדקה העסקית קיימת.
3. **בינתיים (המסלול הפרקטי):** בקשת-פתיחה לסנן על שלושת דומייני-googleapis —
   הנוסח המוכן ב-`maor-system/knowledge/FILTERED-NET-PLAYBOOK-2026-08-11.md`.

## סדר ביצוע מומלץ
שלב 1 (יום אחד, כולל תיאום) → ‏PoC של שלב 2 (יום-יומיים) → הכרעת-בעלים על
היקף שלב 2 המלא לפי תוצאת ה-PoC → שלב 3 רק אחרי ששלב 2 חי.

**גבולות:** אפס נגיעה בקבצים החתומים של זרם-התפריטים; כל שינוי-קליינט מתואם
עם הזרם המקביל; אין החלפות-DNS — הכול תוספתי על הדומיין הקיים (לקח 19).
