# PARITY — מפת ההטמעה המלאה (כל הידע → Flutter)

> **מטרת המסמך:** מקור-האמת היחיד למאמץ ההטמעה. מרכז את **כל הידע** שקיים
> בפרוטוטייפ (`/index.html`) ובאפליקציה הקודמת (Preact `app/`), את הסטטוס הנוכחי
> ב-Flutter (`app_flutter/`), ואת פעולת-ההטמעה הנדרשת — **כ-dial** (R2), עם
> מחרוזות **verbatim** (R6/R8). זהו ה"definition of done" של `TARGET.md`, מפורט.
>
> כל שורה כאן היא מעוגנת-מקור (R8 — אין המצאה). מתעדכן ככל שמטמיעים.

## שלוש השכבות (מקור → יעד)
| שכבה | תפקיד | מה לוקחים ממנה |
|---|---|---|
| פרוטוטייפ `/index.html` (22,416 שו') | ה-spec ל**מה** | כל מסך/עלה/מחרוזת עברית — verbatim |
| Preact `app/` (~13.7K שו', חי) | תרגום ל-**dial** | מבנה ה-dial, הנתונים שחולצו, מה כבר עובד |
| Flutter `app_flutter/` (~45.5K שו') | ה**יעד** | מטמיעים לתוכו, מעל הבסיס הקיים |

## מקרא סטטוס (Flutter)
- ✅ הוטמע ועובד · 🟡 חלקי/פסאדה · 🔌 בנוי אך מנותק · ❌ נעדר · ⛔ חסום (אין נתון/שרת/מכשיר)

## עקרונות הטמעה
1. **dial, לא חלון** (R2) — גם אם הפרוטוטייפ פתח מסך מלא, אצלנו זה dial/עלה.
2. **verbatim** (R6/R8) — כל מחרוזת מהפרוטוטייפ/Preact, לא להמציא.
3. **על הבסיס הקיים** — קטלוג/סטודיו/סל/צ'אט/התראות/הגדרות כבר חזקים; לא לשבור.
4. **wire ⇒ contract ⇒ test** — כל הטמעה: helper טהור + רישום ב-`WIRING.md` + בדיקה.
5. **לוגיקה אמיתית כשיש נתון; אחרת ⛔ ביושר** — לא toast-דמה במקום פיצ'ר.

---

# מצאי הידע לפי תחום

## A · מעטפת וניווט (הבסיס — לפני הכל)
| ידע | מקור | Flutter עכשיו | הטמעה |
|---|---|---|---|
| 5 personas ב-BS dial | proto role-drawer [L4083] / Preact `bs-dial.tsx` | ✅ 5 tiles, 4 עם עצים | — |
| persona קבלן | (הקבלן = האפליקציה הראשית) | ❌ ריק | למלא: dial שמפנה ל-tabs/menu של הקבלן |
| תפריט-הקבלן (בית/פרויקטים/רכש/הגדרות) | Preact `menu-speed-dial.tsx` | 🔌 בנוי, אין trigger | **לחבר** ל-FAB/כפתור |
| תפריט-חיפוש (קולי/ברקוד/פילטר/מיון) | Preact `tools-dial.tsx` | 🔌 בנוי, מנותק (חיפוש בטאב עובד) | **לחבר** ל-FAB |
| R1 — 5 FABs קבועים | `app/RULES.md` | 🟡 4 טאבים + FAB עגלה | **הכרעה**: לממש 5-FAB או להשאיר 4-טאב ולחבר menu/search אחרת |

## B · קבלן — בית וכלי-עבודה
| ידע | מקור | Flutter | הטמעה (dial) |
|---|---|---|---|
| 🤖 AI hub (9 כלים) | proto `openAIHub` [L21123] / Preact | 🔌 עלים→toast | תוכן אמיתי/⛔ לפי נתון |
| 📐 סריקת תוכנית (3 סוגים+OCR) | proto `renderScanResults` [L9821], `PLAN_TYPES` | ❌ | dial + תוצאות (⛔ סריקה אמיתית=מכשיר) |
| 📦 המלאי שלי (מחסן/אתר) | proto `renderStock` [L8209], `STOCK_DEMO` | ❌ | dial + toggle מיקום |
| 📋 משימות + 🏗️ ניהול-אתר (גאנט/ליקויים/קומה-דירה-חדר/יומן/בטיחות) | proto `openSiteHub` [L19856], `GANTT_TASKS`/`SITE_TREE`/`WORK_LOG` | ❌ | dial-drill לכל 10 הפיצ'רים |

## C · קבלן — פרויקטים/אתרים/פיננסים
| ידע | מקור | Flutter | הטמעה |
|---|---|---|---|
| פרויקטים + אתרים | proto `renderProjects` [L7455], `PROJECTS`/`SIM_SITES` | 🔌 שמות בלבד | dial + סטטוס-אתר |
| תקציב חי (קטגוריות/חריגה) | proto `renderBudget`/`openBudgetDetail` [L7159/7190] | ❌ | dial + מתמטיקת-תקציב (helper) |
| מסלול-עבודה חכם (פיצול משימות לימים) | proto `renderSmartProject` [L7348], `TASKS` | ❌ | dial + מצב done/step |
| 📊 מרכז פיננסים (10 כלים) | proto `openFinanceHub` [L19487], `kFinanceHub` | 🔌 עלים→toast | dial-drill (מדד/תנאי-תשלום/ROI/מט"ח...) |

## D · מסחר ו-B2B (הליבה הטרנזקציונית)
| ידע | מקור | Flutter | הטמעה |
|---|---|---|---|
| סל + checkout + מע"מ/משלוח | proto `renderCart`/`computeCheckout` [L11044/10838] | ✅ בסיסי | להעמיק: משלוח-לפי-ספק, קרדיט |
| מתכנן-משלוחים (פיצול שורה לגלים) | proto `renderShipPlanner` [L18583] | ❌ | dial + מודל `lines=[{idx,qty}]` |
| הזמנות + מעקב + תעודת-משלוח | proto `renderMyOrders` [L7701], `ORDER_STAGE` | 🟡 mock | מכונת-מצבים אמיתית |
| RFQ מכרזים | proto `openRFQ`/`submitRFQ` [L19357] | ❌ | dial + draft+list |
| RMA החזרות | proto `openRMA`/`submitRMA` [L18978] | ❌ | dial + פריטים+סיבה |
| השכרת כלים / פקדונות | proto [L19040/19115], `RENTAL_TOOLS`/`DEPOSIT_ITEMS` | 🟡 toast | dial + חישוב ימים×תעריף |
| MSDS גיליונות בטיחות | proto `openMSDS` [L19420], `MSDS_SHEETS` | 🟡 toast | dial + פירוט סיכון/טיפול/עזרה |
| השוואת-מחירים / BULK / מט"ח | proto [L19328/21026/19797] | ❌ | מחשבונים (dial) |
| אשראי קבלן | proto `openCreditDetail` [L11005], `CONTRACTOR_CREDIT` | ❌ | dial + מסגרת/ניצול |
| **ייצוא XML ממשלתי** (מבנה 1.31) | proto `buildGovXML` [L19298] | ❌ | helper בונה-XML + הורדה |
| **חתימה + תעודת-משלוח** | proto `initSignaturePad`/`showDeliveryNote` [L19166/17212] | ❌ | canvas חתימה + מסמך להדפסה |

## E · פרופיל וגיימיפיקציה (חסר לגמרי ב-Flutter)
| ידע | מקור | Flutter | הטמעה |
|---|---|---|---|
| כרטיס-קבלן + סטטיסטיקות חיות | proto `refreshIdentity` [L6545] / Preact `PROFILE_TREE` | ❌ | dial-tree (כמו Preact) + `identityStats` |
| דרגות (RANKS — 4 דרגות, הנחות 2/5/8%) | proto `RANKS` [L6499] | ❌ | helper `currentRank/nextRank` + dial |
| הישגים (6 badges) | proto `identityAchievements` [L6535] | ❌ | dial + תנאים חיים |
| מועדון BuildCoins (מטבעות/אתגרים/לוח/VIP) | proto `openRewardsHub` [L21452] | ❌ | dial-drill |

## F · Onboarding / זהות / RBAC (חסר ב-Flutter)
| ידע | מקור | Flutter | הטמעה |
|---|---|---|---|
| splash→welcome→login→מקצוע→app | proto `ONBOARD_SCREENS` [L11634] | ❌ (נכנס ישר) | להכריע: זרימת-כניסה או דילוג |
| בחירת-מקצוע (אינסטלטור/חשמלאי/שיפוצים) | proto `pickProfession` [L11645] | ❌ | dial/בחירה |
| role-drawer (5 תפקידים) | proto `enterRole` [L11806] | 🟡 BS dial הוא זה | להשלים מעבר-תפקיד |
| RBAC matrix (5×הרשאות + `can`/`requirePerm`) | proto `RBAC_MATRIX` [L21675] | ❌ | מודל הרשאות + dial אבטחה |
| מרכז אבטחה (2FA/ביומטרי/session/פרטיות/audit) | proto `openSecurityHub` [L21751] | 🟡 הגדרות חלקי | dial-drill + audit-log |

## G · 4 אפליקציות-התפקיד (כ-dial, לא dashboards!)
> ⚠️ R2: persona dashboards כחלונות **אסורים** (3 רברטים). מטמיעים את ה**פונקציונליות** דרך dial-drill + מנוע-הזמנות משותף.

| persona | מקור | Flutter | הטמעה (dial) |
|---|---|---|---|
| 🏪 חנות-ספק | proto `renderStore*` [L17080+], `STORES`/`STORE_STOCK` | 🔌 שמות→toast | אישור-הזמנה, ליקוט, toggle-מלאי, פורטל |
| 🛵 שליח | proto `renderCourier*` [L17963+], `FLEET`/`DIST_ZONES` | 🔌 שמות→toast | jobs, התקדמות-משלוח, POD |
| 🦺 עובד | proto `renderWorker` [L11832], `TASKS`/`WORK_LOG` | 🔌 שמות→toast | משימות, לולאת-אישור עובד→מנהל |
| 👔 מנהל | proto `renderMgr*` [L12133+] | 🟡 רגרסיה בלבד | KPI חי (helper), הזמנות, לקוחות, CRUD |
| מנוע-הזמנות משותף | proto `SYS_ORDERS` [L11970] | ❌ | state משותף + מכונת-מצבים |

## H · קטלוג והגדרות (חזק — בעיקר פערים)
| ידע | Flutter | הטמעה |
|---|---|---|
| קטלוג 935 + חיפוש + גיליון + chips | ✅ | — |
| סטודיו-התקנות + BOM | ✅ (עמוק מהפרוטוטייפ) | — |
| ~150 הגדרות | 🟡 ~20 פעילות | לחבר מה שיש נתון; השאר ⛔ ביושר |
| מועדפים | 🟡 אין כפתור הוספה | להוסיף affordance |
| מחירים | ⛔ `brandPrice=0` | חסום עד מקור-מחירים |

## I · חוצה-מערכת
| ידע | מקור | Flutter | הטמעה |
|---|---|---|---|
| i18n (he/ar/en) | proto `I18N` [L22058] | 🟡 he מלא, ar/en stub | לפי החלטה |
| אינדקס חיפוש כללי | proto `buildSearchIndex` [L8591] | ✅ `search_index.dart` | להרחיב עם החדש |
| 6 hubs | proto | 🔌/🟡 | לפי תחומים B/C/F |
| self-test harness | proto `BUTTON_REGISTRY` | ✅ harness תוך-אפליקטיבי | להרחיב לכל חדש |

---

# שלבי הטמעה (סדר מאורגן)
1. **בסיס נגיש** (A) — לחבר תפריט+חיפוש dials, למלא persona קבלן → כל מה שקיים נגיש.
2. **פרופיל וגיימיפיקציה** (E) — Preact כבר עשה כ-dial; הכי קל להטמיע ובעל ערך.
3. **קבלן: בית/פרויקטים/פיננסים/משימות** (B,C) — ליבת הקבלן.
4. **מסחר ו-B2B** (D) — הזרימות הטרנזקציוניות.
5. **4 personas כ-dial-functionality + מנוע-הזמנות** (G).
6. **Onboarding / RBAC / אבטחה** (F).
7. **ליטוש חוצה** (I,H) — i18n, פערי-הגדרות, מועדפים.

כל שלב: dial (R2) · verbatim (R6/R8) · helper+contract+test · גרסה+commit.

---

# קישורים
`TARGET.md` (החזון/parity) · `SPEC.md`+`spec/` (מצב Flutter נוכחי) · `../WIRING.md` (חוזה) ·
`app/RULES.md` (R1–R9) · `/index.html` (מקור התוכן verbatim) · `app/src/` (מימוש dial להעתקה).
