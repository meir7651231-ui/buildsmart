# פורטל/chat (F) + AI (G) + תגמולים (H) (20800–21659)

## פורטל-ספק/שליח + chat (Category F) (20812–21063)
- שליח: `courierNav`/`startCourierNav` (ניווט-מפה) · **`courierPOD`/`capturePOD`** (proof-of-delivery — תמונה).
- פורטל-ספק: `portalFleet` (צי) · **`portalAutoStock`/`runAutoStock`** (חידוש-מלאי-אוטומטי) · `portalRatings` (דירוגים) · `portalSLA` · `portalZones` (אזורי-הפצה) · `portalBulk`/`updateBulkCalc` (הנחות-כמות) · `portalBarcode`/`makeBarcodeSVG` (ברקודים).
- **chat**: `openChat`/`renderChat`/`sendChat` (peer ספק↔קבלן↔שליח, `ux-msg` בועות).

## חיפוש-fuzzy (21065–21122)
**`levenshtein`** (מרחק-עריכה) · `fuzzySearchSuggest` · `homeSearchFuzzy` — חיפוש סלחני (typo-tolerant).

## ⭐ מרכז-AI (Category G) (21123–21401)
`openAIHub`→`aiFeature`: **`aiPredictStock`** (חיזוי-מלאי) · `aiBarcodeScan`/`aiBarcodeResult` (סורק-ברקוד) · **`aiVoiceTask`/`aiVoiceResult`** (משימה-קולית) · **`aiAlternatives`** (חלופות-זולות) · `aiPlanScan`/`aiPlanResult` (סריקת-תוכנית) · `aiThreeWay` (השוואה-משולשת) · `aiWeather` · `aiWearDetect` (זיהוי-בלאי) · `aiAnalytics` (תובנות).

## ⭐ מרכז-תגמולים (Category H) (21402–21659)
`openRewardsHub`→`rwFeature`: **`awardCoins`** (מטבעות) · `rwChallenges`/`claimChallenge` (אתגרים) · **`rwLeaderboard`** (לוח-מובילים) · `rwGreen` (תגמול-ירוק) · `rwCoupons` (קופונים) · **`rwReferral`/`shareReferral`** (חבר-מביא-חבר) · `rwVIP` (דרגות-VIP) · `rwRedeem`/`redeemReward` (מימוש).

---

## 🔄 Preact — דלתא מול אב-הטיפוס
🔧 **תיקון (INSP-0038 + grep):** **מועדון/תגמולים (H) כן נשזרו** ל-PROFILE_TREE כ-dial-leaves verbatim: 🎯 אתגרים חודשיים · 🏆 לוח מובילים · 🌿 תגי ירוק · 📍 קופונים · 👥 הזמן חבר · 💎 מועדון VIP · 🎁 מימוש (`rw*` @ :21464-21471). "בינה מלאכותית" (G) גם מופיע כעלה. → **התוכן ported (לא 'נעדר')**, אך הפונקציונליות = drill/toast.
➖ **לא הומרו (מימוש):** portal ספק/שליח (F, כולל chat) · מנוע-AI מלא (G: predict/alternatives/3way/weather) · flows של תגמולים. (voice+barcode כן אמיתיים — דוח 07.)
⬆️ **חריג:** **voice + barcode** (שהיו ב-AI-hub G) **הועברו ל-search-FAB** ב-Preact (`lib/voice.ts`/`barcode.ts` = **Web Speech API + BarcodeDetector אמיתיים**, לא הדמיה — `legacy-map.md`). שאר ה-AI (predict/alternatives/3way/weather/wear) + תגמולים + portal — נעדרים.

---

## 📱 Flutter — דלתא (portal/AI/rewards) ⭐ נכתב-מחדש
- **chat (F):** `chats_screen.dart` (**1,437ש׳**) = **טאב-ראשי native** (6 threads + bot auto-reply; פירוט בדוח 09). ה-צ׳אטבוט = thread + auto-reply.
- **AI (G):** **נבנה (07-06)** — `AIHubScreen` (`ai_hub_screen.dart` + `ai_hub_logic.dart`), נגיש מ**תפריט-בית**. barcode+voice אמיתיים; שאר ה-AI = תוצאה-מדומה. *(היה: 9 menu-dial toast-stubs — הדיאל הוסר.)*
- **תגמולים (H):** **נבנה (07-06)** — `RewardsHubScreen` (`rewards_hub_screen.dart`, 7 פיצ'רים: אתגרים/מובילים/תגי-ירוק/קופונים/חבר-מביא-חבר/VIP/מימוש), נגיש מ**מסך-פרופיל** (`profile_screen.dart`). *(היה: לא-הומר.)*
🔧 מול הפרוטוטייפ: F→טאב-אמיתי · G→hub-נבנה · H→hub-נבנה (עדכון 07-06).
