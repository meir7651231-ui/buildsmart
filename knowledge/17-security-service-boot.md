# מרכז-אבטחה/RBAC (I) + מרכז-שירות/chatbot (J) + boot (21660–22414)

## ⭐ מרכז-אבטחה `sec-*` (Category I) (21660–22043)
- **`RBAC_MATRIX`** (21675) — `role→permissions[]` (בקרת-גישה מבוססת-תפקיד). `currentSecurityRole`/**`can(perm)`**/**`requirePerm`** (אכיפת-הרשאה) · `auditLog` (יומן-פעולות).
- **session-lock**: `resetSessionTimer`/`lockSession`/**`unlockSession`**/`initSessionTimeout` (נעילה-אוטומטית, `#sessionLock`).
- `openSecurityHub`→`secFeature`: **`secTwoFA`/`toggle2FA`** · **`secRBAC`** (תצוגת-הרשאות, מ-RBAC_MATRIX) · `secBiometric`/`toggleBiometric` · `secAudit` · `secGPS`/`requestGPS` · `secSession`/`setSessionTimeout`/`toggleSession` · `secEncryption` · `secLoginHistory` · `secDevices`/`revokeDevice` · `secPrivacy`/`togglePrivacy`.
> הערה-מקור (21666): "אבטחה אמיתית חיה בשרת — RBAC/audit/2FA כאן הם הדמיה."

## ⭐ מרכז-שירות + chatbot `svc-*` (Category J) (22044–22414)
`openServiceHub`→`svcFeature`:
- **help-desk**: `svcHelpDesk`/`submitHelpDesk`.
- **chatbot**: **`BOT_KB`** (22065) — knowledge-base `{kw[], a}`. `svcChatbot`/**`botReply`** (התאמת-kw→תשובה)/`sendBotMsg`/`botQuick` (צ׳יפים).
- **shake-to-report**: `svcShakeReport`/`toggleShakeReport`/`onDeviceShake`/`triggerBugReport` (ניעור-מכשיר→דיווח-באג).
- כלים: `svcUnitConvert`/`runUnitConv` (ממיר-יחידות) · `svcQtyCalc`/`runQtyCalc` (מחשבון-כמויות) · `svcCalendar` · **`svcJobBoard`/`postJob`** (לוח-דרושים) · `svcOnboarding`/`renderTourStep`/`tourNext` (סיור-מודרך).

---
**🏁 סוף ה-JS (שורה 22414) → `</script>` → `</body>` (22415).**
boot: האפליקציה standalone; מאותחלת ע"י splash-default (`screen-splash` גלוי) + קריאות-inline (`seedNotifications()` 11498 וכו׳). אין שכבת-data חיצונית (הערה 5415).

**bootstrap (script #1, 5419–5439):** תופס-שגיאות גלובלי — `window.addEventListener('error')` שמציג קופסה אדומה `bsFatalError` עם השגיאה (שכפתורים לעולם לא ייכשלו בשקט).

---

## 🔄 Preact — דלתא מול אב-הטיפוס
➖ **לא הומרו ל-Preact:** מרכז-אבטחה/RBAC (I — 2FA/biometric/audit/session-lock/encryption/privacy) + מרכז-שירות/chatbot (J — help-desk/BOT_KB/shake-report/ממיר-יחידות/לוח-דרושים/סיור). הקבוצות "אבטחה" ו"שירות ותמיכה" קיימות כ-rows בהגדרות (דוח 06), אך ה-hubs עצמם — placeholder/נעדרים.
**boot ב-Preact:** `main.tsx` → `render(<App/>)` (Preact). אין splash; error-catcher = כלי-Vite/dev.
