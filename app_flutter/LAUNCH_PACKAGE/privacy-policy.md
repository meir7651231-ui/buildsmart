# מדיניות פרטיות — BuildSmart · טיוטה v2 (לאירוח בכתובת ציבורית)

> **W3-B1 · יעד: B4 — מדיניות-פרטיות לחנויות.** סטטוס: **טיוטה — לא פורסמה**. עודכן 2026-11-06.
>
> **מקור-אמת אחד:** הנוסח העברי למטה זהה מילה-במילה ל-`kPrivacyPolicy` ב-`lib/data/legal_texts.dart`
> (המסך "מדיניות פרטיות" באפליקציה, מוגן ב-`test/legal_screen_test.dart`). אם משנים — משנים **שם**
> ומעתיקים לכאן. הטיוטה הקודמת בקובץ זה (06-2026, "אין חשבון/הרשמה") **הוחלפה** — היא כבר לא נכונה:
> בקוד יש כניסה (טלפון/דוא"ל/Google · `lib/state/auth_state.dart`) ומחיקת-חשבון בתוך האפליקציה
> (`lib/screens/profile_screen.dart` → `deleteAccount`).
>
> ### ⬜ חייב לפני פרסום (החלטות/פרטים של מאיר — לא ממציאים)
> 1. `[שם החברה]` · `[מספר רישום]` · `[כתובת רשומה]` · `[כתובת דוא"ל]` — בעלת-השליטה במידע.
> 2. **איזה בילד הולך לחנות?** הנוסח כתוב על הבילד ה-**LIVE** (`USE_FIREBASE_BACKEND=true` — סנכרון
>    לשרת, GA4, Crashlytics). ה-AAB של `android-release.yml` / `android-package.yml` נבנה היום **בלי**
>    `USE_FIREBASE_BACKEND`. אם זה הבילד שנשלח — המדיניות עדיין נכונה (היא מכסה יותר), אבל טופס
>    ה-Data-Safety / Privacy-Nutrition חייב להתאים לבילד בפועל. להחליט ולסנכרן את `data-safety.md`
>    (שגם הוא עדיין אומר "אין חשבון").
> 3. אירוח בכתובת ציבורית (למשל דף סטטי בדומיין `buildsmart.app`) + הזנת הקישור ב-Play Console
>    וב-App Store Connect. **לא בוצע** — פרסום לרשת דורש אישורך.
> 4. בדיקת עו"ד לפני השקה מסחרית (כנדרש בהערת `legal_texts.dart`).
> 5. Apple: נדרשת גם מחיקת-חשבון מתוך האפליקציה (קיימת ✅) ו-Privacy Nutrition Label תואם.

---

## עברית

**תאריך עדכון אחרון:** 1 באוגוסט 2026 (`kLegalLastUpdated`) · גרסת-מדיניות 2 (`kCurrentPolicyVersion`)

## 1. מבוא

מדיניות פרטיות זו מסבירה איזה מידע אישי נאסף באפליקציית BuildSmart, כיצד וְהיכן הוא נשמר, למי הוא מועבר ומהן זכויותיך. המדיניות מנוסחת בהתאם לחוק הגנת הפרטיות, התשמ"א-1981, לרבות תיקון מס' 13 לחוק (בתוקף מיום 14.8.2025), לתקנות הגנת הפרטיות (אבטחת מידע), התשע"ז-2017, לתקנות הגנת הפרטיות (העברת מידע אל מאגרי מידע שמחוץ לגבולות המדינה), התשס"א-2001, ולהנחיות הרשות להגנת הפרטיות.

בעלת השליטה במידע ומפעילת האפליקציה: [שם החברה], ח.פ./ע.מ: [מספר רישום], כתובת: [כתובת רשומה], דוא"ל לפניות בנושא פרטיות: [כתובת דוא"ל].

## 2. שני מצבי שימוש — אורח מול חשבון רשום

לאפליקציה שני מצבי שימוש המשפיעים ישירות על מה שנשמר והיכן:

מצב אורח: ניתן לעיין באפליקציה ללא הרשמה. במצב זה מזוהה המכשיר באמצעות מזהה אנונימי (לצורך טעינת הקטלוג מהשרת), והמידע האישי שלך — פרופיל, העדפות ונתונים מקומיים — נשמר במכשירך בלבד ואינו מסונכרן אלינו.

חשבון רשום: בהתחברות באמצעות מספר טלפון (קוד ב-SMS), דוא"ל וסיסמה, או חשבון Google — נוצר עבורך חשבון עם מזהה ייחודי (uid), וחלק מהמידע מסונכרן לשרת הענן שלנו (Firebase / Google Cloud) כמפורט בסעיף 4. הסנכרון מאפשר גיבוי, המשכיות בין מכשירים, ופעולות מול משתמשים אחרים (הזמנות, צ׳אט, ניהול חנות/מלאי/אתר).

## 3. חובת יידוע (סעיף 11 לחוק)

מסירת המידע בעת ההרשמה היא מרצונך ואינה מחויבת על-פי חוק. תוצאת אי-המסירה: תוכל להמשיך במצב אורח (מקומי) ללא חשבון שמור על שמך. מטרות האיסוף: יצירת חשבונך והצגת הפרופיל, שמירת העדפותיך, ניהול הפרויקטים/המשימות/ההזמנות/המלאי שלך, ואפשור תקשורת ופעולות מול משתמשים אחרים בפלטפורמה (קבלנים, ספקים, שליחים).

## 4. איזה מידע נאסף והיכן הוא נשמר

(א) מידע הנשמר במכשירך בלבד (אחסון מקומי): הגדרות ותצוגה, מועדפים, חיפושים אחרונים, סלים וטיוטות, התקדמות משימות שלא סונכרנה, תמונות וחתימות שאתה מצלם/יוצר באפליקציה (לרבות הוכחות-מסירה ותמונות-פרופיל/תעודות), ונתוני נוכחות והחתמת כניסה/יציאה — לרבות מיקום GPS לתיוג נוכחות באתר. במצב אורח כלל המידע נשאר כאן. מחיקת נתוני האפליקציה מוחקת מידע זה לצמיתות.

(ב) מידע הנשמר בשרת הענן שלנו (Firebase Firestore, אזור me-west1 / תל-אביב, ישראל) — למשתמשים רשומים ובעת שימוש בתכונות מסונכרנות:
· רשומת חשבון: שם, טלפון ו/או דוא"ל, מקצוע, וכן — באופן רשותי — כתובת/אזור שירות ומספר ח.פ./עוסק; מזהה החשבון (uid), מועדי יצירה/כניסה, וטוקן להתראות (FCM).
· הזמנות: שם המזמין, כתובת האתר, כתובת המשלוח, טלפון המזמין, פירוט הפריטים והערות.
· לקוחות, בקשות-תפקיד (שם וטלפון), משימות, בקשות-חומרים (שם עובד), נתוני חנות/מלאי ונתוני פרויקטים/אתרים — מקושרים למזהה החשבון שלך.
· הודעות צ׳אט שאתה שולח מול משתמשים אחרים — תוכן ההודעה ומזהה השולח.

(ג) אימות (Firebase Authentication, שירות Google): מספר הטלפון ו/או הדוא"ל ומזהה החשבון (uid) מעובדים לצורך ההתחברות.

(ד) מה שאינו עולה לשרת בשלב זה: תמונות המשתמש (נשמרות במכשירך בלבד), נתוני נוכחות ה-GPS, ויומן-האירועים המפורט המקומי.

## 5. אנליטיקה ודיווח תקלות

לצורך שיפור השירות ותפעולו נעשה שימוש בשירותי Google הבאים כאשר האפליקציה מחוברת לשרת:
· Google Analytics (GA4): נרשמים אירועים תפעוליים (למשל ביצוע הזמנה, שיוך תפקיד, אירוע שגיאה), וכן איסוף סטנדרטי של GA4 — סוג מכשיר/מערכת-הפעלה/שפה, מיקום גס לפי כתובת IP, ונתוני-הפעלה/מעורבות.
· Firebase Crashlytics (באפליקציית המובייל, בגרסת שחרור): דיווח קריסות ושגיאות עם הקשר טכני בלבד, ללא תוכן-משתמש גולמי.

אנליטיקת-שימוש מפורטת, נוכחות-משתמשים ובינת-לקוחות — כבויות בשלב זה, ומידע כאמור נשמר במכשירך בלבד (אם בכלל). הפעלה עתידית של העברה מורחבת תיעשה בכפוף להסכמתך המדעת ולגרסת-מדיניות מאושרת, וניתן למשוך את ההסכמה בכל עת.

## 6. שירותי צד-שלישי

· Firebase / Google LLC — אימות, מסד הנתונים (Firestore), אנליטיקה (GA4), דיווח-קריסות (Crashlytics) והתראות (FCM).
· Cloudflare (R2) — רשת אחסון-תוכן שממנה נטענות תמונות הקטלוג; מקבלת נתוני-תקשורת טכניים (כגון כתובת IP) ללא צירוף פרטי פרופיל.
· Open-Meteo — שירות מזג-אוויר חיצוני (אירופה); אם תשתמש בתכונת מזג-האוויר, נשלחות אליו קואורדינטות המיקום שלך לצורך התחזית בלבד.
· מנוע זיהוי-הדיבור של הדפדפן/מערכת-ההפעלה — לחיפוש קולי; ייתכן שספק הדפדפן/מערכת-ההפעלה מעבד את הקול בשרתיו לפי מדיניותו.

אין באפליקציה פרסומות, אין מעקב צד-שלישי לצורכי פרסום, ואין מכירה או השכרה של מידע אישי.

## 7. העברת מידע אל מחוץ לישראל

מסד הנתונים (Firestore) ופונקציות-השרת ממוקמים בישראל (אזור me-west1, תל-אביב). עם זאת, שירותי Google הנלווים — אימות (Authentication), אנליטיקה (GA4), דיווח-קריסות (Crashlytics) והתראות (FCM) — הם שירותים גלובליים שעשויים לעבד מידע גם מחוץ לישראל. העברה כאמור מתבצעת בהתאם לתקנות הגנת הפרטיות (העברת מידע אל מאגרי מידע שמחוץ לגבולות המדינה), התשס"א-2001, ובהסתמך על מנגנוני-ההגנה של ספק הענן.

## 8. הרשאות מכשיר (בהפעלה יזומה שלך בלבד)

· מצלמה — לסריקת ברקוד מוצרים ולצילום תמונות (הוכחת-מסירה, פרופיל, תעודות). אין צילום ברקע.
· מיקרופון — לחיפוש קולי של מוצרים בלבד. אין הקלטה ברקע.
· מיקום — לתיוג נוכחות/החתמת כניסה-יציאה (נשמר במכשירך), ולתכונת מזג-האוויר (שולחת קואורדינטות ל-Open-Meteo). אין איסוף מיקום ברקע.
· גלריית תמונות — לצירוף תמונות קיימות. · התראות — לקבלת עדכונים (FCM).

## 9. זכויותיך במידע

· זכות עיון (סעיף 13): כל המידע גלוי לך במסך הפרופיל ובהגדרות; לגבי מידע השמור בשרת ניתן לפנות אלינו לקבלת עותק.
· זכות תיקון ומחיקה (סעיף 14): ניתן לערוך את פרטי הפרופיל ולאפס הגדרות בכל עת. מחיקה מקומית — הסרת האפליקציה או ניקוי נתוני-האתר. מחיקה מהשרת — מחיקת החשבון מוחקת את רשומת החשבון שלך (users/{uid}) ואת רשומת-האימות; ניתן לבצע זאת מתוך האפליקציה או בפנייה ל-[כתובת דוא"ל].
· לא נענית? באפשרותך לפנות לרשות להגנת הפרטיות (gov.il, משרד המשפטים).

## 10. אבטחת מידע

המפעילה פועלת בהתאם לעקרונות תקנות הגנת הפרטיות (אבטחת מידע), התשע"ז-2017. מידע המאוחסן בשרת מוגן באמצעי-האבטחה של תשתית Firebase — הצפנה בתעבורה ובמנוחה וכללי-גישה מבוססי-אימות, כך שכל משתמש ניגש לנתוניו בלבד. מידע השמור מקומית — אבטחתו תלויה גם באבטחת המכשיר; מומלץ להגדיר נעילת-מכשיר ולעדכן מערכת-הפעלה ודפדפן.

## 11. קטינים

האפליקציה מיועדת לאנשי מקצוע בני 18 ומעלה, ואינה פונה לקטינים. איננו אוספים ביודעין מידע על קטינים.

## 12. שינויים במדיניות ותכונות שאינן פעילות

מדיניות זו תעודכן מעת לעת, ובפרט לפני שינוי מהותי באופן/מקום עיבוד המידע. תכונות הקיימות באפליקציה אך שאינן מעבירות מידע בשלב זה — העלאת תמונות לענן, עוזר ה-AI, ובינת-לקוחות/נוכחות — יופעלו רק לאחר עדכון מדיניות זו, מתן הודעה בתוך האפליקציה וקבלת הסכמה כנדרש בדין. על שינוי מהותי תינתן הודעה בתוך האפליקציה, ותאריך העדכון האחרון מופיע בראש המסך.

---

## English (for Google Play / App Store listings — translation of the Hebrew above; the Hebrew prevails)

**Last updated:** 1 August 2026 · policy version 2

**1. Introduction.** This policy explains what personal data the BuildSmart app collects, how and where it is
stored, who it is shared with and what your rights are. It follows the Israeli Protection of Privacy Law,
5741-1981, including Amendment 13 (in force since 14 Aug 2025), the Privacy Protection (Data Security)
Regulations 2017, the Privacy Protection (Transfer of Data to Databases Abroad) Regulations 2001, and the
guidance of the Privacy Protection Authority. Controller and operator: [Company name], reg. no. [number],
address [registered address], privacy contact: [email].

**2. Two modes — guest vs. registered account.** *Guest:* you can browse without signing up. The device is
identified by an anonymous ID (to load the catalog from the server); your profile, preferences and local data
stay on your device only and are not synced to us. *Registered account:* when you sign in with a phone number
(SMS code), email and password, or a Google account, an account with a unique ID (uid) is created and part of
your data is synced to our cloud server (Firebase / Google Cloud) as described in section 4, for backup,
multi-device continuity and actions with other users (orders, chat, store/stock/site management).

**3. Notice (section 11).** Providing data at sign-up is voluntary and not required by law. If you do not, you
can keep using guest (local) mode without a saved account. Purposes: creating your account and profile, saving
your preferences, managing your projects/tasks/orders/stock, and enabling communication and actions with other
users of the platform (contractors, suppliers, couriers).

**4. What is collected and where it is stored.**
(a) *On your device only:* settings, favorites, recent searches, carts and drafts, unsynced task progress, photos
and signatures you take or create in the app (incl. delivery proofs, profile photos, certificates), and
attendance / clock-in-out data — including GPS location for on-site attendance tagging. In guest mode all data
stays here. Clearing the app's data deletes it permanently.
(b) *On our cloud server* (Firebase Firestore, region me-west1 / Tel Aviv, Israel) — for registered users using
synced features: account record (name, phone and/or email, profession, optionally address/service area and
business ID; uid, creation/sign-in times, push token (FCM)); orders (orderer name, site address, delivery
address, phone, items and notes); customers, role requests (name and phone), tasks, material requests (worker
name), store/stock and project/site data — linked to your account ID; chat messages you send (content and
sender ID).
(c) *Authentication* (Firebase Authentication, a Google service): phone and/or email and uid are processed to
sign you in.
(d) *Not uploaded at this stage:* your photos (device only), GPS attendance data, and the detailed local event log.

**5. Analytics and crash reporting.** When the app is connected to the server we use: Google Analytics (GA4) —
operational events (e.g. placing an order, role assignment, an error event) plus standard GA4 collection
(device type/OS/language, coarse location from IP, session/engagement data); Firebase Crashlytics (mobile
release builds) — crash and error reports with technical context only, no raw user content. Detailed usage
analytics, user presence and customer intelligence are **off** at this stage; any future extended forwarding
will require your informed consent and an approved policy version, and consent can be withdrawn at any time.

**6. Third-party services.** Firebase / Google LLC (authentication, Firestore database, GA4, Crashlytics, FCM);
Cloudflare R2 (content network serving catalog images — receives technical connection data such as IP, no
profile data); Open-Meteo (weather, Europe — receives your coordinates only if you use the weather feature);
the browser/OS speech-recognition engine for voice search (the provider may process audio under its own
policy). No ads, no third-party advertising tracking, no sale or rental of personal data.

**7. Transfers outside Israel.** Firestore and server functions are located in Israel (me-west1, Tel Aviv).
Google's related services — Authentication, GA4, Crashlytics and FCM — are global and may process data outside
Israel, under the 2001 transfer regulations and the cloud provider's safeguards.

**8. Device permissions (only when you trigger them).** Camera — barcode scanning and taking photos (delivery
proof, profile, certificates); no background capture. Microphone — voice product search only; no background
recording. Location — attendance/clock-in tagging (stored on device) and the weather feature (sends coordinates
to Open-Meteo); no background location. Photo library — attaching existing photos. Notifications — updates (FCM).

**9. Your rights.** Access (section 13): your data is visible in the profile and settings screens; for server
data you may request a copy. Correction and deletion (section 14): you can edit your profile and reset
settings at any time; local deletion — uninstall or clear site data; server deletion — **deleting your account
in the app** removes your account record (users/{uid}) and authentication record, or contact [email]. You may
also complain to the Israeli Privacy Protection Authority (gov.il, Ministry of Justice).

**10. Security.** We follow the Data Security Regulations 2017. Server data is protected by Firebase
infrastructure — encryption in transit and at rest and authentication-based access rules so each user reaches
only their own data. Local data also depends on your device's security; use a screen lock and keep your OS and
browser updated.

**11. Minors.** The app is intended for professionals aged 18 and over and is not directed at minors. We do not
knowingly collect data about minors.

**12. Changes and inactive features.** This policy will be updated from time to time, and in particular before
any material change in how or where data is processed. Features present in the app that do not transfer data
at this stage — cloud photo upload, the AI assistant, and customer intelligence/presence — will be enabled only
after this policy is updated, in-app notice is given and consent is obtained as required by law. Material
changes will be announced in the app; the last-updated date appears at the top.
