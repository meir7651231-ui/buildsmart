# Port · מקור A — ידע הפרוטוטייפ (`/index.html`)

> **מקור-האמת לתוכן (ה"מה").** 22,416 שורות · 712 פונקציות · ~70 טבלאות-נתונים.
> כל מחרוזת עברית כאן **verbatim** מהמקור (R6/R8). הפניות `[L#]` למספרי-שורה.
> זה הידע שאותו מטמיעים ל-Flutter כ-dials (R2). מלווה: `preact.md` (איך זה תורגם ל-dial).
>
> **תובנה ארכיטקטונית:** הקבלן אינו `screen-*` נפרד — `enterRole('contractor')` [L11815]
> נכנס דרך login → `enterApp()` [L11756] → `go('catalog')` ונופל לאפליקציית 5-הטאבים.
> מנהל/חנות/שליח/עובד הם dashboards מודבקים (`screen-*`). **כל ה-5 חולקים מנוע-הזמנות
> אחד** `SYS_ORDERS` (localStorage, מסונכרן בזמן-אמת) עם מכונת-מצבים
> `ORDER_STAGE` [L12041]: התקבלה→בהכנה→מוכן לאיסוף→נאסף→בדרך לאתר→נמסר.

## 0 · כניסה / Onboarding
| מסך/זרימה | מקור | תוכן verbatim |
|---|---|---|
| splash | `screen-splash` [L4030] | סלוגן 'מהשרטוט עד האתר — בלי לשכוח כלום'; auto אחרי 1600ms |
| welcome | `screen-welcome` [L4042] | 'כניסה ללקוח קיים' → `enterAsExisting` · רישום (regName/regContact) · 'המשך ללא רישום (דוגמה)' → `enterAsDemo` |
| role-drawer | [L4083] | 'מי אתה?' — 5× `enterRole`: 👷 קבלן · 👔 מנהל המערכת · 🏪 חנות ספק · 🛵 שליח · 🦺 עובד |
| login | `screen-login` [L4116] | טלפון → `loginExisting` |
| מקצוע | `screen-profession` [L4148] | 'מה התחום שלך?' — 🔧 אינסטלטור · ⚡ חשמלאי · 🔨 קבלן שיפוצים → `pickProfession` [L11645] → `enterApp` |
| entryMode | `applyEntryMode` [L6998] | new=פרויקט ריק · demo/existing=seeded |
| tour | `TOUR_STEPS` [L22374] | 6 צעדים (🏠→🛒→💰→📋→🎮→🎉), `renderTourStep` [L22386] |

## 1 · קבלן — בית
`renderHomeProducts` [L10633], view `view-home` [L4416]. כרטיסי-מוצר מתרחבים מ-`TREES`
(thumb/שם/✓-בסל/`₪X /יח'`/qty-wheel/`🌳 עץ מוצרים · N אביזרים`). hero 'הזמן עכשיו — קבל
לאתר עד שעתיים' [L4429]. `SAFETY_TIPS` [L19833] (5 טיפים מתחלפים).

## 2 · קבלן — בית: 4 ענפי הכלים
| ענף | מקור | תוכן |
|---|---|---|
| 🤖 בינה מלאכותית ואוטומציה | `openAIHub` [L21123] | 9: חיזוי מלאי · סורק ברקוד · דיבור למשימה · חלופות זולות · סריקת תוכניות · התאמה משולשת · אוטומציית מזג אוויר · זיהוי בלאי · Analytics חכם |
| 📐 סרוק תוכנית עבודה | `renderScanResults` [L9821], `PLAN_TYPES` [L9658] | 3 סוגים (אינסטלציה/חשמל/אדריכלות) — שרטוט SVG, נקודות, השוואת-מחירים רב-חנותית, 'אשר הכל — הוסף N לסל'; `openDocScan`/`runDocOCR` [L19249] OCR לתעודות |
| 📦 המלאי שלי | `renderStock` [L8209], `STOCK_DEMO` [L6202] | tabs 🏬 המחסן / 🏗️ האתר; `moveStock` toggle מיקום |
| 📋 משימות העבודה / 🏗️ ניהול אתר | `openSiteHub` [L19856] | 10: תרשים גאנט (`GANTT_TASKS`) · רשימת ליקויים · קומה·דירה·חדר (`SITE_TREE`) · נוכחות GPS · יומן עבודה · התראות בטיחות · תלויות חומרים · צילום לפני/אחרי · ביקורות מפקח · ארכיון |

## 3 · קבלן — פרויקטים / אתרים / פיננסים
| ידע | מקור | תוכן |
|---|---|---|
| פרויקטים/אתרים | `renderProjects` [L7455], `PROJECTS` [L6447] | כרטיס-אתר: שם/כתובת/👷 מנהל עבודה/🛒 N בעגלה/🌳 N עצים/📊 סטטוס; `openSiteStatus` [L7502] · `openSiteEditor` · `openProjectModal` |
| מסלול-חכם | `renderSmartProject` [L7348] | פיצול משימות לימים, 'N מתוך M ימים בוצעו · X%', `toggleSmartDay`/`toggleSmartStep` |
| תקציב חי | `renderBudget` [L7159] / `openBudgetDetail` [L7190] | total/spent/left/%, 'חריגה מהתקציב', `budgetCategories` (הוסף/ערוך/מחק) |
| 📊 מרכז פיננסים | `openFinanceHub` [L19487] | 10: 📈 הצמדה למדד · 🗓️ תנאי תשלום · 👷 קבלני משנה · ✅ אישורי רכש · 🔔 התראות חריגה · 📊 ניתוח ROI · 🧾 פיצול חשבוניות · ⏰ פיצויים וקנסות · 📄 דוחות PDF · 💱 רכש במט״ח |

## 4 · מסחר ו-B2B
| ידע | מקור | תוכן/לוגיקה |
|---|---|---|
| מנוע-תמחור | `computeCheckout` [L10838] | קיבוץ לפי ספק (`SUPPLIER_STORES` s1₪90/s2₪65/s3₪45) + haul (`HAUL_TYPES` small0/van40/truck90); split-billing; `VAT 18%`; `EXPRESS_FEE=80`; total×1.18 |
| מחירים | `STORE_PRICING` [L11908] | 3 חנויות × ~270 SKU, מחיר שונה לכל חנות |
| הזמנות | `renderMyOrders` [L7701], `ORDER_STAGE` [L12041] | סטטוסים; `toggleOrder` → 5 פעולות: תעודת-משלוח · פצל-משלוחים · החזרה · חתימה · צילום · ייצוא XML |
| מתכנן-משלוחים | `renderShipPlanner` [L18583] | פיצול שורה לגלים `lines=[{idx,qty}]`, תקרת `claimable`, שמירה חסומה עד שהכל משויך |
| RFQ מכרזים | `openRFQ`/`submitRFQ` [L19357] | טקסט-חופשי + 3 ספקים → `RFQ-50N`, הצעות מדורגות, 🏆 הזולה |
| RMA החזרות | `openRMA`/`submitRMA` [L18978] | checkbox לכל שורה + סיבה (עודף/פגום/בטעות/שינוי) → `RMA-100N` |
| השכרה/פקדונות | [L19040/19115] | `RENTAL_TOOLS` (₪/יום), `DEPOSIT_ITEMS`; `total=days*perDay` |
| MSDS | `openMSDS` [L19420], `MSDS_SHEETS` | 5 חומרים, 3 בלוקים: סיווג סיכון/הנחיות טיפול/עזרה ראשונה |
| מחירים/BULK/מט״ח | [L19328/20734/19482] | השוואת-מחירים · `BULK_TIERS` (1/20/50/100→0/5/9/14%) · `FX_RATES` |
| אשראי | `openCreditDetail` [L11005], `CONTRACTOR_CREDIT` [L16537] | מסגרת 30k–120k, %ניצול, 'שוטף +60' |
| **ייצוא ממשלתי** | `buildGovXML` [L19298] | מבנה אחיד 1.31, `DocumentType=305`, TotalBeforeVAT/VATAmount/TotalWithVAT; הורדת Blob |
| **חתימה+תעודה** | `initSignaturePad` [L19166] / `showDeliveryNote` [L17212] | canvas חתימה (עכבר+מגע) → `podSigned`; מסמך מלא: צדדים/פריטים/מע"מ/2 תיבות-חתימה |

## 5 · פרופיל / גיימיפיקציה
ראה מסמך מפורט `profile-rewards.md` (תחום E). תמצית: כרטיס-קבלן `refreshIdentity` [L6545],
דרגות `RANKS` [L6499] (4), הישגים [L6535] (6), מועדון `openRewardsHub` [L21452] (BuildCoins).

## 6 · RBAC / אבטחה / hubs
| ידע | מקור | תוכן |
|---|---|---|
| RBAC | `RBAC_MATRIX` [L21675] | 5 תפקידים × הרשאות; `can(perm)` [L21689] / `requirePerm` [L21695] → '⛔ אין לך הרשאה' |
| מרכז אבטחה | `openSecurityHub` [L21751] | 10: 2FA · ביומטרי · `auditTrail` [L21703] (נמשך) · GPS · session-timeout (5/15/30/60) · הצפנה · היסטוריית-כניסות · ניהול-מכשירים · `privacySettings` (analytics/location/marketing/crash) |
| מרכז שירות | `openServiceHub` [L22075] | 8: מוקד · 🤖 צ׳אטבוט (`BOT_KB` [L22065]) · דיווח-באג · המרת-מידות (`UNIT_CONV`) · מחשבון-כמויות · סנכרון-יומן · לוח-דרושים · סיור-היכרות |
| עזרה | `openHelp` [L6765], `HELP` | 5 כרטיסי Q&A |
| i18n | `I18N` [L22058] | he/ar/en/ru — אך רק `hub`/`sub` (3 מחרוזות), 99% עברית קשיחה; `dir` מתהפך [L6989] |

## 7 · ארבע אפליקציות-התפקיד (proto = screens; ב-Flutter = dial drill, R2!)
| persona | מקור | תוכן עיקרי |
|---|---|---|
| 🏪 חנות-ספק | `renderStore*` [L17080+] | login (`STORES`) · בית · הזמנות (`storeAdvance` new→preparing→ready) · ליקוט (`renderStorePick` עם **החזקת-חוסר** `heldForMissing`) · מלאי (`toggleStoreStock` מסתיר מהקבלן) · פורטל 8 (`SUPPLIER_RATINGS`/`DIST_ZONES`/`BULK_TIERS`/`FLEET`) |
| 🛵 שליח | `renderCourier*` [L17963+] | בחירת-רכב (`HAUL_TYPES`) · `vehicleCanCarry` (`VEHICLE_RANK`) · jobs לפי פיצול-משלוח · `courierAdvance` ready→pickup→transit→delivered · `courierNav`/`courierPOD` · פורטל 6 |
| 🦺 עובד | `renderWorker` [L11832] | בחירת-עובד (`WORKERS`) · קבוצות (נוכחית/בתור/הוגשו) · `TASKS` [L8023] (steps/photo/note/status) · לולאת-אישור עובד→מנהל · `WORK_LOG` |
| 👔 מנהל | `renderMgr*` [L12133+] | דשבורד KPI חי (`mgrAnalytics` [L12081]: הכנסות/pipeline/דירוג-חנויות) · הזמנות (`mgrAdvanceOrder`, `ORDER_FLOW`) · לקוחות+אשראי · CRUD מוצרים/חנויות · ניהול עץ |
| מנוע משותף | `SYS_ORDERS_SEED` [L11970], `loadSysOrders`/`saveSysOrders` [L18281] | localStorage + מאזין storage חוצה-טאבים |

## 8 · מודל-נתונים + חיפוש + self-test
| ידע | מקור | תוכן |
|---|---|---|
| מודל-מוצר | `TREES` [L5441] | 286 מפתחות: legacy (productType/name/brands[]/acc[] עם `why`+`must`) · `pl_*` (46 PDF+base64) · `acc_*` (148) |
| אינדקס | `CATALOG` [L6046] | 11 קטגוריות → items[] |
| וריאנטים/מפרט | `VARIANTS` [L6060] (50) · `SPECS` [L9894] · `CAT_DESC` · `ATTR_SCHEMA` [L8341] (drill מבוסס-נתונים) | |
| דיאגרמות | `DIAGRAMS` [L9375] | 8 זרימות-התקנה, stage→accessory `match` |
| חיפוש | `buildSearchIndex` [L8591] | `NAV_DESTINATIONS`(18)+`CONTENT_INDEX`(31)+דינמי+קטלוג, דירוג prefix>substring, cap 40 |
| self-test | `buildRegressionReportCore` [L15834], `BUTTON_REGISTRY` [L12517] (350) | בדיקת-מסע openTree→cart לכל מוצר + button-audit שמזהה "HOLES" |

> ⚠️ Flutter **לא** ייבא את `TREES`/`CATALOG` — בנה קטלוג חדש מחילוץ-PDF (935 מוצרי ליפסקי).
> מה שכן יקר לשמר מהפרוטוטייפ: פדגוגיית `why`/`must` לכל אביזר, `DIAGRAMS`, ATTR_SCHEMA.
