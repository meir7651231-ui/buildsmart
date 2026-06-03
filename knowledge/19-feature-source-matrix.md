# מטריצת פיצ'ר × מקור — אב-טיפוס / Preact / Flutter

> תשובה מיידית ל"הפיצ'ר X קיים? איפה? באיזה עומק?". נגזר מ-18 דוחות-המאגר.
> **מקרא:** ✅ מלא · 🟡 חלקי/placeholder · 🔀 שונה · ➖ נעדר.

| פיצ'ר / תחום | אב-טיפוס | 🔄 Preact | 📱 Flutter | דוח |
|---|---|---|---|---|
| מערכת-עיצוב (מותג) | ✅ teal `#1f6f6b` | ✅ teal (זהה) | 🔀 **כתום** `#FF7A18` | 01 |
| dial pattern (FAB/menu/search/BS) | ➖ (מסכים) | ✅ | ✅ (overlay מעל טאבים) | 01/02 |
| מעטפת | 5-tabbar + מסכים | persona-routing (R2) | 4 בוטם-טאבים (WhatsApp) | 02 |
| onboarding (splash/login/מקצוע) | ✅ 12 מסכים | ➖ | ➖ | 02 |
| קטלוג + עץ-מוצרים | ✅ TREES (3 סכמות) | ✅ typed (auto-gen) | ✅ smart_tree | 03 |
| **brands** (בחירת-מותג) | ✅ | ➖ **נגזם** | ✅ **שוחזר** | 03 |
| שלבי-פרויקט (infra/sealing) | ✅ | ✅ (קטגוריות) | ➖ | 03 |
| VARIANTS / TOOLS | ✅ | ✅ (typed) | 🟡 (smart_tree מאחד) | 04 |
| SIZES / STOCK_DEMO / ACC_GROUPS | ✅ | ➖ | ➖ | 04 |
| חיפוש | ✅ 3-bars + fuzzy | ✅ search-FAB + tools | ✅ search-dial | 07 |
| **voice + barcode** | 🟡 הדמיה (AI-hub) | ✅ אמיתי (Web Speech+BarcodeDetector) | ✅ אמיתי (mobile_scanner/speech) | 07/16 |
| הגדרות | ✅ sheet (8 קב') | ✅ dial-tree (R3/R9) | ✅ dial-tree | 06 |
| סל | ✅ | ✅ signals | ✅ cart+store | 08/09 |
| **checkout** (computeCheckout/VAT/split) | ✅ | ➖ | ➖ | 08/10 |
| SYS_ORDERS (חוצה-פרסונות) | ✅ | ➖ | ➖ | 10 |
| פרסונות (5) | ✅ דשבורדים מלאים | 🟡 store; השאר placeholder | 🟡 store-tab; sections לשאר | 12 |
| **chat** | ✅ Category-F (overlay) | ➖ | ✅ **טאב מלא** ⭐ | 16 |
| **התראות** | ✅ פאנל-appbar | 🟡 count signal | ✅ **טאב מלא** ⭐ | 09 |
| B2B (RMA/RFQ/השכרה/MSDS/planner) | ✅ Category-A | 🟡 dial-leaves (labels; flow=toast) | ➖ | 14 |
| מרכז-פיננסים (B) | ✅ | 🟡 dial-leaf | 🟡 kFinanceHub (dial) | 15 |
| ניהול-אתר (C: גאנט/ליקויים/נוכחות) | ✅ | 🟡 site-hub 10 leaves | ➖ | 15 |
| AI-hub (predict/alternatives/3way) | ✅ Category-G | 🟡 dial-leaf (label) | ➖ | 16 |
| תגמולים / portal (H/F) | ✅ | 🟡 dial-leaves (מועדון 7) | ➖ | 16 |
| אבטחה / RBAC (I) | ✅ Category-I | 🟡 dial-subtree (~23 leaves) | 🟡 settings rows | 17 |
| שירות / chatbot (J) | ✅ Category-J | 🟡 dial-subtree (~16) | 🟡 settings rows | 17 |
| סורק-תוכניות + סדר-הרכבה | ✅ | ➖ | 🟡 / ➖ | 08 |
| self-test (BUTTON_REGISTRY ~350) | ✅ | 🟡 test/ ממוקד | ➖ (בענף זה) | 11 |
| PWA / offline | ✅ service-worker | ✅ (vercel build) | ✅ flutter-web | 17 |
| persistence | localStorage | signals/localStorage | ✅ **shared_preferences** | 06/10 |
| i18n (he/ar/en) | 🟡 lang-setting | 🟡 | ✅ flutter_localizations | 01 |
| native (iOS/Android) | ➖ web | ➖ web/PWA | ✅ **native** | 02 |

---
## תובנת-העל
- **אב-טיפוס** = ה-100% — כל פיצ'ר קיים (גם אם כהדמיה).
- **Preact** = **dial-shell** שתרגם את **כל התוכן** (כולל hubs/B2B/rewards/security/service) ל-**dial-leaves verbatim** (117 leaves ב-PROFILE_TREE+SETTINGS_SUB; R6). 🔧 אבל **המימוש-הפונקציונלי** של ה-hubs = drill/toast placeholder, לא flows. (טעות קודמת: "השמיט hubs" — שגוי; השמיט רק את ה-flows, לא את ה-leaves.)
- **Flutter** = **native dial-shell שמשחזר עומק** — מותג כתום · device-APIs אמיתיים · brands+finance-hub חזרו · **chat+התראות כטאבים-מלאים** (מעבר לשני הקודמים) · אך עדיין בלי B2B/AI/site/security-מלא/checkout-engine.
- **שלושה דברים שרק ב-Flutter:** native, device-APIs אמיתיים, chat+notifications כטאבים.
- **רק באב-הטיפוס (כ-flows פונקציונליים מלאים):** B2B (Category-A) · AI-hub · ניהול-אתר (C) · checkout-engine + SYS_ORDERS. (ה-labels/structure שלהם **כן** ב-Preact כ-dial-leaves; ב-Flutter — חלקית, kFinanceHub.)
