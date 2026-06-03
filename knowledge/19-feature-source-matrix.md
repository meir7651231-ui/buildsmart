# מטריצת פיצ'ר × מקור — אב-טיפוס / Preact / Flutter

> תשובה מיידית ל"הפיצ'ר X קיים? איפה? באיזה עומק?". נגזר מ-01–18 + 21–22.
> **מקרא:** ✅ מלא · 🟡 חלקי/stub · 🔀 שונה · ➖ נעדר.
> ⚠️ עמודת-**Flutter = האפליקציה האמיתית** (`whats-happening`, אומת-מקוד) — לא ה-snapshot המיושן.

| פיצ'ר / תחום | אב-טיפוס | 🔄 Preact | 📱 Flutter (אמיתי) | דוח |
|---|---|---|---|---|
| מערכת-עיצוב (מותג) | ✅ teal `#1f6f6b` | ✅ teal | 🔀 **כתום `#FF7A18`** (חסר Rubik/glass) | 01 |
| dial pattern | ➖ (מסכים) | ✅ | ✅ (overlay מעל-טאבים) | 01/02 |
| מעטפת | 5-tabbar+מסכים | persona-routing (R2) | 🔀 **4 טאבים: מחלקות/שיחות/התראות/חנות** | 02 |
| onboarding | ✅ 12 מסכים | ➖ | 🟡 welcome/profession/3-slides (שונה) | 09 |
| קטלוג + עץ-מוצרים | ✅ TREES (202) | ✅ typed (202) | 🔀 **1,337 מוצרים אמיתיים** (Lipskey/Polyroll/Huliot) | 03 |
| **brands** (בחירת-מותג) | ✅ | ➖ נגזם | ✅ שוחזר (אמיתיים) | 03 |
| שלבי-פרויקט (infra/sealing) | ✅ | ✅ קטגוריות | ➖ | 03 |
| VARIANTS / TOOLS / SIZES | ✅ | ✅ typed | 🟡 `variant_families`/`install_kit`/`_size_norm` | 04 |
| חיפוש | ✅ 3-bars+fuzzy | ✅ FAB+5-tools | ✅ search-dial (4 tools) + סינונימים | 07 |
| **voice + barcode** | 🟡 הדמיה | ✅ web-APIs | ✅ **native** (mobile_scanner/speech_to_text) | 07 |
| הגדרות | ✅ sheet (8 קב') | ✅ dial (9, R9) | 🔀 **4 מסכים מלאים (~140) + dial(10)** | 06 |
| סל | ✅ | ✅ signals | ✅ `smart_cart` (persist) | 08 |
| **checkout** | ✅ computeCheckout מלא | ➖ | 🟡 **VAT-18 אמיתי, אישור=mock** | 08/10 |
| SYS_ORDERS (חוצה-פרסונות) | ✅ | ➖ | ➖ (אין backend) | 10 |
| ⭐ **Install-Studio** (engine/BOM/pressure-drop/compliance) | ➖ | ➖ | ✅ **רק-Flutter — עמוק מהפרוטוטייפ** | 08 |
| ⭐ **VerifiedSpec** (מנוע-חיבוריות) | ➖ | ➖ | ✅ 808 specs (Dijkstra) | 03/08 |
| readiness-score (per-מוצר) | ➖ | ➖ | ✅ | 08 |
| פרסונות (5) | ✅ דשבורדים מלאים | 🟡 store; שאר placeholder | 🟡 קבלן=app · מנהל/חנות/שליח/עובד=**BS-dial toast-stubs** | 12 |
| **chat** | ✅ Category-F (overlay) | ➖ | ✅ **טאב מלא** (1437ש׳) ⭐ | 09/16 |
| **התראות** | ✅ פאנל-appbar | 🟡 count signal | ✅ **טאב מלא** (1081ש׳) ⭐ | 09 |
| B2B (RMA/RFQ/השכרה/MSDS) | ✅ Category-A | 🟡 dial-leaves | 🟡 **store-items (demo-stubs)** | 14 |
| מרכז-פיננסים (B) | ✅ | 🟡 dial-leaf | 🟡 `kFinanceHub` (menu-toast) | 15 |
| ניהול-אתר (C) | ✅ | 🟡 10 leaves | 🟡 `kHomeTree`📋 (10, toast) | 15 |
| AI-hub (G) | ✅ Category-G | 🟡 dial-leaf | 🟡 9-tools (menu-toast); voice/barcode אמיתי | 16 |
| תגמולים (H) | ✅ | 🟡 מועדון-7 | ➖ **נעדר** (במקום: readiness-score) | 16 |
| אבטחה / RBAC (I) | ✅ Category-I | 🟡 23-leaves | 🟡 privacy/2FA-בהגדרות-אמיתי; אין RBAC-matrix | 17 |
| שירות / chatbot (J) | ✅ Category-J | 🟡 16-leaves | 🟡 chatbot=chat-thread אמיתי; שאר toast | 17 |
| סורק-תוכניות / סדר-הרכבה | ✅ | ➖ | 🔀 הוחלף ב-Install-Studio | 08 |
| **self-test** | ✅ 350-registry | 🟡 21-button | ✅ **155 בדיקות + `test_harness`** (11 suites) | 11 |
| ⭐ **עולם-פרוטוקולים** (gates/hooks/agents) | ➖ | 🟡 Inspector (43 INSP) | ✅ **116 שערים · 4 שכבות · 6 סוכנים** | 21/22 |
| PWA / offline | ✅ SW (v107) | ✅ Workbox | 🟡 flutter-web (מבטל-SW, אין-offline) | 17/20 |
| persistence | localStorage | localStorage | ✅ **shared_preferences** | 06/10 |
| i18n (he/ar/en) | 🟡 lang-setting | 🟡 | ✅ flutter_localizations | 01 |
| native (iOS/Android) | ➖ web | ➖ web/PWA (Capacitor מחווט-לא-פעיל) | ✅ **native** (launch-blockers=store-config) | 02/20 |
| deploy | — | ✅ Pages `/buildsmart/` | ✅ Pages `/buildsmart/flutter/` | 20 |

---
## תובנת-העל (מתוקנת מהמציאות)
- **אב-טיפוס** = ה-100% breadth — כל פיצ׳ר קיים (גם כהדמיה). מקור-האמת ל"מה".
- **Preact** = **dial-shell** שתרגם את **כל התוכן** ל-dial-leaves verbatim (R6); ה-hubs ported כ-leaves אך **המימוש = drill/toast**, לא flows.
- **Flutter = אפליקציית-אינסטלציה אמיתית, לא port.** קטלוג-מותגים אמיתי (1,337: Lipskey/Polyroll/Huliot) · **Install-Studio הנדסי** (Dijkstra/BOM/pressure-drop — היחיד **עמוק מהפרוטוטייפ**) · chat+notifications כטאבים-מלאים · 155 בדיקות · **116-שערי-פרוטוקול**. ~92% roadmap, קוד מוכן-להשקה (חוסמים=store-config).
- **רק ב-Flutter:** native · device-APIs אמיתיים · **Install-Studio + VerifiedSpec-engine** · chat+notifications-טאבים · readiness-score · עולם-116-שערים.
- **רק באב-הטיפוס (כ-flows מלאים):** SYS_ORDERS חוצה-פרסונות · checkout-engine מלא · B2B/AI/site/rewards פונקציונליים · דשבורדי-פרסונה מלאים (ב-Flutter = BS-dial toast-stubs).
- ⚠️ **drift מתועד:** ה-KB של Flutter אומר 1,879 מוצרים/tab0=קטלוג/teal — הקוד אומר **1,337/מחלקות/כתום** (הקוד קובע, R6).
