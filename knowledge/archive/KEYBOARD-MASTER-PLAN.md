# מקלדת חכמה — BuildSmart Smart Input · מסמך‑בנייה מלא לצי

> **מסמך אב (canonical).** מאחד: חזון‑סופי · מחקר‑עומק (3 חוקרים, 15/6) · ארכיטקטורה · 100 שלבי‑בנייה · אילוצים.
> נלווים: `SPEC-smart-keyboard.md` (מחקר‑גלם) · `KEYBOARD-100-STEPS.md` (אותם 100 שלבים).
> **סטטוס:** v2 · מגודר `kSmartInput` (env `SMART_INPUT`) **default OFF = אפס‑רגרסיה byte‑identical** · **לא חוסם השקה.**

---

## 0. סיכום‑מנהלים
מקלדת **שמכירה את העסק**: במקום להקליד — מקיישים; והמסך נשאר נקי כי הכלים יושבים במקלדת. משאירים את מקשי‑המערכת (עברית/RTL/קול/נגישות בחינם) ומוסיפים מעליהם **רצועת‑הצעות חכמה** + **רצועת‑כלים**, ומחליפים ל**לוח‑ספרות מאובטח** רק בשדות מספר/קוד. **הכול הקשר‑תלוי** (משתנה לפי מסך/שדה/פריט). **רובו הרכבה של רכיבים קיימים** — לא בנייה מאפס.

**חוקי‑ברזל:** R2 (רצועה, לא חלון) · R6/R8 (עברית verbatim מהדאטה הקיימת, לא להמציא — לעטוף קיים) · נגישות חובה (Semantics/48dp/textScaler/RTL) · הכול מגודר OFF.

---

## 1. החזון — המקלדת המוגמרת (חוויית‑קצה)
**מבנה:** למטה המקלדת הרגילה (אותיות עברית). מעליה שתי רצועות דקות: הצעות‑חכמות + כלים.

**צ׳אט (שליח↔חנות):** עוד לפני הקלדה קופצים — "מוכן לאיסוף מהמחסן מ‑__" · "מתי אפשר לאסוף את BS‑1041?" · "אישור הזמנה #__ ✅" · וכלים 📎 POD · 📷 ברקוד · 🎤 קול · #️⃣ הזמנה · 🧱 מוצר · 😀 · ➤. נגיעה במשפט → נכנס; נגיעה ב‑#️⃣ → בוחר BS‑1041 → נכנס. הקלדה אחת במקום עשר.

**חיפוש‑קטלוג:** "מחס" → "מחסום (סיפון) אמריקאי 1.25"" + קטגוריה "מחסומים", מתוך ~1,872 מוצרים. ברקוד → סורק → מק"ט נכנס.

**שדה‑מספר (כמות/מחיר/תקציב):** לוח‑ספרות גדול ונקי + צ'יפי‑יחידות (מ"מ/ס"מ/מ'/ק"ג/יח'). מהיר, פחות טעויות, נוח עם כפפות/בשמש.

**קוד/סיסמה/תשלום:** לוח מאובטח — **ההקלדה לא יוצאת מהאפליקציה** (כמו אפליקציית‑בנק).

**שם/כתובת:** מציע לקוחות/אתרים מוכרים ("אלי בניין בע"מ", "מגדל הרצליה — רמת גן").

**מה לא משתנה (בכוונה):** טקסט חופשי עדיין נכתב במקלדת הרגילה → קול/החלקה/מילון‑אישי/נגישות נשמרים. רק מוסיפים חוכמה‑וכלים מעל, ומחליפים ללוח‑משלנו במספרים/קודים.

---

## 2. עיקרון‑על + הקשר‑תלוי
- **R2 — רצועה, לא חלון:** ה‑dial של ההקלדה.
- **הקשר‑תלוי (קריטי) — 3 רמות:** (1) **סוג‑שדה** (צ׳אט/חיפוש/מספר/קוד → מצב שונה); (2) **מסך** (חיפוש‑קטלוג‑ראשי מול בתוך‑חנות; מחיר מול כמות); (3) **פריט ספציפי** (צ׳אט‑עם‑ספק‑X → ההזמנות/מוצרים/משפטים של אותה שיחה; כמות‑על‑צינור → מטרים, על‑אריח → מ"ר; שליח≠עובד≠חנות). מנוהל ע"י `SmartInputContext{kind, screenId, payload}`.
- **תקדים קיים:** `_FilterChipsRow`/`_audienceChipsFor()` כבר נותן chips שונים לעובד מול שליח — מרחיבים.
- **(א) פאנל‑בתוך‑האפליקציה** (זה מה שבונים) ≠ **(ב) מקלדת‑מערכת IME** (לא בונים).

---

## 3. מחקר — מפת‑הקלט (93 אתרים)
הכול Material `TextField`/`TextFormField` (אין wrappers מותאמים). לפי סוג‑תוכן:

| סוג | # | אתרים מובילים | מה צריך |
|---|---|---|---|
| FREE_TEXT_HE | 13 | צ׳אט `chats_screen.dart:2087` · הערות‑משימה · סיבות‑דחייה | מקשי‑מערכת + רצועה (canned/הזמנה#/מוצר) |
| SEARCH | 6 | קטלוג `catalog_screen.dart:1601` · עץ `:3312` · smart `:3697` · חנות `store_screen.dart:589` | autocomplete (lipskeyWordIndex) |
| NUMERIC | 13 | כמות/מחיר `store_dashboard:981/1003` · תקציב `budget_screen:655` · מלאי `worker_employer_stock_sheet:381` | לוח‑ספרות + יחידות |
| CODE | 5 | OTP `login_sheet.dart:104` · קוד‑לוח `manager_profile:288` · SKU ידני `barcode_scanner:98` | לוח מאובטח |
| PHONE | 11 | `login_sheet:103` + פרופילים | לוח (phone)+פורמט |
| NAME | 8 | שם‑עסק/עובד/חנות | הצעות‑ישויות |
| ADDRESS | 4 | כתובות | הצעות‑אתרים |
| PASSWORD | 1 | `login_sheet:106` | לוח מאובטח |
| EMAIL | 1 | `login_sheet:105` | מקשי‑מערכת (email) |
| OTHER | 31 | שמות‑רשימות · R9 dialogs · תוויות | לפי‑הקשר |

**כפתורים שכבר צמודים לקלט:** שלח · attach · emoji (צ׳אט) · clear (search) · ברקוד (כפתור נפרד).

---

## 4. מחקר — דאטה להשלמה (הנכס)
- **קטלוג ~1,872 מוצרים:** ליפסקי 923 (`lipskey_catalog.dart`) · פולירול ~779 · חוליות ~170. שדות: `sku`(מספרי), `nameHe`, `categoryHe`, `brand`, `dims`, `color`.
- **🔑 `lipskeyWordIndex()`** (`lipskey_catalog.dart:474`) — אינדקס‑מילים הפוך מוכן (word→SKUs, lazy, min‑2). **מנוע‑autocomplete מן‑המוכן.**
- **`search_index.dart`** — 350+ ערכי‑ניווט (`contains()`).
- **8 מותגים** (`brands.dart`) · **13 קטגוריות** (`catalog.dart`, עם emoji).
- **ישויות:** עובדים (רן/עומר) · לקוחות (`kSimCustomers`: "אלי בניין בע"מ"...) · אתרים (`kSimSites`: "מגדל הרצליה"...) · צי.
- **📌 מס׳‑הזמנה = `BS‑####`** (לא ה‑SKU; SKU מספרי).
- **משפטים‑מוכנים בקוד:** תוויות‑שלב (`kOrderStageLabel`: "מוכן לאיסוף"/"בדרך לאתר"/"נמסר ✓") · seed‑צ׳אט (`chat_seeds.dart`: "מוכן לאיסוף מהמחסן מ‑14:00"/"אישור הזמנה #1234 — מוכנה לאיסוף ✅") · סטטוסי‑משימה · טיפי‑בטיחות.

---

## 5. מחקר — תשתית קיימת לשימוש‑חוזר (הרבה מן‑המוכן)
- **🎤 קול:** `VoiceService` (`services/voice.dart`, `speech_to_text:^7.0.0`, he‑IL) — מחווט להכתבת‑הערות; **קול‑בצ׳אט = stub** (`_showVoiceUnavailable`). → לחבר לרצועת‑כלים.
- **📷 ברקוד:** `openBarcodeScanner(context)→Future<String?>` (`mobile_scanner:^5.2.3`) + SKU ידני.
- **🔘 chips:** `_FilterChipsRow`+`_Pill` (`chats_screen.dart:752`) — בסיס לרצועת‑ההצעות.
- **✍️ הזרקה:** `_insertText(controller,text)` + emoji‑picker (`chats_screen.dart:1949`).
- **🔢 stepper:** `_SmartQtyStepper` (`store_screen.dart:1941`).
- **🔐 לוח‑ספרות — לא קיים** (רק validators: `validBoardCode`/`normalizeIlPhone`/`validEmail`). → בנייה חדשה.
- **i18n:** `enum BsLang{he,ar,en}` + locale (`main.dart:332`) + delegates; **RTL קשיח** (`main.dart:372`); תרגומים כמעט‑ריקים; קול he‑IL בלבד.
- **♿ נגישות:** `Semantics(button,label)` + ≥48dp + `textScaler`(`main.dart:358`) + `disableAnimations` + highContrast (`bsOnAccent`/`bsSuccess`). **אין package מקלדת — Flutter primitives, אפס deps חדשים.**

---

## 6. ארכיטקטורה — 3 שכבות
1. **רצועת‑הצעות חכמה** (מעל המקלדת, הקשר‑תלוית): צ׳אט→canned+הזמנה#+מוצר · חיפוש→מוצרים/קטגוריות · מספרי→יחידות · שם/כתובת→ישויות.
2. **רצועת‑כלים** (פיצ'רים במקלדת במקום במסך): שלח · POD · ברקוד→SKU · קול · הזמנה# · מוצר · יחידות · אימוג'י.
3. **לוח‑ספרות מאובטח** (שדות רגישים בלבד): OTP/קוד/סיסמה/תשלום — "לא יוצא מהאפליקציה".

---

## 7. מדיניות פר‑שדה
| שדה | מקלדת | חוכמה |
|---|---|---|
| צ׳אט/הערות | מקשי‑מערכת | canned + הזמנה# + מוצר |
| חיפוש | מקשי‑מערכת | autocomplete קטלוג |
| כמות/מחיר/תקציב/מלאי | לוח‑ספרות in‑app | יחידות |
| OTP/קוד/סיסמה/תשלום | **לוח מאובטח** | — |
| טלפון | לוח (phone) | פורמט IL |
| שם/כתובת | מקשי‑מערכת | לקוחות/אתרים |
| email | מקשי‑מערכת (email) | — |

---

## 8. 100 שלבי‑בנייה (A–I)

### A · יסודות + גידור
1. דגל `kSmartInput` (env `SMART_INPUT`), default false.
2. הרחבת `app_settings` — אופט‑אין פר‑סוג‑שדה, persisted off.
3. תיקייה `lib/widgets/smart_input/` + barrel.
4. enum `InputFieldKind` (9 סוגים).
5. `SmartInputContext{kind, screenId, payload}` (threadId/orderId/categoryId).
6. `SmartInputScaffold` עוטף TextField; OFF → passthrough מוחלט.
7. כיבוד textScaler/reduceMotion/highContrast/RTL ב‑scaffold.
8. provider Riverpod ל‑state (selection/query/recent).
9. helper `insertAtCaret` (חילוץ מ‑`chats_screen:1949`).
10. test: OFF == TextField רגיל (byte‑identical).

### B · רצועת‑הצעות (ליבה)
11. חילוץ `_Pill`/`_FilterChipsRow`→`SmartChipStrip`.
12. מודל `SmartChip{label,emoji?,onTap,kind}`.
13. גלילה אופקית + מירור RTL.
14. ≥48dp + Semantics לכל chip.
15. גודל מגיב ל‑textScaler.
16. צבעי highContrast (`bsOnAccent`/`bsSuccess`).
17. reduceMotion → בלי אנימציה.
18. הרצועה מעל המקלדת (keyboard‑inset aware).
19. tap → `insertAtCaret`.
20. סדר recent‑first + cap.
21. אין הצעות → רצועה מוסתרת.
22. test: הזרקה בקרסור + RTL.

### C · מנועי‑השלמה (דאטת‑העסק)
23. interface `SuggestionSource`.
24. מוצרים — עוטף `lipskeyWordIndex()` (min‑2, debounce).
25. מיפוי SKU→שם+מותג+emoji.
26. מיזוג polyroll+huliot.
27. קטגוריות(13)+מותגים(8).
28. canned (`kOrderStageLabel`+`chat_seeds`).
29. תבניות עם slots ("מ‑__","#__","[BS‑####]").
30. מס׳‑הזמנות אחרונים (`BS‑####`) ממאגר‑חי.
31. ישויות (`kSimCustomers`/`kSimSites`/`kWorkers`).
32. יחידות (מ"מ/ס"מ/מ'/ק"ג/יח').
33. ניווט (`search_index`).
34. debounce + cancel‑on‑keystroke.
35. דירוג prefix>contains+recency/frequency.
36. cap 8 + אינדקס lazy.
37. test לכל source (Firebase‑free).
38. perf: query על ~1,872 < 16ms.

### D · חיווט פר‑שדה (93)
39. צ׳אט‑composer — canned+הזמנה#+מוצר.
40. סגירת stub‑קול בצ׳אט → `VoiceService`.
41. חיפוש‑קטלוג ראשי.
42. עץ + smart.
43. חיפוש‑חנות + הוספת‑מלאי.
44. כמות/מחיר — numeric+units.
45. תקציב + מלאי‑עובד.
46. סכומי‑מימון.
47. שמות → ישויות.
48. כתובות → אתרים.
49. טלפונים → `normalizeIlPhone`.
50. SKU ידני → השלמת‑מוצר.
51. R9 inline / שמות‑רשימות.
52. OTP/קוד → סימון ל‑Phase‑2.
53. R8‑audit: הצעות רק מדאטה קיימת.
54. regression sweep: כל 93 — OFF זהה.

### E · רצועת‑כלים
55. `SmartToolRow` (RTL/48dp/Semantics).
56. שלח (reuse).
57. צרף/POD (reuse `openCameraSheet`).
58. ברקוד→SKU (reuse `openBarcodeScanner`).
59. קול (reuse `VoiceService`, locale מ‑`BsLang`).
60. הוסף‑הזמנה# (בורר `BS‑####`).
61. הוסף‑מוצר (מיני‑בורר‑קטלוג).
62. יחידות.
63. אימוג'י (reuse `_showEmojiPicker`).
64. סט‑כלים פר‑שדה.
65. כלים חסומי‑backend מוסתרים ביושר.
66. test לכל הקשר.

### F · לוח‑ספרות מאובטח (Phase 2)
67. `SecureKeypad` (0‑9/⌫, בלי IME מערכת).
68. פריסה ניטרלית‑RTL, ≥48dp.
69. textScaler/highContrast/reduceMotion.
70. OTP 6‑ספרות.
71. קוד‑לוח 4‑ספרות + `validBoardCode`.
72. וריאנט סיסמה (obscured).
73. וריאנט phone (11 שדות).
74. ודא "לא יוצא מהאפליקציה".
75. וריאנט decimal (מחיר/סכום).
76. שורת‑יחידות צמודה.
77. תוויות‑ספרה לקורא‑מסך.
78. haptic לכל מקש.
79. test לוח + validators.
80. החלטה: האם Phase‑3 (אותיות מלאות) נדרש.

### G · i18n / RTL
81. תוויות דרך l10n (He/Ar/En).
82. `VoiceService` locale מ‑`BsLang`.
83. audit מירור‑RTL.
84. יחידות מתורגמות.
85. canned פר‑locale (Ar/En מגודר).
86. עיצוב‑מספרים (`intl`).
87. ספרות‑LTR לא שוברות RTL‑שורש.
88. test i18n.

### H · נגישות + ליטוש
89. Semantics מלא.
90. בדיקת TalkBack.
91. בדיקת VoiceOver.
92. layout textScaler 0.85–1.35.
93. בדיקה highContrast.
94. בדיקת reduceMotion.

### I · בדיקות · CI · השקה
95. analyze נקי + test ירוק.
96. חבילת‑טסטים smart‑input ל‑CI.
97. APK flags‑ON + web‑preview עם `kSmartInput` ON.
98. QA על מכשיר (צ׳אט/חיפוש/מספרים/OTP).
99. docs (`WIRING`/logs/knowledge).
100. rollout מדורג: בטא→מדידה→GA; OFF עד אישור‑בעלים.

---

## 9. שלבים · מאמץ · מסלול‑הלב
| שלב | מה | מאמץ |
|---|---|---|
| 1 | A+B+C+D+E — רצועה‑חכמה+כלים (מחבר רכיבים קיימים) | **נמוך — ~80% מהחזון** |
| 2 | F — לוח‑מאובטח לשדות קוד/מספר/תשלום | בינוני |
| 3 (אופ׳) | מקשי‑אותיות מלאים — רק אם אבטחה‑מלאה חובה | גבוה |

## 10. אילוצים + שימוש‑חוזר
- **נגישות (חובה חוקית IL):** שלב‑1 משמר; 2‑3 חייבים Semantics+textScaler מחדש.
- אסור לאבד קול/RTL.
- **שימוש‑חוזר מוכן:** `lipskeyWordIndex` · `search_index` · `openBarcodeScanner` · `VoiceService` · `_FilterChipsRow`/`_Pill` · `_insertText` · `_SmartQtyStepper` · seed‑phrases. **לוח‑מאובטח = היחיד מאפס.**

## 11. DoD + שאלות פתוחות
- **DoD‑100%:** K1–K100 ✅ · אפס‑רגרסיה OFF · נגישות נשמרת · APK+preview ירוקים · אישור‑בעלים ל‑GA.
- **פתוח (בעלים):** (1) האם שלב‑3 נדרש או שלב‑2 מספיק. (2) ערבית/אנגלית (תלוי i18n). (3) לסגור stub‑קול‑בצ׳אט בשלב‑1 (זול, ה‑service קיים).

---

## 12. הכרעות-בנייה — נסגרו (2026-06-16, אישור-בעלים) → מוכן-לבנייה

**החלטת-על (ארכיטקטורה):** מקלדת אחת שלנו לכל האפליקציה (לא היברידי).
נגישות: זיהוי קורא-מסך פעיל (MediaQuery.accessibleNavigation) → fallback אוטומטי למקלדת-המערכת, + כפתור-נגישות ידני (הרשמה/פרופיל).
משמעות: זה משדרג מ"שלב-1 הרכבה (~80%)" לבניית-מקלדת-עברית-מלאה — פרויקט גדול יותר (בונים גם את שכבת-ההקלדה, לא רק את החוכמה מעליה).

1. זיהוי-הקשר: תיוג מפורש (InputFieldKind) לשדות החשובים + זיהוי-אוטומטי כ-fallback לשאר.
2. דירוג הצעות: בסיס לפי התאמת-טקסט · להציג 2 אחרונים · פריט שנבחר 3+ פעמים מקודם לראשון (נפוץ) · תקרה 6-8.
3. נתונים: אינדקס עצל (lazy), חייב להיות ניתן-לעדכון (לא סטטי - מתרענן כשהקטלוג/ההזמנות משתנים).
4. משפטים: תבניות-עם-slots מותרות - אבל ה-slot מתמלא רק מנתון-אמת חי (BS-####, שעה, שם-ישות), לעולם לא מילה מומצאת (R8 נשמר).
5. רכיב-הצ'יפים: SmartChipStrip חדש ונפרד - לא נוגעים ב-_FilterChipsRow הקיים (אפס סיכון-רגרסיה לסינון-הקהל בצ'אט).
6. שפות: עברית בשלב-1 · ערבית/אנגלית מגודר לבהמשך (אחרי i18n).
7. קול-בצ'אט: מחברים כבר בשלב-1 (סגירת ה-stub; VoiceService קיים, he-IL).
8. שלב-3 (מקלדת-אותיות מאובטחת): מתמזג להחלטת-העל - "רק המקלדת שלנו" = הכול ממילא בתוך-האפליקציה (אין הבחנה מאובטח/לא).

סטטוס: מוכן-לבנייה · מגודר kSmartInput ברירת-מחדל OFF (OFF = passthrough זהה-בייט, אפס-רגרסיה, לא חוסם-השקה).
נחיל-בנייה החל (בנצי המשיק, 2026-06-16) לפי PLAYBOOK: Understand/Plan -> Phase-1 יסוד (דגל + InputFieldKind + SmartInputContext + SmartInputScaffold[OFF-passthrough + a11y-fallback] + SmartChipStrip + SuggestionSource).
