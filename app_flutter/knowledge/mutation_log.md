# יומן בדיקות mutation

> קובץ זה חייב להיות מעודכן אחרי כל פונקציית עזר חדשה.
> ה-pre-commit hook בודק שהוא עודכן לפני שמירה.

## פורמט רשומה

```
### [שם הפונקציה] — [תאריך]
- תקלה שהוזרקה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- תקלה שנייה: [מה שיניתי]
- תוצאה: הבדיקה הייתה אדומה ✅ / ירוקה ❌
- מסקנה: הבדיקה חזקה / חלשה (מה שופר)
```

## רשומות
<!-- הוסף רשומה חדשה כאן לכל פונקציית עזר -->

## kSearchIndex — copy פרסונה canonical (W0 microcopy) — 2026-06-08

- **קובץ:** `test/search_index_persona_copy_test.dart` (חדש).
- **מה עושה:** נועל שאף `SearchEntry.title` לא מכיל `מנהל מערכת` (חסר ה׳) + שה-canonical `מנהל המערכת` קיים. ('מנהל מערכת' אינו תת-מחרוזת של 'מנהל המערכת' → contains מבחין נקי.)
- תקלה שהוזרקה: replace_all `מנהל המערכת`→`מנהל מערכת` (החזרת ה-drift).
- תוצאה: **אדומה ✅** — 2/2 נכשלו (bad לא-ריק · canonical חסר). ביטול → ירוק ✅.
- מסקנה: הבדיקה **חזקה** — תופסת drift של שם-הפרסונה ב-search index.

## chatBubbleAlignment — צד-בועת-צ׳אט (W1 #1 · RTL) — 2026-06-08

- **קובץ:** `test/chat_bubble_side_test.dart` (חדש).
- **מה עושה:** נועל את חוזה ה-spec (`sys_chat.dart §1 כיווניות`): הודעות-עצמי בצד
  start (ימין ב-RTL), אחרים end (שמאל); ו-resolve נכון ל-RTL (own→x=+1, other→x=−1).
  התיקון מנתב גם בועת-הודעה וגם בועת-הקלדה דרך `chatBubbleAlignment`.
- תקלה שהוזרקה #1: החלפת start↔end (`isMe ? centerEnd : centerStart`).
- תוצאה: **אדומה ✅** — 3/4 נכשלו (own→start · other→end · resolve-RTL); רק "לא-חולקים-קצה" עבר.
- תקלה שהוזרקה #2 (מבנית): החזרת `Alignment` אבסולוטי (הבאג המקורי) → **אינו מתקמפל**
  (טיפוס-החזרה `AlignmentDirectional`) — חוסם רגרסיה ל-absolute.
- מסקנה: הבדיקה **חזקה** — תופסת היפוך-צד; טיפוס-ההחזרה חוסם חזרה ל-`Alignment.center(Left|Right)`.
## install_engine — הנחיית-כיווניות לכל שסתום (B13/#1) — 2026-06-08

- **קובץ:** `test/install_engine_b13_test.dart` (חדש). פונקציית-עזר חדשה: `_directionalContext`.
- **מה עושה:** נועל שהאזהרה הכללית של B11 הפכה ל-**צ'ק לכל שסתום חד-כיווני** —
  `lineComplianceChecklist` פולט "כיוון התקנה: <שם השסתום>" עם `_directionalContext`
  שמציין "בין <עליון> ל-<תחתון>" (או כניסת/יציאת הקו). שני שסתומים → שני צ'קים.
- תקלה שהוזרקה: `_directionalContext` → `return ''` (ביטול ההקשר).
- תוצאה: אדומה ✅ — "naming the valve + neighbours" + "lone contextualised" נכשלו
  (אבד 'בין'/שמות-השכנים/'בקו'); "two valves" + "no directional" נשארו ירוקים.
- ביטול → ירוק ✅ (B13 + B11 + auto_compliance + full_compliance).
- מסקנה: `_directionalContext` load-bearing. **תזכורת:** זו הנחיה, לא אכיפה —
  קצוות-השסתום זהים פיזית, אז דחיית-התקנה-הפוכה בלתי-אפשרית (task #20).

## install_studio — באנר עומס-יתר אמיתי (B12/#5) — 2026-06-08

- **שינוי:** UI בלבד ב-`install_studio_screen._assemble` — `branches` סופר רק
  target אמיתי (≠ המחלק), והבאנר מבהיר "N לא חוברו". **אין פונקציית-עזר חדשה.**
- **הלוגיקה כבר נבדקת:** התנהגות-העומס-יתר במנוע (cap + gaps + warning) נעולה
  ע"י `manifold_test` מקרה 10, שכבר mutation-proved ב-B7 (הסרת ה-cap → אדום).
- **אימות UI חי:** build web + דפדפן — קו 3-ענפים על מחלק 2-יציאות הציג
  "3 ענפים על מחלק 2-יציאות — 1 לא חוברו (חסר במחלק)". צילום נשמר (visual_log).
- מסקנה: אין פונקציה חדשה לבדוק; הספירה נגזרת מהקלט והבאנר אומת חזותית.

## install_engine — אזהרת כיווניות לשסתום חד-כיווני (D4/B11) — 2026-06-08

- **קובץ:** `test/install_engine_b11_test.dart` (חדש).
- **מה עושה:** נועל ש-`_isDirectionalDevice` מזהה אל-חזור/אלחוזר (נחושת) + אל-חזור-ביוב
  (קטגוריה 'אל חזור'), ושהצ'קליסט מוסיף אזהרת "כיוון התקנה" (warning) כשהקו כולל
  שסתום כזה. severity=warning → אפס השפעה על criticalOpen; deep_audit symmetry לא נגעה.
- תקלה שהוזרקה: `_isDirectionalDevice` — קטגוריה→'MUT', name-tokens→'MUTx/MUTy'.
- תוצאה: אדומה ✅ — 4 בדיקות-סימון נכשלו (כלפה/ביוב/אלכסוני/warning); "not flagged" עבר.
- ביטול → ירוק ✅ (B11 + auto_compliance + full_compliance + deep_audit).
- מסקנה: הזיהוי load-bearing. **חלקי במכוון** — זו אזהרה, לא אכיפה. **אכיפת-כיווניות
  מלאה** (port ל-ConnectorEnd + חיפוש-מכוון + הרפיית invariant-הסימטריה) היא שינוי-
  ארכיטקטוני שמחכה להחלטת-עיצוב (task #20).

## install_engine — אזהרת שובר-ואקום לברז-גן (E7/B10) — 2026-06-08

- **קובץ:** `test/install_engine_b10_test.dart` (חדש).
- **מה עושה:** נועל ש-`lineComplianceChecklist` מסמן קו-אספקה עם ברז-גן (`'ברזי גן'`)
  בבדיקת "שובר-ואקום" (warning, satisfied=false — אין מק"ט VB בקטלוג), ולא מסמן קו
  ללא ברז-גן. severity=warning כדי שלא ישפיע על `criticalOpen`.
- תקלה שהוזרקה: `hasGardenOutlet` → `categoryHe == 'MUT-B10'` (לא מזהה ברז-גן).
- תוצאה: אדומה ✅ — "garden-tap line flagged" + "WARNING/unsatisfiable" נכשלו;
  "non-garden NOT flagged" עבר (אישוש: ללא ברז-גן אין בדיקה).
- ביטול → ירוק ✅ (B10 + auto_compliance + full_compliance + install_plan_coverage).
- מסקנה: זיהוי-הגן load-bearing. **חלקי במכוון** — אין מוצר VB לחווט (task #20).

## lipskey_verified_connections — סריקת מקטינים/פקקים שטוחי-DN (B8) — 2026-06-08

- **קובץ:** `test/install_engine_b8_test.dart` (חדש).
- **מה עושה:** נועל ש-9 מק"טים שקצותיהם שוטחו ל-DN בודד (מצרה/מחבר/פקק) חושפים
  כעת את ה-DN משמם: מקטינים 218568→{50,40}/220316→{40,32}/116680→{50,32}/
  194897→{110,*}/218567→{160}, ופקקים חד-קצה 218569→[110]/218460→[50]/218560→[160]/220315→[40].
- תקלה שהוזרקה #1 (פקק): `218569` ends → [_c('50'),_c('50')] (חזרה ל-2-קצוות שטוח).
- תוצאה: אדומה ✅ — "a cap terminates ONE pipe" נכשל.
- תקלה שהוזרקה #2 (מקטין): `218568` ends → [_c('50'),_c('50')].
- תוצאה: אדומה ✅ — "reducers carry both named sizes" נכשל (חסר 40).
- ביטול שתיהן → ירוק ✅. **סוויטה-מלאה: 1569/1569 ירוק** (אפס רגרסיית-חיבור — אף
  בדיקה לא קידדה את החיבורים-השגויים האלה).
- מסקנה: ה-DN נגזרים משם-המוצר; 2 מקרים עמומים (ברך 40/49, אלקון 32/32 שסוג-הקצה
  לא ברור) הושארו לאישור-אנושי (task #20).

## install_engine — חסם עומס-יתר במחלק (E5/B7) — 2026-06-08

- **קובץ:** `test/manifold_test.dart` מקרה 10 (חוזק מבדיקת-אריתמטיקה לבנייה-אמיתית).
- **מה עושה:** נועל ש-`buildTreeInstallation` חוסם את מספר-הענפים למספר-היציאות
  הפיזי של המחלק; עודף → gaps (התקנה לא-שלמה) + אזהרה; TMTV/איזון רק לענף-מנותב.
- תקלה שהוזרקה: `cap = realTargets.length` (הסרת החסם) ב-buildTreeInstallation.
- תוצאה: אדומה ✅ — "4 ענפים על מחלק 2-יציאות" נכשל: 4 ענפים נותבו (zones>2),
  אין gaps עודף, אין אזהרה.
- ביטול → ירוק ✅ (manifold/zone_tmtv/twenty/auto_compliance, +59).
- מסקנה: החסם load-bearing; מחלק 2-יציאות לא פולט עוד 4 ענפי-פנטום עם ברזי-בטיחות.
- **ניקוי-אגב:** הוסר `mats` מת ב-`_autoAddCompliance` (שריד מ-B5 matsFinal) + import
  מיותר ב-manifold_test → analyze נקי.

## lipskey_verified_connections — מקטיני-DN שטוחים + טמפ'-חריג (B6) — 2026-06-08

- **קובץ:** `test/install_engine_b6_test.dart` (חדש).
- **מה עושה:** נועל (E6) `224156` maxTempC=70 (כמו האחים הזהים 224345/224169), ו-(E3)
  שמסעפי-ההקטנה חושפים את כל ה-DN משמם: 116558→{110,50}, 217533→{75,50}, 218564→{110,50}.
  ה-DN נגזרים מ**שם-המוצר** (מסעף 87° 110/50 וכו') — לא המצאה.
- תקלה שהוזרקה #1 (E6): `224156` maxTempC 70 → 80 (חזרה ל-typo).
- תוצאה: אדומה ✅ — "224156 maxTempC ... (70 not 80)" נכשל.
- תקלה שהוזרקה #2 (E3): `116558` ends → [_c('50'),_c('50'),_c('50')] (שיטוח חזרה).
- תוצאה: אדומה ✅ — "reducing branches expose ALL named DNs" נכשל (חסר 110).
- ביטול שתיהן → ירוק ✅ (B6 + pdf_parity + twenty_products + audit40 + deep_audit, +306).
- מסקנה: הבדיקה תופסת גם סטיית-טמפ' וגם מחיקת-DN.

## install_engine — גלוון מבוסס-קבוצות (E1) + ראש/מזלף-מקלחת טרמינל (E8) — 2026-06-07

- **קובץ:** `test/install_engine_b5_test.dart` (חדש, 8 בדיקות).
- **מה עושה:** (E1) נועל ש-`_galvanicallyDissimilar` דורש רקורד-דיאלקטרי רק בין
  קבוצות-מתכת שונות (נחושת/פליז × פלדה/נירוסטה) — דרך `lineComplianceChecklist`;
  (E8) נועל ש-`flowRole` של ראש-מקלחת/מזלף = fixture (קצה), זרוע/מערבל = connector.
- תקלה שהוזרקה #1 (E1): `_galvanicallyDissimilar` → `copperGroup.length>=2` (הסרת בדיקת iron-group).
- תוצאה: אדומה ✅ — כל 4 בדיקות-E1 נכשלו: פלדה↔פליז, נירוסטה↔פליז, נחושת↔פלדה
  (לא דרשו דיאלקטרי), ונחושת↔פליז (דרש דיאלקטרי בטעות = over-flag).
- תקלה שהוזרקה #2 (E8): הסרת `'ראשי מקלחת','מזלפי יד'` מ-`_terminalCats`.
- תוצאה: אדומה ✅ — ראש + מזלף חזרו ל-connector (2 בדיקות נכשלו); זרוע + מערבל
  נשארו connector (עברו) — מאשר שהזרוע/מערבל לא הושפעו.
- ביטול שתיהן → ירוק ✅ (B5 + auto_compliance + install_engine_safety עברו).
- **תיקון-סדר נוסף (חשף ע"י E1):** `_autoAddCompliance` חישב `mats` *לפני* הזרקת
  מיכל-ההתפשטות מ-פלדה → לא הוסיף רקורד-דיאלקטרי לזיווג פליז↔פלדה שהוא-עצמו יצר.
  עכשיו מחושב `matsFinal` על ה-items הסופיים → הדיאלקטרי מתווסף. מאומת ע"י
  `criticalOpen(60)==0` ב-install_plan_coverage/full_compliance_audit/engine_harness
  (היו אדומים "got 1" לפני התיקון) + בדיקת "hot line auto-adds dielectric".
- מסקנה: שלושה תיקונים load-bearing (גלוון, מקלחת, סדר-הדיאלקטרי); אפס over-flag.

## install_engine — מכשירי-קצה: אחד לקו, אין קצה→קצה (B4) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (קבוצה: terminal devices D1/D3/D5/D6).
- **מה עושה:** נועל ש-`_terminalCats` (סיפונים/מחסומים-גלויים/מחסומי-רצפה/מאספי-רצפה/
  תעלות/ניקוז-גג/מאספים · ברזי מטבח/כיור/קיר/אמבטיה/גן/דלי) הם `flowRole=fixture`
  (קצה בלבד), שאסור שני-טרמינלים על קו (double-trap / שני-ברזים), ושגם מקרה
  נפרד-ע"י-צינור נתפס ברמת-הקו (`buildInstallation` → gap → `isComplete=false`).
- תקלה שהוזרקה #1 (MUT-A, סיווג): הסרת `|| _terminalCats.contains(c)` מ-`flowRole`.
- תוצאה: אדומה ✅ — 4 בדיקות-terminal נכשלו (שני-סיפונים / שני-ברזים / שני-מחסומי-
  רצפה / trap→pipe→trap *מצאו* נתיב) + `audit40` "5 כשלים" (3/15/23/35/39 חזרו למצוא נתיב).
- תקלה שהוזרקה #2 (MUT-B, guard ברמת-קו): `if (terminals.length > 1)` → `> 99`.
- תוצאה: אדומה ✅ — **רק** "separated trap→pipe→trap" נכשל; המקרים הצמודים נשארו
  ירוקים (ה-path-guard תופס אותם) → מוכיח ששני ה-guards נחוצים, לא יתירים.
- ביטול שתיהן → ירוק ✅ (52 בדיקות B4-affected עברו, אפס רגרסיה).
- מסקנה: הסיווג, ה-path-guard וה-line-guard — שלושתם load-bearing.

## install_studio — חיווט בדיקת שיפוע-ניקוז (P3.9) — 2026-06-07

- **שינוי:** UI-wiring בלבד ב-`install_studio_screen.dart` — בלוק הלחץ
  (עלייה אנכית / ירידת לחץ) מסונן כעת ל-`lineIsSupply` בלבד, וקו ניקוז מקבל
  במקומו בלוק שיפוע (סליידרים אורך/מפל → `checkDrainageSlope`).
- **אין פונקציית-עזר חדשה** — הלוגיקה כבר קיימת ונבדקת:
  - `checkDrainageSlope` (pressure_drop): נבדק ב-`pressure_drop_advanced_test`
    גם למקרה תקין (ok) וגם למקרה כושל (bad, < 2% → ok:false) — מקרה-ה-bad הוא
    בעצם "הזרקת התקלה" שמוכיחה שספי ת"י 1205 (2%) נאכף ולא ואקום.
  - `lineIsSupply` (install_engine): קובע אספקה↔ניקוז, מכוסה בעקיפין בשערי
    audit40 / install_engine_safety (חוצה-מערכת).
- **אימות UI:** הודגם חי (build web + דפדפן) — קו ניקוז מציג "שיפוע ניקוז 2.0% —
  תקין (≥2% ת"י 1205)", ריאקטיבי לסליידרים (2.0%→4.6%). צילומי-מסך נשמרו.
- מסקנה: אין פונקציה חדשה לבדוק-מוטציה; ספי ה-2% כבר נעול בבדיקת-המנוע הקיימת.

## install_engine safety — _findBridge חוצה-מערכת (P2.4) + manifoldOutlets טקסונומיה (P2.5) — 2026-06-07

- **קובץ:** `test/install_engine_safety_test.dart` (חדש, 4 בדיקות).
- **מה עושה:** נועל (P2.4) ש-`buildInstallation` לעולם לא מגשר supply↔drainage —
  זוג חוצה-מערכת חייב לצאת כ-gap, לא כגשר; ו-(P2.5) ש-`manifoldOutlets` מסווג
  מחלק לפי טקסונומיית-הקטלוג (`'מחלקים'`), לא לפי ספירת-קצוות.
- תקלה שהוזרקה #1 (P2.5, שער-טקסונומיה): ניטרול
  `if (p.productType != 'מחלק' && p.categoryHe != 'מחלקים') return 0;` ב-`manifoldOutlets`.
- תוצאה: אדומה ✅ — "tee 116565 NOT a manifold" נכשל (החזיר 3 במקום 0).
  מחלקים אמיתיים (4/2/4) + צינור (0) נשארו ירוקים — הניטרול לא נוגע בהם.
- תקלה שהוזרקה #2 (P2.4, שתי שכבות-ההגנה): ניטרול גם ה-guard
  `if (shared.isEmpty) return null;` וגם פילטר ה-`canConnect` ב-`_findBridge`.
- תוצאה: אדומה ✅ — "never bridges supply↔drainage" נכשל עם **1600 גשרים
  חוצי-מערכת**. החזרת שכבה אחת בלבד → ירוק.
- ביטול שתיהן → ירוק ✅ — `+4 All tests passed`.
- מסקנה: P2.5 — שער אמיתי שתופס היפוך-סיווג (tee↔מחלק). P2.4 — הבדיקה אוכפת
  end-to-end את אי-חציית-המערכת; ה-guard הוא שכבת-בטיחות יתירה התואמת את ה-BFS
  (probe: 0/3600 ניתנים-להגעה היום, אז הגנה-בעומק ולא תיקון-דליפה-חי).

## install_engine hardening — kBspInchToMm + insertAt guard (B1) — 2026-06-07

- **קובץ:** `test/install_engine_hardening_test.dart` (חדש, 3 בדיקות).
- **מה עושה:** נועל (1) את `kBspInchToMm` — מקור-האמת היחיד לטבלת BSP אינץ׳→מ"מ
  שאוחד מ-3 עותקים מועתקים-ביד (install_engine `_minBoreMmOf` · pressure_drop
  `_boreMeters` · related_info `engineeringSpecFor`); ו-(2) את ה-guard ב-
  `_autoAddCompliance.insertAt` שמונע קריסת `clamp(1,0)` על קו חד-פריטי.
- תקלה שהוזרקה #1 (ערך-קוטר): `kBspInchToMm` `'1/2': 15` → `'1/2': 14`.
- תוצאה: אדומה ✅ — `at location ['1/2'] is <14> instead of <15>` (בדיקת הטבלה-המדויקת).
- תקלה שהוזרקה #2 (השבתת guard): `if (items.length < 2) return;` → `if (items.length < 0) return;`.
- תוצאה: אדומה ✅ — `buildInstallation([oneSupplyProduct], autoCompliance)` זרק
  `ArgumentError:<Invalid argument(s): 1>` (בדיוק קריסת ה-clamp שה-guard מונע);
  הבדיקה ציפתה `return normally`.
- ביטול שתיהן → ירוק ✅ — `+3: All tests passed!`.
- מסקנה: הבדיקה חזקה — תופסת גם סטיית ערך-בודד בטבלת-הקוטר המאוחדת וגם הסרה של
  ה-guard (רגרסיית-קריסה אמיתית), לא רק happy-path.

## cheaperAlternativesAcrossCatalog (T1) — 2026-06-04

- **קובץ:** `test/cheaper_alternatives_test.dart`
- **מה עושה:** סורק את `kHomeProductBrands` (proto §1b HOME_PRODUCTS) ומחזיר לכל מוצר את החלופה הזולה ביותר שמתחת למחיר ההמלצה; אוכף ≥3 חלופות, כל `altPrice<recPrice`, `savings>0`, וסדר-חיסכון יורד.
- תקלה שהוזרקה: `t.price < rec.price` → `t.price > rec.price` (בורר את הטיר היקר במקום הזול).
- תוצאה: אדומה ✅ — `Expected: a value less than <189> · Actual: <329>` (ברז לכיור בחר פרימיום).
- ביטול → ירוק ✅ — All tests passed.
- מסקנה: הבדיקה חזקה — תופסת היפוך של לוגיקת-הסינון המרכזית (זול↔יקר), לא רק קיום פלט.

## gate 117 closeout (v6.11) — full-snapshot parity לפולירול + חוליות — 2026-06-04

- **קבצים:** `test/_polyroll_snapshot.g.dart` (774) · `test/_huliot_snapshot.g.dart` (170).
- **מה עושים:** snapshot lock על כל nameHe+page של כל מק"טי הקטלוג.
- תקלה שהוזרקה (פולירול): `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
  תוצאה: `Polyroll snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- תקלה שהוזרקה (חוליות): `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
  תוצאה: `Huliot snapshot drift (1)` אדום ✅; ביטול → ירוק ✅.
- מסקנה: ה-snapshots תופסים שינוי-תו-אחד בכל מ-944 המק"טים.

## gate 117 closeout — polyroll_pdf_parity_test — 2026-06-04

- **קובץ:** `test/polyroll_pdf_parity_test.dart` (חדש) — 20 SKUs מ-`kPolyrollCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 20 פיפסים/אביזרים מייצגים.
- תקלה שהוזרקה: `'צינור PPR אספקת מים 20'` → `'…אספקתX…'` (95016002).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 closeout — huliot_pdf_parity_test — 2026-06-04

- **קובץ:** `test/huliot_pdf_parity_test.dart` (חדש) — 13 SKUs מ-`kHuliotCatalog`.
- **מה עושה:** snapshot lock על nameHe+page+brand של 13 ברכים/הגבהות/מכסים.
- תקלה שהוזרקה: `'ברך 15° צד אחד חלק 40'` → `'ברך 15X…'` (70041150).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 follow-up — lipskey_hierarchy_parity_test — 2026-06-04

- **קובץ:** `test/lipskey_hierarchy_parity_test.dart` (חדש) + `lib/data/chip_hierarchy.dart`.
- **מה עושה:** אוכף ש-parseChips מחזיר type+path תקינים ל-18 SKUs מייצגים של ליפסקי
  (תנאי-קדם להפעלת `_HierarchyChips` במקום `_NameWords`).
- תקלה שהוזרקה: `'מיכל הדחה'` → `'מיכלX הדחה'` ב-`_kCompoundTypes`.
- תוצאה: אדום ✅ — SKU 152785 (`מיכל הדחה טיטאן לבן`) נכשל ב-`type expected "מיכל הדחה"`.
- ביטול → ירוק ✅ — 18/18.
- מסקנה: הטסט אוכף את ה-compound-type lookup; שינוי שובר את שיוך-ה-type הגורף.

## gate 117 — lipskey_pdf_parity_test (מחסומי רצפה תיקניים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runFloorTrapGroup` (8 SKUs, עמ' 26–27).
- תקלה שהוזרקה: `'מחסום תיקני 140/50 פתוח'` → `'מחסום תיקניX 140/50 פתוח'` (218681).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (צינורות) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runPipeGroup` (57 SKUs, עמ' 47–48).
- תקלה שהוזרקה: ב-fixture 116101 color `'אפור'` → `'אפורX'`.
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אביזרי תבריג) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runScrewOnGroup` (43 SKUs, עמ' 20–23).
- תקלה שהוזרקה: `'מחבר כפול תבריג 32/32'` → `'מחבר כפולX תבריג 32/32'` (116209).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (אטמים/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runGasketPlugGroup` (17 SKUs, עמ' 36–37).
- תקלה שהוזרקה: שינוי `'אטם לכוס 2"'` ל-`'אטם לכוסX 2qq'` (506525).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מאספים/כיסויים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runCollectorGroup` (19 SKUs, עמ' 30–33).
- תקלה שהוזרקה: `'רשת פנימית עגולה אפור'` → `'…אפורX'` (661360).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מצמדים/מצרות/פקקים) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runConnectorGroup` (21 SKUs, עמ' 44–45).
- תקלה שהוזרקה: `'כובע אויר 110'` → `'כובע אוירX 110'` (120311).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מסעפים שקע-תקע) — 2026-06-04

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — `_runInsertionBranchGroup` (13 SKUs, עמ' 42).
- תקלה שהוזרקה: `'מסעף 45° 40/40'` → `'מסעף 45X 40/40'` (220305).
- תוצאה: אדום ✅; ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (ברכיים שקע-תקע) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה רביעית (`_runInsertionBendGroup`)
- **מה עושה:** fixture של 15 SKUs של ברכיים שקע-תקע (עמ' 40–41).
- תקלה שהוזרקה: `'ברך 87° 75'` → `'ברך 87X 75'` (116033).
- תוצאה: הבדיקה אדומה ✅.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מחסומים גלויים) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שלישית (`_runVisibleTrapGroup`)
- **מה עושה:** fixture של 32 SKUs מקטלוג ה-PDF (עמ' 8–15) — אגן 1.25", מטבח 2", אמריקאי 1.5"/2", צד, מאריכים+אביזרים.
- תקלה שהוזרקה: שינוי `'מחסום אמריקאי 1.5"'` → `'מחסום אמריקאיX 1.5"'` (218495).
- תוצאה: הבדיקה אדומה ✅ — `SKU 218495 · מחסום אמריקאי 1.5"`.
- ביטול → ירוק ✅.

## gate 117 — lipskey_pdf_parity_test (מושבי אסלה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` — קבוצה שנייה (`group('… מושבי אסלה')`)
- **מה עושה:** fixture של 26 SKUs מקטלוג ה-PDF (עמ' 53–55) + טסט פנטומים. אוכף `nameHe / color / qtyPack / qtyPallet / categoryHe / page` לכל מושב אסלה.
- תקלה שהוזרקה: `sed 's/מושב אסלה כרמל סגירה רכה לבן/מושב אסלה כרמלX סגירה רכה לבן/'` — שינוי שם דגם כרמל.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 195505 · מושב אסלה כרמל סגירה רכה לבן`.
- ביטול → ירוק ✅ — 51/51.
- מסקנה: הטסט תופס שינויי-שם גם בקטגוריה השנייה, באותה רמת דיוק.

## gate 117 — lipskey_pdf_parity_test (מיכלי הדחה) — 2026-06-03

- **קובץ:** `test/lipskey_pdf_parity_test.dart` (חדש)
- **מה עושה:** fixture של 23 SKUs מקטלוג ה-PDF (עמ' 50–52) + טסט פנטומים. אוכף `nameHe / color / qtyPack / categoryHe / page / dims` של כל מיכל הדחה.
- תקלה שהוזרקה #1: `sed 's/מיכל הדחה ספיר לבן/מיכל הדחה ספירX לבן/' lib/data/lipskey_catalog.dart` — שינוי שם דגם של ספיר.
- תוצאה: הבדיקה אדומה ✅ — נכשלה ב-`SKU 124848 · מיכל הדחה ספיר לבן`.
- ביטול → ירוק ✅ — 24/24.
- מסקנה: הטסט תופס שינויי-שם ב-nameHe מקצה-לקצה, גם תווים בודדים.



- **קובץ:** `lib/data/polyroll_catalog.dart:609`
- **מה עושה:** factory function — יוצר `LipskeyCatalogProduct` לצינור PPR מיזוג אוויר (Aquatherm blue pipe). עוטף `_ppr()` עם קבועים ספציפיים ל-AC.
- **בדיקה:** `test/polyroll_catalog_test.dart` — ודא שמוצר AC Blue Pipe מופיע ב-`kPolyrollCatalog` עם SKU תקין.
- מסקנה: factory בלי לוגיקה — בדיקה מינימלית מספיקה (SKU קיים, קטגוריה נכונה)

## §22.H photo-only routing (_pprSpecFor: kPprElectrofusion + kPprTools) — 2026-05-31
- תקלה שהוזרקה #1: p72 routing `90→45` (כל ברך 90° מקבל spec של 45°).
- תוצאה: §22.H אדום ✅ (תפס את ה-swap, לא רק "לא page").
- תקלה שהוזרקה #2: p91 routing `תותב die→driver`.
- תוצאה: §22.H אדום ✅.
- מסקנה: הבדיקה חזקה — אחרי שחיזקתי מ-"not page + exists" ל-מיפוי-ספציפי
  פר-תת-סוג. הגרסה החלשה הראשונה הייתה עוברת את שני ה-swaps.

## §21 chip parser — angle vs size (parseChips/kChipLevel2Shape) — 2026-05-31
- תקלה שהוזרקה: החזרת bare '45','90' ל-kChipLevel2Shape (המצב הקודם).
- תוצאה: §21 angle test אדום ✅ — הקוטר 90mm נגנב לתא ה-shape, size=null.
- מסקנה: הבדיקה חזקה — תופסת גם את ה-collision של זווית-מול-קוטר וגם את
  הבליעה של sizeRe. הוזרק וחזר ירוק אחרי שחזור.

## §21 multi-word chip compound (_l3Compounds) — 2026-06-01
- תקלה שהוזרקה: מחיקת 'למיקום נקודת מים' מ-_l3Compounds.
- תוצאה: §21 multi-word test אדום ✅ — הביטוי התפזר ל-[מים, למיקום, נקודת].
- מסקנה: הבדיקה חזקה — מאמתת גם נוכחות הביטוי כ-chip אחד וגם היעדר פיזור.

## §21.B unit-fold — recoverability E2E (parseChips / _kChipUnits) — 2026-06-01
- תקלה שהוזרקה: הסרת ענף ה-unit-fold (`if (_kChipUnits.contains(t))`) מ-parseChips.
- תוצאה: §21.B test אדום ✅ — `מזוודת ריתוך קטנה 20-63 מ"מ` איבד את "מ"מ"
  (lost: מ"מ), השחזור מ-set-המילים נכשל.
- מסקנה: הבדיקה חזקה — תופסת כל נפילת token (לא רק מ"מ): משווה את כל set-המילים
  מקור↔שחזור על כל kPolyrollCatalog. הוזרק וחזר ירוק אחרי שחזור הענף.

## §21.C chip level labels (levelLabelOf / מידה anchor) — 2026-06-01
- תקלה שהוזרקה: שינוי `if (i == 0 && level5 != null) return 'מידה';` → return ''.
- תוצאה: §21.C test אדום ✅ — ציפי-הגודל בכל הקטלוג קיבלו label ריק, הבדיקה
  פלטה רשימה ארוכה של "size chip 'X' → '' (expected מידה)".
- מסקנה: הבדיקה חזקה — לא רק מאמתת קיום של אחת מ-5 תוויות אלא מצמידה את ציפ
  הגודל ספציפית ל-"מידה" (העוגן ל-leaf, כך שמשתמש תמיד יודע מה ה-bottom-of-chain).
  הוזרק, חזר ירוק אחרי שחזור.

### lib/data/polyroll_catalog.dart — 2026-06-01T15:00:31+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'מק"ט חוליות': sku,/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## _sl — Huliot SmartLock factory (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:61`
- **מה עושה:** factory — בונה `LipskeyCatalogProduct` עם brand='חוליות' ומזריק
  `יצרן='חוליות'` + `מק"ט חוליות'=sku` ל-dims אוטומטית (§22.I by-construction).
- תקלה שהוזרקה: הסרת `'יצרן': 'חוליות'` משדה ה-fullDims.
- תוצאה: הבדיקה הייתה אדומה ✅ — `§22.I every Huliot product carries יצרן`
  נכשל עם 170 קוויי "[no יצרן]".
- שחזור: byte-exact (החזרת השורה). הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת §22.I פר-מוצר. ה-factory pattern מבטיח שאי-אפשר
  לשכוח יצרן/מק"ט גם כשמוסיפים 170 מוצרים ב-batch.

## _brandDir — brand→dir mapping (lib/data/lipskey_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/lipskey_catalog.dart:49`
- **מה עושה:** static helper — ממפה brand string לתיקיית assets:
  פולירול→polyroll, חוליות→huliot_smartlock, אחר→lipskey.
- **בדיקה חיזק (2026-06-01 — סשן 100%):** נוסף `§22-Huliot every product
  asset resolves to assets/huliot_smartlock/` ב-spec_assets_test.dart שסורק
  כל imageAssets/specImageAssets של 170 מוצרי Huliot. בנוסף `§22-Huliot
  every Huliot page asset exists on disk` מוודא קיום פיזי.
- mutation_verify.sh ראשוני (תיעד את החולשה) → אחרי הוספת ה-test, mutation_verify
  שני (`s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed|`) → אדום ✅.

### availableLensesForSet — 2026-05-31
- תקלה שהוזרקה: `>= smartTreeMinFraction` → `> smartTreeMinFraction` (סף עץ-חכם)
- תוצאה: הבדיקה הייתה אדומה ✅ ("exactly at the fraction → smart-tree included" נפל — 0.25 > 0.25 = false)
- תקלה שנייה: `if (products.any((p) => famSkus.contains(p.sku)))` → `if (true)` (variant תמיד)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant lens follows injected family membership" נפל — without-family ציפה לא-variant)
- מסקנה: הבדיקה חזקה — תופסת גם את גבול הסף (>=/>) וגם את תלות ה-variant במשפחה.

### groupByLens — 2026-05-31
- תקלה שהוזרקה: ב-smartTree case, `smartProductForSku(p.sku)` → `?? smartProductForSku(kLipskeyCatalog.first.sku)` (unmapped לא נזרק)
- תוצאה: הבדיקה הייתה אדומה ✅ ("smart-tree keeps ONLY mapped" — kept != mapped)
- תקלה שנייה: ב-variant case, `singletons.add(...)` → הוסר (singletons נזרקים)
- תוצאה: הבדיקה הייתה אדומה ✅ ("variant nothing dropped" — total != copper.length)
- מסקנה: הבדיקה חזקה — תופסת גם drop של unmapped ב-smartTree וגם drop של singletons ב-variant.

### cardReadinessScore (raised bar, 9 dims) — 2026-06-01
- שינוי: הנוסחה הורחבה מ-5 ל-9 ממדים (spec25/compat20/תקן12/התקנה13/קבלה5/תאימות5/מאתר5/מחיר5/וריאנט10), max 100.
- תקלה שהוזרקה: `score += 25` (spec) → `score += 0`.
- תוצאה: הבדיקה הייתה אדומה ✅ ("rich spec+connectable PPR hits top band" נפל — PPR ירד מ-95 ל-70 < 80).
- מסקנה: הבדיקה החדשה ("raised bar") חזקה — תופסת ירידת משקל ליבה. בנוסף: endpoint נשאר נמוך, ואין ממד יחיד שמגיע ל-100 (דורש רוחב).

### cardReadinessScore (quantity-aware) — 2026-06-01
- שינוי: הציון מודד עכשיו *כמות-ידע*, לא רק נוכחות בינארית. ממדים מדורגים: עומק-נתונים `p.dims.length` (≥8→15/4-7→10/1-3→5), חיבורים (≥20→18/≥5→12/>0→6), טיפים/קבלה/תאימות מדורגים לפי כמות. spec ירד 25→20, מחיר/מאתר ירדו.
- מניע (משוב משתמש): "לא תתסתכל על הכמות ידע שיש לו" — צינור PPR פייזר (dims=11, העשיר ביותר) קיבל ~75 בגלל compat=0; עכשיו 80 מצוין.
- תקלה שהוזרקה: ענף ה-dims `: 0` (אפס dims) → `: 50` (בונוס שמן ל-0 ידע).
- תוצאה: 2 בדיקות אדומות ✅ — "fixture endpoint (toilet seat) stays low" (אסלה קפצה 16→66 > 45) וגם "no single dimension reaches 100".
- מסקנה: הבדיקות תופסות ניפוח שגוי של מוצרים חסרי-ידע. אומת: PPR אספקה 98 · PPR פייזר 80 · אסלה 16 · סיפון כיור 63.

### cardReadinessScore (composite breadth+depth) — 2026-06-01
- מניע (משוב משתמש): "שישקף גם וגם משולב … ויתן ציון משוכלל משניהם" — ציון אחד שמשלב שני צירים.
- שינוי: הנוסחה פוצלה לשני תת-ציונים (כל אחד ≤50) ומוחזרים ב-record:
  • רוחב (breadth) — נוכחות משוקללת של *סוגי* ידע שונים (spec10/חיבור8/dims6/תקן6/התקנה5/וריאנט4/טיפים4/קבלה3/תאימות2/מאתר1/מחיר1).
  • עומק (depth) — *כמות* בתוך הסוגים המדידים (dims ≥8→18/4-7→12/1-3→6 · חיבורים ≥20→16/≥5→10/>0→5 · טיפים/קבלה/תאימות מדורגים).
  composite = breadth + depth (cap 100). מוצר רחב-ושטחי או עמוק-וצר נופל לאמצע; רק רחב+עמוק מגיע ל-מצוין.
- תוצאות מאומתות: PPR אספקה 99 (b49/d50) · PPR פייזר 75 (b41/d34, נענש על 0 חיבורים בשני הצירים אך מקבל קרדיט מלא על 11 dims) · אסלה 15 (b11/d4) · סיפון 55 (b40/d15). Lipskey top: 29 מוצרים ≥80, max 85 (צינורות גמישים b50/d35).
- תקלה שהוזרקה: `var score = breadth + depth` → `var score = breadth` (התעלמות מעומק).
- תוצאה: 2 בדיקות אדומות ✅ — "composite == breadth + depth" וגם "raised bar PPR hits top band" (PPR צנח ל-49<80).
- מסקנה: הבדיקות נועלות גם את הזהות composite=breadth+depth וגם את שילוב שני הצירים בפועל.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-01T19:21:42+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יצרן': 'חוליות',/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_catalog.dart — 2026-06-01T19:22:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brand == 'חוליות') return 'huliot_smartlock';|// removed for mutation test|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring (v5.62) — 2026-06-02
- שינוי: 17 מק"טי חוליות נוספו כ-SmartBrand ל-4 כרטיסי-ניקוז (floorDrain+7,
  basinTrap+3, kitchenDrain+4, washingMachineDrain+3). כיסוי עץ-חכם 293→310.
- תקלה שהוזרקה: מק"ט חוליות מחובר '70124599' → '00000000' (לא קיים בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — smartproduct_contract "Huliot … wired into the
  smart-tree" (spot-check sku→card + card-has-Huliot-brand) וגם "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הקישור מוגן דו-שכבתית — test/smartproduct_contract_test + harness
  lib/test_harness/tests/catalog.dart (צעד 77).

### Huliot smart-tree wiring batch 2 (v5.63) — 2026-06-02
- שינוי: +62 מק"טי חוליות (צנרת PP) כ-SmartBrand ל-4 כרטיסים: pvcPipe+7,
  drainageElbow+27, drainageFittings+20, visibleTrap+8. כיסוי 310→372, חוליות 79/170.
- תקלה שהוזרקה: מק"ט ברך מחובר '70033960' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: הכיסוי המורחב מוגן; כל 8 הכרטיסים נבדקים שיש בהם מותג חוליות + spot-check.

### Huliot smart-tree wiring batch 3 (v5.64) — 2026-06-02
- שינוי: +38 מק"טי חוליות כ-SmartBrand: roofCollector+8 (מאספים), drainChannel+10
  (AQUA SLIM), floorCover+20 (מכסים/רשתות). כיסוי 372→410, חוליות 117/170.
- תקלה שהוזרקה: מק"ט AQUA SLIM מחובר '60150331' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 11 הכרטיסים מוגן (spot-check + ≥117 ממופים).

## _huliotImageFor — per-family crop routing (lib/data/huliot_smartlock_catalog.dart) — 2026-06-01
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart:46`
- **מה עושה:** switch פר-עמוד (11-43) שמנתב כל מוצר Huliot ל-crop פר-משפחה
  `sml_p{NN}_{a|b|c|d}.jpg` לפי keyword ב-nameHe. החליף את ה-fallback של
  עמוד-מוקטן (`page_NN.jpg`) ב-88 תמונות מוצר חתוכות (§17.1).
- **בדיקה:** `test/spec_assets_test.dart §17.1-Huliot every product front
  image exists + is a real crop` — מאמת (א) imageAsset קיים על דיסק; (ב) אינו
  `/pages/page_` (פרט לעמ' 27 AQUA SLIM). סורק 170/170.
- תקלה שהוזרקה: שינוי `case 11:` להחזיר `'page_11.jpg'` במקום `_p(11,'a')`.
- תוצאה: §17.1-Huliot אדום ✅ — "still on whole-page fallback" עם 7 מוצרי
  צינור (עמ' 11) שחזרו ל-page image.
- שחזור: החזרת `_p(11,'a')`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression לעמוד-מוקטן (הפרת §17.1). זו
  בדיוק התלונה של המשתמש ("איפה תמונות לפי פרוטוקול") — עכשיו test-guarded.

## parseChips — Huliot vocab + parser-skip cosmetics (lib/data/chip_hierarchy.dart) — 2026-06-01
- **קובץ:** `lib/data/chip_hierarchy.dart`
- **מה השתנה:** (א) tokenizer מדלג על '-', '—', '/' (separators קוסמטיים).
  (ב) ב-loop, raw token עם parens עוטפות → strip לפני vocab lookup.
  (ג) מספר נומרי אחרי `l5` נצמד אליו ב-space (היה ?? = pin to first only).
  (ד) kChipTypes/Level2/Level3 + _l3Compounds הורחבו ב-100+ tokens של Huliot.
- **בדיקות:**
  - `test/spec_assets_test.dart §21.B-Huliot every product fully recoverable
    via parseChips` — סורק 170/170; recon = type + path + leftover; כל מילה
    בשם (אחרי norm + skip '-/—//') חייבת להופיע ב-recon; leftover חייב להיות
    ריק. עבר 170/170.
  - `test/spec_assets_test.dart §21.C-Huliot every visible chip carries
    semantic level label` — כל chip ב-path מקבל אחת מ-{חיבור/צורה/תכונה/
    תבריג/מידה}; size chip תמיד 'מידה'. עבר.
- **תקלות שהוזרקו:**
  - הסרת ענף ה-`(raw.startsWith('(') && raw.endsWith(')'))` (paren-strip) →
    §21.B-Huliot אדום ✅ עם 12 מקרים `leftover: סיפון` (כש-(סיפון) לא matchen).
  - שינוי `l5 == null ? t : '$l5 $t'` → `l5 ??= t` (multi-numeric drop) →
    §21.B-Huliot אדום ✅ עם `missing: 3000/4000` ב-7 מוצרי צינור.
- שני המוטציות שוחזרו → ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת כל regression בפרסר שמשפיעה על תכולת ה-card
  (משאיר מילה מאחור = מילה מתאדה מה-UI = הפרת §14.E).

## FinderGroup 'דלוחין SmartLock' — finder_screen.dart — 2026-06-01
- **קובץ:** `lib/screens/finder_screen.dart:71` (אחרי 'צנרת PPR')
- **מה עושה:** קבוצת home שמאחדת 17 קטגוריות kSml* תחת label אחד
  ("🟢 דלוחין SmartLock"); 170 מוצרי Huliot נספרים תחתיה במסך הבית.
- **בדיקה:**
  - `test/wiring_test.dart` "named groups are pairwise disjoint" — מאמת
    שאין קטגוריה משותפת לשתי קבוצות. תפס שה-'סיפונים' הופיע גם בניקוז וגם
    ב-SmartLock; כשעדכנתי `kSmlSiphons = 'סיפונים SmartLock'`, הבדיקה עברה ירוק.
  - `test/finder_group_icons_test.dart` "every group has dedicated icon/image" —
    מאמת שלכל קבוצה יש Material icon ייעודי + תמונה ייעודית.
- תקלה שהוזרקה: החזרת `kSmlSiphons = 'סיפונים'` (הערך הקודם).
- תוצאה: שני בדיקות אדומות ✅ — `pairwise disjoint` שיכפל את 'סיפונים'
  בין ניקוז ו-SmartLock; `paranoid 12-check` לא נפגע (catRoot mapping של
  הבדיקה מסתמך על categoryHe).
- שחזור: החזרת `'סיפונים SmartLock'`. הרצה חוזרת ירוקה ✅.
- מסקנה: הבדיקה חזקה — תופסת collision של category-set בין שתי קבוצות
  finder. זו ההגנה היחידה שמבטיחה ש-finder.home לא מציג מוצר באותו פעם
  באף one of two distinct groups (UX duplicate).

### lib/data/related_info.dart — 2026-06-02T13:07:53+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (p.brand == 'חוליות') return (emoji: '🟢', label: 'דלוחין SmartLock');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T13:42:06+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `/'יח׳\/ארגז': '90', 'יח׳\/משטח': '3,780'}/d`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:17:05+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#if (has('מוגבהת')) return _p(30, 'a');#// mutated#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T14:37:52+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s#return _p(27, 'a');#return 'page_27.jpg';#`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### system_division (productDivisionSystems · filterBySystem · nodeHasSystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** ליבת חלוקת מים/שפכים (בנצי #1) — סיווג מוצר/צומת-עץ ל-WaterSystem.
- תקלה שהוזרקה #1: ב-`productDivisionSystems` הפכתי את fallback ה-PPR מ-`supply` ל-`drainage`.
- תוצאה: אדום ✅ — `'PPR ... → supply'` נתפס (הכלל שהמשתמש קבע: PPR=מים נקיים).
- תקלה שהוזרקה #2: ב-`nodeHasSystem` הסרתי את שורת ה-`_fixtureTitles` (מתקנים
  לא יופיעו בשני הצדדים).
- תוצאה: אדום ✅ — `'fixture (אסלות) shows under BOTH systems'` נתפס (כלל option 2).
- תקלה שהוזרקה #3: ב-`filterBySystem` החזרתי `list` גם כש-system≠null (ביטול הסינון).
- תוצאה: אדום ✅ — `'supply filter keeps only supply'` נתפס.
- שחזור: שלושתן הוחזרו → הרצה ירוקה (9/9) ✅.
- מסקנה: הבדיקה חזקה — מכסה את שלושת הכללים (PPR=נקיים, מתקנים בשני צדדים, סינון ממשי).

### system_division — פאזה 2b (smartProductSystems · filterSmartBySystem) — 2026-06-02
- **קובץ:** `lib/logic/system_division.dart` · בדיקה: `test/system_division_test.dart`
- **מה עושה:** סינון עץ-חכם — ממפה את ה-SKU של מותגי ה-SmartProduct חזרה לקטלוג
  כדי לסווג כל מוצר-חכם למערכת (לא-פתיר → נשאר בשני הצדדים).
- תקלה שהוזרקה A: ב-`smartProductSystems` שיניתי `p.sku == sku` ל-SKU שלעולם
  אינו קיים (אף התאמה → כל מוצר "לא-פתיר").
- תוצאה: אדום ✅ — `'brand-SKU mapping resolves'` **וגם** `'filter discriminates'`
  נתפסו (הכול הפך ל"בשני הצדדים" → sup==dr==all).
- תקלה שהוזרקה B: ב-`filterSmartBySystem` החזרתי `list` תמיד (no-op, ביטול הסינון).
- תוצאה: אדום ✅ — `'filter discriminates — supply/drainage pools differ'` נתפס.
- שחזור: שתיהן הוחזרו → 14/14 ירוק ✅.
- מסקנה: הבדיקה חזקה — מכסה מיפוי-לא-no-op, אי-היעלמות (supply∪drainage מכסה הכול),
  והבחנה ממשית (48 נקיים · 58 שפכים מתוך 81; 23 supply-only · 33 drainage-only).

### lib/data/huliot_smartlock_catalog.dart — 2026-06-02T18:16:15+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|return 'spec_$img';|return 'spec_sml_p99_z.jpg';|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/spec_assets_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Huliot smart-tree wiring batch 4 (v5.72) — 2026-06-02
- שינוי: +9 מק"טי חוליות כ-SmartBrand: tools+4 (חותכים+מפתחות), drainageFittings+5
  (אומי-חיבור). חוליות 117→126/170. הנותרים (~44) = אביזרי-סיפון (SmartAcc), לא כרטיסים.
- תקלה שהוזרקה: מק"ט חותך מחובר '79904070' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 12 הכרטיסים מוגן (spot-check + ≥126 ממופים).

### _huliotImageForCrop — R2-fallback helper extraction (v5.80) — 2026-06-02
- **קובץ:** `lib/data/huliot_smartlock_catalog.dart`
- **מה עושה:** ה-routing הקנוני (per-page tag mapping) חולץ ל-`_huliotImageForCrop`.
  `_huliotImageFor` עכשיו מחזיר `page_NN.jpg` כברירת-מחדל (R2-fallback)
  כל עוד `_routeCropDisabled = true`. כשהדגל יוסר → חוזר לקרוא ל-helper הקנוני.
- תקלה שהוזרקה: `s|return 'page_\${page.toString().padLeft(2, '0')}.jpg';|return null;|`
  (לדמות מצב שבו ה-fallback בעצמו נכשל).
- תוצאה: §17.1-Huliot אדום ✅ — `${p.sku} → null imageAsset`.
- מסקנה: ה-guard המוקל ("exists") עדיין תופס נפילה מוחלטת, ולא רק crop-vs-page.

### Huliot smart-tree wiring batch 5 — spare-parts card (v5.78) — 2026-06-02
- שינוי: כרטיס חדש `smlSpareParts` עם 44 מק"טי אביזרי-סיפון/מחסום כ-SmartBrand.
  כיסוי חוליות 126→**170/170 (100%)**.
- תקלה שהוזרקה: מק"ט אטם מחובר '67750440' → '00000000' (לא בקטלוג).
- תוצאה: 2 בדיקות אדומות ✅ — "Huliot … wired into the smart-tree" + "every
  SmartBrand.sku is a real catalog SKU".
- מסקנה: כיסוי 13 הכרטיסים מוגן (spot-check + ≥170 ממופים).

### lib/logic/install_kit.dart — 2026-06-02T20:25:13+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (p.brand == 'חוליות')|if (p.brand == 'מותג-שלא-קיים')|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/polyroll_e2e_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### Unified-catalog reads (v5.90) — 2026-06-03
- איחוד שלושה תיקונים על origin (עבודת v5.85–87, יושמה-מחדש אחרי ש-origin התקדם ל-v5.89):
  כרטיס-ריק (אחים מ-kCatalogProducts + guard), חיפוש-מק"ט (matchProducts על המאוחד),
  מועדפים/שורת-עגלה (kCatalogProducts).
- אימות: cartLineDisplay('lip:64032300') → שם-קטלוג ולא fallback;
  catalogProductMatchesQuery על kCatalogProducts מוצא 64032300, על kLipskeyCatalog ריק.
- נשאר Lipskey בכוונה: searchSuggestions (autocomplete) + ספירת-מתכנן.

### lib/data/chip_hierarchy.dart — 2026-06-03T17:46:43+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|if (brandOf(q) != brand) continue;|if (brandOf(q) == brand) continue;|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/huliot_picker_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

## resolveCatTitle / catNodeProductCount (category_division.dart) — 2026-06-03
- **קובץ:** `lib/logic/category_division.dart`
- **מה עושה:** ממפה כותרת-מחלקה (`kDeptCatHeadings.titles`) לצומת-עץ (top-node /
  leaf / synthetic) + סופר מוצרים תחתיו — הבסיס לתצוגת כלים-מול-צנרת (בנצי #1).
- תקלה שהוזרקה: `return null;` בראש `resolveCatTitle` (כל כותרת → לא-נפתרת).
- תוצאה: `category_division_test` אדום ✅ (3 בדיקות נפלו — "does not resolve" +
  flat-products ריקים למים/שפכים/אסלות).
- שחזור: byte-exact מ-backup; הרצה חוזרת 5/5 ירוק ✅.
- מסקנה: הבדיקה חזקה — תופסת מיפוי שבור (כל ערך חייב להיפתר לצומת עם >0 מוצרים, R8).

## דו-מערכתיים בשתי הכותרות (category_division.dart) — 2026-06-03 (v5.97)
- **קובץ:** `lib/logic/category_division.dart` (`kDeptCatHeadings['אינסטלציה']`)
- **מה עושה:** דו-מערכתיים (אטמים/חבקים/עוגנים/סטי-הידוק) רשומים תחת **שתי**
  הכותרות 💧 צינורות מים + 🟤 צינורות שפכים — נגישים מכל כותרת (בנצי #1).
- תקלה שהוזרקה: הסרת בלוק 5 הדו-מערכתיים מכותרת **שפכים**.
- תוצאה: `category_division_test` אדום ✅ (`+5 -1`) — נתפס ע"י הבדיקה החדשה
  "dual-system fittings appear under BOTH מים and שפכים headings (#1)"
  ("אטמים ופקקים missing from צינורות שפכים").
- שחזור: הבלוק הוחזר; הרצה חוזרת 6/6 ירוק ✅.
- מסקנה: הבדיקה חזקה — דורשת שכל דו-מערכתי יופיע בשתי הכותרות (ולא רק באחת).

### contractor_seeds helpers (T0) — 2026-06-04
- helpers: bestStore/fMoney/caToday/budgetLevel.
- אימות: שברתי מפריד-אלפים של fMoney (`% 3 == 0`→`% 3 == 9`) → contractor_seeds_test
  אדום ("Expected ₪9,840 · Actual ₪9840") ✅. שחזור → 8/8 ירוק.
- מסקנה: הבדיקה תופסת רגרסיה ב-helper.

### lib/data/persona_data.dart — 2026-06-03T23:58:26+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s|t.worker == worker && statuses.contains|t.worker != worker \&\& statuses.contains|`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/worker_app_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### ManagerAnalytics — 👔 dashboard derivations (lib/logic/manager_dashboard.dart) — 2026-06-03
- **קובץ:** `lib/logic/manager_dashboard.dart` · בדיקה: `test/manager_dashboard_test.dart`
- **מה עושה:** פורט PURE של `mgrAnalytics()` (@index.html:12081-12126) — `ManagerAnalytics`
  גוזר את 5 ה-mdMetric tiles (openOrders/catalogCount/accessoryCount/availableCount/
  storesLabel) ע"י fold על seed שפורט verbatim (STORES · SYS_ORDERS_SEED · התפלגות
  TREES · STORE_STOCK). כל מספר אומת מול הלולאה החיה ב-index.html (node-replay).
- תקלה שהוזרקה #1: ב-`catalogCount` הפכתי `totalProducts - accessoryCount` →
  `totalProducts + accessoryCount`.
- תוצאה: אדום ✅ — `'📦 catalogCount = non-accessory products = 54'` נפל (350≠54) וגם
  `'catalog + accessory == total'` (ה-split כבר לא ממצה).
- תקלה שהוזרקה #2: ב-`openOrders` הפכתי `o.isOpen` (`stage != 'delivered'`) ל-`!o.isOpen`.
- תוצאה: אדום ✅ — `'🚚 openOrders … = 4'` נפל (0≠4; אף הזמנה לא 'delivered').
- תקלה שהוזרקה #3: ב-`activeStores` הפכתי `where((s) => s.on)` ל-`where((s) => !s.on)`.
- תוצאה: אדום ✅ — `'🏪 stores = … 3/3'` נפל (`storesLabel`="0/3").
- שחזור: שלושתן הוחזרו → 12/12 ירוק ✅.
- מסקנה: הבדיקה חזקה — נועלת כל אחד מ-5 ה-tiles למספר ה-verbatim, וגם את אקסיומת
  ה-split (catalog+acc==total) ואת ה-flow (כל seed stage ∈ ORDER_FLOW). מוטציה בכל
  getter נתפסת. (`contractorCredit`/`mgrCustomerList` = foundation ל-M3, נבדקים גם הם:
  band 30k-120k · דטרמיניסטיות · group-by-buyer aggregation.)

### lib/screens/contractor_tools_sheets.dart — 2026-06-07T05:23:07+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/b.savings.compareTo(a.savings)/a.savings.compareTo(b.savings)/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/cheaper_alternatives_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/logic/ai_hub_logic.dart — 2026-06-07T18:44:40+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int get save => fromPrice - toPrice/int get save => toPrice - fromPrice/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/t3_ghi_rewards_ai_home_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/settings_tree.dart (Wave 6 — מחיקה) — 2026-06-07
- שינוי ה-lib/(logic|data) ב-commit זה = **מחיקת data מת בלבד**: `kSettingsGroups`/`walkSettings`
  (~70 עלים const, 0 צרכנים, הוחלף ע"י מסכי-ההגדרות). אין logic/התנהגות למוטציה — נתון const שהוסר.
- שאר Wave 6 (autoStock→OOS · chat-history cleared-flag · העברת `storeOosProvider` ל-lib/state) ב-
  lib/screens|state; ל-`markOos` המועבר אין בדיקה ייעודית (ההתנהגות נשמרה verbatim בהעברה).
  מכוסה ב-suite הירוק של השער (analyze 0 · tests · build · conformance 7/7 · required-tests).

### lib/state/store_stock.dart — 2026-06-07T19:16:48+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/{...state, name}/{...state}/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/store_stock_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/state/sys_chat.dart — 2026-06-07T23:13:55+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/t.participants.contains(role)/true/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/sys_chat_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/stock_local.dart — 2026-06-08T00:12:00+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/stockDemo() => kStockDemo;/stockDemo() => const <String, String>{};/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/repositories/finance_local.dart — 2026-06-08T00:53:36+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/int budgetTotal() => kBudgetTotal;/int budgetTotal() => 0;/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/repositories_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/screens/profile_screen.dart — 2026-06-08T17:27:45+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/activePersona == null/activePersona != null/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/deep_fix_regression_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/lipskey_smart_data.dart — 2026-06-08T18:59:32+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/אטמים ופקקים/אטמים אומים ופקקים/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/lipskey_category_keys_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.

### lib/data/huliot_smartlock_catalog.dart — 2026-06-08 (manual)
- שינוי: `_routeCropDisabled = true` → `false`, `_specCropDisabled = true` → `false`
- מטרה: הפעלת תמונות-מוצר חתוכות (159 crops כבר ב-assets, WIP v45-v52)
- תוצאה: האפליקציה מציגה sml_pXX_X.jpg במקום page_XX.jpg לכל 170 מוצרי חוליות
- תיקוני gate-32 (spec_assets_test 0→53 PASS):
  - `_huliotImageFor` כעת מחזיר page-fallback (לא null) כשאין crop ספציפי
  - p24 אטם (seal): routing מוחזר null → page_24.jpg (sml_p24_a.jpg לא נוצר ב-crop_huliot.py)
  - `_missingSpecs` set: 11 קבצי spec שלא נוצרו (p11_b, p30_d, p32_a, p36_b, p38_a, p39_b/c, p40_a/c/41_c, p42_a/b/c/d)

### lib/data/product_images.dart — 2026-06-08T21:04:22+00:00 (mutation_verify.sh)
- תקלה שהוזרקה: `s/semanticLabel == null/false/`
- תוצאה: הבדיקה הייתה אדומה ✅ (נתפסה ע"י test/product_image_a11y_test.dart)
- שחזור: byte-exact מ-backup; הרצה חוזרת ירוקה ✅
- מסקנה: הבדיקה חזקה — תפסה את המוטציה.
### 2026-06-09 — מסך-בית חכם / מחיקת 'הכל' (UI-wiring)
- מוטציה 1: שינוי `catalogSectionProvider` ברירת-מחדל `'בית'`→`'מאתר'` → `hard_tests "default catalog landing"` אדום (Expected 'בית', Actual 'מאתר') ✅ נתפס; שוחזר.
- מוטציה 2: הסרת תיקון ה-overflow (`Flexible`/`Expanded` ב-_MiniTile/_SmartTreeCard) → robustness 1/12 RenderFlex overflowed אדום ✅; שוחזר.
- כיסוי: widget_test "בית" smart-home shows wired section blocks · robustness 1/12/18 render · hard_tests default-landing.

### 2026-06-09 — מסך-הבית מסונכרן-הגדרות (UI-wiring)
- מוטציה 1: קיבוע `crossAxisCount: 4` (התעלמות מ-`gridColumns`) → הבית לא מגיב לעמדות-רשת בהגדרות (אומת ויזואלית: gridColumns=2 צריך 2 עמודות) ✅; שוחזר.
- מוטציה 2: `childAspectRatio` במקום `mainAxisExtent` → ב-2 עמודות אריחים ענקיים (חצי-מסך-ריבועי) ✅ נתפס ויזואלית; שוחזר ל-`mainAxisExtent` קבוע.
- מוטציה 3: החזרת `reverse: true` → גלילה הפוכה ב-RTL ✅; שוחזר.
- כיסוי: אימות ויזואלי חי (אין טסט-יחידה ל-layout-metrics; נבדק בעין על :5556).

### 2026-06-09 — server-S2 (rebuild): cache-pattern base (`firestore_cached_repo`)
- מוטציה (ידנית — הסקריפט flaky על restore): נטרול עדכון-ה-cache האופטימי ב-`upsert` (`_cache = _sorted(next)` → `_sorted(_cache)`) → `firestore_cached_repo_test` **-5 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+20 ירוק**.
- כיסוי: 20 טסטים על fake-source — seed-ראשוני · snapshot מחליף+notify · doc פגום מדולג · optimistic מיידי (assert סינכרוני) · כשל-כתיבה לא משחית/זורק · replaceAll/resetToSeed/removeById · empty-ראשון≠מאוחר · roundtrip מיפוי+סדר · provider=local בלי Firebase. (נבנה-מחדש אחרי שה-restart גלגל את הקומיט הלא-דחוף.)

### 2026-06-09 — server-S3 (rebuild): גל הנחיל ×5 (`stock_firebase` כנציג)
- מוטציה (ידנית): נטרול flip-המיקום ב-`move` (`'site' : 'warehouse'` → `'warehouse' : 'warehouse'`) → `stock_firebase_repo_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean (0 markers) → **+10 ירוק**.
- כיסוי-גל: 46 טסטים חדשים (customers 9 · stock 10 · site 13 · finance 11 · catalog-guard 3) — fake-sources, אפס deps; provider=local בלי Firebase בכל דומיין; ה-base עצמו mutation-verified ב-S2.
### 2026-06-10 — lib/logic/input_validators.dart (חדש · #64 נחיל)
- מוטציה: `^05\d{8}$` → `^05\d{7,8}$` (קבלת נייד בן 9 ספרות) → `test/input_validators_test.dart` אדום ("mobile — 9 digits (too short) is invalid": Expected false, Actual true) ✅ נתפס.
- שחזור: regex הוחזר byte-exact; הרצה חוזרת 27/27 ירוקה ✅.
- מסקנה: הבדיקה חזקה — מכסה אורך/קידומת/תווים לכל 5 הוולידטורים (27 cases).
- `lib/data/legal_texts.dart` (חדש · #26): const-strings בלבד (תנאי-שימוש/פרטיות) — אין לוגיקה למוטט; מכוסה עקיף ע"י analyze + legal_screen רנדור.

### 2026-06-10 — server-S1+S4: Auth + Real-time (`auth_state` כנציג)
- מוטציה (ידנית): הסרת אימות-תפקיד-מוכר ב-`rolesFromClaims` (`single is String && known.contains(single)` → `single is String`) → `auth_state_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+24 ירוק**.
- כיסוי-גל: 59 טסטים חדשים (auth_state+login_sheet 41 · chat_firebase 10 · realtime_wiring 8) — fake gateway/sources, אפס deps; ללא-Firebase = byte-identical להיום (signed-out picker · מנועים local).

### 2026-06-10 — server-S5/S6/S8/S9: גל-הסגירה (`offline_order_queue` כנציג)
- מוטציה (ידנית): שבירת FIFO ב-`drainQueue` (`pending.first` → `pending.last` = LIFO) → `offline_order_queue_test` **-2 אדום** ✅ נתפס; שוחזר byte-clean → **+9 ירוק**.
- כיסוי-גל: 25 טסטי-flutter חדשים (queue 9 · push_state 15 · S9.3-pin ב-cache-repo 1) + **85/85 rules-emulator** (S5, רץ אמת מול ה-emulator) + **53/53 functions selftest** (S8, כולל אימות bit-for-bit של dartStringHashCode מול dart run).

### 2026-06-10 — server-gate: דגל-בקאנד default-OFF (`backend.dart`)
- מוטציה (ידנית): הפיכת ברירת-המחדל של הדגל ל-true (`bool.fromEnvironment('USE_FIREBASE_BACKEND', defaultValue: true)`) → `backend_flag_test` **-1 אדום** ✅ נתפס; שוחזר byte-clean → **+1 ירוק**.
- כיסוי: `backend_flag_test` נועל את ברירת-המחדל (demo/_local ללא-define, ללא-Firebase) — ה-live נשאר דמו עד הדלקה מפורשת. 11 אתרי-switch דרך `useFirebaseBackend`.
### 2026-06-10 — lib/data/board_accounts_local.dart + lib/state/board_auth.dart (חדשים · #65 נחיל-לוחות)
- מוטציה: קוד-הכניסה של ran שונה '1111'→'9999' → `test/board_auth_test.dart` אדום (4 בדיקות: login-success/persist/case-insensitive/race-guard — Expected session, Actual null) ✅ נתפס.
- שחזור: byte-exact; הרצה חוזרת 8/8 ירוקה ✅.
- מסקנה: בדיקות-הזהות חזקות — מכסות הצלחה/כישלון/persist/דמו/logout/קוד-החלפה.
- `lib/data/chat_seeds.dart` (חדש · #70/#75): seed-בלבד (שיחות audience) — מכוסה עקיף ע"י בדיקות ה-chat הקיימות + analyze.

### 2026-06-10 — worker-v2 (לוגיקה חדשה ב-lib/state + lib/data/task_skus_local)
- באג-אמיתי שנתפס ע"י בדיקת-שמירה (לא מוטציה מלאכותית): vacation_requests — שתי בקשות באותה אלפית-שנייה קיבלו אותו id (web=דיוק-ms) → החלטה אחת אישרה את שתיהן; הבדיקה 'decision touches ONLY the given id' אדומה → תוקן `_seq` מונוטוני → ירוקה. תיעוד כ-mutation-equivalent (fault אמיתי→red→fix→green).
- task_skus_local.dart: seed-בלבד (מיפוי משימה→מק"טים, DEMO-SEED) — מכוסה ע"י רנדור 'מה להביא' + analyze.

### 2026-06-11 — uid-migration A2+A3 (נחיל Phase A · builder+supervisor)
- **A2 — `currentUidProvider` (`lib/state/auth_state.dart`):** מוטציה — `return ref.watch(authStateProvider).user?.uid` → `return null` → `auth_state_test` קבוצת 'currentUidProvider — A2' **אדום** (signed-in: Expected 'u-42' / Actual null, שורה 422) ✅ נתפס; שוחזר byte-clean → ירוק.
- **A3 — `Order.contractorUid` (`lib/state/orders_engine.dart`):** מוטציה (supervisor) — שבירת ה-preservation ב-copyWith `contractorUid: contractorUid,` → `contractorUid: ''` → `orders_uid_a3_test` 'a stage advance (copyWith) keeps the contractor uid' **אדום** (Expected 'u-9' / Actual '') ✅ נתפס; שוחזר byte-clean (grep-count חזר ל-3) → +8 ירוק.
### 2026-06-11 — lib/data/chat_seeds.dart (#83 threads-ספק · נחיל-קנוני)
- מוטציה: audience 'store'→'worker' על thread-ספק → **שרדה** (חור-כיסוי!) → נוספה בדיקת-נעילה (sys_chat_test: 4 ids חייבים audience 'store') → מוטציה חוזרת **נתפסה** (אדום) → שוחזר → ירוק. לקח: seed-fields שמשפיעים-על-נראות חייבים נעילת-בדיקה.
### 2026-06-11 — personal-v2 #86/#87 (נחיל קנוני · orchestrator)
- **`lib/data/supplier_data.dart` — `deliveredRevenue`:** חור-כיסוי נמצא (אפס בדיקות לשדה) → נוספה בדיקה ל-t9 ('deliveredRevenue counts ONLY delivered orders'). מוטציה — הוספת `|| transit` לסינון → **אדום** (seed: BS-1039 ב-transit, ציפייה 0) ✅ נתפס; שוחזר → 12/12 ירוק.
- **`lib/state/persona_fulfillment.dart` — `courierUser` fromJson:** מוטציה — `j['cu']…` → `null` קבוע → `persona_fulfillment_test` **אדום** (Expected 'noam'/Actual null, round-trip+stamp) ✅ נתפס; שוחזר → 20/20 ירוק.
- **`lib/state/vacation_requests.dart` — back-compat `role`:** מוטציה — ברירת-מחדל decode `'worker'`→`'courier'` → `vacation_requests_test` **אדום** (Expected 'worker'/Actual 'courier' — legacy חייב עובד) ✅ נתפס; שוחזר → 11/11 ירוק.

### 2026-06-11 — חיבור הגדרות-תצוגה בקטלוג (נחיל גל-2 מנה-1)
- **`lib/state/catalog_settings.dart` — `priceWithVat`:** מוטציה — `base*(1+kVatRate)` → `base` קבוע → `catalog_price_units_settings_test` **אדום** (2 assertions: Expected 117/'~₪117', Actual 100/'~₪100') ✅ נתפס; שוחזר byte-clean (cp) → 16/16 ירוק.

### 2026-06-11 — מיון-קטלוג (נחיל גל-2 מנה-2)
- **`catalog_screen.dart`/`catalog_settings.dart` — `sortCatalogProducts` nameAZ:** מוטציה — היפוך ה-comparator (descending) → `catalog_sort_alerts_settings_test` nameAZ **אדום** (['B-200','C-300','A-100'] ≠ ['A-100','C-300','B-200']) ✅ נתפס; שוחזר (cp) → 16/16 ירוק.

### 2026-06-11 — חיבור התראות in-app (נחיל גל-2 מנה-3)
- **`lib/state/worker_notifs.dart` — `boardFeedEnabled`:** מוטציה — זרוע-העובד `=> true` קבוע → `notif_settings_wiring_test` **אדום** (3: personaWorker/master/restore gating) ✅ נתפס; שוחזר (backup) → 14/14 ירוק.

### 2026-06-11 — כלי-AI על דאטה אמיתי (נחיל גל-4 · supervisor)
- **`lib/logic/ai_hub_logic.dart` — `computeStockForecast`:** מוטציה — fold-הצריכה `+ li.qty` → `- li.qty` → `ai_hub_compute_test` **אדום** (5 assertions: rate/urgent/span/on-hand/aggregate) ✅ נתפס; שוחזר (cp, md5 חזר) → 14/14 ירוק.

### 2026-06-12 — הכנת-זהות A8 (נחיל)
- **`lib/state/sys_chat.dart`/`chat_firebase.dart` — `fromUid`:** מוטציה — שבירת כתיבת/round-trip של fromUid → `chat_uid_a8_test` **אדום** (Expected 'u-7'/Actual null) ✅ נתפס; שוחזר → ירוק.

### 2026-06-12 — מדריך users lookup A7 (נחיל)
- **`lib/data/repositories/users_lookup.dart` — predicate-הטלפון:** מוטציה — `== phone` → `!= phone` → `users_lookup_a7_test` **אדום** (4: hit→uid-שגוי · miss→החזיר-uid · role-narrow→null) ✅ נתפס; שוחזר (cp) → 10/10 ירוק.

### 2026-06-13 — בעלות-הזמנה A4-A6 (נחיל)
- **`firestore.rules` — no-steal (`claimOnlySelf`/`unassignedOrMine`):** מוטציה (emulator) — נטרול ל-true → 2 steal-tests **אדום** (25/2) → שוחזר → 27/0.
- **`lib/state/orders_engine.dart` — `claimStore` no-steal:** מוטציה — הסרת ה-guard → 'store אחר לא יכול לגנוב' **אדום** (Expected store-a/Actual store-b) → שוחזר.

### 2026-06-13 — server-swap זהות-לוח seed→Firebase (אני, לא נחיל)
- **`lib/state/board_auth.dart` — `boardSessionFromAuthSnapshot` (helper טהור):** מוטציה — `return null` קבוע בראש ה-helper (מנטרל את כל הגזירה) → `board_auth_server_test` **אדום** `+5 -7` (7 בדיקות שמצפות session: store-claim/each-role/multi-role/no-displayName/sign-in/אינווריאנט/sign-out נפלו; 5 שמצפות null נשארו ירוקות) ✅ נתפס; שוחזר byte-מדויק (cp מגיבוי, **לא** git checkout — שלא לאבד את SW2/SW3) → 12/12 ירוק.

### 2026-06-13 — A9 צ׳אט participantUids (נחיל)
- **`lib/state/sys_chat.dart` — `chatThreadVisibleToUid` (helper טהור):** מוטציה — הסרת סעיף empty-is-visible (`participantUids.isEmpty || participantUids.contains(uid)` → `participantUids.contains(uid)`) → `chat_uid_a9_test` 'an EMPTY participantUids is VISIBLE to anyone (legacy/un-migrated)' **אדום** (Expected: true / Actual: \<false\>, `+5 -1`) ✅ נתפס; שוחזר (cp מגיבוי `/tmp/A9_sys_chat.dart.bak`, **לא** git checkout — שלא לאבד את שדה ה-A9 הלא-מקומט) → `+6` ירוק.
- **`firestore.rules` — `chatThreads` read (membership על participantUids):** מוטציה (emulator) — החלשת ה-read ל-`if isSignedIn();` (הסרת `request.auth.uid in resource.data.get('participantUids', [])`) → 3 בדיקות-chat **אדום** (`a NON-member is DENIED` · `a display ROLE in participants never gates` · `a LEGACY thread matches no uid` — כולן 'Expected request to fail, but it succeeded', chat.test.js:95) → 39/3 fail · שוחזר (cp מגיבוי `/tmp/A9_firestore.rules.bak`) → **42/42/0** ירוק.
- **defect שתוקן (לא מוטציה — באג-אמת):** `rules_test/chat.test.js` החדש חלק `PROJECT_ID = 'demo-buildsmart'` עם `orders.test.js`; `node --test` מריץ את שני הקבצים **במקביל** מול emulator יחיד, ו-`clearFirestore` של קובץ אחד מחק את ה-docs שזרע השני באמצע-בדיקה → ה-`get()` החוצה-מסמך של חוקי chatMessages על thread-האב נכשל ("Service call error") → כשל פלאקי (1-2) בחיוביים תלויי-seed. תיקון: project-id ייעודי `demo-buildsmart-chat` (מבודד namespace, אפס-נגיעה ב-orders). chat-לבד 7/7 דטרמיניסטי; combined 42/42/0 ב-3/3 ריצות.

### 2026-06-13 — A14 צ׳אט last-mile: אכלוס participantUids אמיתי (נחיל)
- **הפער שנסגר:** A9 הוסיף את `participantUids` כשדה inert (מעולם לא אוכלס → תמיד ריק → "ריק=גלוי-לכולם" → אפס בידוד-אמיתי). A14 מאכלס אותו באמת: `ChatEngineNotifier.ensureParticipantUids` פותר את **האיחוד** של uids-התפקידים (A7 `uidsByRole`) + uid-השולח וחותם על ה-thread, gated ב-`uidScoped` (default `kUidScopedQueries`).
- **`lib/state/sys_chat.dart` — `ensureParticipantUids` (אכלוס-האיחוד):** מוטציה — שבירת לולאת-האיחוד (`union.addAll(await lk.uidsByRole(role.name))` → `await lk.uidsByRole(role.name);` בלי addAll, כלומר זריקת ה-uids של התפקידים) → `chat_uid_a14_populate_test` **`+3 -3` אדום**: 'flag ON: a send STAMPS the union' (Expected Set{uid-c,uid-s1,uid-s2} / Actual Set{uid-c} — רק השולח שרד) · 'ensureParticipantUids on thread OPEN' (אותו {uid-c}) · 'VISIBLE to a member, NOT to a non-member' (Expected true/Actual false — חבר-החנות uid-s1 נשמט → ה-rules-twin מבודד אותו, מוכיח שהאכלוס הוא מה שמניע את הבידוד האמיתי) ✅ נתפס. נעילות אפס-הרגרסיה (flag-OFF stays empty) + resolve-once + compile-time-OFF נשארו ירוקות (המוטציה נגעה רק באיחוד).
- שחזור: `cp /tmp/A14_sys_chat.dart.bak lib/state/sys_chat.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14 הלא-מקומט); md5 חזר ל-`efc72d1dff51673d130252879fe8c5b4` → הרצה חוזרת **+6 ירוק**.
- **`lib/data/repositories/chat_firebase.dart` / `chat_repository.dart` — `setParticipantUids`:** seam-נתיב-השרת לחתימת ה-head (toDoc של A9 כבר persist את participantUids כשלא-ריק). מכוסה עקיף ע"י ההוכחה הנ"ל (הנתיב-המקומי) + בדיקות-ה-chat הקיימות (`chat_uid_a9_test` toDoc/fromDoc) + analyze. הנתיב-המקומי (engine IS the store) הוא מה שהבדיקות מריצות (Firebase-free).
- **emulator:** ללא שינוי-rules → 42/42/0 (אומת מחדש; לא נדרשו בדיקות-rules חדשות).

### 2026-06-13 — שיחות/וידאו V1+V2 (calls/video): כפתורי 📞/💬 + הסתרת עץ-הגדרות-מת (אני)
- **`lib/logic/input_validators.dart` — `waMeDigits` (helper טהור, נרמול טלפון→wa.me):** מוטציה — הפלת המרת ה-0→972 (`digits = '972${digits.substring(1)}';` הוערה החוצה) → `input_validators_test` **`+31 -3` אדום**: 'waMe — Israeli local 0501234567 → 972501234567' (Expected '972501234567' / Actual '0501234567') · 'waMe — separators…' (אותו) · 'waMe — does NOT double-prefix…' (אותו) ✅ נתפס. נעילות אפס-הרגרסיה (empty→'' · already-972 untouched · 00-prefix) נשארו ירוקות (המוטציה נגעה רק בענף-ה-0-המקומי). שחזור: `cp /tmp/input_validators.dart.bak lib/logic/input_validators.dart` (**לא** git checkout); md5 חזר ל-`1d2bd4145ffe5ad25876a31904d90de6` → הרצה חוזרת **+34 ירוק**.
- **`lib/data/search_index.dart` — הסרת עץ 'הגדרות שיחות' המת (V2):** הוסר ה-entry העליון (`title: 'הגדרות שיחות'`) + כל תת-העץ (~40 leaves: שיחות-וחיווי/אישורי-קריאה/חיווי-הקלדה/התראות-שיחה/צלצול-שיחה-נכנסת/מדיה-ושמע/דחיסת-וידאו/פרטיות/גיבוי-וייצוא/שפה/עסקיות/בוט/ארכיון). נעול ע"י `call_settings_hidden_test` (8 כותרות-מת נעדרות + אפס breadcrumb תחת 'הגדרות שיחות' + ה-entry 'שיחות' של הצ׳אט-האמיתי **נשמר** + 3 עצי-הגדרות-שכנים נשמרים). אין helper חדש בקובץ זה → לא נדרשה מוטציה ייעודית (זו data-list); הבדיקה היא ה-guard הביצועי לבייטים.

### 2026-06-13 — order-card 📞/💬: customerPhone על ההזמנה (V1 last-mile · נחיל)
- **הפער שנסגר:** V1 (8709129) נתן `ContactActions` על chat + כרטיסי-פרופיל, אבל ל**כרטיס-ההזמנה** לא היו כפתורים — אף order-model לא נשא טלפון (Order/SysOrder חשפו רק `who`=שם-תצוגה). הוחלט (בעל-המוצר): על כרטיס-הזמנה ה-📞/💬 מגיעים ל**מי שהזמין** (הקבלן). שדה additive `Order.customerPhone` (default `''`, כתיבה-מוגנת כמו `contractorUid`/`storeUid`) ← נחתם ב-checkout (`store_screen` = `userProfileProvider.contact`) → מוקרן ל-`SysOrder.customerPhone` (`sys_orders._toSysOrder`). **לא flag-gated** — ה-default-הריק + empty-guard של ContactActions הם אפס-הרגרסיה (seed/legacy → אין כפתורים).
- **`lib/state/orders_engine.dart` — `Order.fromJson` קריאת `customerPhone`:** מוטציה — `customerPhone: (j['customerPhone'] as String?) ?? ''` → `customerPhone: ''` קבוע (זריקת הקריאה) → `orders_engine_test` 'Order.customerPhone … a phone is WRITTEN and round-trips losslessly when non-empty' **אדום `+26 -1`** (Expected '050-123 4567' / Actual ''); נעילות אפס-הרגרסיה (EMPTY omitted · fromJson defaults '' · copyWith preserves · placeOrder stamps/defaults) נשארו ירוקות (המוטציה נגעה רק בקריאה-כשקיים) ✅ נתפס. שחזור: `cp /tmp/orders_engine.dart.bak lib/state/orders_engine.dart` (**לא** git checkout); md5 חזר ל-`3bf5bdaa4f54e16ffa87a44e84f9fb6e` → הרצה חוזרת **+27 ירוק**.
- **`lib/data/repositories/orders_firebase.dart` / `orders_local.dart` / `orders_repository.dart` — חתימת `placeOrder` + toDoc/fromDoc:** השדה עבר דרך כל ה-impls (guarded-write `if (o.customerPhone.isNotEmpty)` ב-toDoc · default-read ב-fromDoc) מירור מדויק ל-`contractorUid`/`storeUid`. מכוסה ע"י `orders_uid_a3_test` קבוצת customerPhone (Firestore shape: WRITTEN+round-trip · EMPTY omitted · fromDoc defaults '') + analyze.
- **test-doubles שתוקנו לשינוי-החתימה (האנטי-דפוס החוזר):** `_RecordingOrdersRepo` (`offline_order_queue_test.dart`) + `_SpyOrders` (`site_firebase_repo_test.dart`) — שניהם `implements OrdersRepository`, הוסף להם הפרמטר `String customerPhone = ''` (ל-recording גם `customerPhone: customerPhone` ב-Order שהוא בונה). analyze 0-errors תפס שהם חייבים עדכון; שניהם ירוקים.
- **gate:** `flutter analyze` (כל הקבצים הנגועים) — 0 errors/warnings (רק info קיימים-מראש; אפס info חדש). `flutter test` מלא — **+2233 All tests passed** (היה +2222; +11: order_card_contact_actions +2 · engine customerPhone +6 · a3 customerPhone +3). `flutter build web --release` — ✓ Built. לוגיקת בעלות-הזמנה (A4-A6/A14 claim/scope/uid) **לא נגעתי** — customerPhone שדה עצמאי.

### 2026-06-14 — 4 כפתורים-מתים/מזויפים → התנהגות-אמת (ביקורת-launch · נחיל)
4 fixes; מוטציה מלאה הורצה על FIX#1 (share), שאר ה-3 מכוסים ע"י בדיקות-effect ייעודיות.
- **FIX#1 (share) · `lib/screens/store_screen.dart` — טקסט-השיתוף ב-`_CartActionsRow`:** מוטציה — `final text = 'סל BuildSmart:\n$items\n\nסה״כ: ₪$total';` → `final text = 'MUTANT';` (Edit) → `cart_share_test` 'tapping שתף hands the cart summary to the share seam' **אדום** (`Expected: contains 'מלט' / Actual: 'MUTANT'`) ✅ נתפס — הבדיקה מוכיחה שטקסט-הסל-האמיתי זורם ל-seam, לא no-op. שחזור: `cp /tmp/store_screen.bak.dart lib/screens/store_screen.dart` (**לא** git checkout) → הרצה חוזרת **2/2 ירוק**.
- **FIX#3 (order-now) · `lib/logic/ai_hub_logic.dart` — `computeStockForecast` קטיף emoji+unitPrice:** מכוסה ע"י `ai_hub_compute_test` 'carries REAL emoji + unit price from the latest order line' (יחידה: line אחרון 🪨/200÷4 → `emoji='🪨'`, `unitPrice=50`) + widget 'הזמן עכשיו adds the recommended item to the live cart' (טאפ → `smartCartProvider` גדל ב-1, line `ai-restock:PEX` עם emoji-אמת). שבירת הקטיף (החזרת `📦`/`0`) הייתה מפילה את היחידה — הבדיקה היא ה-guard הביצועי.
- **FIX#2 (favorite) · `lib/screens/smart_home_screen.dart` — onTap של אריח-מועדף:** אין helper טהור (UI-wiring) → מכוסה ע"י `favorite_tile_opens_sheet_test` (טאפ אריח-כוכב → `LipskeyProductSheet` נפתח; `onTap: () {}` המקורי היה מפיל את ה-`findsOneWidget`).
- **FIX#4 (PDF) · `lib/logic/finance_report_pdf.dart` — `buildFinanceReportPdf`:** מכוסה ע"י `finance_pdf_export_test` — הבונה-הטהור חייב להפיק bytes לא-ריקים שמתחילים ב-magic `%PDF` (שבירת ה-`addPage` הייתה מפילה את `isNotEmpty`/`'%PDF'`); ה-widget-test מוכיח שטאפ 'הדפסה' מזריק את אותו doc ל-`pdfPrintProvider` (seam). 
- **gate:** analyze (כל הקבצים הנגועים) 0 errors/warnings (4 קבצים-חדשים נקיים) · full-suite **+2241 All tests passed** (היה +2233; +8) · build web ✅ Built (printing נפתר web). pubspec.lock לא staged.

### 2026-06-14 — A13 קידום-שלב + אשראי → Cloud Functions callables (gated, אני)
- **הפער שנסגר:** `advanceOrderStage`+`computeCredit` קיימות בשרת (+טריגר `revertIllegalOrderStageWrite` שמחזיר כתיבת-stage ישירה לא-חוקית), אבל ה-client עשה direct optimistic Firestore writes + hash-אשראי מקומי שעוקפים את השרת+S5. A13 מחווט נתיב-callable **gated** מאחורי `kServerCallables` (default OFF, דפוס `kUidScopedQueries`/`uidScoped`), forward-ready ל-deploy+flip של הבעלים. seam חדש `OrderFunctionsGateway` (mirror ל-`AuthGateway`; `FirebaseOrderFunctionsGateway` פותר `FirebaseFunctions.instanceFor(region: me-west1)` עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי). OFF + provider-gateway null מחוץ ל-live-backend = byte-identical.
- **`lib/state/orders_engine.dart` — `_advanceViaCallable` (החלת ה-`{to}` הקנוני של השרת):** מוטציה — `remote.applyServerStage(orderId, result.to)` → `result.from` (החלת השלב-הישן במקום החדש) → `orders_credit_a13_callable_test` 'flag ON: advance INVOKES advanceOrderStage … applies the server's {to} LOCALLY' **אדום `+0 -1`** (Expected: 'preparing' / Actual: 'new' — השלב לא התקדם). נעילות OFF (direct set) + FunctionsException + credit נשארו ירוקות (המוטציה נגעה רק בהחלה-המקומית של ה-advance). ✅ נתפס. שחזור: `cp /tmp/A13_oe_final.bak lib/state/orders_engine.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A13); md5 חזר ל-`7ab77ca974d951979977414a200e55b4` → הרצה חוזרת **+8 ירוק**.
- **מוטציה שנייה (נעילת ה-tension optimistic↔callable) · `advance`:** הוספת `r.advance(orderId)` בענף-ON (כלומר גם יורה את ה-direct write שהטריגר היה מחזיר) → אותו test **אדום** (`Expected: empty / Actual: [BS-1042…]` על `src.sets` — הוכחה בייט-לבייט ש-ON אסור שיירה `set` ישיר). שוחזר → ירוק. זו ההוכחה שה-test נועל באמת את "ה-callable הוא הכתיבה הקנונית; ה-client לא יורה direct set".
- **`lib/data/repositories/customers_local.dart`/`customers_firebase.dart` — `computeCredit` (נתיב-אשראי):** gated זהה; ON→callable `computeCredit({name})`, OFF→גזירה-מקומית זהה לדשבורד (`contractorCredit`+spend-fold+`pct`/`balance`), FunctionsException→fallback מקומי (בלי לזייף). מכוסה ע"י אותו test (ON-credit מזמן+מחזיר server figures · OFF-credit local זהה+callable-לא-נקרא · FunctionsException→fallback · default-OFF). ה-`creditLimit(name)` הסינכרוני (נתיב-הדשבורד) **לא נגעתי** — אפס-רגרסיה.
- **`lib/data/repositories/firestore_cached_repo.dart` — `upsertLocalOnly`:** תאום LOCAL-only ל-`upsert` (cache+notify, **בלי `set`**) — הנתיב שבו הכתיבה-הקנונית נעשית במקום-אחר (ה-callable). `lib/data/repositories/orders_firebase.dart` — `applyServerStage` (stage-only מעליו). `lib/data/repositories/backend.dart` — ה-flag. `lib/data/repositories/customers_repository.dart` — מתודת-interface `computeCredit` אדיטיבית.
- **gate:** `flutter analyze` (כל ~8 הקבצים הנגועים + ה-test) — **0 errors/warnings**; אפס info-lints חדשים (אומת מול HEAD: `firestore_cached_repo` 82/103 + `orders_engine` 27/57/219/243 קיימים-מראש). `flutter test` מלא — **+2260 All tests passed** (היה +2252; +8). `flutter build web --release` — ✓ Built. לוגיקת uid/chat-message **לא נגעתי**. (הערה: ה-codebase בסגנון-formatter ישן; `dart format` היה מעצב-מחדש קוד-קיים → שוחזר ל-HEAD ושוכתב בסגנון-המקור, diff = additions בלבד.)

## A14 — צילומי-תמונה → R2 upload דרך `getUploadUrl` (gated, אני) — 2026-06-14

- **הפער שנסגר:** כל תמונה (POD/before-after/פרופיל/לוגו/תעודה) = `data:…;base64` data-URL ב-localStorage (~1.5MB, ללא sync); ה-callable `getUploadUrl` (`functions/src/r2.ts`, presigned-PUT ל-R2) קיים אבל ה-client לא קרא לו. A14 מחווט נתיב-העלאה **gated** מאחורי `kCloudPhotos` (default OFF, נפרד מ-`kServerCallables`), forward-ready ל-provision+deploy+flip של הבעלים. seam חדש `UploadFunctionsGateway` (mirror ל-`OrderFunctionsGateway`; `FirebaseUploadFunctionsGateway` פותר Functions עצלן, מתרגם `FirebaseFunctionsException`→ניטרלי) + seam שני `PhotoHttpPut` (ברירת-מחדל `http.put`). חוזה: השרת מחזיר `{url,key,…}` (אין public-URL בחוזה); ה-publicUrl מורכב `{kImageBaseUrl}/{key}`.
- **`lib/services/task_photo.dart` — `uploadCapturedPhoto` (החזרת ה-URL הציבורי על 2xx):** מוטציה — `return target.publicUrl;` → `return target.uploadUrl;` (אחסון ה-presigned-PUT URL במקום הציבורי) → `cloud_photos_a14_upload_test` **`+10 -2` אדום**: 'ON: a capture INVOKES getUploadUrl … stores the PUBLIC url' (Expected `https://pub-test.r2.dev/pod/u/9-photo.jpg` / Actual `https://r2.example/put/k1?sig=AAA`) + 'uploadCapturedPhoto … publicUrl on a 2xx' (Expected publicUrl / Actual upload-url) ✅ נתפס. נעילות OFF (byte-identical) + 3 ה-fallbacks (getUploadUrl-throw/PUT-403/PUT-throw) + gif + display נשארו ירוקות (המוטציה נגעה רק באחסון-ה-URL בנתיב-ה-2xx). שחזור: `cp /tmp/task_photo.dart.bak lib/services/task_photo.dart` (**לא** git checkout — שלא לאבד את קוד-ה-A14) → הרצה חוזרת **+12 ירוק**.
- **קבצים נגועים (lib/services|lib/state|lib/data):** `lib/services/task_photo.dart` (נתיב-העלאה + seams + gate) · `lib/data/repositories/upload_functions.dart` (חדש — ה-seam) · `lib/data/repositories/backend.dart` (ה-flag `kCloudPhotos`) · `lib/widgets/photo_viewer.dart` (`imageProviderForRef`/`showFullPhotoRefDialog`/`isHttpPhotoRef`) + ~12 אתרי-רינדור (screens). `lib/state/persona_fulfillment.dart` — **לא** נגעתי (ה-side-map שומר את ה-String כמו-שהוא; ON מאחסן https, OFF מאחסן base64 — אותו mechanism).
- **gate:** `flutter analyze` (כל הנגועים) — **0 errors** (info/warning קיימים-מראש בלבד). `flutter test` מלא — **+2272 All tests passed** (היה +2260; +12). `flutter build web --release` — ✓ Built. pubspec.lock **לא** staged. לוגיקת uid/chat/orders-callable **לא נגעתי**.
### 2026-06-14 — גל-D פוליש (#98 · נחיל אמיתי)
- **`lib/state/vacation_requests.dart:132` — back-compat decode של role:** מוטציה — `: 'worker'` → `: 'courier'` (ברירת-מחדל ל-payload ישן בלי 'role'). הבדיקה החדשה 'P-12 worker filter — an OLD payload without role is counted as the worker's (back-compat)' **אדומה** (Expected ['vac-legacy-demo'] / Actual []) + #86.3 back-compat האדים גם → ✅ נתפס; שוחזר byte-clean → 13/13 ירוק.
- **כיסוי כן:** סינון-המסך של P-12 (worker_forms_screen.dart, r.role=='worker') מכוסה רק עקיפות — ה-unit-test משכפל את ביטוי-הסינון ומאמת את מודל-ה-role/back-compat שעליו הוא נשען, לא קורא מה-widget. דפקט-המודל (back-compat) כן נתפס במוטציה; רגרסיה בשורת-המסך עצמה תיתפס רק ב-widget-test ייעודי (לא נכתב — פוליש).
