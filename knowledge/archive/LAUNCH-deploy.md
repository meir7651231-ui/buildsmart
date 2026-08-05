# LAUNCH-deploy — העלאת BuildSmart לאוויר (Firebase Hosting + Cloudflare + LiveDNS)

> runbook click-by-click. **ארכיטקטורה:** אתר = **Firebase Hosting** · שרת (שלב הבא) = **Firebase** · DNS של הראשי = **Cloudflare** · דומיין-עברי = **LiveDNS** (הפניה).
> מקרא: 📱 = בדפדפן/טלפון · 🤖 = אני/הצי מכין · 💻 = מחשב (רק במסלול הידני).
> ⚠️ **ערכים מדויקים (IP / TXT) — להעתיק מה-console של Firebase, לא מהמסמך הזה.**

---

## ✅ סטטוס מאומת (06-09, anchor `db920f2`)
- **אפליקציה חיה ✅** — Flutter web על Firebase Hosting: `https://buildsmart-b0b78.web.app` (deploy אוטומטי · run #1 success · build 49s + deploy 27s · "Production deploy succeeded").
- **CI שהוטמע** (code branch `whats-happening`, commit `db920f2`, **תוספת בלבד**): `firebase.json` + `.github/workflows/firebase-hosting.yml` (build base-href `/` → deploy live · project `buildsmart-b0b78` · secret `FIREBASE_SERVICE_ACCOUNT`).
- **גילוי:** כבר קיים pipeline `deploy.yml` → GitHub Pages (Preact ב-`/buildsmart/` + Flutter ב-`/flutter/`). **נשאר כתצוגה-מקדימה — לא נגעתי בו.**
- **החלטה מוצרית:** `buildsmart-il.com` → **האפליקציה החדשה (Flutter)**.
- **`buildsmart-il.com` ✅ חי (06-09)** — מחובר · **SSL פעיל** · מגיש את אפליקציית ה-Flutter כ-**PWA installable**. (אומת: A 199.36.158.100 DNS-only + TXT → Firebase verify + SSL.)
- **`בניהחכמה.ישראל` ⏸️ נדחה:** `serverHold` (לא פעיל) · LiveDNS גובה ₪170/שנה ל-forwarding → **לא לשלם**; כשיהיה פעיל → הפניה חינמית דרך Cloudflare Redirect Rules.

## 🗺️ מה הלאה (roadmap לפי עדיפות)
1. ✅ **בוצע** — `buildsmart-il.com` חי עם SSL, מגיש את אפליקציית ה-Flutter (PWA).
2. **(הצעד הגדול) Backend/שרת** — מ"דמו" ל"אמיתי": Auth (OTP) · Firestore (נתונים אמיתיים) · Security Rules (RBAC) · FCM (push). מפורק ב-`SPEC-server-connect-MICRO.md` (~48 משימות · 2–3 שבועות). פרויקט-פיתוח (הצי בונה · אתה עושה חלקי-console).
3. **(במקביל/אחר כך) חנויות** — iOS ($99/שנה) + Google Play ($25 חד-פעמי): listings · צילומים · privacy policy · signing · הגשה.
4. **(פוליש)** — הדומיין העברי (הפניה חינמית) · P-1 צבעים · P-5 ניקוי-knowledge.

**הצעד המשמעותי הבא = #2 (Backend).** בלעדיו = הדגמה יפה; איתו = מוצר אמיתי.

## ארכיטקטורה (מי מצביע לאן)
```
בניהחכמה.ישראל ──(הפניה 301, LiveDNS)──▶ buildsmart-il.com ──(A records, Cloudflare DNS)──▶ Firebase Hosting (האתר)
                                                                                              └─ Firebase = גם השרת (Auth/DB/Push) בשלב הבא
```
- **אירוח** (עכשיו) ו**שרת** (שלב הבא) — שניהם Firebase, console אחד.
- האפליקציה רצה כרגע על דאטה-דמו → אירוח לבד = אתר חי שנראה עובד. חיבור Firebase-server = פרויקט נפרד (`SPEC-server-connect.md`).

---

## חלק א — פרויקט Firebase (📱 דפדפן)
1. כנס ל-`console.firebase.google.com` → התחבר עם Google.
2. **Add project / הוסף פרויקט** → שם: `buildsmart` → Continue.
3. Analytics: אפשר לכבות → Create. המתן ~30ש' → Continue.
4. **רשום לעצמך את ה-Project ID** (מתחת לשם, למשל `buildsmart-xxxx`) — תצטרך אותו בחלק ב.

## חלק ב — deploy אוטומטי (📱 אתה + 🤖 הצי)
**המטרה:** כל push ל-GitHub בונה ומעלה לבד — בלי מסוף, בלי מחשב.
1. 📱 **מפתח-שירות:** Firebase → גלגל-שיניים (**Project settings**) → לשונית **Service accounts** → **Generate new private key** → יורד קובץ **JSON**.
2. 📱 **GitHub:** repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:
   - Name: `FIREBASE_SERVICE_ACCOUNT`
   - Value: כל תוכן ה-JSON (הדבק).
3. 🤖 **אני מכין** את `deploy-web.yml` + `firebase.json` (תוכן למטה) → הצי דוחף לענף-הקוד.
4. 📱 אחרי שהקבצים בריפו → push מפעיל build+deploy. בדוק **GitHub → Actions** שהריצה ירוקה ✅.
5. 📱 האתר חי ב-`https://<project-id>.web.app` — פתח, ודא שנטען.

**🤖 `.github/workflows/deploy-web.yml`:**
```yaml
name: Deploy Web to Firebase Hosting
on:
  push:
    branches: [ <ענף-הקוד> ]
jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
        working-directory: app_flutter
      - run: flutter build web --release
        working-directory: app_flutter
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          projectId: <project-id>
          channelId: live
```
**🤖 `firebase.json` (שורש הריפו):**
```json
{ "hosting": {
    "public": "app_flutter/build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [ { "source": "**", "destination": "/index.html" } ]
} }
```

**💻 אלטרנטיבה ידנית (רק אם יש מחשב ורוצים פעם-אחת בלי CI):**
`npm i -g firebase-tools` → `firebase login` → `cd app_flutter && flutter build web --release` → `firebase init hosting` (public=`build/web`, SPA=Yes) → `firebase deploy --only hosting`.

## חלק ג — חבר את buildsmart-il.com (📱 Firebase + 📱 Cloudflare)
1. 📱 Firebase → **Hosting** → **Add custom domain** → הקלד `buildsmart-il.com` → Continue.
2. 📱 Firebase יראה **רשומת TXT** לאימות-בעלות → העתק.
3. 📱 Cloudflare → הדומיין → **DNS** → **Add record** → Type=**TXT** → הדבק → Save.
4. 📱 חזור ל-Firebase → **Verify** (דקות עד שעות).
5. 📱 אחרי אימות → Firebase ייתן **2 רשומות A (כתובות IP)**.
6. 📱 Cloudflare → DNS:
   - **מחק** רשומות A/AAAA/CNAME ישנות של השורש שמצביעות למקום אחר (אחרת SSL לא יונפק).
   - הוסף **2 רשומות A** עם ה-IP-ים מ-Firebase, Name=`@`.
   - **Proxy status: DNS only (ענן אפור)** — כדי ש-Firebase ינפיק SSL בלי התנגשות.
7. 📱 חכה — Firebase מנפיק SSL (שעות). מסיים → `https://buildsmart-il.com` עם 🔒.
   - (www אופציונלי: חזור על 1–6 עבור `www.buildsmart-il.com`.)

## חלק ד — הפנה את בניהחכמה.ישראל (📱 LiveDNS)
1. 📱 LiveDNS → ליד `בניהחכמה.ישראל` → גלגל-שיניים / DNS.
2. חפש **"הפניית URL" / Web Forwarding** → הפנה ל-`https://buildsmart-il.com` (301).
3. אם אין כפתור כזה — שלח לתמיכת LiveDNS את ההודעה (🤖):
   > שלום, ברשותי הדומיין בניהחכמה.ישראל אצלכם. אני רוצה להגדיר הפניה (URL forwarding / 301) כך שכל כניסה ל-בניהחכמה.ישראל תעביר אוטומטית ל-https://buildsmart-il.com. אפשר להפעיל לי או להסביר איך? תודה.

## חלק ה — אימות סופי
- `https://buildsmart-il.com` → אתר + 🔒.
- `בניהחכמה.ישראל` → קופץ ל-buildsmart-il.com.
- ⏳ אזור `.ישראל` מתעדכן **5×/יום** (8:00/12:00/14:00/18:00/22:00).

---

## חלוקת-עבודה
- 📱 **אתה:** א (פרויקט) · ב1–ב2 (secret) · ב4–ב5 (בדיקה) · ג (דומיין+DNS) · ד (הפניה).
- 🤖 **אני/הצי:** ב3 (workflow + firebase.json) · טקסט-התמיכה · הערכים-המאומתים.
- ערכי IP/TXT — **אתה מעתיק מ-Firebase** (לא ממומצא).

## מקורות
- [Deploy to Firebase Hosting — GitHub Action (FirebaseExtended)](https://github.com/FirebaseExtended/action-hosting-deploy)
- [How to Deploy a Flutter Web App to Firebase Hosting with GitHub Actions — freeCodeCamp](https://www.freecodecamp.org/news/how-to-deploy-a-flutter-web-app-to-firebase-hosting-with-github-actions/)
- [Connect a custom domain — Firebase Hosting (Google)](https://firebase.google.com/docs/hosting/custom-domain)
- [Cloudflare proxy with Firebase Hosting custom domain — Cloudflare Community](https://community.cloudflare.com/t/how-to-use-cloudflare-proxy-with-firebase-hosting-custom-domain-verification/865296)
