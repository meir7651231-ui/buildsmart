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
➖ **לא הומרו ל-Preact:** פורטל ספק/שליח (F, כולל chat) · מרכז-AI (G) · תגמולים (H).
⬆️ **חריג:** **voice + barcode** (שהיו ב-AI-hub G) **הועברו ל-search-FAB** ב-Preact (`lib/voice.ts`/`barcode.ts` = **Web Speech API + BarcodeDetector אמיתיים**, לא הדמיה — `legacy-map.md`). שאר ה-AI (predict/alternatives/3way/weather/wear) + תגמולים + portal — נעדרים.

---

## 📱 Flutter (`app_flutter/lib/screens/chats_screen.dart`, 914 ש') — דלתא ⭐
**טאב-שיחות מלא בסגנון WhatsApp** (native): `_SearchBar` + `_FilterChipsRow` + `_ThreadList` + `_Pill` + שיחה. מול אב-הטיפוס (chat ב-Category F, `chatOverlay`) ו-Preact (לא הומר). ⭐ **chat = טאב ראשי** (אחד מ-4 הטאבים). שאר Category-F/G/H — לא הומרו.
