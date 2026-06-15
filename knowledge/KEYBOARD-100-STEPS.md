# KEYBOARD-100 — מפת‑בנייה לצי: מקלדת חכמה ב‑100 שלבי‑מיקרו

> נגזר מ‑`SPEC-smart-keyboard.md` (מחקר 3‑חוקרים, 15/6). כל שלב = יחידה אטומית שאפשר לסמן ✅.
> **חוקים:** הכול מגודר `kSmartInput` (env `SMART_INPUT`) **default OFF = אפס‑רגרסיה byte‑identical** · R2 (רצועה, לא חלון) · R6 (עברית verbatim מהדאטה הקיימת) · R8 (לא להמציא — לעטוף קיים) · נגישות חובה (Semantics/48dp/textScaler/RTL).
> **שימוש‑חוזר (לא לבנות מאפס):** `lipskeyWordIndex` · `search_index` · `openBarcodeScanner` · `VoiceService` · `_FilterChipsRow`/`_Pill` · `_insertText` · `_SmartQtyStepper` · seed‑phrases.

---

## A · יסודות + גידור (K1–K10)
1. דגל `kSmartInput` ב‑`backend.dart` (env `SMART_INPUT`), default **false**.
2. הרחבת `app_settings.dart` — אופט‑אין פר‑סוג‑שדה (`smartInputPerKind` map), persisted, default off.
3. תיקייה `lib/widgets/smart_input/` + barrel `smart_input.dart`.
4. enum `InputFieldKind { freeTextHe, search, numeric, code, phone, name, address, email, password }`.
5. `SmartInputContext { kind, screenId, payload }` (payload = threadId/orderId/categoryId לפי הקשר).
6. `SmartInputScaffold` — עוטף `TextField`; דגל OFF → passthrough מוחלט (אפס‑שינוי).
7. ב‑scaffold לכבד `MediaQuery.textScaler` + `disableAnimations` + highContrast + `Directionality.rtl`.
8. provider Riverpod ל‑state של ה‑smart‑input (selection/query/recent).
9. helper `insertAtCaret(controller, text)` — חילוץ `_insertText` מ‑`chats_screen.dart:1949`.
10. **test:** דגל OFF → scaffold == TextField רגיל (golden/byte‑identical).

## B · רצועת‑הצעות — ליבה (K11–K22)
11. חילוץ `_Pill`+`_FilterChipsRow` (`chats_screen.dart:752`) ל‑`SmartChipStrip` גנרי.
12. מודל `SmartChip { label, emoji?, onTap, kind }`.
13. גלילה אופקית + מירור RTL נכון.
14. כל chip: ≥48dp + `Semantics(button:true,label)`.
15. גודל‑chip מגיב ל‑`textScaler`.
16. צבעים דרך `bsOnAccent`/`bsSuccess` (highContrast‑safe).
17. `reduceMotion` → לדלג אנימציות‑chip.
18. הרצועה יושבת **מעל המקלדת** (keyboard‑inset aware), לא חלון (R2).
19. tap → `insertAtCaret` (הוסף/החלף לפי סוג).
20. סדר recent‑first, מכסה (cap) ל‑N.
21. empty‑state: רצועה **מוסתרת** כשאין הצעות (אין בר ריק).
22. **test:** tap‑chip מזריק בקרסור, RTL תקין.

## C · מנועי‑השלמה / מקורות‑דאטה (K23–K38)
23. interface `SuggestionSource { Future<List<Suggestion>> query(String, ctx) }`.
24. `ProductSuggestionSource` — עוטף `lipskeyWordIndex()` (min‑2, debounce).
25. מיפוי SKU→`nameHe`+brand+emoji לתצוגה.
26. מיזוג polyroll+huliot לאינדקס המוצרים.
27. `CategorySuggestionSource` — `kCatalogCats`(13)+`kBrands`(8).
28. `CannedPhraseSource` — `kOrderStageLabel`+תבניות `chat_seeds.dart`.
29. תבניות עם slots: "מוכן לאיסוף מהמחסן מ‑__" · "אישור הזמנה #__ ✅" · "מתי אפשר לאסוף את [BS‑####]?".
30. `OrderRefSource` — מס׳‑הזמנות אחרונים (`BS‑####`) ממאגר‑ההזמנות החי.
31. `EntitySource` — `kSimCustomers`/`kSimSites`/`kWorkers` ל‑NAME/ADDRESS.
32. `UnitSource` — chips יחידות: מ"מ · ס"מ · מ' · ק"ג · יח'.
33. `NavSuggestionSource` — `search_index.dart` לחיפוש‑גלובלי.
34. debounce + async + cancel‑on‑new‑keystroke.
35. דירוג: prefix > contains, ואז recency/frequency.
36. cap ל‑8 תוצאות, בניית‑אינדקס lazy.
37. **test:** לכל source בדיקה דטרמיניסטית (Firebase‑free).
38. **perf:** query על ~1,872 מוצרים < 16ms.

## D · חיווט פר‑שדה (93 האתרים) (K39–K54)
39. צ׳אט‑composer (`chats_screen.dart:2087`) — canned+orderRef+product.
40. לסגור stub‑קול בצ׳אט (`_showVoiceUnavailable`) → `VoiceService`.
41. חיפוש‑קטלוג ראשי (`catalog_screen.dart:1601`) — product+category.
42. חיפוש עץ (`:3312`) + smart (`:3697`).
43. חיפוש‑חנות (`store_screen.dart:589`) + הוספת‑מלאי (`store_dashboard:687`).
44. כמות/מחיר (`store_dashboard:981/1003`) — numeric‑strip + units.
45. תקציב (`budget_screen:655`) + מלאי‑עובד (`worker_employer_stock_sheet:381/396`).
46. סכומי‑מימון (`finance_hub_sheets:1163/1603`).
47. שמות (profile/worker/courier/store) — `EntitySource`.
48. כתובות — הצעות‑אתרים.
49. טלפונים — `normalizeIlPhone` + פורמט.
50. SKU ידני (`barcode_scanner.dart:98`) — `ProductSuggestionSource`.
51. שדות R9 inline / שמות‑רשימות (`catalog_screen` dialogs) — הצעות קלות.
52. OTP/קוד (`login_sheet:104`,`manager_profile:288`) — לסמן ל‑Phase‑2 (כרגע ללא strip).
53. **R8‑audit:** ההצעות מגיעות **רק** מדאטה קיימת (אפס המצאה).
54. **regression sweep:** כל 93 — דגל OFF זהה לחלוטין.

## E · רצועת‑כלים (פיצ'רים במקלדת) (K55–K66)
55. `SmartToolRow` — בר‑פעולות קומפקטי (RTL, 48dp, Semantics).
56. כלי **שלח** (reuse send הקיים).
57. כלי **צרף/POD** (reuse `openCameraSheet`/`_showAttachSheet`).
58. כלי **ברקוד→הוסף‑SKU** (reuse `openBarcodeScanner`).
59. כלי **קול→הכתבה** (reuse `VoiceService`, locale מ‑`BsLang`).
60. כלי **הוסף‑הזמנה#** (בורר `BS‑####` אחרונים).
61. כלי **הוסף‑מוצר** (מיני‑בורר‑קטלוג → שם/SKU).
62. כלי **יחידות** (quick‑insert).
63. כלי **אימוג'י** (reuse `_showEmojiPicker`).
64. סט‑כלים פר‑שדה (צ׳אט=הכול · חיפוש=ברקוד+קול · מספרי=יחידות).
65. כלים חסומי‑backend מוסתרים ביושר (לא placeholder מזויף).
66. **test:** tool‑row לכל הקשר.

## F · לוח‑ספרות מאובטח (Phase 2) (K67–K80)
67. `SecureKeypad` — 0‑9/⌫/נקה, `readOnly:true`+`showCursor` (בלי IME מערכת).
68. פריסת‑ספרות ניטרלית‑RTL, ≥48dp.
69. כיבוד textScaler/highContrast/reduceMotion.
70. חיווט ל‑OTP (`login_sheet:104`) 6‑ספרות.
71. חיווט קוד‑לוח (`manager_profile:288`) 4‑ספרות + `validBoardCode`.
72. וריאנט obscured לסיסמה (`login_sheet:106`).
73. וריאנט phone ל‑11 שדות‑הטלפון.
74. ודא **"ההקלדה לא יוצאת מהאפליקציה"** (אין IME חיצוני בשדות אלה).
75. וריאנט decimal למחיר/סכום.
76. שורת‑יחידות צמודה ללוח‑המספרים.
77. תוויות‑ספרה לקורא‑מסך.
78. haptic לכל מקש (לפי הגדרה).
79. **test:** לוח + validators (unit+widget).
80. **החלטה פתוחה:** האם Phase‑3 (מקשי‑אותיות‑מלאים) נדרש — stub‑gate בלבד.

## G · i18n / RTL / locale (K81–K88)
81. תוויות הרצועה/לוח דרך l10n — להרחיב `l10n/smart_card_strings.dart` ל‑He/Ar/En.
82. `VoiceService` — לפרמטר `localeId` מ‑`BsLang` (ar/en).
83. audit מירור‑RTL ל‑strip+toolrow+pad.
84. הצעות‑יחידות מתורגמות.
85. canned‑phrases פר‑locale (He עכשיו; Ar/En מגודר‑עתידי).
86. עיצוב‑מספרים (`intl`) לסכומים.
87. ודא ששורש‑always‑RTL לא נשבר משדות‑ספרות LTR.
88. **test:** i18n.

## H · נגישות + ליטוש (K89–K94)
89. מעבר‑Semantics מלא (כל מקש/chip/כלי).
90. סקריפט‑בדיקה TalkBack (Android).
91. סקריפט‑בדיקה VoiceOver (iOS).
92. בדיקת‑layout ב‑textScaler 0.85–1.35 (אין overflow).
93. בדיקה ויזואלית highContrast.
94. בדיקת reduceMotion (אין אנימציות).

## I · בדיקות · CI · rollout (K95–K100)
95. `flutter analyze` נקי + `flutter test` ירוק.
96. הוספת חבילת‑טסטים smart‑input לשערי‑CI.
97. build APK flags‑ON + web‑preview עם `kSmartInput` ON ל‑QA.
98. סקריפט‑QA על מכשיר (השלמת‑צ׳אט · חיפוש · לוח‑מספרים · OTP‑מאובטח).
99. docs: עדכון `WIRING.md` + `mutation_log`/`visual_log` + knowledge.
100. rollout מדורג: `kSmartInput` לבטא → מדידה → GA; default OFF עד אישור‑בעלים.

---
**DoD‑100%:** כל K1–K100 ✅ · אפס‑רגרסיה בדגל OFF · נגישות נשמרת · APK+preview ירוקים · אישור‑בעלים ל‑GA.
**מסלול‑מינימום (אם רוצים רק את הלב):** A+B+C+D+E = "מקלדת חכמה שמכירה את העסק" (שלב‑1 של ה‑SPEC). F=אבטחה. G/H/I=ליטוש‑והשקה.
