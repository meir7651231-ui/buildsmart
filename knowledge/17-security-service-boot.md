# מרכז-אבטחה/RBAC (I) + מרכז-שירות/chatbot (J) + boot (21660–22414)

## ⭐ מרכז-אבטחה `sec-*` (Category I) (21660–22043)
- **`RBAC_MATRIX`** (21675) — `role→permissions[]` (בקרת-גישה מבוססת-תפקיד). `currentSecurityRole`/**`can(perm)`**/**`requirePerm`** (אכיפת-הרשאה) · `auditLog` (יומן-פעולות).
- **תוכן-עומק verbatim (INSP-0008):** RBAC **5 תפקידים** (קבלן · מנהל-מערכת · ספק/חנות · שליח · עובד) · session-timeouts **5/15/30/60 דק'** · encryption **4** (HTTPS/TLS · נתונים-מקומיים · סיסמאות-Hash · גיבוי-ענן) · privacy **4 toggles** (נתוני-שימוש · מיקום · שיווק · דוחות-תקלה).
- **session-lock**: `resetSessionTimer`/`lockSession`/**`unlockSession`**/`initSessionTimeout` (נעילה-אוטומטית, `#sessionLock`).
- `openSecurityHub`→`secFeature`: **`secTwoFA`/`toggle2FA`** · **`secRBAC`** (תצוגת-הרשאות, מ-RBAC_MATRIX) · `secBiometric`/`toggleBiometric` · `secAudit` · `secGPS`/`requestGPS` · `secSession`/`setSessionTimeout`/`toggleSession` · `secEncryption` · `secLoginHistory` · `secDevices`/`revokeDevice` · `secPrivacy`/`togglePrivacy`.
- **10 אריחי-המרכז verbatim (`openSecurityHub` @21752–21762, INSP-0007):** אימות דו-שלבי · הרשאות גישה · כניסה ביומטרית · יומן ביקורת · הרשאת מיקום · נעילת הפעלה · הצפנת נתונים · היסטוריית כניסות · ניהול מכשירים · בקרת פרטיות. (אלה ה-strings הפונים-למשתמש; השמות לעיל הם שמות-הפונקציות.)
> הערה-מקור (21666): "אבטחה אמיתית חיה בשרת — RBAC/audit/2FA כאן הם הדמיה."

## ⭐ מרכז-שירות + chatbot `svc-*` (Category J) (22044–22414)
`openServiceHub`→`svcFeature`:
- **help-desk**: `svcHelpDesk`/`submitHelpDesk`.
- **chatbot**: **`BOT_KB`** (22065) — knowledge-base `{kw[], a}`. `svcChatbot`/**`botReply`** (התאמת-kw→תשובה)/`sendBotMsg`/`botQuick` (צ׳יפים).
- **shake-to-report**: `svcShakeReport`/`toggleShakeReport`/`onDeviceShake`/`triggerBugReport` (ניעור-מכשיר→דיווח-באג).
- כלים: `svcUnitConvert`/`runUnitConv` (ממיר-יחידות) · **`svcQtyCalc`/`runQtyCalc`** (מחשבון-כמויות — 3 מצבים: אריחים/צבע/בטון) · `svcCalendar` · **`svcJobBoard`/`postJob`** (לוח-דרושים) · **`svcOnboarding`/`renderTourStep`/`tourNext`** (סיור — 6 שלבים: בית/הזמנה/תקציב/משימות-ואתר/מועדון/מוכנים). (verbatim, INSP-0008.)
- **8 אריחי-המרכז verbatim (`openServiceHub` @22081–22090, INSP-0007):** מוקד תמיכה · צ׳אטבוט · דיווח על באג · המרת מידות · מחשבון כמויות · סנכרון יומן · לוח דרושים · סיור היכרות. (strings פונים-למשתמש; לעיל = שמות-פונקציות.)

---
**🏁 סוף ה-JS (שורה 22414) → `</script>` → `</body>` (22415).**
boot: האפליקציה standalone; מאותחלת ע"י splash-default (`screen-splash` גלוי) + קריאות-inline (`seedNotifications()` 11498 וכו׳). אין שכבת-data חיצונית (הערה 5415).

**bootstrap (script #1, 5419–5439):** תופס-שגיאות גלובלי — `window.addEventListener('error')` שמציג קופסה אדומה `bsFatalError` עם השגיאה (שכפתורים לעולם לא ייכשלו בשקט).

---

## 🔄 Preact — דלתא מול אב-הטיפוס
🔧 **תיקון (INSP + grep על nice-volta):** מרכז-אבטחה (I) + מרכז-שירות (J) **כן נשזרו ל-Preact כ-dial-subtrees מלאים** (SETTINGS_SUB), verbatim (R6): **אבטחה ~23 עלים** (2FA · biometric · RBAC×5 · encryption×4 · privacy×4 · session-timeout · audit · GPS · devices) + **שירות ~16** (help-desk · chatbot · ממיר-יחידות · מחשבון-כמויות · סיור). grep: "מרכז האבטחה"×24, "מרכז השירות"×16.
➖ אבל **הפונקציונליות = toast/drill בלבד** (לא ה-flows המלאים — RBAC-matrix/OTP/BOT_KB/shake לא רצים). כלומר התוכן **ported כ-leaves**, המימוש לא.
**boot ב-Preact:** `main.tsx` → `render(<App/>)` (Preact). אין splash; error-catcher = כלי-Vite/dev.

---

## 📱 Flutter — דלתא
➖ אבטחה/RBAC (I) + שירות/chatbot (J) — לא הומרו (קבוצות "אבטחה"/"שירות" קיימות ב-`settings_tree` כ-rows בלבד).
**boot ב-Flutter:** `main.dart` → `runApp(ProviderScope(BuildSmartApp))` → `MaterialApp` (light/dark · RTL · he/ar/en) → `HomeShell`. אין splash/onboarding.

---

## 🌐 PWA · offline · deploy (תשתית-שורש)
> שכבת-המסירה — חלה על ה-web builds.
- **`manifest.json`** (root) — PWA לאב-הטיפוס: name "BuildSmart — רכש חומרי בנייה" · `start_url:./index.html` · `display:standalone` · `orientation:portrait` · `theme_color:#1f6f6b` (teal) · אייקוני-BS (SVG data-URI 192/512, `maskable`).
- **`service-worker.js`** (root · `CACHE_NAME:'buildsmart-v107'`) — SW **של אב-הטיפוס**: offline (network-first → cache-fallback → `index.html`). 🔧 ה-**Preact** מייצר PWA **משלו** דרך **`vite-plugin-pwa` (Workbox)** — SW+manifest אוטומטיים (app/README), לא ה-SW הידני הזה.
- **`vercel.json`** — deploy של **Preact**: `installCommand/buildCommand: cd app` → `outputDirectory: app/dist` + SPA-rewrites (הכל→`index.html` חוץ מ-assets). (CLAUDE.md: Preact חי גם ב-GitHub Pages.)
- **Flutter web**: `app_flutter/web/index.html` (shell נפרד; `flutter build web`).
- **`CLAUDE.md`** (root) — הוראות-פרויקט (ענפי-עבודה · R1–R9 · Flutter dev-loop) — מטא-פיתוח, לא ידע-מוצר.
