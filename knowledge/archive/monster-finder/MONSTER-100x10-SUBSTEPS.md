# MONSTER — 100 שלבים × 10 תת-שלבים (1000 נקודות)

> פירוק כל אחד מ-100 שלבי-הבנייה (ראה MONSTER-100-STEP-BUILD-PLAN.md) ל-10 נקודות: יעד · איך בונים · תקלות צפויות · פתרון · בדיקות · שיפור · ריאלי? · וידוא-פיקס · 2 תכנונים-נוספים. נבנה מנחיל 10-סוכנים מעוגן בקוד benzi-kb-build.

---

<div dir="rtl">

# פירוק-מיקרו לשלבים 1–10 (פאזה P1 — יסוד-נתונים)

> מעוגן בקוד החי תחת `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל מזהה/נתיב/טיפוס באנגלית; ההסבר בעברית.
> קבצי-ליבה רלוונטיים: `lib/features/word_finder/dive_pool.dart` · `lib/features/card_keyboard/card_engine.dart` · `lib/features/card_keyboard/card_signals.dart` · `lib/features/word_finder/narrow_axis.dart` · `lib/screens/_size_norm.dart` · `lib/features/word_finder/material_lexicon.dart` · `lib/data/variant_families.dart` · `lib/data/lipskey_catalog.dart` · `lib/features/word_finder/word_finder_engine.dart`.

---

### שלב 1 — קיבוע יקום קנוני + baseline ל-analyze + תיקון docstring

**1. יעד:** קיים `kReachUniverse` ציבורי ב-`dive_pool.dart` = הכרטיסים-הנבדלים של `kDivePool` (קיפול לפי `_collapseKey`/`distinctCardCount` של `word_finder_engine.dart`), נטען-שווה (eager `final`) כך שלא יוכל להתכווץ בשקט; ושני docstring-ים מטעים ב-`card_engine.dart` (שורות 11–14 "PHASE 0 (this skeleton)... stubbed to empty, so until Phase 2 the engine behaves exactly..." ושורה 148 "PHASE 0: step 4's [_mergedChips] is stubbed to empty") כבר מתוקנים — כי `_mergedChips` כבר ממומש מלא (שורות 217–297), כך שההערה שקרית והיא מלכודת-קריאה. בנוסף נרשם baseline ל-`flutter analyze` (היום 18 infos) כעוגן לשלבי-ההמשך.

**2. איך בונים:** (א) להוסיף ל-`dive_pool.dart` ליד `kDivePool`: `final List<LipskeyCatalogProduct> kReachUniverse = _buildReachUniverse();` שמקפל את `kDivePool` ב-`distinctCardCount`-key — אבל `_collapseKey` הוא `private` ב-`word_finder_engine.dart` (שורה ~236), לכן לחשוף עוזר ציבורי `distinctReachCards(pool)` שם, או להסתמך על `distinctProducts(kDivePool, cap: aHugeNumber)` שכבר נותן נציג-לכל-כרטיס-נבדל (שורה 288) — העדפה: `distinctProducts` עם cap ענק, כי הוא כבר ציבורי ושומר סדר-בריכה. (ב) לתקן את 2 ה-docstring-ים ב-`card_engine.dart` שיתארו את המצב האמיתי (merge חי, לא stub). (ג) להריץ `flutter analyze` ולתעד את ה-baseline (18) בתוך הערת-ראש או בקובץ-בדיקה.

**3. תקלות צפויות:** (1) `_collapseKey` פרטי — ניסיון לייבא אותו ל-`dive_pool.dart` נכשל קומפילציה. (2) `kReachUniverse` כ-`final` eager בונה רשימה בזמן-טעינת-המודול; אם נכניס אותו לגרף-ייבוא של `word_finder_engine` ניצור תלות-מעגלית (engine כבר מייבא `dive_pool`? לא — אבל `dive_pool` מייבא הרבה data; להישמר ממעגל אם נחשוף helper ב-engine שמייבא `dive_pool`). (3) שינוי docstring "אמור" להיות זהה-בייטים בפרודקשן — והוא כן (תגובה בלבד), אבל אם בטעות נשנה שורת-קוד ליד התגובה, נשבור את byte-identity של flag-OFF. (4) baseline 18-infos עלול לזוז אם הוספת `kReachUniverse` מולידה lint (unused_element אם לא-נקרא-עדיין; השלב מצהיר "נטען-שווה" אבל לא-נצרך → אזהרת unused).

**4. פתרון:** (1) לחשוף ב-`word_finder_engine.dart` פונקציה ציבורית טהורה `List<LipskeyCatalogProduct> distinctReachCards(List<LipskeyCatalogProduct> pool) => distinctProducts(pool, cap: 1 << 30);` (שכבר משתמשת ב-`_collapseKey` בתוך `distinctProducts`) — אפס שכפול-לוגיקה. (2) לוודא ש-`word_finder_engine` כבר מייבא `dive_pool` (כן, ל-`_divePoolBySku`) ולכן את ה-helper מניחים שם, ו-`dive_pool` קורא לו — מעגל. במקום זה: `kReachUniverse` יבנה ב-`dive_pool.dart` ישירות מ-`distinctProducts(kDivePool, cap: 1<<30)` (engine→dive_pool כיוון-אחד נשמר). (3) להגביל את ה-edit לשורות-תגובה בלבד; להריץ את בדיקת byte-identity (שלב 24/2) מיד. (4) להוסיף `// ignore: unused_element`-שקול — עדיף: לרשום בדיקה (סעיף 5) שצורכת את `kReachUniverse`, כך אין unused.

**5. בדיקות:** קובץ `test/features/card_keyboard/reach_universe_test.dart`: (א) `kReachUniverse` לא-ריק ו-`kReachUniverse.length == distinctCardCount(kDivePool)` (קיבוע "נטען-שווה"). (ב) כל sku ב-`kReachUniverse` ייחודי (`map((p)=>p.sku).toSet().length == length`). (ג) `mergedKeys(kDivePool, [], lexicon, null)` מחזיר `CardAskWords` עם `words` לא-ריק (השדרה חיה מעל היקום). (ד) assert-עיגון: `kReachUniverse.length` שווה לקבוע-מוקלד (snapshot מספרי) כדי שכיווץ-שקט ייכשל.

**6. שיפור:** במקום cap `1<<30` קסם, להגדיר קבוע ציבורי `kUnboundedCap` ב-`word_finder_engine.dart` וגם להשתמש בו; ולתעד את ה-baseline-18 כקובץ `test/analyze_baseline.txt` שבדיקת-CI משווה אליו (במקום הערה שמתיישנת), כך שעלייה ל-19 נכשלת אוטומטית.

**7. ריאלי?:** כן — אטומי וקטן (הוספת `final` אחד + helper ציבורי + 2 תגובות). בר-בדיקה מיידית. אין סיכון פרודקשן (אין call-site חי). זה השלב הנכון לפתוח בו את הפאזה.

**8. וידוא-פיקס מלא:** `flutter analyze` = 0-new מול baseline-18 (ה-helper וה-final לא מוסיפים lint כי נצרכים ע"י הבדיקה); הרצת `reach_universe_test` ירוקה עם `taskkill dart` לפני וה-retry-wrap לכשלי-טעינה; בדיקת byte-identity של flag-OFF (שלב-2) עוברת — אין שינוי התנהגות חי; אין דליפת-זיכרון (eager-final נבנה פעם-אחת, כמו `kDivePool` עצמו).

**9. תכנון נוסף (שלי):** להוסיף `reachUniverseBySku` (Map<String,LipskeyCatalogProduct>) לצד `kReachUniverse` — שלבי-הגרף (71–90) יזדקקו לחיפוש-sku→נציג ב-O(1); לבנותו עכשיו, פעם-אחת, חוסך re-scan חוזר וגם משמש את מפקדי-ה-≤6/≤4. אחרת כל מפקד יבנה אינדקס משלו ויסטה.

**10. תכנון נוסף (שלי):** לכתוב `test` שמוודא ש-`kReachUniverse ⊇` כל ה-skus שיש להם `hasSpec==true` ב-`divePoolIndex` (כלומר היקום-הקנוני לא משמיט מוצר בעל-גיאומטריה-אמינה שמנוע-ההתקנה מכיר) — זה תופס רגרסיה עתידית שבה קיפול-הכרטיסים בולע בטעות מוצר ייחודי שמנוע-ההתקנה עדיין צריך.

---

### שלב 2 — נעילת golden + baseline-רגרסיה לפני-תיקוני-נתונים

**1. יעד:** קיים golden-snapshot כתוב (flag-OFF/מצב-נוכחי) של פלט `_mergedChips` עבור בריכת-עוגן קבועה, וגם של `narrowAxis(...).chips`/`sizeTokensIn(...)` לאותה בריכה — כעוגן-רגרסיה שמקפיא את ההתנהגות *לפני* תיקוני-הנתונים של שלבים 3–10. כל סטייה עתידית מהפלט הזה תיתפס.

**2. איך בונים:** (א) לבחור בריכת-עוגן דטרמיניסטית — לא `kDivePool` כולו (גדול/שביר), אלא תת-קבוצה יציבה לפי subtype או לפי קטגוריה (למשל כל המוצרים מקטגוריה אחת עשירת-גדלים). (ב) להריץ `_mergedChips(pool, [stack-לא-ריק], subtype)` ולכתוב את ה-`(axisId,value,displayLabel)` של כל chip לרשימת-ליטרלים בקובץ-בדיקה (golden כ-`const` בתוך הטסט, לא קובץ-תמונה). (ג) במקביל לכתוב golden ל-`sizeTokensIn(pool).map((t)=>t.label)` ול-`SizeSignal().chipsFor(pool)` — אלו ישתנו בשלבים 3–4 ולכן הם ה"לפני". (ד) `_mergedChips` פרטית — לחשוף test-seam או להשתמש דרך `mergedKeys(...)` ולחלץ את `MergedKeys.chips`.

**3. תקלות צפויות:** (1) `_mergedChips` פרטית (card_engine:217) — בדיקה לא יכולה לקרוא לה ישירות; דרך `mergedKeys` היא מחזירה `MergedKeys` רק כשהבריכה > `kShowProductsThreshold` (12) ו-chips לא-ריק (card_engine:164–169), אחרת `CardShowProducts` — אם בוחרים בריכה קטנה מדי לא נקבל chips. (2) golden שביר: word-axis תלוי בסדר-בריכה — אך `WordSignal.chipsFor` כבר ממיין canonical-sku (card_signals:164), כך שיציב; אבל אם בריכת-העוגן תיבחר מבריכה לא-ממוינת והבדיקה תניח סדר אחר → flakiness מדומה. (3) `representativeTake` (card_engine:308) דוגם נציגים — golden צריך לתפוס *בדיוק* אותם אינדקסים; שינוי בקיבול (`kMergedKeyCap=10`) ישבור. (4) הסכנה האמיתית: לקבע golden שמכיל כבר את ה"באג" של גדלים-כפולים (DN15 ו-½" כשני chips) — וזה דווקא רצוי כאן (זה ה"לפני"), אך חובה לתעד שזה ה-OFF-anchor ולא ה-target.

**4. פתרון:** (1) לבחור בריכת-עוגן בגודל מוכח > 12 כרטיסים-נבדלים (assert בתוך הטסט: `distinctCardCount(pool) > kShowProductsThreshold`) כדי להבטיח ענף `MergedKeys`. (2) למיין את בריכת-העוגן ב-sku בתוך הטסט לפני הקריאה, ולהוסיף בדיקת-shuffle (לְעַרְבֵּב ואז להריץ → פלט זהה) שמוכיחה שה-golden אינו תלוי-סדר. (3) לקבע במפורש `expect(MergedKeys.chips.length, lessThanOrEqualTo(kMergedKeyCap))` ולהשוות רשימה-מלאה. (4) לתעד בכותרת-הטסט: `// FLAG-OFF ANCHOR — intentionally captures pre-canonicalization size duplicates; steps 3-4 will change sizeTokens golden, not this merged golden until step 11`.

**5. בדיקות:** קובץ `test/features/card_keyboard/merged_golden_anchor_test.dart`: (א) `golden_mergedChips`: רשימת-`(axisId|value|displayLabel)` קבועה == הפלט הנוכחי. (ב) `golden_sizeTokens`: `sizeTokensIn(anchorPool).labels` == רשימה קבועה. (ג) shuffle-stability: ערבוב הבריכה לא משנה את הפלט. (ד) הצהרת analyze: ריצת-`flutter analyze` zero-new (כחלק מ-CI, לא בתוך הטסט). שלוש החבילות `card_engine_test`/`card_signals_test`/`narrow_axis_test` ירוקות.

**6. שיפור:** לאחסן את ה-golden כקובץ-טקסט נפרד (`test/.../goldens/merged_anchor.txt`) ולא כליטרל-קוד, עם דגל-עדכון `--update-goldens` (כמו `dive_demo_golden_test.dart` הקיים תחת `test/smart_input/dive/goldens`) — כך עדכון-מכוון בשלב 11 הוא רענון-קובץ, לא עריכת-קוד שמסכנת byte-identity.

**7. ריאלי?:** כן, אטומי. זו "נעילה" פסיבית (כתיבת-בדיקה בלבד, אפס שינוי-קוד-מקור). תלוי בשלב 1 רק לשם `kReachUniverse` כמקור-בריכה אופציונלי. הסיכון היחיד הוא בחירת-בריכת-עוגן לא-יציבה — מנוטרל ע"י בדיקת-shuffle.

**8. וידוא-פיקס מלא:** הטסט עובר 3 ריצות-רצופות (יציבות לא-flaky, חשוב במיוחד לאור היסטוריית-קריסות-isolate ב-gate); `flutter analyze` 0-new; אין call-site חי (golden הוא בדיקה בלבד) ולכן byte-identity של flag-OFF טריוויאלית-שמורה; אין leak.

**9. תכנון נוסף (שלי):** לקבע golden שני, נפרד, גם ל-`_AxisScore` הדירוג — כלומר לתעד את *הסדר* של הצירים (size→angle→... אחרי הדירוג לפי expRem) עבור בריכת-העוגן, לא רק את ה-chips הסופיים. שלבים 64–66 ישנו את הדירוג בכוונה; בלי golden-סדר נפרד לא נדע אם שינוי-סדר עתידי הוא מכוון או רגרסיה.

**10. תכנון נוסף (שלי):** להוסיף בריכת-עוגן *שנייה* שמכוונת לציר-החומר (בריכה עתירת-נחושת/פליז) ולקבע golden של `MaterialSignal().chipsFor` — כי שלבים 7–9 נוגעים בכיסוי-החומר וב-gate, ובלי עוגן-חומר ייעודי השינויים שם "בלתי-נראים" לרגרסיה.

---

### שלב 3 — טבלת-בור-קנוני + `canonicalSize()` (card-scoped בלבד)

**1. יעד:** קיימת פונקציה טהורה `canonicalSize(SizeToken)` (או `canonicalSize(String label)`) חדשה, card-scoped בלבד, שמקפלת מידות שקולות-פיזית לאותו מפתח-קנוני: `DN15 == ½" == 15mm → 'DN15'` ברצועת-סבילות `±1.5mm`. עדיין לא-נקראת מאף call-site (לא-נוגעת בחי). אורך נשאר נפרד מקוטר; קיפול אידמפוטנטי.

**2. איך בונים:** (א) קובץ חדש `lib/features/card_keyboard/card_size_canonical.dart` (card-scoped; *לא* לגעת ב-`_size_norm.dart` החי). (ב) להגדיר טבלת-עוגן של בורות-קנוניים: רשימת-`(canonicalKey, mm, families-מותרות)` — למשל `DN15↔½"↔15mm` כולם מתמפים ל-`'DN15'` ב-`mm≈12.7..15`. (ג) `canonicalSize` מקבל `SizeToken`, ובודק לפי `family` (`inchDiameter`/`dnDiameter`/`mm` בלבד — לא `cm`/`meters`/`angle`, שהם אורך/זווית), מוצא את הבור שבו `|t.mm - bucket.mm| <= 1.5`, ומחזיר את `canonicalKey`; אם אין בור — מחזיר את `t.label` עצמו (key=עצמו, אפס-קיפול). (ד) להגן: `angle`/`cm`/`meters` → תמיד `t.label` (אורך≠קוטר).

**3. תקלות צפויות:** (1) `SizeToken.mm` הוא scalar-מיון בלבד, וב-inch הוא `inches×25.4` (`_kInchMm`, `_size_norm.dart:95`) בעוד DN.mm הוא הערך-הנקוב (DN15→15, אך ½"→12.7) — כלומר ½" ו-DN15 *לא* באותו mm (12.7 מול 15); רצועת ±1.5mm גשר עליהם (הפרש 2.3mm > 1.5!) → הקיפול *ייכשל* לאחד ½" עם DN15. (2) cross-dim (`16×20`) מקודד `family: mm` עם `mm=16` (`_size_norm.dart:200`) — קיפול-לפי-mm יבלע אותו לבור-15 שגוי. (3) רצועה גלובלית ±1.5 חופפת בורות צמודים (DN15/DN16/DN20) → מוצר עלול ליפול לשני בורות (אי-דטרמיניזם). (4) `meters`-mm הוא `cm*10` (אורך) — אם לא-נחריג, אורך 1.5מ׳ ייבלע לבור-קוטר.

**4. פתרון:** (1) הרצועה אינה יכולה להיות "±1.5mm גלובלי על mm-המיון"; להגדיר בור ע"י *סט-תוויות-שקולות מפורש* (allowlist: `{'DN15','½"','15 מ"מ'} → 'DN15'`) שנבנה ידנית מהנתונים-המאומתים, ולא ע"י סף-מרחק עיוור — כך ½" ו-DN15 מתאחדים בקביעה, לא במרחק. הרצועה ±1.5 משמשת רק לבליעת-רעש בתוך אותה-משפחה (`14.x מ"מ`→`15`). (2) להחריג `cross-dim` במפורש: אם `label.contains('×')` → key=עצמו. (3) לבחור בור *יחיד* בקביעה (מילון-תוויות), כך אין חפיפת-טווחים; ה-±1.5 חל רק כשאין-תווית-מפורשת. (4) `family != inch/dn/mm` → key=label (סעיף 2.ד).

**5. בדיקות:** קובץ `test/features/card_keyboard/size_norm_canonical_test.dart`: (א) קיפול: `canonicalSize(DN15)==canonicalSize(½")==canonicalSize(15mm)=='DN15'`. (ב) גבול: `19mm`-בור-נפרד מ-`15`-בור (לא חופף). (ג) אורך≠קוטר: `canonicalSize(2 מ׳)` ו-`canonicalSize(2")` שונים; `cm`/`meters`/`angle` לעולם לא-מתקפלים לבור-קוטר. (ד) idempotent: `canonicalSize` על תוצאתה-עצמה יציב. (ה) cross-dim: `16×20` → key=`'16×20'` (לא נבלע).

**6. שיפור:** לבנות את מילון-הבורות *מ-`kDivePool` בזמן-build* (לגזור אילו תוויות-גודל באמת קיימות ולקבץ לפי mm-מעוגל) במקום רשימה-ידנית שמתיישנת — אך עם override-ידני לזוגות-הבעייתיים (½"↔DN15). זה נותן כיסוי-מלא אוטומטי + דיוק-ידני במקום-הצורך.

**7. ריאלי?:** כן, אטומי — קובץ-טהור חדש + בדיקה, אפס call-site. *אבל* יש סיכון-תוכן: "רצועת ±1.5mm" כפי-שנוסחה בתוכנית היא לא-נכונה פיזית (½"=12.7 מול DN15=15). השלב אטומי-מבחינה-הנדסית אך דורש דיוק-נתונים; לא צריך פיצול, צריך לתקן את מודל-הקיפול (מילון מפורש, לא סף-עיוור).

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `size_norm_canonical_test` ירוק כולל בדיקת-idempotent ו-property-fuzz (אלפי תוויות אקראיות → אף-פעם-לא-throw, תמיד-קיפול-יציב); byte-identity של flag-OFF טריוויאלי (לא-נקרא); `_size_norm.dart` החי לא-נגוע (diff ריק עליו) — לוודא ב-`git diff --stat` שאין שינוי שם.

**9. תכנון נוסף (שלי):** להוסיף `canonicalSizeReason(token)` שמחזיר *מאיזה בור* הגיע הקיפול (לדיבוג/בדיקות), ולחשוף `kCanonicalSizeBuckets` כמפה ציבורית קבועה — כך שלב 4 (קיפול `SizeSignal`) ושלב 10 (ניקוד) יקראו את אותה מפה-יחידה, ולא ישכפלו טבלה.

**10. תכנון נוסף (שלי):** לכתוב בדיקת-כיסוי שמריצה `canonicalSize` על *כל* התוויות מ-`sizeTokensIn(kDivePool)` ומוודאת ש-≥X% נופלות לבור-קנוני (ולא ל-key=עצמן) — מדד-כיסוי שמתעד כמה באמת התקפל היקום; בלי זה לא נדע אם הקיפול אפקטיבי או no-op בפועל.

---

### שלב 4 — קיפול `SizeSignal` על `canonicalSize` עם נציג-דטרמיניסטי

**1. יעד:** `SizeSignal.chipsFor` (`card_signals.dart:81`) מקבץ את תווי-הגודל לפי `canonicalSize` (שלב 3): `value` = המפתח-הקנוני, `displayLabel` = נציג-תצוגה דטרמיניסטי (tie-break ע"י sku/סדר-קבוע). נהרגת מלכודת ה"שני שבבי-גודל לאותו canonical". המנוע-החי (`narrow_axis.sizeTokensIn`) לא-נוגע — ה-golden שלו זהה-בייטים.

**2. איך בונים:** (א) ב-`SizeSignal.chipsFor`, אחרי `sizeTokensIn(pool)` והמיון-mm הקיים (שורות 82–85), לקבץ את ה-tokens ב-`canonicalSize(t)` כמפתח. (ב) לכל קבוצה לבחור displayLabel דטרמיניסטי — נציג ב-tie-break ממוין (למשל הקטן-ב-mm, ואז label-לקסיקלי; או "המפתח-הנקוב המועדף" אם הוא בקבוצה). (ג) להחזיר chip-אחד-לבור: `SignalChip(axisId:'size', value: canonicalKey, displayLabel: representative, axisName:'גודל')`. (ד) לעדכן את `matches` (שורה 97): היום `productHasChip(p, chip.value)` עם `value==label`; כעת `value`=מפתח-קנוני, אז `matches` חייב להחזיר true אם *לאיזושהי* תווית-גודל של המוצר יש אותו `canonicalSize` — כלומר `productSizeTokens(p).any((t)=>canonicalSize(t)==chip.value)`.

**3. תקלות צפויות:** (1) שבירת חוזה-PARITY של `card_signals.dart` (שורות 9–17): ה-docstring מצהיר במפורש ש-`SignalChip.displayLabel` *byte-identical* ל-`AskAxis` הישן ו-ש-`SizeSignal` *לא* מקפל DN15↔½" ("deferred as an owner-reviewed enhancement"). שלב 4 מבטל את ההצהרה הזו — חובה לעדכן את ה-docstring, אחרת הקוד והתיעוד סותרים. (2) `representativeTake` ב-`_mergedChips` (card_engine:291) מניח chips ממוינים-mm; אם הקיבוץ הקנוני משנה סדר/מספר, הדגימה זזה → golden-merge של שלב 2 ישתנה (וזה *לא* אמור, כי שלב 2 הוא ה-OFF-anchor; השינוי כאן הוא flag-ON). (3) `matches` החדש יקר יותר (קורא `productSizeTokens` + `canonicalSize` per-product per-chip) — נתיב-חם ב-`_mergedChips` (לולאת-ניקוד שורות 250–255). (4) שינוי `value` שובר את ה-`SignalChip.==`/golden-anchor של `card_signals_test` הקיים.

**4. פתרון:** (1) לשכתב את פסקת-ה-PARITY ב-`card_signals.dart:9–17` כך שתתאר את הקיפול-הקנוני (value=canonical, display=נציג) ותסביר שהמנוע-החי נשאר non-folded. (2) שלב 2 כבר תיעד שה-golden-merge הוא OFF-anchor שלא-משתנה עד שלב 11; כאן מעדכנים *golden-ON* נפרד (אם קיים) או מוסיפים בדיקה חדשה — לא נוגעים ב-OFF-anchor. (3) למזכר (memoize) `canonicalSize` ברמת-הקריאה, ולחשב `productSizeTokens(p)` פעם-אחת לכל מוצר ולא לכל-chip (לבנות map `sku→Set<canonicalKey>` בתחילת `chipsFor`/`matches`-context). (4) לעדכן את ה-golden של `card_signals_test` במכוון (שינוי-data מאושר) ולתעד.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_signals_test.dart` (הרחבה): (א) "אין שני שבבי-גודל לאותו canonical": `SizeSignal().chipsFor(pool).map((c)=>canonicalSize-of(c.value)).toSet().length == chips.length` (כל value קנוני ייחודי). (ב) parity-OFF: `sizeTokensIn(pool)` (המנוע-החי) *זהה-בייטים* ל-golden שלב-2 (המנוע-החי לא-נגע). (ג) `matches`-נכונות: מוצר שנושא ½" *כן* נשמר תחת chip של `value=='DN15'`. (ד) displayLabel-דטרמיניזם: ערבוב-בריכה → אותו displayLabel נבחר.

**6. שיפור:** להפיק את ה-displayLabel-הנציג מתוך *העדפת-תצוגה* קנונית (DN לפני inch לפני mm — לפי `_kFamilyPrecedence` ב-`_size_norm.dart:40`) במקום "הקטן-ב-mm", כך שהנציג קריא-יותר למשתמש (DN15 עדיף ל-`15 מ"מ`); ולחשב את מפת-`sku→canonicalKeys` פעם-אחת ולשתף אותה בין `chipsFor` ל-`matches` דרך פרמטר-context, להריץ את הניקוד מהר.

**7. ריאלי?:** כן, אטומי — שינוי ממוקד בקובץ-אחד (`card_signals.dart`) + בדיקה. תלוי קשות בשלב 3 (אסור לפני שמילון-הבורות יציב). הסיכון הגבוה הוא parity ו-golden — מנוטרל ע"י בדיקת-OFF-anchor.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `card_signals_test` + `card_engine_test` ירוקים; בדיקת byte-identity מוודאת ש-`sizeTokensIn` החי לא-זז (זה הליבה — flag-OFF פרודקשן זהה); הרצת חבילת-הרגרסיה המלאה של word_finder (כי `card_signals` מייבא את `narrow_axis`/`_size_norm` — לוודא שלא נגרר שינוי); אין leak (memoize ברמת-קריאה, לא static-cache שמחזיק בריכות).

**9. תכנון נוסף (שלי):** לחשוף `sizeChipReason(chip)`/`siblingsOf(canonicalKey)` — בשלב 4 אנו מאחדים ½"/DN15/15mm לכרטיס-אחד, אבל המשתמש לפעמים *כן* רוצה את ההבחנה (אינץ' מול DN זה תקן-תבריג שונה); לשמור את התוויות-המקוריות שהתקפלו, כך ש-rail/כרטיס-המוצר (שלבי P8) יוכל להציג "גם ½" וגם DN15" בלי לאבד מידע.

**10. תכנון נוסף (שלי):** להוסיף guard-test שמוודא שאחרי הקיפול, *כל* מוצר שהיה נגיש דרך תווית-גודל כלשהי עדיין נגיש דרך ה-chip-הקנוני שלו (אין מוצר-יתום-גודל) — בדיקת-כיסוי שמריצה על `kDivePool`: לכל `p`, אם `productSizeTokens(p)` לא-ריק, קיים chip ב-`SizeSignal().chipsFor(poolסביבו)` ש-`matches(p, chip)` true. זו ההגנה הישירה מפני באג-"חבר-נעלם" שכבר תועד ב-`_size_norm.dart` (הערת `dedupLengthByMm` שורות 258–264).

---

### שלב 5 — תצוגת-צבע card-scoped ללא נחושת/פליז/כרום

**1. יעד:** קיים קובץ חדש `lib/features/card_keyboard/card_color.dart` עם פונקציית-תצוגת-צבע card-scoped שמחזירה צבע-אמיתי בלבד (לבן/שחור/אפור/פרגמון…) ומחזירה `null` עבור ערכים-שאינם-צבע-ויזואלי: נחושת/פליז/כרום (אלו חומר/גימור, לא צבע). `kLipskeyColors` בפרודקשן (`lipskey_catalog.dart:463`) *לא-נוגע*; ה-getter `colorVariant` (שורה 160) החי נשמר.

**2. איך בונים:** (א) קובץ חדש `card_color.dart`. (ב) להגדיר `kCardColorExclusions = {'נחושת','כרום',...}` — הערכים מתוך `kLipskeyColors` שהם גימור/חומר ולא צבע (נחושת:465, כרום:465; פליז לא ב-`kLipskeyColors` אך כן ב-material-terms). (ג) `String? cardColorOf(LipskeyCatalogProduct p)` שמחזיר את `p.color` (השדה-המובנה) רק אם הוא לא-ב-exclusions, אחרת `null`. (ד) (אופציונלי) `List<String> cardColorOptions(pool)` מקביל ל-`colorOptions` (`narrow_axis.dart:93`) אך מסונן-exclusions, ל-reuse בשלב 6.

**3. תקלות צפויות:** (1) כפילות-מקור: יש *שני* מקורות-צבע — `p.color` (שדה) ו-`colorVariant` (getter שקורא `kLipskeyColors` בשם, `lipskey_catalog.dart:160–165`). `ColorSignal` החי משתמש ב-`p.color` (card_signals:143) ו-`colorOptions` ב-`p.color` (narrow_axis:97) — אבל `colorVariant` קורא נחושת/כרום *מתוך-השם*. אם נחריג רק ב-`p.color` ולא נטפל ב-`colorVariant`, נחושת עדיין תדלוף דרך מסלול-אחר. (2) "כרום" הוא לעיתים הגימור-היחיד שמבדיל מוצר (ברז-כרום מול ברז-ניקל) — הסרתו מציר-הצבע עלולה למחוק הבחנה לגיטימית. (3) קובץ-חדש לא-נקרא → אזהרת unused (analyze). (4) byte-identity: כל-עוד `card_color.dart` לא-מחווט, פרודקשן זהה — אבל אם בטעות נייבא אותו מקובץ-חי, נשבור.

**4. פתרון:** (1) להגדיר במפורש שהשלב מטפל ב-*ציר-הצבע של הכרטיס* (שלב 6 מפנה את `ColorSignal` לכאן); נחושת-מהשם תיתפס בשלב 6–7 דרך *ציר-החומר* (`materialOf` כבר מזהה נחושת/פליז, material_lexicon:48). כאן רק לוודא ש-exclusions מכסה גם ערך-צבע-מהשם אם בעתיד נשתמש ב-`colorVariant`. (2) "כרום" — לשמר אותו כ*חומר/גימור* (להעבירו לציר-חומר/גימור) ולא למחקו; ה-exclusion מציר-הצבע ✓ אבל נגיש דרך ציר-אחר (החלטת-מוצר; לתעד). (3) הבדיקה (סעיף 5) צורכת את הקובץ → אין unused. (4) לאסור ייבוא מקובץ-חי בשלב זה; הבדיקה היחידה היא ה-call-site.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_color_test.dart`: (א) `cardColorOf(productWithColor('נחושת'))==null`; (ב) `cardColorOf(productWithColor('כרום'))==null`; (ג) `cardColorOf(productWithColor('לבן'))=='לבן'` (צבע-אמיתי עובר); (ד) `cardColorOptions(mixedPool)` לא-מכיל נחושת/כרום אך כן-מכיל את הצבעים-האמיתיים; (ה) טוהר/דטרמיניזם: אותה בריכה → אותו פלט, ערבוב-יציב.

**6. שיפור:** במקום רשימת-exclusions שמתיישנת, להפריד את `kLipskeyColors` לוגית לשתי-רשימות-ציבוריות: `kTrueColors` (לבן/שחור/אפור/פרגמון/כחול/אדום…) מול `kFinishesAndMaterials` (נחושת/כרום/ניקל/זהב…) — `card_color.dart` משתמש ב-`kTrueColors`. זה הופך את ה"מה-צבע-אמיתי" למקור-יחיד מפורש, וגם ציר-הגימור העתידי (כרום/ניקל/זהב) מקבל את הרשימה-המשלימה חינם.

**7. ריאלי?:** כן, אטומי — קובץ-טהור חדש + בדיקה, אפס-חי. ההחלטה היחידה הלא-טריוויאלית ("כרום צבע או גימור?") היא החלטת-מוצר קטנה שניתנת-לקיבוע כאן. אין צורך בפיצול.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new (הבדיקה צורכת את הקובץ); `card_color_test` ירוק; byte-identity של flag-OFF טריוויאלי (לא-מחווט לחי); `git diff` על `lipskey_catalog.dart` ריק (פרודקשן לא-נגע); הרצת חבילת card_keyboard המלאה ירוקה.

**9. תכנון נוסף (שלי):** להגדיר במקביל `cardFinishOf(p)` (ציר-גימור: כרום/ניקל/ניקל-מוברש/זהב/גרפיטי — כל אלו ב-`kLipskeyColors` שורות 464–466 והם גימורי-מתכת) — כי ברגע שמוציאים אותם מציר-הצבע, ההבחנה ברז-כרום↔ברז-ניקל נעלמת אם אין ציר-גימור; השלב מסיר אך לא-נותן-בית-חדש. ציר-גימור פותר זאת מיד.

**10. תכנון נוסף (שלי):** להוסיף בדיקת-מיפוי הופכית: לכל ערך ב-`kLipskeyColors`, לסווג מפורשות "צבע" / "גימור" / "חומר", ולקבע בבדיקה שאיחוד-שלוש-הקבוצות == `kLipskeyColors` (אין ערך-יתום) — כך כל ערך-עתידי שיתווסף לקטלוג יאלץ סיווג ולא ידלוף בשקט לציר-הצבע.

---

### שלב 6 — הפניית `ColorSignal` לתצוגת-צבע-הכרטיס

**1. יעד:** `ColorSignal` (`card_signals.dart:126`) משתמש בתצוגת-הצבע card-scoped משלב 5 — כך שנחושת *עוזבת* את ציר-הצבע לחלוטין (אין לה chip-צבע), ונגישה רק דרך ציר-החומר. בריכה עתירת-נחושת נותנת שבב-חומר אך *לא* שבב-צבע.

**2. איך בונים:** (א) ב-`ColorSignal.chipsFor` (שורות 133–141) להחליף `colorOptions(pool)` ב-`cardColorOptions(pool)` (משלב 5, מסונן-exclusions). (ב) ב-`ColorSignal.matches` (שורות 143–144) — היום `p.color == chip.value`; כיוון שה-chips כבר מסוננים, מוצר-נחושת לעולם לא-יקבל chip-צבע, אבל ל-robustness: `matches` יכול להישאר `p.color == chip.value` (כי אם אין chip-נחושת, אין מה-להתאים). לוודא ש-`cardColorOf` ולא `p.color` הוא מקור-האמת אם רוצים עקביות-מלאה. (ג) לא-לגעת ב-`colorOptions` ב-`narrow_axis.dart` (המנוע-החי).

**3. תקלות צפויות:** (1) **סתירת-תלות:** שלב 6 תלוי ב-4 *וגם* 5, אבל הוא ב-`_mergedChips` משתתף בדירוג-הצירים (card_engine:227–262) — הסרת chips-צבע משנה את `_AxisScore` של ציר-הצבע (פחות chips → אולי נופל מתחת `kMergedAxisFloor=2`, card_signals-merge:236 → הציר נשמט) → ה-golden-merge משתנה. אם שלב 2 קיבע golden עם chip-נחושת-צבע, השוואה תיכשל. (2) `colorVariant` (lipskey_catalog:160) עדיין מחזיר 'נחושת' מהשם — אבל `ColorSignal` לא-משתמש בו (משתמש ב-`p.color`), כך שזה לא-דולף *דרך ColorSignal*; ובכל-זאת אם בריכה כלשהי מסתמכת על `colorVariant` במקום-אחר, חוסר-עקביות. (3) מוצר שצבעו-המובנה 'נחושת' אך אין-לו-חומר-מזוהה → אחרי שלב 6 הוא לא-נגיש-בצבע *וגם* `materialOf` עלול להחזיר null → "מוצר-יתום" (לא נגיש לא בצבע ולא בחומר). (4) `kMergedAxisFloor` — ציר-צבע שירד מ-2 ל-1 chip נשמט כליל.

**4. פתרון:** (1) שלב 2 כבר תיעד את ה-golden כ-OFF-anchor; כאן מעדכנים golden-ON (אם נוצר) במכוון. ה-floor-drop הוא *רצוי* (ציר-צבע עם chip-יחיד אחרי-סינון באמת לא-מנרמל). לתעד. (2) לתקן את `colorVariant`? לא — מחוץ-להיקף (פרודקשן). לוודא בבדיקה שאף call-site ב-`card_*` לא-משתמש ב-`colorVariant`. (3) **קריטי:** לוודא ש-`materialOf` מכסה את כל-מוצרי-הנחושת — שלב 7 בדיוק לזה (`kCategoryMaterial`, material_lexicon:68); לכן סדר-התלות 6→תלוי-ב-4,5 אבל מעשית-תלוי-גם-ב-7 לכיסוי. להריץ guard: כל מוצר עם `p.color=='נחושת'` חייב `materialOf(p)!=null`. (4) `kMergedAxisFloor` — לקבל את ההשמטה כהתנהגות-נכונה; אם רוצים ציר-צבע גם עם chip-יחיד, להוריד floor — אך לא, נשמר 2.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_signals_test.dart` (הרחבה): (א) "נחושת עוזבת צבע": בריכה עם מוצרי-נחושת → `ColorSignal().chipsFor(pool)` *לא-מכיל* 'נחושת'; אך `MaterialSignal().chipsFor(pool)` *כן-מכיל* 'נחושת'. (ב) "כרום עוזב צבע" אנלוגית. (ג) צבע-אמיתי נשאר: בריכת-מושבי-אסלה (לבן/פרגמון/אפור) → `ColorSignal` כן-נותן את שלושתם. (ד) guard-יתום: לכל `p` ב-`kDivePool` עם `p.color` ב-exclusions, `materialOf(p)!=null` (מוכיח גישה-דרך-חומר).

**6. שיפור:** לאחד את הגדרת-ה-predicate: במקום `p.color == chip.value` ב-`matches`, להשתמש ב-`cardColorOf(p) == chip.value` — כך ה-chips וה-predicate נשענים על *אותו* מקור (`card_color.dart`), ולא ייתכן מצב שבו chip מסונן אבל predicate עדיין מתאים על `p.color`-הגולמי. עקביות-מקור-יחיד.

**7. ריאלי?:** כן, אטומי — שינוי דו-שורתי ב-`ColorSignal` + בדיקות. תלוי ב-4,5 (ומעשית-ב-7 לכיסוי-יתומים, ראה סעיף 4.3 — שווה לתעד תלות-רכה ב-7 או להזיז guard-היתום לשלב 9). הסיכון: golden-merge ויתומי-נחושת — שניהם מנוטרלים בבדיקות.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `card_signals_test`+`card_engine_test` ירוקים; byte-identity flag-OFF (פרודקשן: `narrow_axis.colorOptions` לא-נגע; הסינון רק בשכבת-card); guard-יתום עובר (אפס מוצר נגיש-לא-בצבע-ולא-בחומר); רגרסיית card_keyboard מלאה ירוקה.

**9. תכנון נוסף (שלי):** להוסיף *מפקד-נגישות-צבע→חומר* כבדיקה: לאסוף את כל הערכים-המוסרים-מהצבע (נחושת/כרום/פליז) ולאמת שכל-אחד מהם נגיש דרך *לפחות ציר-אחד אחר* (חומר או גימור) על-פני היקום — לא רק "materialOf != null" לכל-מוצר, אלא שהערך-עצמו עדיין מגיע-לכרטיס. זו ההוכחה הישירה לטענת-השלב "נגישה רק דרך חומר".

**10. תכנון נוסף (שלי):** לתעד ולבדוק את האינטראקציה עם `CuratedFacetSignal` (card_signals:234) — לקטגוריה `'מכסים ורשתות'` ה-facets כוללים 'נחושת' ו'שחור' כ*מילות-מפתח* (narrow_axis:85)! כלומר נחושת *עדיין* יכולה להופיע כ-facet-chip אחרי שהוסרה מציר-הצבע. צריך להחליט: זה מכוון (facet=מילה-בשם) או כפילות-מבלבלת; לכל-הפחות בדיקה שמתעדת את ההתנהגות הזו כדי שלא-תתגלה כבאג בשלב 31/58.

---

### שלב 7 — חיזוק כיסוי-חומר (פליז + עקיפות-קטגוריה)

**1. יעד:** כיסוי-החומר (`MaterialSignal.seededFraction`, card_signals:200) מוגבר: פליז מתקפל-לנחושת (כבר ב-`kMaterials['נחושת']=['נחושת','פליז']`, material_lexicon:48) ועקיפות-קטגוריה (`kCategoryMaterial`, material_lexicon:68 — ברזי-ניל/מעבר/קיר/כיור/מחלקים/נקודות-מים → נחושת) מסווגות מוצרים שטקסטם לא-אומר-זאת. התוצאה: `seededFraction` עולה כך שציר-החומר עובר את ה-gate בבריכות-יותר.

**2. איך בונים:** רוב-המנגנון *כבר-קיים* (פליז + `kCategoryMaterial` נבנו ב-#24). השלב הוא *חיזוק/הרחבה*: (א) למדוד `seededFraction(kDivePool)` ו-per-category הנוכחי. (ב) לזהות קטגוריות עתירות-מוצר עם `materialOf==null` שהן בבירור חומר-יחיד, ולהוסיפן ל-`kCategoryMaterial`. (ג) להרחיב `kMaterials` terms אם חסרים spellings (למשל 'פליז (תבריג)' שמופיע ב-`variant_families.productMaterial:241` אך לא ב-material-lexicon). (ד) לעדכן את ה-golden-חומר (משלב 2/סעיף-10) במכוון.

**3. תקלות צפויות:** (1) `materialOf` משתמש ב-`String.contains` על `'<nameHe> <categoryHe>'` (material_lexicon:81–88) — הוספת-term קצר (למשל 'PP') תתפוס false-positives (PP בתוך 'PPR' או בתוך מילה-אחרת) → סיווג-שגוי. (2) `kMaterials` הוא `ordered` וה-precedence הוא סדר-המפתחות (material_lexicon:33,82) — הוספת-מפתח-חדש *לפני* קיים משנה את סיווג מוצרים-שמתאימים-לשניים → רגרסיה שקטה ב-`materialsInPool`. (3) הגברת-כיסוי משנה אילו בריכות עוברות את `kMaterialCoverageGate=0.5` → ציר-חומר מופיע במקומות-חדשים → golden-merge משתנה (כולל `_AxisScore`). (4) `kCategoryMaterial` ממופה ב-`categoryHe` *מדויק* (material_lexicon:88) — שם-קטגוריה עם רווח/וריאציה לא-יתפס.

**4. פתרון:** (1) לעולם לא-להוסיף term שהוא תת-מחרוזת-של-term-קיים או מילה-נפוצה; כל term-חדש חייב בדיקת-false-positive על `kDivePool` (לספור כמה מוצרים נתפסים ולוודא-ידנית). (2) להוסיף מפתחות-חדשים רק *בסוף* `kMaterials` או במיקום-מתועד, ולהריץ diff על `materialsInPool(kDivePool)` לפני/אחרי. (3) golden-חומר (שלב 2/10) מתעדכן-במכוון; golden-merge-OFF לא-נגע (זה flag-ON). (4) להפיק את מפתחות-`kCategoryMaterial` מתוך הערכים-הממשיים של `categoryHe` ב-`kDivePool` (לא לנחש מחרוזת) — בדיקה שכל-מפתח ב-`kCategoryMaterial` באמת-קיים כ-`categoryHe` של ≥1 מוצר.

**5. בדיקות:** קובץ `test/features/word_finder/material_lexicon_test.dart` (הרחבה): (א) פליז→נחושת: `materialOf(brassProduct)=='נחושת'`. (ב) עקיפת-קטגוריה: מוצר ב-'ברזי ניל' עם שם-נטול-חומר → `materialOf=='נחושת'`. (ג) `seededFraction` עלה: `MaterialSignal.seededFraction(categoryPool) >= מדד-קבוע` לקטגוריות-היעד. (ד) no-false-positive: term-חדש לא-מסווג מוצר-שגוי (snapshot של `materialsInPool(kDivePool)`). (ה) כל מפתח ב-`kCategoryMaterial` קיים כ-`categoryHe` אמיתי.

**6. שיפור:** להחליף את `String.contains`-על-terms ב-`materialOf` במנגנון word-boundary (RegExp `\b` או split-tokens) לפחות לטוקנים-לטיניים (PP/PPR/PEX/HDPE) — מסיר את כל מחלקת ה-false-positive-של-תת-מחרוזת בלי-לשבור עברית. זה הופך את הרחבת-הכיסוי לבטוחה-מבנית במקום ביקורת-ידנית-לכל-term.

**7. ריאלי?:** כן, אטומי — הרחבת-data (מפות-const) + בדיקות. *אבל* "חיזוק-כיסוי" הוא open-ended; כדאי לתחום אותו ליעד-מספרי מפורש (למשל "להעלות seededFraction-גלובלי מ-X% ל-Y%") ולא "כמה-שיותר", אחרת השלב נמרח. לא-פיצול, אבל קיבוע-יעד.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `material_lexicon_test` ירוק כולל no-false-positive; byte-identity flag-OFF (כל-זה תחת ציר-חומר שהוא חלק מ-card-engine מאחורי-דגל — פרודקשן זהה); diff מבוקר על `materialsInPool(kDivePool)` (כל שינוי-סיווג מכוון ומתועד); רגרסיית word_finder מלאה (כי material_lexicon נצרך גם ע"י word_finder_screen).

**9. תכנון נוסף (שלי):** להוסיף *מד-כיסוי-מתועד* — בדיקה שמדפיסה (או מקבעת) את `seededFraction` per-categoryHe על `kDivePool`, ממוין-עולה, כך שרואים מיד אילו קטגוריות עדיין מתחת-לגייט והן מועמדות-הבאות ל-`kCategoryMaterial`. זה הופך את "חיזוק-הכיסוי" מניחוש למונחה-נתונים, וגם נותן baseline ל-`materialCoverage` של שלב 9.

**10. תכנון נוסף (שלי):** ליישב את שתי-טקסונומיות-החומר *כבר עכשיו* (לא רק בשלב 8): `material_lexicon.materialOf` (7 מפתחות: נחושת/PPR/HDPE/רב-שכבתי/פקס/נירוסטה/פלדה) מול `variant_families.productMaterial` (13 buckets שונים: PVC/PP/NTM/גמיש/...). יש סיכון שהן יסווגו את אותו-מוצר שונה ויבלבלו בשלב 8. להוסיף בדיקת-עקביות שמתעדת היכן הן חלוקות, כדי ש-`cardMaterialOf` (שלב 8) ייבנה מתוך-הבנה ולא-יסתור.

---

### שלב 8 — יישוב `variant_families` material על `materialOf`

**1. יעד:** קיים wrapper `cardMaterialOf(p)` שמאחד את סמנטיקת-החומר תחת `materialOf` (material_lexicon) כמקור-יחיד לשכבת-הכרטיס, בעוד `variant_families.productMaterial` (variant_families:232) נשמר ללא-שינוי לקריאות-הפרודקשן הקיימות שלו (קיבוץ-וריאנטים תחת "קוטר"). התנהגות-הפרודקשן זהה; שכבת-הכרטיס מפסיקה לשאול שתי-מקורות-חומר סותרים.

**2. איך בונים:** (א) להגדיר `String? cardMaterialOf(LipskeyCatalogProduct p)` — עוטף את `materialOf(p)` (material_lexicon). (ב) לאתר את כל קריאות-החומר בשכבת-card_keyboard ולוודא שכולן עוברות דרך `cardMaterialOf`/`materialOf` ולא `productMaterial`. (ג) `productMaterial` (variant_families) נשאר לקוראיו-החיים: `variant_families` עצמו, ו-`line_score.dart` (אותר ב-grep). לא-לגעת בהם. (ד) לתעד את ה-mapping: היכן `cardMaterialOf` שונה מ-`productMaterial` ולמה זה-בסדר.

**3. תקלות צפויות:** (1) **טקסונומיות-שונות:** `productMaterial` תמיד-מחזיר-ערך (ברירת-מחדל 'אחר', variant_families:247) בעוד `materialOf` מחזיר `null` כשלא-מזוהה. wrapper שמחקה-`productMaterial`-API (non-null) ישבור את ה-gate של `MaterialSignal` (שמסתמך על null=לא-מזוהה, card_signals:201–203). (2) `productMaterial` כולל buckets ש-`materialOf` לא-מכיר (PVC/PP/NTM/גמיש/'קרמיקה/פלסטיק'/'ברזים/מקלחות') — אם נחליף קריאה-חיה ל-`materialOf` בטעות, נאבד buckets ב-`variant_families` והקיבוץ-תחת-קוטר ישתנה → רגרסיית-פרודקשן. (3) `census-callers` (לשון-התוכנית) — צריך למצוא *כל* קורא; פספוס-קורא = חוסר-עקביות. (4) byte-identity: `variant_families` נצרך ע"י קוד-פרודקשן חי (catalog) — כל שינוי-חתימה שם שובר.

**4. פתרון:** (1) `cardMaterialOf` *לא* מחקה את `productMaterial`-API; הוא nullable כמו `materialOf`. כל ההיגיון של ה-gate נשמר. (2) **לא-להחליף** אף קריאה-חיה ל-`productMaterial`; השלב הוא *הוספת*-wrapper לשכבת-card בלבד + מפקד-מוודא, לא-מיגרציה-של-variant_families. ה"יישוב" הוא: שכבת-card משתמשת ב-`materialOf`-בלבד (כבר-עכשיו `card_signals` כך), ו-`productMaterial` נשאר עצמאי. (3) מפקד דרך `Grep` על `productMaterial` בכל `lib/features/card_keyboard/` (כיום: אפס — `card_signals` כבר משתמש ב-`materialOf`!) → אז השלב הוא בעיקר *קיבוע-עובדה* + בדיקה. (4) אפס-שינוי ל-`variant_families.dart`.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_material_of_test.dart`: (א) `cardMaterialOf == materialOf` לכל `kDivePool` (ה-wrapper הוא pass-through). (ב) census: אין שום `productMaterial` בשימוש תחת `lib/features/card_keyboard/` (בדיקת-מקור/grep-assert, או הערה+CI-check). (ג) התנהגות-`variant_families` זהה: `productMaterial(p)` על דגימות → ערכים-קבועים (snapshot, מוודא שלא-נגע). (ד) nullable-נשמר: קיים `p` ב-`kDivePool` ש-`cardMaterialOf(p)==null` (מוכיח שלא-הפכנו ל-non-null).

**6. שיפור:** במקום wrapper-ריק (`cardMaterialOf == materialOf`), לתת לו ערך-מוסף: למזג את עקיפות-הקטגוריה של `productMaterial` שכן-מדויקות (למשל 'גמיש'/'אפור (PVC ניקוז)' — buckets ש-`materialOf` *חסר*) לתוך `kCategoryMaterial` של material_lexicon, כך ש-`materialOf` משתפר ו-`cardMaterialOf` באמת-מאחד את הטוב-משתי-הטקסונומיות במקום סתם-pass-through. אחרת ה-wrapper מיותר.

**7. ריאלי?:** כן, אטומי — קטן מאוד (כיום `card_signals` *כבר* על `materialOf`, אז זה בעיקר קיבוע+בדיקה+census). תלוי ב-7. אם בוחרים בגרסת-השיפור (מיזוג-buckets) זה גדל-מעט אך עדיין אטומי. אין-פיצול.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `card_material_of_test` ירוק; census-grep מאשר אפס-`productMaterial` ב-card-layer; byte-identity flag-OFF (variant_families לא-נגע → פרודקשן-קטלוג זהה-בייטים); רגרסיית variant_families/line_score ירוקה (לוודא שלא-נשבר קיבוץ-הוריאנטים החי).

**9. תכנון נוסף (שלי):** להוסיף בדיקת-טבלת-המרה מפורשת `productMaterial-bucket → cardMaterialOf-key` (או null) — מתעדת לכל אחד מ-13 ה-buckets של variant_families מה-המקבילה-בשכבת-card; כך ההחלטה "PVC/PP/NTM אין-להם-ציר-חומר-בכרטיס" היא מודעת-ומתועדת ולא-מקרית, ושלב-עתידי שירצה להוסיף ציר-PVC יודע-בדיוק מה-חסר.

**10. תכנון נוסף (שלי):** לאחד גם את `colorVariant`/`productType`/`productSubtype` getters (lipskey_catalog:160/169/178) למסקנה: השלב נוגע ב"מקור-חומר-יחיד", אבל יש *עוד* getters-נגזרים-מהשם בקטלוג שעלולים לסתור את ציר-ה-card; להוסיף הערת-מעקב/בדיקה שמוודאת ש-`cardMaterialOf` ו-`productType` לא-מתנגשים (מוצר שסומן חומר-נחושת לא מסומן בטעות type-נחושת), כדי למנוע כפילות-ציר בשלבי-המיזוג (P7).

---

### שלב 9 — החלטת-סמנטיקת-חומר פעם-אחת (gate-exempt-via-seed) + כיסוי-נצפה

**1. יעד:** `kMaterialCoverageGate` עובר מ-`const` top-level (card_signals:37) לשדה-instance על `MaterialSignal`, ונוספים `materialCoverage(pool)` (חושף את ה-seededFraction-הנצפה) ו-`materialAlwaysOn` (דגל): כש-זרע-חומר נבחר במפורש (המשתמש לחץ 'חומר'), ציר-החומר *פטור-משער* ונשאר פתוח-ומתחרה גם מתחת-לגייט. **זה מסלק את סתירת-P3-מול-P7** (P3 רוצה ציר-חומר-זמין-תמיד-כפה; P7 רוצה gate לפי-info-gain). בריכת-30%-חומר *כן* נותנת שבבי-חומר כשהזרע-חומר; ברירת-מחדל (ללא-זרע) זהה-בייטים להיום.

**2. איך בונים:** (א) להפוך `MaterialSignal` ל-בעל-שדות: `final double coverageGate;` `final bool materialAlwaysOn;` עם constructor-defaults (`coverageGate = kMaterialCoverageGate`, `materialAlwaysOn = false`) — כך `const MaterialSignal()` הקיים (card_signals:275) נשאר תקף וברירת-המחדל זהה. (ב) `chipsFor` (שורות 207–218): התנאי `if (seededFraction(pool) < gate)` הופך ל-`if (!materialAlwaysOn && seededFraction(pool) < coverageGate)`. (ג) להוסיף `static double materialCoverage(pool) => seededFraction(pool)` (alias-נצפה ציבורי). (ד) ב-`sourcesFor`/`_mergedChips`: כשהזרע-הנוכחי הוא חומר (axis-answered=='חומר' או seed-axis=='חומר'), להזריק `MaterialSignal(materialAlwaysOn: true)`. (ה) להגדיר את ה-`kOpeningSeedAxis`/סמנטיקה כך ש"זרע-חומר אינו מסמן axis-answered" (תיאום עם שלב 31).

**3. תקלות צפויות:** (1) **בדיקות-קיימות נשברות:** `card_signals_test.dart:73–85` מקבע את ה-gate כ-`seededFraction < kMaterialCoverageGate` STRICT-< עם גבול-0.5-מדויק ("seededFraction == 0.5 is NOT below the gate → axis SHOWS", "1/3 < gate → HIDES"). הפיכת-הגייט ל-instance + always-on משנה את החתימה/ההתנהגות → הבדיקות-הללו נכשלות-קומפילציה או לוגית. (2) `const MaterialSignal()` ב-`kHardSignals` (card_signals:270–276) — אם נוסיף שדה-non-final או default לא-const, ה-`const` נשבר → שגיאת-קומפילציה בכל call-site. (3) הזרקת-`always-on` ב-`_mergedChips` משנה את `_AxisScore` (ציר-חומר נכנס-לדירוג גם ב-30%) → golden-merge משתנה כשיש-זרע-חומר. (4) `materialAlwaysOn` שמתעלם-מהגייט תמיד עלול להציג ציר-חומר עם chip-יחיד (`materialsInPool` בגודל-1) → ה-floor (`kMergedAxisFloor=2`) עדיין-מסנן, אבל הסמנטיקה "פתוח-ומתחרה" מול floor-2 צריכה תיאום.

**4. פתרון:** (1) לעדכן את `card_signals_test:73–85` במכוון: לפצל לשני-תרחישים — (ברירת-מחדל, no-seed) הגבול-0.5-STRICT נשמר; (always-on) הגייט-לא-חל. הבדיקות-החדשות מקבעות את שתי-הסמנטיקות. (2) לשמור `const`-תקינות: שדות `final` + default-const- values → `const MaterialSignal()` עדיין-const; `MaterialSignal(materialAlwaysOn: true)` הוא non-const (תקין, נוצר בזמן-ריצה ב-`sourcesFor`). לוודא ש-`kHardSignals` נשאר `const` (משתמש ב-default-ctor). (3) golden-merge-עם-זרע-חומר הוא תרחיש-ON חדש; golden-OFF (no-seed) זהה-בייטים — לקבע את שניהם בנפרד. (4) להשאיר `kMergedAxisFloor` כפי-שהוא; "פתוח-ומתחרה" פירושו "נכנס-לדירוג", לא "נכפה-גם-עם-chip-בודד" — floor-2 עדיין-תקף, מתועד.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_signals_test.dart` (עדכון+הרחבה): (א) ברירת-מחדל: `MaterialSignal()` עם בריכת-30% → `chipsFor` ריק (גייט-חל). (ב) always-on: `MaterialSignal(materialAlwaysOn:true)` עם אותה-בריכת-30% → `chipsFor` *לא-ריק* (פטור-משער). (ג) גבול-0.5 STRICT נשמר ל-default (re-assert של הבדיקה-הישנה). (ד) `materialCoverage(pool)==seededFraction(pool)`. (ה) `const MaterialSignal()` עדיין-const (קומפילציה). (ו) flag-OFF/no-seed זהה-בייטים: `_mergedChips` ללא-זרע-חומר == golden שלב-2.

**6. שיפור:** במקום `bool materialAlwaysOn` בינארי, להגדיר את הסמנטיקה כ-`coverageGate` שהזרקת-הזרע *מאפסת* (`MaterialSignal(coverageGate: 0)`) — שדה-אחד במקום-שניים, ופחות-מצבים-לבדוק. בנוסף, לתעד את ההחלטה כ-enum מפורש `MaterialAxisMode { gated, seedExempt }` כדי ש-P3 (שלב 31) ו-P7 (שלב 65) יקראו את אותו-מקור-החלטה ולא-ימציאו-מחדש את "מתי-חומר-פטור".

**7. ריאלי?:** כן, אטומי — שינוי ממוקד ב-`MaterialSignal` + עדכון-בדיקה. זהו שלב-החלטה קונספטואלי ("פעם-אחת") אך מימושו קטן. הסיכון-הגבוה הוא שבירת-`const` ושבירת-בדיקות-הגבול — שניהם ידועים-ומנוטרלים. אין-פיצול, אך חובה לתאם עם שלבים 31/65 שמסתמכים על ההחלטה.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new (כולל אימות ש-`const MaterialSignal()` לא-מייצר אזהרה); כל `card_signals_test` ירוק עם שתי-הסמנטיקות; byte-identity flag-OFF *וגם* no-seed-path (קריטי — ברירת-המחדל חייבת להישאר זהה-להיום, אחרת שלב-9 דולף לפרודקשן-העתידי); רגרסיית card_keyboard מלאה; אין leak (instance-fields, לא static-mutable-state — חשוב ל-employer-isolation, build-plan §3).

**9. תכנון נוסף (שלי):** "סתירת-P3-מול-P7" שהשלב מצהיר-שהוא-מסלק חוצה-גם-את-שלב-2-golden: צריך לקבע *שני* goldens מפורשים — `golden_merge_noMaterialSeed` (גייט-חל, היום) ו-`golden_merge_withMaterialSeed` (פטור) — ולתעד שמרגע-זה כל שינוי-merge נמדד מול הזוג. בלי זה, שלבי-65/66 שמשנים-דירוג לא-יבחינו אם שברו את סמנטיקת-הפטור.

**10. תכנון נוסף (שלי):** להגדיר ולבדוק את אינטראקציית-הפטור עם `answered` (card_engine:222): השלב אומר "זרע-חומר אינו מסמן axis-answered" — אבל `_mergedChips` מדלג על ציר ש-`answered.contains(src.axisName)` (שורה 229). צריך הוכחה-מפורשת שאחרי לחיצת-'חומר', ציר-החומר *עדיין-מופיע* בסבב-הבא (לא-סומן-answered) *וגם* פטור-משער — אחרת המשתמש לוחץ-נחושת והציר-נעלם, סותר את כוונת-השלב. בדיקה: stack עם צעד-חומר → `mergedKeys` הבא עדיין-כולל chips-חומר.

---

### שלב 10 — ניקוד-גודל כן מעל הקיפול-הקנוני במיזוג

**1. יעד:** במיזוג (`_mergedChips`, card_engine:217), ניקוד-ציר-הגודל מחושב *מעל הקיפול-הקנוני* (שלב 3–4) — שבב-אחד-לכל-בור-קנוני, כך שה-`(sumSq,n)` של ציר-הגודל משקף קיבוץ-אמיתי ולא תוויות-כפולות; ו-`representativeTake` (card_engine:308) שומר-קצוות (הקטן והגדול ביותר) מעל הבורות-הקנוניים. הניקוד "כן" = expRem של הגודל מודד את מה-שלחיצת-chip-קנוני באמת-מספקת.

**2. איך בונים:** (א) כיוון ששלב 4 כבר הפך את `SizeSignal.chipsFor` ל-chip-לכל-בור ואת `matches` ל-canonical-aware, לולאת-הניקוד הגנרית ב-`_mergedChips` (שורות 250–255, `pool.where((p)=>src.matches(p,chip))`) *כבר* מנקדת מעל-הקנוני — אז עיקר-העבודה הוא *אימות* שזה-קורה. (ב) לוודא ש-`representativeTake` עדיין-נכון: הוא דוגם לפי-אינדקס מתוך `a.chips` הממוינים-mm (card_engine:291–293); אחרי-הקיבוץ-הקנוני הסדר-מ-`SizeSignal` הוא mm-עולה-לפי-נציג → endpoints עדיין הקיצוניים. (ג) לבדוק בריכה-מעורבת DN/inch/mm שהקיפול-עובד-במיזוג: `value`-קנוני זהה ל-DN15/½"/15mm נספר פעם-אחת.

**3. תקלות צפויות:** (1) **כפל-ספירה הפוך:** אם הקיפול-הקנוני (שלב 4) אגרסיבי-מדי, שני-בורות-שונים-פיזית מתמזגים ל-chip-אחד → `sumSq` של הגודל *יורד-מלאכותית* → ציר-הגודל מדורג-ראשון-תמיד (expRem-נמוך-כוזב) → דוחק צירים-אמיתיים. (2) `representativeTake` ממיין לפי mm-של-הנציג, אבל הנציג-הקנוני נבחר ב-tie-break-sku (שלב 4) — אם הנציג אינו-בהכרח-בעל-mm-המייצג-את-הבור, הסדר-mm עלול לא-להיות-מונוטוני → endpoints שגויים. (3) ה-mm של `value`-קנוני: `matches` סופר `distinctCardCount(narrowed)` — אבל `narrowed` תלוי ב-`canonicalSize` per-product (יקר, נתיב-חם, שורות 250–255 × chips × axes). (4) golden-merge משתנה (פחות-chips-גודל, ערכי-sumSq-שונים) → צריך re-bless מכוון.

**4. פתרון:** (1) ההגנה היא שלב-3 *מדויק* (מילון-בורות-מפורש, לא-סף-עיוור — ראה שלב 3/סעיף 4); בדיקה (סעיף 5) שמוודאת ש-`sumSq`-הגודל-הקנוני *סביר* (לא-קורס-ל-bucket-יחיד על בריכה-מגוונת). (2) לוודא ב-`SizeSignal` שהנציג-הקנוני נושא את ה-mm-של-הבור (לא mm-שרירותי) — להעביר את ה-mm-הקנוני יחד עם ה-chip (אולי דרך infoGain-זמני או שדה-עזר), כך ש-`representativeTake` ממיין-נכון; או למיין את chips-הגודל לפי mm-הבור-הקנוני לפני-הדגימה. (3) memoize `canonicalSize` ובניית `sku→Set<canonicalKey>` פעם-אחת (כמו שלב 4/סעיף 4). (4) re-bless golden-merge-ON במכוון; OFF זהה.

**5. בדיקות:** קובץ `test/features/card_keyboard/card_engine_test.dart` (הרחבה): (א) בריכה-מעורבת DN/inch/mm שכולם-אותו-בור → ב-`MergedKeys.chips` יש *chip-גודל-אחד* לאותו canonical (לא-שלושה). (ב) endpoints: ה-chips-גודל ב-`MergedKeys` כוללים את הבור-הקטן-ביותר ואת-הגדול-ביותר של הבריכה (representativeTake שומר-קצוות). (ג) ניקוד-כן: על בריכה שבה הגודל *לא* הציר-המפצל-ביותר, ציר-הגודל *לא* מדורג-ראשון (הקיפול לא-מנפח אותו מלאכותית). (ד) per-chip-narrow: `matches` של chip-קנוני שומר את כל-המוצרים-מכל-שלוש-התוויות.

**6. שיפור:** להוסיף ל-`SignalChip` שדה-אופציונלי `sortKey`/`mm` (כבר יש `infoGain` שלא-בשימוש-כ-sort, card_engine:73) המאוכלס בציר-הגודל ל-mm-הבור-הקנוני, כך ש-`representativeTake` ממיין לפיו במפורש במקום-להסתמך על-סדר-קלט — הופך את "שומר-קצוות" למובטח-מבנית ולא-תלוי-בסדר-הקיבוץ. זה גם-מכין את הקרקע ל-Phase-3 (per-chip-weight) שה-docstring (card_engine:206–213) כבר-צופה.

**7. ריאלי?:** כן, אטומי — ברובו *אימות+בדיקה* מעל מה-ששלב-4 כבר-בנה, פלוס תיקון-קטן ל-`representativeTake`-ordering אם-צריך. תלוי ב-4 (וב-3). הסיכון: אם הקיבול-הקנוני שגוי, הניקוד מתעוות — אבל זה-תופס-בבדיקת-סעיף-5.ג. אין-פיצול.

**8. וידוא-פיקס מלא:** `flutter analyze` 0-new; `card_engine_test`+`card_signals_test` ירוקים; golden-merge-OFF זהה-בייטים (no-flag פרודקשן); golden-merge-ON מבורך-מחדש-במכוון; בדיקת-shuffle (ערבוב-בריכה → אותו-merge) מאשרת שהקיפול-הקנוני לא-הכניס תלות-סדר; אין leak (memoize ברמת-קריאה).

**9. תכנון נוסף (שלי):** להוסיף בדיקת-אינווריאנט חוצת-ציר: אחרי הקיפול-הקנוני, `expRem(size) >= expRem-של-ציר-שבאמת-מפצל-יותר` בבריכות-מבחן — כלומר לוודא שהקיפול *לא* שובר את סדר-הדירוג היחסי הצפוי. בלי זה, באג-קיפול עלול להפוך את הגודל ל"מנצח-תמיד" בלי-שאף-בדיקה-בודדת-תיכשל (כל בדיקה בודקת בריכה-אחת; האינווריאנט בודק יחס).

**10. תכנון נוסף (שלי):** לגזור את ה-`representativeTake`-count מהמבנה (מספר-הבורות-הקנוניים) ולא מקבוע-`kMergedAxisMaxPerAxis=4` עיוור — אחרי הקיפול ייתכן שבבריכה יש בדיוק-3-בורות-גודל, ואז `take=4` מחזיר-3 (תקין) אבל בבריכה עם 20-בורות, 4-נציגים מאבדים-את-האמצע; להוסיף בדיקה/לוגיקה שמוודאת שהנציגים-הקנוניים מכסים את הטווח באופן-מייצג (לא-רק-קצוות) כשהבורות-רבים, אחרת מוצרי-האמצע פחות-נגישים — מה שמסכן את חוזה-ה-≤6 של שלב 33/42.

</div>

<div dir="rtl">

# MONSTER — פירוק-מפורט שלבים 11–20 (10 נקודות לכל שלב)

> מקור-אמת: `C:/Users/User/Desktop/benzi-kb-build/app_flutter` בלבד. כל קלון `New folder/buildsmart` הוא STALE והתעלמתי ממנו.
> **שלב 11** סוגר את P1 (יסוד-נתונים); **שלבים 12–20** הם תחילת P2 (יסוד-מצב: מועדפים, כותב-אחד ל"נצפו", מיגרציית savedConfigs, שכבת last-touched, היקף-זהות).
>
> **ממצא-מסגרת קריטי שמשנה כמה ניתוחים למטה (אומת בקוד):**
> 1. `kReachUniverse`, `canonicalSize()`, `card_color.dart`, `cardMaterialOf`, `materialCoverage`/`materialAlwaysOn` — **עדיין לא קיימים** בקוד. הם תוצרי שלבים 1–10 ש**טרם נבנו**. שלב 11 תלוי בהם ישירות (תלוי: 6,9,10). כלומר 11 אינו אטומי אם 1–10 לא נחתמו.
> 2. `productFavoritesProvider.toggle()` **אינו נקרא באף מקום ב-`lib`** היום (אומת: `grep` מצא רק את ההגדרה ב-`state/product_favorites.dart`, אפס call-sites של toggle/UI). הכוכב ב-`catalog_screen.dart:5138` הוא `savedConfigsProvider.toggle(p.key, brand.name)` (תצורת מוצר#מותג), וה-`favSkus` ב-`catalog_screen.dart:7143` (`_FavoritesSection`) הוא **קריאה-בלבד**. לכן "★-הקטלוג" שהתוכנית מבקשת להפנות (שלב 16) **אינו כותב מועדפים כיום** — אין מה "להפנות", צריך קודם *לחבר* כותב.
> 3. כותב "נצפו לאחרונה" יחיד קיים כיום: `catalog_screen.dart:4506` (`recentlyViewedProvider.notifier.touch(sku)` ב-`initState` של כרטיס-הקטלוג, post-frame). ה-`grep` מצא **כותב יחיד** ב-`lib`, לא שניים. הציון בתוכנית "(:4395,:4506)" שגוי-עכשווי: 4395 הוא `brandHistoryProvider.record(...)` (לא recently-viewed), וה-sheet (`lipskey_product_sheet.dart`) **אינו** כותב recently-viewed כלל. הכותב-השני שהתוכנית מניחה ייווצר רק כשהכרטיס-המאוחד יזרים אל ה-sheet.

---

### שלב 11 — קיבוע golden טרי אחרי תיקוני-P1 + אינווריאנטים חוצי-ציר
**1. יעד:** אחרי שכל תיקוני-P1 (קיפול-גודל קנוני 3/4/10, נחושת יוצאת מציר-הצבע 5/6, כיסוי-חומר 7/8, סמנטיקת-חומר gate-exempt 9) נכנסו, יש שני עוגנים נבדלים: golden **flag-ON חדש** ל-`_mergedChips`/`mergedKeys` שמתעד את ההתנהגות-החדשה (נחושת רק כשבב-חומר, גודל מקופל לבור-קנוני), **בנפרד** מ-golden ה-flag-OFF של שלב 2 (שעדיין חייב להישאר זהה-בייטים). בנוסף נחתם קובץ `data_axis_invariants` שמוכיח תכונות חוצות-ציר שלא היו אכיפות קודם (לדוגמה: אין sku שמופיע גם כשבב-צבע וגם כשבב-חומר עבור נחושת; כל בור-גודל קנוני מיוצג בשבב-אחד-לכל-היותר).
**2. איך בונים:** (א) קודם לוודא ש-6+9+10 חתומים (תלות מוצהרת). (ב) ליצור `test/card_keyboard/merged_keys_golden_on_test.dart` שמריץ `mergedKeys(pool, stack, lexicon, subtype)` על 3–4 בריכות-זרע מייצגות (ברז, מרפק, צינור) ומקבע את רשימת ה-`SignalChip` המלאה (axisId+value+displayLabel+axisName) כליטרל-מקור. (ג) ליצור `test/card_keyboard/data_axis_invariants_test.dart` עם property-checks חוצי-ציר מעל `kReachUniverse` (היקום הקנוני משלב 1). (ד) להריץ `flutter analyze` ולוודא zero-new, ולברך את ה-golden פעם-אחת.
**3. תקלות צפויות:** (א) **תלות-רפאים** — `kReachUniverse`/`canonicalSize`/`card_color.dart` עדיין לא בקוד (אומת ב-`grep`), אז אי-אפשר לכתוב את האינווריאנטים כפי שמנוסחים; השלב נשען על scaffolding שטרם נבנה. (ב) **golden-כפול מתנגש** — ב-`card_engine.dart` כיום `_mergedChips` הוא **כבר ממומש מלא** (לא stub כפי שה-docstring בשורות 10–14 ו-148 עוד טוען "PHASE 0 stubbed"); golden ON שנכתב מול docstring ישן יתאר התנהגות שגויה. (ג) **חוסר-יציבות תחת shuffle** — אם בור-גודל לא באמת קופל (כי 3/4/10 לא נכנסו), `representativeTake` ב-`card_engine.dart:308` ידגום אינדקסים שונים בין הרצות וה-golden יהבהב. (ד) **דליפת flag** — אם בטעות ה-golden-ON מאותחל דרך `featureFlagsProvider` במקום `forceLiveForTest`, מספר ה-overrides ב-`ProviderScope` ישתנה ו-Riverpod יזרוק על re-pump.
**4. פתרון:** (א) לחסום את 11 עד ש-1–10 ירוקים (gate בתזמורת, לא לכתוב את 11 "על יבש"). (ב) **לתקן קודם את ה-docstrings** ב-`card_engine.dart:10–14,148` שעדיין אומרים "stubbed to empty" — זה היה אמור לקרות בשלב 1 ("ליישב הערות-ראש"); אם לא קרה, לבצע כאן כתת-משימה-0. (ג) לבסס את ה-golden-ON על בריכות-זרע **דטרמיניסטיות** וקבועות, ולהריץ אותו 3× עם `pool.reversed` כדי לאמת byte-stability לפני הברכה. (ד) לבנות את שני ה-golden עם `forceLiveForTest:true`/קריאה-ישירה ל-`mergedKeys` (טהור, ללא Riverpod) — אין צורך ב-scope כלל למנוע טהור.
**5. בדיקות:** `test/card_keyboard/merged_keys_golden_on_test.dart` — מקבע את ה-`List<SignalChip>` המדויק ל-≥3 בריכות, ומאמת שהרצה על `pool` ועל `pool.reversed` נותנת רשימה זהה (byte-stable). `test/card_keyboard/data_axis_invariants_test.dart` — לכל מוצר ב-`kReachUniverse`: (1) אם `materialOf(p)=='נחושת'` אז הוא לא נמצא ב-`colorOptions` של בריכה שמכילה אותו; (2) כל שני שבבי-גודל ב-`mergedKeys` נבדלים ב-`canonicalSize(value)` (אין כפילות-בור); (3) `mergedKeys` לעולם לא ריק כש-`distinctCardCount(pool) > kShowProductsThreshold` ויש ציר-מפצל. golden-OFF הקיים משלב 2 חייב להישאר ירוק ללא שינוי.
**6. שיפור:** במקום golden-ליטרל שביר, לאחסן את ה-golden כקובץ-`.json` נלווה ולהשוות עם matcher שמדפיס diff קריא בכשל — מקצר זמן-תיקון כשמברכים-מחדש. בנוסף, לחלץ את "בריכות-הזרע המייצגות" לקבוע משותף `kGoldenSeedPools` שגם 64/66/84 (golden עתידיים) ישתמשו בו, כדי שכל ה-golden ינועו יחד ולא יסתרו.
**7. ריאלי?:** **לא אטומי כפי שמנוסח** — הוא צרור-תלות של 6+9+10 שלא קיימים, פלוס שתי-יצירות-בדיקה נבדלות (golden-ON ו-invariants) שהן באמת שתי משימות. לפצל ל: **11a** קיבוע golden-ON (תלוי 10), **11b** `data_axis_invariants` (תלוי 6,9), **11c** ראקונסיליאציית-docstrings (חוב משלב 1). כל תת-שלב אטומי+בר-בדיקה.
**8. וידוא-פיקס מלא:** `dart run flutter analyze` = zero-new (להשוות מול baseline 18 infos משלב 1). להריץ `flutter test test/card_keyboard/` כולה + הרצת-רגרסיה של חבילות ה-word_finder הקיימות (כדי לאמת שתיקוני-P1 לא נגעו במנוע-החי). לאמת byte-identity flag-OFF: golden-OFF משלב 2 ירוק מילה-במילה. taskkill dart לפני ההרצה; retry-wrap לכשלי-טעינת-isolate (לא `tail`).
**9. תכנון נוסף (שלי):** התוכנית מקבעת golden אך **לא מקבעת את היקום עצמו**. צריך כאן בדיקת-`count` קשיחה: `expect(kReachUniverse.length, <מספר-מדויק>)` — אחרת תיקון-נתונים עתידי יכווץ/ינפח את היקום בשקט וה-golden "יעבור" על יקום שונה. זו בדיוק האזהרה ב-§ "הוכחת-החוזה" (נטען-שווה כדי שלא יתכווץ בשקט).
**10. תכנון נוסף (שלי):** להוסיף אינווריאנט-`displayLabel`-≠-`value` ממוקד-גודל: כיום ב-`card_signals.dart:90` ה-`SizeSignal` מציב `value==displayLabel` (קיפול עוד לא קרה). אחרי 4/10 זה יתפצל. בדיקה שמוודאת **שלשבב-גודל יש `value`=מפתח-קנוני אבל `displayLabel`=תווית-גולמית** תתפוס רגרסיה שבה מישהו "מתקן" את הקיפול בחזרה ל-passthrough ושובר את כל הרציונל של `SignalChip` (ההפרדה value/displayLabel, שורות 53–66 ב-`card_engine.dart`).

---

### שלב 12 — כוכב-מועדפים אמיתי בכותרת-הכרטיס
**1. יעד:** ב-`lipskey_product_sheet.dart` יש toggle-כוכב לחיץ ליד כפתור ה-Close (השורה ב-`:411–438`, ה-`Align` עם `Icons.close`), שכותב/מסיר את ה-sku הנוכחי ב-`productFavoritesProvider`. אחרי השלב: טאפ על הכוכב → ה-sku נכנס לסט-המועדפים והאייקון מתמלא; טאפ-חוזר → מוסר. זהו **הכותב-הראשון בכלל** ל-`productFavoritesProvider` (כיום אין אף אחד).
**2. איך בונים:** (א) ב-`_LipskeyProductSheetState.build`, להוסיף ליד ה-Close `Consumer`/שימוש ב-`ref` (ה-sheet כבר `ConsumerStatefulWidget`, שורה 102) שקורא `ref.watch(productFavoritesProvider)`. (ב) לחשב את ה-sku הנוכחי מ-`_current.recBrand.sku` (אותו מקור כמו ב-`catalog_screen.dart:4503`). (ג) `IconButton`/`InkWell` עם `Icons.star`/`Icons.star_border` לפי `favSkus.contains(sku)`, `onTap: () => ref.read(productFavoritesProvider.notifier).toggle(sku)`. (ד) Semantics `button:true,label:'מועדף'` + Tooltip, בעקבות תבנית ה-Close הקיימת (שורות 419–423). (ה) הכל מאחורי `kCardKeyboard`? — **לא**: זה תיקון-מצב אמיתי שמשפר את ה-sheet הקיים גם בלי הדגל, אבל כדי לשמור זהות-בייטים בפרודקשן עד "תדחוף" כדאי לעטוף את הכוכב ב-`if (live)` כמו שאר #38.
**3. תקלות צפויות:** (א) **sku-null** — `recBrand.sku` יכול להיות null (ב-`catalog_screen.dart:4504` יש שמירה מפורשת `if (sku != null)`); כוכב על מוצר ללא-sku יקרוס ב-`toggle(null)`. (ב) **race ב-`_load`** — `ProductFavoritesNotifier._load` (שורות 17–22) אסינכרוני; אם המשתמש מקיש כוכב לפני שה-prefs נטענו, ה-`_userTouched` (שורה 15) מגן — אבל רק אם משתמשים ב-`toggle` ולא משכתבים state ישירות. (ג) **זהות-בייטים** — הוספת ווידג'ט לכותרת **משנה את ה-layout** של ה-sheet; אם לא מאחורי דגל, זה שובר byte-identity של המסך החי (ה-Close היה Align-יחיד; עכשיו Row). (ד) **כפילות-מקור-sku** — ה-sheet כבר מחזיק `_chipOverride` ו-`_current`; אם לוקחים sku מ-`widget.product` במקום מ-`_current`, הכוכב יסמן את המוצר-הראשי במקום הווריאנט-הנבחר.
**4. פתרון:** (א) `final sku = _current.recBrand.sku; if (sku == null) return const SizedBox(width:48);` — לשמור על אותו רוחב-48 כמו ה-spacer ב-`card_keyboard_screen.dart:422` כדי לא לקפוץ layout. (ב) להשתמש *תמיד* ב-`.notifier.toggle(sku)` (לא הצבת-state), כך ש-`_userTouched` מגן מפני ה-late-load. (ג) לעטוף את הכוכב ב-`final live = ref.watch(featureFlagsProvider).contains(kCardKeyboardFlag);` ולהראותו רק כש-live (או להחליט במפורש שזה תיקון-כללי ולברך golden-sheet חדש). (ד) לקרוא sku מ-`_current` (הווריאנט הפעיל), עקבי עם שאר ה-sheet.
**5. בדיקות:** `test/card_keyboard/sheet_favorite_star_test.dart` — pump של `LipskeyProductSheet` עם `forceLiveForTest`-מקביל (ה-sheet עוד לא חושף כזה; ראו תקלה), `find` של הכוכב, `tap`, ואז `expect(container.read(productFavoritesProvider).contains(sku), isTrue)`; tap-חוזר → `isFalse`. בנוסף בדיקת-יחידה טהורה ל-`ProductFavoritesNotifier` (כמו ב-`recently_viewed_test.dart`): `SharedPreferences.setMockInitialValues({})`, `toggle('X')`, delay, notifier-טרי טוען `{'X'}`.
**6. שיפור:** במקום לחווט sku-מ-`recBrand` בכל מקום בנפרד, לחלץ `String? currentFavSku(LipskeyProductSheet)` helper משותף — גם שלב 16 (★-קטלוג) וגם warm-start (שלב 22) ישתמשו באותו מקור-sku, מונע סחיפת-מקורות.
**7. ריאלי?:** **כן, אטומי+בר-בדיקה** — ווידג'ט-יחיד, provider קיים, תבנית-toggle ידועה. ההיקף נכון. ההסתייגות היחידה: ה-`@visibleForTesting forceLiveForTest` קיים ב-`CardKeyboardScreen` אבל **לא** ב-`LipskeyProductSheet`; השלב צריך להוסיף seam-בדיקה ל-sheet (ראו שלב 74 בתוכנית, "forceLive ב-LipskeyProductSheet") — שזה רמז ש-12 נשען על תשתית-בדיקה ש-74 בונה. אפשרי לבדוק גם בלי-דגל אם מחליטים שהכוכב כללי.
**8. וידוא-פיקס מלא:** analyze zero-new. הרצת `flutter test test/card_keyboard/sheet_favorite_star_test.dart` + `test/recently_viewed_test.dart`-סגנון לפרסיסטנס. וידוא byte-identity flag-OFF: אם הכוכב מאחורי דגל, golden/בדיקת-ה-sheet הקיימת (אם יש) חייבת להישאר זהה כש-`kCardKeyboard` OFF. בדיקת-דליפה: לוודא ש-`toggle` לא קורא `_persist` יותר מפעם-אחת לטאפ (אין double-write). taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית לא אומרת **היכן מהפ-favorites נקרא חזרה** ב-UI. כיום `_FavoritesSection` ב-`catalog_screen.dart:7138` הוא הצרכן-היחיד, והוא מסונן ב-`filterBySystem(...catalogSystemFilterProvider)` (שורה 7149). צריך לאמת שמוצר שסומן מה-sheet **אכן מופיע** ב-`_FavoritesSection` ולא נופל בגלל מסנן-המערכת — אחרת המשתמש מסמן כוכב "שנעלם". בדיקת-אינטגרציה קצרה לסגירת-הלולאה.
**10. תכנון נוסף (שלי):** להוסיף **כתיבת recently-viewed מה-sheet** כאן או לתאם עם 13: ברגע שה-sheet נפתח דרך הכרטיס-המאוחד (`card_keyboard_screen.dart:211,367` קוראים `showLipskeyProductSheet`), אף-אחד לא קורא `touch(sku)` (רק כרטיס-הקטלוג ב-`catalog_screen.dart:4506` עושה זאת). אם לא נטפל, מוצר שנמצא דרך המאתר-המאוחד **לא** ייכנס ל"נצפו לאחרונה" — מה שסותר את warm-start (שלב 22). לכן צריך כאן להחליט: ה-sheet הוא הכותב-היחיד (ואז להזיז את ה-`touch` מ-4506 ל-sheet), וזה בדיוק מה ש-13 אמור לעשות — לתאם.

---

### שלב 13 — מפקד-כותבים ל"נצפו לאחרונה" → כותב-אחד
**1. יעד:** קיים **כותב-יחיד מאומת** ל-`recentlyViewedProvider`, ובעקביות: ה-sheet (`lipskey_product_sheet.dart`) הוא הכותב. כל כתיבה ש"קופצת" מכרטיס-קטלוג (`catalog_screen.dart:4506`) מבוטלת/מועברת, כך שמוצר שנפתח דרך *כל* מסלול (קטלוג, מאתר-מאוחד, מועדפים) נרשם פעם-אחת-בדיוק במקום-אחד, ויש בדיקת-מפקד שתיכשל אם יתווסף כותב-שני בעתיד.
**2. איך בונים:** (א) להריץ מפקד: `grep -rn "recentlyViewedProvider.notifier" lib` (אומת: כיום כותב-יחיד ב-`:4506`). (ב) להעביר את ה-`touch(sku)` מ-`initState` של כרטיס-הקטלוג (`catalog_screen.dart:4501–4508`) אל ה-sheet (`_LipskeyProductSheetState.initState`/post-frame), כך שכל פתיחת-sheet (כולל דרך `card_keyboard_screen`) רושמת. (ג) לכתוב `test/card_keyboard/recent_write_census_test.dart` שאוכף "כותב-אחד" — בדיקה שסורקת את עץ-המקור (כמחרוזת) ומוודאת בדיוק התאמה-אחת ל-`recentlyViewedProvider.notifier.touch`. (ד) לוודא ש-`_FavoritesSection`/`catalog_screen.dart:6261` (הצרכן של recently-viewed) עדיין מקבל נתונים.
**3. תקלות צפויות:** (א) **התוכנית מניחה שני כותבים (:4395,:4506); בפועל יש אחד** (4395 = `brandHistoryProvider.record`, לא recently-viewed). אם מוחקים "עיוור" לפי המספרים שבתוכנית, מוחקים את `brandHistory` בטעות ושוברים את ברירת-המותג (`resolveDefaultBrandIndex` ב-`catalog_screen.dart:4481`). (ב) **רגרסיית-כיסוי** — אם מעבירים את ה-`touch` ל-sheet אבל לא כל מסלול עובר דרך ה-sheet, מוצרים שנצפו-בקטלוג-בלי-לפתוח-sheet יפסיקו להירשם. (ג) **double-touch** — אם משאירים גם את 4506 וגם מוסיפים ל-sheet, מוצר שנפתח מהקטלוג נרשם פעמיים (לא מזיק לוגית בגלל move-to-front, אבל שובר את חוזה-"כותב-אחד"). (ד) **post-frame mounted** — ב-4505 יש `if (mounted)` שמירה; השכחתו ב-sheet תזרוק אם ה-sheet נסגר באותו frame.
**4. פתרון:** (א) **לא לסמוך על מספרי-השורות שבתוכנית** — להריץ את ה-`grep` ולפעול לפי המצב-בפועל (כותב-אחד ב-4506). לתעד את הסטייה. (ב) להעביר את ה-`touch` ל-`showLipskeyProductSheet` עצמו (`lipskey_product_sheet.dart:29`) — נקודת-המעבר היחידה שכל המסלולים חולפים בה (קטלוג, מאתר, מועדפים כולם קוראים אותה). כך הכיסוי טוטלי בלי כפילות. (ג) למחוק את 4506 באותו commit. (ד) לשמר `WidgetsBinding.instance.addPostFrameCallback` + `mounted` כמו במקור.
**5. בדיקות:** `test/card_keyboard/recent_write_census_test.dart` — קורא את `lib/screens/lipskey_product_sheet.dart` ו-`lib/screens/catalog_screen.dart` כמחרוזות ומוודא `RegExp('recentlyViewedProvider.notifier').allMatches(...).length == 1` (הכותב-היחיד ב-sheet). בדיקת-התנהגות: pump-sheet → post-frame → `expect(read(recentlyViewedProvider).first, sku)`. רגרסיה: `recently_viewed_test.dart` הקיים נשאר ירוק.
**6. שיפור:** במקום מפקד-מבוסס-grep (שביר לשינויי-שמות), לעטוף את הכתיבה ב-API-יחיד `markViewed(ref, sku)` ב-`recently_viewed.dart`, ולאכוף בלינטר/בדיקה ש**רק** הפונקציה הזו קוראת `.touch` — מרכז את ה-choke-point ומסיר את הצורך ב-string-scan.
**7. ריאלי?:** **כן, אטומי** — מהלך מחיקה+העברה ממוקד עם בדיקת-מפקד. ההיקף נכון. הסתייגות: ה-docstring "(:4395,:4506)" בתוכנית מטעה ועלול להוביל למחיקה שגויה; השלב צריך לפתוח בראקונסיליאציה של המצב-בפועל. אטומיות נשמרת כל עוד לא מערבבים עם שלב 12.
**8. וידוא-פיקס מלא:** analyze zero-new. `flutter test test/card_keyboard/recent_write_census_test.dart` + `recently_viewed_test.dart` + רגרסיה של `catalog_screen` tests (לאמת שברירת-המותג לא נשברה — שזה מה ש-4395 נוגע בו). byte-identity: אם המעבר מאחורי-דגל, flag-OFF משאיר את 4506 פעיל; אם החלטה-כללית, לוודא ש-`_FavoritesSection`/recently-viewed UI עדיין מתמלא. taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** להוסיף **בדיקת-no-leak חוצת-זהות** כבר כאן (לא לדחות עד 21): מאחר שה-`touch` עובר ל-`showLipskeyProductSheet` שנקרא מכל מקום, מוצר שמנהל-A פתח לא צריך לדלוף ל-recently-viewed של עובד-B. כיום `recentlyViewedProvider` **גלובלי** (לא ממוקד-זהות). לסמן זאת כחוב מפורש ש-21 סוגר, ולהוסיף `// TODO(step-21): scope by employerId` ליד הכתיבה.
**10. תכנון נוסף (שלי):** לתעד את **סדר ה-touch מול ה-resolve** ב-`card_keyboard_screen`: כיום `_pushStep` (`:204`) פותח sheet על `CardResolve`, אבל ה-`_onWordTap`→`_ProductTap` (`:366`) פותח sheet על בחירת-מוצר מ-ShowProducts. שני המסלולים חייבים לעבור דרך אותו `showLipskeyProductSheet` כדי שה-touch-היחיד יתפוס את שניהם — לאמת בבדיקה ששני המסלולים רושמים recently-viewed.

---

### שלב 14 — מתרגם-טהור `savedConfigKeysToSkus`
**1. יעד:** קיימת פונקציה טהורה `savedConfigKeysToSkus(Set<String> keys)` שממירה מפתחות-תצורה בפורמט `'<productKey>#<brandName>'` (כפי שמיוצר ב-`saved_configs.dart:14` `keyFor`) לקבוצת-skus נבדלת, עם dedup. אחרי השלב: אפשר לקחת את כל ה-savedConfigs הישנים ולגזור מהם רשימת-skus תקפה, בלי תלות-UI ובלי תופעות-לוואי — אבן-הבניין למיגרציה (15) ולשכבת last-touched (19/20).
**2. איך בונים:** (א) ב-`saved_configs.dart` (או קובץ-עזר טהור נלווה), `Set<String> savedConfigKeysToSkus(Iterable<String> keys)`: לכל key לפצל על `'#'` הראשון → `productKey`, להתעלם מ-`brandName` או להשתמש בו לבחירת-המותג. (ב) למפות `productKey`→sku: ב-`lipskey_catalog.dart`/`polyroll_catalog.dart` למוצר יש `.key` ומותגים עם `.sku`; להשתמש ב-`recBrand.sku` של המוצר (אותו מקור-sku כמו 4503/12) או לבחור את ה-brand התואם אם קיים. (ג) dedup דרך `Set`. (ד) להתעלם ממפתחות-לא-תקפים (productKey לא-מוכר, sku-null) בשקט.
**3. תקלות צפויות:** (א) **`'#'` במחרוזת** — `brandName` עלול להכיל `'#'` (לא סביר אבל לא-מוגן); split נאיבי על כל-ה-`#` ישבור productKey. (ב) **productKey→sku רב-ערכי** — לאותו productKey כמה מותגים עם skus שונים; אם מתעלמים מ-brandName, מאבדים את הברנד-הספציפי שהמשתמש שמר. (ג) **sku-null** — מותג ללא sku (כמו ב-12) ייתן null שצריך לסנן. (ד) **התאמה ל-divePool** — sku שנגזר חייב להיות קיים ב-`divePoolIndex` (`dive_pool.dart:83`) אחרת הוא חסר-תועלת ל-last-touched.
**4. פתרון:** (א) `key.split('#').first` ל-productKey ו-`key.substring(key.indexOf('#')+1)` ל-brand — מפצל רק על ה-`#` הראשון. (ב) לטעון את ה-brand התואם: `product.brands.firstWhere((b)=>b.name==brand, orElse:()=>product.recBrand)` ולקחת את ה-sku שלו — שומר על הברנד-הספציפי. (ג) `.where((sku)=>sku!=null).cast<String>()` לפני ה-Set. (ד) לסנן מול `divePoolIndex.containsKey(sku)` כדי שהפלט תמיד-תקף לפול.
**5. בדיקות:** `test/card_keyboard/saved_config_keys_to_skus_test.dart` (טהור, ללא prefs) — (1) `'p1#BrandA'` → ה-sku של BrandA למוצר p1; (2) שני מפתחות לאותו sku → קבוצה בגודל 1 (dedup); (3) productKey לא-מוכר → לא-תורם (קבוצה ריקה); (4) brandName עם `'#'` בתוכו → productKey נכון; (5) idempotent: הרצה כפולה זהה.
**6. שיפור:** להחזיר `Map<String,String>` (key→sku) ולא רק Set — כך 15 (מיזוג) ו-19 (last-touched) יכולים גם לדעת *איזה* config-key הוליד *איזה* sku, מועיל ל-breadcrumb ולמחיקה-נדחית (17). עלות-אפס, גמישות-יתר.
**7. ריאלי?:** **כן, אטומי לחלוטין** — פונקציה-טהורה אחת, קלט/פלט ברורים, בדיקת-property פשוטה. אין תלות-UI/Riverpod. ההיקף מושלם. זה הסוג של שלב שהוא בדיוק-בגודל.
**8. וידוא-פיקס מלא:** analyze zero-new. הבדיקה-הטהורה ירוקה. אין נגיעה ב-state/UI אז byte-identity flag-OFF טריוויאלי (קובץ חדש, לא-נקרא-עדיין). לאמת שאין import מעגלי (saved_configs ↔ catalog data). taskkill dart; retry-wrap (אם כי בדיקה-טהורה נדיר שתקרוס isolate).
**9. תכנון נוסף (שלי):** התוכנית לא מציינת **מה קורה ל-savedConfig שמכוון למוצר שכבר לא בקטלוג** (מוצר שהוסר בעדכון-נתונים). המתרגם צריך להחליט: לדלג בשקט (בחרתי) — ולתעד שזה אומר שמיגרציה (15) עלולה "לאבד" configs ישנים שמוצריהם נעלמו. בדיקה מפורשת למקרה-הזה.
**10. תכנון נוסף (שלי):** להוסיף **פונקציה-הפוכה לאימות** `skusToSavedConfigKeys` (לפחות ב-spirit) או לפחות בדיקת-round-trip חלקית, כדי שמיגרציית-המחיקה-הנדחית (17) תוכל לוודא שקילות: "כל config ישן → sku → עדיין נגיש כמועדף". בלי כיוון-הפוך כלשהו, הוכחת-השקילות ב-17 (`saved_configs_equivalence`) חלשה.

---

### שלב 15 — מיזוג חד-פעמי legacy→productFavorites
**1. יעד:** ב-`_load` של אחד ה-notifiers (productFavorites או saved_configs), מתבצע מיזוג חד-פעמי: כל ה-savedConfigs הישנים מומרים ל-skus (דרך 14) ומאוחדים לתוך `productFavoritesProvider`, ומפתח-ה-prefs הישן (`bs.saved-configs.v1`) נמחק/מסומן-מהוגר. אחרי השלב: משתמש קיים עם תצורות-שמורות ישנות מוצא אותן כמועדפי-מוצר, פעם-אחת, בלי כפילות.
**2. איך בונים:** (א) ב-`ProductFavoritesNotifier._load` (`product_favorites.dart:17`), אחרי טעינת המפתח החדש, לבדוק אם קיים `bs.saved-configs.v1`; אם כן — `savedConfigKeysToSkus(oldSet)` (שלב 14), `state = {...state, ...migratedSkus}`, ולכתוב מפתח-דגל `bs.saved-configs.migrated.v1=true` (או למחוק את הישן). (ב) להבטיח חד-פעמיות: לבדוק את דגל-המיגרציה לפני המיזוג. (ג) `_persist()` אחרי. (ד) לכתוב `test/card_keyboard/saved_configs_absorb_test.dart`.
**3. תקלות צפויות:** (א) **race עם `_userTouched`** — `_load` אסינכרוני; אם המשתמש הקיש כוכב לפני שהמיגרציה רצה, ה-`if (_userTouched) return` (`product_favorites.dart:21`) **ידלג על המיגרציה לגמרי** (כי הוא חוסם את כל הסיפא של `_load`). זו מלכודת אמיתית: המיגרציה תיעלם למשתמשים-פעילים. (ב) **מחיקה-מוקדמת** — אם מוחקים את `bs.saved-configs.v1` לפני ש-`SavedConfigsNotifier` (שעדיין קיים ונקרא ב-`catalog_screen.dart:5124`) טוען אותו, ה-★-תצורה בקטלוג יתרוקן. (ג) **כפל-מיגרציה בין-notifiers** — אם גם productFavorites וגם משהו-אחר מנסים למזג, ה-sku ייכנס פעמיים (Set מגן, אבל הדגל-החד-פעמי חייב להיות משותף). (ד) **idempotence על reload** — בלי דגל, כל restart ימזג-מחדש (לא מזיק ל-Set, אבל "מחזיר" configs שהמשתמש מחק ידנית מאז).
**4. פתרון:** (א) **להזיז את המיגרציה לפני בדיקת `_userTouched`**, או להפריד: בדיקת `_userTouched` חוסמת רק את הצבת-ה-state מהמפתח-החדש, אבל המיגרציה-החד-פעמית רצה תמיד (עם merge, לא overwrite) ומוגנת בדגל-מיגרציה-נפרד. (ב) **לא למחוק** את `bs.saved-configs.v1` בשלב 15 — רק לסמן `migrated`. המחיקה-בפועל נדחית לשלב 17 ("מחיקה נדחית"), בדיוק כפי שהתוכנית אומרת. (ג) דגל-מיגרציה יחיד `bs.saved-configs.migrated.v1` שכל מי שממזג בודק. (ד) הדגל מבטיח חד-פעמיות חוצת-restart.
**5. בדיקות:** `test/card_keyboard/saved_configs_absorb_test.dart` — `SharedPreferences.setMockInitialValues({'bs.saved-configs.v1':['p1#BrandA','p2#BrandB'], 'bs.product-favorites.v1':['SKU-X']})`; notifier-טרי; delay; `expect(state, containsAll([skuOf(p1,BrandA), skuOf(p2,BrandB), 'SKU-X']))`; ובדיקת-חד-פעמיות: restart-שני → אותו state (אין הכפלה, ואם המשתמש הסיר sku-X בינתיים הוא לא חוזר). בדיקת-race: `toggle` לפני שה-load הסתיים → המיגרציה עדיין רצה.
**6. שיפור:** לחלץ את לוגיקת-המיזוג ל-`mergeLegacyConfigs(Set<String> favs, Set<String> legacy)` טהורה ולבדוק אותה בנפרד מה-prefs — מפריד את "מה ממזגים" (טהור, קל-לבדיקה) מ-"מתי/האם כבר מוזג" (effect). מוריד את שבריריות-ה-async מהבדיקה.
**7. ריאלי?:** **כן, אטומי** — שינוי-`_load` ממוקד + בדיקת-round-trip. אבל **תלוי קריטית בשלב 14** (המתרגם) ומכיל את מלכודת-ה-`_userTouched` שהיא לא-טריוויאלית. ההיקף נכון; הסיכון הוא בעדינות-ה-race, לא בגודל. לא צריך פיצול.
**8. וידוא-פיקס מלא:** analyze zero-new. הבדיקה ירוקה כולל מקרה-ה-race ומקרה-ה-restart-כפול. byte-identity flag-OFF: למשתמש **חדש** (אין savedConfigs) ה-`_load` חייב להתנהג בדיוק כמו קודם (אין מיגרציה, state ריק) — בדיקה מפורשת. לאמת ש-`SavedConfigsNotifier` עדיין טוען (לא מחקנו את המפתח). taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית לא מטפלת ב**גרסת-סכימה**. אם בעתיד פורמט-ה-config ישתנה (`#` ל-`|`), המיגרציה תישבר בשקט. להוסיף בדיקת-פורמט: לדלג על מפתח שלא תואם `^[^#]+#.+$` ולספור-כמה-דולגו (לוג-debug בלבד), כדי שלא "נבלע" configs פגומים בשקט.
**10. תכנון נוסף (שלי):** להוסיף **בדיקת-no-loss כמותית**: `expect(migratedSkus.length, lessThanOrEqualTo(legacyKeys.length))` ו-`expect(migratedSkus.length, greaterThan(0))` כאשר ה-legacy לא-ריק וכל ה-productKeys מוכרים. בלי זה, באג ב-14 (שמחזיר Set-ריק) "יעבור" כמיגרציה-ריקה מוצלחת והמשתמש יאבד את כל המועדפים-הישנים בלי שאף בדיקה תצעק.

---

### שלב 16 — הפניית ★-הקטלוג ל-productFavorites
**1. יעד:** הכוכב/ים בקטלוג שכיום כותבים לפורמט-הישן (config `productKey#brandName`) כותבים ל-`productFavoritesProvider` לפי sku, בלי ארגומנט-מותג, ועם תוויות-UI זהות (★/☆) למשתמש. אחרי השלב: סימון-כוכב בקטלוג ובכרטיס (שלב 12) משתמשים ב**אותו** מקור-אמת (productFavorites), כך שמועדף-יחיד עקבי בכל המסכים.
**2. איך בונים:** (א) **ראקונסיליאציה ראשונה** (קריטי): הכוכב ב-`catalog_screen.dart:5122–5152` הוא `savedConfigsProvider.toggle(p.key, brand.name)` — תצורת-מותג, **לא** product-favorite. אין כיום כוכב-קטלוג שכותב productFavorites (אומת: אפס call-sites של `productFavoritesProvider.notifier`). (ב) להחליט: או להמיר את ה-★-תצורה ב-5138 לכוכב-מוצר (`productFavoritesProvider.notifier.toggle(sku)` עם sku מ-`brand.sku`/`recBrand.sku`), או להוסיף כוכב-מוצר נפרד ב-`_FavoritesSection`/בכרטיס-הקטלוג. (ג) לעדכן את ה-`isSaved`/הצבע (5125–5147) לקרוא `productFavoritesProvider.contains(sku)`. (ד) לשמר תוויות `★ נשמר`/`☆ שמור` ו-Semantics זהים.
**3. תקלות צפויות:** (א) **התוכנית מניחה ★-קטלוג קיים שכותב favorites — אין כזה.** "drop brand-arg" מניח חתימת-`toggle(sku,brand)`; בפועל productFavorites.toggle כבר מקבל sku-בלבד (`product_favorites.dart:32`), ומה שיש זה savedConfigs.toggle(key,brand). כלומר השלב הוא **המרת-סמנטיקה** (config→favorite), לא "הסרת-ארגומנט". (ב) **אובדן-סמנטיקת-תצורה** — אם ממירים את 5138 מ-savedConfigs ל-productFavorites, מאבדים את היכולת לשמור *תצורת-מותג-ספציפית* (productFavorites הוא per-sku, לא per-config). זה שינוי-מוצר. (ג) **כפילות עם 12** — אם גם הכרטיס (12) וגם הקטלוג (16) כותבים, צריך שניהם לאותו provider — אחרת מצב-מפוצל. (ד) **byte-identity** — שינוי הכוכב בקטלוג משנה UI חי.
**4. פתרון:** (א) **לפתוח בהחלטת-מוצר מפורשת** (כמו ש-§4 בכללי-הבנייה אומר "שאלות-פתוחות מקובעות בתוך השלבים"): או savedConfigs נבלע-כ-favorite (פשטות, אובדן per-brand), או savedConfigs נשאר ל-per-brand ונוסף כוכב-מוצר חדש. בהינתן ש-19 (last-touched) רוצה fav→frequent→recent, ההכרעה הסבירה: savedConfigs מהוגר ל-skus (כבר ב-15), והכוכב-בקטלוג הופך לכוכב-מוצר; per-brand נשמר רק ב-`cardSelection`/`brandHistory` (שכבר קיימים, 4390/4394). (ב) sku מ-`brand.sku` הנבחר (לא recBrand) כדי לשמר את כוונת-המותג. (ג) שני הכותבים (12,16) → `productFavoritesProvider` בלבד. (ד) מאחורי `kCardKeyboard` (או golden-קטלוג חדש) לשמירת byte-identity flag-OFF.
**5. בדיקות:** `test/card_keyboard/catalog_star_redirect_test.dart` — pump של מקטע-הכוכב, tap → `expect(read(productFavoritesProvider).contains(sku), isTrue)`; tap-חוזר → `isFalse`. בדיקת-עקביות חוצת-מסך: סמן מהכרטיס (12) → פתח קטלוג → `_FavoritesSection` מכיל את ה-sku. בדיקת-byte-identity: flag-OFF → הכוכב-הישן (savedConfigs) עדיין פעיל, או golden-קטלוג זהה.
**6. שיפור:** לאחד את **כל** כותבי-הכוכב (sheet-12, catalog-16, ועתידי quick-pad) מאחורי helper יחיד `toggleFavorite(ref, sku)` ב-`product_favorites.dart`, כך שאף UI לא קורא `.notifier.toggle` ישירות — choke-point יחיד שמקל על step-21 (scoping) ועל מפקד-כותבים.
**7. ריאלי?:** **כן אבל דורש החלטת-מוצר תחילה** — לא טכנית-קשה, אבל ה"הפניה" שהתוכנית מתארת שגויה-בהנחה (אין ★-favorites בקטלוג), אז השלב חייב להתחיל בהכרעת config↔favorite. ברגע שהוכרע — אטומי. אפשרי לפצל ל-**16a** החלטה+המרת-ה-★-תצורה, **16b** עקביות חוצת-מסך, אבל לא חובה.
**8. וידוא-פיקס מלא:** analyze zero-new. הבדיקות ירוקות. byte-identity flag-OFF מאומת (golden-קטלוג או הכוכב-הישן נשאר). רגרסיה: `saved_configs`-tests הקיימים (אם המרנו את 5138, הם עשויים לדרוש עדכון — לתעד). לאמת ש-`_FavoritesSection` (7138) מציג נכון אחרי המעבר. taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית מתעלמת מ-**`storeFavoritesProvider`** (`store_screen.dart:1215,1238`) ש**כן** קיים ונקרא — מועדפי-חנות לפי כותרת-פריט, נפרד מ-productFavorites. צריך להחליט אם הוא נכלל ב-last-touched (19) או נשאר עולם-נפרד. לפחות לתעד את קיומו כדי שלא ייווצר מקור-אמת-שלישי-נסתר למועדפים.
**10. תכנון נוסף (שלי):** לוודא **תאימות-system-filter**: `_FavoritesSection` מסנן `filterBySystem(...catalogSystemFilterProvider)` (7149). אם הכוכב-החדש מסמן sku ממערכת-מים אחרת מהמסונן-כעת, המוצר "נעלם". להוסיף או הודעת-ריק מובהקת ("יש מועדפים במערכת אחרת") או לכבד את הסינון בעקביות עם ה-sheet — אחרת UX מבלבל.

---

### שלב 17 — פרישת savedConfigs דרך מיגרציה-מוכחת-שקילה (מחיקה נדחית)
**1. יעד:** כל **הקריאות** ל-`savedConfigsProvider` (כיום ב-`catalog_screen.dart:5124,5126,5137`) מוסרות/מומרות, כך ש-savedConfigs כבר לא משמש לשליטת-UI — אבל **הקובץ/המפתח לא נמחק עדיין**. יש בדיקת-שקילות שמוכיחה ש-flags-OFF ההתנהגות זהה לפני/אחרי (כל מה ש-savedConfig עשה, productFavorites עכשיו עושה שווה-ערך). אחרי השלב: savedConfigs הוא dead-code-בטוח-להסרה (ההסרה-בפועל בשלב מאוחר).
**2. איך בונים:** (א) להחליף את ה-`ref.watch(savedConfigsProvider)`/`isSaved`/`toggle` ב-`catalog_screen.dart:5124–5138` בקריאות-productFavorites המקבילות (המשך-ישיר של 16). (ב) להשאיר את `SavedConfigsNotifier` ו-`bs.saved-configs.v1` *בקוד* (לא-נקראים) — מחיקה נדחית. (ג) לכתוב `test/card_keyboard/saved_configs_equivalence_test.dart` שמוכיח: לכל קלט-config, התנהגות-ה-UI-החדשה (productFavorites) שקולה לישנה. (ד) לוודא flags-OFF זהה.
**3. תקלות צפויות:** (א) **savedConfig הוא per-`(productKey,brandName)`, productFavorites הוא per-sku** — השקילות **לא טוטלית**: שני brands של אותו productKey הם config-נבדל אבל אולי אותו sku (או skus-שונים). הוכחת-"שקילות" תיכשל אם לא מגדירים *איזו* שקילות (set-of-skus, לא set-of-configs). (ב) **קריאות נסתרות** — ה-`grep` מצא 3 ב-catalog_screen, אבל ה-import קיים גם ב-`card_versions.dart:7` (רק docstring) — לוודא שאין צרכן-אמיתי נוסף. (ג) **מחיקה-מוקדמת בטעות** — אם מסירים את ה-provider ולא רק את הקריאות, שלב-15 (שעדיין ממזג מהמפתח) נשבר. (ד) **byte-identity** — שינוי 5124–5138 משנה UI חי אם לא מאחורי דגל.
**4. פתרון:** (א) להגדיר את השקילות כ-**"set-of-favorite-skus זהה"**: `savedConfigKeysToSkus(oldConfigs) == productFavorites-after-migration`. זו הוכחת-השקילות הנכונה, לא config-by-config. (ב) `grep -rn savedConfigsProvider lib` מלא לפני ההסרה; לוודא רק docstring ב-card_versions. (ג) **רק להסיר קריאות, לא את ה-provider/notifier/מפתח** — בדיוק כלשון התוכנית "מחיקה נדחית". (ד) מאחורי `kCardKeyboard`/golden-קטלוג.
**5. בדיקות:** `test/card_keyboard/saved_configs_equivalence_test.dart` — לכל קבוצת-configs לדוגמה: `expect(savedConfigKeysToSkus(configs), equals(productFavoritesAfterLoad))`; בדיקת flags-OFF: ה-UI של הקטלוג עם `kCardKeyboard` OFF מתנהג זהה (golden-קטלוג זהה לפני/אחרי). מפקד: `RegExp('savedConfigsProvider').allMatches(catalog_screen)` → 0 קריאות-state (רק docstrings מותרים).
**6. שיפור:** במקום בדיקת-שקילות חד-פעמית, להוסיף **invariant-מתמשך** שכל עוד `bs.saved-configs.v1` קיים, המיגרציה (15) שומרת `migratedSkus ⊆ productFavorites` — כך שאם מישהו "מחזיר" קריאת-savedConfig בעתיד, הבדיקה תתפוס את הסטייה.
**7. ריאלי?:** **כן אבל לא-נקי כפי שמנוסח** — "מיגרציה-מוכחת-שקילה" מרמז שקילות-מלאה שלא קיימת (per-config ≠ per-sku). השלב צריך לצמצם את טענת-השקילות ל-skus. בהינתן הצמצום — אטומי (הסרת-3-קריאות + בדיקה). תלוי-שרשרת ב-14/15/16. לא צריך פיצול, אבל חייב לתקן את הגדרת-השקילות.
**8. וידוא-פיקס מלא:** analyze zero-new. בדיקת-השקילות ירוקה. byte-identity flag-OFF: golden-קטלוג זהה לשלב-2/לפני-השלב. מפקד-0-קריאות (לא נשארו צרכני-savedConfigs פעילים). לוודא ש-15 עדיין ממזג (המפתח קיים). regression suite מלא של catalog_screen. taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית לא קובעת **מתי** המחיקה-הסופית קורית (איזה שלב מאוחר). להוסיף `// TODO(post-cut-over): remove SavedConfigsNotifier + bs.saved-configs.v1 once kUnifiedFinder ships (step 100)` — לקשור את המחיקה לקאט-אובר (100), שאחריו אין דרך-חזרה, כך שלא נשאר dead-code לנצח.
**10. תכנון נוסף (שלי):** להוסיף **בדיקת-no-orphan-write**: אחרי הפרישה, אסור שאף קוד עדיין *יכתוב* ל-savedConfigs (אחרת המיגרציה-החד-פעמית של 15 תפספס כתיבות-חדשות). מפקד שמוודא `savedConfigsProvider.notifier` אפס call-sites-של-toggle ב-`lib` — קומפלמנטרי לבדיקת-הקריאה.

---

### שלב 18 — מתרגם `frequentTextToSkus` (text→sku, בלי תדירות-מזויפת)
**1. יעד:** קיימת פונקציה טהורה שממירה את שאילתות-הטקסט-התכופות של המשתמש (כיום ב-`recentSearchesProvider`, `recent_searches.dart:66`, מקסימום 8, newest-first) לקבוצת-skus, כל שאילתה דרך `resolveWord(query, cardKeyboardLexicon)` (`word_finder_engine.dart:528`) ולקיחת **top-1** בלבד — בלי להמציא משקלי-תדירות שלא קיימים. אחרי השלב: אפשר לגזור מ"מה המשתמש חיפש לאחרונה" רשימת-skus תקפה ל-last-touched (19).
**2. איך בונים:** (א) `Set<String> frequentTextToSkus(List<String> queries, WordLexicon lexicon)`: לכל query, `resolveWord(query, lexicon)`; אם לא-ריק, לקחת `.first.sku` (top-1, שומר את סדר-ה-first-seen של הלקסיקון לפי `word_finder_engine.dart:531–535`). (ב) לשמר את סדר-ה-queries (newest-first) → סדר-skus, עם dedup ראשון-מנצח. (ג) לסנן sku-null ו-skus שלא ב-`divePoolIndex`. (ד) להתעלם מ-queries ש-`resolveWord` לא פותר (אין מבוי-סתום, פשוט דילוג).
**3. תקלות צפויות:** (א) **"תדירות-מזויפת"** — `recentSearchesProvider` הוא **recency-ordered, לא frequency** (move-to-front ב-`addRecentSearch`, שורות 10–19); השם `frequentTextToSkus` מטעה. אם מתייחסים לסדר כתדירות, ממציאים אות שלא קיים (בדיוק האזהרה "בלי תדירות-מזויפת"). (ב) **`resolveWord` רב-תוצאות** — query כמו 'ברז' פותר להרבה מוצרים; top-1 שרירותי (הראשון-בלקסיקון) — עלול להיות לא-מה-שהמשתמש-התכוון. (ג) **תלות-לקסיקון** — `cardKeyboardLexicon` (`card_keyboard_screen.dart:40`) נבנה מ-`kDivePool`; אם מעבירים lexicon אחר, top-1 שונה. (ד) **query-מנורמל** — `recent_searches` שומר `query.trim()` אבל לא מנרמל-מילים-נרדפות (copper/נחושת); `resolveWord` עשוי לא-לפתור 'copper'. גשר-המילים-הנרדפות הוא שלב 34, לא-קיים-עדיין.
**4. פתרון:** (א) **לקבל את ה-recency כפי-שהיא** — לתעד שזה "טקסט-אחרון" לא "טקסט-תכוף"; הפלט מוזן ל-last-touched (שכבר recency-based, 19), אז הסמנטיקה נכונה. אולי לשנות-שם ל-`recentTextToSkus`. (ב) top-1 = ה-best-match-של-הלקסיקון; לתעד שזה heuristic, ולשקול לסנן ל-queries שפותרים ל-≤k מוצרים (query-ספציפי) כדי שה-sku יהיה משמעותי. (ג) להשתמש *תמיד* ב-`cardKeyboardLexicon` (אותו מקור כמו המנוע). (ד) להזרים queries דרך `normalizeQuery` של שלב 34 כש-יבנה; עד אז, לקבל ש-'copper' לא-נפתר (דילוג שקט) — חוב מתועד.
**5. בדיקות:** `test/card_keyboard/frequent_text_to_skus_test.dart` (טהור) — (1) query שפותר → ה-sku של top-1; (2) query לא-פתיר → לא-תורם; (3) שתי queries לאותו top-1 → קבוצה בגודל 1 (dedup); (4) סדר newest-first נשמר ב-skus; (5) idempotent. בדיקה מול לקסיקון-בדיקה קבוע כדי שה-top-1 דטרמיניסטי.
**6. שיפור:** להחזיר `List<String>` מסודר (recency) ולא `Set`, כי 19 (last-touched) זקוק לסדר. בנוסף, לחשוף פרמטר `maxPerQuery` (ברירת-מחדל 1) כך שאם בעתיד נרצה top-k לכל query (לדוגמה לזריעת-בריכה רחבה), אותה פונקציה משרתת — בלי לכפול לוגיקה.
**7. ריאלי?:** **כן, אטומי לחלוטין** — פונקציה-טהורה מעל `resolveWord` הקיים ו-`recentSearchesProvider` הקיים. קלט/פלט ברורים, בדיקת-property פשוטה. ההיקף מושלם. ההסתייגות היחידה היא קונספטואלית (שם מטעה), לא היקפית.
**8. וידוא-פיקס מלא:** analyze zero-new. הבדיקה-הטהורה ירוקה. אין נגיעת-UI/state → byte-identity טריוויאלי (קובץ חדש, לא-נקרא-עדיין עד 19/20). לאמת אין-import-מעגלי (frequent_text ↔ word_finder_engine — חד-כיווני, תקין). taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית לא מטפלת ב-**query שפותר ל-sku שלא-בקטלוג-יותר** או ל-sku שכבר-במועדפים (כפילות בין fav ל-frequent). מאחר ש-19 ממזג fav→frequent→recent עם first-wins, צריך לוודא שה-frequentTextToSkus לא מחזיר skus שכבר-fav (אחרת בזבוז-slot). אפשרי לקבל את זה ב-19 (dedup חוצה-מקורות) — לתעד היכן ה-dedup קורה.
**10. תכנון נוסף (שלי):** להוסיף **בדיקת-יציבות-תחת-נרמול-עתידי**: לכתוב את הבדיקה כך ש-query='נחושת' ו-query='copper' *צפויים* לתת אותו sku **אחרי** שלב 34, ולסמן את ה-assert ב-`skip:'until step 34 synonym bridge'`. כך כשבונים את 34, הבדיקה כבר-שם ומאמתת את הקיפול-הנרדף end-to-end דרך frequentTextToSkus.

---

### שלב 19 — שכבת `lastTouchedSkus()` מאוחדת
**1. יעד:** קיימת פונקציה טהורה `lastTouchedSkus(favs, frequentSkus, recentSkus)` שממזגת שלושה מקורות בסדר-עדיפות **fav → frequent → recent** עם first-wins (dedup חוצה-מקורות), מוגבלת ל-cap. אחרי השלב: יש מקור-אמת-יחיד ל"מה המשתמש נגע-בו לאחרונה" — הבסיס ל-warm-start (22), לבוסט-דירוג (23), ולשבבי-קיצור (100).
**2. איך בונים:** (א) `List<String> lastTouchedSkus({required Set<String> favs, required List<String> frequent, required List<String> recent, int cap=...})`: לשרשר `[...favs, ...frequent, ...recent]`, dedup first-wins (`LinkedHashSet`), `.take(cap)`. (ב) להחליט על cap (probably 20, כמו `RecentlyViewedNotifier.cap`). (ג) לסנן מול `divePoolIndex` (כל sku חייב להיות פול-תקף). (ד) `test/card_keyboard/last_touched_test.dart`.
**3. תקלות צפויות:** (א) **favs הוא `Set` (לא-מסודר)** — `productFavoritesProvider` הוא `Set<String>` (`product_favorites.dart:43`); סדר-איטרציה של Set לא-דטרמיניסטי בין-הרצות → ה-prefix של lastTouched יהבהב. (ב) **dedup חוצה-מקורות** — sku שגם-fav וגם-recent חייב להופיע פעם-אחת בעמדת-ה-fav; שרשור נאיבי בלי-dedup יכפיל. (ג) **cap מול fav רבים** — אם יש >cap מועדפים, frequent/recent ייחתכו לגמרי — אולי לא-רצוי (warm-start יראה רק מועדפים). (ד) **sku-זבל** — מקור עלול להחזיק sku שהוסר-מהקטלוג.
**4. פתרון:** (א) **למיין את favs דטרמיניסטית** לפני המיזוג (sku-sort, כמו ש-`card_signals.dart:164` עושה ל-word axis) — אחרת אין byte-stability. או לקבל את favs כ-`List` ממקור-מסודר. (ב) `LinkedHashSet` עם first-wins מבטיח dedup נכון תוך-שמירת-סדר. (ג) לשקול cap-לכל-מקור (לדוגמה 8 fav + 8 frequent + 4 recent) במקום cap-גלובלי, כדי שכל-מקור מיוצג. (ד) `.where((s)=>divePoolIndex.containsKey(s))`.
**5. בדיקות:** `test/card_keyboard/last_touched_test.dart` (טהור) — (1) סדר: fav לפני frequent לפני recent; (2) dedup: sku ב-fav+recent מופיע פעם-אחת בעמדת-fav; (3) cap: ≤cap; (4) byte-stable: הרצה על favs כ-Set ממוין נותנת תוצאה זהה בין-הרצות (להריץ עם favs בסדר-הכנסה שונה → אותו פלט); (5) ריק: כל-המקורות-ריקים → []. בדיקת-`divePoolIndex` filter: sku-זבל מסונן.
**6. שיפור:** להחזיר רשומות מתויגות-מקור `List<({String sku, String source})>` (source ∈ fav/frequent/recent) — כך 22 (warm-start chips) ו-100 (שבבי-קיצור) יכולים להראות *למה* sku מוצע (כוכב מול שעון), ולא רק רשימה-שטוחה. עלות-אפס, ערך-UX.
**7. ריאלי?:** **כן, אטומי** — פונקציה-טהורה אחת, מיזוג-3-מקורות, בדיקת-property. תלוי 18 (frequent). ההיקף נכון. מלכודת-ה-Set-לא-מסודר היא העדינות-היחידה, אבל פתירה-בקלות. לא צריך פיצול.
**8. וידוא-פיקס מלא:** analyze zero-new. הבדיקה-הטהורה ירוקה כולל byte-stability תחת-shuffle-של-fav. אין נגיעת-UI → byte-identity טריוויאלי (קובץ חדש). לאמת שהפונקציה לא-תלויה-ב-Riverpod (טהורה, מקבלת ערכים) — כך שהיא בטוחה-לזהות (21 יזין לה ערכים ממוקדי-זהות). taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית מערבבת מקור-אחד ("frequent") עם sku-list, אבל **לא מגדירה התנהגות כשמקור-אחד עצום**. צריך מדיניות-cap מפורשת (per-source vs global) כי היא משפיעה ישירות על warm-start (22). אני ממליץ per-source caps עם total≤20, ולכתוב את הבחירה כקבועים-מתועדים `kLastTouchedFavCap/FreqCap/RecentCap` — אחרת 22 יקבל פלט בלתי-צפוי.
**10. תכנון נוסף (שלי):** להוסיף **חוזה-טוהר מפורש בבדיקה**: `lastTouchedSkus` חייבת להיות פונקציה-נקייה ללא-קריאת-providers (כדי שתהיה בטוחה-לזהות). בדיקה שמריצה אותה פעמיים עם אותם-קלטים ומוודאת `identical`-בתוכן + שאין side-effect (אין כתיבת-prefs). זה מקדים את step-21 שמסתמך על-כך שהשכבה-עצמה לא-דולפת בין-זהויות.

---

### שלב 20 — `lastTouchedSkusProvider` מרכיב 3 ספקים
**1. יעד:** קיים provider `lastTouchedSkusProvider` (בקובץ חדש `last_touched.dart`) שמרכיב את שלושת ה-providers (`productFavoritesProvider` + מתרגם-frequent מעל `recentSearchesProvider` + `recentlyViewedProvider`) דרך הפונקציה-הטהורה `lastTouchedSkus` (19). אחרי השלב: צרכן-יחיד (warm-start 22, בוסט 23) קורא provider-אחד ומקבל את רשימת-ה-skus-המאוחדת-החיה, שמתעדכנת כשכל מקור משתנה.
**2. איך בונים:** (א) `last_touched.dart`: `final lastTouchedSkusProvider = Provider<List<String>>((ref){ final favs=ref.watch(productFavoritesProvider); final recent=ref.watch(recentlyViewedProvider); final freqText=ref.watch(recentSearchesProvider); final freqSkus=frequentTextToSkus(freqText, cardKeyboardLexicon); return lastTouchedSkus(favs:favs, frequent:freqSkus, recent:recent); });`. (ב) לוודא שכל ה-`watch` מפעילים reactivity נכונה. (ג) `test/card_keyboard/last_touched_provider_test.dart` עם `ProviderContainer`.
**3. תקלות צפויות:** (א) **תלות-לקסיקון top-level** — `cardKeyboardLexicon` (`card_keyboard_screen.dart:40`) הוא `final` top-level שנבנה פעם-אחת; import שלו מ-`last_touched.dart` גורר את כל ה-imports של card_keyboard_screen (כולל Flutter/material) לתוך קובץ-state — שובר את הטוהר-הרצוי ל-provider-נתונים. (ב) **Riverpod override-count** — בדיקה שמשתמשת ב-`ProviderContainer(overrides:[...])`; אם מספר ה-overrides משתנה בין re-reads, Riverpod זורק (מלכודת מוכרת מ-MEMORY). (ג) **rebuild-storm** — `recentlyViewedProvider` משתנה בכל פתיחת-מוצר; provider שתלוי בו ייבנה-מחדש תכופות — ה-`frequentTextToSkus` (`resolveWord` לכל query) רץ בכל פעם. (ד) **race ב-`_load`** — שלושת המקורות טוענים async; ה-provider עלול להחזיר רשימה-חלקית ב-frame הראשון.
**4. פתרון:** (א) **להעביר את `cardKeyboardLexicon` למקום-טהור** — או לבנות `final lastTouchedLexicon = buildWordLexicon(kDivePool)` ב-`last_touched.dart` עצמו (מ-`word_lexicon.dart`, שהוא טהור), או להעביר את הלקסיקון מ-card_keyboard_screen לקובץ-טהור משותף. כך אין-גרירת-Flutter. (ב) בבדיקה לשמור **מספר-overrides קבוע** בין כל ה-`pump`/`read` (לא להוסיף/להסיר override דינמית). (ג) למַמֵש את `frequentTextToSkus` בתוך provider עם `ref.watch` ל-`recentSearchesProvider` בלבד, או למַמֵז — אבל מאחר שזה טהור וקל, rebuild סביר; אם כבד, `select` על אורך-הרשימה. (ד) לקבל רשימה-חלקית-ב-frame-ראשון (warm-start פשוט יראה פחות chips עד שה-load מסתיים) — מתועד.
**5. בדיקות:** `test/card_keyboard/last_touched_provider_test.dart` — `ProviderContainer` עם seed ל-3 המקורות (`overrides` ל-fav/recent/recentSearches notifiers), `container.read(lastTouchedSkusProvider)` → רשימה-מאוחדת בסדר fav→frequent→recent; שינוי מקור (toggle fav) → ה-provider-מעדכן; ריק → []. בדיקת idempotence: שתי-קריאות-רצופות אותו-ערך.
**6. שיפור:** להשתמש ב-`Provider.autoDispose` + `ref.cacheFor`/`keepAlive` מדוד, או למַמֵז את `frequentTextToSkus` לפי-זהות-הרשימה, כדי שפתיחת-מוצר-תכופה (recentlyViewed משתנה) לא תריץ `resolveWord` על כל-ה-queries בכל-פעם. שיפור-ביצועים ישיר ל-hot-path.
**7. ריאלי?:** **כן, אטומי** — provider-composition אחד מעל 3 קיימים + פונקציה-טהורה (19) + מתרגם (18). תלוי 19,17. ההיקף נכון. מלכודת-הגרירת-Flikupter (לקסיקון) היא העדינות; פתירה ע"י לקסיקון-טהור-מקומי. לא צריך פיצול.
**8. וידוא-פיקס מלא:** analyze zero-new. בדיקת-ה-provider ירוקה. **byte-identity flag-OFF**: ה-provider קיים אבל אף-אחד עוד-לא-קורא לו (warm-start הוא 22) — אז flag-OFF טריוויאלי, אבל לוודא ש-import שלו לא גורר side-effect/Flutter לעץ-המקור החי. בדיקת-no-leak: ה-provider טהור-קומפוזיציה, לא מחזיק-state-משלו. taskkill dart; retry-wrap.
**9. תכנון נוסף (שלי):** התוכנית **לא מציינת ש-`recentSearchesProvider` הוא בכלל המקור ל-frequent** — אני מאמת שזה המקור הנכון (אין provider 'frequentText' אחר; `recent_searches.dart` הוא היחיד עם טקסט-חיפוש-משתמש). צריך לתעד מפורשות שהמיפוי הוא `recentSearches → frequentTextToSkus → frequent`, אחרת בנאי-עתידי יחפש provider-frequent-לא-קיים. זה גם מסביר למה 18 תלוי בלקסיקון.
**10. תכנון נוסף (שלי):** להקדים את **בעיית-הזהות** שתפוצץ ב-21: כל שלושת המקורות (`productFavoritesProvider`/`recentlyViewedProvider`/`recentSearchesProvider`) הם **גלובליים**, לא ממוקדי-`employerId` (אומת: כולם `StateNotifierProvider` פשוטים ב-`state/`, ללא `.family`). לכן `lastTouchedSkusProvider` **ידלוף בין-זהויות** עד ש-21 יעטוף אותו ב-seam ממוקד-`boardAuthProvider.employerId` (`board_auth.dart:376`, מסוג `BoardSession?`). להוסיף `// TODO(step-21): identity-scope all three sources before warm-start` ולוודא שה-API של 20 מקבל-ערכים (לא-קורא-providers-עמוק) כך ש-21 יוכל להזריק-ערכים-ממוקדי-זהות בלי שכתוב.

</div>

<div dir="rtl">

# MONSTER — פירוק מפורט לשלבים 21–30 (P2 סיום + P3 פתיחה)

> מקור-אמת לקוד: `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל הקבצים תחת `New folder/buildsmart` הם שכפול מיושן ולא נקראו.
> עוגנים אמיתיים שאומתו: `lib/features/card_keyboard/card_keyboard_screen.dart` · `card_engine.dart` · `card_signals.dart` · `card_soft.dart` · `card_keyboard_flag.dart` · `lib/state/recently_viewed.dart` · `product_favorites.dart` · `recent_searches.dart` · `saved_configs.dart` · `lib/state/auth_state.dart` (`currentUidProvider:642`) · `lib/screens/floating_card_keyboard.dart` · `lib/screens/card_keyboard_sheet.dart` · `lib/screens/lipskey_product_sheet.dart` · `lib/screens/catalog_screen.dart` (כותב-recent ב-:4506).
> הערה מבנית קריטית: כל הקבצים ש-21–30 "בונים" (`last_touched.dart`, `card_mouth.dart`, `card_front_door.dart`, `card_history_row.dart`) **עדיין לא קיימים** — אלה שלבים עתידיים. ה-4 ספקי-המצב (`recentlyViewedProvider`/`productFavoritesProvider`/`recentSearchesProvider`/`savedConfigsProvider`) כולם משתמשים במפתח-prefs **גלובלי יחיד** (`bs.recently-viewed.v1` וכו') ולא ממוקדי-זהות — זו בדיוק הדליפה ש-21 פותר.

---

### שלב 21 — שער-בידוד-זהות למצב-מתמיד (שאלה-פתוחה מקובעת)
**1. יעד:** אחרי השלב, "נצפו לאחרונה" + מועדפים + חיפושים-אחרונים + savedConfigs מאוחסנים **תחת מפתח ממוקד-זהות**, כך שכניסת קבלן A ואחר-כך B אינה דולפת היסטוריית-A ל-B. כיום `recentlyViewedProvider` (recently_viewed.dart:53) הוא `StateNotifierProvider` חסר-family עם `_key='bs.recently-viewed.v1'` קבוע — גלובלי. היעד: seam שבוחר את המפתח לפי הזהות-הפעילה (`currentUidProvider`, auth_state.dart:642), עם `null`-uid = ההתנהגות הגלובלית של היום (אפס-רגרסיה, כמו ש-A2 uid-migration כבר עושה לשאר שכבת-הנתונים).
**2. איך בונים:** (א) להוסיף בכל אחד מ-4 הקבצים `static String _scopedKey(String? uid)` שמחזיר את ה-`_key` הישן כש-`uid==null`/ריק, ואחרת `'$_key.$uid'` — כך המפתח-הישן נשאר הברירת-מחדל הביתית. (ב) להפוך את ה-notifier לקבל `uid` בבנאי (`RecentlyViewedNotifier(this._uid)`), ו-`_load`/`_persist` קוראים `_scopedKey(_uid)`. (ג) להמיר את הספק ל-`StateNotifierProvider.family<…, String?>` שמקבל uid, או — מהלך נקי יותר — להשאיר את ה-API היחיד ולעטוף: ספק-חיצוני `recentlyViewedProvider` שקורא `final uid = ref.watch(currentUidProvider); return ref.watch(_recentlyViewedFamily(uid));`. (ד) לרכז את הבחירה ב-`lib/state/identity_scope.dart` חדש: `String? activeIdentityKey(Ref) => ref.watch(currentUidProvider)` — מקור-יחיד, כך ש-32 (איפוס-זהות) ו-88 (seam-ספק) יקראו אותו ולא ישכפלו.
**3. תקלות צפויות:** (א) **דליפת-prefs בכיוון-הזמן:** היום `_load` כבר ריצה על `_key` הגלובלי; אם משנים את המפתח בלי מיגרציה, מועדפים קיימים של המשתמש הנוכחי "נעלמים" (נשמרו תחת `bs.product-favorites.v1`, נקראים תחת `…​.<uid>`). (ב) **`StateNotifierProvider.family` שובר את כל ה-`ref.watch(recentlyViewedProvider)` הקיימים** ב-quick_pad_screen.dart:122 ו-catalog_screen.dart:6261 — חתימת-הספק משתנה מ-0-args ל-1-arg. (ג) **מירוץ-`_userTouched`:** ה-guard הקיים (recently_viewed.dart:20) מניח notifier יחיד לכל מחזור-חיים; family יוצר notifier-לכל-uid, וה-`_load` של ה-instance-החדש (אחרי החלפת-זהות) עלול לרוץ אחרי כתיבה. (ד) **טסטים מניחים uid=null:** עשרות טסטים עושים `SharedPreferences.setMockInitialValues({})` בלי auth — אם הספק עכשיו `ref.watch(currentUidProvider)` שלא קיים ב-scope, הם יקרסו.
**4. פתרון:** (א) **מיגרציה חד-פעמית בכיוון-הזהות הנוכחי בלבד:** ב-`_load`, אם המפתח-הממוקד ריק אבל המפתח-הגלובלי-הישן מלא **ו-uid הוא הראשון שנראה**, להעתיק פעם-אחת (כמו מיזוג legacy→productFavorites בשלב 15). (ב) **לשמר API 0-args:** לבחור את עיטוף-ה-proxy (ג ב-"איך בונים") במקום family חשוף, כך ש-`recentlyViewedProvider` נשאר 0-args וכל ה-watchers הקיימים נשארים זהים-בייטים. (ג) להפוך את ה-`_userTouched` ל-per-uid דרך מפה `static final Map<String?, bool>` או — פשוט יותר — להסתמך על כך ש-`autoDispose` של ה-family-הפנימי מוחק את ה-notifier-הישן בהחלפה (ראה 32). (ד) `currentUidProvider` כבר מחזיר `null` ללא-Firebase (auth_state.dart:642 "null ⇒ today's behavior"), כך שטסטים בלי auth מקבלים את ה-`_key` הגלובלי אוטומטית — אפס שינוי לטסטים קיימים.
**5. בדיקות:** `test/identity_isolation_test.dart`: (א) `_scopedKey(null)=='bs.recently-viewed.v1'` ו-`_scopedKey('u_A')` נבדל. (ב) round-trip ממוקד: `setMockInitialValues({})` → notifier עם uid='A' → touch('SKU1') → notifier טרי עם uid='B' → `state` ריק (A→B לא דולף). (ג) חזרה ל-uid='A' עם notifier טרי → `['SKU1']` (התמדה שורדת). (ד) מיגרציה: prefs ראשוני עם המפתח-הגלובלי-הישן מלא → notifier ראשון עם uid='A' → קולט אותם פעם-אחת; notifier שני עם uid='B' → לא קולט. (ה) **flag-OFF-זהות:** uid=null נותן בדיוק את state-של-שלב-2 (אותם כותבים, אותו מפתח).
**6. שיפור:** לחלץ `ScopedPrefsStore<T>` גנרי (קריאה/כתיבה/מיגרציה + guard) שכל 4 ה-notifiers יורשים — כיום הקוד מועתק 4 פעמים (כל אחד עם `_userTouched`+`_load`+`_persist` כמעט-זהים). זה הופך את 4 ההמרות לשורה-אחת-לכל-קובץ ומונע סחיפה.
**7. ריאלי?:** **גדול מדי — לפצל.** 4 קבצי-מצב × (scoped-key + מיגרציה + proxy + guard) + seam-זהות מרכזי + טיפול-בטסטים = יותר מ-atom יחיד. לפצל ל-21a (seam `identity_scope.dart` + ScopedPrefsStore + recently_viewed בלבד, מוכח A→B) ו-21b (החלת אותו דפוס על 3 הנותרים). השלב כפי-שמוגדר משלב "שאלה-פתוחה מקובעת" (גלובלי-מול-employer-scoped) שהיא **החלטת-מוצר**, לא קוד — צריך לקבע אותה ראשונה (ראה 9).
**8. וידוא-פיקס מלא:** `flutter analyze`=0-חדש; להריץ את כל חבילת-המצב (recently_viewed_test, recent_searches_test, product_favorites אם קיים, store_purchase_history_settings_test) ולוודא ירוק; **flag-OFF/uid-null זהה-בייטים**: diff על אותם מפתחות-prefs כש-uid=null; להריץ את הטסטים שנגעו ב-`recentlyViewedProvider` (catalog) ולוודא שאין שינוי-התנהגות; `taskkill dart` לפני-ריצה, retry-wrap לכשלי-isolate (מלכודת תנודתיות-השער הידועה).
**9. תכנון נוסף (שלי):** **לקבע את ההחלטה-הפתוחה במפורש לפני קוד:** היסטוריה/מועדפים הם **per-uid** (אישי), לא per-employer — קבלן שעובד ל-2 מעסיקים רואה היסטוריה-אישית אחת. לכתוב את ההכרעה כקבוע מתועד `kHistoryScope = IdentityScope.perUser` ולא להשאיר אותה משתמעת בבחירת-המפתח, כך ש-88 (seam היסטוריה-ממוקד-זהות אל המנוע) לא ימציא היקף שני.
**10. תכנון נוסף (שלי):** **נתיב-מחיקה בהתנתקות (logout-wipe):** auth_state.dart:478 כבר מתעד "Local wipe hook (S1.7/S1.8)"; השלב חייב לחווט את ה-4 מפתחות-הממוקדים ל-hook הזה, אחרת מכשיר-משותף משאיר היסטוריית-A ב-prefs אחרי שֵ-A התנתק — דליפת-בידוד דרך הדיסק, לא דרך הספק. בדיקה: logout → `_scopedKey('A')` נמחק מ-prefs.

---

### שלב 22 — warm-start לפתיחת-המקלדת מ-last-touched
**1. יעד:** כשנפתחת המקלדת המאוחדת (`CardKeyboardScreen` בפתיחה, מצב `CardAskWords`), המשתמש רואה **שבבי-מוצר-חמים** מ-`lastTouchedSkus()` (שלב 20) לפני שהקליד משהו — קיצור-דרך לדברים שכבר נגע בהם. כיום הפתיחה (card_engine.dart:155, `CardAskWords(kFirstQuestion, wordsByFrequency(...).take(kFirstWordCount))`) מציגה אך-ורק מילים-תכופות-קטלוגיות, אגנוסטית-להיסטוריה. היעד: בריכה ריקה/ללא-היסטוריה → **זהה-בייטים** למצב היום.
**2. איך בונים:** (א) להוסיף ל-card_keyboard_screen.dart ספק-קריאה `final warm = ref.watch(lastTouchedSkusProvider)` (שלב 20). (ב) למפות sku→מוצר דרך `divePoolIndex`/`kDivePool` (לדלג sku שלא בבריכה). (ג) להרכיב שורת-שבבים מעל ה-`WordKeyboard` הפותח: `_WarmRow` שמרנדר עד-N (למשל 6) שבבי-מוצר; tap → אותו `_ProductTap`-מסלול → `showLipskeyProductSheet` (card_keyboard_screen.dart:366). (ד) **gate ריק:** `if (warm.isEmpty) return const SizedBox.shrink()` כך שאין שינוי-פריסה כשאין היסטוריה.
**3. תקלות צפויות:** (א) **שבירת זהות-בייטים flag-OFF:** השלב מוסיף `ref.watch` חדש לתוך `build`; אם לא ב-`if (warm.isNotEmpty)`, הוא משנה את עץ-הווידג'טים גם כשהשורה ריקה. (ב) **מירוץ-flag:** `_live` נקרא פעם-אחת ב-mount (card_keyboard_screen.dart:124); ה-warm-row חייב לכבד את אותו gate — אסור שירונדר כש-`!_live`. (ג) **תלות-בשלב-13:** ה-warm נשען על "כותב-אחד ל-recently-viewed"; אם 13 לא נחת, `lastTouchedSkus` עלול לכלול sku כפולים מ-2 הכותבים (catalog:4506 + הכותב-הישן). (ד) **מירוץ-Riverpod בטסט-widget:** הוספת `ref.watch(lastTouchedSkusProvider)` דורשת שכל הספקים-המרכיבים (fav+frequent+recent, שלב 20) יהיו ב-`ProviderScope`; הוספת overrides ל-re-pump תשבור את "Riverpod אוסר שינוי מספר overrides ב-re-pump" (מלכודת ידועה).
**4. פתרון:** (א) לעטוף את כל ה-warm-row ב-`if (warm.isNotEmpty && (_live || forceLiveForTest))` כך שעץ-הווידג'טים זהה-בייטים כשריק/OFF. (ב) לקרוא `warm` רק בתוך אותו ענף `!_live`-guarded שכבר קיים ב-build (card_keyboard_screen.dart:400). (ג) להתנות את 22 ב-13 (התוכנית כבר מצהירה `תלוי: 21, 13`) ולוודא ב-CI ש-13 ירוק קודם. (ד) לבנות את הטסט עם **קבוצת-overrides קבועה** מראש (לזרוע `recentlyViewedProvider` עם override-state אחד) ולא לשנות את מספרם בין pumps — לזרוע פעם-אחת ולקרוא `pumpAndSettle`.
**5. בדיקות:** `test/features/card_keyboard/warm_start_test.dart`: (א) `setMockInitialValues({})` + `forceLiveForTest:true` + אין-היסטוריה → **אין** `_WarmRow`, רק ה-`WordKeyboard` הפותח (כמו screen_test הקיים). (ב) עם override שמזריק last-touched=[SKU_A,SKU_B] → השורה מציגה 2 שבבים; tap על SKU_A → `openSheetOnResolve=false` ואז וידוא שה-tap נוסה (כמו הדפוס ב-card_keyboard_screen_test.dart:57). (ג) **byte-identity:** flag-OFF (`forceLiveForTest:false`) → `SizedBox.shrink` (כמו הטסט הקיים בשורה 22). (ד) sku-לא-בבריכה ב-last-touched → מסונן, לא קורס.
**6. שיפור:** למזג את ה-warm-row אל אותו `WordKeyboard` הפותח כ**קבוצת-מקשים מובחנת** (עם glyph-מוצר) במקום widget-נפרד מעליו — כך הניווט-במקלדת (a11y live-region, card_keyboard_screen.dart:429) מכריז עליהם כחלק מאותה קבוצה, ולא צריך עוד Semantics-header נפרד.
**7. ריאלי?:** **כן, atom.** מקור-יחיד (`lastTouchedSkusProvider`), מיפוי-בריכה טריוויאלי, gate-ריק ברור, וטסט-widget אחד מכסה ON/OFF/ריק. הסיכון היחיד הוא תלות-קדם (13+20), לא היקף.
**8. וידוא-פיקס מלא:** analyze=0-חדש; card_keyboard_screen_test הקיים נשאר ירוק (לא נשבר ע"י warm-row); flag-OFF נותן בדיוק את אותו עץ-ווידג'טים (לאמת ב-`find.byType` שאין widgets-חדשים); להריץ את כל חבילת-card_keyboard; אין leak (לוודא שאין `ref.read` ב-`initState` שמחזיק notifier מעבר ל-dispose).
**9. תכנון נוסף (שלי):** **תקרת-warm מוגדרת + סדר דטרמיניסטי:** להגדיר `kWarmRowCap` ולוודא שהשבבים מסודרים בדיוק לפי `lastTouchedSkus` (fav→frequent→recent, first-wins משלב 19) — אחרת הסדר נראה אקראי בין-ריצות. בדיקה: 3 sku חוזרים באותו סדר תמיד.
**10. תכנון נוסף (שלי):** **תווית-מוצר נבדלת ל-warm:** להשתמש ב-`distinctSelectionLabels` (card_keyboard_screen.dart:284) גם כאן — אחרת שני מוצרים חמים עם אותו `nameHe` יראו זהים. בדיקה: 2 מוצרים חמים שווי-שם → 2 תוויות-נבדלות.

---

### שלב 23 — בוסט דירוג-mergedKeys לפי last-touched (tie-break בלבד)
**1. יעד:** כשהמנוע מציג שורת-`MergedKeys`, שבב שמוביל למוצר שהמשתמש כבר נגע בו עולה **קלות** בדירוג — אבל **רק כשובר-שוויון** אחרי info-gain, לעולם לא מעל ציר מכריע. בריכה ללא-היסטוריה (`historySkus` ריק) → **זהה-בייטים ל-golden-של-שלב-11**. כיום הדירוג ב-`_mergedChips` (card_engine.dart:267) הוא `scored.sort` לפי `expRem=sumSq/n` עם tie-break `a.rank` בלבד — אין רכיב-היסטוריה.
**2. איך בונים:** (א) להעביר `Set<String> historySkus` כפרמטר אופציונלי ל-`mergedKeys`/`_mergedChips` (ברירת-מחדל `const {}` → אינרטי). (ב) **לא לשנות את מיון-הצירים** (info-gain נשאר ראשי). הטילט מופעל **בתוך-ציר** או כשובר-שוויון-בין-צירים בלבד: בקומפרטור (card_engine.dart:267), אחרי `lhs!=rhs` ולפני `a.rank`, להוסיף `final ha=_historyTouchCount(a,historySkus); if (ha!=hb) return hb.compareTo(ha);`. (ג) `_historyTouchCount` = כמה מוצרים-בבריכה-המצומצמת-של-הציר נמצאים ב-`historySkus`. (ד) לוודא ש-`historySkus` נשאב מ-`lastTouchedSkusProvider` (שלב 20) במסך ומוזרק — המנוע נשאר **טהור** (אין `ref` ב-card_engine).
**3. תקלות צפויות:** (א) **שבירת ה-golden של שלב-11/64:** כל שינוי בסדר-השבבים כש-history-ריק שובר את golden `_mergedChips`. הסכנה: באג ב"אינרטי כשריק" (למשל `_historyTouchCount` מחזיר ערך לא-אפס לבריכה ריקה). (ב) **טילט שמטפס מעל ציר מכריע:** אם הטילט נכנס לפני `lhs!=rhs` במקום אחרי, הוא יכול להקדים ציר עם info-gain גרוע → שובר את החוזה ≤6. (ג) **הפרת טוהר/דטרמיניזם:** אם `historySkus` הוא `List` ולא `Set`, או אם הסדר תלוי-ב-iteration, הבייט-יציבות-תחת-shuffle (שמובטחת ב-card_engine.dart:213) נשברת. (ד) **התנגשות עם softTilt העתידי (שלב 82-84):** 84 משכתב את `_mergedChips` ל-top-K עם `softTilt`; בוסט-היסטוריה שמוטמע כאן ידני עלול להתנגש עם המנגנון-המאוחד ההוא.
**4. פתרון:** (א) `_historyTouchCount` עם `historySkus.isEmpty → return 0` בתחילתו (קצר-מעגל מובטח). (ב) למקם את בדיקת-ההיסטוריה **אך-ורק** אחרי `if (lhs!=rhs) return …` — לכתוב טסט שמוודא שציר-A עם expRem גרוע **לא** עוקף ציר-B טוב גם כש-A מלא-היסטוריה. (ג) לחתום על חתימת `Set<String>` ולמיין-קנונית (`historySkus` כבר Set מ-fav/recent). (ד) לתעד מפורשות ש-23 הוא **tie-break-בלבד זמני** ו-84 יבלע אותו ל-`softTilt` הכללי (התוכנית כבר מצהירה `softTilt רק-מסדר-בתוך-ציר`, שלב 91) — לסמן `// SUPERSEDED-BY: §84` כדי שלא יישאר כפילות.
**5. בדיקות:** `test/features/card_keyboard/history_boost_test.dart`: (א) `historySkus={}` → `_mergedChips` **זהה-בייטים** לפלט בלי הפרמטר (אותו golden כשלב 11). (ב) שני צירים שווי-expRem בדיוק, אחד עם מוצר-בהיסטוריה → הציר-עם-ההיסטוריה ראשון. (ג) ציר עם expRem **גרוע** + מלא-היסטוריה לעולם **לא** עוקף ציר עם expRem טוב + ללא-היסטוריה (הוכחת "tie-break בלבד"). (ד) shuffle-stability: shuffle של הבריכה + history קבוע → אותו פלט.
**6. שיפור:** במקום `_historyTouchCount` שסורק את הבריכה-המצומצמת לכל-ציר (O(chips×pool)), לחשב פעם-אחת `Set<String> poolHistory = pool.skus ∩ historySkus` ולהשתמש בו — חוסך סריקות חוזרות בקומפרטור (שנקרא O(n log n)).
**7. ריאלי?:** **כן, atom — אבל שביר-golden.** השינוי קטן (קומפרטור + פרמטר), אבל הוא נוגע בלב מנוע-הדירוג ש-golden-של-שלב-11 שומר. atom בתנאי שה-golden-11 כבר נעול (שלב 11 `תלוי`). אם 64 (golden לפני-מבנה-מחדש) טרם קיים, להריץ קודם.
**8. וידוא-פיקס מלא:** analyze=0-חדש; **ה-golden של שלב 11 חייב לעבור ללא-שינוי** (זו הראיה המרכזית ל"אינרטי כשריק"); להריץ את כל card_engine_test + card_signals_test; לוודא שאף assertion על info-gain-ordering לא נשבר; fuzz-shuffle (כמו הדפוס ב-card_engine_test.dart:9 שמייבא `Random`).
**9. תכנון נוסף (שלי):** **תקרת-טילט מפורשת = 0 דרגות-מעבר:** לקבע אינווריאנט שהבוסט **לעולם לא מוסיף או מסיר שבב** מהשורה — הוא רק מסדר-מחדש צירים שכבר נכנסו. בדיקה: `set(chips_with_history)==set(chips_without_history)` (אותם שבבים, אולי סדר שונה). זה מגדיר את ה"רך" כ-no-op-כמותי, בדיוק כמו §91.
**10. תכנון נוסף (שלי):** **בידוד-זהות של ה-historySkus:** הבוסט חייב לקבל את ההיסטוריה **הממוקדת-זהות** (שלב 21), אחרת הוא מטה את הדירוג של B לפי מה ש-A נגע בו — דליפה דרך הדירוג. בדיקה: history של uid='A' לא משפיע על `_mergedChips` כשהזהות-הפעילה היא 'B' (ריק → golden).

---

### שלב 24 — סחיפת אמת-יחידה ליסוד + זהות-בייטים flag-OFF
**1. יעד:** P2 (שלבים 12–23) נחתם: חבילת-בדיקות-שמירה אחת מוכיחה שכל-יסוד-המצב (מועדפים/recent/savedConfigs/last-touched/בידוד-זהות/warm/בוסט) עובד יחד, ו**flag-OFF זהה-בייטים לשלב-2** (העוגן שנקבע לפני כל תיקוני-המצב). אחרי השלב אין "אמת כפולה" — כותב-אחד ל-recent, מתרגם-אחד למועדפים, שכבת-last-touched אחת.
**2. איך בונים:** (א) `test/features/card_keyboard/foundation_single_truth_test.dart` שמרכז את ההוכחות: כותב-recent יחיד (census), מועדפים-מתורגם-נכון, last-touched first-wins, בידוד A→B, warm-ריק-shrink, בוסט-אינרטי-כשריק. (ב) להריץ `flutter analyze` ולתעד baseline-של-infos (כמו שלב 1 רושם 18 infos) ולוודא zero-new מול שלב-2. (ג) להוסיף assertion שה-golden flag-OFF (`_mergedChips` + `narrowAxis.sizeTokensIn`, שלב 2) **לא השתנה** מאז שלב-2 — היסוד לא נגע בפרודקשן.
**3. תקלות צפויות:** (א) **סחיפת-analyze מצטברת:** 12 שלבים הוסיפו imports/providers; analyze עלול לצבור infos חדשים (unused_import, missing-doc) שלא נתפסו בודדים. (ב) **golden flag-OFF זז בלי-כוונה:** אם 23 (בוסט) או 10 (ניקוד-גודל) דלפו לנתיב-OFF, ה-golden-2 נשבר וזו הראיה שמשהו לא היה מאחורי-דגל. (ג) **כותב-recent כפול שנשאר:** אם 13 לא מחק את שני הכותבים (catalog:4506 + הישן), ה-census ייכשל — וזו תקלת-תלות שמתגלה רק כאן. (ד) **מירוץ-prefs בטסט-מאוחד:** הרצת כל הספקים-המתמידים יחד באותו טסט עם `setMockInitialValues` יכולה לדלוף state בין test-cases אם לא מאופס ב-`setUp`.
**4. פתרון:** (א) להריץ `flutter analyze` מלא ולתקן כל info-חדש לפני נעילת השלב (לא להשאיר "כמעט-ירוק"). (ב) להפוך את golden-flag-OFF-זהה-לשלב-2 ל**שער-חוסם** בטסט (לא warning) — אם זז, השלב נכשל. (ג) להוסיף census-assert מפורש "בדיוק כותב-אחד ל-`recentlyViewedProvider.notifier).touch`" שסורק את `lib/` (כמו `recent_write_census_test` של שלב 13) ולוודא שהוא ירוק כאן שוב. (ד) `setUp(() => SharedPreferences.setMockInitialValues({}))` בכל group (הדפוס הקיים ב-card_keyboard_screen_test.dart:20).
**5. בדיקות:** `foundation_single_truth_test.dart` (החבילה המרכזת) + הרצה-חוזרת של: identity_isolation_test, warm_start_test, history_boost_test, recent_write_census_test, recently_viewed_test, recent_searches_test. ה-assert המרכזי: **`_mergedChips(kDivePool,[…],…)` flag-OFF == golden-שלב-2 בייט-בבייט**, ו-`analyze` zero-new.
**6. שיפור:** להפוך את "זהה-בייטים-לשלב-2" ל-helper משותף `assertFoundationByteIdentity()` שגם 11, 24, 70 קוראים — כך נקודת-העוגן (golden-2) מוגדרת פעם-אחת ולא משוכפלת בכל שלב-נעילה.
**7. ריאלי?:** **כן, atom — זה שלב-נעילה לא שלב-בנייה.** הוא לא מוסיף קוד-מוצר, רק מרכז ראיות ומריץ analyze. הסיכון היחיד: הוא **חושף** חוב שנצבר ב-12–23 (census-כפול, golden-זז) — וזה בדיוק תפקידו. atom נקי.
**8. וידוא-פיקס מלא:** הגדרת-הוויעדא **היא** השלב: analyze-0-חדש מול שלב-2; כל חבילות-המצב ירוקות; golden-flag-OFF==שלב-2; census כותב-אחד; אין-leak (כל ה-notifiers הממוקדים נבדקים round-trip+dispose). `taskkill dart` + retry-wrap לפני ההרצה-המלאה.
**9. תכנון נוסף (שלי):** **תקציב-infos מספרי מתועד:** לרשום את מספר-ה-infos המדויק (כמו "18 infos" בשלב 1) בראש הטסט כקבוע, כך ש"zero-new" ניתן-לאימות-מכונה ולא "נראה ירוק". בלי מספר-עוגן, info שמתחלף ב-info לא-נתפס.
**10. תכנון נוסף (שלי):** **snapshot של מפתחות-prefs:** לתעד את רשימת מפתחות-ה-SharedPreferences שהיסוד כותב (`bs.recently-viewed.v1[.uid]`, `bs.product-favorites.v1[.uid]`, …) כטסט-רגרסיה — כך הסרת/שינוי-מפתח עתידי (שתשבור התמדה אצל משתמשים-קיימים) נתפסת. בדיקה: קבוצת-המפתחות הנכתבים == הרשימה-המתועדת.

---

### שלב 25 — חוזה `CardMouth` (seam-פה pool-טהור)
**1. יעד:** קיים חוזה-נתונים טהור `CardMouth` (`lib/features/card_keyboard/card_mouth.dart` חדש) שמגדיר "פה" = `{id, labelHe, glyph, seedFor}`, כאשר `seedFor(pool)` הוא פונקציה-טהורה pool→pool מסוננת. זו השדרה הניטרלית של P3: כל 6 הפיות (טקסט/קול, רשת-מילים, חומר, עבודה, קטגוריה-אמוji, AI) יממשו את אותו חוזה. כיום אין מושג-פה כלל — `card_keyboard_screen.dart` יודע רק על `CardAskWords`/`MergedKeys`/`_WordTap`.
**2. איך בונים:** (א) קובץ חדש `card_mouth.dart` עם `library;` + doc-header (כמו card_signals.dart:1). (ב) `@immutable class CardMouth { final String id; final String labelHe; final IconData glyph; final List<LipskeyCatalogProduct> Function(List<LipskeyCatalogProduct> pool) seedFor; }`. (ג) **טוהר:** אסור imports של Flutter-widgets/Riverpod — אבל `IconData` הוא מ-`package:flutter/widgets.dart`; להכריע: או לשמור `glyph` כ-`IconData` (תלות-קלה ב-widgets, כמו ש-`WordKey.axisGlyph` כבר עושה ב-card_keyboard_screen.dart:276) או לשמור `int glyphCodePoint` טהור ולמפות במסך. (ד) `seedFor` חייב להחזיר **תת-קבוצה לא-ריקה או ריקה** (מסנן, לא ממציא) — אינווריאנט מתועד.
**3. תקלות צפויות:** (א) **טוהר מול IconData:** אם החוזה אמור להיות "pool-טהור" (כמו card_engine/card_signals שמכריזים "no Flutter widgets"), הכנסת `IconData` סותרת את ההכרזה. (ב) **`seedFor` שמחזיר super-set:** אם פה כלשהו (למשל AI) יחזיר מוצרים שלא בבריכה הנכנסת, החוזה ≤4/≤6 נשבר במורד. (ג) **התנגשות-id עם axisId הקיים:** `CardMouth.id` חייב להיות מרחב-שמות נפרד מ-`SignalSource.axisId` ('size'/'word'/…) אחרת חיווט עתידי (58) יתבלבל בין פה-מקור-זרע לציר-מיזוג. (ד) **closure לא-ניתן-להשוואה:** `seedFor` הוא closure → `CardMouth` לא יכול להיות value-equal, מה שמסבך טסטים שמשווים רשימות-פיות.
**4. פתרון:** (א) להגדיר את הטוהר כ"no Riverpod/clock/IO, ותלות-widgets מינימלית ל-`IconData` בלבד" (כמו ש-word_keys_model.dart כבר עושה) — או, נקי יותר, `glyphCodePoint:int` והמסך בונה `IconData(cp, fontFamily:'MaterialIcons')`. אבחר את הווריאנט-הטהור כדי לשמר את הכרזת-הטוהר. (ב) לתעד+לאמת אינווריאנט `seedFor(pool) ⊆ pool` (כל פלט מקור-מהבריכה). (ג) למרחב-שמות: `CardMouth.id` בערכים כמו 'mouth.text'/'mouth.material' (נבדל מ-axisId). (ד) להשוות פיות לפי `id` בלבד (לא לפי closure) — מספיק ל-26 (6 ids ייחודיים).
**5. בדיקות:** `test/features/card_keyboard/card_mouth_test.dart`: (א) לכל פה-דמה, `seedFor(kDivePool)` מחזיר תת-קבוצה (`result.every((p)=>kDivePool.contains(p))`) ולא-ריק לקלט-תקין. (ב) `seedFor` דטרמיניסטי (אותו pool → אותו פלט, גם אחרי shuffle). (ג) `glyphCodePoint` חוקי (>0). (ד) אם נבחר `IconData` — `glyph != null`.
**6. שיפור:** להוסיף `bool answersAxis` לחוזה — חלק מהפיות (חומר/קטגוריה, שלב 31/58) זורעות **בלי** לסמן ציר-נענה (כדי שהציר יישאר פתוח+מתחרה במיזוג), אחרים (טקסט) כן. לקבע את הסמנטיקה הזו בחוזה עצמו במקום לפזר אותה ב-31/58 (היכן ש-`_kOpeningWordAxis` כבר עושה את ההבחנה הזו ב-card_keyboard_screen.dart:51).
**7. ריאלי?:** **כן, atom נקי.** זה חוזה-נתונים טהור בקובץ-בודד עם טסט-טהרה אחד — בדיוק הגרעין שכל P3 נבנה עליו. אפס-תלות-בפרודקשן (קובץ-חדש, לא מחווט עדיין), כך שזהות-בייטים מובטחת טריוויאלית.
**8. וידוא-פיקס מלא:** analyze=0-חדש; הקובץ לא מיובא מאף-מקום-חי (grep ש-`card_mouth.dart` לא ב-import של widget-מורנדר) → flag-OFF זהה-בייטים אוטומטית (קוד-מת עד החיווט בשלב 28/30); card_mouth_test ירוק; אין-leak (טהור, אין state).
**9. תכנון נוסף (שלי):** **אינווריאנט "non-empty-or-null" מפורש + טיפול-בקלט-ריק:** להגדיר ש-`seedFor([])==[]` תמיד (פה על בריכה-ריקה לא קורס) — זה מונע את ה-`Invalid argument(s): 0` שכבר תועד ב-lipskey_product_sheet.dart:41 כשרשימת-siblings ריקה. בדיקה: `seedFor(const [])` לא-throw.
**10. תכנון נוסף (שלי):** **שדה `axisLabel` לזרע (seedAxisLabel):** כדי ש-30/58 ידעו איזה `NewbieStep.axisLabel` לדחוף כשפה זורע (כמו ש-`_kOpeningWordAxis='מילת-פתיחה'` שומר את ציר-המילה פתוח), החוזה צריך לשאת את התווית-המיועדת. בלי זה כל פה יצטרך להמציא תווית בנקודת-החיווט → סחיפה. בדיקה: `mouth.seedAxisLabel` נבדל מ-`SignalSource.axisName` עבור פה-שמשאיר-ציר-פתוח.

---

### שלב 26 — config-משטח טהור: `kCardMouths` + copy-פתיחה
**1. יעד:** קיימת רשימה-טהורה `kCardMouths` של 6 ה-`CardMouth` בסדר-תצוגה קנוני + מחרוזות-copy לפתיחה (כותרת "מה אתה מחפש?" וכו'). זו תצורת-המשטח: מקור-יחיד לאילו פיות קיימות ובאיזה סדר. כיום ה-copy מפוזר (card_keyboard_screen.dart:298 `'מה אתה מחפש?'`, :44 `kCardMergedQuestion='מה מתאים?'`).
**2. איך בונים:** (א) ב-card_mouth.dart (או `card_mouths.dart` נלווה): `const List<CardMouth> kCardMouths = [textMouth, voiceMouth?, wordGridMouth, materialMouth, jobMouth, categoryMouth, aiMouth]` — להכריע אם טקסט+קול הם פה-אחד (כפי שהתוכנית מרמזת ב"6 פיות שוות: טקסט/קול") או שניים. לפי החוזה: 6 פיות → טקסט/קול=אחד. (ב) כל פה עם `seedFor` שמחבר למקור-הזרע הקיים: material→`materialsInPool`-based, word→`resolveWord`, category→דליי-קטלוג, job→`assembleKit`/`kSmartProducts`. **בשלב זה ה-seedFor יכולים להיות stubs טהורים** (מחזירים את הבריכה או ריק) — המימוש המלא הוא 31/52–55. (ג) קבועי-copy: `kCardOpeningTitle`, להפנות את card_keyboard_screen.dart:298 אליו.
**3. תקלות צפויות:** (א) **`const` עם closure:** `CardMouth.seedFor` הוא closure → `kCardMouths` **לא יכול להיות `const`** (רק `final`). ניסיון `const` ייכשל בקומפילציה — מלכודת ש-MEMORY כבר תיעדה לגבי `bool.fromEnvironment` ב-collection-if. (ב) **6 ids ייחודיים:** טעות-העתקה תיתן 2 פיות עם אותו id → הטסט (6 ids ייחודיים) נכשל, וחיווט עתידי מנתב שגוי. (ג) **שינוי copy שובר טסט-טקסט קיים:** card_keyboard_screen_test.dart:33/61 בודק במפורש `'מה אתה מחפש?'`; הפניית ה-copy לקבוע חייבת לשמור על אותה מחרוזת בדיוק. (ד) **סדר-תצוגה לא-יציב:** אם הסדר נגזר ממפה/set, הוא לא-דטרמיניסטי.
**4. פתרון:** (א) `final` (לא `const`) ל-`kCardMouths`; אם רוצים `const`-עליון, להעביר את ה-closures ל-top-level-functions ולהפנות אליהן (top-level tearoff הוא const). (ב) טסט שמוודא `kCardMouths.map((m)=>m.id).toSet().length==6`. (ג) `kCardOpeningTitle='מה אתה מחפש?'` **בדיוק** (להעתיק מ-card_keyboard_screen.dart:298), והטסט הקיים נשאר ירוק. (ד) `List` literal עם סדר מפורש (לא נגזר).
**5. בדיקות:** `test/features/card_keyboard/card_mouths_test.dart`: (א) `kCardMouths.length==6`. (ב) 6 ids ייחודיים. (ג) הסדר קבוע (assert על רשימת-ה-ids המדויקת). (ד) `kCardOpeningTitle=='מה אתה מחפש?'` (שמירה על ה-copy). (ה) כל פה ב-`kCardMouths` מקיים את אינווריאנט-25 (`seedFor⊆pool`).
**6. שיפור:** להוסיף `enabledFor(subtype)`/דגל-זמינות-לפה — חלק מהפיות (AI) דורשות חיבור, חלק (קול) דורשות פלטפורמה; לקבע זמינות ב-config ולא לפזר `if`-ים במסך. כך 33 (כל-פה-נוחת-≤6) יכול לדלג פה-לא-זמין מסודר.
**7. ריאלי?:** **כן, atom — בהנחה ש-seedFor הם stubs כאן.** התצורה עצמה (רשימה+copy) היא atom. אם השלב מנסה גם **לממש** את כל 6 ה-seedFor במלואם, הוא נהיה גדול-מדי (זה 31+52–55). לשמור כאן stubs טהורים ולממש במורד.
**8. וידוא-פיקס מלא:** analyze=0-חדש; **card_keyboard_screen_test הקיים ירוק** (ה-copy לא זז); `kCardMouths` לא מחווט לאף-widget-חי עדיין (grep) → flag-OFF זהה-בייטים; card_mouths_test ירוק.
**9. תכנון נוסף (שלי):** **glyph-לכל-פה מובחן ב-grayscale:** לבחור 6 glyphs נבדלים (לא רק צבע) — בדיוק העיקרון מ-card_keyboard_screen.dart:239 `_glyphForAxis` (WCAG 1.4.1). בדיקה: 6 ה-`glyphCodePoint` ייחודיים.
**10. תכנון נוסף (שלי):** **קיבוע סדר-הפיות כהחלטת-מוצר מתועדת:** הסדר (טקסט→רשת→חומר→עבודה→קטגוריה→AI) הוא בחירת-UX, לא שרירותי; לתעד אותו כקבוע `// OWNER-ORDER` ולקבע אותו בטסט, כך ש-28 (דלת-קדמית) לא יסדר-מחדש בלי-כוונה. בדיקה: רשימת-ids מול קבוע-מתועד.

---

### שלב 27 — שורת-היסטוריה-חמה כווידג'ט-טהור
**1. יעד:** קיים ווידג'ט `CardHistoryRow` שמרנדר שבבי-מוצר-חמים (מ-last-touched), ו**מתכווץ לכלום כשריק** (`SizedBox.shrink`) — הורג את ה"היסטוריה-מתה" (שורה ריקה שתופסת מקום). זה ה-warm-row של שלב 22 מופשט לווידג'ט עצמאי + ניתן-לבדיקה. כיום אין widget כזה.
**2. איך בונים:** (א) `lib/features/card_keyboard/card_history_row.dart`: `class CardHistoryRow extends StatelessWidget` שמקבל `List<LipskeyCatalogProduct> products` + `void Function(LipskeyCatalogProduct) onTap` כפרמטרים (לא ספקים — נשאר טהור-מבחינת-Riverpod, הזרקה מבחוץ). (ב) `if (products.isEmpty) return const SizedBox.shrink();`. (ג) שורת-שבבים אופקית גלילה (כמו שורת-החיזוי ב-floating_card_keyboard) עם תווית-נבדלת (`distinctSelectionLabels`) + glyph-מוצר. (ד) RTL (`Directionality`/`textDirection`).
**3. תקלות צפויות:** (א) **overflow ב-N שבבים:** שורה אופקית בלי גלילה תזרוק `RenderFlex overflowed` במסך-צר (360px) — מלכודת רספונסיביות. (ב) **כפילות עם warm-row של 22:** אם 22 בנה warm-row inline ו-27 בונה widget נפרד, יש 2 מימושים → צריך ש-22 ישתמש ב-`CardHistoryRow` (תלות הפוכה: 27 צריך לבוא או-להיבלע-ל-22). התוכנית מסמנת `27 תלוי: 13` ו-`22 תלוי: 21,13` — לא תלויים זה-בזה, אז יש סיכון-כפילות אמיתי. (ג) **`ensureVisible` לא `scrollUntilVisible`:** טסט-tap על שבב מחוץ-למסך חייב `ensureVisible` לפני-tap (מלכודת flutter-test ידועה). (ד) tap-תוך-כדי-גלילה.
**4. פתרון:** (א) `SingleChildScrollView(scrollDirection: Axis.horizontal)` או `Wrap`; לבדוק 360 בלי-overflow. (ב) **לאחד:** להפוך את warm-row של 22 לשימוש-ב-`CardHistoryRow` — כלומר 27 מספק את הווידג'ט ו-22 מחווט אותו לספק. אם סדר-הבנייה הוא 22→27, לשכתב את 22 כאן לקרוא ל-`CardHistoryRow`. לתעד את היחס. (ג) בטסט: `await tester.ensureVisible(find.text(label))` לפני `tester.tap` (לא `scrollUntilVisible`). (ד) `pumpAndSettle` אחרי tap.
**5. בדיקות:** `test/features/card_keyboard/card_history_row_test.dart`: (א) `products:[]` → `find.byType(CardHistoryRow)` קיים אבל **שום שבב** (shrink). (ב) `products:[A,B]` → 2 שבבים; tap על A קורא `onTap(A)` (לוודא דרך callback-spy). (ג) 360px → אין-overflow (ensureSemantics/pump בלי exception). (ד) 2 מוצרים שווי-שם → 2 תוויות-נבדלות.
**6. שיפור:** להוסיף כותרת-קטנה "נגעת לאחרונה" שמופיעה רק-כשיש-שבבים — מבהיר למשתמש מה השורה. כיום אין הקשר-טקסטואלי לשבבים, מה שמבלבל מול שבבי-החיזוי-הרגילים.
**7. ריאלי?:** **כן, atom — אבל בעל יחס-תלות עדין ל-22.** הווידג'ט עצמו atom. הסיכון: כפילות עם 22. הפתרון הנקי הוא לראות את 22+27 כ**זוג** (27 = הווידג'ט, 22 = החיווט-לספק), ואם הם נבנים בנפרד — להבטיח ש-22 צורך את 27.
**8. וידוא-פיקס מלא:** analyze=0-חדש; flag-OFF זהה-בייטים (הווידג'ט מרונדר רק כש-`products` לא-ריק, וה-products באים מ-last-touched שריק-בברירת-מחדל בטסט); אין-leak (StatelessWidget); להריץ widget-test ב-360 וב-800.
**9. תכנון נוסף (שלי):** **תקרת-שבבים + "עוד":** להגביל ל-`kHistoryRowCap` שבבים גלויים עם אינדיקציית-גלילה, אחרת 20 פריטי-recent (cap של recently_viewed.dart:13) יוצרים שורה ענקית. בדיקה: 20 מוצרים → ≤cap גלויים.
**10. תכנון נוסף (שלי):** **a11y: live-region להופעת/היעלמות השורה:** כשהיסטוריה עוברת מ-ריק ל-מלא (משתמש פתח-מוצר אז חזר), קורא-מסך צריך שמיעה — לעטוף ב-`Semantics(liveRegion:true)` כמו card_keyboard_screen.dart:429. בדיקה: צומת-semantics עם liveRegion קיים כשיש שבבים.

---

### שלב 28 — ווידג'ט דלת-קדמית (layout/RTL, פיות כפרמטר)
**1. יעד:** קיים ווידג'ט `CardFrontDoor` שמרכיב את משטח-הכניסה: כותרת (copy מ-26) + `CardHistoryRow` (27) + 6 הפיות (מ-`kCardMouths`, כפרמטר) מעל `WordKeyboard` הפותח — הכל ב-RTL. זו "הדלת-הקדמית האחת" של P3. הפיות מוזרקות כפרמטר (טהור-מ-Riverpod). כיום הפתיחה היא רק `WordKeyboard` עירום על `CardAskWords` (card_keyboard_screen.dart:448).
**2. איך בונים:** (א) `lib/features/card_keyboard/card_front_door.dart`: `class CardFrontDoor extends StatelessWidget` עם `{required List<CardMouth> mouths, required List<WordKey> openingWords, required CardHistoryRow? historyRow, required void Function(CardMouth) onMouth, required void Function(WordKey) onWord}`. (ב) `Column`: header → historyRow (אם לא-null) → שורת-פיות (6 `_MouthButton` עם glyph+labelHe) → `WordKeyboard(words:openingWords, onWordTap:onWord, showUtilityRow:false)` (כמו card_keyboard_screen.dart:454). (ג) RTL מפורש. (ד) `WordKeyboard`-אחד בלבד (אינווריאנט).
**3. תקלות צפויות:** (א) **2× `WordKeyboard`:** אם הדלת מרנדרת גם רשת-פתיחה וגם פה-רשת-מילים כ-WordKeyboard נפרד, יש 2 → הטסט (WordKeyboard-אחד) נכשל. (ב) **overflow אנכי:** header+history+6-פיות+מקלדת על מסך-נמוך → `RenderFlex overflowed bottom`. (ג) **`onMouth` שלא-מחווט עדיין:** 28 בונה את ה-layout אבל החיווט-לזרע הוא 30/31 — `onMouth` חייב להיות פרמטר-חובה שהמסך מספק, אחרת tap-על-פה הוא no-op מת. (ד) **טוהר-Riverpod מול הזרקה:** הווידג'ט טהור, אבל מי שבונה אותו (30) חייב לקרוא `ref.watch` — להבטיח שהקריאה ב-30, לא כאן.
**4. פתרון:** (א) רשת-הפתיחה (opening words) **היא** ה-`WordKeyboard` היחיד; פה-רשת-מילים הוא **כפתור-פה** שכשנלחץ מחליף את תוכן-המקלדת (drill, שלב 57), לא WordKeyboard שני. לקבע "בדיוק WordKeyboard אחד" בטסט. (ב) לעטוף ב-`SingleChildScrollView`/`Flexible` כדי לספוג גובה; לבדוק ב-360×640. (ג) `onMouth` פרמטר-חובה; בשלב-28 המסך מחווט אותו ל-callback-ריק-מתועד או ל-stub שדוחף זרע-stub, והחיווט-המלא ב-30/31. (ד) `CardFrontDoor` נשאר StatelessWidget בלי `ref`; כל ה-`ref.watch` ב-`CardKeyboardScreen.build`.
**5. בדיקות:** `test/features/card_keyboard/card_front_door_test.dart`: (א) רנדר עם 6 פיות + openingWords + historyRow → `find.byType(WordKeyboard)` **בדיוק אחד**. (ב) tap על כפתור-פה → `onMouth` נקרא עם ה-`CardMouth` הנכון. (ג) tap על מילה-פותחת → `onWord` נקרא. (ד) RTL: `Directionality.of(context)==rtl`. (ה) historyRow=null → אין-שורת-היסטוריה, אין-crash.
**6. שיפור:** להפוך את שורת-הפיות ל`Wrap` במקום `Row` כך שב-2-עמודות (מסך-צר) הן עוברות-שורה אוטומטית במקום לדרוש LayoutBuilder נפרד (שלב 29) — מפשט את 29 ל-tuning בלבד.
**7. ריאלי?:** **כן, atom — בתנאי ש-onMouth הוא seam ולא מימוש.** ה-layout + RTL + הרכבה הם atom. אם 28 מנסה גם לחווט את כל הפיות לזרעים-אמיתיים, הוא בולע את 30/31 → גדול-מדי. לשמור seam.
**8. וידוא-פיקס מלא:** analyze=0-חדש; הווידג'ט לא מחווט ל-`CardKeyboardScreen` עדיין (30 עושה זאת) → flag-OFF זהה-בייטים (grep ש-card_keyboard_screen.dart לא מייבא card_front_door עדיין); widget-test ירוק; אין-leak.
**9. תכנון נוסף (שלי):** **focus-order / סדר-מעבר-קורא-מסך:** לקבע סדר-traversal מפורש (כותרת→היסטוריה→פיות→מקלדת) דרך `FocusTraversalOrder`, אחרת קורא-מסך ב-RTL עלול לקרוא פיות לפני הכותרת. בדיקה: semantics-traversal בסדר הצפוי.
**10. תכנון נוסף (שלי):** **מצב-ריק-יקום (defensive):** אם `openingWords` ריק (בריכה-ריקה תיאורטית), הדלת חייבת להציג הודעה+restart במקום מקלדת-ריקה — בדיוק `_buildEmptyState` שכבר קיים ב-card_keyboard_screen.dart:375. בדיקה: openingWords=[] → טקסט-ריק-state, לא מקלדת-ריקה.

---

### שלב 29 — מטריקות-רספונסיביות למשטח
**1. יעד:** `CardFrontDoor` מגיב לרוחב: פריסת-2-עמודות (מסך-צר ≤~400px) מול 3-עמודות-רחב (≥~700px), דרך `LayoutBuilder`, בלי-overflow ב-360 וב-800. זה מקביל לדפוס שכבר תועד ב-MEMORY (`BsKbScale`+`KbCellMetrics`: מובייל 30/19 vs דסקטופ 44/20). כיום אין רספונסיביות בדלת (היא חדשה משלב 28).
**2. איך בונים:** (א) לעטוף את שורת-הפיות ב-`LayoutBuilder` שבוחר `crossAxisCount`/גודל-כפתור לפי `constraints.maxWidth`. (ב) להגדיר breakpoints מפורשים (`kFrontDoorNarrow=400`, `kFrontDoorWide=700`) + מטריקות (גודל-glyph, padding) לכל-מצב. (ג) להשתמש ב-`GridView`/`Wrap` עם `crossAxisCount` נגזר. (ד) לוודא שגם `CardHistoryRow` (27) וגם המקלדת מכבדים את הרוחב.
**3. תקלות צפויות:** (א) **`LayoutBuilder` בתוך `Column` ללא-גובה-מוגבל:** `LayoutBuilder` צריך constraints; בתוך `Column` unbounded-height הוא יקבל `maxHeight=infinity` → `GridView` יזרוק. (ב) **golden-שבירה:** אם קיים golden-widget לדלת, שינוי-מטריקות שובר אותו. (ג) **overflow ב-breakpoint-הגבול:** בדיוק ב-400px (הגבול) הפריסה עלולה להתנדנד בין 2/3 עמודות ולגלוש. (ד) **טסט-רספונסיבי דורש `tester.binding.window`/`setSurfaceSize`** — שינוי-גודל בין-pumps עלול לדרוש `addTearDown(() => binding.setSurfaceSize(null))`.
**4. פתרון:** (א) `GridView` עם `shrinkWrap:true` + `physics:NeverScrollableScrollPhysics` בתוך ה-Column, או `Wrap` (שלא דורש gw-constraints) — אבחר `Wrap` (פשוט יותר, ראה שיפור-28). (ב) אם אין golden-widget לדלת — לא לבנות אחד עד 11/64 (טסטי-layout מספיקים); אם יש — לברך-מחדש. (ג) להגדיר את הגבול חד-משמעית (`>700 → 3, >400 → 2, else → 2`) ולבדוק את ה-edge בדיוק. (ד) `await tester.binding.setSurfaceSize(const Size(360,640))` + tearDown שמאפס.
**5. בדיקות:** `test/features/card_front_door_responsive_test.dart`: (א) `setSurfaceSize(Size(360,640))` → pump → אין-`exception` (no overflow), פיות ב-2-עמודות. (ב) `setSurfaceSize(Size(800,1000))` → 3-עמודות, אין-overflow. (ג) edge ב-400/700 → אין-overflow. (ד) tearDown מאפס surface (מונע דליפה ל-טסט-הבא).
**6. שיפור:** לאחד את מטריקות-הדלת עם `BsKbScale`/`KbCellMetrics` הקיימים (שכבר מבדילים מובייל/דסקטופ) במקום breakpoints חדשים — מקור-יחיד-לסקאלה לכל-המקלדת. כך הדלת והמקלדת תמיד מסכימות על "צר/רחב".
**7. ריאלי?:** **כן, atom — קטן.** זה tuning-פריסה על widget קיים (28), עם 2 breakpoints + טסט-layout. אם 28 כבר השתמש ב-`Wrap`, 29 מצטמצם ל-tuning-מטריקות בלבד — atom נקי.
**8. וידוא-פיקס מלא:** analyze=0-חדש; flag-OFF זהה-בייטים (הדלת עדיין לא-מחווטת); responsive-test ירוק ב-360/800/edge; אין-leak; אם יש golden — מבורך-מחדש ומתועד.
**9. תכנון נוסף (שלי):** **textScaleFactor (נגישות-גופן גדול):** משתמש עם גופן-מערכת ×1.5 ישבור פריסה צמודה — לבדוק `MediaQuery(textScaler: TextScaler.linear(1.5))` ב-360 בלי-overflow. זו תקלת-נגישות אמיתית שbreakpoint-רוחב לא תופס. בדיקה: 360px × textScale-1.5 → אין-overflow.
**10. תכנון נוסף (שלי):** **landscape (מסך-רחב-נמוך):** טלפון-בשכיבה (800×360) הוא רחב-אבל-נמוך — 3-עמודות + מקלדת לא יכנסו אנכית. לבדוק שהמשטח גליל אנכית במצב זה. בדיקה: `setSurfaceSize(Size(800,360))` → גלילה-אנכית, אין-overflow-תחתון.

---

### שלב 30 — חיווט המעטפת לפתיחת-CardKeyboardScreen
**1. יעד:** `CardFrontDoor` מחליף את ה-`WordKeyboard`-העירום בפתיחת `CardKeyboardScreen` (כלומר במצב `CardAskWords`): flag-OFF → כלום (כמו היום); flag-ON → דלת+רשת+פיות. זו הנקודה שבה P3 נהיה חי-מאחורי-דגל. כיום card_keyboard_screen.dart:448 מרנדר `WordKeyboard` ישירות על `CardAskWords` בלי דלת/פיות/היסטוריה.
**2. איך בונים:** (א) ב-`CardKeyboardScreen.build`, בענף `CardAskWords` בלבד, להחליף את `WordKeyboard(...)` ב-`CardFrontDoor(mouths: kCardMouths, openingWords: keys, historyRow: warm.isEmpty ? null : CardHistoryRow(products: warmProducts, onTap: _openProduct), onMouth: _onMouth, onWord: _onWordTap)`. (ב) `_onMouth(CardMouth m)` חדש: דוחף `NewbieStep` עם `predicate:(p)=>m.seedFor(currentPool).contains(p)` ו-`axisLabel:m.seedAxisLabel` (משלב 25) — מחווט את הפה לשדרת-הזריעה הקיימת (`_pushStep`, card_keyboard_screen.dart:204). (ג) לקרוא `ref.watch(lastTouchedSkusProvider)` (שלב 20) בתוך ה-build (בענף `_live`). (ד) **לשמור על ה-self-gate**: כל זה בתוך `if (!_live && !forceLiveForTest) return SizedBox.shrink()` הקיים (card_keyboard_screen.dart:400).
**3. תקלות צפויות:** (א) **שבירת card_keyboard_screen_test הקיים:** הטסט (card_keyboard_screen_test.dart:61) בודק `find.text('מה אתה מחפש?')` + `WordKeyboard`; אם הדלת עוטפת אחרת, הטקסט/המקלדת עלולים לא-להימצא או להימצא-כפול. (ב) **flag-race:** הוספת `ref.watch(lastTouchedSkusProvider)` ל-build משנה את ה-rebuild-timing; חייב להישאר בתוך ענף-`_live` כדי ש-flag-OFF לא יירשם כ-watcher (בדיוק הדפוס ב-floating_card_keyboard.dart:763 "EXPENSIVE watches stay INSIDE if(live)"). (ג) **שינוי מספר-overrides ב-re-pump:** טסט-ON שמזריק last-touched ואז re-pump עם override-נוסף שובר את "Riverpod אוסר שינוי מספר overrides ב-re-pump" (מלכודת ידועה). (ד) **`_WordTap` מול `_onMouth`:** המסך כבר מנתב tap לפי `payload` (card_keyboard_screen.dart:309); הוספת מסלול-פה חייבת לא-להתנגש עם `_WordTap`/`_ChipTap`/`_ProductTap` הקיימים.
**4. פתרון:** (א) להבטיח שה-`CardFrontDoor` מציג את אותה כותרת ('מה אתה מחפש?', מ-`kCardOpeningTitle`) ובדיוק `WordKeyboard` אחד עם אותם opening words — כך הטסט-הקיים נשאר ירוק. אם הטסט שביר, לעדכן אותו ל-`find.descendant(of: find.byType(CardFrontDoor), ...)`. (ב) למקם את כל ה-`ref.watch(lastTouchedSkusProvider)` בתוך ענף-`_live` (אחרי ה-gate), לא בראש-build — כך flag-OFF לא-מנוי. (ג) בטסט: קבוצת-overrides **קבועה** מראש (לזרוע last-touched פעם-אחת ב-`ProviderScope.overrides`), בלי לשנות מספר בין-pumps. (ד) `_onMouth` מנתב דרך typed-payload חדש `_MouthTap` (sealed `_Tap` קיים, card_keyboard_screen.dart:59) — נבדל-מבנית מ-3 הקיימים, כך אי-אפשר להתבלבל (אותו עיקרון של swarm-R6 ב-card_keyboard_screen.dart:58).
**5. בדיקות:** `test/features/card_keyboard/front_door_wiring_test.dart`: (א) flag-OFF (`forceLiveForTest:false`) + `setMockInitialValues({})` → **כלום** (`SizedBox.shrink`, אין `CardFrontDoor`, אין כותרת) — מרחיב את הטסט-הקיים בשורה 22. (ב) flag-ON (`forceLiveForTest:true`) → `find.byType(CardFrontDoor)` אחד + 6 פיות + רשת-מילים. (ג) tap על פה-חומר → `crumbs` גדל ב-1, וה-`answeredAxes` **לא** כולל את ציר-החומר אם הפה משאיר-ציר-פתוח (חיבור ל-31). (ד) tap על מילה-פותחת עדיין עובד (רגרסיה ל-card_keyboard_screen_test).
**6. שיפור:** לחווט את 6 הפיות דרך **מפת-dispatch** (כמו `_destByChip`/`_drillIndexByChip`/`_runByChip` ב-floating_card_keyboard.dart:168) ולא דרך `if/else` — כך הוספת-פה-עתידית (51–55) היא רישום-במפה ולא ענף-חדש. זה מיישר את הדלת לדפוס-ה-dispatch שכבר הוכח-עובד במקלדת-הצפה.
**7. ריאלי?:** **גבולי — שוקל לפצל.** החיווט (החלפת-WordKeyboard, `_onMouth`, warm-row, gate) הוא הרבה-נקודות-מגע ב-build היחיד. אבל כולן באותו ענף-`CardAskWords` ומאחורי אותו gate, אז זה atom-לוגי. הסיכון: 30 גם מנסה לחווט פיות חומר+עבודה (זה 31). לשמור 30 = "החלף-WordKeyboard-בדלת + onMouth-stub-שזורע"; 31 = הסמנטיקה-המדויקת של חומר/עבודה. אז atom.
**8. וידוא-פיקס מלא:** analyze=0-חדש; **card_keyboard_screen_test הקיים ירוק** (זו הראיה ש-flag-OFF זהה-בייטים — הטסט בשורה 22 בודק בדיוק את ה-shrink); flag-OFF → grep+widget-test שאין `CardFrontDoor` בעץ; להריץ את כל חבילת-card_keyboard + floating_card_keyboard_test; אין-leak (ה-warm `ref.watch` ב-build, לא ב-initState); `taskkill dart`+retry-wrap.
**9. תכנון נוסף (שלי):** **שדרת-זריעה אחת ל-onMouth (לא לעקוף את `_pushStep`):** `_onMouth` חייב לעבור דרך אותו `_pushStep`/`_diveVersion`/memo (card_keyboard_screen.dart:204) כמו tap-מילה — אחרת הזרע-מפה לא-יזכה ל-memoization ול-resolve-terminus. בדיקה: tap-פה שמצמצם לבריכה-יחידה → `CardResolve` (פותח sheet כמו tap-מילה).
**10. תכנון נוסף (שלי):** **התנהגות-פה כשהמחסנית-לא-ריקה (drill פנימי):** הדלת+פיות שייכים ל-`CardAskWords` (פתיחה); אבל מה קורה ל-tap-פה אחרי שכבר צללנו? לקבע מפורשות שהפיות מופיעות **רק** במצב-הפתיחה (stack ריק), ובמורד המיזוג (`MergedKeys`) הן נעלמות (כמו chrome-מחליף-פיות, שלב 57). אחרת פה-קטגוריה אחרי-צלילה יאפס את הבריכה בצורה מבלבלת. בדיקה: אחרי tap-מילה (stack לא-ריק) → `CardFrontDoor` כבר לא בעץ (רק שורת-`MergedKeys`).

</div>

<div dir="rtl">

# פירוק-מפורט — שלבים 31–40 (P3 סוף · P4 טקסט+קול)

> מקור-אמת לקוד: `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל ההפניות מעוגנות בקבצים האמיתיים שם (לא בשום קלון `New folder/buildsmart`).
>
> **הקשר-בנייה קריטי שהתגלה בקריאת-הקוד:** הארטיפקטים של שלבים 25–30 (`card_mouth.dart`, `card_front_door.dart`, `kCardMouths`, `CardFrontDoor`) **עדיין לא קיימים** בקוד — תיקיית `lib/features/card_keyboard/` מכילה היום רק 6 קבצים: `card_engine.dart`, `card_signals.dart`, `card_keyboard_screen.dart`, `card_keyboard_state.dart`, `card_soft.dart`, `card_keyboard_flag.dart`. המשטח-החי הוא `CardKeyboardScreen` שנפתח ב-`CardAskWords → WordKeyboard`, ממוסך ב-`catalog_screen.dart:2469` מאחורי `kCardKeyboardFlag`. לכן שלבים 31–33 בונים על שלב-30 שטרם נבנה, ושלבים 34–43 בונים על אותו `CardFrontDoor`. זה משפיע ישירות על סעיף "ריאלי?" של כל שלב.
>
> **תקדים-זהב שכבר בקוד:** `card_keyboard_screen.dart:51` מגדיר `_kOpeningWordAxis = 'מילת-פתיחה'` — מילת-הפתיחה זורעת את הבריכה אך **לא** מסמנת את ציר-המילה כ-answered (כי `answered` ב-`_mergedChips` נבנה מ-`s.axisLabel` ומושווה ל-`src.axisName`='דגם'). זה בדיוק דפוס ה"זרע פטור-משער + הציר נשאר פתוח" ששלבים 31/58 צריכים לחומר. שכפול הדפוס הזה הוא ה-DNA של P3.

---

### שלב 31 — פיות חומר+עבודה מחווטות (זרע gate-exempt, ציר נשאר פתוח)
**1. יעד:** אחרי השלב, לחיצה על פה-החומר ב-`CardFrontDoor` (למשל "נחושת") **זורעת** את הבריכה למוצרי-נחושת אך **לא** מסמנת את ציר-החומר כ-answered — כך שב-`MergedKeys` שאחריה שבב-חומר עדיין מתחרה ויכול לצוף שוב; ולחיצה על פה-העבודה זורעת מ-`assembleKit(recipe)` (acc→sku). לפני השלב פה-החומר/עבודה ב-`CardFrontDoor` היו תצוגתיים-בלבד (שלב 30 בנה layout עם `seedFor` כפרמטר אך לא חיווט אותם למסך). הבדיקה האמיתית: `'נחושת' → state.answeredAxes` **לא** מכיל 'חומר'.

**2. איך בונים:** (א) ב-`CardKeyboardScreen` להוסיף טיפוס-tap חדש `_MaterialSeedTap(material)` ו-`_JobSeedTap(recipeKey)` למשפחת `_Tap` הקיימת (`card_keyboard_screen.dart:59-85`), במקביל ל-`_WordTap`. (ב) ב-`_onWordTap` להוסיף ענף ל-`_MaterialSeedTap`: לבנות `skuSet` מ-`productsOfMaterial(kDivePool, material)` (מ-`material_lexicon.dart`), ולדחוף `NewbieStep` עם `axisLabel:` **מחרוזת-זרע ייעודית** `_kMaterialSeedAxis = 'חומר-פתיחה'` (לא `MaterialSignal().axisName`='חומר') — בדיוק כמו `_kOpeningWordAxis`. (ג) ענף `_JobSeedTap`: `assembleKit(recipe)` → לאסוף `line.product?.sku` מכל `KitLine` שאינו `KitMatch.none` → `skuSet` → `NewbieStep(axisLabel:'מתכון', predicate: skuSet.contains)`. (ד) ב-`CardFrontDoor.seedFor` למפות את כפתורי החומר/עבודה ל-`_MaterialSeedTap`/`_JobSeedTap` ולקרוא ל-`onSeed`.

**3. תקלות צפויות:**
- **הזרע יסגור את הציר בטעות** אם נשתמש ב-`axisLabel: MaterialSignal().axisName`. אז ב-`_mergedChips` (`card_engine.dart:222`) `answered` יכיל 'חומר', `MaterialSignal` יידלג (`answered.contains(src.axisName)`), וסתירת-P3-מול-P7 (שעליה שלב 9 נבנה) חוזרת.
- **שער-הכיסוי 0.5 חוסם את שבב-החומר העמוק.** גם אם הציר פתוח, `MaterialSignal.chipsFor` (`card_signals.dart:207-208`) מחזיר ריק כש-`seededFraction(pool) < kMaterialCoverageGate=0.5`. בבריכת-נחושת-זרועה `seededFraction` קרוב ל-1.0, אבל ה**מטרה** היא שגם בבריכה כללית החומר יציע — ושם הכיסוי < 0.5. תלות אמיתית בשלב 9 (`materialAlwaysOn`/gate-exempt-via-seed).
- **`assembleKit` מחזיר רוב `KitMatch.none`** (`recipe_kit.dart` מתעד ≈305/363 acc חסרי-sku) → `skuSet` של פה-עבודה עלול להיות זעיר/ריק → `predicate` שמרוקן את הבריכה → `CardShowProducts([])` → מסך-ריק.
- **שבירת זהות-בייטים flag-OFF**: כל שינוי ב-`_Tap`/`_onWordTap` חייב להישאר מתחת ל-`if (!_live && !widget.forceLiveForTest) return const SizedBox.shrink()` (`card_keyboard_screen.dart:400`).

**4. פתרון:**
- להשתמש ב-`axisLabel:'חומר-פתיחה'` (sentinel נבדל), בדיוק כמו `_kOpeningWordAxis`. בדיקה ייעודית מאמתת ש-'חומר' לא ב-`answeredAxes`.
- להישען על שלב 9: `MaterialSignal` יקבל `materialAlwaysOn`/`coverageGate` כשדה-instance, וזרע-החומר יעביר `coverageGate:0` (פטור-משער). עד שלב 9 — לכלול בדיקה שמדלגת אם הכיסוי < gate, ולתעד את התלות.
- לפה-העבודה: לסנן `skuSet` רק ל-`match != none` **וגם** `product != null`; אם `skuSet.isEmpty` — לא לדחוף step כלל (no-op + הודעת-toast/ניטרלי), כך שלחיצה על מתכון-ריק לא יוצרת מבוי-סתום. ולוודא `kDivePool` מכיל את ה-skus (כבר ככה: `recipe_kit._bySku` בנוי מ-`kDivePool`).
- כל הקוד החדש נשאר אחרי ה-self-gate; בדיקת byte-identity (flag-OFF) חוזרת לוודא `SizedBox.shrink`.

**5. בדיקות:** `card_front_door_seed_test.dart`:
- `'material seed keeps axis open'`: בונים `CardKeyboardScreen(forceLiveForTest:true)`, מדמים `onSeed(_MaterialSeedTap('נחושת'))`, ואז `expect((state.answeredAxes as List).contains('חומר'), isFalse)` + `expect(state.crumbs, contains('נחושת'))`.
- `'material seed actually narrows the pool'`: אחרי הזרע `state.verdict` הוא `MergedKeys`/`CardShowProducts` ולא `CardAskWords`, ובריכת-המוצרים שלו ⊆ `productsOfMaterial(kDivePool,'נחושת')`.
- `'job seed assembles recipe'`: זרע פה-עבודה למתכון ידוע (`kSmartProducts.first`), `expect(state.crumbs, contains(recipe.titleHe))`; כל ה-skus בבריכה קיימים ב-`assembleKit` עם `match != none`.
- `'empty recipe is a no-op, not a dead-end'`: מתכון שכל ה-acc שלו `none` → `state.crumbs` נשאר ריק (לא נדחף step).

**6. שיפור:** במקום שני טיפוסי-tap נפרדים (`_MaterialSeedTap`/`_JobSeedTap`), להגדיר `_SeedTap({required axisLabel, required Set<String> skus, required String crumb})` גנרי אחד שכל פה ממלא — מאחד את כל ששת-הפיות לשער-זרע יחיד, מצמצם כפילות, ומכין את הקרקע ל-`CardSeed`/`seedPool` (שלבים 51/62). זה גם הופך את "פה=שורת-זרע" לאינווריאנט בר-בדיקה (כל פה ⇒ `_SeedTap` תקין).

**7. ריאלי?:** **גבולי — שני זרעים-שונים-במהותם בשלב אחד.** פה-החומר (זרע סטטי מ-`productsOfMaterial`) ופה-העבודה (זרע מ-`assembleKit` היקר, עם טיפול-במתכון-ריק) הם שני מנגנונים נפרדים שנדחסו לשלב אחד, ושניהם תלויים ב-30 (מעטפת) **וגם** 9 (gate-exempt). מומלץ לפצל ל-31a (פה-חומר, gate-exempt, ציר-פתוח) ו-31b (פה-עבודה, מתכון on-ramp + no-op על מתכון-ריק) — אחרת בדיקה-בודדת שנכשלת לא תבחין איזה פה שבר, ותלות-9 חוסמת את שניהם יחד.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; flag-OFF byte-identity — `card_keyboard_screen_test` (ברירת-מחדל → `SizedBox.shrink`) חוזר ירוק (הקוד החדש כולו אחרי ה-self-gate ב-`card_keyboard_screen.dart:400`); כל `test/features/card_keyboard/` ירוק + `card_front_door_seed_test`; להריץ עם taskkill-dart-לפני + retry-wrap לכשלי-טעינת-isolate (תקלת-השער המתועדת); לוודא אין memo-leak (`_diveVersion`/`_memoVersion` מתואמים אחרי כל זרע, `card_keyboard_screen.dart:144-152`); לאשר ש-`answeredAxes` לא הושחת (לא הוסף ציר-זרע ל-`answered` של `_mergedChips`).

**9. תכנון נוסף (שלי):** **מטמון `assembleKit`-per-recipe**. `assembleKit` סורק את כל `kDivePool` עם `searchRelevance` לכל acc — יקר. אם פה-העבודה מציג רשימת-מתכונים, אסור להריץ `assembleKit` בכל render. לבנות `final Map<String,Set<String>> _recipeSkus = {for(r in kSmartProducts) r.key: assembleKit(r).where(...).map(sku).toSet()}` ברמת-top-level (פעם-אחת-לאיזולייט, כמו `cardKeyboardLexicon` ב-`card_keyboard_screen.dart:40`).

**10. תכנון נוסף (שלי):** **מדיניות null-carry-along עקבית בין זרע-לבין-ציר.** ה-tap-predicate של `MaterialSignal.matches` (`card_signals.dart:221-224`) שומר גם null-material (carry-along). אבל זרע-החומר שמשתמש ב-`productsOfMaterial` (`materialOf(p)==material`, שוויון מדויק) **לא** שומר null. סתירה זו תיצור התנהגות-שונה בין "פתחתי דרך פה-החומר" ל"לחצתי שבב-חומר באמצע-צלילה". להחליט פעם-אחת (סביר: זרע-פתיחה מדויק, שבב-עומק carry-along) ולתעד בבדיקה כדי שלא ייסחף.

---

### שלב 32 — איפוס-פתיחה ממוקד-זהות בהחלפת-זהות
**1. יעד:** אחרי השלב, החלפת-הזהות-הפעילה (מעסיק/עובד) בזמן שצלילה פתוחה **מאפסת את ה-stack** של `CardKeyboardScreen` לריק — כך שמשתמש-ב לא יורש את ה-breadcrumb/בריכה של משתמש-א. לפני השלב, `stack` הוא `List<NewbieStep>` מקומי ב-`_CardKeyboardScreenState` (`card_keyboard_screen.dart:116`) שאף החלפת-זהות לא נוגעת בו → דליפת-מצב.

**2. איך בונים:** (א) להישען על seam-הזהות משלב 21 (`activeIdentityProvider` או דומה). (ב) ב-`_CardKeyboardScreenState` להוסיף `ref.listen(activeIdentityProvider, (prev,next){ if(prev!=next) _restart(); })` בתוך `build` (Riverpod `ref.listen` חוקי שם). `_restart` כבר קיים (`card_keyboard_screen.dart:226`) ומנקה stack + מקדם `_diveVersion` (שמבטל את ה-memo). (ג) לוודא ש-`_restart` גם מאפס דגלים נלווים (`_busy=false`).

**3. תקלות צפויות:**
- **`ref.listen` ב-`build` שרץ אחרי ה-self-gate** — אם נשים אותו אחרי `if(!_live) return SizedBox.shrink()`, הוא לא יירשם כשהדגל OFF (תקין: אין מה לאפס). אבל אם נשים אותו לפני, הוא ירוץ גם flag-OFF ויכול לקרוא ל-`setState` על widget מוסתר → שבירת byte-identity (ה-`_restart` קורא `setState`).
- **`setState` במהלך-build** אם `_restart` נקרא סינכרונית מ-callback של `ref.listen` בזמן ה-build הראשון.
- **שלב 21 עדיין לא קיים** (`activeIdentityProvider`) — תלות-קשה. בלי seam-הזהות אין על מה להאזין.
- **memo לא מתאפס** אם נשנה את `stack` בלי לקדם `_diveVersion` (אבל `_restart` כבר מקדם — תקין כל עוד משתמשים בו).

**4. פתרון:**
- לשים את `ref.listen` **אחרי** ה-self-gate (כשהמסך מוסתר, אין צלילה לאבד; כשיתגלה-מחדש הוא נפתח ב-`CardAskWords` ממילא).
- `_restart` כבר עטוף ב-`setState`; להבטיח שה-callback של `ref.listen` רץ בין-frames (Riverpod מבטיח שזה לא בתוך build), אבל להוסיף שמירה: רק `if(stack.isNotEmpty) _restart()` כדי לא לקרוא `setState` מיותר על stack-ריק.
- לתאם עם שלב 21: עד שהוא נבנה, להזריק `identityProvider` כפרמטר-בדיקה (override ב-`ProviderScope`) ולאמת את הניתוק לוגית.

**5. בדיקות:** `card_identity_reset_test.dart`:
- `'identity switch clears the dive stack'`: בונים מסך עם `forceLiveForTest`, דוחפים 2 steps (`state.crumbs.length==2`), משנים את `identityProvider` (`container.read(identityProvider.notifier).state = 'B'`), `pump`, ואז `expect(state.crumbs, isEmpty)` + `expect(state.verdict, isA<CardAskWords>())`.
- `'switch with empty stack is a no-op'`: ללא steps, החלפה לא זורקת ולא קוראת setState מיותר (אפשר למנות builds דרך counter).
- `'flag OFF: identity switch does nothing observable'`: flag-OFF, החלפת-זהות → עדיין `SizedBox.shrink`, אפס rebuilds נראים.

**6. שיפור:** במקום `ref.listen`+`_restart` הרכים, להפוך את ה-stack עצמו ל**ממוקד-זהות-מקור**: לשמור `stack` תחת מפתח-זהות (`Map<IdentityKey,List<NewbieStep>>`) או ב-`StateNotifier` ממוקד-family. אז החלפת-זהות לא "מאפסת" אלא פשוט **מציגה stack אחר** — וחזרה לזהות-המקורית משחזרת את הצלילה. זה גם פותר את שלב 78 (breadcrumb-מסלול) בחינם וממקם נכון את "האם היסטוריה גלובלי או employer-scoped" (השאלה-הפתוחה של שלב 21).

**7. ריאלי?:** **כן, אטומי — אך חסום-על-21.** ה-mechanism עצמו זעיר (`ref.listen`→`_restart`, ושניהם כבר קיימים — `_restart` ב-`card_keyboard_screen.dart:226`). הסיכון היחיד הוא שהוא תלוי-קשה ב-seam-הזהות של שלב 21 שטרם נבנה; ברגע שיש `activeIdentityProvider` להאזין-עליו, השלב אטומי ובדיק-יחידה לחלוטין. עד אז אפשר לאמת לוגית עם `identityProvider` מוזרק (override ב-`ProviderScope`).

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF הוא הקריטי** — ה-`ref.listen` ממוקם אחרי ה-self-gate, אז `card_keyboard_screen_test` (flag-OFF → `SizedBox.shrink`, אפס rebuilds נראים) חוזר ירוק; `card_identity_reset_test` ירוק; לוודא אין `setState after dispose` (ה-callback לא יורה על widget מפורק) ואין rebuild-מיותר על stack-ריק; להריץ עם retry-wrap לכשלי-isolate; לאמת שה-memo התאפס (`_diveVersion` קודם ע"י `_restart`).

**9. תכנון נוסף (שלי):** **גם sheet פתוח חייב להיסגר.** אם החלפת-הזהות קורית כששלב-resolve פתח `showLipskeyProductSheet` (`card_keyboard_screen.dart:211/367`), ה-sheet של מוצר-של-זהות-א נשאר על המסך מעל זהות-ב. צריך `Navigator.popUntil`/לסגור modal-barriers בעת-איפוס, או לשמור `_openSheetRoute` ולסגור אותו ב-`_restart`. הבדיקה: החלפה-בזמן-sheet-פתוח → אין sheet.

**10. תכנון נוסף (שלי):** **לאפס גם warm-start cache (שלב 22).** שלב 22 מזריק שבבי-מוצר-חמים מ-`lastTouchedSkus` בפתיחה. ה-cache הזה ממוקד-זהות מטבעו; אם איפוס-הזהות לא מבטל אותו, הפתיחה-מחדש תציג מוצרים-חמים של הזהות-הקודמת. לוודא ש-`_restart` מבטל גם את הזרעת-ה-warm-start (או ש-warm-start נקרא-מחדש מ-provider ממוקד-זהות שכבר התעדכן).

---

### שלב 33 — כיסוי דלת-קדמית: כל פה נוחת מוצר ≤6
**1. יעד:** אחרי השלב יש **מפקד-בדיקה ממצה** שמוכיח שכל אחד מ-4 פיות-הלחיצה (word/material/job/category) מתכנס למוצר תוך ≤6 תורים בתרחיש-הגרוע-ביותר, דרך מסלול "רשימה-ואז-בחר" (ShowProducts עד-תור-5, בחירה=תור-6). לפני השלב אין הוכחת-≤6 ל-`CardFrontDoor` — רק ל-mergedKeys הגולמי.

**2. איך בונים:** (א) לכתוב מפקד שמדמה לכל פה את הזרע (קוראים ישירות ל-`mergedKeys` עם `NewbieStep` הזרע המתאים), ואז מריץ לולאת-greedy שבכל תור בוחר את השבב שהכי מצמצם (worst-case = הענף הגרוע), סופר תורים, ועוצר ב-`CardResolve`/`CardShowProducts`. (ב) לאמת ש-`turns <= kMaxDiveTurns`. (ג) להריץ על דגימת-זרעים מייצגת (לא חייב כל היקום בשלב הזה — זה כיסוי-משטח, לא המפקד-המוחי הממצה של שלב 69).

**3. תקלות צפויות:**
- **`kMaxDiveTurns` עדיין לא קיים** — הוא נוצר רק בשלב 67 (`card_engine.dart` היום מחזיק `kShowProductsThreshold=12`, `kFirstWordCount=24`, `kMergedKeyCap=10`, אבל אין `kMaxDiveTurns`). השלב **מקדים את מקור-האמת שלו**. צריך או להמתין לשלב 67, או להגדיר קבוע-זמני ולעדן בשלב 67 (חוב-תזמון).
- **"worst-case" לא-מוגדר-היטב**: greedy-best-split מודד מסלול-קצר, אבל ≤6 צריך את המסלול-ה**ארוך**-ביותר שמשתמש סביר ילך. מדידת greedy עלולה להחביא ענף-ארוך.
- **`assembleKit` בפה-העבודה איטי** → מפקד שמריץ אותו על כל המתכונים יהיה כבד (תקלת-קיבולת, בדיוק כמו אזהרת "כיול-לקיבולת" בזיכרון).
- **תלות בשלב 31 (פיות מחווטות) ו-32** — בלי הזרע המחווט אין מה למדוד.

**4. פתרון:**
- להגדיר `kMaxDiveTurns` **כבר כאן** כקבוע-ציבורי ב-`card_engine.dart` (=6) ולתעד שב-67 הוא יהפוך ל"מקור-יחיד" שכל המפקדים מייבאים. כך אין כפילות-עתידית — שלב 67 רק מחזק את אותו קבוע. (זה הופך את 33 ל-אטומי-יותר.)
- להגדיר worst-case מפורשות: לא greedy-best אלא **BFS/DFS שמודד את עומק-המסלול-המקסימלי** עד resolve (או, מעשי יותר: לבחור בכל תור את השבב ששומר הכי **הרבה** מוצרים — ה"מצמצם-הכי-פחות" — ולמדוד שגם אז ≤6). זה ה-worst-case האמיתי.
- למטמן `assembleKit` (כמו ההצעה בשלב 31) ולהריץ על תת-קבוצת-מתכונים מייצגת.

**5. בדיקות:** `card_front_door_reach_test.dart`:
- `'word mouth reaches a card in ≤ kMaxDiveTurns'`: לכל מילת-פתיחה ב-`wordsByFrequency(lexicon).take(kFirstWordCount)`, להריץ את לולאת-הצלילה ולאמת `turns <= kMaxDiveTurns`.
- `'material mouth ≤ turns'`: לכל `m in materialsInPool(kDivePool)`.
- `'category/job mouth ≤ turns'`: דגימה מייצגת.
- כל בדיקה: גם `turns==kMaxDiveTurns` עוברת (`<=`), וגם offenders מודפסים (כמו census ב-`recipe_kit`).

**6. שיפור:** לחלץ את לולאת-הצלילה-הגרועה ל-helper-טהור-יחיד `int worstCaseTurns(NewbieStep seed, {int max})` ב-`card_engine.dart` (לצד `mergedKeys`), כך שכל ארבעת-המפקדים (word/material/job/category) קוראים לאותה לוגיקה במקום לשכפל את לולאת-ה-greedy. זה הופך את חשבון-ה-≤6 ל**מקור-יחיד** כבר עכשיו (ולא רק `kMaxDiveTurns` הקבוע), מונע סטייה בין מפקדי-הפיות, ומכין ישירות את שלב 67 (השער-הקשיח) ו-69 (המפקד-המוחי) שיוכלו לייבא את אותו helper במקום להמציא-מחדש.

**7. ריאלי?:** **גבולי — נוטה לפיצול.** השלב כתוב כ"כיסוי 4 פיות" אבל הוא בולע: (א) הגדרת `kMaxDiveTurns`, (ב) הגדרת חשבון-worst-case, (ג) מפקד לכל פה. מומלץ לפצל ל-33a (לקבע `kMaxDiveTurns` + חשבון רשימה-ואז-בחר על מילה-בלבד) ו-33b (הרחבה ל-material/job/category). אחרת בדיקה-בודדת תיכשל ולא יהיה ברור איזה פה שבר.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; flag-OFF byte-identity (`card_keyboard_screen_test` עובר — `SizedBox.shrink`); כל ה-`card_*` packages ירוקים (`flutter test test/features/card_keyboard/`); להריץ עם `--total-shards`/retry-wrap לכשלי-טעינת-isolate (תקלת-השער המתועדת בזיכרון). לוודא שאין memo-leak: `_diveVersion`/`_memoVersion` מתואמים אחרי כל זרע.

**9. תכנון נוסף (שלי):** **allowlist ל-offenders.** בדיוק כמו ששלב 67/100 מתארים allowlist-מצטמצם, גם מפקד-33 צריך רשימת-היתר מפורשת (מתכונים/חומרים ידועים-בעייתיים) במקום כשל-בינארי — כך שאפשר לנעול את ה-baseline (כמה כרטיסים-בעייתיים יש היום) ולמנוע **רגרסיה** מבלי לחסום את כל הבנייה על פריט-קצה בודד.

**10. תכנון נוסף (שלי):** **בדיקת-שקילות פה-מול-מאתר-הישן.** הפה-החדש אמור להגיע לאותם כרטיסים כמו `word_finder_screen`. כדאי לאמת שכל כרטיס שמילת-פתיחה מגיעה אליו ב-`CardFrontDoor`, גם `offerQuestion` (המנוע-הישן, `word_finder_engine.dart`) מגיע אליו — כך שהמיזוג לא **מאבד** מוצרים שהיו נגישים. זה תופס נסיגת-כיסוי שמפקד-≤6 לבדו לא יתפוס (ספירה תקינה אך כרטיס-יתום נעלם).

---

### שלב 34 — מקור-מילים-נרדפות יחיד: `normalizeQuery` לטקסט-ו-predictions
**1. יעד:** אחרי השלב קיים `synonym_bridge.dart` עם `normalizeQuery(String)` יחיד שמקפל מילים-נרדפות (copper/brass/פליז→נחושת, pipe→צינור, elbow→ברך...) ל**מקור-אחד**, ו**גם** מסלול-הטקסט (`resolveQuery`, שלב 35) **וגם** `keyboard_predictions` משתמשים בו — כך שאין סטייה בין מה שהקלדה פותרת לבין מה שהחיזוי מציע. לפני השלב אין נרמול-נרדפות מאוחד; `searchRelevance` (`catalog_screen.dart:187`) מטפל בנרדפות-משלו, ו-`kMaterials` (`material_lexicon.dart:48`) מקפל פליז→נחושת בנפרד — שלושה מקורות-נרדפות נפרדים.

**2. איך בונים:** (א) קובץ טהור חדש `lib/features/word_finder/synonym_bridge.dart` (אפס Flutter, כמו `narrow_axis.dart`). (ב) `const Map<String,String> kSynonymFold` — מילה-נרדפת→קנונית (en→he וגם he-variants). למשוך את הזוגות שכבר קיימים: `kMaterials` (פליז→נחושת), ומה-synonyms של `searchRelevance`. (ג) `String normalizeQuery(String raw)` — tokenize, מיפוי כל token דרך `kSynonymFold` (חוסר-התאמה=המילה כמו-שהיא), חיבור-חזרה. (ד) לחבר את `keyboard_predictions.predictionChips` ו-`resolveQuery` (35) לקרוא ל-`normalizeQuery` ראשון.

**3. תקלות צפויות:**
- **שבירת `searchRelevance` הקיים**: אם נחליף את לוגיקת-הנרדפות שלו ב-`normalizeQuery`, נשנה את ציוני-הרלוונטיות → `recipe_kit` (שמסתמך על ספי-`kKitAutoScore=140`/`kKitAutoMargin=40`, `recipe_kit.dart:135/142`) ישנה את חלוקת `KitMatch.auto/ambiguous` → `measureKitCoverage` יזוז → בדיקות-כיסוי נשברות.
- **כפל-קיפול**: אם `normalizeQuery` מקפל פליז→נחושת **וגם** `materialOf` מקפל, מילה כבר-קנונית עלולה להתפצל-ולהתאחד באופן לא-עקבי.
- **over-folding**: מיפוי aggressive ('צינור'→משהו) עלול למחוק הבחנות אמיתיות.
- **`keyboard_predictions` הוא PURE** (`keyboard_predictions.dart:30` — אפס Flutter/widgets). `synonym_bridge` חייב להישאר טהור כדי לא לזהם אותו.

**4. פתרון:**
- **לא לגעת ב-`searchRelevance`** בשלב הזה. `normalizeQuery` רק מנרמל את ה**קלט** לפני שהוא מגיע ל-`resolveQuery`/`predictionChips`; את `searchRelevance` משאירים byte-identical (אז `recipe_kit` לא זז). מיזוג-מקורות-הנרדפות-המלא הוא שלב-עתידי מפורש, לא כאן.
- `kSynonymFold` ממופה רק לקנוניות שכבר ב-`kMaterials`/lexicon (לא ממציא). בדיקת-idempotence: `normalizeQuery(normalizeQuery(x))==normalizeQuery(x)`.
- שמירת `synonym_bridge.dart` טהור — לאמת ב-import-test שאין `package:flutter`.

**5. בדיקות:** `synonym_bridge_test.dart`:
- `'copper/brass/פליז all fold to נחושת'`: `expect(normalizeQuery('copper'), contains('נחושת'))` וכן `'brass'`, `'פליז'`.
- `'fold is idempotent'`: לכל מפתח, `normalizeQuery∘normalizeQuery == normalizeQuery`.
- `'unknown words pass through unchanged'`: `normalizeQuery('ברז')=='ברז'`.
- `'predictions and resolveQuery use the same fold'` (parity): `predictionChips` על שאילתת-'copper' מציע אותם כרטיסים כמו 'נחושת' (אחרי שלב 35).
- `'pure: no flutter import'`: בדיקת-מטא שהקובץ לא מייבא widgets.

**6. שיפור:** במקום `Map<String,String>` שטוח, להגדיר `kSynonymGroups` כ-`List<Set<String>>` (כל קבוצה = מילים-שקולות) ולגזור ממנו את ה-fold-map עם בורר-קנוני דטרמיניסטי (הקצר/הראשון). זה מונע באג-עקיפות (a→b, b→c בלי a→c), הופך את ה"קיפול-אחד" לבדיק (כל קבוצה מקפלת לאיבר-אחד), ומאפשר ל-`MaterialSignal`/`searchRelevance` בעתיד לצרוך **את אותו** מקור.

**7. ריאלי?:** **כן, אטומי ובדיק** — קובץ-טהור-בודד + פונקציה-טהורה + בדיקות-יחידה. אין UI, אין flag, אין מצב. זה אחד השלבים הנקיים ביותר ב-batch. (תלות: —, באמת עצמאי.)

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין flag/UI להפר byte-identity, אבל **חובה** לאמת ש-`searchRelevance` (`catalog_screen.dart:187`) ו-`recipe_kit.measureKitCoverage` **לא זזו** (השלב לא נוגע בהם) — להריץ `recipe_kit_test` ולוודא שספירות-ה-`KitMatch` זהות; `synonym_bridge_test` ירוק; בדיקת-טוהר (אין `package:flutter` ב-`synonym_bridge.dart`); idempotence עובר. אין מצב/timer/isolate-race (פונקציה-טהורה).

**9. תכנון נוסף (שלי):** **כיסוי-ניב/שגיאות-כתיב, לא רק תרגום-שפה.** משתמש-אמיתי יקליד "נחשת" (חסר ו), "פליז'", "ניפל"/"ניפעל". `normalizeQuery` צריך לטפל גם בנירמול-ניקוד/רווחים-כפולים/גרשיים (״ vs "), לא רק en→he. להוסיף שלב-נירמול-תווים (trim, collapse-whitespace, unify-quotes) **לפני** ה-fold.

**10. תכנון נוסף (שלי):** **טבלת-נרדפות מאומתת-מול-הקטלוג.** סכנה: להוסיף 'pipe'→'צינור' אבל בקטלוג המילה היא 'צנרת'/'מ.צינור'. צריך בדיקת-מטא שכל **ערך-קנוני** ב-`kSynonymFold` באמת מופיע ב-`cardKeyboardLexicon`/`kDivePool` (אחרת הקיפול מצביע למילה-שלא-מחזירה-מוצרים — מבוי-סתום שקט). זה תופס נרדפות-מתות בזמן-בנייה.

---

### שלב 35 — מתרגם-שאילתה טהור `resolveQuery()` מזין בריכה-אחת
**1. יעד:** אחרי השלב קיים `resolveQuery(String, lexicon)` טהור שלוקח טקסט-חופשי → `normalizeQuery` (34) → tokenize → `resolveWord` per-token → **union** של ה-sku-sets → **AND-חיתוך** בין-tokens (עם fallback ל-union כשהחיתוך ריק, כדי שלא ייווצר מבוי-סתום) → בריכת-מוצרים אחת זהה לזו שפה-הרשת מזין. parity: copper==נחושת==פליז מחזירים אותה בריכה. לפני השלב, הקלדה אינה מסלול ב-`CardKeyboardScreen` כלל (רק לחיצת-מילים).

**2. איך בונים:** (א) ב-`synonym_bridge.dart` או קובץ-אח `query_resolver.dart` טהור. (ב) `List<LipskeyCatalogProduct> resolveQuery(String raw, WordLexicon lex)`: `final toks = normalizeQuery(raw).split(ws)`; לכל token `resolveWord(tok, lex)` (`word_finder_engine.dart:528`) → `Set<sku>`. (ג) חיתוך-AND: בריכה=מוצרים ש-`skuSet` שלהם בכל-ה-token-sets; אם ריק → להחזיר union (fallback). (ד) למיין דטרמיניסטית (sku) ולמפות חזרה דרך `_divePoolBySku` (כבר קיים ב-`word_finder_engine.dart:222`, אבל הוא private — צריך helper ציבורי או לבנות אינדקס מקומי).

**3. תקלות צפויות:**
- **`_divePoolBySku` הוא private** (`word_finder_engine.dart:222`). `resolveQuery` בקובץ-אחר לא יכול לקרוא לו. צריך אינדקס-ציבורי או לבנות מקומי (כפילות).
- **AND-חיתוך מרוקן הכל**: 'ברז נחושת 1/2' — אם token כלשהו לא-מוכר ב-lexicon, `resolveWord` מחזיר ריק → חיתוך=ריק. ה-fallback ל-union הכרחי, אבל union עלול להחזיר בריכה-ענקית (כל מוצר עם 'ברז' או 'נחושת').
- **`resolveWord` מחזיר רק מילים-בלקסיקון** — מספרים/גדלים ('1/2"') אינם מילות-lexicon (ה-tokenizer ב-`wordOptions` מסנן `\d`). אז token-גודל לא יתרום לחיתוך → 'ברז 1/2' מתנהג כמו 'ברז'.
- **טוהר**: אסור לייבא Flutter ל-`resolveQuery`.

**4. פתרון:**
- לחשוף אינדקס-ציבורי: או להוסיף `Map<String,LipskeyCatalogProduct> divePoolBySku` ציבורי ל-`dive_pool.dart` (לצד `divePoolIndex` הקיים), או helper `productForSku`. זה גם מנקה כפילות עתידית.
- fallback מדורג: חיתוך-AND מלא → אם ריק, חיתוך של ה-tokens-המוכרים-בלבד → אם עדיין ריק, union → אף-פעם-לא-ריק (אלא אם כל ה-tokens לא-מוכרים, ואז בריכה=ריקה במכוון).
- לטפל ב-token-גודל בנפרד: לאחר resolveWord, להעביר את הבריכה דרך `applyNarrow(pool, sizeToken)` (`word_finder_engine.dart:542`) עבור token שנראה כגודל (`productHasChip`). זה משלב טקסט+גודל באמת.
- import-test לטוהר.

**5. בדיקות:** `query_resolver_test.dart`:
- `'parity copper==נחושת==פליז'`: שלוש השאילתות מחזירות בריכה זהה (set of skus).
- `'multi-word AND narrows'`: `resolveQuery('ברז נחושת')` ⊊ `resolveQuery('ברז')` (חיתוך מצמצם).
- `'all-unknown → empty (honest)'`: `resolveQuery('xyzzy', lex)` ריק.
- `'unknown token falls back, never dead-ends'`: `resolveQuery('ברז zzz')` לא-ריק (fallback ל-'ברז').
- `'size token narrows via productHasChip'`: `resolveQuery('ברז 1/2"')` ⊆ מוצרים-עם-1/2".
- `'deterministic under repeat'`: אותה שאילתה ⇒ אותה רשימה.

**6. שיפור:** להחזיר `({List<LipskeyCatalogProduct> pool, List<String> matchedTokens, List<String> unknownTokens})` במקום רק בריכה — כך פה-הטקסט (37) יכול להציג "לא הבנתי: zzz" ולהדגיש איזה token לא-נתרם. זה הופך 0-תוצאות מ"מבוי-סתום שקט" ל**משוב-בונה**, ומכין את שלב 41 (עידון תוך-צלילה).

**7. ריאלי?:** **כן, אטומי** — פונקציה-טהורה אחת מעל primitives קיימים (`normalizeQuery`, `resolveWord`, `applyNarrow`). תלוי בשלב 34 בלבד. בדיק-לחלוטין ביחידה.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין UI/flag (פונקציה-טהורה) — byte-identity לא-רלוונטי-ישירות, אבל אם נחשף `divePoolBySku` ציבורי חדש ב-`dive_pool.dart`, לוודא ש-`dive_pool_test` עדיין ירוק ושלא שונה `kDivePool`/`divePoolIndex`; `query_resolver_test` ירוק (parity, AND-narrow, empty-honest, fallback, size-token, determinism); בדיקת-טוהר (אין Flutter); אין מצב/timer. להריץ פעמיים לאשר דטרמיניזם (אותה שאילתה ⇒ אותה רשימה).

**9. תכנון נוסף (שלי):** **חיבור לשער-ה-≤6 כבר כאן.** `resolveQuery` מחזיר בריכה — אבל אם הבריכה גדולה (כל-הברזים), המשתמש עדיין רחוק ממוצר. צריך שהבריכה הזו תיכנס לאותה `mergedKeys`-ladder (כ-NewbieStep-זרע, בדיוק כמו `_WordTap`), לא כרשימה-שטוחה. לתכנן את ה-seam כך ש-`resolveQuery` ⇒ `Set<sku>` ⇒ `NewbieStep(axisLabel:'שאילתה', predicate)` — מתחבר ישירות ל-`_onWordTap`. זה מבטיח שטקסט מקבל את אותו ≤6-guarantee כמו לחיצה.

**10. תכנון נוסף (שלי):** **קאש-LRU לשאילתות-תכופות.** `resolveQuery` רץ על כל keystroke (אחרי debounce, שלב 36). resolveWord+חיתוך על בריכה-של-אלפים פר-token יכול להצטבר. מטמון קטן (שאילתה-מנורמלת→בריכה) חוסך חישוב-חוזר על הקלדה-איטית/מחיקה-והקלדה-מחדש. דטרמיניסטי ולכן בטוח לקאש.

---

### שלב 36 — controller-שאילתה משוהה (scheduler מוזרק)
**1. יעד:** אחרי השלב קיים controller שמשהה (debounce) קריאות ל-`resolveQuery` כך שהקלדה-מהירה פותרת **פעם-אחת** (בסוף הרצף), לא פר-תו. ה-scheduler/timer **מוזרק** (test seam) כדי שבדיקה תוכל להריץ זמן-מדומה בלי `await Future.delayed` אמיתי. לפני השלב — אין מסלול-טקסט בכלל.

**2. איך בונים:** (א) `QueryController` (או `ChangeNotifier`/`StateNotifier`) שמחזיק `Timer? _debounce` ו-`Duration debounceMs`. (ב) `void onChanged(String raw)` — מבטל timer קודם, מתזמן חדש ל-`debounceMs`, שבסיומו קורא `resolveQuery` ומפרסם תוצאה. (ג) **הזרקת-scheduler**: `typedef SchedulerFn = Timer Function(Duration, void Function())` עם ברירת-מחדל `Timer` — בדיוק כמו `VoiceListenFn` ב-`voice_dictate_button.dart:5` (תקדים-הזרקה בקוד). (ד) `dispose` שמבטל timer.

**3. תקלות צפויות:**
- **דליפת-Timer** אם `dispose` לא מבטל את `_debounce` → בדיקות-flutter תופסות "Timer still pending" / pending-timer-after-test.
- **`pumpAndSettle` תלוי בזמן-אמיתי**: אם ה-debounce אמיתי, `pumpAndSettle` עלול לא-להתכנס או לקחת זמן → תקלת-flaky.
- **race עם setState אחרי-dispose**: ה-timer יורה אחרי שה-widget נעלם → `setState() called after dispose`.
- **double-fire**: אם `onChanged` נקרא בזמן ש-timer פעיל, חייב לבטל-ולתזמן-מחדש, אחרת שתי-פתירות.

**4. פתרון:**
- `dispose()` חובה לבטל `_debounce?.cancel()`. בדיקת-leak מפורשת.
- להזריק `SchedulerFn` בבדיקות → להריץ את ה-callback סינכרונית/בשליטה (`FakeAsync` או seam שמריץ-מיד), כך שאין תלות-בזמן-אמיתי.
- שמירת `if(!mounted) return` לפני setState ב-callback (אם זה widget) או לבדוק `disposed` ב-notifier.
- הבדיקה "הקלדה-מהירה פותרת-פעם-אחת" סופרת קריאות ל-resolveQuery (mock/counter).

**5. בדיקות:** `query_controller_test.dart`:
- `'rapid input resolves once'`: עם scheduler-מוזרק, `onChanged('ב')...onChanged('ברז')` ברצף → רק קריאה-אחת ל-resolve (counter==1) על המחרוזת-האחרונה.
- `'debounce cancels prior pending'`: שני onChanged עם flush-ביניהם → שתי קריאות; בלי flush → אחת.
- `'dispose cancels timer (no leak)'`: `onChanged` ואז `dispose` מיד → אין pending-timer (הבדיקה לא מתלוננת על leak).
- `'no setState after dispose'`: dispose בזמן-timer-פעיל → flush → אין exception.

**6. שיפור:** להפריד את ה-debounce ל-helper-טהור `Debouncer(SchedulerFn)` רב-שימושי (לא קשור-לשאילתה), ולהפוך את `QueryController` לדק שמחבר `Debouncer`+`resolveQuery`+פרסום. כך ה-debounce עצמו נבדק במנותק, וגם פה-הקול (38) יכול לעבור דרך אותו controller (קול=onChanged-בודד, בלי debounce — אבל אותו צינור-פרסום → parity מובטח).

**7. ריאלי?:** **כן, אטומי.** controller-בודד עם seam-הזרקה. תלוי ב-35. הבדיקה נקייה בזכות הזרקת-ה-scheduler (תקדים `VoiceListenFn` כבר בקוד).

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין שינוי-UI גלוי flag-OFF (ה-controller לא מורכב כשהמסך מוסתר); **הקריטי כאן: אפס pending-timer** — `query_controller_test` (כולל "dispose cancels timer", "no setState after dispose") חייב לעבור, ו-`flutter test` לא מתלונן על "Timer still pending after test"; להריץ עם scheduler-מוזרק (לא זמן-אמיתי) כדי שלא יהיה flaky; retry-wrap לכשלי-isolate.

**9. תכנון נוסף (שלי):** **לבטל פתירה-מיושנת (stale-result guard).** אם המשתמש מקליד 'ברז', ה-resolve מתחיל, ואז הוא מוחק ל-'בר' — ה-resolve-של-'ברז' עלול לחזור **אחרי** ה-resolve-של-'בר' ולדרוס אותו (resolveQuery סינכרוני היום, אבל אם יהפוך async/יקבל מטמון-async — race). להוסיף `_seq` (מונה-רצף) ולהתעלם מתוצאה שה-`_seq` שלה אינו האחרון. (זה בדיוק דפוס `_seq` ל-id המתועד בזיכרון-המלכודות.)

**10. תכנון נוסף (שלי):** **debounce אדפטיבי לאורך-שאילתה.** שאילתה של תו-בודד מחזירה בריכה-ענקית ויקרה לחשב; שאילתה ארוכה זולה. כדאי debounce ארוך-יותר ל-1-2 תווים (להימנע מחישוב-ענק חסר-טעם) וקצר-יותר ל-3+. או: לא-לפתור-בכלל מתחת ל-2 תווים (להציג רק את שורת-המילים). זה משפר חוויית-הקלדה ומוריד עומס-CPU על המקרה-הגרוע.

---

### שלב 37 — ווידג'ט פה-טקסט (משוהה, ספירה-חיה)
**1. יעד:** אחרי השלב יש ווידג'ט פה-טקסט: `TextField` ב-RTL מחובר ל-`QueryController` (36), שמציג ספירה-חיה 'נמצאו N' תוך-כדי-הקלדה (N=`resolveQuery(...).length` של כרטיסים-נבדלים). לפני השלב אין שדה-הקלדה ב-`CardFrontDoor`.

**2. איך בונים:** (א) `CardTextMouth` StatefulWidget שמחזיק `QueryController`+`TextEditingController`. (ב) `TextField(textDirection: TextDirection.rtl, ...)` שמזין `controller.onChanged`. (ג) להאזין ל-controller ולהציג `Text('נמצאו ${count}')` כאשר count = `distinctCardCount(pool)` (`word_finder_engine.dart:279`) ולא `pool.length` (אחרת variants נספרים פעמיים). (ד) onSubmit/בחירה → `onSeed(_QuerySeedTap(text))` (חיווט בשלב 40).

**3. תקלות צפויות:**
- **`distinctCardCount` vs `pool.length`**: הצגת `pool.length` תנפח את N (variants). בדיוק הטעות שהזיכרון מתאר ("100% מנופח") בהקשר-אחר — לספור נבדלים.
- **RTL+מספרים+מירכאות**: 'נמצאו 12' ב-RTL עלול להציג את המספר בצד-הלא-נכון; וגדלים כמו 1/2" בתוך השדה שוברים bidi.
- **rebuild-storm**: כל keystroke → setState → rebuild של כל ה-`CardFrontDoor`. אם הספירה ב-root, כל הפיות מצוירות-מחדש.
- **Riverpod override-count**: אם הווידג'ט קורא provider, בדיקת-widget שמשנה state בין-pumps לא יכולה לשנות מספר-overrides (מלכודת Riverpod מתועדת).

**4. פתרון:**
- להשתמש ב-`distinctCardCount(resolveQuery(text))` לספירה.
- לעטוף את שדה-המספר ב-`Directionality(textDirection: ltr)` רק לתצוגת-המספר, או להשתמש ב-`Text.rich` עם bidi-isolate; לאמת ב-golden-טקסט (לא golden-תמונה — שביר).
- למקם את ה-'נמצאו N' ב-`ValueListenableBuilder`/`Consumer` ממוקד **רק** סביב הספירה, לא ב-root → לא rebuild-storm.
- לא להוסיף overrides דינמית; להזריק את ה-controller כפרמטר (test seam) במקום provider, או לשמור מספר-overrides קבוע.

**5. בדיקות:** `card_text_mouth_test.dart`:
- `'typing copper shows a live count'`: `tester.enterText(find.byType(TextField), 'copper')`, flush-debounce (scheduler-מוזרק), `expect(find.textContaining('נמצאו'), findsOneWidget)` ו-N>0.
- `'count is distinct cards, not raw pool'`: לשאילתה עם variants ידועים, N==`distinctCardCount`, < `pool.length`.
- `'0 results shows נמצאו 0 (not a crash)'`: שאילתת-'xyzzy' → 'נמצאו 0', אין throw.
- `'RTL: field is rtl'`: `expect(textField.textDirection, TextDirection.rtl)`.

**6. שיפור:** להציג לצד-הספירה את **שלושת-הכרטיסים-המובילים** (thumbnails) כבר תוך-הקלדה (preview), לא רק מספר — כך המשתמש רואה שהוא מתקרב לפני שהוא לוחץ. מנצל את `distinctProducts(pool).take(3)` + `imageAsset` שכבר נתמך ב-`WordKey` (`word_keys_model.dart:30`, מ-R2/CDN לפי הזיכרון). הופך את הפה ל"מראה-חיה" (עיקרון keyboard-live-mirror בזיכרון).

**7. ריאלי?:** **כן, אטומי** — ווידג'ט-בודד מעל controller קיים. תלוי ב-36. בדיק-widget נקי עם scheduler-מוזרק.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; flag-OFF — הווידג'ט יושב בתוך `CardFrontDoor` שכולו מתחת ל-self-gate, אז `card_keyboard_screen_test` (flag-OFF → אין TextField) חוזר ירוק; `card_text_mouth_test` ירוק (count חי, distinct-not-raw, 0-תוצאות, RTL); **לאמת מספר-overrides של Riverpod קבוע בין-pumps** (מלכודת Riverpod — לא לשנות overrides ב-re-pump); אין pending-timer (dispose מנקה); golden-טקסט (לא תמונה) לתצוגת-הספירה כדי להימנע מ-golden-bidi שביר.

**9. תכנון נוסף (שלי):** **כפתור-ניקוי (X) + שמירת-פוקוס.** TextField בלי clear-button מאלץ מחיקה-תו-תו. להוסיף suffixIcon-X שמנקה ומחזיר ל-`CardAskWords`/רשת. וגם: בעת-זריעה השדה לא צריך לאבד-פוקוס (כדי שהמשתמש ימשיך-לעדן, שלב 41). לתכנן את ניהול-הפוקוס מראש.

**10. תכנון נוסף (שלי):** **debounce-visual: spinner/placeholder בזמן-החישוב.** בין keystroke ל-flush-של-debounce, הספירה מציגה את הערך-הישן — מטעה. להציג מצב-ביניים ('מחשב…'/עמעום) כשיש-טקסט-אך-טרם-נפתר, כדי שהמשתמש לא יחשוב ש-N=ישן הוא התוצאה-הסופית. קטן אך משמעותי לאמון.

---

### שלב 38 — ווידג'ט פה-קול (`VoiceService`, he-IL)
**1. יעד:** אחרי השלב יש ווידג'ט פה-קול: כפתור-מיקרופון שמפעיל `VoiceService.listen(localeId:'he-IL')` (`voice.dart:57`), והתמלול הסופי מוזרם לאותו controller כמו פה-הטקסט; שגיאות-מנוע (`onError`) מטופלות בכנות (לא נבלעות). לפני השלב אין קול ב-`CardFrontDoor`.

**2. איך בונים:** (א) `CardVoiceMouth` עם seam-הזרקה `VoiceListenFn`/`stopFn` — **בדיוק** כמו `VoiceDictateButton` (`voice_dictate_button.dart:5-12`), שאפשר להעתיק את דפוסו. (ב) tap→`listen(onFinal:(t)=>controller.onChanged(t), onError:(r)=>showError(r), localeId:'he-IL')`; tap-שני בזמן-האזנה→`stop`. (ג) טיפול ב-`available==false` (פלטפורמה לא-תומכת) → להציג מצב-מושבת, לא לתלות. (ד) `VoiceService.isWebUnstable` (`voice.dart:92`) → UI-מעומעם ב-web.

**3. תקלות צפויות:**
- **`VoiceService` הוא singleton** (`voice.dart:8` `static final instance`) — בלי הזרקת-seam, בדיקה לא יכולה לדמות מיקרופון → תלייה/דרישת-הרשאה אמיתית.
- **בליעת-שגיאות**: `voice.dart` כבר תוקן ל-honesty (`_failSession`), אבל אם הווידג'ט לא מעביר `onError`, ה-no-result/permission-denied שקטים והכפתור תקוע ב"מקליט".
- **מצב-listening תקוע** אם dispose קורה בזמן-האזנה בלי `stop`.
- **web flakiness** (`isWebUnstable`) — Web Speech API לא-יציב; וגם `package:web` conditional-import (מלכודת מתועדת לטסטי-פלאטר).

**4. פתרון:**
- להזריק `VoiceListenFn` (ברירת-מחדל=`VoiceService.instance.listen`), כמו התקדים. בדיקות מספקות fake-listen שקורא `onFinal('ברז נחושת')` סינכרונית.
- תמיד להעביר `onError` שמנקה את מצב-ה-listening ומציג הודעה (snackbar/inline). בדיקת-onError מפורשת.
- `dispose` קורא `stop`.
- ל-web: לעמעם/להסתיר לפי `isWebUnstable`; conditional-import ל-`package:web` אם נדרש (`if (dart.library.html)` — לפי מלכודת-הזיכרון, לא import-ישיר).

**5. בדיקות:** `card_voice_mouth_test.dart`:
- `'fake-listen ברז נחושת routes to controller'`: seam שקורא `onFinal('ברז נחושת')` → `expect(controller.lastQuery, 'ברז נחושת')` (או שהבריכה התעדכנה).
- `'onError surfaces, unsticks the mic'`: seam שקורא `onError('no-result')` → הכפתור חוזר ממצב-listening + הודעה מוצגת.
- `'unsupported platform → disabled, no hang'`: seam שמחזיר `false` → מצב-מושבת, אין exception.
- `'dispose while listening calls stop'`: stopFn-מוזרק נקרא ב-dispose.

**6. שיפור:** לאחד את פה-הקול ופה-הטקסט ל**ווידג'ט-קלט-אחד** עם כפתור-מיקרופון בתוך ה-`TextField` (suffixIcon), כך שקול=דרך-קלט-לאותו-שדה ולא פה-נפרד. זה ממש את "6 פיות שוות→controller-אחד" של שלב 39 כבר כאן, ומבטיח parity ב-construction (קול וטקסט פיזית-אותו-controller).

**7. ריאלי?:** **כן, אטומי** — ווידג'ט מעל seam קיים (`VoiceService`+תקדים `VoiceDictateButton`). תלות: — (עצמאי, רק `VoiceService`). בדיק עם fake-listen.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; flag-OFF — הכפתור בתוך `CardFrontDoor` מתחת ל-self-gate, אז byte-identity נשמר; `card_voice_mouth_test` ירוק (fake-listen→controller, onError-unsticks, unsupported→disabled, dispose→stop); **אין VoiceService-leak** — `stop` נקרא ב-dispose, אין session תקועה; אם נדרש `package:web` ל-web, conditional-import (`if (dart.library.html)`, מלכודת-הזיכרון) ולא import-ישיר; להריץ עם retry-wrap.

**9. תכנון נוסף (שלי):** **משוב-חי תוך-דיבור (partial) + הרשאת-מיקרופון מפורשת.** `voice.dart:78` מגדיר `partialResults:false` — המשתמש לא רואה כלום עד שהוא מסיים. לפחות להציג אנימציית-"מקשיב…" + תמלול-ביניים אם נפעיל partial. וגם: לבקש הרשאת-מיקרופון בלחיצה-הראשונה עם הסבר-Hebrew, לא להניח שהיא ניתנה.

**10. תכנון נוסף (שלי):** **נירמול-קול דרך אותו `normalizeQuery`.** קול מחזיר טקסט-חופשי ('נחושת חצי צול') — חייב לעבור את **אותו** `normalizeQuery`/`resolveQuery` (34/35) כמו הקלדה, אחרת 'חצי צול' (קולי) לא יתאים ל-'1/2"' (גודל). זו נקודת-ה-parity הקריטית: קול וטקסט חייבים לחלוק את כל צינור-הנרמול, לא רק את ה-controller. לתכנן ש-`onFinal`→`controller.onChanged` (ולא נתיב-עוקף).

---

### שלב 39 — משטח-כניסה מאוחד (טקסט+קול+רשת שווים)
**1. יעד:** אחרי השלב, פה-הקול מנותב לאותו `QueryController` כמו פה-הטקסט, ורשת-המילים (`CardAskWords`→`WordKeyboard`) היא פה-ההשלמה-החזויה — שלושתם **שווים** (אף אחד לא "ראשי"); #38 (הפה-הקולי כיעד-נפרד) **נבלע** לתוך המשטח-המאוחד. parity מוכח: copper-בטקסט == 'נחושת'-בקול == לחיצת-'נחושת'-ברשת מחזירים אותה בריכה. לפני השלב הפיות היו ווידג'טים-נפרדים בלי ערובת-parity.

**2. איך בונים:** (א) ב-`CardFrontDoor`, להזרים את כל-שלושת-המקורות ל-callback-זרע-אחד `onSeed(_QuerySeedTap|_WordTap)`. (ב) קול→`controller.onChanged`→(בסוף debounce/מיד)→`onSeed(_QuerySeedTap(finalText))`. (ג) רשת→`onSeed(_WordTap(word))` (כבר קיים). (ד) טקסט→`onSeed(_QuerySeedTap(submittedText))`. (ה) לוודא ששלושתם עוברים `normalizeQuery`/`resolveQuery` (34/35).

**3. תקלות צפויות:**
- **שני מסלולי-זרע שונים**: רשת משתמשת ב-`resolveWord(word)` (token-בודד), טקסט ב-`resolveQuery(text)` (multi-token+חיתוך). לחיצת-'נחושת' (resolveWord) עלולה להחזיר בריכה **שונה** מהקלדת-'נחושת' (resolveQuery) אם resolveQuery מוסיף נרמול/fallback. שבירת-parity.
- **קול שמדלג על debounce**: אם קול קורא `onSeed` ישירות אבל טקסט עובר debounce, התזמון שונה — אך התוצאה צריכה להיות זהה. הסיכון: קול עוקף את `normalizeQuery`.
- **כפילות-זרע**: קול ש-`onFinal` + גם `controller.onChanged` שמפעיל resolve → שני steps.

**4. פתרון:**
- **לאחד את resolveWord ו-resolveQuery**: `resolveQuery('נחושת')` (token-בודד) **חייב** להיות שווה ל-`resolveWord('נחושת')`-המנורמל. לבנות `resolveQuery` כך שעל token-בודד-מוכר היא מחזירה בדיוק `resolveWord(normalized)`. בדיקת-parity מפורשת תופסת סטייה.
- כל המקורות עוברים את **אותה** `resolveQuery` (לא resolveWord ישיר ברשת) — או לפחות אותו `normalizeQuery` קודם. הרשת תקרא `resolveQuery(word)` במקום `resolveWord` ישיר.
- קול: `onFinal`→`onChanged`→זרע-יחיד (לא גם-וגם). מונה re-entrancy (`_busy` כבר קיים ב-`card_keyboard_screen.dart:120`).

**5. בדיקות:** `unified_entry_parity_test.dart`:
- `'copper-text == נחושת-voice == נחושת-grid'`: שלושת-המסלולים → אותו `Set<sku>` בבריכה. **הבדיקה המרכזית של השלב.**
- `'voice routes through normalizeQuery'`: fake-voice-onFinal('חצי צול') → בריכה==`resolveQuery('1/2"')`-המקבילה (אם הנרמול ממפה).
- `'no double-seed from voice'`: onFinal → בדיוק step-אחד נדחף (`crumbs.length==1`).
- `'grid word uses resolveQuery not bare resolveWord'`: לחיצת-מילה ⇒ בריכה==`resolveQuery(word)`.

**6. שיפור:** להפוך את ה-parity מ"מאומת-בבדיקה" ל"מובטח-בקונסטרוקציה": לנתב את **כל** שלושת-המקורות (טקסט/קול/רשת) דרך **פונקציה-יחידה** `seedFromQuery(String) → NewbieStep` — כך שאין שני מסלולי-קוד שיכולים-להיסחף. הרשת תקרא `seedFromQuery(word)` (לא `_WordTap`→`resolveWord` ישיר), הטקסט `seedFromQuery(text)`, הקול `seedFromQuery(finalText)`. ברגע ש-resolveWord↔resolveQuery מאוחדים מאחורי-שער-אחד, ה-parity-המשולש הוא tautology, לא מזל — וזה גם ה-`_SeedTap` הגנרי שמכין את שלב 62 (`seedPool`).

**7. ריאלי?:** **גבולי — תלות-יתר.** השלב מאחד 3 רכיבים (37,38, ורשת) ודורש ערובת-parity ביניהם — וזה חושף את אי-ההתאמה resolveWord↔resolveQuery שאולי דורש שינוי ב-2 קבצים. ריאלי כשלב-אינטגרציה, אבל הבדיקה-המרכזית (parity-משולש) עלולה להיכשל בגלל פער שמקורו בשלב 35. כדאי לוודא את ה-parity resolveWord↔resolveQuery כחלק-מ-35, כך ש-39 רק מחבר.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; flag-OFF: `CardFrontDoor` כולו מתחת ל-self-gate → byte-identity (אין שדה/מיקרופון כשהדגל OFF); להריץ `card_keyboard_screen_test`+`unified_entry_parity_test`+`synonym_bridge_test`+`query_resolver_test` ירוקים; אין pending-timer (פה-הטקסט dispose נקי); אין leak-של-VoiceService (stop ב-dispose).

**9. תכנון נוסף (שלי):** **מצב-ריק אחיד למשטח.** כשאין-טקסט-ואין-קול, המשטח מציג את רשת-המילים. צריך מעבר-חלק: התחלת-הקלדה מכווצת/מחליפה את הרשת (לא מערמת שתי-תצוגות). ושורת-ההיסטוריה-החמה (שלב 27) צריכה לשבת בעקביות ביחס לשלושת-הפיות. לתכנן את ה-layout-state-machine (ריק→מקליד→תוצאות) מפורשות.

**10. תכנון נוסף (שלי):** **טלמטריה-של-פה (איזה פה הביא לכרטיס).** כדי לאמת ש"6 פיות שוות" באמת-שוות בשימוש, להוסיף שדה-מקור ל-`NewbieStep`/event (`mouthId`) — render-only/analytics, לעולם-לא-ניתוב (כמו `isDestination` בשלב 85). זה גם יזין את מפקד-≤6 (33/69) לדעת איזה פה כיסה איזה כרטיס, ויחשוף פה-מת.

---

### שלב 40 — חיווט משטח-הכניסה לפתיחת-המסך (`_QuerySeedTap`)
**1. יעד:** אחרי השלב, `CardFrontDoor` (עם טקסט+קול+רשת) מחווט מעל הרשת ב-`CardKeyboardScreen` כך שב-stack-ריק (`CardAskWords`) מופיע משטח-הכניסה המלא, ולחיצת-זרע-טקסט פותחת step ('נחושת'→crumb). flag-OFF: אין-תיבה (byte-identity). לפני השלב, ב-stack-ריק המסך מציג רק `WordKeyboard` עירום (`card_keyboard_screen.dart:447-455`).

**2. איך בונים:** (א) להוסיף `_QuerySeedTap(query)` למשפחת `_Tap` (`card_keyboard_screen.dart:59`). (ב) ב-`_keysFor`/`build`, כש-`verdict is CardAskWords`, להחליף את `WordKeyboard` הגולמי ב-`CardFrontDoor(mouths: kCardMouths, onSeed: _onSeed, ...)`. (ג) `_onSeed(_QuerySeedTap q)`: `final skuSet = resolveQuery(q.query, cardKeyboardLexicon).map((p)=>p.sku).toSet()`; `_pushStep(NewbieStep(axisLabel:'שאילתה', chipLabel:q.query, crumbWord:q.query, predicate: skuSet.contains))` — בדיוק כמו ענף `_WordTap` (`card_keyboard_screen.dart:318-334`). (ד) הכל מתחת ל-self-gate (`card_keyboard_screen.dart:400`).

**3. תקלות צפויות:**
- **`CardFrontDoor`/`kCardMouths` לא קיימים** — שלב 30 (תלות) טרם נבנה בקוד. בלי המעטפת אין מה לחווט. **חוב-תזמון מהותי.**
- **שבירת byte-identity flag-OFF**: אם `CardFrontDoor` נבנה לפני ה-self-gate, או אם הוא קורא provider שמשנה את עץ-הווידג'טים גם flag-OFF.
- **`CardAskWords` כבר מציג רשת** — החלפה ל-`CardFrontDoor` משנה את ה-golden-ON (אם יש). וגם, אם `CardFrontDoor` עוטף `WordKeyboard`, בדיקת `findsOneWidget(WordKeyboard)` ב-`card_keyboard_screen_test:63` עדיין צריכה לעבור (רשת בתוך המעטפת).
- **stack-לא-ריק**: כשהמשתמש כבר זרע, אסור שמשטח-הכניסה יופיע שוב (רק `MergedKeys`). החיווט חייב להיות **רק** ב-`CardAskWords`.

**4. פתרון:**
- **תזמון**: שלב 40 חוסם-על-30. אם בונים לפי-סדר, 30 כבר שם. אם לא — להזריק `CardFrontDoor` כ-stub מינימלי (header+history+WordKeyboard) שמתרחב בשלב 30. לתעד את התלות.
- כל החיווט **אחרי** `if(!_live && !forceLiveForTest) return SizedBox.shrink()`. בדיקת flag-OFF (`card_keyboard_screen_test:22`) חוזרת לוודא `SizedBox.shrink` + אין-TextField.
- לשמור את `WordKeyboard` **בתוך** `CardFrontDoor` כך ש-`find.byType(WordKeyboard)` עדיין `findsOneWidget`; אם משנים את ה-golden-ON, לברך-מחדש מפורשות (כמו שלב 66 מתאר).
- החיווט מותנה ב-`v is CardAskWords` בלבד (ה-switch ב-`build`).

**5. בדיקות:** `card_front_door_wiring_test.dart`:
- `'flag OFF → no front door, no TextField'`: ברירת-מחדל → `SizedBox.shrink`, `find.byType(TextField) findsNothing`, `find.byType(CardFrontDoor) findsNothing`.
- `'flag ON → front door with grid + text + voice'`: `forceLiveForTest:true` → `CardFrontDoor findsOneWidget`, `WordKeyboard findsOneWidget`, `TextField findsOneWidget`.
- `'נחושת query seed → crumb נחושת, axis שאילתה not material'`: `enterText('נחושת')`+submit → `state.crumbs` מכיל 'נחושת', `answeredAxes` **לא** מכיל 'חומר'/'דגם' (זרע משאיר צירים פתוחים).
- `'front door only at empty stack'`: אחרי זרע → `CardFrontDoor findsNothing` (רק שורת-MergedKeys).
- regression: `card_keyboard_screen_test` הקיים עדיין ירוק (הרשת עדיין נמצאת).

**6. שיפור:** במקום `_QuerySeedTap` שמייצר `NewbieStep` ידני ב-`_onSeed`, להשתמש ב-`_SeedTap` הגנרי המוצע בשלב 31 — כל ששת-הפיות (כולל שאילתה) מייצרות `_SeedTap` אחיד, ו-`_onWordTap` מטפל בכולן בענף-אחד. זה מנקה את ה-`_onWordTap` התופח (כבר 60 שורות, `card_keyboard_screen.dart:309-369`) ומאחד את שער-הזרע — ישירות לקראת `seedPool` של שלב 62.

**7. ריאלי?:** **גבולי — חוסם-על-30 ועל-39.** השלב עצמו קטן (הוספת `_QuerySeedTap` + החלפת ווידג'ט), אבל הוא מניח ש-30 (מעטפת) ו-39 (פיות-מאוחדות) קיימים. כשלב-חיווט-טהור הוא אטומי ובדיק; כתלוי-במעטפת-שטרם-קיימת הוא חסום. בנייה-לפי-סדר-התלויות פותרת.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF byte-identity הוא הבדיקה-הקריטית** — `card_keyboard_screen_test` (flag-OFF → `SizedBox.shrink`, אין header, אין TextField, אין WordKeyboard) חייב לעבור; כל חבילת-`test/features/card_keyboard/` ירוקה + `synonym_bridge`+`query_resolver`+`query_controller`; להריץ עם taskkill-dart-לפני + retry-wrap (תקלת-isolate); לוודא אין pending-timer (פה-הטקסט) ואין VoiceService-leak; לאשר ש-`catalog_screen.dart:2469` (המסך-הממוסך) עדיין עובר את אותו self-gate.

**9. תכנון נוסף (שלי):** **בדיקת-byte-identity ברמת-ה-pill בקטלוג.** `catalog_screen.dart` מציג pill 'מקלדת חכמה' מאחורי `kCardKeyboardFlag` (`catalog_screen.dart:724/865/2458`). שלב 40 משנה את מה-שה-pill פותח. צריך בדיקה (כמו `catalog_pills_byte_identity` שמוזכר בשלב 100) שמאמתת שכש-flag-OFF ה-pill **לא** מרונדר וה-route לא-פעיל — כך שהשינוי במשטח-הכניסה לא דולף ל-UI-הקטלוג בפרודקשן.

**10. תכנון נוסף (שלי):** **שמירת-טקסט-בין-back-ל-front-door.** כשהמשתמש מקליד 'ברז', זורע, ואז לוחץ 'חזרה' (`_popStep`, `card_keyboard_screen.dart:216`) חזרה ל-stack-ריק → משטח-הכניסה נפתח **ריק**, הטקסט אבד. לתכנן שמירת השאילתה-האחרונה (או לפחות הצגתה כ-placeholder/שבב-'ברז' לחיץ) כך שחזרה אינה מחיקה. מתחבר ל"עיקרון פעם-אחרונה" (keyboard-live-mirror בזיכרון) ולשלב 78 (breadcrump-מסלול).

</div>

<div dir="rtl">

# MONSTER — פירוט שלבים 41–50 (P4 טקסט+קול · P5 AI-תאר)

> מעוגן בקוד האמיתי תחת `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל קובץ-קלון (`New folder/buildsmart`) התעלמתי ממנו כ-STALE.
> קבצי-הליבה שנקראו: `lib/features/card_keyboard/{card_engine,card_keyboard_screen,card_signals,card_keyboard_flag}.dart`, `lib/features/word_finder/{word_finder_engine,word_keyboard,dive_pool,material_lexicon,recipe_kit}.dart`, `lib/screens/{ai_finder_screen,describe_to_cart_screen,ai_assistant_screen,lipskey_product_sheet}.dart`, `lib/services/voice.dart`, `lib/data/repositories/claude_functions.dart`, `lib/logic/prompt_sanitize.dart`, `lib/data/fuzzy_search.dart`.

---

### שלב 41 — עידון-טקסט תוך-צלילה (חיתוך-בריכה, בלי מבוי-סתום)
**1. יעד:** אחרי השלב — בתוך מצב `MergedKeys` (כשהבריכה כבר נזרעה ע"י מילת-פתיחה) קיימת **תיבת-טקסט חיה** שמצמצמת את הבריכה תוך-צלילה ('ברז' ואז 'נחושת'→מצטמצם), בלי לעזוב את ה-stack. **קריטי:** 0-תוצאות **שומר את השבבים הקיימים** (לא מרוקן מסך). היום ב-`card_keyboard_screen.dart` קלט-הטקסט קיים רק כ-`_WordTap` בפתיחה (`CardAskWords`); אין refinement ידני אחרי הזרע.

**2. איך בונים:** (א) להוסיף ל-`_CardKeyboardScreenState` שדה `final TextEditingController _refine` + `String _refineText=''`. (ב) ב-`build`, כש-`v is MergedKeys`, לרנדר מעל ה-`WordKeyboard` `TextField` RTL (debounce דרך אותו דפוס שב-`ai_finder_screen._search` עם `|| _loading`, אבל כאן ללא קריאת-רשת — טהור). (ג) ב-`_ensureMemo`, **אחרי** ה-loop של `stack`, אם `_refineText.isNotEmpty` להוסיף סינון נוסף: `pool = pool.where((p) => productHasChip(p, tok) || p.nameHe.contains(tok))` עבור כל token מתוך `resolveQuery`-עתידי (שלב 35) או בינתיים `resolveWord(_refineText, cardKeyboardLexicon)`. (ד) **שמירת-שבבים על 0:** אם הסינון-המעודן מחזיר ריק, לא להחיל אותו — להחזיק את הבריכה הקודמת ולהציג באנר "0 — מצמצם פחות". (ה) `_refineText` חייב להזרים `_diveVersion++` כדי לשבור את ה-memo (`_memoVersion==_diveVersion` → return מוקדם).

**3. תקלות צפויות:** (1) **memo לא-נשבר:** `_ensureMemo` חוזר מוקדם כש-`_memoVersion==_diveVersion`; שינוי `_refineText` בלי `_diveVersion++` ייתן verdict מיושן. (2) **מבוי-סתום:** סינון נאיבי `where(...).toList()` שמחזיר `[]` → `mergedKeys` יפול ל-`distinctCardCount<=1`→`CardResolve(pool.first…)` על בריכה ריקה → `pool.first` **זורק** (`Bad state: No element`) או `CardShowProducts([])` שמרנדר `_buildEmptyState` ומאבד את כל ההקשר. (3) **debounce-race:** `onSubmitted` עוקף disable של כפתור — בדיוק ה-race ש-`ai_finder._search` סוגר עם `|| _loading`; כאן שתי הקלדות מהירות יכולות לדחוף `_diveVersion` פעמיים ולגרום `setState` כפול. (4) **golden flag-ON של שלב 11/66:** הוספת ענף refinement ל-`_ensureMemo` עם `_refineText==''` חייבת להיות **no-op מוחלט** אחרת שובר זהות-בייטים. (5) **זליגת-controller:** `_refine` ללא `dispose()` → handle-leak שה-`flutter_test` תופס.

**4. פתרון:** (1) לקרוא `_diveVersion++` בתוך `setState` של ה-debounce callback תמיד. (2) **שער מבוי-סתום:** לבנות `final narrowed = pool.where(refinePred).toList(); pool = narrowed.isEmpty ? pool : narrowed;` — בדיוק הדפוס ש-`resolveQuery` (שלב 35) מתאר "AND-חיתוך עם fallback (בלי מבוי-סתום)". (3) להעתיק את משמר ה-`|| _loading`/`_busy` הקיים (`_onWordTap` כבר משתמש ב-`_busy`+`addPostFrameCallback`). (4) לעטוף את כל ענף ה-refinement ב-`if (_refineText.isNotEmpty)` כך שמסלול-ברירת-המחדל נוגע באפס שורות. (5) `@override dispose(){ _refine.dispose(); super.dispose(); }`.

**5. בדיקות:** `test/features/card_keyboard/card_refine_in_dive_test.dart`: (א) `forceLiveForTest:true`, להזין מילת-פתיחה→`MergedKeys`, להקליד 'נחושת' בתיבה→`pumpAndSettle`→לאשר `state.verdict` בריכה קטנה יותר (`(verdict as MergedKeys/CardShowProducts)` עם פחות distinct). (ב) להקליד מחרוזת-זבל ('zzz')→לאשר ש-`state.verdict` עדיין `MergedKeys` עם **אותם שבבים** (לא `_buildEmptyState`). (ג) למחוק את הטקסט→הבריכה חוזרת. (ד) flag-OFF (`card_keyboard_screen_test.dart` הקיים) עדיין `findsNothing`.

**6. שיפור:** למזג את ה-refinement עם שלב 35 (`resolveQuery`) **מראש** — תיבת-הפתיחה ותיבת-התוך-צלילה הן אותו `_QuerySeedTap`/controller, רק עם בריכת-בסיס שונה (`kDivePool` מול הבריכה-המסוננת). מונע שני נתיבי-טוקניזציה שייסחפו.

**7. ריאלי?:** אטומי וניתן-לבדיקה כפי שמוגדר. תלוי 40 (תיבת-הפתיחה). אם שלב 35/36 (`resolveQuery`+debounce-controller) עוד לא נחתו, השלב גדל — מומלץ לפצל: 41a "תיבת-טקסט סטטית עם שער-מבוי-סתום", 41b "debounce". התוכנית מסמנת תלות 40 בלבד אך **הסמנטיקה דורשת 35/36**.

**8. וידוא-פיקס מלא:** `flutter analyze`→0-חדש; `card_keyboard_screen_test` flag-OFF=`SizedBox.shrink` זהה; להריץ את כל חבילת `test/features/card_keyboard/`; וידוא אין handle-leak (controller disposed); `_refineText==''` → diff-בייטים אפס מול golden flag-ON. taskkill dart לפני; retry-wrap לכשלי-טעינת-isolate (זה הקיר המוכר).

**9. תכנון נוסף (שלי):** **highlight-של-טוקן-תואם** — כשהמשתמש מקליד 'נחוש', להאיר את שבב-החומר 'נחושת' שכבר ב-`MergedKeys` במקום (או בנוסף ל) סינון, כך שהקלדה ולחיצה מתכנסים לאותו `value`. מונע מצב שבו הקלדה מוצאת מוצר שלחיצת-שבב לא הייתה מגיעה אליו (פער parity #29).

**10. תכנון נוסף (שלי):** **crumb ל-refinement** — להוסיף את הטקסט-המעודן כ-`NewbieStep` עם `axisLabel:'עידון'` (לא `SignalSource.axisName` כלשהו, כמו `_kOpeningWordAxis`) כשהמשתמש מאשר, כדי שכפתור-"חזרה" (`_popStep`) יוכל לבטל את העידון בלי לאבד את הזרע. אחרת הטקסט "תקוע" ב-`_refineText` מחוץ ל-stack ולא ניתן-לחזרה.

---

### שלב 42 — מפקד-הישגיות-טקסט (כל כרטיס דרך טקסט/קטגוריה/חומר)
**1. יעד:** אחרי השלב — קיים מבחן-מפקד **ממצה** שמוכיח שכל כרטיס-יקום ב-`kDivePool` נגיש מ**לפחות פה-אחד** (טקסט/קטגוריה/חומר). היום אין הוכחה כזאת — `card_engine_test`/`card_signals_test` בודקים ציר-בודד, לא כיסוי-יקום מלא. offenders (כרטיסים בלתי-נגישים) **נכשלים-בקול** מול allowlist.

**2. איך בונים:** (א) קובץ-מבחן `card_text_reach_census_test.dart` (לא קוד-ייצור). (ב) לבנות `universe = {for (p in kDivePool) _collapseKey(p)}` — אבל `_collapseKey` פרטי ל-`word_finder_engine.dart`; להשתמש ב-`distinctProducts(kDivePool, cap: 99999)` כמקור-נציגים-נבדלים (ציבורי) ולמפות ל-sku/key. (ג) לכל נציג, לבדוק שלפחות אחד מתקיים: `resolveWord(w, cardKeyboardLexicon)` מכיל את ה-sku עבור מילה מהשם; **או** `materialsInPool` נותן חומר התואם `materialOf(p)`; **או** הקטגוריה `p.categoryHe` קיימת. (ד) לצבור `offenders` ולהשוות מול `const kKnownUnreachable = <String>{}` (allowlist מצטמצם). (ה) `expect(offenders, kKnownUnreachable)`.

**3. תקלות צפויות:** (1) **`_collapseKey` פרטי** — לא ניתן לייבא; שימוש ב-sku גולמי יספור וריאנטים פעמיים ויתן מפקד מנופח/שגוי (זה בדיוק כשל-"100%-מנופח" שתועד בזיכרון-הקטלוג). (2) **כיסוי-חומר חלקי:** `materialOf` מזהה חומר רק למיעוט מהבריכה (ה-comment ב-`card_signals.dart` תיקן "~42%" כ-overstatement); רוב הכרטיסים **לא** נגישים-דרך-חומר → המפקד יסתמך על טקסט/קטגוריה, ואם מילה אחת חסרה ב-`wordToSkus` → offender. (3) **`wordOptions`/lexicon תלוי-סדר:** `WordSignal.chipsFor` כבר ממיין sku-canonical (swarm R2), אבל `cardKeyboardLexicon` נבנה מ-`kDivePool` בסדר-ההכנסה — מילה נדירה (`ניפל`,`רקורד`,`בושינג` שה-comment ב-`wordsByFrequency` מזכיר) עלולה ליפול מתחת ל-`take(12)` ב-`wordOptions` ולא לכסות. (4) **זמן-ריצה:** מפקד-יקום × 3-צירים הוא O(N²) על ~אלפי-מוצרים — עלול לחצות timeout ולקרוס isolate (הקיר המוכר). (5) ה-allowlist יתחיל גדול ויסתיר באגים אמיתיים.

**4. פתרון:** (1) **לחשוף helper-מפקד ב-`card_engine.dart`** או `card_signals.dart`: `Set<String> textReachKeys(pool)` שמשתמש פנימית ב-`distinctProducts` — או, מינימלית, להוסיף `@visibleForTesting String collapseKeyForTest(p)` ל-`word_finder_engine`. (2) להגדיר את ההישג כ-"נגיש מ-≥פה-אחד" (איחוד), לא "מכל-פה" — כך כיסוי-חומר-חלקי תקין כל עוד טקסט/קטגוריה תופסים. (3) להזין את ה-census בבריכה **canonical** (sku-sorted) כדי לשקף את `WordSignal`. (4) לפרק את הלולאה לאצוות + `taskkill dart` לפני; להריץ `flutter test --concurrency=1` עם retry-wrap (הדפוס המנצח מ-gate-flakiness). (5) ה-allowlist **חייב להיות שדה-עם-תיעוד** לכל sku (מדוע יתום) + tracking-issue, לא דלי-שקט.

**5. בדיקות:** `card_text_reach_census_test.dart`: `expect(offenders, equals(kKnownUnreachable))` עם הודעת-כשל שמדפיסה sku+nameHe של כל offender; טסט-משנה `every-distinct-product-has-≥1-word` (`resolveWord` reverse-index); טסט `material-coverage-fraction` שמאשר `MaterialSignal.seededFraction(kDivePool)` בטווח-צפוי (לא 100%, מאשר את תיקון-ה-overstatement).

**6. שיפור:** לבנות אינדקס-הפוך פעם-אחת — `Map<sku,Set<פה>>` שנבנה ב-O(N) ע"י סריקה אחת על `wordToSkus`+`materialsInPool`+קטגוריות, במקום לולאה-מקוננת לכל כרטיס. הופך O(N²)→O(N) ומסיר את סיכון-ה-timeout (תקלה 4).

**7. ריאלי?:** **גדול מדי כאטום** כפי שמוגדר — "מפקד ממצה" דורש קודם לחשוף את ה-collapse-key הפרטי, וזה edit-ייצור נפרד. לפצל: 42a "לחשוף collapse-key/text-reach helper ציבורי" (edit ייצור זעיר), 42b "מבחן-מפקד" (טסט בלבד). התלות המוצהרת 40,41 נכונה אבל חסרה תלות בחשיפת-ה-helper.

**8. וידוא-פיקס מלא:** analyze-0; המפקד ירוק עם allowlist ריק (או מתועד-מלא); להריץ פעמיים לוודא דטרמיניזם (אותו offender-set); flag-OFF לא-מושפע (טסט-בלבד, אין edit-ייצור פרט ל-helper שמוגן בעצמו ע"י byte-identity); אין דליפת-זיכרון (המפקד לא בונה providers).

**9. תכנון נוסף (שלי):** **מפקד-נגישות-עומק** (לא רק קיום-פה אלא ≤6-תורים) — להפריד ל-43, אבל כאן לפחות לאסוף את **מספר-התורים** המינימלי לכל כרטיס ולשמור snapshot (כמו ספייק-72 בגרף), כדי ש-43/67 יקבלו קלט-עיצוב אמיתי במקום ניחוש.

**10. תכנון נוסף (שלי):** **מפקד-דו-כיווני** — לא רק "כל כרטיס נגיש" אלא גם "כל מילה/חומר/קטגוריה שמוצגת **מובילה למשהו**" (אין שבב-מת שמסנן ל-0). זה תופס את הצד-ההפוך של מבוי-הסתום משלב 41, ומגן מפני שבב שמופיע ב-`MergedKeys` אך לחיצתו מרוקנת.

---

### שלב 43 — חוזה-≤6 E2E לפה-הטקסט + הקשחת-fuzz-alias
**1. יעד:** אחרי השלב — לדגימות מייצגות (מרפק-נחושת, PPR, מושב, HDPE) פה-הטקסט מגיע למוצר ב-**≤6 תורים** מקצה-לקצה (לא רק ציר-בודד), ו-1000+ קלטי-fuzz/alias עוברים **בלי throw**. זה החותם של P4: הופך את ה"≤6" מהבטחה לבדיקה-רצה.

**2. איך בונים:** (א) `card_text_le6_e2e_test.dart`. (ב) E2E טהור (בלי widget): להתחיל `stack=[]`, לקרוא `mergedKeys(pool, stack, cardKeyboardLexicon, null)`, לדמות מסלול: מילת-פתיחה→`resolveWord`→`NewbieStep`, ואז ללולאה לבחור שבב מ-`MergedKeys.chips` עד `CardResolve`/`CardShowProducts` כשה-sku-היעד **בתוך** התוצאה, לספור תורים. (ג) `expect(turns, lessThanOrEqualTo(kMaxDiveTurns))` — **אבל `kMaxDiveTurns` נוצר רק בשלב 67**; כאן להשתמש ב-`6` ליטרלי ולהשאיר TODO לייבוא. (ד) **fuzz:** לולאה על 1000+ מחרוזות (alias דרך `promptSafeText`-עתידי/`synonym_bridge` שלב 34: copper/brass/פליז) + קלטי-זבל (אמוji, מחרוזות-ארוכות, ריקות) → `resolveWord`/`mergedKeys` לא זורקים. (ה) לאשר parity: copper==נחושת==פליז מובילים לאותה בריכה (תלוי 34/35).

**3. תקלות צפויות:** (1) **`pool.first` על ריק:** `mergedKeys` שורה 161 `if (pool.isNotEmpty && distinctCardCount(pool)<=1) return CardResolve(pool.first…)` — מסלול-fuzz שמצמצם ל-0 ואז `distinctCardCount==0` **לא** נכנס (שומר `isNotEmpty`), נופל ל-`<=kShowProductsThreshold`→`CardShowProducts(distinctProducts([]))`=ריק — לא-throw אבל מסלול-מבוי-סתום שלא סופר ≤6. (2) **multi-size loop:** השם נושא `½"×¾"` → לחיצת-גודל לא מצמצמת, `_mergedChips` שורה 260 `if(!anySplit) continue` מדלג, אבל אם **כל** הצירים לא-מצמצמים → `chips.isEmpty`→`CardShowProducts` כבר בתור-1 (טוב ל-≤6, אבל אומר שהמסלול לא באמת "טקסט"). (3) **≤6 לא-מובטח בלי שער:** בלי `kMaxDiveTurns`+`ShowProducts עד-תור-5` (שלב 67) המסלול יכול לדרוש 7+ תורים על בריכה-עמוקה — הטסט **ייכשל אמיתית**, וזה תלות-מבנית על 67 שהתוכנית לא מסמנת (מסמנת 40,41,42). (4) **alias parity מזויף:** בלי `synonym_bridge` (שלב 34) 'copper'≠'נחושת' ב-lexicon → ה-parity-assert ייכשל. (5) **fuzz קורס isolate** על 1000 איטרציות (הקיר).

**4. פתרון:** (1)/(3) **לייבא `kMaxDiveTurns` מ-67** — כלומר השלב **תלוי 67**, או להגדיר חוזה-זמני `6` ולתעד שהשער-האמיתי ב-67 הוא המקור-היחיד (התוכנית עצמה אומרת "33/42/43/60/69 מייבאים את `kMaxDiveTurns`"). (2) הטסט חייב לאשר ש-`CardShowProducts` המוקדם **מכיל את ה-sku-היעד** (לא רק "הגיע למצב-תצוגה") — אחרת ≤6 חסר-משמעות. (4) להריץ את ה-fuzz **אחרי** 34/35 או לדלג על ה-parity-assert עם `skip:` מתועד. (5) `--concurrency=1`+retry-wrap+taskkill; לזרוע RNG עם seed-קבוע לדטרמיניזם.

**5. בדיקות:** `card_text_le6_e2e_test.dart`: `group('≤6 per sample')` עם 4 דגימות-קשות, כל אחת `expect(turns<=6 && targetSkuInResult, isTrue)`; `group('fuzz no-throw')` עם `for (i in 0..1500)` קלט-אקראי-seeded→`expect(()=>resolveQuery/mergedKeys, returnsNormally)`; `test('alias parity')` copper/brass/פליז→אותו `Set<sku>` (skip-אם-אין-34).

**6. שיפור:** במקום 4 דגימות-קבועות, לגזור את הדגימות **אוטומטית** מ-census-42 (כל offender-לשעבר + כל קטגוריה) — כך הכיסוי גדל עם הקטלוג ולא מתיישן. למזג 42+43 לחבילת-"contract" אחת עם שכבת-census משותפת.

**7. ריאלי?:** **תלוי-מבנית ב-67** (השער-הקשיח) — כפי שמוגדר עם תלות 40,41,42 בלבד הוא **לא** באמת מוכיח ≤6, כי שום-דבר עוד לא כופה את ה"רשימה-עד-תור-5". ריאלי כ"בדיקת-עשן ≤6 רכה" עכשיו, אבל החוזה-הקשיח חייב להמתין ל-67. לפצל: 43a "fuzz no-throw + parity" (עצמאי), 43b "חוזה-≤6 קשיח" (תלוי 67).

**8. וידוא-פיקס מלא:** analyze-0; כל 4 הדגימות+1500 fuzz ירוקים פעמיים-רצוף (דטרמיניזם); flag-OFF re-green (`card_keyboard_screen_test`); כל חבילת `test/` ירוקה; `git diff --stat` על `lib/` = 0 (טסט-בלבד). taskkill+retry-wrap.

**9. תכנון נוסף (שלי):** **מדידת-תורים-בפועל מול ספירת-לחיצות** — ≤6 "תורים" אינו ≤6 "לחיצות": מילת-פתיחה היא 1, כל שבב 1, בחירת-גריד ב-`CardShowProducts` היא ה-≤6. הטסט חייב לספור את **בחירת-הגריד הסופית** כתור, אחרת מדווח ≤5 שגוי. להוסיף assert מפורש על נקודת-הספירה.

**10. תכנון נוסף (שלי):** **דגימת-worst-case במקום best-case** — בכל תור לבחור את השבב ש**הכי פחות** מצמצם (אדוורסרי), לא הראשון, כדי להוכיח ≤6 בענף-הגרוע. בחירה-ראשונה (`chips.first`) מודדת מסלול-אופטימי; אדוורסרי מוכיח את החוזה האמיתי.

---

### שלב 44 — מצאי משטחי-AI + החלטת-בליעה
**1. יעד:** אחרי השלב — קיים מצאי-מתועד של **3 משטחי-ה-AI** הקיימים עם **disposition מפורש** לכל-אחד (נבלע-לפה / נשאר-כלי-נפרד / נמחק). היום שלושת המסכים — `ai_finder_screen.dart` (תאר→מצא, closed-set קטגוריה), `describe_to_cart_screen.dart` (תאר-עבודה→סל, closed-set recipe-key), `ai_assistant_screen.dart` (עוזר-שיחה פתוח) — חיים עצמאית, ואין החלטה איזה הופך ל"פה-AI" של המנוע.

**2. איך בונים:** (א) מבחן-מצאי `ai_surface_inventory_test.dart` שמייבא את שלושת המסכים ומאשר את ה-API-הציבורי שכל disposition מסתמך עליו: `finderCategories()`, `matchCategory()`, `productsInCategory()` (finder); `describeToCartPrompt()`, `matchRecipe()`, `resolvedKitProducts()` (cart); `claudeGatewayProvider` (משותף). (ב) להחליט: **finder→פה-AI הקנוני** (closed-set קטגוריה→`productsInCategory`→בריכה, מתאים בול ל-`AiSeed`), **cart→נבלע מאוחר** (P10 "השלם-קו"→`assembleKit`), **assistant→נשאר כלי-נפרד** (שיחה פתוחה, לא מאתר-מוצר). (ג) לתעד ב-docstring של `card_engine.dart`/תוכנית. (ד) המבחן מקבע את ה-disposition כ-`const Map<surface,disposition>` ומאשר שהסמלים קיימים.

**3. תקלות צפויות:** (1) **כפילות-לוגיקה:** `ai_assistant_screen.dart` כבר **מייבא** מ-`ai_finder_screen` (`productsInCategory`) ומ-`describe_to_cart_screen` (`matchRecipe,resolvedKitProducts`) — בליעה תמימה של finder תשבור את ה-assistant. (2) **disposition-AI הוא שאלה-פתוחה** שהתוכנית מסמנת מפורשות ("44=disposition-AI") — החלטה שגויה כאן מדף-דומינו ל-45/49/50/100. (3) **`fuzzySearchProducts` literal-first** ב-`ai_finder._search` שורה 130 רץ **לפני** ה-gateway — כלומר ה-finder כבר חצי-טקסט-חצי-AI; בליעתו-כ"פה-AI-טהור" מתעלמת מהמסלול-הליטרלי שכבר נבלע בפה-הטקסט (P4). (4) **טסט-מצאי שביר:** אם הוא מאשר חתימות-מדויקות, כל refactor עתידי שובר אותו.

**4. פתרון:** (1) לבלוע **רק את ה-seed-logic** (`matchCategory`→`productsInCategory`) ל-`aiSeedToPool` (שלב 45) ולהשאיר את שלושת המסכים שלמים עד הקאט-אובר-100 — ה-assistant ממשיך לייבא מהם. (2) לקבע את ה-disposition **בכתב** עם נימוק-לכל-משטח (כפי שאני עושה ב-2ב) ולסמן כ-OWNER-REVIEW (זו שאלה-פתוחה). (3) להבהיר ש-finder-literal == פה-טקסט (P4) ו-finder-semantic == פה-AI (P5) — שני חצאים, שני פיות. (4) המבחן יאשר **קיום**-סמל (`isA<Function>()`/לא-null), לא חתימה-מדויקת.

**5. בדיקות:** `ai_surface_inventory_test.dart`: `expect(finderCategories(), isNotEmpty)`; `expect(matchCategory('NONE'), isNull)`; `expect(matchRecipe('NONE'), isNull)`; `expect(claudeGatewayProvider, isNotNull)` (provider קיים); `test('disposition map covers 3 surfaces')` מאשר 3 כניסות. אין צורך ב-gateway-אמיתי (כולם closed-set-validators טהורים).

**6. שיפור:** במקום מבחן-מצאי סטטי, לכתוב **disposition-doc** קצר ב-`card_engine.dart` כ-comment-block + מבחן שמאשר שה-3 קבצים עדיין קומפילבילים ומייצאים את ה-validators — קל-תחזוקה יותר מ-assertion על חתימות.

**7. ריאלי?:** אטומי וקל (טסט-מצאי + החלטה-מתועדת, אפס edit-ייצור). זה השלב הכי-קטן בבאטץ'. תלות מוצהרת "—" נכונה. הסיכון היחיד הוא **איכות-ההחלטה**, לא היקף.

**8. וידוא-פיקס מלא:** analyze-0; המבחן ירוק; שלושת המסכים עדיין קומפילבילים (`flutter analyze` על כולם); אין edit-ייצור→זהות-בייטים טריוויאלית; ה-disposition מתועד ונסקר.

**9. תכנון נוסף (שלי):** **לכלול את `voice.dart`+`voice_dictate_button.dart` במצאי** — התוכנית ממקמת קול ב-P4 (שלב 38) אבל פה-ה-AI (תאר-לי) הוא היעד-הטבעי-ביותר לקלט-קולי-חופשי. להחליט כאן אם פה-ה-AI חולק את `VoiceService` עם פה-הטקסט או מחזיק משלו, כדי למנוע שני-נתיבי-מיקרופון.

**10. תכנון נוסף (שלי):** **מצאי-עלות+offline** — לתעד לכל משטח את ה-`maxTokens` (finder=48, cart=32) ואת התנהגות-ה-offline (`gw==null`→"דורש חיבור"). פה-ה-AI-המאוחד חייב לרשת מדיניות-עלות אחת; בלי המצאי הזה כל פה ימציא תקציב-טוקנים משלו.

---

### שלב 45 — `aiSeedToPool` טהור: `AiSeed` מעל היקום
**1. יעד:** אחרי השלב — קיימת הפשטה **טהורה** `AiSeed` + `aiSeedToPool` שממירה תשובת-AI מקורקעת לתת-קבוצה של `kDivePool`, **לעולם לא ממציאה** ('שחור'→הצינורות-השחורים האמיתיים, **לא** 'נחושת'). זו השדרה שמחברת פה-AI ל-`mergedKeys`. היום הלוגיקה כלואה ב-`ai_finder_screen._search` (UI+state+gateway מעורבבים).

**2. איך בונים:** (א) קובץ טהור `lib/features/card_keyboard/ai_seed.dart` (mirror של `card_signals.dart` — אפס Flutter/Riverpod/IO). (ב) `@immutable class AiSeed { final String? category; final List<String> literalTokens; }`. (ג) `List<LipskeyCatalogProduct> aiSeedToPool(AiSeed seed)`: אם `category!=null`→`kDivePool.where((p)=>p.categoryHe==seed.category)` (לא `kCatalogProducts` כמו `productsInCategory`! היקום הקנוני הוא `kDivePool` הכולל מים-חמים — שלב 1). (ד) `AiSeed seedFromLiteral(String reply, …)`: לעטוף את `matchCategory(reply)` הקיים (ייבוא מ-`ai_finder_screen`) + `fuzzySearchProducts` לטוקנים-ליטרליים. (ה) **טוהר:** הכל transform של const-data, בריכה כפרמטר.

**3. תקלות צפויות:** (1) **`kCatalogProducts` ≠ `kDivePool`:** `productsInCategory` ב-`ai_finder` משתמש ב-`kCatalogProducts` ש**משמיט מים-חמים** (`dive_pool.dart` docstring: "kCatalogProducts OMITS hot-water"). שכפול תמים יחמיץ קטגוריות-מים-חמים → 'שחור'/'דוד' לא ימצאו את HW-skus. (2) **`matchCategory` תלוי `finderCategories()`** שנגזר מ-`kCatalogProducts` — אותו פער. (3) **המצאה-בדלת-האחורית:** אם `seedFromLiteral` נופל ל-`String.contains` רופף על שמות, 'נחושת' עלול לתפוס מוצר עם 'נחושת' בתיאור שאינו-נחושת (בדיוק האזהרה ב-`ColorSignal`/`MaterialSignal`). (4) **ייבוא-מ-UI:** ייבוא `matchCategory` מ-`ai_finder_screen.dart` מושך `package:flutter/material.dart` לתוך מודול-שאמור-להיות-טהור → שובר את חוזה-הטוהר ש-`card_engine`/`card_signals` שומרים.

**4. פתרון:** (1)/(2) **לחשב קטגוריות מ-`kDivePool`** בתוך `ai_seed.dart`: `aiSeedCategories()` = `{for(p in kDivePool) p.categoryHe}` — לא לייבא את `finderCategories`. (3) `seedFromLiteral` ישתמש ב-`fuzzySearchProducts` (כבר-מקורקע, מחזיר מוצרים-אמיתיים) ולא ב-`contains` גולמי; 'שחור' עובר דרך אותו literal-path שה-finder מוכיח. (4) **להעתיק את `matchCategory` (16 שורות טהורות) ל-`ai_seed.dart`** במקום לייבא מ-UI — או להעלות אותה למודול-טהור משותף `lib/logic/ai_category_match.dart` ש-גם-finder-גם-seed מייבאים. כך הטוהר נשמר ואין כפילות.

**5. בדיקות:** `ai_seed_test.dart`: `expect(aiSeedToPool(AiSeed(category:'…')), everyElement(predicate p.categoryHe==…))`; `test("'שחור' literal→real black pipes, not copper")` (השחור אמיתי+לא-נחושת — בדיוק ניסוח-התוכנית); `test('NONE→empty seed')`; `test('hot-water category reachable')` (מאשר תיקון תקלה-1 — HW-sku נמצא); `test('purity: no Flutter import')` (גרֶפ-מבחן/קומפילציה תחת `dart test` אם אפשר).

**6. שיפור:** למזג `AiSeed` עם `CardSeed`/`PoolSeed` (שלבים 51/62) **מראש** — כל הפיות (טקסט/חומר/AI) חולקים `seedFromX→List<product>` אחד, ו-`aiSeedToPool` הוא רק `seedFromCategory`+`seedFromSkus`. מונע מודל-זרע שלישי נפרד שייסחף.

**7. ריאלי?:** אטומי וטהור-לחלוטין (קל-לבדיקה). תלות מוצהרת 44 נכונה. הסיכון היחיד הוא פער-`kCatalogProducts`/`kDivePool` — שאם מטופל ב-2ג/4א, השלב נקי. ריאלי כפי שמוגדר.

**8. וידוא-פיקס מלא:** analyze-0; `ai_seed_test` ירוק; **וידוא-טוהר:** המודול לא מייבא Flutter (בדיקת-imports); flag-OFF זהה (מודול-חדש לא-מחווט, אפס שינוי-ייצור קיים); `productsInCategory` הישן לא-נגוע (ה-finder ממשיך לעבוד); כל חבילת-AI ירוקה (`ai_finder_test`,`describe_to_cart_test`).

**9. תכנון נוסף (שלי):** **`seedFromLiteral` חייב להחזיר גם נתיב-טוקנים-מרובים** — בקשה "ברז נחושת חם" היא 3 אותות (מילה+חומר+טמפ'); להחזיר `AiSeed` עם רשימת-טוקנים ולא קטגוריה-יחידה, כך ש-`aiSeedToPool` עושה AND-חיתוך (כמו `resolveQuery` שלב 35). קטגוריה-יחידה היא בדיוק המגבלה ש-`ai_finder` literal-first נועד לעקוף.

**10. תכנון נוסף (שלי):** **שער-מבוי-סתום ב-`aiSeedToPool`** — אם החיתוך מחזיר `[]`, להחזיר את הבריכה-הרחבה-יותר (קטגוריה בלבד, או `kDivePool`) במקום ריק, כדי ש-`initialSeed` (שלב 46) לא יזרע בריכה-ריקה שתפיל את `mergedKeys` ל-`pool.first` throw. עקבי עם משמר-המבוי-סתום של 41.

---

### שלב 46 — זריעת-השדרה: `initialSeed` ב-CardKeyboardScreen
**1. יעד:** אחרי השלב — `CardKeyboardScreen` מקבל `initialSeed` אופציונלי שדוחף **צעד-פתיחה אחד** לתוך ה-`stack` בעת mount, כך שהמסך נפתח כבר-מצומצם (תת-קבוצה→crumbs==[label]). `null`==זהה-בייטים (פתיחה רגילה). זה ה-slot שדרכו פה-ה-AI (וכל פה) מזריק זרע.

**2. איך בונים:** (א) להוסיף `final List<LipskeyCatalogProduct>? initialSeed;` + `final String? initialSeedLabel;` ל-`CardKeyboardScreen` (ליד `subtype`,`forceLiveForTest`). (ב) ב-`initState`, אם `initialSeed!=null`, לדחוף `NewbieStep` עם `axisLabel:_kOpeningWordAxis` (לא ציר-אמיתי — בדיוק כמו מילת-פתיחה, כדי לא לשרוף ציר), `predicate:(p)=>seedSkus.contains(p.sku)`, `crumbWord:initialSeedLabel`. (ג) `_diveVersion++` כבר קורה דרך ה-push, אבל ב-`initState` אין `setState` — לדחוף ישירות ל-`stack` ולאתחל `_diveVersion`. (ד) `verdict` הראשון יהיה `MergedKeys`/`CardShowProducts` במקום `CardAskWords`.

**3. תקלות צפויות:** (1) **`ref.read` ב-`initState`:** `_live` הוא `late final = ref.read(...)` שכבר רץ ב-mount; דחיפת-זרע ב-`initState` **לפני** ש-`_live` מאותחל עלולה לקרוס (`LateInitializationError`) או לזרוע גם כש-flag-OFF. (2) **זהות-בייטים:** התניית-הזרע על flag — אם `initialSeed!=null` אבל `!_live`, האם לזרוע? חייב **לא** (flag-OFF=פתיחה-עירומה=`SizedBox.shrink`), אחרת זריעה דולפת. (3) **`pool.first` throw:** אם `initialSeed` ריק (`[]`), `_ensureMemo` יבנה `pool=[]`→`mergedKeys`→`distinctCardCount==0`→נופל ל-`CardShowProducts([])`→`_buildEmptyState`. פתיחה-על-מסך-ריק. (4) **`didUpdateWidget`:** הורה שמרנדר-מחדש עם `initialSeed` שונה — `didUpdateWidget` היום בודק רק `subtype`; שינוי-זרע לא-יבטל memo→verdict מיושן. (5) **memo-version:** ה-stack מאותחל ב-`initState` אבל `_memoVersion=-1` ו-`_diveVersion=0` — ה-`_ensureMemo` הראשון ירוץ נכון רק אם `_diveVersion` שונה מ-`_memoVersion`; לוודא `_diveVersion` מתחיל ב-1 כשיש-זרע או ש-`-1!=0`.

**4. פתרון:** (1) לקרוא `_live` **לפני** הזריעה ב-`initState` (סדר-שדות: `_live` מוגדר כ-field-initializer שרץ-ראשון; הזריעה ב-`initState` רצה אחרי field-init — בטוח). או להעביר את `_live` ל-`bool _live;` + אתחול מפורש בראש `initState`. (2) **`if ((_live||forceLiveForTest) && initialSeed!=null && initialSeed.isNotEmpty)`** לפני הדחיפה — זרע רק כש-ON. (3) שער `isNotEmpty` (כבר ב-2). (4) להרחיב `didUpdateWidget`: `if (widget.initialSeed != oldWidget.initialSeed) _reseed()`. (5) `-1 != 0` כבר נכון (memo יחושב); ה-push ב-`initState` לא-קורא setState אז להשתמש ב-`stack.add` ישיר + `_diveVersion=1`.

**5. בדיקות:** `card_initial_seed_test.dart`: (א) `CardKeyboardScreen(forceLiveForTest:true, initialSeed:[p1,p2], initialSeedLabel:'נחושת')`→`pump`→`expect(state.crumbs, ['נחושת'])` + `verdict` לא-`CardAskWords`. (ב) `initialSeed:null`→`verdict is CardAskWords` (זהה-לפתיחה). (ג) flag-OFF (`forceLiveForTest:false`,`initialSeed:[...]`)→`SizedBox.shrink`, **אין זריעה** (`find.byType(WordKeyboard) findsNothing`). (ד) `initialSeed:[]`→לא-throw, לא-crash.

**6. שיפור:** במקום `List<product>?` להעביר `AiSeed?`/`CardSeed?` (שלב 45/51) ישירות, ולתת ל-`initState` לקרוא `aiSeedToPool` — כך ה-slot טיפוסי וה-label נגזר מהזרע, לא משוכפל כפרמטר נפרד (`initialSeedLabel`).

**7. ריאלי?:** אטומי וניתן-לבדיקה. תלות מוצהרת 45 נכונה. הסיכון העיקרי הוא ה-flag-race ב-`initState` (תקלה 1/2) — שאם מטופל, נקי. ריאלי כפי שמוגדר.

**8. וידוא-פיקס מלא:** analyze-0; `card_initial_seed_test` ירוק; **flag-OFF byte-identity קריטי כאן** — `card_keyboard_screen_test` flag-OFF עדיין `SizedBox.shrink` **גם עם `initialSeed` מסופק** (לוודא שהזריעה מותנית-flag); אין דליפת-state; `didUpdateWidget` reseed עובד (טסט-rebuild).

**9. תכנון נוסף (שלי):** **תרחיש-`initialSeed`-בלבד-של-מוצר-יחיד** — אם הזרע מצמצם מיד ל-1 כרטיס, `verdict` יהיה `CardResolve` כבר ב-mount, ו-`_pushStep` היה פותח sheet — אבל ב-`initState` אין `_pushStep`. צריך החלטה: האם פתיחת-מסך-עם-זרע-חד-ערכי פותחת sheet מיד? להוסיף `openSheetOnResolve` בדיקה ב-`initState` או post-frame.

**10. תכנון נוסף (שלי):** **שמירת-זרע ל-warm-start** — `initialSeed` הוא הוק טבעי לשלב 22 (warm-start מ-last-touched). לתעד שה-slot הזה משרת **גם** AI-seed **וגם** last-touched-seed, ולוודא ששניהם משתמשים באותו `_kOpeningWordAxis` (ציר-לא-נשרף) כדי שהמיזוג יציע ציר-מילה גם אחרי warm-start.

---

### שלב 47 — `resolveAiSeed` מונע-gateway (literal-first, offline-כן)
**1. יעד:** אחרי השלב — קיימת `resolveAiSeed` שמחזירה `AiSeed` **בלי קריאת-gateway** כשאפשר (literal-first, offline-כן); `null`→none; **`ClaudeException` נזרק-מחדש (לעולם לא-בודה)**. זה ה-orchestrator שמחליט: ליטרלי-מקומי קודם, ורק לבקשה-סמנטית פונה ל-Claude — ואם Claude נכשל, כשל-כן ולא מוצר-מזויף.

**2. איך בונים:** (א) `Future<AiSeed?> resolveAiSeed(String userText, ClaudeGateway? gw, {…})` ב-`ai_seed.dart` (כאן זה כבר-לא-טהור — מחזיר Future, מקבל gateway — אז אולי `ai_seed_resolver.dart` נפרד). (ב) **literal-first** (mirror `ai_finder._search` שורות 130-140): `final literal = fuzzySearchProducts(userText); if (literal.isNotEmpty) return AiSeed(literalSkus: [for p in literal] p.sku);` — אפס קריאת-רשת, offline-מלא. (ג) `if (gw==null) return null;` (offline→none כן, לא-throw). (ד) `final r = await gw.ask(prompt: aiFinderPrompt(userText), system:_kSystem, maxTokens:48); final cat = matchCategory(r.text); return cat==null ? null : AiSeed(category:cat);`. (ה) **לא לעטוף ב-try/catch שבולע** — לתת ל-`ClaudeException` לעלות (re-throw מרומז), כך הקורא מבדיל בין "אין-תוצאה" ל"נכשל".

**3. תקלות צפויות:** (1) **`ai_finder._search` בולע את החריגה** — שורה 174 `catch(_){ setState(_failed=true) }` תופס **הכל** ומציג "משהו השתבש"; שכפול-תמים ל-`resolveAiSeed` יבלע `ClaudeException` ויחזיר null→"אין-תוצאה" שקרי במקום "נכשל". התוכנית מפורשת: "ClaudeException נזרק-מחדש (לעולם לא-בודה)". (2) **`gw.ask` כבר ממפה הכל ל-`ClaudeException`** (`claude_functions.dart` שורות 110-114: `on Object catch(e)→ClaudeException('unavailable',…)`) — אז `resolveAiSeed` לא צריך מיפוי משלו, רק לא-לבלוע. (3) **timeout 30s** ב-`gw.ask` — בקשה-תקועה תחזיק UI; ה-orchestrator חייב להיות async-נכון (הקורא מציג ספינר). (4) **literal-first מכפיל את פה-הטקסט (P4):** אם פה-הטקסט כבר עושה `fuzzySearchProducts`, אז `resolveAiSeed` literal-first הוא כפילות — שני פיות עושים אותו ליטרלי. (5) **`aiFinderPrompt` תלוי `finderCategories()`=`kCatalogProducts`** (פער מים-חמים משלב 45).

**4. פתרון:** (1)/(2) **לא לכתוב `catch` ב-`resolveAiSeed`** — לתת ל-`ClaudeException` (שכבר ממופה ב-gateway) לעלות; **הקורא** (פאנל-48) תופס ומציג "נכשל". כך "literal/offline→null" מובחן מ"gateway-error→throw". (3) להסתמך על ה-timeout המובנה (30s) ולא להוסiff עוד; ה-orchestrator מחזיר Future והקורא מנהל ספינר (כמו `_loading` ב-finder). (4) **להבהיר:** literal-first ב-`resolveAiSeed` הוא **fallback** למקרה שהפה-AI נקרא ישירות; כשמחווט דרך המנוע, פה-הטקסט תופס ליטרלי קודם ופה-ה-AI מקבל רק את הסמנטי. או — להסיר literal מ-`resolveAiSeed` ולהשאיר אותו פה-AI-טהור-סמנטי (החלטה-44). (5) להשתמש ב-prompt שנגזר מ-`aiSeedCategories()`(=`kDivePool`) משלב 45, לא `finderCategories`.

**5. בדיקות:** `ai_seed_resolver_test.dart` עם **fake-gateway** (hand-rolled, כמו `claude_gateway_test.dart` — `setUp` + fake `ClaudeGateway`): (א) `resolveAiSeed('ברז נחושת', null)`→literal `AiSeed` (offline, fake לא-נקרא). (ב) `resolveAiSeed('משהו לחבר צינורות', null)`→`null` (gw==null, no literal). (ג) fake-gw שמחזיר קטגוריה→`AiSeed(category:…)`. (ד) **fake-gw שזורק `ClaudeException('unavailable')`→`expect(()=>resolveAiSeed(...), throwsA(isA<ClaudeException>()))`** (לא-בודה!). (ה) fake-gw שמחזיר 'NONE'→`null`.

**6. שיפור:** להזריק את ה-`fuzzySearchProducts` ואת ה-prompt-builder כפרמטרים (DI) כדי שהמבחן לא-תלוי בקטלוג-האמיתי ויכול לבדוק את ה-orchestration-בלבד דטרמיניסטית. גם מאפשר לפה-הטקסט ולפה-ה-AI לחלוק literal-resolver אחד.

**7. ריאלי?:** אטומי וניתן-לבדיקה היטב (fake-gateway קל, הדפוס קיים ב-`claude_gateway_test`). תלות מוצהרת 45 נכונה. ה-re-throw הוא הליבה ועדין — אבל מבחן-`throwsA` מכסה. ריאלי כפי שמוגדר.

**8. וידוא-פיקס מלא:** analyze-0; `ai_seed_resolver_test` ירוק כולל ענף-ה-throw; `claude_gateway_test` הקיים עדיין ירוק (לא-נגענו ב-gateway); flag-OFF זהה (מודול-חדש לא-מחווט); וידוא ש-`gw==null`→null **ולא** throw (offline-כן); אין דליפת-Future (כל `await` מסתיים).

**9. תכנון נוסף (שלי):** **הבחנה בין קודי-`ClaudeException`** — `unauthenticated`/`failed-precondition`(App-Check)/`unavailable`(לא-פרוס) דורשים הודעות-משתמש שונות. ה-orchestrator (או הפאנל-48) צריך למפות קוד→הודעה, לא "משהו השתבש" גנרי לכולם (כמו ש-finder עושה היום). להוסיף `switch(e.code)`.

**10. תכנון נוסף (שלי):** **cache/dedup לבקשות-זהות** — בקשה סמנטית זהה תוך-זמן-קצר לא צריכה קריאת-gateway חוזרת (עלות+latency). להוסיף memo-טהור `Map<userText,AiSeed>` ברמת-ה-orchestrator (או להשאיר ל-90). מונע גם את ה-race ש-`|| _loading` סוגר ב-finder.

---

### שלב 48 — ווידג'ט פה-AI (פאנל מאחורי-דגל, offline-כן)
**1. יעד:** אחרי השלב — קיים ווידג'ט פה-AI ('מצא לי') **מאחורי `kCardKeyboard`**: literal-offline עובד תמיד; `requires-connection` מוצג רק למסלול-הסמנטי כשאין-gateway. הפה משתלב במשטח-הכניסה כ-slot-שווה. היום ה-UI היחיד הוא `ai_finder_screen.dart` (מסך-מלא נפרד, לא פה-במקלדת).

**2. איך בונים:** (א) `lib/features/card_keyboard/card_ai_mouth.dart` — `ConsumerStatefulWidget` רזה (לא `Scaffold`/`AppBar` כמו ה-finder — רק `Column`+`TextField`+כפתור, כמו ה-strip של `card_keyboard_screen`). (ב) `final void Function(AiSeed) onSeed;` callback (לא פותח sheet בעצמו — מזריק זרע למסך). (ג) ב-`_find`: `final gw = ref.read(claudeGatewayProvider); final seed = await resolveAiSeed(text, gw);` (שלב 47) → `if(seed!=null) onSeed(seed);` → `catch(ClaudeException){ setState(_failed) }`. (ד) **offline-כן:** literal-path עובד גם כש-`gw==null` (resolveAiSeed מחזיר literal-seed); רק בקשה-סמנטית-בלי-gw מציגה "💡 דורש חיבור" (כמו finder שורה 214). (ה) self-gate על `kCardKeyboard` (read-once, כמו `_live` במסך).

**3. תקלות צפויות:** (1) **`ai_finder` בולע חריגות** (שורה 174 `catch(_)`) — אם הפאנל מעתיק זאת, ה-re-throw של 47 נבלע והכל הופך "אין-תוצאה". (2) **offline-לא-מובחן:** ה-finder מציג "דורש חיבור" כש-`aiAvailable==false` **לכל** הקלט (שורה 213), אבל הפה-החדש חייב להריץ literal גם offline — אחרת מסך-AI-offline=מת לגמרי. התוכנית: "literal-offline עובד; requires-connection רק לסמנטי". (3) **flag-race:** קריאת `kCardKeyboard` per-keystroke במקום once → late-load מחליף מנוע (הקיר ש-`card_keyboard_flag.dart` מתעד). (4) **controller-leak:** `TextField` controller ללא dispose. (5) **`onSubmitted` race:** כמו ב-finder, `onSubmitted` עוקף disable→ask כפול; `resolveAiSeed` חייב `||_loading` guard.

**4. פתרון:** (1) `catch (ClaudeException catch e)` **ספציפי**→`_failed`+הודעה-לפי-`e.code`; לא `catch(_)` כללי (זה מבדיל offline-null מ-error). (2) להפריד מצבים: `if (text-is-literal-hit)` → תמיד-עובד; `else if (gw==null)` → "דורש חיבור לבקשה חופשית"; `else` → ask. הליטרלי-תמיד-לפני-בדיקת-gw. (3) `late final bool _live = ref.read(featureFlagsProvider).contains(kCardKeyboardFlag);` once (mirror המסך). (4) `dispose(){_controller.dispose();super.dispose();}`. (5) `if (text.isEmpty || _loading) return;` (העתק מדויק מ-finder שמתועד שם כתיקון-race).

**5. בדיקות:** `card_ai_mouth_test.dart` (השם שהתוכנית נוקבת): (א) flag-OFF→`SizedBox.shrink`/לא-מרנדר. (ב) flag-ON + fake-gw→הקלדת-טקסט-סמנטי→tap→`onSeed` נקרא עם `AiSeed(category)`. (ג) **offline (gw==null) + טקסט-ליטרלי ('ברז')→`onSeed` עם literal-seed עדיין נקרא** (offline-כן). (ד) offline + טקסט-סמנטי→"דורש חיבור" מוצג, `onSeed` **לא** נקרא. (ה) fake-gw זורק→"נכשל" (`_failed`), `onSeed` לא-נקרא. השתמש ב-`ProviderScope(overrides:[claudeGatewayProvider.overrideWithValue(fakeGw)])`.

**6. שיפור:** לחלוק את ה-`TextField`+debounce-controller עם פה-הטקסט (שלב 37/41) — פה-AI ופה-טקסט הם **אותה תיבה** עם נתב-תוצאה שונה (literal→זרע מיד; סמנטי→gateway). מבטל שני-controllers ושני-נתיבי-race. מתכתב עם החזון "6 פיות שוות→בריכה אחת".

**7. ריאלי?:** אטומי וניתן-לבדיקה (fake-gw + overrides, דפוס מוכר). תלות מוצהרת 46,47 נכונה. הסיכון: **הבחנת-offline** (literal-עובד-תמיד) דורשת קפידה אבל מכוסה במבחן (ג)/(ד). ריאלי כפי שמוגדר.

**8. וידוא-פיקס מלא:** analyze-0; `card_ai_mouth_test` ירוק (כל 5 הענפים); flag-OFF→`SizedBox.shrink` (byte-identity); `ai_finder_screen` הישן לא-נגוע (עדיין עובד, `ai_finder_test` ירוק); אין controller-leak; וידוא offline-literal עובד (תקלה-2 הקריטית); retry-wrap+taskkill.

**9. תכנון נוסף (שלי):** **כפתור-מיקרופון בפה-ה-AI** — קלט-קולי-חופשי ('תאר-לי') הוא ה-fit הטבעי ל-`VoiceService.listen(localeId:'he-IL')`. להוסיף `voice_dictate_button` שממלא את ה-`TextField` ואז מריץ `_find`. עקבי עם שלב 38 (פה-קול) ומאחד מיקרופון. חייב לטפל ב-`onError`-כן (no-result/mic-denied) שה-`VoiceService` כבר חושף.

**10. תכנון נוסף (שלי):** **מצב-טעינה+ביטול** — בקשה-סמנטית לוקחת עד-30s; הפאנל צריך ספינר **וכפתור-ביטול** (Future-cancellation או דגל-mounted) כדי שמשתמש לא-יתקע. ה-finder מסתמך על `if(mounted)` בלבד; פה-במקלדת (שיכול להיסגר) דורש ביטול-מפורש כדי לא-לקרוא `onSeed` אחרי-dispose.

---

### שלב 49 — terminus-זרע-AI + אימות קפיצת-≤4-כרטיס
**1. יעד:** אחרי השלב — זרע-AI שמתכנס מגיע לאותו `showLipskeyProductSheet(context, product, siblings)` (אותו terminus כמו כל פה), ומאומת שהקפיצה-בין-כרטיסים מהזרע ≤4. בריכה-מתכנסת→`CardShowProducts`. זה מחבר את פה-ה-AI לכרטיס-המוצר דרך אותה שדרה, לא route חדש.

**2. איך בונים:** (א) פה-ה-AI (48) קורא `onSeed(seed)`→המסך (46) זורע→`mergedKeys` רץ→`CardShowProducts`/`CardResolve`. (ב) `_pushStep` (שורה 204-213) כבר פותח `showLipskeyProductSheet(context, v.product, v.siblings)` על `CardResolve` — **אין route חדש**, אותו terminus כ-`_onWordTap`. (ג) לאמת שזרע-AI-שמתכנס-ל-1 → `CardResolve` → sheet עם `siblings`. (ד) לאמת ≤4: מהזרע-כל-מוצר-בבריכה נגיש ≤4 לחיצות — אבל גרף-הקפיצה (`hop_graph`) נבנה רק ב-P8 (71+); כאן רק לאמת ש**בתוך** ה-`CardShowProducts` בחירת-מוצר→sheet→(rails של ה-sheet = הגרף). (ה) `expect` שזרע→`ShowProducts` (לא תקוע ב-`MergedKeys` אינסופי).

**3. תקלות צפויות:** (1) **`siblings` ריק→throw בסל-המוצר:** `showLipskeyProductSheet` שורה 43-44 מגן (`categoryProducts.isEmpty ? [product] : …`) — אבל אם זרע-AI נותן בריכה שמתכנסת ל-`CardResolve(pool.first, pool)` עם pool בגודל-1, ה-`siblings==pool` תקין. הסכנה: בריכה-ריקה→`pool.first` throw **לפני** ה-sheet. (2) **≤4 לא-ניתן-לאימות עדיין:** הגרף-הקנוני (73/77/90) לא קיים ב-P5; "אימות-≤4" כאן הוא **מוקדם-מדי** — התוכנית מסמנת תלות 46,48 בלבד, אבל ≤4-אמיתי תלוי P8. (3) **`_pushStep` ב-`initState`-context:** הזרע נדחף ב-`initState` (46) שבו אין `BuildContext`-מוכן ל-`showModalBottomSheet`; אם זרע מתכנס-מיד-ל-1, פתיחת-sheet ב-mount תזרוק (`context` לא-מוכן / `No Overlay`). (4) **`openSheetOnResolve`:** הטסט חייב לכבות אותו (כמו `card_keyboard_screen_test` שורה 58) אחרת צריך deps-כבדים של ה-sheet. (5) **double-sheet:** `_busy`-debounce מכסה tap, אבל זרע-AI שמגיע async עלול להתנגש עם tap-ידני.

**4. פתרון:** (1) שער-מבוי-סתום ב-`aiSeedToPool`/`initialSeed` (45/46): בריכה-ריקה→bריכה-רחבה, לעולם-לא-`[]`→ה-`pool.first` בטוח. (2) **לתחום את 49 ל"terminus + התכנסות-ל-ShowProducts"** ולדחות "≤4-קשיח" ל-P8 (49 מאמת רק שהזרע **מגיע** ל-sheet, לא את קוטר-הגרף). או — לאמת ≤4 **בתוך-הבריכה-המתכנסת** (כל מוצר ב-`CardShowProducts` הוא לחיצה-אחת), שזה ≤4 טריוויאלי כי הבריכה ≤12. (3) להזיז פתיחת-sheet-על-mount ל-`addPostFrameCallback` (כמו `ai_finder.initState` שורה 106) כדי ש-`context` מוכן; או לא-לפתוח-sheet-ב-mount (לחכות ל-tap). (4) הטסט מכבה `openSheetOnResolve` ובודק `verdict is CardResolve` ישירות (כמו הקיים). (5) להרחיב את `_busy` לכסות גם את ה-`onSeed` async-path.

**5. בדיקות:** `card_ai_terminus_test.dart`: (א) `forceLiveForTest:true` + `initialSeed`=בריכה-שמתכנסת + `openSheetOnResolve=false`→`pump`→`expect(state.verdict, isA<CardShowProducts>())` (התכנסות→ShowProducts, ניסוח-התוכנית). (ב) זרע-של-1-כרטיס→`expect(verdict, isA<CardResolve>())` + `(verdict as CardResolve).siblings, isNotEmpty`. (ג) `test('terminus is the same sheet')` — לאמת ש-`_pushStep` על resolve קורא `showLipskeyProductSheet` (spy/flag). (ד) ≤4-בתוך-ShowProducts: `expect(distinctProducts(pool).length, lessThanOrEqualTo(kShowProductsThreshold))` (≤12→בחירה-אחת≤4).

**6. שיפור:** לאחד את ה-terminus לפונקציה-אחת `_openTerminus(product, siblings)` שגם `_pushStep`, גם `_onWordTap` (product-path), גם זרע-AI קוראים — נקודת-יציאה-יחידה לכרטיס. מונע שלושה call-sites של `showLipskeyProductSheet` שייסחפו (כבר יש 2 ב-`card_keyboard_screen`).

**7. ריאלי?:** **חצוי** — "terminus + התכנסות" אטומי וריאלי עכשיו; "אימות-קפיצת-≤4" **תלוי P8** (הגרף לא קיים). כפי שמוגדר עם תלות 46,48 בלבד, ה-≤4 הוא או-טריוויאלי (בתוך-ShowProducts) או-בלתי-אפשרי (גרף-מלא). לפצל: 49a "terminus-זרע→sheet + ShowProducts" (עכשיו), 49b "≤4-מהזרע על הגרף-הקנוני" (אחרי 73/90).

**8. וידוא-פיקס מלא:** analyze-0; `card_ai_terminus_test` ירוק; `card_keyboard_screen_test` הקיים ירוק (terminus משותף לא-נשבר); `lipskey_product_sheet` לא-נגוע (אותה חתימה, אותו sheet); flag-OFF זהה; אין double-sheet (debounce); retry-wrap.

**9. תכנון נוסף (שלי):** **breadcrumb לזרע-AI** — כשזרע-AI פותח sheet, ה-crumb צריך להראות את הבקשה-המקורית ('ברז למטבח חם') לא רק את ה-label, כך שכפתור-"חזרה" (`_popStep`) מחזיר לפה-ה-AI עם הטקסט-משומר, לא לפתיחה-עירומה. אחרת המשתמש מאבד את הקשר-הבקשה.

**10. תכנון נוסף (שלי):** **טיפול-בכרטיס-בודד-מיידי** — אם זרע-AI מתכנס ל-`CardResolve` כבר-ב-mount, ההתנהגות הנכונה (לפתוח-sheet-מיד מול להציג-כרטיס-במסך) היא החלטת-UX. לתעד ולבחור: AI שמצא-מוצר-אחד-בדיוק כנראה צריך לפתוח sheet מיד (post-frame), בעוד פה-טקסט אולי-לא. החלטה זו חסרה ב-46/49.

---

### שלב 50 — הרכבת פה-AI למשטח-המאוחד + סגירה
**1. יעד:** אחרי השלב — פה-ה-AI הוא **slot שווה** במשטח-הכניסה מאחורי `kCardKeyboard`; flag-OFF זהה-בייטים; `ai_finder`+`claude_gateway` ירוקים. זו סגירת-P5: ששת-הפיות (טקסט/קול/רשת/חומר/עבודה/קטגוריה/AI) חיים יחד בדלת-הקדמית, פה-ה-AI ביניהם.

**2. איך בונים:** (א) להוסיף את `card_ai_mouth` (48) ל-`CardFrontDoor`/משטח-הכניסה (שלב 28/30 — `CardFrontDoor: header+history+mouths`) כ-slot שווה. (ב) לחווט `onSeed`→`initialSeed`/reseed של `CardKeyboardScreen` (46). (ג) self-gate על `kCardKeyboard` (כל המשטח כבר מאחורי-דגל). (ד) לאשר ש-`ai_finder_screen` הישן **עדיין קיים-ועובד** (לא-נמחק עד קאט-אובר-100). (ה) להריץ regression מלא: `ai_finder_test`,`claude_gateway_test`,`describe_to_cart_test`,`card_keyboard_screen_test`.

**3. תקלות צפויות:** (1) **`CardFrontDoor` עדיין-לא-קיים:** התוכנית בונה אותו ב-P3 (25-33); אם P3 לא-נחת, אין-משטח-לחבר-אליו — תלות-מבנית על 28/30 שהשלב מסמן רק 48,49,44. (2) **flag-OFF byte-identity:** הוספת slot למשטח חייבת להיות תחת `kCardKeyboard`-gate; כל רכיב-AI שדולף ל-flag-OFF שובר זהות. (3) **Riverpod override-count:** ה-`card_keyboard_screen_test` בודק ב-`ProviderScope`; הוספת `claudeGatewayProvider` למשטח דורשת override במבחנים — **שינוי מספר ה-overrides בין re-pumps אסור ב-Riverpod** (מלכודת מוכרת מהזיכרון: "Riverpod אוסר שינוי מספר overrides ב-re-pump"). (4) **golden של המשטח** (29 — מטריקות-רספונסיביות): הוספת פה-AI משנה layout→שובר golden-משטח אם קיים. (5) **regression-AI:** חיווט-משותף עלול לשבור את `ai_finder_test` אם `matchCategory`/`finderCategories` שונו.

**4. פתרון:** (1) לוודא ש-P3 (28/30) נחת **לפני** 50, או לפצל: 50 מניח `CardFrontDoor` קיים (תלות אמיתית 28,30,48,49). (2) כל ה-slot תחת `if(_live)` של המשטח; flag-OFF→`CardFrontDoor` לא-מרנדר→`SizedBox.shrink` (כמו המסך). (3) **לקבע את ה-overrides מראש** — להעביר `claudeGatewayProvider.overrideWithValue(null)` בכל המבחנים-הקיימים שמרנדרים את המשטח, ולשמור מספר-override **קבוע** בין pumps (לא להוסיף/להסיר override תוך-טסט). (4) אם יש golden-משטח, לברך-מחדש **בכוונה** (כמו 66) או להחריג את פה-ה-AI מה-golden (כמו ש-`_PredictionChip` הוחרג). (5) לא-לגעת ב-`matchCategory`/`finderCategories` (להעתיק ל-`ai_seed` ב-45, לא-לשנות מקור) → `ai_finder_test` לא-מושפע.

**5. בדיקות:** `card_front_door_ai_slot_test.dart`: (א) flag-OFF→המשטח `SizedBox.shrink`, **אין פה-AI** (`find.text('מצא לי') findsNothing`). (ב) flag-ON→6 הפיות מרנדרות כולל פה-AI (slot-שווה). (ג) tap-בפה-AI→`onSeed`→המסך נזרע (`state.crumbs` לא-ריק). (ד) **regression:** להריץ `ai_finder_test`+`claude_gateway_test`+`describe_to_cart_test`→כולם ירוקים (ניסוח-התוכנית: "ai_finder+claude_gateway ירוקים"). (ה) byte-identity: flag-OFF `CardFrontDoor` == flag-OFF פתיחה-קודמת.

**6. שיפור:** להגדיר את ששת-הפיות כ-`List<CardMouth>` נתון (שלב 25/26 `kCardMouths`) ולרנדר אותן בלולאה-אחת, כך שפה-ה-AI הוא **כניסה-ברשימה** ולא slot-מיוחד-מחווט-ידנית. מונע "פה-AI שונה מהאחרים" ומבטיח slot-שווה אמיתית (החוזה: "6 פיות שוות").

**7. ריאלי?:** **תלוי-מבנית ב-P3** (28/30 — `CardFrontDoor`+חיווט-מעטפת). כפי שמוגדר עם תלות 48,49,44, חסרה תלות-המשטח. אם P3 נחת — אטומי וריאלי (הרכבה+regression). לפצל אם P3 לא-מוכן: 50a "פה-AI כ-CardMouth ברשימה", 50b "חיווט+regression-סגירה".

**8. וידוא-פיקס מלא:** analyze-0; `card_front_door_ai_slot_test` ירוק; **regression-סוויטה מלאה:** `ai_finder_test`,`claude_gateway_test`,`describe_to_cart_test`,`ai_assistant_test`,`card_keyboard_screen_test`,`card_ai_mouth_test` — כולם ירוקים; **flag-OFF byte-identity** = הקריטריון-המרכזי (המשטח דולה-ל-`SizedBox.shrink`); Riverpod override-count קבוע (אין re-pump-mismatch); אם golden-משטח קיים — מבורך-מחדש או מוחרג; `git diff` על נתיבי-ה-AI-הישנים = 0 (הועתק, לא-שונה). taskkill dart + retry-wrap (הקיר).

**9. תכנון נוסף (שלי):** **מבחן-שקילות-פיות** — לאמת ש-3 פיות שונות (טקסט 'ברז נחושת', קול 'ברז נחושת', AI 'ברז למטבח') שמובילות לאותו מוצר מגיעות ל**אותה בריכה/אותו sheet** (parity חוצה-פיות). זה החוזה "6 פיות→בריכה אחת" ברמת-E2E, וחסר ב-50 שמרכיב-בלבד.

**10. תכנון נוסף (שלי):** **מדיניות-עלות+offline אחידה למשטח** — פה-ה-AI הוא היחיד שעולה-כסף/דורש-רשת; המשטח צריך אינדיקטור-עקבי (badge "דורש חיבור" על פה-ה-AI כש-`gw==null`, בעוד 5 הפיות עובדות-offline). לתעד שפה-ה-AI מתפקד-חלקית-offline (literal-כן, סמנטי-לא) ולהציג זאת ב-slot, לא להשאיר את המשתמש מנחש למה רק-פה-אחד לא-מגיב.

</div>

<div dir="rtl">

# פירוק מפורט — שלבים 51–60 (P6: פיות-לחיצה)

> מעוגן בקוד האמיתי תחת `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל ההפניות הן ל-`lib/features/card_keyboard/` ול-`lib/features/word_finder/` בעץ הזה בלבד (כל קלון תחת `New folder/buildsmart` הוא STALE ולא נקרא).
>
> **הקשר-המאקרו של P6:** עד שלב 50 הפיות "טקסט/קול" ו-"AI" כבר זורעות לתוך `mergedKeys`. P6 מוסיף את ארבע הפיות ה-*לחיצות-בלבד* (רשת-מילים · חומר · עבודה · קטגוריה-אמוji) כ**מקורות-זרע טהורים** מעל אותה שדרה (`mergedKeys` → `CardVerdict`), ומחווט אותן ל-`CardKeyboardScreen` בלי לגעת ב-`word_finder` החי. ה-seam הקיים שכולן רוכבות עליו הוא `SignalSource`/`sourcesFor` ב-`card_signals.dart` ו-`NewbieStep`-stack ב-`card_keyboard_screen.dart`.
>
> **מצב-בסיס שמצאתי בקוד (חשוב לכל 10 השלבים):** `card_engine.dart` כבר מלא (לא stub — ה-docstring "PHASE 0 stubbed" בשורות 10–14 מיושן, `_mergedChips` ממומש מלא). `card_signals.dart` כבר מחזיק 5 צירים + `CuratedFacetSignal`. `card_keyboard_screen.dart` כבר מחווט פתיחת-`CardAskWords` + `_WordTap`/`_ChipTap`/`_ProductTap` (sealed `_Tap`) + memo לפי `_diveVersion`. **`CardSeed` עדיין לא קיים** — שלב 51 יוצר אותו. **טאבי-פיות (chrome) עדיין לא קיימים** — שלבים 56–58 יוצרים אותם. הדגל `kCardKeyboardFlag='kCardKeyboard'` OFF כברירת-מחדל, נקרא פעם-אחת ב-`_live` (שורה 124).

---

### שלב 51 — הפשטת `CardSeed` טהורה (ה-seam האחד)

**1. יעד:** קיים טיפוס-נתונים טהור חדש `CardSeed` (קובץ `lib/features/card_keyboard/card_seed.dart`) עם החמישיה `{mouthId, displayLabel, emoji, seedPredicate, seedAxisLabel}`, שהוא ה-seam ה**יחיד** שכל ארבע פיות-הלחיצה (52–55) פולטות דרכו. לפני השלב כל "זרע" היה רק `_WordTap(word)` שמיתרגם דרך `resolveWord`; אחרי השלב יש מודל-זרע אחיד שאינו תלוי-מילון: predicate ישיר על `LipskeyCatalogProduct` + תווית-ציר שתיכנס ל-`NewbieStep.axisLabel`. ה-sentinels (ערכי `seedAxisLabel` לכל פה) נבדלים זוג-זוג כך ש-`answeredAxes` יודע איזה ציר פה-הפתיחה "שרף" (או לא).

**2. איך בונים:** (א) קובץ חדש `card_seed.dart`, `library;`, import רק `lipskey_catalog.dart` + `package:flutter/foundation.dart show immutable` — אפס Flutter-widgets/Riverpod (אותה דוקטרינת-טוהר כמו `card_signals.dart` שורה 18). (ב) `@immutable class CardSeed` עם השדות; `seedPredicate` מסוג `bool Function(LipskeyCatalogProduct)`. (ג) להגדיר `==`/`hashCode` **בלי** `seedPredicate` (closure לא בר-השוואה-ערכית — ראה תקלה 3) — להשוות על `mouthId+displayLabel+emoji+seedAxisLabel`. (ד) קבועי-sentinel ל-`seedAxisLabel`: לעקוב אחרי התקדים הקיים `_kOpeningWordAxis='מילת-פתיחה'` (`card_keyboard_screen.dart:51`) — ערכים שאינם אף `SignalSource.axisName` ('גודל'/'זווית'/'צבע'/'דגם'/'חומר'/'אפשרות'), כך שזריעה לא מסמנת ציר-מיזוג כ-answered. לדוגמה: `kSeedAxisWord='מילת-פתיחה'` (re-use), `kSeedAxisMaterial='חומר-פתיחה'`, `kSeedAxisJob='עבודה-פתיחה'`, `kSeedAxisCategory='קטגוריה-פתיחה'`. (ה) **החלטת-סמנטיקה קריטית לחומר:** `kSeedAxisMaterial` חייב להיות **שונה** מ-`MaterialSignal.axisName='חומר'` (שלב 9/31: זרע-חומר gate-exempt משאיר את ציר-החומר פתוח להתחרות). (ו) לתעד ב-docstring שזו ה"abstraction אחת" — אין מסלול-זרע שני.

**3. תקלות צפויות:** (א) **closure ב-`==`** — אם נכלול `seedPredicate` ב-`hashCode`/`==`, שני זרעים זהים-לוגית ייראו שונים (closures שונים-אינסטנס), ו-`Set<CardSeed>`/golden ישברו אקראית; גרוע מכך, `const` בלתי-אפשרי. (ב) **התנגשות-sentinel** — אם `kSeedAxisMaterial=='חומר'` (זהה ל-`MaterialSignal.axisName`), זריעה תכניס `NewbieStep(axisLabel:'חומר')`, `_mergedChips` (שורה 229 `if (answered.contains(src.axisName)) continue`) ידלג על ציר-החומר, וזה **סותר את שלב 9/31** ("ציר נשאר פתוח"). (ג) **טוהר** — import בטעות של `material.dart` ימשוך UI לתוך ספרייה-טהורה ויפיל את אינווריאנט-הטוהר שכל הבדיקות מסתמכות עליו. (ד) זה שלב *הוספה-בלבד* — אסור שיגע ב-`card_engine.dart`/`card_signals.dart` כך שזהות-הבייטים flag-OFF נשמרת אוטומטית (אין מסלול-קריאה מהפרודקשן).

**4. פתרון:** (א) להחריג `seedPredicate` מ-`==`/`hashCode` (כמו שה-`SignalChip` ב-`card_engine.dart:81-93` בכוונה משווה רק שדות-נתונים) — ולתעד "predicate excluded: closures aren't value-equal; identity is the (mouthId,axisLabel,label) tuple". (ב) בדיקת-אינווריאנט שכל ערכי-ה-sentinel ∉ `{for (s in kHardSignals) s.axisName} ∪ {'אפשרות'}`. (ג) lint/בדיקה שהקובץ לא מייבא `flutter/material` או `flutter_riverpod` (grep בבדיקה או `dart analyze`). (ד) לוודא שאף קובץ-פרודקשן לא מייבא עדיין את `card_seed.dart` (רק טסטים) — זהות-בייטים מובטחת.

**5. בדיקות:** `test/features/card_keyboard/card_seed_test.dart`: (1) `'sentinels זוג-זוג נבדלים'` — לאסוף את כל קבועי-ה-axis ולוודא `.toSet().length == count`. (2) `'אף sentinel אינו axisName של ציר-מיזוג'` — `expect(kSeedAxis*, isNot(anyOf('גודל','זווית','צבע','דגם','חומר','אפשרות')))`. (3) `'== מתעלם מ-predicate'` — שני `CardSeed` עם אותם שדות אך closures שונים → `expect(a, equals(b))`. (4) `'seedPredicate מסנן ולא-ריק על kDivePool'` — לכל seed-מדגם, `kDivePool.where(s.seedPredicate)` לא-ריק ⊊ `kDivePool` (mirror של בדיקת `CardMouth.seedFor` בשלב 25). (5) `'טוהר: אין import של widgets'` — קריאת הקובץ ו-`expect(content.contains('material.dart'), isFalse)`.

**6. שיפור:** במקום `String seedAxisLabel` חופשי, להגדיר `enum CardSeedAxis { word, material, job, category }` עם `extension` ל-Hebrew-label — מונע typo-sentinel ב-compile-time ומבטל את בדיקת-ההתנגשות (ב) לגמרי (ה-enum לא יכול להתנגש ל-String של `axisName`). מחיר: צריך map enum→`NewbieStep.axisLabel` בנקודת-החיווט (58), אך זה זול ובטוח יותר.

**7. ריאלי?:** כן — אטומי ובר-בדיקה במלואו. זהו טיפוס-נתונים טהור של ~40 שורות בלי תלות-מצב, בלי UI, בלי קריאת-פרודקשן. אין סיבה לפצל.

**8. וידוא-פיקס מלא:** `dart analyze` = 0-חדש (קובץ חדש בלבד). זהות-בייטים flag-OFF **טריוויאלית** כי אין קוֹרֵא-פרודקשן (אפשר לאמת ב-grep: `card_seed` מופיע רק תחת `test/`). להריץ את כל חבילת `card_keyboard` הקיימת (`card_engine_test`, `card_signals_test`, `card_keyboard_screen_test`, `card_soft_test`) — חייבות להישאר ירוקות ללא-שינוי (השלב לא נגע בהן). אין-leak: הקובץ טהור, אין `dispose` נדרש.

**9. תכנון נוסף (שלי):** להוסיף שדה אופציונלי `String? seedCrumb` (ברירת-מחדל = `displayLabel`). כיום `card_keyboard_screen` קובע `crumbWord: payload.word`/`payload.displayLabel`. פה-עבודה (54) ירצה crumb ידידותי ("ברז לכיור") שונה מ-`displayLabel` הטכני — להפריד עכשיו חוסך רפקטור ב-58.

**10. תכנון נוסף (שלי):** factory-guard `CardSeed.checked(...)` שזורק `assert(displayLabel.isNotEmpty)` ב-debug — מונע מקרה-קצה של זרע-ריק שיֵצֵר `WordKey('')` (מקש-ריק) במורד הזרם ב-56/58. זה תופס באגי-נתונים בפיות-עבודה/קטגוריה שבהן ה-label נגזר ממקור חיצוני (`SmartProduct.name`/`categoryHe`).

---

### שלב 52 — פה רשת-מילים + מקור-זרע עוד…(זנב-ארוך)

**1. יעד:** קיים מקור-זרע טהור `wordSeeds(pool, {expanded})` (ב-`card_seed.dart` או `card_word_mouth.dart`) שמחזיר `List<CardSeed>` עבור פה-רשת-המילים: **מצב-מקופל = top-24** מילים, **מצב-מלא = הזנב-הארוך כולו**. לפני השלב הפתיחה מציגה `wordsByFrequency(lexicon).take(kFirstWordCount)` (`card_engine.dart:158`) ללא toggle ולא 24-cap נבדל. אחרי: יש מקור-זרע יחיד שה-UI (56/59) צורך, עם הבחנה מקופל/מלא דטרמיניסטית.

**2. איך בונים:** (א) להחליט מקור-המילים: לעקוב אחרי `cardKeyboardLexicon` (`card_keyboard_screen.dart:40` = `buildWordLexicon(kDivePool)`) + `wordsByFrequency` (כבר מיובא ב-`card_engine.dart:33`). (ב) `List<CardSeed> wordSeeds(WordLexicon lex, {bool expanded=false})`: לבנות מ-`wordsByFrequency(lex)` רשימה; `expanded ? full : full.take(24)`. (ג) ה-`seedPredicate` לכל מילה = `(p) => resolveWord(word, lex).any((r)=>r.sku==p.sku)` — **זהה לוגית** למה ש-`_onWordTap`/`_WordTap` עושה היום (`card_keyboard_screen.dart:318-333`: `resolveWord(...).sku` → `skuSet.contains`). כדי להישאר טהור, להעדיף לחשב `skuSet` פעם-אחת ולסגור עליו. (ד) `seedAxisLabel=kSeedAxisWord` (='מילת-פתיחה', re-use, כדי לא לשרוף ציר-דגם). (ה) `emoji` ריק/אחיד (מילים אין-אמוji); `displayLabel=word`. (ו) קבוע `kWordMouthCollapsed=24`.

**3. תקלות צפויות:** (א) **24 מול `kFirstWordCount`** — אם `kFirstWordCount != 24`, מסלול-הפתיחה הקיים (`card_engine.dart:158 CardAskWords`) ומסלול-`wordSeeds` המקופל יציגו רשימות שונות → אי-עקביות-UX וגולדן-מבולבל. (ב) **דטרמיניזם** — `wordsByFrequency`/`wordOptions` רגישים-לסדר (תועד מפורשות ב-`card_signals.dart:158-163`: "`wordOptions`' equal-count tie-break follow the pool's iteration order"); אם `wordSeeds` נגזר מ-pool מסונן (ולא מהמילון-הקבוע), shuffle ישבור top-24. (ג) **`resolveWord` מחזיר-ריק** — מילה שלא ממופה תיתן `seedPredicate` שמסנן-לריק → מקש-זרע מת. (ד) זה עדיין מקור טהור — אסור לגעת ב-`card_engine.dart` (הפתיחה נשארת `CardAskWords` עד שלב 56 שמרפקטר את `_keysFor`).

**4. פתרון:** (א) לקבע `kWordMouthCollapsed` ולהאחיד: או להציב `kFirstWordCount==24`, או בדיקה מפורשת שמתעדת שהם שונים-בכוונה (פתיחה ≠ פה-מילים). (ב) לגזור תמיד מ-`cardKeyboardLexicon` הקבוע (top-level, נבנה פעם-אחת מ-`kDivePool`) ולא מ-pool-זמני, כך ש-top-24 קבוע ובלתי-תלוי-shuffle — ולהוסיף בדיקת-shuffle. (ג) לסנן זרעים שה-`seedPredicate` שלהם ריק על `kDivePool` (drop empty) — או, פשוט יותר, לסמוך על כך ש-`wordsByFrequency` כבר מגיע מהמילון שנבנה מאותו pool (כל מילה ⇒ ≥1 מוצר). (ד) grep: `wordSeeds` לא נקרא מפרודקשן עד 56.

**5. בדיקות:** `test/features/card_keyboard/card_word_mouth_test.dart`: (1) `'collapsed == 24'` — `expect(wordSeeds(cardKeyboardLexicon).length, 24)` (או `<=24` אם הזנב קצר; להתאים ל-`kWordMouthCollapsed`). (2) `'expanded ⊋ collapsed וה-prefix זהה'` — `expanded.take(24)` שווה ל-collapsed (אותו דירוג, רק מאריך). (3) `'shuffle-stable'` — לבנות מילון מ-`kDivePool` מעורבב ולוודא אותם 24 labels (mirror של `WordSignal.chipsFor` sku-sort). (4) `'כל seedPredicate לא-ריק על kDivePool'`. (5) `'seedAxisLabel == kSeedAxisWord לכולם'`.

**6. שיפור:** במקום `expanded:bool` בינארי, להחזיר את הרשימה-המלאה-המדורגת פעם-אחת ולתת ל-UI לחתוך (`.take(24)`/הכל) — מבטל כפילות-חישוב ומפשט את ה-toggle בשלב 59 ל-state-של-UI בלבד (`_wordsExpanded` חותך, לא קורא-מחדש). פחות משטח-באג.

**7. ריאלי?:** כן — אטומי. מקור טהור עם פרמטר-בוליאני בודד. הבדיקות ישירות. אין צורך לפצל; ה-toggle-UI מופרד נכון לשלב 59.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF זהות-בייטים: `wordSeeds` עדיין לא-מחווט (פרודקשן עובר ב-`CardAskWords` הישן) → אין שינוי-פלט. חבילת-`card_keyboard` ירוקה. הבדיקה החשובה היא shuffle-stability (תופסת רגרסיית-דטרמיניזם, הכשל ההיסטורי מס' 1 במודול לפי `card_signals.dart:158`).

**9. תכנון נוסף (שלי):** dedup על `displayLabel` ב-`wordSeeds` — `wordsByFrequency` עלול להחזיר וריאנט-איות כפול; `Set`-by-label לפני ה-cap מבטיח שה-24 הם 24 *נבדלים* (אחרת מקופל יציג <24 ייחודיים).

**10. תכנון נוסף (שלי):** לכלול בכל `CardSeed`-מילה ספירת-`hitCount` (=`resolveWord(...).length`) כשדה-תצוגה-אופציונלי. פה-הטקסט (37) כבר מציג 'נמצאו N'; פה-המילים יכול להציג כמה-מוצרים כל מילה פותחת — מנחה את המשתמש לעבר מילים-מפצלות לפני ההקלקה, מקרב ל-≤6.

---

### שלב 53 — מקור-זרע פה-חומר (נחושת מקפלת פליז, gate-exempt)

**1. יעד:** קיים `materialSeeds(pool)` שמחזיר `CardSeed` אחד לכל חומר ב-`materialsInPool(pool)` (`material_lexicon.dart:95`), שבו **נחושת מקפלת נחושת+פליז** (כי `kMaterials['נחושת']=['נחושת','פליז']`, שורה 48), והזרע **gate-exempt** — בניגוד ל-`MaterialSignal.chipsFor` (`card_signals.dart:207-208`) שמסתיר חומר מתחת `kMaterialCoverageGate=0.5`, פה-החומר תמיד מציע את החומרים (כי הוא ה*מקור* של הצלילה, לא ציר-מיזוג). אחרי השלב: לחיצה על 'נחושת' זורעת את כל מוצרי-הנחושת/פליז ומשאירה את ציר-החומר במיזוג *פתוח* (שלב 9/31).

**2. איך בונים:** (א) `List<CardSeed> materialSeeds(List<LipskeyCatalogProduct> pool)`: `for (m in materialsInPool(pool))` → `CardSeed(mouthId:'material', displayLabel:m, emoji:_materialEmoji(m), seedAxisLabel:kSeedAxisMaterial, seedPredicate:(p)=>materialOf(p)==m)`. (ב) **שים לב להבדל-predicate מ-`MaterialSignal.matches`:** ה-axis-predicate הוא null-tolerant carry-along (`card_signals.dart:221-224`: `m==chip.value || m==null`) כי שם הוא *מצמצם* בריכה-קיימת ולא רוצה להפיל את ה-unknown-majority. אבל פה-החומר *זורע* — הוא צריך את הזרע ה**מדויק** (`materialOf(p)==m`, ללא null), אחרת זרע-'נחושת' היה בולע את כל חסרי-החומר (רוב היקום). (ג) gate-exempt: לא לקרוא ל-`seededFraction`/`kMaterialCoverageGate` כאן בכלל. (ד) `_materialEmoji`: map קטן 'נחושת'→🟠/'PPR'→🔵 וכו' (אופציונלי; אפשר אמוji-אחיד 🧪). (ה) `seedAxisLabel=kSeedAxisMaterial` (='חומר-פתיחה' ≠ 'חומר').

**3. תקלות צפויות:** (א) **predicate הפוך** — אם נשתמש ב-`MaterialSignal().matches` (carry-along null) לזריעה, 'נחושת' תזרע ~רוב-היקום (כל ה-null-material רוכבים), הצלילה לא תצטמצם, וחוזה-≤6 יישבר. (ב) **שריפת-ציר** — אם `kSeedAxisMaterial=='חומר'`, ציר-החומר יסומן answered (`card_engine.dart:229`) וזה סותר שלב 9/31 מפורשות ("'נחושת'→'חומר' UNANSWERED", בדיקת שלב 31). (ג) **קיפול פליז** — בדיקה שמצפה שזרע-'נחושת' כולל גם מוצרי-פליז: תלוי ב-`materialOf` שמחזיר 'נחושת' עבור טקסט-'פליז' (precedence ב-`kMaterials`); וגם ב-`kCategoryMaterial` (שורה 68: 'ברזי ניל'→'נחושת' וכו') — שתי דרכי-קיפול. (ד) `materialsInPool` ריק על pool-דליל → אפס-זרעים-חומר (תקין, אבל הבדיקה צריכה pool מובטח-עשיר).

**4. פתרון:** (א) predicate-זריעה מדויק `materialOf(p)==m` (ללא null) — לתעד מפורשות את ההבדל מ-axis-matches. (ב) `kSeedAxisMaterial` קבוע נבדל (כבר אכוף ע"י בדיקת-sentinel בשלב 51). (ג) בדיקה משתמשת ב-`kDivePool` המלא (מובטח שיש בו נחושת+פליז+פלדה — `card_signals_test.dart:105-111` כבר נשען על קיומם). (ד) על pool-ריק להחזיר `const []` בלי-throw.

**5. בדיקות:** `test/features/card_keyboard/card_material_mouth_test.dart`: (1) `'נחושת שומרת copper+brass, דוחה פלדה'` — `final s = materialSeeds(kDivePool).firstWhere((x)=>x.displayLabel=='נחושת'); final kept = kDivePool.where(s.seedPredicate);` — לוודא שיש בתוך-kept מוצר עם טקסט-'פליז' וגם עם טקסט-'נחושת', ושאין בתוכו מוצר עם `materialOf=='פלדה'`. (2) `'gate-exempt: pool דליל (30% חומר) עדיין מחזיר זרעי-חומר'` — לבנות pool ב-`seededFraction<0.5` ולוודא `materialSeeds(pool).isNotEmpty` (בעוד `MaterialSignal().chipsFor(samePool)` ריק — ניגוד מפורש שמוכיח את ה-exempt). (3) `'seedAxisLabel==kSeedAxisMaterial (≠חומר)'`. (4) `'labels == materialsInPool(pool)'` — parity לסדר. (5) `'predicate-זריעה אינו carry-along'` — מוצר עם `materialOf==null` **לא** נכלל בזרע-נחושת (ההיפך מ-`card_signals_test.dart:97-103`).

**6. שיפור:** למזג את map-האמוji לחומר עם סדר-התצוגה ב-`kMaterials` (`material_lexicon.dart:47`) — להוסיף שדה-אמוji למפתח-החומר במקום map-מקביל, כך שאמת-אחת. אם פולשני מדי לקובץ-הליבה, להחזיק `const Map<String,String> kMaterialEmoji` ליד `materialSeeds` עם בדיקה שמפתחותיו = `kMaterials.keys` (אין חומר ללא-אמוji ואין אמוji-יתום).

**7. ריאלי?:** כן — אטומי. מקור טהור הנשען על `material_lexicon.dart` הקיים-והבדוק. הסיכון היחיד (predicate carry-along מול מדויק) נתפס בבדיקה (5). אין צורך בפיצול.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF: `materialSeeds` לא-מחווט עד 58 → פרודקשן זהה-בייטים. `material_lexicon_test.dart` הקיים נשאר ירוק (לא נגענו ב-`material_lexicon.dart`). הניגוד-המפורש בבדיקה (2) הוא הווידוא שה-gate-exempt עובד *ושאינו דולף* לציר-המיזוג (שמכבד עדיין את ה-gate).

**9. תכנון נוסף (שלי):** לבדוק `kCategoryMaterial`-overrides (`material_lexicon.dart:68`, 6 קטגוריות→'נחושת') — זרע-'נחושת' חייב לכלול גם 'ברזי ניל'/'מחלקים' שאין בשמם 'נחושת'/'פליז'. להוסיף assertion שמוצר מקטגוריית-override נמצא בתוך זרע-הנחושת — אחרת "איפה כל אביזרי-הנחושת?" (כוונת-הבעלים המקורית) מפספס את ברזי-הפליז-מצופי-כרום.

**10. תכנון נוסף (שלי):** מיון-זרעי-החומר לפי גודל-דלי (כמה מוצרים כל חומר פותח) ולא לפי סדר-`kMaterials`-בלבד — חומר עם 3 מוצרים אחרי לחיצה כבר ≤threshold וקרוב-לכרטיס; חומר עם 120 (HDPE, `material_lexicon.dart:50`) רחוק. תצוגה לפי-תרומה מקרבת ל-≤6 ועקבית עם רוח-`representativeTake`.

---

### שלב 54 — מקור-זרע פה-עבודה (מתכון on-ramp)

**1. יעד:** קיים `jobSeeds()` שמחזיר `CardSeed` אחד לכל מתכון ב-`kSmartProducts` (`smart_tree.dart:153`), שבו ה-`seedPredicate` נגזר מ-`assembleKit(recipe)` (`recipe_kit.dart:261`) — כלומר זריעת-עבודה ('סיפון לכיור') פותחת את **כל המוצרים שהמתכון מאסף** (ה-`KitLine.product.sku` שנפתרו). אחרי השלב: `jobSeeds().length == kSmartProducts.length`, וכל זרע-עבודה הוא on-ramp שמכניס את המשתמש לבריכת-מוצרי-המתכון.

**2. איך בונים:** (א) `List<CardSeed> jobSeeds()`: `for (r in kSmartProducts)` → לחשב `skuSet = {for (line in assembleKit(r)) if (line.product != null) line.product!.sku}` (זכור: `KitLine.product` הוא `LipskeyCatalogProduct?`, `recipe_kit.dart:78`, ויכול להיות null עבור `KitMatch.none`). (ב) `CardSeed(mouthId:'job', displayLabel:r.name, emoji:r.emoji, seedAxisLabel:kSeedAxisJob, seedPredicate:(p)=>skuSet.contains(p.sku))`. (ג) `r.emoji` ו-`r.name` כבר קיימים (`smart_tree.dart:128-129`: '🌀'/'סיפון לכיור רחצה'). (ד) להחליט מקור-ה-sku: `assembleKit` (acc-בלבד) או גם `recipe.brands[].sku`? — המתכון עצמו (הברזים/סיפונים) חי ב-`brands` (`smart_tree.dart:130`,163-186), והאביזרים ב-`acc`. ל-on-ramp שלם כדאי **union(brands.sku, assembleKit.product.sku)** — אחרת זרע-'סיפון' פותח רק את האטמים/טפלון ולא את הסיפון עצמו. אבל הצעד אומר מפורשות "predicate מ-assembleKit", אז: predicate-בסיס = `assembleKit`, ובדיקה (9) תרחיב ל-brands. (ה) sentinel `kSeedAxisJob='עבודה-פתיחה'` — לא ציר-מיזוג (אין ציר 'עבודה' ב-`sourcesFor`), אז ממילא לא שורף-ציר.

**3. תקלות צפויות:** (א) **`KitLine.product==null`** — `assembleKit` מחזיר line לכל acc, גם כשלא-נפתר (`KitMatch.none`, `recipe_kit.dart:228-234`, product:null); `line.product!.sku` יזרוק NPE. (ב) **זרע-ריק** — מתכון שכל ה-acc שלו לא-נפתרו → `skuSet` ריק → זרע-עבודה מת (מקש שמוביל ל-`CardShowProducts([])`/empty-state). (ג) **טוהר** — `assembleKit` עצמו טהור (map מעל `resolveAccessory`, `recipe_kit.dart:261`), אבל הוא יקר-יחסית (סורק קטלוג לכל acc); קריאה ב-build-loop של 30+ מתכונים × N-acc תהיה איטית אם תיקרא בכל-keystroke. (ד) **חוסר-on-ramp** — אם נשתמש רק ב-acc, ה-sku של המוצר-הראשי (הסיפון) לא נכלל וה-UX שבור ("בחרתי סיפון, איפה הסיפון?").

**4. פתרון:** (א) `if (line.product != null)` לפני קריאת-sku (כמו (א) ב-2). (ב) לסנן זרעי-עבודה עם `skuSet` ריק (drop empty) — או לכלול תמיד את `brands.sku` כך שהזרע לעולם לא-ריק (כל מתכון יש לו brands). (ג) לחשב `jobSeeds()` **פעם-אחת** (top-level `final`, כמו `cardKeyboardLexicon`) — `assembleKit` דטרמיניסטי ונטול-מצב, אז cache-קבוע בטוח; ה-screen-memo (`_diveVersion`) ממילא לא יקרא-מחדש. (ד) union עם `brands.sku` (ראה 2ד) — ולתעד שהזרע = מתכון+אביזריו.

**5. בדיקות:** `test/features/card_keyboard/card_job_mouth_test.dart`: (1) `'length == kSmartProducts.length'` (או `<=` אם מסננים ריקים — להתאים להחלטת-4ב). (2) `'predicate מ-assembleKit: זרע-סיפון פותח את אביזרי-המתכון'` — `final s=jobSeeds().firstWhere((x)=>x.displayLabel=='סיפון לכיור רחצה'); final kit=assembleKit(kSmartProducts.firstWhere((r)=>r.key=='basinTrap')); for (line in kit) if (line.product!=null) expect(kDivePool.where(s.seedPredicate).map((p)=>p.sku), contains(line.product!.sku));`. (3) `'אף זרע לא NPE (product==null מסונן)'` — `expect(()=>jobSeeds(), returnsNormally)`. (4) `'אף זרע לא-ריק על kDivePool'` (אם בחרנו union-brands). (5) `'seedAxisLabel==kSeedAxisJob'`.

**6. שיפור:** לקבץ זרעי-עבודה לפי `recipe.cat` ('ניקוז וצנרת'/'ברזים וכיורים', `smart_tree.dart:129`) — 30+ מתכונים בשורה-שטוחה גדולים-מדי לפתיחה; היררכיית-קטגוריה (קטגוריה→מתכונים) או cap+"עוד" שומרת על ה-UX. עקבי עם רוח ה-collapsed-24 של פה-המילים.

**7. ריאלי?:** כן, *אבל בגבול*. אטומי כמקור-זרע, אך החלטת-ה-on-ramp (acc-בלבד מול union-brands) היא החלטת-מוצר שמשנה התנהגות. הצעד מנוסח "predicate מ-assembleKit" — אם נצמדים לזה בלבד, הוא אטומי-ובטוח אבל ה-UX חלקי; ה-union הוא תוספת-קטנה שלא דורשת פיצול-שלב, רק החלטה מתועדת. **שומר על אטומיות.**

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF: לא-מחווט עד 58 → זהות-בייטים. `recipe_kit_test.dart` הקיים נשאר ירוק. ביצועים: לאמת ש-`jobSeeds()` הוא `final`-top-level (לא getter) — לוודא שאין קריאת-`assembleKit` חוזרת בכל-frame (אפשר בדיקת-זהות-מופע: `identical(jobSeeds, jobSeeds)` אם משתנה-קבוע). אין-leak (טהור).

**9. תכנון נוסף (שלי):** לכלול את `KitMatch.ambiguous`-מוצרים בזרע (לא רק `auto`/`curated`) — `assembleKit` מחזיר גם best-guess עמום (`recipe_kit.dart:250-255`); להשמיט אותם מצמצם-יתר את ה-on-ramp. או לפחות שדה-tag שמסמן confidence, כך שפה-העבודה זורע-רחב והכרטיס מציג איכות-התאמה. תואם את רוח 'דו-צירי-ציון' מהזיכרון.

**10. תכנון נוסף (שלי):** קישור-דו-כיווני: לשמור על כל `CardSeed`-עבודה את `recipe.key` (כ-metadata) כך שכאשר הצלילה מתכנסת לכרטיס, ה-rail-עבודה (P10, שלב 98 'השלם-קו'/BOM) יכול לשחזר את ה-`SmartProduct` המקורי ולהציע את שאר-המתכון. בלי זה הזרע "שוכח" מאיזה מתכון בא, וה-on-ramp הופך חד-כיווני.

---

### שלב 55 — פה קטגוריה/אמוji מכסה כל-כרטיס (דליי כל-הקטלוג)

**1. יעד:** קיים `categorySeeds()` שמחזיר `CardSeed` לכל דלי-קטגוריה כך ש**איחוד-הדליים מכסה 100% מ-`kReachUniverse`** (כל כרטיס-יקום שייך ל≥דלי-אחד — אפס-יתומים). זהו הפה ה*ממצה* (היחיד שמבטיח כיסוי-מלא ללא-הקלדה), שעליו נשען מפקד-הדפדוף בשלב 60. אחרי השלב: `union(for s in categorySeeds() kDivePool.where(s.seedPredicate)) == distinct(kDivePool)`.

**2. איך בונים:** (א) מקור-הדליים: `LipskeyCatalogProduct.categoryHe` (השדה הקיים, נקרא ב-`material_lexicon.dart:82`, ב-`kCategoryMaterial`-keys). `final cats = {for (p in kDivePool) p.categoryHe}` → דלי לכל-קטגוריה. (ב) `CardSeed(mouthId:'category', displayLabel:cat, emoji:_categoryEmoji(cat), seedAxisLabel:kSeedAxisCategory, seedPredicate:(p)=>p.categoryHe==cat)`. (ג) **ערובת-הכיסוי:** כיוון שכל מוצר *יש לו* `categoryHe`, חלוקה-לפי-categoryHe מכסה 100% טריוויאלית — *בתנאי* שלא מסננים קטגוריות. אם רוצים אמוji-מובחר רק לחלקן, צריך דלי-"אחר"/fallback שאוסף כל קטגוריה-לא-ממופה, אחרת יתומים. (ד) `_categoryEmoji`: map קטגוריה→אמוji (חלקי), עם ברירת-מחדל 📦. (ה) sentinel `kSeedAxisCategory='קטגוריה-פתיחה'`.

**3. תקלות צפויות:** (א) **יתומים** — אם נבחר רשימת-קטגוריות-אמוji *מובחרת* (כמו `kFinderFacets`, `narrow_axis.dart:84`, שמכסה רק 3 subtypes) במקום *כל* ה-`categoryHe`, מוצרים בקטגוריות-לא-ממופות נופלים בין-הכיסאות וה-census בשלב 60 נכשל ("איחוד≠100%"). (ב) **`categoryHe` ריק/null** — מוצר עם `categoryHe==''` יוצר דלי-ריק או נופל-החוצה. (ג) **גרנולריות** — אם `kDivePool` מכיל 80+ קטגוריות-נבדלות, שורת-פתיחה של 80 אמוji בלתי-שמישה (סותר ≤6-קליקים-לפתיחה). (ד) **התנגשות עם `kReachUniverse`** — הצעד מדבר על "כל כרטיס-יקום"; היקום הקנוני (`kReachUniverse`, שלב 1) = כרטיסים-*נבדלים*, בעוד `categoryHe` הוא ברמת-מוצר; צריך לוודא שהכיסוי נמדד על אותו יקום (distinct-cards), לא על raw-pool.

**4. פתרון:** (א) **דלי-לכל-`categoryHe` + דלי-fallback** — לבנות מ-*כל* הקטגוריות הנבדלות (לא רשימה-מובחרת), כך שכיסוי-100% מובטח-בקונסטרוקציה. אמוji-מובחר רק לתצוגה; קטגוריה-לא-ממופה מקבלת 📦 אך עדיין דלי-משלה. (ב) למפות `categoryHe` ריק לדלי-"כללי" מפורש. (ג) **קיבוץ-על** — אם יותר-מדי קטגוריות, להגדיר `kCategoryGroups` (map קטגוריה→קבוצת-על, ~8-12 קבוצות) ולזרוע ברמת-הקבוצה, עם invariant שכל `categoryHe`∈קבוצה-כלשהי (זה ה"דליי כל-הקטלוג" האמיתי של הצעד). (ד) למדוד כיסוי על `distinctProducts(kDivePool)`/`kReachUniverse` ולא על raw-`kDivePool`.

**5. בדיקות:** `test/features/card_keyboard/card_category_mouth_test.dart`: (1) `'איחוד-הדליים == 100% היקום (אין יתום)'` — `final covered={for (s in categorySeeds()) for (p in kDivePool.where(s.seedPredicate)) p.sku}; expect(covered, containsAll(kDivePool.map((p)=>p.sku)));` (או מול `distinctProducts`). (2) `'כל קטגוריה→קבוצה (אם יש קיבוץ-על)'` — `for (c in {kDivePool.categoryHe}) expect(kCategoryGroups.containsKey(c) || hasFallback, isTrue)`. (3) `'אין דלי-ריק'` — כל seed פותח ≥1 מוצר. (4) `'seedAxisLabel==kSeedAxisCategory'`. (5) `'דטרמיניסטי: סדר-דליים יציב תחת shuffle'`.

**6. שיפור:** לגזור את עץ-הקטגוריות מ-`smart_tree.dart` הקיים (שכבר מארגן קטגוריה→מתכון, `SmartProduct.cat`) במקום map-אמוji ידני — מאחד את היררכיית-העבודה (54) וההיררכיית-קטגוריה (55) למקור-אחד, ומבטל סחיפה בין-שניהם. ה-"דליי כל-הקטלוג" הופך נגזר ולא-מתוחזק-ביד.

**7. ריאלי?:** **בגבול — נוטה ל"גדול-מדי".** "מכסה כל-כרטיס" + קיבוץ-לאמוji-שמיש הם שתי דאגות: (א) כיסוי-מלא (טכני, קל) ו-(ב) טקסונומיה-ידידותית (החלטת-מוצר, פתוחה). אם `kDivePool` מכיל עשרות-קטגוריות, **כדאי לפצל**: 55a = `categorySeeds` גולמי-לפי-`categoryHe` עם invariant-כיסוי (אטומי, בר-בדיקה מיד); 55b = `kCategoryGroups` קיבוץ-לאמוji-שמיש (החלטת-מוצר, ניתן-לדחות). הצעד כפי-שמנוסח מערבב את שניהם.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF: לא-מחווט עד 58. **בדיקת-הכיסוי (1) היא ה-gate הקריטי** — היא ההוכחה שפה-הקטגוריה ממצה, שבלעדיה מפקד-60 לא-יכול-לעבור. להריץ אותה על `kDivePool` המלא (כולל 81 מים-חמים, `dive_pool.dart:49`) — אחרת מים-חמים יתומים. אין-leak (טהור).

**9. תכנון נוסף (שלי):** invariant הפוך — **כל דלי ⊆ היקום** (אין דלי שמפנה לקטגוריה-רפאים שאין בה מוצרים). יחד עם בדיקת-(1) זה נותן ביג'קציה: דליים↔יקום, אפס-יתום *ואפס-דלי-מת*. בלי זה אפשר "לרמות" את הכיסוי עם דלי-ענק-יחיד.

**10. תכנון נוסף (שלי):** לכרוך אמוji-קטגוריה למפת-החומר/האייקון הקיימת — `card_keyboard_screen._glyphForAxis` (`card_keyboard_screen.dart:239-247`) כבר ממפה ציר→`IconData`. פה-הקטגוריה צריך אמוji עקבי איתו (לא להמציא סט-אייקונים שני). להגדיר מקור-אייקונים-אחד שמשרת גם את הטאבים (57) וגם את דליי-הקטגוריה.

---

### שלב 56 — רפקטור רשת-המסך ל-`wordSeeds`

**1. יעד:** `CardKeyboardScreen` משתמש ב-`wordSeeds` (שלב 52) כמקור-מקשי-הפתיחה דרך payload **typed** `_SeedTap` חדש, במקום ה-`_WordTap` הנוכחי שעובר דרך `CardAskWords`+`resolveWord` inline. אחרי השלב: ה-top-24 שמוצג זהה (regression-safe), אך הזריעה עוברת במסלול-`CardSeed` האחיד — מכין את הקרקע לחיווט שאר-הפיות (58) דרך אותו seam.

**2. איך בונים:** (א) להוסיף ל-sealed `_Tap` (`card_keyboard_screen.dart:59`) מקרה `class _SeedTap extends _Tap { const _SeedTap(this.seed); final CardSeed seed; }` — מקביל ל-`_WordTap`/`_ChipTap`/`_ProductTap` הקיימים. (ב) ב-`_keysFor` (`card_keyboard_screen.dart:255`), בענף `CardAskWords` להחליף `WordKey(e.word, payload:_WordTap(e.word))` ב-`for (s in wordSeeds(cardKeyboardLexicon)) WordKey(s.displayLabel, payload:_SeedTap(s))`. (ג) ב-`_onWordTap` (`:309`), להוסיף ענף `if (payload is _SeedTap)` שדוחף `NewbieStep(axisLabel:payload.seed.seedAxisLabel, chipLabel:payload.seed.displayLabel, crumbWord:payload.seed.displayLabel, predicate:payload.seed.seedPredicate)` — מאחד את הלוגיקה שכיום משוכפלת ב-`_WordTap`-branch (`:318-334`). (ד) **לשמור** את `_WordTap` בינתיים? לא — להחליפו ב-`_SeedTap` (פה-מילים זה רק עוד `CardSeed`). אבל `CardAskWords` עדיין מקור-ה-verdict; להחזיק את ה-`top-24` תואם ל-`opening.words` של הבדיקה הקיימת. (ה) `_diveVersion`-bump נשמר ב-`_pushStep` (`:204`).

**3. תקלות צפויות:** (א) **regression בבדיקה הקיימת** — `card_keyboard_screen_test.dart:68-83` עושה `state.verdict as CardAskWords`, `opening.words.first.word`, מקיש על `find.text(firstWord)`, ובודק `answeredAxes` *לא*-מכיל 'דגם'. אם `wordSeeds` מחזיר labels שונים מ-`wordsByFrequency(...).take(kFirstWordCount)`, או אם `_SeedTap` דוחף `axisLabel` שונה מ-`_kOpeningWordAxis`, הבדיקה תישבר. (ב) **שריפת-ציר-דגם** — חייב `seedAxisLabel==kSeedAxisWord=='מילת-פתיחה'` כדי ש-`answeredAxes` לא-יכיל 'דגם' (`card_keyboard_screen_test.dart:82`). (ג) **payload-type drift** — אם משאירים גם `_WordTap` וגם `_SeedTap`, `_onWordTap` צריך לטפל בשניהם; קל לשכוח ענף. (ד) **byte-identity flag-OFF** — `_keysFor` נקרא רק כש-`_live||forceLiveForTest` (build מגודר ב-`:400`), אז flag-OFF ממילא זהה; אבל אם הרפקטור משנה את `CardAskWords` עצמו (ה-verdict), ייתכן שינוי-עקיף.

**4. פתרון:** (א) **לשמור parity מספרי:** או להגדיר `kWordMouthCollapsed==kFirstWordCount`, או לעדכן את הבדיקה במכוון. עדיף: לבנות `wordSeeds` כך שה-top-N שלו זהה ל-`CardAskWords.words` (אותו `wordsByFrequency`, אותו cap) — אז הבדיקה עוברת ללא-שינוי. (ב) `seedAxisLabel=kSeedAxisWord` (אכוף ע"י סדנל-51). (ג) להסיר את `_WordTap` לגמרי ולנתב הכל דרך `_SeedTap` — ענף-אחד, פחות-משטח. (ד) להריץ flag-OFF byte-identity (test קיים `:22-37`).

**5. בדיקות:** עדכון `card_keyboard_screen_test.dart` (אותו קובץ): (1) להחליף את ה-tap-on-`firstWord` כך שעדיין עובר (אם labels זהים — ללא-שינוי). (2) טסט חדש `'opening keys come from wordSeeds (top-24)'` — `final keys = (state as dynamic)...` או דרך `find.byType(WordKeyboard)` לספור 24 מקשים. (3) `'_SeedTap word seeds without burning דגם'` — אחרי tap, `answeredAxes` מכיל `kSeedAxisWord` ולא 'דגם' (שדרוג של `:82`). (4) `card_seed_screen_wiring_test.dart`: tap-זרע→`crumbs.last==seed.displayLabel`.

**6. שיפור:** לאחד את שלושת ה-tap-handlers (`_WordTap`/`_SeedTap`/`_ChipTap`) — כולם דוחפים `NewbieStep` עם predicate; אפשר handler-יחיד שמקבל `(axisLabel, label, predicate)` ו-`_SeedTap`/`_ChipTap` בונים אותו. מקטין את `_onWordTap` (`:309-369`) משלושה-ענפים-כמעט-זהים לאחד+dispatch. פחות-באג, קל-לבדיקה.

**7. ריאלי?:** כן — אטומי. רפקטור פנימי של מסך-יחיד, מגודר-דגל, עם בדיקה-קיימת שתופסת רגרסיה. ההיקף ברור (פה-מילים בלבד; שאר-הפיות ב-58). אין צורך בפיצול.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. **flag-OFF byte-identity** — `card_keyboard_screen_test.dart:22-37` ('renders nothing') חייב להישאר ירוק (build מגודר ב-`:400`, אז OFF=`SizedBox.shrink`, לא-מושפע). חבילת-`card_keyboard` מלאה ירוקה. רגרסיה: ה-flow flag-ON (`:39-123`) עובר ללא-שינוי-התנהגותי (אותם 24 מקשי-פתיחה, אותו crumb, אותו אי-שריפת-דגם). אין-leak: `_SeedTap` הוא `const`-data, ה-state כבר `autoDispose` (ראה `card_keyboard_state.dart`).

**9. תכנון נוסף (שלי):** **לשמר את `_predicateFor`-replay-stability** — `card_keyboard_screen.dart:189-200` משחזר predicate-של-chip מ-`(axisId,value)` DATA (לא closure לכוד), כדי שיהיה replay-stable (build-plan §2 #19). אבל `_SeedTap` נושא `seedPredicate` כ-**closure לכוד**. זה מפר את עיקרון ה-replay-from-data. לתכנן: ה-`CardSeed` צריך לשאת מספיק-DATA (`mouthId`+`value`) לשחזר את ה-predicate, או לתעד מפורשות שזרעי-פתיחה אינם נדרשים replay-stable (כי הם לא נשמרים/serializ). החלטה זו חסרה בצעד.

**10. תכנון נוסף (שלי):** למדוד שהמעבר ל-`wordSeeds` לא שובר את ה-`_busy` debounce (`:118-120`,`:313-315`) — הרפקטור מוסיף ענף-tap; לוודא שכל ענף עדיין יוצא-מוקדם תחת `_busy` (double-tap לא-דוחף-פעמיים). להוסיף טסט double-tap-on-seed שמוודא step-יחיד.

---

### שלב 57 — chrome מחליף-פיות (טאבים שווים בפתיחה)

**1. יעד:** בפתיחה (stack ריק) המסך מציג שורת-`segments`/טאבים מעל ה-`WordKeyboard` — פה אחד לכל מקור-זרע (מילים · חומר · עבודה · קטגוריה, ובהמשך טקסט/קול/AI), כולם **שווים**. הקשה על טאב **מחליפה את המקשים במקום** (drill, בלי step-בצלילה) — עקבי עם עיקרון-הזיכרון "לחיצת-כלי ממירה את המקלדת במקום". אחרי השלב: ה-chrome נעלם ברגע שהצלילה התחילה (אחרי זרע ראשון), כך שטאבים מופיעים רק בפתיחה.

**2. איך בונים:** (א) state חדש ב-`_CardKeyboardScreenState`: `CardMouthId _activeMouth = CardMouthId.words;` (enum/קבוע של 4-6 פיות). (ב) ב-`build` (`:396`), כש-`stack.isEmpty` (פתיחה), לרנדר מעל ה-`WordKeyboard` שורת-`SegmentedButton`/`Row` של `ChoiceChip`-ים, אחד לכל פה, `selected: _activeMouth==id`, `onSelected: (_)=>setState(()=>_activeMouth=id)`. (ג) `_keysFor(CardAskWords)` נעשה תלוי-`_activeMouth`: `switch(_activeMouth){ words=>wordSeeds..., material=>materialSeeds(kDivePool)..., job=>jobSeeds()..., category=>categorySeeds()... }` (החיווט המלא ב-58; פה רק ה-chrome+state). (ד) **כשהצלילה לא-ריקה** (אחרי זרע), לא-לרנדר את הטאבים (`if (stack.isEmpty) ...segments`). (ה) **לא** ל-bump `_diveVersion` בהחלפת-טאב — זה לא-צעד-צלילה, רק מקור-מקשים; ה-verdict בפתיחה הוא תמיד `CardAskWords` (אך המקשים מוחלפים).

**3. תקלות צפויות:** (א) **memo-stale** — `verdict` ממומֵז על `_diveVersion` (`:144-152`). אם החלפת-טאב לא-משנה את ה-verdict (תמיד `CardAskWords` בפתיחה) אבל *כן* משנה את ה-keys, ו-`_keysFor` נקרא מתוך `build` עם ה-verdict הממומֵז — ה-keys לא-יתעדכנו אלא-אם `setState` מפעיל rebuild. צריך `setState` בהחלפה (יש), אבל לוודא ש-`_keysFor` קורא את `_activeMouth` הטרי ולא ערך-ממומֵז. (ב) **`showUtilityRow:false`** (`:454`) — ה-`WordKeyboard` כבר מסתיר את שורת-הכלים הדיפולטית; הוספת-segments-משלנו לא-תתנגש, אבל צריך לוודא שהיא לא-מופיעה מתחת-לטאבים פעמיים. (ג) **RTL/responsive** — 4-6 טאבים ב-360px (מובייל) עלולים לגלוש; הזיכרון מתעד `BsKbScale`/responsive 30/19. (ד) **דגל-OFF** — הטאבים בתוך ה-build המגודר (`:400` early-return), אז OFF=כלום; בטוח.

**4. פתרון:** (א) `setState` ב-`onSelected` + לוודא `_keysFor` נקרא *אחרי* קריאת `_activeMouth` ב-`build` (לא ב-getter ממומֵז). אם צריך — לא-למַמֵז את `_keysFor`, רק את `verdict`. אופציה נקייה: לרנדר את ה-keys ישירות מ-`_activeMouth` בפתיחה, ולעקוף את `_keysFor(CardAskWords)`. (ב) לוודא `showUtilityRow:false` נשאר. (ג) `LayoutBuilder`/`Wrap` + `SingleChildScrollView` אופקי לטאבים תחת-360px (עקבי עם responsive שבזיכרון); או אייקון-בלבד (אמוji) ללא-טקסט במובייל. (ד) flag-OFF test קיים מכסה.

**5. בדיקות:** `test/features/card_keyboard/card_mouth_chrome_test.dart` (flag-ON, `forceLiveForTest:true`): (1) `'פתיחה מציגה N טאבי-פיות'` — `find.byType(ChoiceChip)`/`SegmentedButton` findsNWidgets(4). (2) `'tap material מחליף-מקשים בלי-step'` — לפני: `crumbs` ריק; tap-טאב-'חומר'; אחרי: `crumbs` עדיין-ריק (לא-צעד), אך `find.text('נחושת')` מופיע (מקשי-חומר). (3) `'הטאבים נעלמים אחרי זרע'` — tap-זרע→`find.byType(ChoiceChip) findsNothing`. (4) `'flag OFF: אין טאבים'` (מורחב מ-`:22-37`). (5) `'360px: אין overflow'` — `tester.binding.window.physicalSizeTestValue` 360 → `expect(tester.takeException(), isNull)`.

**6. שיפור:** להגדיר את רשימת-הפיות+אמוji+label כ-`const kCardMouths` (כמו `kCardMouths` שב-P3 שלב 26) במקום inline-switch — מקור-אחד שגם ה-chrome (57), גם החיווט (58), וגם מפקד-60 קוראים. מבטל סחיפה בין "אילו פיות קיימות" בשלושה-מקומות.

**7. ריאלי?:** כן — אטומי, אך תלוי-58 לחיווט-המלא. כפי-שמנוסח (chrome+state-בלבד, החלפת-מקשים) הוא בר-בדיקה לבד (טאב-חומר מציג מקשי-חומר). הסיכון היחיד (memo-vs-keys) נתפס בבדיקה (2). אין צורך בפיצול, אבל **חייב לבוא לפני 58** (התלות נכונה בצעד).

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF byte-identity: build מגודר ב-`:400` → OFF=`SizedBox.shrink`, אפס-טאבים (בדיקה 4). חבילת-`card_keyboard` ירוקה. רגרסיה: ה-flow flag-ON הקיים (`:39-123`) — פתיחה עדיין מציגה `WordKeyboard` עם מקשי-מילים (טאב-ברירת-מחדל=words), אז `opening.words.first` עדיין עובד. responsive: snapshot 360+800 ללא-overflow. אין-leak: `_activeMouth` הוא enum-state, אין-stream/controller.

**9. תכנון נוסף (שלי):** **שימור-טאב חוצה-back** — כשהמשתמש עושה `_popStep` (`:216`) חזרה לפתיחה (stack שוב-ריק), `_activeMouth` צריך לחזור לערך-סביר (words? או הטאב-האחרון?). הצעד לא-מגדיר. כדאי: לאפס ל-`words` ב-`_restart` (`:226`) אך לשמר ב-`_popStep`-לפתיחה — אחרת המשתמש מאבד הקשר. החלטה זו חסרה.

**10. תכנון נוסף (שלי):** a11y לטאבים — הצעד מוסיף `segments` אך `card_keyboard_screen` כבר משקיע ב-Semantics (header `liveRegion:true` ב-`:429`, `semanticLabel` למקשים ב-`:273`). הטאבים צריכים `Semantics(selected:..., label:'פה: חומר')` + הכרזת live-region בהחלפה, אחרת קורא-מסך לא-יודע שהמקשים התחלפו. עקבי עם דוקטרינת-ה-a11y הקיימת במודול.

---

### שלב 58 — חיווט פיות חומר+עבודה+קטגוריה ל-`_keysFor`/`_onWordTap`

**1. יעד:** ארבע-פיות-הלחיצה מחווטות מלא: `_keysFor` בונה מקשי-`_SeedTap` ממקור-הזרע של הפה-הפעיל (`materialSeeds`/`jobSeeds`/`categorySeeds`/`wordSeeds`), ו-`_onWordTap` דוחף `NewbieStep` מה-`CardSeed`. **חומר וקטגוריה משאירים ציר-פתוח** (sentinel-axisLabel נבדל), כך ש'נחושת'→ציר-החומר במיזוג נשאר UNANSWERED (שלב 9/31). אחרי השלב: לחיצה על כל-פה זורעת נכון ומתחילה צלילה דרך אותה שדרת-`mergedKeys`.

**2. איך בונים:** (א) להשלים את ה-`switch(_activeMouth)` ב-`_keysFor` (שהחל ב-57) כך שכל-פה ממפה ל-`List<CardSeed>`→`List<WordKey>` עם `_SeedTap`+`semanticLabel`+`axisGlyph`. (ב) להוסיף ל-`_glyphForAxis` (`:239`) או למפת-אמוji-נפרדת אייקון לכל-פה (material→`category_outlined` כבר קיים, job→חדש, category→חדש). (ג) `_onWordTap`-`_SeedTap`-branch (משלב 56) כבר דוחף `axisLabel:seed.seedAxisLabel` — כיוון שזרעי-חומר/קטגוריה נושאים `kSeedAxisMaterial`/`kSeedAxisCategory` (≠'חומר'/אף-ציר), הציר נשאר פתוח **אוטומטית** (אין קוד-מיוחד; זו עוצמת ה-sentinel מ-51). (ד) **emoji בכרטיס-המקש** — `WordKey` אין-לו שדה-emoji (`word_keys_model.dart`: יש `label`,`imageAsset`,`semanticLabel`,`axisGlyph`). להחליט: אמוji כ-prefix ב-`label` ('🟠 נחושת') או דרך `axisGlyph` (IconData, לא-emoji). (ה) זרעי-עבודה (`jobSeeds`) — `seedAxisLabel:kSeedAxisJob`; אין ציר-עבודה ב-`sourcesFor` אז ממילא לא-שורף; אך הזרע-עצמו צריך לזרוע נכון (assembleKit-skus).

**3. תקלות צפויות:** (א) **שריפת-ציר-חומר** — אם בטעות `materialSeeds` משתמש ב-`MaterialSignal.axisName='חומר'` כ-`seedAxisLabel`, ה-step יסמן 'חומר' answered, `_mergedChips:229` ידלג על ציר-החומר, והבדיקה ('נחושת'→'חומר' UNANSWERED) תיכשל — **סתירת-P3/P7 חוזרת**. (ב) **WordKey חסר-emoji** — ה-`CardSeed.emoji` לא-מוצג כי `WordKey` לא-תומך-emoji; הפיות נראות חסרות-זהות-ויזואלית. (ג) **`_predicateFor` לא-רלוונטי לזרעים** — `_predicateFor` (`:189`) משחזר predicate מ-`(axisId,value)` עבור `_ChipTap`; זרעי-פתיחה נושאים closure ישיר (`seedPredicate`), מסלול-נפרד — לוודא ש-`_SeedTap`-branch לא-קורא בטעות ל-`_predicateFor`. (ד) **memo** — אחרי tap-זרע, `_pushStep`→`_diveVersion++`→memo-מתחדש; אבל החלפת-*טאב* (57) לא-bump; לוודא שאחרי-זרע ה-verdict הוא כבר MergedKeys/ShowProducts (מסלול-רגיל).

**4. פתרון:** (א) `kSeedAxisMaterial`/`kSeedAxisCategory` נבדלים (אכוף 51) — ובדיקה מפורשת (5). (ב) להוסיף emoji כ-prefix ל-`label` ב-מקש-זרע: `WordKey('${seed.emoji} ${seed.displayLabel}', ...)` — **אבל זה שובר** את `find.text(seed.displayLabel)` של הבדיקות; לכן עדיף שדה-`leadingEmoji` חדש ב-`WordKey` (אדיטיבי, default-null=byte-identical, כמו ש-`axisGlyph`/`imageAsset` נוספו, `word_keys_model.dart:26-42`), והטקסט נשאר נקי. (ג) לוודא `_SeedTap`-branch משתמש ב-`payload.seed.seedPredicate` ישירות. (ד) לבדוק ש-`_diveVersion` נכון אחרי-זרע.

**5. בדיקות:** `test/features/card_keyboard/card_mouth_wiring_test.dart` (flag-ON): (1) `'material→חומר unanswered'` — tap-טאב-חומר, tap-מקש-'נחושת'; `expect(answeredAxes, contains(kSeedAxisMaterial)); expect(answeredAxes, isNot(contains('חומר')))` — וה-`verdict` הבא עדיין מציע ציר-חומר אם רלוונטי. (2) `'job seeds open recipe pool'` — tap-עבודה→'סיפון', `crumbs.last=='סיפון לכיור רחצה'`, ה-pool מסונן מכיל את אביזרי-`assembleKit`. (3) `'category seeds narrow by categoryHe'` — tap-קטגוריה, מקש-קטגוריה→`verdict` pool כולו `categoryHe==X`. (4) `'each mouth seeds, none NPE'`. (5) flag-OFF byte-identity (קיים `:22`).

**6. שיפור:** ה-`switch(_activeMouth)` ב-`_keysFor` משכפל את ה"איזה-מקור-לכל-פה". להחליפו ב-`CardMouth.seedFor(pool)` polymorphic (כמו seam ה-`CardMouth` שב-P3 שלב 25/26) — כל פה יודע לזרוע-את-עצמו, וה-screen רק קורא `activeMouth.seedFor(...)`. מבטל את ה-switch ומאחד עם 57.

**7. ריאלי?:** כן — אטומי, אך **תלוי נכון ב-53+54+55+57** (כל המקורות + ה-chrome). זהו "שלב-החיווט" שמחבר את ארבעת-המקורות הטהורים ל-UI. ההיקף ברור. אין צורך בפיצול, אבל הוא הצומת שבו כל באג-מקור (53/54/55) יתגלה ראשונה — אז סדר-התלות קריטי.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. **flag-OFF byte-identity** — אם הוספנו `leadingEmoji` ל-`WordKey`, חייב default-null + בדיקה ש-`word_finder` החי זהה-בייטים (הזיכרון מתעד שזו מלכודת: golden של `word_finder`). חבילת-`card_keyboard` + `word_finder` (כולל `word_keyboard_test`/`word_finder_screen_test`) ירוקות. הבדיקה (1) היא הווידוא לאי-שריפת-הציר (הסתירה-ההיסטורית). אין-leak.

**9. תכנון נוסף (שלי):** **dedup חוצה-פיות בזריעה** — אם המשתמש מקיש 'נחושת' (חומר) ואז הצלילה ממשיכה, ייתכן שמקש-מילה 'נחושת' יופיע שוב במיזוג (כפילות). לוודא שזרע-פה אחד לא-יוצר ציר-מיזוג מיותר שמציג את אותו-ערך. הצעד לא-מתייחס לאינטראקציה בין-פיות-במורד-הצלילה.

**10. תכנון נוסף (שלי):** **טיפול ב-pool-ריק אחרי-זרע** — זרע-קטגוריה/חומר שמסנן-לריק (קטגוריה-רפאים, או חומר ללא-מוצרים אחרי-חיתוך) צריך לנחות ב-`_buildEmptyState` (`:375`) ולא ב-crash. הצעד מחווט-זריעה אך לא-מבטיח שכל-זרע→pool-לא-ריק; להוסיף assertion/בדיקה שכל מקש-זרע-מוצג מוביל ל-verdict-תקין (לא-`CardShowProducts([])` בלתי-צפוי).

---

### שלב 59 — toggle עוד…/פחות לפה-המילים

**1. יעד:** פה-המילים מקבל כפתור-`עוד…`/`פחות` שמהפך `_wordsExpanded` (state חדש ב-`_CardKeyboardScreenState`), המחליף בין top-24 (מקופל) לזנב-הארוך-המלא (`wordSeeds(expanded:true)`, שלב 52). הכפתור **לעולם לא-זורע** — רק מרחיב/מצמצם את רשת-המילים. אחרי השלב: 'עוד…'→`count==מלא`, 'פחות'→חזרה ל-24.

**2. איך בונים:** (א) state: `bool _wordsExpanded = false;`. (ב) ב-`_keysFor` (פה-מילים בלבד), `wordSeeds(cardKeyboardLexicon, expanded:_wordsExpanded)`. (ג) לרנדר מקש/כפתור-`עוד…` בסוף-רשת-המילים (רק כש-`_activeMouth==words && !stack.isEmpty`? לא — בפתיחה), `onTap:()=>setState(()=>_wordsExpanded=!_wordsExpanded)`, label דינמי 'עוד…'/'פחות'. (ד) **לא** דרך `_SeedTap` (זה לא-זרע) — payload נפרד `_ToggleWordsTap` או טיפול-מיוחד ב-`onWordTap`, או כפתור נפרד מחוץ-ל-`WordKeyboard`. (ה) **לא** ל-bump `_diveVersion` (לא-צעד-צלילה). (ו) להציג 'עוד…' רק כשיש זנב (`full.length>24`).

**3. תקלות צפויות:** (א) **payload-collision** — אם מממשים 'עוד…' כ-`WordKey` עם payload, `_onWordTap` חייב ענף-נוסף; קל לבלבל עם `_SeedTap`. (ב) **`representativeTake` לא-רלוונטי כאן** — שלא כמו ציר-גודל במיזוג (`card_engine.dart:282-293`), פה-המילים מקופל ב-`take(24)` פשוט (frequency-ordered, top-N הוא-הנכון, כפי שמתועד `:289-290`). אם בטעות נשתמש ב-`representativeTake` למילים, נקבל דגימה-מפוזרת במקום top-24 → מילים-נדירות יוצגו והשכיחות-יוסתרו. (ג) **memo** — כמו 57, החלפת-`_wordsExpanded` משנה keys לא-verdict; צריך `setState`+`_keysFor` טרי. (ד) **double-tap על 'עוד…'** — `_busy` (`:118`) חוסם tap-שני; אבל 'עוד…' הוא toggle, לא-צעד — לוודא שהוא לא-נחסם-לרעה (toggle כפול = חזרה, לא-נזק).

**4. פתרון:** (א) payload-type `_ToggleWordsTap extends _Tap` עם ענף-`onWordTap` שעושה רק `setState(_wordsExpanded=!)` ו-`return` (לא-`_pushStep`). או — נקי יותר — כפתור-`TextButton` נפרד מתחת-ל-`WordKeyboard` (כמו ה-`_restart` ב-`:390`), מחוץ-למסלול-המקשים. (ב) פה-מילים: `chips.take(N)` רגיל (לא-`representativeTake`) — תיעוד מפורש. (ג) `setState`+`_keysFor` קורא `_wordsExpanded` טרי. (ד) ה-toggle לא-תחת-`_busy` (זה לא-tap-מקש-זרע) — או, אם תחת `WordKeyboard`, לוודא ש-double-toggle בטוח.

**5. בדיקות:** `test/features/card_keyboard/card_words_toggle_test.dart` (flag-ON): (1) `'עוד…→count==מלא'` — לספור מקשי-מילים לפני (24), tap-'עוד…', אחרי==`wordSeeds(expanded:true).length`. (2) `'פחות→חזרה ל-24'` — toggle-כפול חוזר ל-24. (3) `'עוד… לעולם לא-זורע'` — אחרי-toggle, `crumbs` עדיין-ריק, `verdict` עדיין `CardAskWords`. (4) `'עוד… מוסתר כשאין-זנב'` — אם `full.length<=24` הכפתור לא-מופיע (mock-lexicon קצר, או skip). (5) `'top-24 הוא frequency-top לא-representative'` — ה-24 הם ה-prefix של ה-full, לא-מדגם-מפוזר.

**6. שיפור:** במקום בינארי עוד/פחות, אינקרמנטלי (24→48→הכל) או virtualized-scroll — אבל זה over-engineering לפתיחה. שיפור-אמיתי: לקשור את ה-toggle ל-`kWordMouthCollapsed` קבוע-יחיד (גם 52 גם 59 קוראים אותו), ולגזור 'עוד…'-visibility מ-`full.length>kWordMouthCollapsed` — מקור-אחד, אין-magic-24.

**7. ריאלי?:** כן — אטומי וקטן. toggle-state בודד + render-מותנה. בדיקות ישירות. אין צורך בפיצול. תלוי-נכון ב-52 (מקור עוד/פחות) ו-56 (רשת-המסך).

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. flag-OFF: build מגודר → אין-toggle. חבילת-`card_keyboard` ירוקה. רגרסיה: פתיחה ברירת-מחדל עדיין 24-מקשים (toggle=false), `opening.words.first` עובד. אין-leak: `_wordsExpanded`=bool-state. הבדיקה (3) — 'לעולם לא-זורע' — היא הווידוא ל-invariant-הצעד.

**9. תכנון נוסף (שלי):** **איפוס `_wordsExpanded` בהחלפת-טאב** — אם המשתמש הרחיב מילים ואז עבר לטאב-חומר וחזר, האם המילים עדיין-מורחבות? כדאי לאפס ל-collapsed בכל החלפת-פה (57) — אחרת state-נסתר מבלבל. הצעד (וגם 57) לא-מגדיר את האינטראקציה בין `_activeMouth` ל-`_wordsExpanded`.

**10. תכנון נוסף (שלי):** **toggle גם לפיות-עבודה/קטגוריה** — אם `jobSeeds` (30+ מתכונים, שלב 54) או `categorySeeds` (עשרות, שלב 55) ארוכים-מ-cap, הם זקוקים לאותו עוד/פחות. הצעד ממסגר רק פה-מילים; להכליל את ה-toggle ל"כל פה-עם-זנב" (state `Map<CardMouthId,bool> _expanded`) חוסך 3 toggles-נפרדים ושומר עקביות. תואם את הערת-השיפור בשלב 54 (cap+"עוד").

---

### שלב 60 — מפקד-דפדוף-ללא-הקלדה (הישג-עץ-עמוק ≤6, אפס-ידע)

**1. יעד:** קיים **מפקד ממצה** (`card_browse_census_test.dart`) שמוכיח שכל כרטיס ב-`kReachUniverse` נגיש ב-**≤6 לחיצות דרך פיות-הדפדוף בלבד** (קטגוריה-אמוji + עדשה, **בלי טקסט/הקלדה**). זוהי ההוכחה שדפדוף-טהור שורד את פרישת-9-הכלים — משתמש שלא-מקליד-בכלל עדיין מגיע לכל-מוצר. אחרי השלב: census ירוק = כל-כרטיס ≤6 ללא-הקלדה, או allowlist-offenders מצטמצם.

**2. איך בונים:** (א) להגדיר את שרשרת-הדפדוף-הטהורה: זרע-קטגוריה (`categorySeeds`, 55) → `mergedKeys`-turns (size/angle/color/material/facet — *לא* word-typing, אבל chip-word-tap מותר כי זו לחיצה לא-הקלדה) → `CardShowProducts` → בחירה. (ב) המפקד: לכל `card` ב-`distinctProducts(kDivePool)`/`kReachUniverse`, לסמלץ צלילה: התחל מזרע-קטגוריה שמכיל את-הכרטיס; בכל-turn בחר את ה-chip שמשאיר את-הכרטיס ומצמצם-מקסימלית; ספור turns עד `CardResolve`/`CardShowProducts`-שמכיל-את-הכרטיס. (ג) `expect(turns <= kMaxDiveTurns)` (=6; הצעד 67 יהפוך את `kMaxDiveTurns` למקור-יחיד, וצעד-60 *מייבא* אותו — אך 67 אחרי 60 בתוכנית, אז בינתיים קבוע-מקומי `const _kMaxBrowseTurns=6` עם TODO-לאיחוד). (ד) להשתמש ב-`mergedKeys`/`_mergedChips` הקיימים (לא-לשכפל) — לסמלץ tap דרך `src.matches`. (ה) allowlist ל-offenders-ידועים (כמו census קודמים במודול).

**3. תקלות צפויות:** (א) **מסלול לא-ממצה** — אם `categorySeeds` (55) לא-מכסה-100% (יתום), המפקד נכשל על הכרטיס-היתום — זו בעצם הבדיקה הנכונה, אבל תלויה-קריטית בשלב-55 שעבד. (ב) **word-typing מעורבב** — הצעד דורש 'בלי-הקלדה'; אם הסימולציה נופלת ל-chip-מסוג-word, זה *לחיצה* (מותר) אך אם היא מסתמכת על `resolveWord(טקסט-חופשי)` זה הקלדה (אסור). לוודא שהמסלול עובר רק chips פולטים מ-`_mergedChips`. (ג) **>6 אמיתי** — קטגוריה-ענקית (HDPE, 120 מוצרים) עם ציר-מפצל-חלש עלולה לדרוש >6 turns → census-fail אמיתי שחושף פגם-עומק-עץ. (ד) **בחירת-chip greedy לא-אופטימלית** — greedy "צמצם-מקסימלית" עלול לפספס מסלול-קצר-יותר; ה-census צריך BFS/אופטימום, לא-greedy, אחרת false-negative. (ה) **עלות-חישוב** — census על כל-כרטיס × כל-turn × `distinctCardCount` יקר; עלול לחרוג מ-timeout-טסט (הזיכרון מתעד מלכודת isolate-crash/Defender; ה-retry-wrap ב-gate).

**4. פתרון:** (א) להריץ את census *אחרי* שבדיקת-כיסוי-55 ירוקה (תלות-נכונה: 60 תלוי-55). (ב) להגביל את הסימולציה ל-chips מ-`mergedKeys` בלבד (כולל word-chip = לחיצה, *לא* TextField) — לתעד שזו "לחיצה לא-הקלדה". (ג) offenders אמיתיים → allowlist *מצטמצם* + issue לחיזוק-ציר (לא-להסתיר). (ד) **BFS** על גרף-המצבים (לא-greedy): מצב=pool-מסונן; קשת=chip-tap; מצא מרחק-מינימלי עד pool-שמכיל-את-הכרטיס-ו-`<=threshold`. (ה) `taskkill dart` לפני, retry-wrap לכשלי-טעינה (דוקטרינת-הזיכרון), `c=1` במידת-הצורך; לעולם-לא-`tail`.

**5. בדיקות:** `test/features/card_keyboard/card_browse_census_test.dart`: (1) `'כל כרטיס ≤6 דרך קטגוריה-אמוji בלי-הקלדה'` — הלולאה-הממצה לעיל; `for (card in kReachUniverse) expect(browseDepth(card) <= 6)`. (2) `'דפדוף שורד פרישת-כלים: union-קטגוריה==100%'` — תלות מ-55, מאומת שוב כאן (כל-כרטיס נגיש מ-זרע-כלשהו). (3) `'אפס-ידע: המסלול לא-קורא resolveWord(freetext)'` — assertion-מבני שהסימולציה משתמשת רק ב-`_mergedChips`/`categorySeeds`. (4) `'offenders ⊆ allowlist מצטמצם'` — אם יש חורגים, רשימה-מפורשת קטֵנה. (5) `'BFS-optimal לא-greedy'` — מקרה-בקרה שבו greedy>6 אך BFS≤6.

**6. שיפור:** למזג את census-60 (דפדוף-ללא-הקלדה) עם census-42 (טקסט/קטגוריה/חומר, P4) ועם census-69 (מוח-ממצה, P7) לתשתית-census-אחת פרמטרית (`censusReach(mouths, maxTurns)`) — שלושתם מודדים "כל-כרטיס ≤6 דרך X". מקור-אחד מונע סחיפה ב-`kMaxDiveTurns` ובהגדרת-היקום, ומקל על שלב-100 (השער-המרכזי).

**7. ריאלי?:** **בגבול-העליון — שוקל פיצול.** המפקד-עצמו אטומי-במהותו (assertion-אחת), אבל הוא תלוי בשלשה (55+58+42) *ועובד*, וה-BFS-הממצה על כל-היקום הוא רכיב-לא-טריוויאלי. אם ה-BFS-engine עוד-לא-קיים, כדאי לפצל: 60a = `browseDepth(card)` BFS-engine טהור (בר-בדיקה לבד על דוגמאות); 60b = ה-census-הממצה שמריץ אותו על כל-היקום. כפי-שמנוסח, השלב מניח שה-engine-וההרצה יחד — סביר רק אם BFS פשוט.

**8. וידוא-פיקס מלא:** `analyze`=0-חדש. **זהו census-בדיקה-בלבד — אפס-קוד-פרודקשן** → flag-OFF byte-identity טריוויאלית (לא-נגענו בשום-מקור). להריץ עם `taskkill dart` קודם + retry-wrap (הזיכרון: כשלי-טעינת-isolate לסירוגין, לא-זיכרון). הווידוא-האמיתי: ה-census **ירוק על כל kReachUniverse כולל 81 מים-חמים** (`dive_pool.dart:49`) — אם offenders, הם ב-allowlist-מפורש-מצטמצם, לא-מוסתרים. אין-leak (טהור). רגרסיה: כל חבילות-המודול ירוקות (census לא-משנה-מקורות).

**9. תכנון נוסף (שלי):** **census-≤4-קליקים-בין-פיות במקביל ל-≤6-לכרטיס** — החוזה הוא ≤6-שאלות *וגם* ≤4-לחיצות-בין-שני-מוצרים. שלב-60 מוכיח ≤6-דרך-דפדוף, אך ≤4-בין-מוצרים שייך ל-P8 (גרף-קפיצה, 80). כדאי שהמפקד-הזה יתעד מפורשות שהוא מכסה רק את חצי-החוזה (≤6-הגעה), כדי שלא-תהיה אשליית-כיסוי-מלא; ולהוסיף cross-reference ל-80. הצעד לא-מבהיר את הגבול.

**10. תכנון נוסף (שלי):** **regression-snapshot של עומק-הדפדוף** — לא-רק `<=6` (boolean) אלא לשמור היסטוגרמת-עומק (כמה-כרטיסים ב-2/3/4/5/6 turns). שינוי-עתידי בפיות (53/54/55) עלול להחמיר עומק *בלי* לחצות-6; snapshot תופס רגרסיה-איכותית מוקדם (כרטיס שעבר מ-3 ל-5 turns). תואם את רוח-ה"baseline" של שלב-1/72 (snapshot-כקלט-עיצוב).

</div>

<div dir="rtl">

# פירוק-משנה: שלבים 61–70 (סוף P6 + כל P7 — "המוח-הממוזג")

> מעוגן ב-`C:/Users/User/Desktop/benzi-kb-build/app_flutter`. המנוע החי = 6 קבצים תחת `lib/features/card_keyboard/` (`card_engine.dart`, `card_signals.dart`, `card_soft.dart`, `card_keyboard_screen.dart`, `card_keyboard_flag.dart`, `card_keyboard_state.dart`) — פאזות 0–5 של #38 כבר נבנו.
>
> **עובדת-יסוד שמכתיבה הכול:** סריקת-קוד אישרה ש**אף אחד מהסמלים של P7 עדיין לא קיים** — אין `kMaxDiveTurns`, אין `kReachUniverse`, אין `seedPool`/`PoolSeed`, אין `CardSeed`/`card_seed.dart`, אין `_scoreAxis`, אין `kOpeningSeedAxis`, ואין golden-טקסט ל-`_mergedChips`. ה-goldens שבריפו הם תצלומי-widget מסוג PNG (`matchesGoldenFile`, ראו `test/smart_input/dive/dive_demo_golden_test.dart`), **לא** goldens של ערך/טקסט. לכן שלבים 61–70 **בונים** את הסמלים האלה; ההפניות בתוכנית ל"golden זהה-לשלב-11/64" הן אנכּוֹר שייווצר תוך-כדי, לא קובץ קיים.
>
> כל המספרים/הזהויות מתוך הקוד האמיתי: `_mergedChips` ב-`card_engine.dart:217–297`; `kMergedKeyCap=10`, `kMergedAxisFloor=2`, `kMergedAxisMaxPerAxis=4` (`card_engine.dart:173–175`); `kShowProductsThreshold=12`, `kShowProductsCap=30` (`word_finder_engine.dart:210,218`); דירוג-הצירים ב-cross-multiply שלם (`card_engine.dart:267–272`); `SignalChip.infoGain` ברירת-מחדל `0` ולעולם לא מאוכלס (`card_engine.dart:49`); סולם-הוורדיקט inline ב-`mergedKeys` (`card_engine.dart:155–170`).

---

### שלב 61 — fuzz דטרמיניזם/טוהר למקורות-זרע + שמירת-ציר-נבדל

**1. יעד:** אחרי השלב קיים קובץ-בדיקות יחיד `card_seeds_invariants_test.dart` שמוכיח ש**כל** מקורות-הזרע של P6 (רשת-מילים/חומר/עבודה/קטגוריה-אמוji משלבים 52–55 + 58–59) **דטרמיניסטיים תחת shuffle** ושומרים **טוהר** (אין IO/clock/Random), וש**ציר-החומר/קטגוריה נשאר נבדל** (זרע שאינו מסמן axis-answered). מה שלא היה אמת קודם: עד עכשיו רק `_mergedChips` נבדק ל-shuffle-stability (`card_engine_test.dart:92`); מקורות-הזרע של הפיות (שעדיין צריכים להיבנות ב-51–60) חסרי-מעטפת-fuzz אחת מאחדת. **הערה ריאלית:** שלב זה תלוי ב-58/59/60 שטרם נבנו בקוד — אז כשהוא יגיע, ה-`CardSeed`/`wordSeeds`/`categorySeeds` כבר יהיו קיימים; כרגע הם לא.

**2. איך בונים:** (א) להוסיף `test/features/card_keyboard/card_seeds_invariants_test.dart`. (ב) לכל מקור-זרע: `for (final seed in [1,7,42,99,1234]) { final shuffled = [...kDivePool]..shuffle(Random(seed)); expect(key(seedSource.seedsFor(shuffled)), want); }` — בדיוק האידיום מ-`card_engine_test.dart:112–116`. (ג) טוהר: לוודא שאין import של `dart:io`/`dart:math Random`/`DateTime` בקבצי-המקור (בדיקת-מקור סטטית, כמו `catalog_static_guard_test.dart`). (ד) שמירת-ציר: לבנות זרע-חומר על בריכת-נחושת ולוודא ש-`seedStep.axisLabel != MaterialSignal.axisName('חומר')` (כלומר הזרע אינו "עונה" על ציר-החומר), בהקבלה ל-`_kOpeningWordAxis='מילת-פתיחה'` ב-`card_keyboard_screen.dart:51`.

**3. תקלות צפויות:** (א) **תלות-קדימה לא-בנויה** — אם 52–60 לא הושלמו, הקובץ לא יתקמפל (אין `CardSeed`/`wordSeeds`). (ב) **ציר-המילים order-sensitive** — `wordOptions` (`narrow_axis.dart:58–80`) משתמש ב-`counts` LinkedHashMap עם `take(12)` לפי סדר-הבריכה ו-`sort` לא-יציב על שוויון-ספירה; זרע-מילים ינסה shuffle-stability וייכשל בדיוק כמו שתועד ב-`card_signals.dart:157–164` (התיקון שם: sku-sort). (ג) **`materialOf` תלוי-בריכה** — `MaterialSignal.seededFraction` (`card_signals.dart:200`) מחושב מחדש לכל בריכה, אז shuffle לא משנה אותו, אבל אם זרע-החומר מסנן top-N הוא עלול להיות order-sensitive. (ד) **flag-race לא רלוונטי כאן** (טהור), אבל אם מישהו יקרא `featureFlagsProvider` בתוך מקור-זרע — לכלוא.

**4. פתרון:** (א) לסמן את 61 כתלוי-קשיח ב-58/59/60 (כבר רשום בתוכנית) — לא להריץ לפני. (ב) להעביר לכל מקור-מילים בריכה קנונית sku-ממוינת לפני `wordOptions`, בדיוק כמו `WordSignal.chipsFor` (`card_signals.dart:164`: `[...pool]..sort((a,b)=>a.sku.compareTo(b.sku))`). (ג) זרע-חומר ישתמש ב-`materialsInPool` (כבר דטרמיניסטי, `material_lexicon.dart:95`) ולא ב-top-N-לפי-תדירות. (ד) בדיקת-מקור סטטית ש-import-set של 6 קבצי-card_keyboard ⊆ allowlist טהור.

**5. בדיקות:** `card_seeds_invariants_test.dart`: (1) `'every seed source is byte-stable under shuffle seeds [1,7,42,99,1234]'` — מאסר על `key()` קבוע. (2) `'material/category seed never answers its own axis'` — `seedStep.axisLabel ∉ {'חומר', אמוji-axis}`. (3) `'seed sources import no IO/Random/clock'` — סורק את source-text של הקבצים. (4) `'shuffle-stable ALSO for the word seed (sku-sorted)'` — בנפרד, כי זה ה-edge שנשבר.

**6. שיפור:** במקום 4 לולאות-shuffle נפרדות לכל מקור — helper פרמטרי יחיד `void assertShuffleStable<T>(List<T> Function(List<LipskeyCatalogProduct>) f, String label)` שמופעל פעם לכל מקור; חוסך כפילות וקובע שהאידיום זהה בכל המקורות (פחות סחף-בדיקה).

**7. ריאלי?:** אטומי ובר-בדיקה **בתנאי ש-58–60 נבנו** — שלב-בדיקות טהור ללא קוד-מוצר חדש. אם 58–60 עדיין לא קיימים (כפי שכרגע בקוד), 61 **חסום** ולא ניתן להרצה; אין צורך לפצל אותו עצמו.

**8. וידוא-פיקס מלא:** `flutter analyze` = 0-new; להריץ את החבילה החדשה ירוקה + להריץ-מחדש את כל `test/features/card_keyboard/` (4 הקבצים הקיימים) כדי לאשר אפס-רגרסיה; אין flag-OFF byte-identity לבדוק כאן (טהור, מאחורי-דגל ממילא), אבל לאשר ש-`card_keyboard_screen_test.dart` "flag OFF → renders nothing" עדיין עובר.

**9. תכנון נוסף (שלי):** להוסיף בדיקת **idempotence** — `seedsFor(pool)` שנקרא פעמיים על אותה בריכה מחזיר רשימה שווה-ערך (לא רק shuffle-stable). מגן מפני state נסתר במקור-זרע (caching שגוי).

**10. תכנון נוסף (שלי):** בדיקת **disjoint-sentinel** — `CardSeed` של פיות שונות נבדלים זוג-זוג (כפי שהתוכנית מבטיחה ב-51 "sentinels זוג-זוג נבדלים"), כדי שצירוף-זרעים בעתיד (P10) לא יתנגש; לאסור `seedA.mouthId != seedB.mouthId` לכל זוג.

---

### שלב 62 — חוזה `PoolSeed` + `seedPool()` משפך-מאוחד

**1. יעד:** קיים seam חדש וטהור `seedPool()` + טיפוס `PoolSeed`, שדרכו **כל 6 הפיות** נכנסות לבריכה דרך משפך-אחד, ו-`kOpeningSeedAxis` הוא קבוע **ציבורי** יחיד (מחליף את ה-`_kOpeningWordAxis` הפרטי שב-`card_keyboard_screen.dart:51`). מה שחדש: היום כל פה היה זורע בנתיב-אד-הוק משלו ב-`_onWordTap` (`card_keyboard_screen.dart:318–334` בונה `NewbieStep` ידנית עם `skuSet.contains`); אחרי 62 יש פונקציה-משפך אחת ש-`seedStep` שלה **שומר sku** (הבריכה אחרי-זרע = בדיוק המוצרים שהזרע מיפה).

**2. איך בונים:** (א) קובץ חדש `lib/features/card_keyboard/pool_seed.dart`. (ב) `class PoolSeed { final String axisLabel; final String crumb; final bool Function(LipskeyCatalogProduct) predicate; }`. (ג) `NewbieStep seedPool(PoolSeed s) => NewbieStep(axisLabel: s.axisLabel, chipLabel: s.crumb, crumbWord: s.crumb, predicate: s.predicate)` — עוטף את `NewbieStep` הקיים (`word_finder_engine.dart:57`). (ד) `const String kOpeningSeedAxis = 'מילת-פתיחה';` ציבורי; להחליף את ההפניה הפרטית. (ה) לא לחווט עדיין למסך (זה שלב 68) — רק ה-seam + הבדיקה.

**3. תקלות צפויות:** (א) **כפילות-קבוע** — אם `kOpeningSeedAxis` החדש לא **מחליף** את `_kOpeningWordAxis` אלא מתווסף לידו, יהיו שני קבועים עם אותו ערך-מחרוזת ('מילת-פתיחה') וסיכון-סחף. (ב) **שבירת byte-identity** — `card_keyboard_screen.dart` עדיין משתמש ב-`_kOpeningWordAxis`; אם נמחק לפני 68 הקובץ לא יתקמפל. (ג) **predicate שלא שומר-sku** — אם המשפך מנרמל/מסנן את ה-predicate, הבריכה אחרי-זרע לא תשווה ל-skuSet, ובדיקת "seedStep שומר sku" תיכשל. (ד) `NewbieStep` הוא `const`-friendly (`word_finder_engine.dart:58`) — `seedPool` חייב להישאר טהור, בלי לכידת-context.

**4. פתרון:** (א) להשאיר את `_kOpeningWordAxis` בקובץ-המסך כ-`@Deprecated` המצביע על `kOpeningSeedAxis`, או פשוט לדחות את המחיקה ל-68 (כמו דפוס "מחיקה נדחית" בשלב 17 בתוכנית). (ב) ב-62 **לא לגעת** ב-`card_keyboard_screen.dart` — רק קובץ חדש + טסט; כך אפס שינוי לקובץ-המסך = אפס byte-change. (ג) ה-predicate שעובר דרך `seedPool` הוא identity — `seedPool` רק עוטף, לא ממיר.

**5. בדיקות:** `pool_seed_test.dart`: (1) `'seedPool wraps a PoolSeed into a NewbieStep preserving predicate'` — בונה `PoolSeed` עם `(p)=>skuSet.contains(p.sku)`, מסנן `kDivePool`, מאשר התוצאה == סינון-ידני (שומר-sku). (2) `'kOpeningSeedAxis is the public opening axis label'` — `expect(kOpeningSeedAxis, 'מילת-פתיחה')`. (3) `'seedPool is pure (same input → equal step predicate result)'` — שתי קריאות, אותה תוצאת-סינון.

**6. שיפור:** להוסיף ל-`PoolSeed` שדה `mouthId` כבר עכשיו (גם אם 62 לא משתמש בו), כדי ש-63/68 לא יצטרכו לשנות את החתימה שוב — חוסך migration כפול של הטיפוס.

**7. ריאלי?:** אטומי לחלוטין — קובץ-טהור חדש + 3 בדיקות, אפס-נגיעה במסך. ריאלי וקטן; לא דורש פיצול.

**8. וידוא-פיקס מלא:** `analyze`=0-new; `pool_seed_test.dart` ירוק; **flag-OFF byte-identity:** מכיוון שלא נגענו ב-`card_keyboard_screen.dart`, ה-`card_keyboard_screen_test.dart` ("flag OFF → renders nothing") חייב לעבור ללא שינוי — זו הוכחת אי-הרגרסיה. להריץ-מחדש את כל `test/features/card_keyboard/`.

**9. תכנון נוסף (שלי):** להגדיר את `PoolSeed` עם `operator ==`/`hashCode` (כמו `SignalChip`, `card_engine.dart:81–93`) — כדי ש-63's union/dedup של זרעים יוכל להשתמש ב-`Set<PoolSeed>` בלי כפילויות שקטות.

**10. תכנון נוסף (שלי):** בדיקת **null-safety של זרע-ריק** — `seedPool` עם predicate שמחזיר תמיד-false חייב להחזיר `NewbieStep` תקין (לא לזרוק), כי המסך כבר מטפל ב-`CardShowProducts([])` (`card_engine.dart:168`, `_buildEmptyState` `card_keyboard_screen.dart:375`); לאסור `returnsNormally`.

---

### שלב 63 — כל-הזורעים מעל אותה בריכה (text/material/facet/sku/AI)

**1. יעד:** חמש פונקציות-זרע טהורות — `seedFromText`, `seedFromMaterial`, `seedFromFacetSubtype`, `seedFromSkus`, (וזרע-AI דרך `seedFromText`/literal) — כולן בונות `PoolSeed` **מעל אותה `kDivePool`**, עם **union על מילים מרובות** ו-**`all-unknown → null`** (אין מבוי-סתום). מה שחדש: היום הזריעה היחידה היא `_WordTap` שמשתמש ב-`resolveWord` (`card_keyboard_screen.dart:319`); אין נתיב חומר/facet/sku מאוחד.

**2. איך בונים:** (א) ב-`pool_seed.dart`: `PoolSeed? seedFromText(String q, WordLexicon lex)` — tokenize, `resolveWord` לכל token (`word_finder_engine.dart:528`), **union** של ה-skus, predicate=`skuSet.contains(p.sku)`; `null` אם כל ה-tokens לא ידועים. (ב) `PoolSeed seedFromMaterial(String m)` — predicate=`MaterialSignal().matches` עם null-carry (`card_signals.dart:221–224`), `axisLabel != 'חומר'` (ציר נשאר פתוח). (ג) `PoolSeed? seedFromFacetSubtype(String subtype)` — דרך `kFinderFacets[subtype]` (`narrow_axis.dart:84`). (ד) `PoolSeed seedFromSkus(Set<String> skus)`. (ה) זרע-AI: literal-first דרך `seedFromText` (P5 כבר קבע literal-מקורקע).

**3. תקלות צפויות:** (א) **AND vs union** — אם `seedFromText` עושה AND-חיתוך על tokens מרובים, 'ברז נחושת' עלול להחזיר ריק (מבוי-סתום) כי אף מוצר לא נושא את שתי המילים כ-word-tokens; התוכנית דורשת "multi-word union". (ב) **`materialOf` null-carry סותר ציר-פתוח** — `MaterialSignal.matches` מחזיר true על `m==null` (`card_signals.dart:223`), אז זרע-חומר 'נחושת' שומר את כל ה-unknown; זה **נכון** אבל אומר שהבריכה אחרי-זרע גדולה, וה-`distinctCardCount` עדיין `> 12` → המסך יישאר ב-MergedKeys (לא יקרוס מוקדם). (ג) **`seedFromText` order-sensitive** — `resolveWord` שומר סדר-lexicon (`word_finder_engine.dart:531–536`), אבל union על tokens מרובים תלוי-סדר-tokens; להפוך ל-`Set`. (ד) **facet ריק** — `seedFromFacetSubtype(null)` חייב `null`, אחרת predicate-תמיד-true.

**4. פתרון:** (א) `seedFromText` = **union** מפורש: `final skus = <String>{ for (final t in tokens) for (final p in resolveWord(t, lex)) p.sku };` ואז `if (skus.isEmpty) return null;`. (ב) לתעד ש-null-carry הוא by-design (כמו `card_signals.dart:182–191`) ולבדוק שהבריכה-אחרי-נחושת עדיין נותנת שבבי-חומר (ציר פתוח). (ג) `Set<String>` ל-union → order-independent. (ד) guard מפורש `subtype==null || !kFinderFacets.containsKey(subtype) → null`.

**5. בדיקות:** `pool_seed_test.dart` (מורחב): (1) `'seedFromText multi-word is UNION not AND (no dead-end)'` — 'ברז נחושת' → skuSet ⊇ resolveWord('ברז') ∪ resolveWord('נחושת'), לא-ריק. (2) `'seedFromText all-unknown → null'` — 'qwerty zzz' → null. (3) `'seedFromMaterial keeps null-material carry-along'` — בריכת-נחושת+unknown, ה-unknown שורד. (4) `'seedFromFacetSubtype null/unknown → null'`. (5) `'seedFromSkus filters to exactly those skus'`.

**6. שיפור:** לאחד את חמשת ה-`seedFrom*` תחת enum `SeedKind` + dispatch אחד `PoolSeed? seedFor(SeedKind k, Object arg)` — כך 68 (חיווט-המסך) מקבל נקודת-כניסה אחת במקום 5, ופחות סיכון ש-פה-אחד יישכח לחווט.

**7. ריאלי?:** גבולי-גדול — 5 פונקציות-זרע + union-logic + null-paths. **ממליץ לפצל מנטלית** ל-63a (text+sku, ה-seam הקריטי) ו-63b (material+facet+AI), אם כי כקובץ-בודד טהור זה עדיין בר-בדיקה ביחידה אחת. אטומי-מספיק להישאר שלב-אחד.

**8. וידוא-פיקס מלא:** `analyze`=0-new; חבילת `pool_seed_test` ירוקה; אפס-נגיעה במסך → `card_keyboard_screen_test.dart` עובר ללא-שינוי (byte-identity); regression על כל `card_keyboard/`; לוודא שאין דליפת-Riverpod (הקובץ טהור, אסור import של `flutter_riverpod`).

**9. תכנון נוסף (שלי):** בדיקת **parity חוצת-זורעים** — `seedFromText('נחושת')` ו-`seedFromMaterial('נחושת')` חייבים להחזיר בריכות **חופפות אך לא זהות** (text=word-match, material=null-carry); לתעד את ההפרש בבדיקה כדי שלא ייחשב באג ב-69.

**10. תכנון נוסף (שלי):** **fuzz של 1000+ מחרוזות-קלט** ל-`seedFromText` (כמו שלב 43 מתכנן לפה-הטקסט) שלא-זורק על תווי-RTL/מספרים/ריק — להעביר את ה-fuzz כבר ל-seam הזה, לא רק ל-UI מאוחר יותר.

---

### שלב 64 — golden לפני-מבנה-מחדש (info-gain מאוכלס, סדר לא-משתנה)

**1. יעד:** `SignalChip.infoGain` שהיום **תמיד 0** (`card_engine.dart:49,74`) יאוכלס בערך אמיתי `infoGain = n - distinctCardCount(narrowed)` לכל שבב, **בלי לשנות את סדר השורה**, וייקבע golden-טקסט שמתעד את השורה הזו כעוגן לפני המבנה-מחדש של 66. מה שחדש: שבבים נושאים מדד-תועלת אמיתי (לתצוגה/דירוג עתידי), וקיים golden-ערך ראשון של `_mergedChips`.

**2. איך בונים:** (א) ב-`_mergedChips` (`card_engine.dart:250–255`) כבר מחושב `nc = distinctCardCount(narrowed)` בלולאת-ה-sumSq; להעביר אותו ל-`SignalChip` כ-`infoGain: (n - nc).toDouble()` בעת בניית השבב הסופי. (ב) **קריטי לסדר:** הדירוג (`card_engine.dart:267–272`) משתמש ב-`sumSq`/`n` בלבד, וה-comparator לא נוגע ב-`infoGain` — אז מילוי `infoGain` חייב להשאיר את הסדר זהה-בייטים. (ג) ליצור `card_merge_golden_test.dart` שמדפיס את השורה כ-`'${axisId}:${value}@${infoGain}'|...` ומשווה למחרוזת-golden קבועה (לא PNG).

**3. תקלות צפויות:** (א) **שבירת equality/hashCode** — `SignalChip.==` ו-`hashCode` כוללים את `infoGain` (`card_engine.dart:82–93`)! מילוי `infoGain` משנה את ה-`==` של כל שבב → כל בדיקה שמשווה `SignalChip` שנבנה-בטסט עם `infoGain:0` מול שבב-מנוע תיכשל (למשל `card_engine_test.dart:137` בונה שבבים ידניים עם infoGain מרומז-0). (ב) **shuffle-stability** — `n - nc` תלוי ב-`distinctCardCount` שהוא order-free, אז זה בטוח; אבל אם הסדר-בתוך-ציר משתנה, ה-golden ישבר. (ג) **golden זהה-לשלב-11** (כלשון התוכנית) — שלב-11 golden **לא קיים** (P1 לא נבנה), אז אין למה להשוות; ה-golden כאן הוא חדש-לגמרי.

**4. פתרון:** (א) **לא לכלול `infoGain` ב-`==`/`hashCode`** — או, אם רוצים לשמור עליו ב-equality, לעדכן את כל בוני-השבבים-בטסט לכלול את ה-infoGain הצפוי. ההמלצה: להוציא את `infoGain` מ-`==`/`hashCode` (זה "DISPLAY/coarse tier ONLY", `card_engine.dart:72–74` — לוגית לא חלק מהזהות), ולתעד. (ב) לאשר shuffle-stability על ה-golden עם 5 seeds. (ג) לתקן את ניסוח-התוכנית: ה-golden הוא baseline טרי, לא "זהה-לשלב-11".

**5. בדיקות:** `card_merge_golden_test.dart`: (1) `'merged row golden (axisId:value@infoGain) is byte-stable'` — `expect(serialize(row), kMergedRowGolden)`. (2) `'every chip infoGain > 0'` — מאסר ש-`chips.every((c)=>c.infoGain>0)` (כל שבב-מוצג מצמצם). (3) `'populating infoGain did NOT change chip ORDER'` — משווה `row.map((c)=>'${c.axisId}:${c.value}')` מול אותו golden-סדר מ-63's snapshot. (4) עדכון `card_engine_test.dart` "value/displayLabel split" אם `==` השתנה.

**6. שיפור:** לחשב `infoGain` פעם-אחת ולשמור ב-`_AxisScore` (שכבר נושא את ה-`nc` לכל שבב במשתמע) במקום לחשב-מחדש בבנייה — אבל הלולאה הנוכחית (`card_engine.dart:250`) זורקת את ה-`nc` הפר-שבב; לשמור `List<int> perChipNc` ב-`_AxisScore` ולהשתמש בו, חוסך חישוב כפול של `distinctCardCount` בבנייה.

**7. ריאלי?:** אטומי אך **מסוכן בגלל ה-`==`** — שינוי שדה-זהות הוא breaking-change חבוי. ריאלי כשלב-אחד אם מקדימים את החלטת-ה-equality. ממליץ: להוסיף תת-משימה מפורשת "להחליט אם infoGain ∈ identity" כצעד-ראשון בתוך 64.

**8. וידוא-פיקס מלא:** `analyze`=0-new; ה-golden החדש מבורך (`--update-goldens` או קבוע-מחרוזת); **flag-OFF byte-identity:** מכיוון שמילוי infoGain הוא בתוך `_mergedChips` שרץ רק מאחורי-דגל (המסך self-gates `card_keyboard_screen.dart:400`), הפרודקשן זהה-בייטים; להריץ את כל `card_keyboard/` + לוודא ש-`card_engine_test.dart` (כל 7 הקבוצות) ירוק אחרי שינוי-ה-`==`.

**9. תכנון נוסף (שלי):** לעגן את ה-golden **גם לבריכה-מסוננת** (אחרי זרע 'ברז'), לא רק `kDivePool` הגולמי — כי 66 ישנה דירוג, וצריך עוגן על בריכה שבה כמה צירים מתחרים, לא רק הבריכה-המלאה שבה ציר-המילים שולט.

**10. תכנון נוסף (שלי):** בדיקת-**מונוטוניות**: שבב עם `infoGain` גבוה יותר חייב להגיע מ-ציר עם `expRem` נמוך יותר (התועלת עקבית עם הדירוג) — מאסר שאין שבב "מטעה" שמראה תועלת-גבוהה בעוד הציר שלו דורג נמוך.

---

### שלב 65 — איחוד ניקוד-info-gain ל-5 צירים כולל חומר (שומר-התנהגות)

**1. יעד:** הגיון-הניקוד הפר-ציר יחולץ לפונקציה משותפת אחת `_scoreAxis(SignalSource src, List<LipskeyCatalogProduct> pool)` שמחזירה `(sumSq, n)`, **כולל ציר-החומר באותו מסלול** (לא ענף-מיוחד), עם golden **זהה-לשלב-64**. מה שחדש: היום הניקוד מוטמע inline בלולאה (`card_engine.dart:246–261`) ומעורבב עם בניית-`_AxisScore`; אחרי 65 יש helper טהור בר-בדיקה-עצמאית, וחומר כבר לא דורש הערת-"swarm R3 fix" מיוחדת אלא עובר באותה דלת.

**2. איך בונים:** (א) לחלץ `({int sumSq, int n, bool anySplit}) _scoreAxis(SignalSource src, List<LipskeyCatalogProduct> pool)` מתוך הגוף הקיים (`card_engine.dart:246–260`) — `n=distinctCardCount(pool)`, לולאה על `src.chipsFor(pool)` עם `src.matches`, צבירת `sumSq` ו-`anySplit`. (ב) `_mergedChips` קורא ל-`_scoreAxis` במקום הלולאה-המוטמעת. (ג) חומר עובר דרך אותו `_scoreAxis` — וזה **כבר המצב** בקוד (`card_signals.dart:182–191` מתעד שחומר מנוקד "SAME way as every other axis on the FULL pool"), אז 65 בעיקר **מקבע** את זה ומחלץ.

**3. תקלות צפויות:** (א) **התנהגות חייבת להישאר זהה-בייטים** — חילוץ-helper הוא refactor; כל סטייה ב-`sumSq`/`anySplit` תזיז את הדירוג ותשבור את golden-64. הסכנה: לשכוח את ה-`if (nc < n) anySplit = true` (`card_engine.dart:253`) או את ה-div-0 guard (`card_engine.dart:247`). (ב) **חומר וה-null-carry** — `MaterialSignal.matches` מחזיר true על null (`card_signals.dart:223`), אז `sumSq` של חומר סופר את ה-carry-along; אם ה-helper בטעות יסנן null, ה-expRem של חומר יקטן וחומר יקפוץ-בדירוג (בדיוק ה-over-rank ש-R3 תיקן). (ג) **`representativeTake` לא בתחום ה-helper** — ה-helper מנקד בלבד; ה-layout (`card_engine.dart:277–295`) נשאר; אסור לערבב.

**4. פתרון:** (א) חילוץ מכני 1:1 — להעתיק את הגוף בדיוק, כולל שני ה-guards, ולאשר עם golden-64 שאין שינוי. (ב) ה-helper מקבל `SignalSource` ומשתמש ב-`src.matches` (שכבר נושא את ה-null-carry לחומר) — לא מיישם predicate משלו. (ג) ה-helper מחזיר רק `(sumSq,n,anySplit)`; הבנייה והדירוג נשארים ב-`_mergedChips`.

**5. בדיקות:** `card_merge_golden_test.dart` (מורחב) + `card_score_axis_test.dart`: (1) `'_scoreAxis(material) counts the null-carry pool (no over-rank)'` — בריכה עם נחושת+unknown, `n` כולל את ה-unknown. (2) `'merged row golden UNCHANGED after _scoreAxis extraction'` — אותו `kMergedRowGolden` משלב-64 (מאסר-רגרסיה). (3) `'_scoreAxis div-0 guard: empty pool → n=0, anySplit=false'`. (4) `'material is scored via the SAME path as size (no special branch)'` — בדיקה ש-`_scoreAxis` נקרא אחיד.

**6. שיפור:** ה-helper יכול להחזיר גם את `perChipNc` (ראו שיפור-64), כך ש-66's top-K-לפי-gain יקבל את ה-`nc` הפר-שבב בחינם במקום לחשב מחדש — איחוד נקודת-החישוב היחידה של `distinctCardCount` היקר (התוכנית עצמה מציינת ב-`card_engine.dart:201–204` שזה ה-op היקר ביותר).

**7. ריאלי?:** אטומי לחלוטין — refactor שומר-התנהגות עם golden-עוגן. ריאלי וקטן; לא דורש פיצול. זה בדיוק סוג-השלב שצריך להישאר אטומי (שינוי-מבנה מבודד מ-שינוי-התנהגות ב-66).

**8. וידוא-פיקס מלא:** `analyze`=0-new; golden-64 ירוק ללא-שינוי (ההוכחה ש-65 שומר-התנהגות); `card_engine_test.dart` כולו ירוק; **flag-OFF byte-identity:** `_scoreAxis` רץ רק בתוך `_mergedChips` מאחורי-דגל → פרודקשן זהה; regression מלא על `card_keyboard/`.

**9. תכנון נוסף (שלי):** בדיקת **commensurability** מפורשת — כל 5 הצירים חולקים את אותו מכנה `n=distinctCardCount(pool)` (`card_engine.dart:246`), אז ה-expRem בר-השוואה; לאסור שכל `_AxisScore.n` שווה לכולם באותו turn (מגן מפני באג עתידי שבו ציר ינקד על בריכה-מסוננת אחרת).

**10. תכנון נוסף (שלי):** להוסיף **assertion על facet-axis** — `CuratedFacetSignal` (`card_signals.dart:234`) חייב לעבור דרך אותו `_scoreAxis` כשיש subtype, כדי שציר-ה-facet ידורג-בין-האחרים-לפי-decisiveness (כפי שמבטיח `card_signals.dart:280–282`) ולא יקבל יחס-מיוחד.

---

### שלב 66 — מעבר ל-top-K-לפי-gain לכל-ציר (golden משתנה בכוונה, מבורך-מחדש)

**1. יעד:** ה-layout הפר-ציר עובר מ-**positional take** (היום: `representativeTake` ל-size/angle, `take(take)` לשאר — `card_engine.dart:291–293`) ל-**top-K-לפי-gain** — שורה-מדורגת אחת שבה כל שבב נבחר לפי ה-`infoGain` שלו, **בעוד size/angle עדיין שומרים-קצוות** (smallest+largest). golden **משתנה בכוונה** ומבורך-מחדש. מה שחדש: השבבים-המוצגים הם ה-K-המצמצמים-ביותר לכל ציר, לא ה-N-הראשונים.

**2. איך בונים:** (א) ב-`_mergedChips` להחליף את `a.chips.take(take)` (`card_engine.dart:292`) ב-`topKByGain(a.chips, take)` שממיין לפי `infoGain` יורד (מ-64). (ב) ל-size/angle: לשמור את ה-`representativeTake` שמבטיח קצוות, אבל **אחרי** סינון-K-לפי-gain — או למזג: "קצוות + top-(K-2)-gain-באמצע". (ג) לעדכן `kMergedRowGolden` למחרוזת החדשה (`--update-goldens`/קבוע-חדש). (ד) להריץ-מחדש את חשבון-ה-≤6 (שלב 67 תלוי, אבל כאן רק "≤6 מאושר-מחדש" כ-sanity).

**3. תקלות צפויות:** (א) **שבירת golden-65 בכוונה** — חייב להחליף את הקבוע, אחרת הבדיקה אדומה; הסכנה היא להחליף-מוקדם או לשכוח להריץ-מחדש. (ב) **size/angle truncation חוזר** — אם top-K-לפי-gain קודם ל-representativeTake, ה-`take(take)` הפנימי יחתוך את הקצה-הגדול בדיוק כמו שתועד נגד ב-`card_engine.dart:283–290` (swarm R5: "size-only branch silently exposed angle to truncation"). זו רגרסיה לבאג-מתועד. (ג) **infoGain כ-sort-key מפר-דטרמיניזם?** — `infoGain` הוא `double` (`card_engine.dart:74` "never the sort key... uses exact integer rational"); מיון לפי double יכול להכניס ULP-ties/NaN. (ד) **shuffle-stability** — מיון-לפי-double על שוויון עלול להיות לא-יציב.

**4. פתרון:** (א) להחליף את הקבוע **באותו commit** של שינוי-ה-layout, ולבדוק את ה-≤6-sanity מיד. (ב) למזג נכון: לחשב את ה-top-K-gain על **כל** שבבי-הציר, ואז **לכפות הכללת-קצוות** ל-size/angle (union של {smallest, largest} עם top-(K-2)), ולמיין את התוצאה-הסופית לפי mm (כדי שהשורה תישאר מונוטונית-קריאה) — לא להחזיר positional-truncation. (ג) למיין top-K לפי **`(n-nc)` השלם** (לא ה-`double infoGain`) עם tie-break sku/label — שומר את ערובת-ה-cross-multiply-השלם של `card_engine.dart:267–272`. (ד) tie-break דטרמיניסטי (label) → shuffle-stable.

**5. בדיקות:** `card_merge_golden_test.dart` (golden חדש): (1) `'merged row golden CHANGED (top-K-by-gain) and is blessed'` — קבוע-חדש. (2) `'size/angle STILL include smallest AND largest (no tail-cut regression)'` — מאסר ש-`row.where(size).first.value==minMm && .last.value==maxMm` (מגן על swarm R5). (3) `'top-K uses integer gain, byte-stable under shuffle [1,7,42,99,1234]'`. (4) `'≤6 still holds after re-layout'` — sanity מהיר (המאסר-המלא ב-67).

**6. שיפור:** במקום מיון-מלא של כל שבבי-הציר ואז חיתוך, להשתמש ב-partial-selection (nth_element-style) ל-top-K — אבל בהינתן ש-`kMergedAxisMaxPerAxis=4` (`card_engine.dart:175`) וגדלי-הצירים קטנים, המיון-המלא זניח; השיפור האמיתי הוא לשמור את `perChipNc` מ-65 כדי לא לחשב `distinctCardCount` שוב בשלב-המיון.

**7. ריאלי?:** אטומי, אבל **הוא ה-restructure שהתוכנית עצמה מסמנת** (`card_engine.dart:206–213`: "realising Phase 3 will mean... replacing the per-axis positional take with a per-axis scored top-K — a restructure of this loop"). ריאלי כשלב-אחד **בתנאי** שמיזוג-הקצוות נעשה נכון; אם מסתבך, לפצל ל-66a (top-K לציר-word/color) ו-66b (top-K+קצוות לציר-size/angle). ממליץ להשאיר אחד אך לתכנן את ה-split כגיבוי.

**8. וידוא-פיקס מלא:** `analyze`=0-new; golden-חדש מבורך + 3 הבדיקות ירוקות; להריץ-מחדש את **כל** `card_engine_test.dart` (כולל "byte-stable under shuffle" `:92` ו-"per-axis FLOOR" `:80`); **flag-OFF byte-identity:** שינוי בתוך `_mergedChips` מאחורי-דגל → פרודקשן זהה (לוודא `card_keyboard_screen_test.dart` "flag OFF"); אין דליפה (טהור).

**9. תכנון נוסף (שלי):** לוודא שה-**floor עדיין מתקיים אחרי top-K** — `kMergedAxisFloor=2` (`card_engine.dart:236`) נבדק על `chipsFor` המלא; אחרי top-K צריך לוודא שלא ירדנו מתחת ל-floor בגלל הצמצום (אם ל-ציר יש בדיוק 2 שבבים ושניהם נבחרים — בסדר; אבל לאסור מפורשות).

**10. תכנון נוסף (שלי):** golden **שני על בריכה-מסוננת רב-צירית** (אחרי 'ברז'+גודל) — כי על `kDivePool` המלא ציר-המילים שולט וה-top-K כמעט לא משנה; הערך-האמיתי של top-K נראה רק כשכמה צירים מתחרים בעוצמה דומה, וזה ה-golden שיתפוס רגרסיות-דירוג עתידיות.

---

### שלב 67 — שער-קשיח ≤6-תורים + חשבון רשימה-ואז-בחר (ShowProducts עד-תור-5)

**1. יעד:** קבוע **ציבורי** יחיד `kMaxDiveTurns` (=6) שהוא **מקור-האמת היחיד** ל-≤6, + מנגנון שכופה `CardShowProducts` עד-תור-5 כך שבחירת-הגריד היא הפעולה ה-≤6, + מפקד-בדיקה שמאסר "רשימה ≤12 עד-תור-5". מה שחדש: היום אין תקרת-תורים כלל — `mergedKeys` (`card_engine.dart:149–170`) יכול להמשיך לבקש שבבים עד שהבריכה מתכווצת מטבעה; אין ערובה ש-`stack.length ≤ 6`.

**2. איך בונים:** (א) ב-`card_engine.dart`: `const int kMaxDiveTurns = 6;`. (ב) ב-`mergedKeys`, **לפני** רונג-ה-merge (`card_engine.dart:167`), להוסיף: `if (stack.length >= kMaxDiveTurns - 1) return CardShowProducts(distinctProducts(pool));` — כך מתור-5 ואילך תמיד מציגים מוצרים (הבחירה היא תור-6). (ג) לוודא ש-`distinctProducts` חתום ב-`kShowProductsCap=30` (`word_finder_engine.dart:288`) — אבל החשבון דורש ≤12 בתור-5; לכן ה-cap-האפקטיבי בתור-5 צריך להיות `kShowProductsThreshold=12`, לא 30. (ד) שלבים 33/42/43/60/69 **מייבאים** את `kMaxDiveTurns` (מקור-יחיד).

**3. תקלות צפויות:** (א) **≤12 לא מובטח בתור-5** — `distinctProducts` עם `cap=30` (`word_finder_engine.dart:289`) יכול להחזיר עד 30 מוצרים; אם הבריכה בתור-5 עדיין רחבה, "רשימה ≤12" נכשל. (ב) **`kShowProductsThreshold` כבר עוצר מוקדם** — אם הבריכה ≤12 כבר בתור-3, סולם-הוורדיקט מחזיר ShowProducts (`card_engine.dart:164`) **לפני** שמגיעים ל-gate-החדש; ה-gate הוא רק לתרחיש שהבריכה נשארת >12 עד תור-5. (ג) **לולאת-אינסוף-לוגית** — בלי ה-gate, בריכה ש-`_mergedChips` מחזיר עבורה שבבים-לא-מצמצמים (`anySplit` כן אבל איטי) יכולה לדרוש >6 תורים. (ד) **`stack.length` vs תורים** — האם הזרע-הפותח נספר כתור? (`card_keyboard_screen.dart:322` דוחף step לזרע) — צריך החלטה: זרע=תור-1.

**4. פתרון:** (א) בתור-5 (ה-gate) לקרוא `distinctProducts(pool, cap: kShowProductsThreshold)` — לכפות ≤12. אם הבריכה >12 בתור-5, להציג את ה-12-הראשונים (החשבון: 5 שאלות + בחירה-מ-12 = ≤6 פעולות-משתמש; זה בדיוק "רשימה-ואז-בחר"). (ב) לתעד ש-ה-gate משלים את `kShowProductsThreshold` (לא מחליף): threshold עוצר-מוקדם כשאפשר, gate כופה-עצירה כשהבריכה עקשנית. (ג) ה-gate מבטיח טרמינציה קשיחה ללא תלות ב-`anySplit`. (ד) להחליט מפורשות: הזרע-הפותח **כן** נספר (`stack.length` כולל אותו, `card_keyboard_screen.dart:322`), אז `kMaxDiveTurns-1=5` הוא הגבול-לפני-בחירה.

**5. בדיקות:** `card_dive_turns_test.dart`: (1) `'kMaxDiveTurns == 6 and is the single source'` — `expect(kMaxDiveTurns, 6)`. (2) `'at turn 5 (stack.length==5) verdict is ShowProducts ≤12'` — בונה stack באורך-5, מאסר `v is CardShowProducts && v.products.length <= 12`. (3) `'no dive exceeds kMaxDiveTurns turns'` — סימולציית-greedy שבכל turn לוקחת את השבב-הראשון, מאסר שתוך ≤6 מגיעים ל-Resolve/ShowProducts. (4) `'gate complements threshold (≤12 pool resolves before gate)'`.

**6. שיפור:** במקום מספר-קסם `kMaxDiveTurns - 1` בתנאי, להגדיר `kMaxMergeTurns = kMaxDiveTurns - 1` (=5) מפורשות עם docstring "אחרי כך-וכך תורי-merge כופים בחירה" — שלב 100 (השער-המרכזי) יוכל לייבא את שניהם בלי לחשב.

**7. ריאלי?:** אטומי וקריטי — זהו הצומת שכל הוכחת-ה-≤6 תלויה בו (התוכנית: "מקור-יחיד ל-≤6"). ריאלי כשלב-אחד; קטן בקוד אך גבוה-במשמעות. לא לפצל — דווקא חשוב שיהיה אטומי כדי שהמקור-היחיד לא יתפצל.

**8. וידוא-פיקס מלא:** `analyze`=0-new; `card_dive_turns_test.dart` ירוק; **golden:** ה-gate משנה התנהגות רק בתור-5+ (נדיר על מסלולים קצרים), אז golden-66 צריך להישאר ירוק על מסלולים ≤4 — לאשר; **flag-OFF byte-identity:** הכול בתוך `mergedKeys` מאחורי-דגל → פרודקשן זהה (`card_keyboard_screen_test.dart` "flag OFF"); regression מלא; אין דליפה.

**9. תכנון נוסף (שלי):** **allowlist מצטמצם** של חורגים — התוכנית (סעיף הוכחת-החוזה) מזכירה "allowlist מצטמצם"; כבר כאן להוסיף `const Set<String> kOver6Allowlist = {}` (ריק) ובדיקה שהוא ריק, כדי ש-100 יוכל להפיל-בילד על כל sku שלא ב-allowlist בלי להמציא מבנה.

**10. תכנון נוסף (שלי):** לוודא ש-ה-gate **לא קורה לפני** רונג-ה-Resolve (`card_engine.dart:161`) — אם בתור-5 הבריכה כבר collapsed ל-1, צריך Resolve (לא ShowProducts); סדר-הרונגים חייב להיות Resolve→threshold→turn-gate→merge. לבדוק מפורשות שבריכה-של-1-בתור-5 נותנת `CardResolve`, לא `CardShowProducts`.

---

### שלב 68 — חיווט המסך ל-`seedPool`: כל פה דרך card_seed

**1. יעד:** `CardKeyboardScreen` מחווט כך ש**כל** זריעה (טקסט-חופשי + כל פה) עוברת דרך `seedPool`/`seedFrom*` (משלבים 62–63) בצעד-זרע-**אחד**, במקום בניית-`NewbieStep` ידנית ב-`_onWordTap`. מה שחדש: היום `_WordTap` בונה את ה-step ב-`card_keyboard_screen.dart:318–334` עם `skuSet`+`_kOpeningWordAxis` מקומיים; אחרי 68 הוא קורא `seedFromText`/`seedFromSkus` והדוחף `seedPool(...)`.

**2. איך בונים:** (א) ב-`_onWordTap`, ענף `_WordTap` (`card_keyboard_screen.dart:318`): להחליף את הבנייה-הידנית ב-`final seed = seedFromText(payload.word, cardKeyboardLexicon); if (seed != null) _pushStep(seedPool(seed));`. (ב) להחליף `_kOpeningWordAxis` (`:51`) ב-`kOpeningSeedAxis` הציבורי (מ-62) ולמחוק את הפרטי (המחיקה-הנדחית מ-62). (ג) seam טקסט-חופשי: להוסיף נתיב-כניסה ל-`seedFromText` ממחרוזת-חיפוש (מקדים את פה-הטקסט המלא של P4, אבל ה-seam נדרש כאן). (ד) להשאיר את `_ChipTap` (`:337`) כפי-שהוא — הוא צמצום, לא זריעה.

**3. תקלות צפויות:** (א) **byte-identity של ה-seed-step** — `seedFromText` עושה **union** (שלב 63), בעוד הקוד-הישן `card_keyboard_screen.dart:319` עושה `resolveWord(payload.word)` של **מילה-אחת**; למילה-בודדת union==single, אז זהה — אבל לוודא. (ב) **`seedFromText` יכול להחזיר null** (כל-לא-ידוע, `seedFromText→null`); הקוד-הישן תמיד דחף step (אפילו עם skuSet ריק → בריכה-ריקה → `CardShowProducts([])`, `card_engine.dart:168`). שינוי-התנהגות: null=אין-step במקום step-ריק. (ג) **flag-race** — `_live` נקרא פעם-אחת ב-`late final` (`card_keyboard_screen.dart:124`); החיווט-החדש אסור שיקרא `featureFlagsProvider` שוב. (ד) **memo invalidation** — `_pushStep` מבמפ `_diveVersion` (`:208`); אם seedPool נדחף בלי `_diveVersion++`, ה-verdict יישאר stale (`card_keyboard_screen.dart:144–152`).

**4. פתרון:** (א) בדיקת-parity: `seedFromText('ברז')` == הבנייה-הישנה ל-'ברז' (אותו skuSet). (ב) להחליט: על-null, לדחוף step-ריק (לשמר התנהגות `CardShowProducts([])` + `_buildEmptyState`) **או** להתעלם; ההמלצה — לדחוף `seedPool` עם predicate-תמיד-false אם null, כדי לשמר את ה-empty-state-path הקיים (אחרת המשתמש לוחץ-ולא-קורה-כלום). (ג) להמשיך להשתמש ב-`_pushStep` הקיים (שמבמפ `_diveVersion`) — לא לעקוף אותו. (ד) לעבור רק דרך `_pushStep`/`_popStep` שכבר מטפלים ב-memo.

**5. בדיקות:** `card_keyboard_screen_test.dart` (מורחב — הקובץ הקיים): (1) `'tapping a word seeds via seedPool in ONE step'` — אחרי tap, `state.crumbs.length == 1` ו-`answeredAxes` **לא** מכיל 'דגם' (ציר-מילים פתוח, כמו הבדיקה הקיימת `:82`). (2) `'seedFromText null (gibberish) keeps the empty-state path'` — אם נחווט נתיב-טקסט, gibberish → `CardShowProducts([])` → `_buildEmptyState`. (3) `'opening seed uses kOpeningSeedAxis (public)'`. (4) **byte-identity:** `'flag OFF → renders nothing'` (הבדיקה הקיימת `:22`) חייבת לעבור ללא-שינוי.

**6. שיפור:** לאחד את `_WordTap` ו-seam-הטקסט-החופשי ל-`_SeedTap(PoolSeed seed)` יחיד — כך `_onWordTap` מקבל זרע-מוכן ולא בונה אותו, וה-payload נושא את ה-`PoolSeed` ישירות (פחות לוגיקה ב-UI, יותר ב-seam הטהור הבדיק). תואם את ה-`_Tap` הקיים (`card_keyboard_screen.dart:59–85`).

**7. ריאלי?:** אטומי — שינוי-חיווט בקובץ-מסך-אחד עם בדיקת-parity. ריאלי וקטן. לא דורש פיצול, אך **תלוי ב-62+63** (ה-seam חייב להתקיים); כרגע בקוד הם לא קיימים, אז 68 חסום עד שייבנו.

**8. וידוא-פיקס מלא:** `analyze`=0-new; `card_keyboard_screen_test.dart` כולו ירוק (כולל ה-flag-ON tap-flow `:39`); **flag-OFF byte-identity קריטי כאן** — זה הקובץ-מסך, אז "flag OFF → renders nothing" (`:22`) הוא ההוכחה שפרודקשן לא זז; להריץ-מחדש; לוודא אין דליפת-Riverpod-stack (ה-`cardKeyboardStackProvider` הוא `autoDispose`, `card_keyboard_state.dart:18`).

**9. תכנון נוסף (שלי):** לחווט את **איפוס-המחסנית-ממוקד-זהות** (שלב 32/21 בתוכנית) כאן-או-לוודא-שכבר-קיים — `card_keyboard_state.dart:14–17` מתעד ש-identity-family נדחה ל-Phase 4; אם 68 מחווט זריעה, זה הרגע לוודא שהחלפת-זהות מאפסת את ה-`stack` (אחרת זרע של עובד-A דולף לעובד-B). לפחות בדיקה ש-`stack` מתאפס על invalidate.

**10. תכנון נוסף (שלי):** בדיקת **debounce** — `_onWordTap` כבר נושא `_busy` re-entrancy guard (`card_keyboard_screen.dart:309–315`); לוודא שהחיווט-החדש דרך `seedPool` עדיין מכובד ע"י ה-debounce (double-tap על מילה לא דוחף שני seed-steps). הבדיקה הקיימת לא מכסה double-tap על זרע.

---

### שלב 69 — שקילות-חוצת-פיות + מפקד ≤6 ממצה לכל-כרטיס

**1. יעד:** מפקד-מוח **ממצה** — `card_brain_contract_test.dart` שמוכיח שלכל כרטיס-יקום (כל מוצר נבדל ב-`kDivePool`) יש **מסלול-≤6** שה-sku-היעד **בתוך התוצאה-החתוכה** (לא רק ורדיקט-סופי), + **שקילות חוצת-פיות** (אותו יעד נגיש מ-≥פה-אחד). מה שחדש: היום אין מפקד-מיצוי כלל; `card_engine_test.dart` בודק התנהגות-נקודתית (פה ושם), לא כיסוי-מלא-של-היקום.

**2. איך בונים:** (א) `test/features/card_keyboard/card_brain_contract_test.dart`. (ב) להגדיר `universe = distinctProducts(kDivePool, cap: 99999)` (כל הכרטיסים-הנבדלים). (ג) לכל כרטיס: סימולציית-dive greedy — מתחילים מזרע (`seedFromText` של מילה-מאפיינת או `seedFromSkus({sku})`), ואז בכל turn בוחרים את השבב שמקרב-הכי-הרבה ליעד (heuristic: השבב ש-`narrowed` עדיין מכיל את ה-sku-היעד), עד `CardShowProducts`/`CardResolve`. (ד) המאסר: ה-sku-היעד **בתוך** `v.products` (ל-ShowProducts) או `v.product/siblings` (ל-Resolve), תוך **≤kMaxDiveTurns** תורים. (ה) שקילות: לבדוק שאותו sku נגיש גם מ-seedFromMaterial (אם יש לו חומר) — ≥2 פיות.

**3. תקלות צפויות:** (א) **"ורדיקט-סופי" ≠ "sku בתוך התוצאה"** — התוכנית מדגישה שזה הכשל-הנסתר: dive יכול להגיע ל-`CardShowProducts` תוך ≤6 אבל היעד **נחתך** ע"י `kShowProductsCap=30` (`word_finder_engine.dart:289`) או ע"י ה-≤12 של 67. אם היעד הוא ה-13-בבריכה בתור-5, הוא לא ב-12-המוצגים → לא-נגיש. (ב) **carry-along של חומר** — `MaterialSignal.matches` שומר null (`card_signals.dart:223`); מסלול-חומר עלול לשמור בריכה-רחבה שלא מתכווצת ל-≤12 ב-5 תורים. (ג) **`distinctProducts` cap** — אם היקום > 30, הספירה-החתוכה מסתירה זנב. (ד) **זמן-ריצה** — מפקד על מאות כרטיסים × 6 תורים × `distinctCardCount` (O(pool)) הוא כבד; עלול לקרוס isolate (זיכרון/Defender — כמתועד ב-MEMORY gate-flakiness).

**4. פתרון:** (א) המאסר **חייב** לבדוק `v.products.any((p)=>collapseKey(p)==collapseKey(target))` — לא רק `v is CardShowProducts`. אם היעד נחתך, זה offender. (ב) ל-offenders של carry-along: heuristic-הבחירה צריך להעדיף ציר-מצמצם (gain-גבוה) על ציר-חומר כשהיעד-עדיין-רחב; וה-≤12-בתור-5 (שלב 67) צריך לכלול את היעד — אם לא, זה כשל-קשיח מול allowlist (שלב 67-תכנון-9). (ג) לרוץ על `distinctProducts(pool, cap: kDivePool.length)` כדי לא להחמיץ זנב. (ד) **retry-wrap** לכשלי-טעינת-isolate (כמתועד ב-MEMORY: עוטף-retry שמריץ-מחדש רק כשלי-טעינה), `taskkill dart` לפני, ולעולם לא `tail`; לחלק את המפקד ל-shards אם כבד.

**5. בדיקות:** `card_brain_contract_test.dart`: (1) `'every distinct card is reachable ≤6 turns with the sku INSIDE the cut result'` — הלולאה-הממצה לעיל, מאסר-כפול (≤6 **וגם** sku-בתוך). (2) `'cross-mouth: each card reachable from ≥1 mouth; material-bearing from ≥2'`. (3) `'offenders list is empty (or ⊆ allowlist)'` — אוסף את ה-skus-הלא-נגישים ומאסר ⊆ `kOver6Allowlist` (ריק). (4) `'no path keeps a pool >12 at turn 5 that excludes the target'`.

**6. שיפור:** במקום greedy-heuristic שעלול לפספס מסלול-קיים, להשתמש ב-**BFS-מוגבל-עומק-6** על מרחב-השבבים — מוצא מסלול-≤6 אם קיים (completeness), לא רק אם ה-greedy מוצא. יקר יותר אבל מוכיח-מיצוי-אמיתי; אפשר BFS רק ל-offenders של ה-greedy (היברידי: greedy-first, BFS-fallback).

**7. ריאלי?:** **גדול מדי כשלב-אחד** — מפקד-מיצוי על כל היקום + שקילות-חוצת-פיות + טיפול-offenders + retry-wrap הוא נפח-עבודה משמעותי וכבד-ריצה. **ממליץ לפצל:** 69a = מפקד-מיצוי-מסלול-יחיד (≤6 + sku-בתוך), 69b = שקילות-חוצת-פיות + allowlist. הסיכון-העיקרי הוא קריסת-isolate, שמחייב את ה-retry-wrap לפני שזה "ירוק".

**8. וידוא-פיקס מלא:** `analyze`=0-new; המפקד ירוק **תחת retry-wrap** (לא ירוק-מזויף מ-isolate-crash); `taskkill dart` לפני-הרצה; להריץ את כל `card_keyboard/` + `word_finder/` (כי המפקד נשען על `distinctProducts`/`resolveWord` שלהם); **flag-OFF byte-identity:** המפקד טהור (קורא `mergedKeys` ישירות, לא דרך המסך) → לא נוגע בפרודקשן; לוודא אין דליפת-handle (semantics/timer) בסוף.

**9. תכנון נוסף (שלי):** **קיבוע היקום ב-`kReachUniverse`** (שלב 1 בתוכנית, שעדיין לא נבנה!) — המפקד חייב לרוץ על יקום-מקובע נטען-שווה, אחרת הוא יכול "להצליח" ע"י התכווצות-שקטה של היקום. אם `kReachUniverse` לא קיים (וכרגע לא), 69 צריך להגדיר אותו או לתלות במפורש ב-1. בדיקה: `expect(kReachUniverse.length, <מספר-קבוע>)`.

**10. תכנון נוסף (שלי):** מפקד **סימטריה** — לא רק "כל כרטיס נגיש", אלא "אף מסלול לא חורג מ-≤6 לאף כרטיס" (הכיוון ההפוך): לסרוק מסלולים ולמצוא את ה-worst-case-turns המקסימלי, ולאסור שהוא ≤6 — תופס מסלול-עקשן שה-greedy-הממוצע לא חשף.

---

### שלב 70 — רגרסיית-מוח-ממוזג + סחיפת-analyze

**1. יעד:** **כל** חבילות-הבדיקה של המוח-הממוזג (61–69) רצות-יחד-ירוקות + `flutter analyze` נקי (zero-new), ו-**flag-OFF זהה-לשלב-2** (כלומר פרודקשן byte-identical ל-baseline-לפני-P7). מה שחדש: נקודת-בקרה-מאחדת שמאשרת ש-P7 כולו לא הדליף שום שינוי לפרודקשן ולא הותיר חוב-analyze.

**2. איך בונים:** (א) להריץ את כל `test/features/card_keyboard/` + `test/features/word_finder/` כסוויטה-אחת. (ב) `flutter analyze` ולהשוות ל-baseline (התוכנית: "18 infos" baseline משלב 1 — אבל שלב-1 לא נבנה, אז ה-baseline הוא ה-analyze הנוכחי לפני-P7). (ג) **flag-OFF byte-identity:** לאשר ש-`card_keyboard_screen_test.dart` "flag OFF → renders nothing" (`:22`) עובר, ושאף קובץ-פרודקשן לא-מאחורי-דגל לא שונה (כל P7 חי ב-`card_*` + `pool_seed.dart`, כולם מאחורי `kCardKeyboardFlag`). (ד) `taskkill dart` + retry-wrap לפני הרצת-הסוויטה הכבדה.

**3. תקלות צפויות:** (א) **"זהה-לשלב-2" — שלב-2 golden לא קיים** — שלב-2 (golden flag-OFF + `narrowAxis.sizeTokensIn` עוגן) לא נבנה; אז ה-"baseline" הוא מצב-הקוד-הנוכחי, לא golden-שלב-2. צריך לתפוס את ה-baseline **עכשיו** (לפני P7) כדי שיהיה למה להשוות. (ב) **analyze-drift מהקבצים-החדשים** — `pool_seed.dart`, `card_brain_contract_test.dart` וכו' עלולים להוסיף infos (unused_import, prefer_const). (ג) **isolate-flakiness** — סוויטה גדולה על מאות-כרטיסים (69) עלולה לקרוס-לסירוגין (`Connection closed before test suite loaded`, MEMORY gate-flakiness) ולתת "אדום-מזויף". (ד) **golden-drift** — אם 64/66 בירכו goldens, צריך לוודא שהם committed ולא משתנים בריצה-חוזרת.

**4. פתרון:** (א) לתפוס baseline-flag-OFF **בתחילת P7** (snapshot של פלט-`mergedKeys`-stub או של widget-render-OFF) ולהשוות אליו ב-70; לתעד שזה ה-baseline-המעשי (לא golden-שלב-2 שלא קיים). (ב) `analyze` נקי על כל קובץ-חדש — להסיר unused imports, `const` היכן שאפשר. (ג) **retry-wrap** סביב שלב-הטסט (כמתועד ב-MEMORY: מריץ-מחדש רק כשלי-טעינה, לעולם לא כשל-אמיתי) + `taskkill dart` + לעולם לא `tail`. (ד) לוודא goldens committed.

**5. בדיקות:** (1) הרצת-סוויטה: `flutter test test/features/card_keyboard/ test/features/word_finder/` — הכול ירוק. (2) `card_keyboard_flag_off_baseline_test.dart`: `'flag OFF screen render == pre-P7 baseline (byte-identical)'` — משווה widget-tree-OFF ל-snapshot. (3) `analyze`-gate: סקריפט שמאסר `analyze` issues ≤ baseline-count. (4) `'no production file outside kCardKeyboardFlag changed in P7'` — בדיקת-מקור/diff-guard.

**6. שיפור:** לעטוף את 70 בסקריפט-CI יחיד (`verify_card_brain.ps1`) שמריץ analyze + סוויטה + byte-identity ברצף ומחזיר exit-code אחד — מקדים את `verify_card_keyboard.ps1` של שלב 100, ומאפשר להריץ את כל-בקרת-P7 בפקודה-אחת בכל שלב עתידי.

**7. ריאלי?:** אטומי כ-checkpoint (אין קוד-מוצר חדש, רק הרצה+אימות+ניקוי-analyze). ריאלי; הסיכון היחיד הוא isolate-flakiness שמחייב retry-wrap. לא דורש פיצול.

**8. וידוא-פיקס מלא:** `analyze`=0-new (זו **כל** מהות-השלב); כל הסוויטה ירוקה תחת-retry; flag-OFF byte-identity מאושר מול baseline; אין דליפת-handle/timer; `taskkill dart` לפני; לאשר שכל ה-goldens (64,66) יציבים בריצה-חוזרת (לא flaky).

**9. תכנון נוסף (שלי):** להוסיף **בדיקת-מיצוי-imports** — לאסור שאף קובץ-card_keyboard מייבא `package:flutter_riverpod`/`dart:io` בקבצי-המנוע-הטהורים (`card_engine`, `card_signals`, `card_soft`, `pool_seed`); רק `card_keyboard_screen` ו-`card_keyboard_state` רשאים. מגן על חוזה-הטוהר שכל P7 נשען עליו (`card_engine.dart:16–19`).

**10. תכנון נוסף (שלי):** **diff-guard אוטומטי** מול ה-6-קבצים-הקיימים-לפני-P7 — לוודא ש-P7 לא שינה את החתימות-הציבוריות של `mergedKeys`/`CardVerdict`/`SignalChip` בלי-כוונה (חוץ מ-`infoGain` שכן השתנה ב-64); בדיקת-API-surface שמקבעת את ה-sealed-cases של `CardVerdict` (`card_engine.dart:100–135`) כדי ש-P8 (שמוסיף rails) לא ישבור את ה-switch הממצה ב-`_keysFor` (`card_keyboard_screen.dart:255–281`).

</div>

<div dir="rtl">

# פירוק מפורט — שלבים 71–80 (P8: גרף-הקפיצה)

> מעוגן בקוד האמיתי תחת `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל ההפניות הן ל-`lib/features/card_keyboard/`, `lib/features/word_finder/`, `lib/screens/lipskey_product_sheet.dart` ו-`lib/data/related_info.dart` בעץ הזה בלבד (כל קלון תחת `New folder/buildsmart` הוא **STALE** ולא נקרא).
>
> **הקשר-המאקרו של P8:** עד שלב 70 כל ה"פיות" כבר זורעות לתוך `mergedKeys` והמשפך־המאוחד מוכח ≤6-תורים לכל-כרטיס. P8 בונה את **חצי ה-≤4** של החוזה: **גרף-מוצרים אחד קנוני** מעל `kDivePool` (כולל מים-חמים), מודד את הקוטר הנוכחי, מתקן אותו בקונסטרוקציה עם **גב hub-clique**, ואז מחווט אותו ל-`LipskeyProductSheet` כ-rails (קפיצה-במקום + חזרה-מוצר-אחד + breadcrumb). הכל מאחורי דגל; פרודקשן זהה-בייטים.
>
> **מצב-בסיס שמצאתי בקוד (קריטי לכל 10 השלבים):**
> - **`hop_graph.dart` עדיין לא קיים** — שלב 71 יוצר אותו. גם **אין** טסט `hop_*`/`*graph*` תחת `test/` (אישרתי). הסט-נוד יהיה `kDivePool` (`dive_pool.dart:40`, האיחוד-מנוכה-כפילויות הכולל את `kHotWaterCatalog`).
> - **שלושה מקורות-קשת אמיתיים כבר קיימים** (אסור לבנות לוגיקת-תאימות מקבילה): `compatibleProductsFor` (`related_info.dart:217`, סריקת-מאטצ' מעל `kVerifiedSpecs` (855 ערכים), **ממומואיז** ב-`_compatCache`), `connectionsFor` (`word_finder_engine.dart:592`, שער `isConnectionAnchor` → `compatibleWith`), `variantSiblingsOf` (`related_info.dart:473`, משפחת מפתח-קנוני). בנוסף ה-kit-מוצרי בגיליון: `_installKit`/`_connectionGroups` (`lipskey_product_sheet.dart:271`/`:237`).
> - **`distinctCardCount`/`distinctProducts`** (`word_finder_engine.dart:279`/`:288`) מקפלים וריאנטים דרך `_collapseKey` (`brand||category||strippedName`). זה קריטי: "מוצר" בגרף-הקפיצה הוא **כרטיס-נבדל**, לא sku גולמי — אחרת 855 וריאנטים מנפחים את הצמתים.
> - **הגיליון (`LipskeyProductSheet`)**: שדה-העקיפה היחיד הוא `_chipOverride` (`:121`); `_switchByChip(q)` (`:364`) מציב אותו **במקום** (setState, בלי sheet חדש). `_QuickInfoStrips.onPickProduct` (`:563-567`) כבר קורא `_switchByChip` — קפיצה-במקום קיימת חלקית. **אבל** קרוסלת "🔧 חיבורים תואמים" (`:769-781`) קוראת `showLipskeyProductSheet` **רקורסיבית** (פותחת sheet-שני) — זה היעד שמתקן שלב 76.
> - **`forceLiveForTest` כבר קיים על `CardKeyboardScreen`** (`card_keyboard_screen.dart:93,106`) אך **לא** על `LipskeyProductSheet` — שלב 74 מוסיף אותו לגיליון.
> - **נקודת-העגינה לזהות-בייטים flag-OFF:** הגיליון נפתח דרך `showLipskeyProductSheet` (גלובלי, `showModalBottomSheet`); המסך מחווט ב-`catalog_screen.dart:2469` (`child: CardKeyboardScreen()`). הדגל `kCardKeyboardFlag='kCardKeyboard'` OFF, נקרא פעם-אחת ב-`_live` (`:124`).
> - **`anchorOf`/`softSuggestionsFor`** (`card_soft.dart`) כבר עוטפים את `connectionsFor` — P8 חולק את אותו גרף, לא בונה שלישי (זה מתקבע ב-90).

---

### שלב 71 — שדרת-גרף-קפיצה טהורה (compat+variants+kit, צמתי-מוצר בלבד)

**1. יעד:** קיים קובץ-טהור חדש `lib/features/card_keyboard/hop_graph.dart` שבונה **גרף לא-מכוון אחד** שבו הצמתים הם **כרטיסים-נבדלים** של `kDivePool` (לא skus גולמיים) וקשת קיימת בין שני כרטיסים אם הם מתחברים (`compatibleProductsFor`/`connectionsFor`), משלימים-ערכה (kit), או וריאנטים (`variantSiblingsOf`). לפני השלב אין שום מבנה-גרף — "קשור" קיים רק כקרוסלות אד-הוק בגיליון. אחרי: יש `hopGraph` קנוני יחיד עם `nodeSet`==קבוצת-הכרטיסים-הנבדלים, ו-adjacency דטרמיניסטי. **אין צמתים-וירטואליים** (אין צומת "hub"/"קטגוריה" שנספר כלחיצה) — hubs יתווספו ב-73 כ**קבוצת-נציגים מתוך הצמתים האמיתיים**, לא כצמתים חדשים.

**2. איך בונים:** (א) קובץ חדש, `library;`, import רק `lipskey_catalog.dart`, `dive_pool.dart`, `related_info.dart`, `word_finder_engine.dart` (ל-`connectionsFor`/`distinctProducts`/`_collapseKey`-מקביל) — **אפס** Flutter/Riverpod (דוקטרינת-הטוהר של `card_soft.dart:23`). (ב) להגדיר את **מפתח-הצומת** כ-`collapseKey` הציבורי: כיום `_collapseKey` פרטי ב-`word_finder_engine.dart:~250` — לחשוף `cardKey(p)` ציבורי (re-export דק) או להשתמש ב-`distinctProducts(kDivePool)` כרשימת-הנציגים הקנונית (FIRST-wins, כמו `mergedKeys`). (ג) `final List<LipskeyCatalogProduct> hopNodes = distinctProducts(kDivePool, cap: <גדול-מספיק>)` — אזהרה: `distinctProducts` חתוך ב-`kShowProductsCap`! צריך וריאנט לא-חתוך לגרף (ראה תקלה א). (ד) `Map<String, Set<String>> _adjacency` keyed על cardKey: לכל זוג-נציגים `(a,b)`, להוסיף קשת אם `compatibleProductsFor(a)` מכיל sku ממשפחת-b **או** `connectionsFor(a)` מכיל אותו **או** `variantSiblingsOf(a)` מכיל אותו **או** הם חולקים חבר-ערכה (`_installKit`-מקביל טהור). (ה) `Iterable<String> neighborsOf(String cardKey)` ציבורי. (ו) דגירה-עצלה (`late final`/memo top-level) כמו `_compatCache` — הבנייה היא O(N²) על ~N כרטיסים, חד-פעמית לכל isolate.

**3. תקלות צפויות:** (א) **`distinctProducts` חתוך** — חתימתו `cap: kShowProductsCap` (`word_finder_engine.dart:289`) **קוטעת** את היקום! אם נשתמש בו ישירות, הגרף יחסיר כרטיסים והקוטר יהיה שקרי. צריך לבנות קבוצת-נציגים **לא-חתוכה** (לקפל את `kDivePool` ידנית על cardKey). (ב) **`connectionsFor` מחזיר ריק לרוב-המוצרים** — השער `isConnectionAnchor` (`word_finder_engine.dart:570`) דורש `inCompat && hasSpec`; כל מוצר polyroll/huliot/מים-חמים-ללא-spec יחזיר `[]`, אז קשתות-החיבור דלילות מאוד וייתכן שהגרף **לא קשיר** (זה בדיוק מה ש-72 ימדוד ו-73 יתקן). (ג) **קשת על sku מול cardKey** — `compatibleProductsFor` מחזיר מוצרים (skus); אם נבדוק חברות לפי sku גולמי במקום לפי cardKey-של-היעד, וריאנט-של-שכן לא יזוהה והקשת תיעלם. (ד) **חוסר-סימטריה** — `compatibleProductsFor(a)∋b` לא בהכרח גורר `∋a` הפוך (rank/memo שונים); גרף לא-מכוון חייב `addEdge` דו-כיווני מפורש. (ה) **טוהר** — `related_info.dart` מושך הרבה, אך הוא data-layer טהור (אין widgets) — לוודא שאין import טרנזיטיבי של `material.dart`.

**4. פתרון:** (א) פונקציית-עזר פרטית `_cardReps()` שמקפלת את **כל** `kDivePool` על `cardKey` ל-`Map<String,LipskeyCatalogProduct>` (FIRST-wins) — **בלי cap**; `nodeSet = _cardReps().keys.toSet()`. לתעד "NOT distinctProducts — that caps at kShowProductsCap". (ב) **לא לתקן כאן** — אי-הקשירות היא תוצר-לגיטימי שספייק-72 חושף; הקשת-הדלילה נכונה. (ג) למפות כל sku-יעד דרך `cardKey(q)` לפני הוספת-קשת, ולוודא ש-`q`'s cardKey ∈ nodeSet (לדלג על מוצר שנפל מהקיפול). (ד) `void _addEdge(ka,kb){ _adj[ka]!.add(kb); _adj[kb]!.add(ka); }` — תמיד דו-כיווני. (ה) `dart analyze` + בדיקת-grep שאין `material.dart` ב-imports.

**5. בדיקות:** `test/features/card_keyboard/hop_graph_test.dart`: (1) `'node-set == כרטיסים-נבדלים של kDivePool'` — `expect(hopGraph.nodeSet.length, kDivePool.map(cardKey).toSet().length)` ו-`expect(hopGraph.nodeSet, equals(...))`. (2) `'כולל מים-חמים'` — `expect(hopGraph.nodeSet, contains(cardKey(HW-PUMP-25)))` (אותו sentinel כמו `dive_pool_test.dart:31`). (3) `'אין צמתים-וירטואליים'` — כל מפתח ב-`nodeSet` מתאים ל-`cardKey` של מוצר אמיתי ב-`kDivePool` (אין מפתח "hub:"/"cat:"). (4) `'גרף לא-מכוון (סימטרי)'` — לכל `a∈neighborsOf(b)` מתקיים `b∈neighborsOf(a)`. (5) `'דטרמיניסטי תחת shuffle'` — בנייה מ-`kDivePool` מעורבב (אם נחשוף constructor-מוזרק) נותנת אותה adjacency. (6) `'אין self-loop'` — `expect(neighborsOf(k), isNot(contains(k)))`.

**6. שיפור:** במקום O(N²) זוגות (N≈מאות → עשרות-אלפי בדיקות-`_reallyMates`), לבנות **inverted index**: לעבור פעם-אחת על כל מוצר, לקרוא `compatibleProductsFor(p)` (כבר ממוקאש!) ולהוסיף קשת `cardKey(p)↔cardKey(q)` לכל `q` ברשימה. זה O(N·deg) במקום O(N²), ומנצל את `_compatCache` הקיים. אותו דבר ל-`variantSiblingsOf` (משפחה→clique). זה גם מבטל את בעיית-הסימטריה כי כל קצה נוסף משני הכיוונים ממילא.

**7. ריאלי?:** כן, אטומי — אבל **גדול**. בנייה טהורה של ~120 שורות, אך משלב שלושה מקורות-קשת + קיפול-cardKey. בר-בדיקה במלואו (טהור, דטרמיניסטי). שווה לשקול פיצול-פנימי: 71a=שדרת-nodeSet+קיפול, 71b=הוספת-קשתות — אך מכיוון שהבדיקה המרכזית (node-set) עומדת בפני עצמה, אפשר להשאיר כשלב-אחד עם 6 בדיקות.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש (קובץ-חדש בלבד). זהות-בייטים flag-OFF **טריוויאלית** — אין קוֹרֵא-פרודקשן (grep: `hop_graph` רק תחת `test/`). להריץ את כל חבילת `card_keyboard` הקיימת — חייבת להישאר ירוקה (לא נגעתי בה). אין-leak (טהור, אין dispose). לאמת ש-`cardKey` הציבורי שחשפתי לא שינה את `_collapseKey` (אם re-export — להריץ `word_finder_engine`/`card_soft`/`distinct_label` טסטים).

**9. תכנון נוסף (שלי):** לחשוף `EdgeKind` לכל קשת (`compat`/`variant`/`kit`) כ-`Map<(String,String),Set<EdgeKind>>` נלווה. שלב 77 (rail 'קשור') ושלב 89 (rail רך) ירצו **להבחין** "מתחבר פיזית" מ-"וריאנט/אותה-משפחה" כדי לתייג את ה-chip; בלי זה הם יצטרכו לחשב מחדש את הסיווג. עלות זניחה בזמן-הבנייה, חוסך כפילות-לוגיקה ב-77/89.

**10. תכנון נוסף (שלי):** להוסיף `int get componentCount` + `Set<String> componentOf(key)` (union-find בזמן-בנייה). ספייק-72 צריך את מספר-המבודדים/הרכיבים; אם הגרף כבר מחזיק union-find מוכן, 72 הופך לקריאה ולא לחישוב-מחדש, ו-73 (hub-clique) יכול לכוון נציג-אחד-לרכיב במקום לנחש. זו תשתית-אמת-יחידה שמונעת "גרף שני" שמזהיר נגדו שלב 90.

---

### שלב 72 — ספייק-הישגיות: למדוד קוטר נוכחי + מבודדים לפני-hubs

**1. יעד:** קיים כלי-מדידה (טסט/סקריפט) שמריץ BFS על `hopGraph` (משלב 71) ומדפיס/מאשר שלושה מספרים: `diameter` (הקוטר הנוכחי), `worstPair` (זוג-הכרטיסים הרחוקים ביותר), ו-`isolatedCount`/`componentCount` (כמה כרטיסים בלתי-נגישים זה-מזה). לפני השלב אין מושג מה הקוטר האמיתי. אחרי: יש **snapshot מספרי** שמשמש כקלט-עיצוב ל-73 (כמה hubs צריך, ואיפה). הציפייה (מהתוכנית): ~130 מבודדים/רכיבים — כי `connectionsFor` דליל (תקלה 71ב).

**2. איך בונים:** (א) `hop_metrics.dart` טהור (או פונקציות ב-`hop_graph.dart`): `int diameterOf(graph)`, `(String,String) worstPairOf(graph)`, `int isolatedCount(graph)`. (ב) BFS פר-צומת: לכל `start∈nodeSet`, BFS שמחזיר `Map<key,dist>`; הקוטר = max על כל המרחקים-הסופיים; צמתים בלתי-נגישים (dist=∞) **לא** נספרים בקוטר אלא ב-`isolatedCount`/רכיבים. (ג) **שימוש ב-union-find משלב 71 #10** אם קיים — אז `componentCount` הוא O(1) ו-BFS רץ רק בתוך הרכיב-הגדול. (ד) `diameter` = double-BFS על הרכיב-הגדול (לא צריך all-pairs מדויק לספייק — אבל ל**הוכחה** ב-80 כן). (ה) הטסט מדפיס את המספרים (`debugPrint`/`reason`) ו-**מאשר רק שהם ביצירה** (לא מספר-קסם), כי הם קלט-עיצוב, לא חוזה. (ו) לתעד את ה-snapshot ב-comment כדי ש-73 יעוגן בו.

**3. תקלות צפויות:** (א) **all-pairs-BFS = O(N·(N+E))** על מאות-צמתים — איטי אך לא בלתי-אפשרי; אם נריץ עם isolate-ים מרובים זה יכול לקרוס (ראה זיכרון "תנודתיות-השער"). (ב) **קוטר על גרף לא-קשיר = ∞** — אם נחשב max נאיבי כולל בלתי-נגישים, נקבל `intMax`/שגיאה; חייבים להפריד "קוטר ברכיב" מ-"רכיבים מנותקים". (ג) **double-BFS לא מדויק** לקוטר בגרפים כלליים (מדויק רק בעצים) — לספייק זה בסדר (אומדן), אך **אסור** להסתמך עליו ל-≤4-הוכחה הקשיחה ב-80 (שם צריך all-pairs אמיתי או הוכחת-קונסטרוקציה). (ד) **`worstPair` לא-יציב** — אם יש כמה זוגות במרחק-המקסימום, הבחירה תלויה בסדר-איטרציה; לקבע tie-break (cardKey ממוין). (ה) המספר "130" הוא **ניחוש בתוכנית** — אם בפועל יוצא שונה מאוד (למשל הגרף קשיר!), זה מאותת שהקשתות צפופות יותר מהצפוי, ו-73 אולי מיותר — **למדוד לפני לאבחן** (זיכרון swarm-sizing).

**4. פתרון:** (א) להריץ עם `--concurrency=1` או כטסט-יחיד; לעטוף ב-retry-wrap לכשלי-טעינת-isolate (זיכרון gate-flakiness); `taskkill dart` לפני. (ב) להפריד מפורשות: `unreachableFrom(start)` נספר ל-`isolatedCount`, רק מרחקים-סופיים נכנסים ל-max-הקוטר. (ג) לתעד "double-BFS = אומדן-ספייק בלבד; ההוכחה הקשיחה ב-80 משתמשת ב-BFS-מלא". (ד) `worstPair` עם `(a,b)` ממוין-לקסיקלית כ-tie-break דטרמיניסטי. (ה) **לא לקודד את 130 כ-expect** — לאשר רק `isolatedCount >= 0`, `diameter > 0` ולהדפיס; אם המספר מפתיע, לעצור ולחשוב מחדש על 73.

**5. בדיקות:** `test/features/card_keyboard/hop_metrics_test.dart`: (1) `'snapshot: מדפיס קוטר/worst-pair/מבודדים'` — מריץ ומדפיס, מאשר `diameter` סופי ו-`isolatedCount` מוגדר (לא-קוסמטי: קלט-עיצוב). (2) `'קוטר על גרף-צעצוע = ידוע'` — לבנות גרף-קו של 5 צמתים מוזרק ולאמת `diameter==4` (מאמת את ה-BFS עצמו, לא תלוי-קטלוג). (3) `'מבודד מזוהה'` — צומת ללא-קשתות בגרף-צעצוע → `isolatedCount>=1`. (4) `'worstPair דטרמיניסטי'` — שתי קריאות → אותו זוג. (5) `'נגיש-עצמי dist=0'`.

**6. שיפור:** להחליף double-BFS ב-**BFS-from-all-sources במקביל לרכיב** עם זיכרון-מטריצת-מרחקים דחוסה (רק הרכיב-הגדול), ולשמור את ה-`worstPair` כ"זוג-ההוכחה" שעובר ישירות ל-73 (ה-hub חייב לכסות בדיוק את הזוג הזה). כך הספייק לא רק מודד אלא **מייצר את קלט-התיקון** — חוסך ל-73 לחשב מחדש איפה הכאב.

**7. ריאלי?:** כן, אטומי לחלוטין — כלי-מדידה קריאה בלבד, לא משנה קוד-פרודקשן ולא את הגרף. בר-בדיקה (גרף-צעצוע מאמת את ה-BFS; הקטלוג-האמיתי הוא snapshot). זה השלב הכי "בטוח" ב-P8.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. זהות-בייטים flag-OFF טריוויאלית (כלי-מדידה, אפס קוֹרֵא-פרודקשן). אין-leak. הוכחת-מלאות: גרף-הצעצוע (בדיקה 2) **מאמת את אלגוריתם-ה-BFS עצמו** בנפרד מהקטלוג, כך שמספרי-ה-snapshot אמינים. להריץ פעמיים ולוודא יציבות-המספרים (דטרמיניזם).

**9. תכנון נוסף (שלי):** לפלוט גם **היסטוגרמת-מעלות** (degree distribution) ו-`maxDegree`/`avgDegree`. אם יש כרטיס יחיד עם מעלה-ענקית (hub-טבעי) זה משנה את אסטרטגיית-73 (אולי כבר יש hub אורגני). בלי זה 73 עיוור לטופולוגיה ועלול להוסיף נציגים מיותרים.

**10. תכנון נוסף (שלי):** לשמור את ה-snapshot כ**קובץ-golden נומרי** (`hop_metrics.golden` — diameter+componentCount). אז כל שינוי עתידי בקטלוג/בקשתות שמרעיד את הטופולוגיה ייתפס מיד בדיף, ולא יתגלה רק כשהשער-המרכזי ב-100 נופל. זה הופך את "≤4" ממדידה-חד-פעמית למשמר-רגרסיה.

---

### שלב 73 — גב hub-clique בונה (נציגי-מוצר-אמיתיים) חוסם עלה-לעלה ≤4

**1. יעד:** קיים מבנה `hubBackbone` שבוחר **קבוצת-נציגים מתוך הצמתים האמיתיים** של `hopGraph` כך ש-**בקונסטרוקציה**: (א) כל כרטיס נמצא ≤1-קפיצה מנציג-hub כלשהו, ו-(ב) כל זוג-נציגים ≤2-קפיצות זה-מזה (clique-מורחב). מזה נובע מתמטית: כל זוג-עלים ≤ 1+2+1 = **≤4** קפיצות. לפני השלב הגרף לא-קשיר (130 מבודדים, 72). אחרי: `unreachableCount==0` ויש חסם-עליון ≤4 קשיח-בקונסטרוקציה. **הנציגים הם מוצרים-לחיצים** (כרטיסים אמיתיים), לא צמתים-וירטואליים — כך ש"קפיצה אל hub" היא קפיצה אל מוצר אמת שהמשתמש רואה.

**2. איך בונים:** (א) `hub_backbone.dart` טהור. (ב) **בחירת-נציגים greedy dominating-set**: לעבור על צמתים בסדר-דטרמיניסטי (ממוין-cardKey), ולכל צומת שעדיין לא "מכוסה" (לא הוא ולא שכנו נציג) — להכתיר אותו נציג ולסמן אותו+שכניו ככוסים. זה מבטיח (א) — כל כרטיס ≤1 מנציג. (ג) **חיבור-הנציגים ל-clique-≤2**: כאן הקושי האמיתי — הנציגים שנבחרו מרכיבים-מנותקים **לא** מחוברים זה-לזה כלל. צריך "על-hub" — לבחור **נציג-על אחד** (הכרטיס עם המעלה-הגבוהה ביותר, מ-72 #9) ולוודא שכל שאר-הנציגים ≤2 ממנו. אך אם הגרף לא-קשיר, אי-אפשר! ולכן: (ד) **גשר-קטגוריה/חומר נדרש** — אם רכיבים מנותקים פיזית, צריך קשת-גישור דרך ציר-משותף (אותה קטגוריה/חומר). זה אומר ש-`hopGraph` של 71 **חייב לכלול גם קשתות-קטגוריה/וריאנט** (לא רק חיבור-פיזי) כדי שהגב יהיה אפשרי. (ה) `Set<String> hubReps` + `Map<String,String> hubOf` (כל כרטיס→נציגו). (ו) `bool get isFullyConnected` + `int unreachableCount`.

**3. תקלות צפויות:** (א) **אי-אפשרות-בקונסטרוקציה** — אם `hopGraph` (71) כולל רק קשתות-חיבור-פיזי דלילות, אין דרך לחבר 130 רכיבים ל-clique-≤2 **בלי** צמתים-וירטואליים, וזה סותר את "אין צמתים-וירטואליים" (71). הפתרון מחייב ש-71 כבר ייתן קשתות-וריאנט+קטגוריה (לכן 71 כולל את שלושת המקורות). (ב) **dominating-set ≠ קשירות** — greedy-dominating מבטיח (א) אבל **לא** (ב); שני נציגים יכולים להיות במרחק-∞. צריך שלב-חיבור נפרד מפורש. (ג) **"clique זוג-זוג ≤2" יקר לאמת** — O(hubs²) double-BFS; אם יש מאות-נציגים זה כבד. (ד) **דטרמיניזם** — greedy תלוי-סדר; חייב סדר-cardKey יציב אחרת `hubReps` משתנה בין ריצות וה-rails קופצים. (ה) **הגדרת-"כיסוי"** — האם "מכוסה" פירושו ≤1 מ-*נציג-כלשהו* או מ-*נציג-יחיד*? להבהיר אחרת ההוכחה ל-≤4 דולפת.

**4. פתרון:** (א) לוודא ש-71 כולל קשתות-וריאנט+קטגוריה (לכן הקשתות שם הן union של 3+ מקורות) — לתעד שזה **תנאי-מוקדם להוכחת-73**. (ב) שלב-חיבור: לאחר dominating-set, לבחור `superHub` (מעלה-מקס) ולחבר כל נציג אליו דרך ה**רכיב**; אם נציג ברכיב-נפרד מ-superHub → להוסיף קשת-גישור דרך הציר-המשותף (קטגוריה) **לתוך hopGraph** (קשת אמיתית, לא צומת). (ג) לאמת clique-≤2 רק על `hubReps` (קבוצה קטנה אחרי domination), ולא על כל הצמתים. (ד) סדר-cardHey ממוין מפורש ב-greedy; בדיקת-shuffle-stability. (ה) להגדיר מפורשות: "מכוסה = ∃ hub h כך ש-h==v ∨ h∈neighborsOf(v)" ולתעד שזה נותן d(v,h)≤1.

**5. בדיקות:** `test/features/card_keyboard/hub_backbone_test.dart`: (1) `'unreachableCount==0'` — **הבדיקה-המרכזית**: אחרי הגב, כל זוג-כרטיסים נגיש. (2) `'כל כרטיס ≤1 מנציג'` — `for k in nodeSet: expect(hubOf[k]==k || neighborsOf(k).contains(hubOf[k]))`. (3) `'נציגים זוג-זוג ≤2'` — `for (h1,h2) in hubReps×hubReps: expect(hopsBetween(h1,h2) <= 2)`. (4) `'⇒ עלה-לעלה ≤4'` — דגימת זוגות-עלים אקראיים: `expect(hopsBetween(a,b) <= 4)` (מאמת את הקומבינציה 1+2+1). (5) `'נציגים הם כרטיסים אמיתיים'` — `expect(nodeSet.containsAll(hubReps))` (אין hub-וירטואלי). (6) `'דטרמיניסטי'` — שתי בניות → אותו `hubReps`. (7) `'כולל מים-חמים בכיסוי'` — `expect(hubOf.containsKey(cardKey(HW-PUMP-25)))`.

**6. שיפור:** במקום dominating-set+super-hub שני-שלבי, להשתמש ב**2-hop clustering** ישיר: לבחור מרכזים כך שכל צומת ≤2 ממרכז, ואז לחבר את כל-המרכזים לטבעת/כוכב. אך הדרך הנקייה ביותר: לבנות גרף בשתי-שכבות — שכבת-עלים מחוברת לשכבת-hubs, ושכבת-hubs היא clique-מלא בקונסטרוקציה (כל hub מחובר לכל hub דרך קשת-קטגוריה). זה **מוכיח** ≤4 בלי double-BFS על hubs (חסם-קונסטרוקציה במקום חסם-מדוד), ומבטל את בדיקה 3 היקרה.

**7. ריאלי?:** **גדול מדי — צריך פיצול.** זה השלב הכבד ביותר ב-P8: dominating-set + חיבור-רכיבים + הוכחת-≤4. אני מציע: **73a** = dominating-set (כל כרטיס ≤1 מנציג) + בדיקה 2; **73b** = חיבור-נציגים ל-clique-≤2 + גישורי-קטגוריה + בדיקות 1,3,4. החלוקה נקייה כי 73a בר-בדיקה לבד (כיסוי-מקומי) ו-73b בונה עליו (קשירות-גלובלית). התוכנית מונה אותו כשלב-אחד אך המורכבות מצדיקה תת-חלוקה.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. זהות-בייטים flag-OFF טריוויאלית (טהור, אפס קוֹרֵא-פרודקשן). **הוכחת-מלאות = בדיקה 1** (`unreachableCount==0`) **+ בדיקה 4** (דגימת ≤4): אם שתיהן ירוקות, החסם מובטח. להריץ פעמיים (דטרמיניזם). אם פיצלתי (73a/b), לוודא ש-73a לבד לא שובר כלום ו-73b משלים. לוודא שגישורי-הקטגוריה שהוספתי ל-hopGraph **לא** הוסיפו צמתים (בדיקה 5 של 71 חוזרת ירוקה).

**9. תכנון נוסף (שלי):** להגדיר `hubFor(card) → representative` כ-API ציבורי שישמש ישירות את rail-77 ("הקפיצה אל ה-hub" = chip לחיץ של `hubOf[current]`). בלי זה 77 יצטרך לחשב מחדש מי-ה-hub, ועלול לבחור נציג-אחר → שובר את הוכחת-≤4 (המסלול הנראה חייב להיות בדיוק מסלול-ההוכחה).

**10. תכנון נוסף (שלי):** לחשוף `proofPath(a,b) → List<String>` שמחזיר את מסלול-ה-≤4 הקונקרטי (a→hubOf[a]→superHub→hubOf[b]→b, מקוצר אם חופף). שלב 77/80 צריכים להראות שכל קשת-הוכחה היא chip לחיץ; אם הגב פולט את המסלול-המפורש, 77 פשוט מרנדר אותו, ו-80 פשוט מאמת אותו — במקום ששלושתם יחשבו מסלולים-עצמאיים שעלולים להתפצל ("גרף שלישי" ש-90 מזהיר נגדו).

---

### שלב 74 — seam-בדיקה forceLive ב-LipskeyProductSheet

**1. יעד:** ל-`LipskeyProductSheet` יש פרמטר `@visibleForTesting bool forceLiveForTest=false` (מקביל ל-זה שכבר קיים על `CardKeyboardScreen` ב-`card_keyboard_screen.dart:93,106`), שמכריח את התנהגות-הקפיצה החדשה (rails/breadcrumb/קפיצה-במקום של 75–80) **ON** בטסט, ללא תלות ב-`kCardKeyboardFlag` (שאינו unit-seedable). לפני השלב אין דרך לבדוק את התנהגות-הקפיצה ON בגיליון. אחרי: טסט-וידג'ט יכול לבנות `LipskeyProductSheet(forceLiveForTest:true)` ולתרגל את ה-rails.

**2. איך בונים:** (א) להוסיף ל-constructor של `LipskeyProductSheet` (`:103-107`) את השדה `this.forceLiveForTest = false` + `@visibleForTesting final bool forceLiveForTest`. (ב) ב-`_LipskeyProductSheetState` להוסיף `late final bool _hopLive = widget.forceLiveForTest || ref.read(featureFlagsProvider).contains(kCardKeyboardFlag);` — נקרא **פעם-אחת** ב-initState/late (אותו דפוס flag-race-guard כמו `_live` ב-`card_keyboard_screen.dart:124`). (ג) כל קוד-קפיצה חדש (75–80) יישמר מאחורי `if (_hopLive)`. (ד) להוסיף import `feature_flags.dart` + `card_keyboard_flag.dart` לגיליון. (ה) לתעד למה זה דרוש (הדגל async-load אחרי mount; הטסט לא יכול לזרוע אותו) — verbatim מה-docstring הקיים בשורות 100-106 של המסך.

**3. תקלות צפויות:** (א) **`showLipskeyProductSheet` הגלובלי** (`:29-47`) בונה את הווידג'ט — הוא **לא** מעביר `forceLiveForTest`; אז גם אם נוסיף את השדה, נתיב-הפרודקשן ייצור אותו `false` (טוב!), אבל הטסט שקורא `showLipskeyProductSheet` לא יוכל להדליק — הטסט חייב לבנות `LipskeyProductSheet` ישירות (כמו ש-`card_keyboard_screen_test.dart:44` בונה `CardKeyboardScreen(forceLiveForTest:true)` ישירות, לא דרך wrapper). (ב) **`late final` שנקרא ב-build לפני initState** — אם `_hopLive` הוא `late final` ברמת-המחלקה והוא ניגש ל-`ref.read`, זה בטוח רק כי `ConsumerState.ref` זמין; לוודא שאינו נקרא ב-field-initializer של שדה-אחר. (ג) **זהות-בייטים** — עצם הוספת השדה (`=false` ברירת-מחדל) + `_hopLive` שמחשב את אותו ערך שהדגל נתן = אפס-שינוי-התנהגות בפרודקשן, **כל עוד** שום קוד-קפיצה לא מחווט עדיין (74 הוא רק ה-seam). (ד) **השדה `_hopLive` לא-בשימוש עדיין** → `analyze` יתלונן על unused. 

**4. פתרון:** (א) הטסטים של 75–80 יבנו `LipskeyProductSheet(...)` ישירות עם `forceLiveForTest:true` (לתעד שזה הנתיב). נתיב-הפרודקשן דרך `showLipskeyProductSheet` נשאר `false` — זהות-בייטים. (ב) לשמור `_hopLive` כ-`late final` ולגשת אליו רק בתוך `build`/handlers, לא ב-initializer של שדה-אחר. (ג) לוודא ב-74 שאף `if (_hopLive)` עדיין לא עוטף קוד-נראה (רק ה-seam) — הקפיצה-בפועל מגיעה ב-75. (ד) כדי להימנע מ-unused: לחווט מיד בדיקת-`_hopLive` נקודתית **או** לסמן שהשדה ייצרך ב-75 ולהוסיף `// ignore: unused_field` זמני (עדיף: לאחד 74+75 אם ה-unused מטריד — ראה ריאלי).

**5. בדיקות:** `test/screens/sheet_force_live_test.dart`: (1) `'forceLiveForTest:false (ברירת-מחדל) → אין rails/breadcrumb'` — לבנות `LipskeyProductSheet(product:p, categoryProducts:[...], forceLiveForTest:false)`, לפמפ, ולוודא שאין את הווידג'ט-החדש (`_HopBreadcrumb`/rail) — byte-identity. (2) `'forceLiveForTest:true → ה-seam ON'` — אחרי 75 יהיה מה לבדוק; ב-74 לבדו אפשר רק לאמת ש-`_hopLive==true` דרך getter-בדיקה. (3) `'הדגל OFF + force:false → OFF'` (ברירת-המחדל היא ה-state ב-`SharedPreferences.setMockInitialValues({})`, כמו `card_keyboard_screen_test.dart:20`).

**6. שיפור:** במקום פרמטר-בוליאני, לחשוף `@visibleForTesting static bool debugForceHopLive` סטטי על המחלקה (כמו `forceLiveForTest` של word_finder ב-`forceLiveForTest` המוזכר בשלב). אך הפרמטר-בקונסטרוקטור עדיף כי הוא **per-instance** (אין דליפת-state בין טסטים, אין `addTearDown` לאיפוס) — תואם את התקדים שכבר עובד על `CardKeyboardScreen`. אז: להישאר עם הפרמטר.

**7. ריאלי?:** כן, אטומי — אבל **קטן מדי לבדו** (שדה-בוליאני + getter). ה-unused-field מעיק. אני ממליץ **לאחד 74 עם 75** (ה-seam + הצרכן-הראשון שלו), כך שה-`_hopLive` נצרך מיד וה-byte-identity נבדק בהקשר-אמיתי. אם נשמר נפרד — זה עדיין בר-בדיקה (בדיקה 1 לבדה משמעותית).

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש (פרט ל-unused-field אם 74 נפרד — לטפל בו). **זהות-בייטים flag-OFF = בדיקה 1**: `showLipskeyProductSheet` (נתיב-הפרודקשן) בונה `forceLiveForTest:false`, ו-`_hopLive` מחשב את אותו ערך שהדגל-OFF נתן → הגיליון מרנדר **בדיוק** כמו לפני. להריץ את כל טסטי-הגיליון/קטלוג הקיימים (`floating_card_keyboard_test`, `card_keyboard_screen_test`) — ירוקים ללא-שינוי. אין-leak (שדה bool).

**9. תכנון נוסף (שלי):** לחשוף `@visibleForTesting bool get hopLiveForTest => _hopLive;` כדי שטסט יוכל לאשר את ה-seam **בלי** לחכות ל-75 (פותר את בעיית-ה-unused וגם נותן נקודת-בדיקה ל-74-נפרד). זה התקדים מ-`card_keyboard_screen.dart` שחושף `verdict`/`crumbs` כ-`@visibleForTesting`.

**10. תכנון נוסף (שלי):** לוודא ש-`showLipskeyProductSheet` (הגלובלי) מקבל פרמטר **אופציונלי** `bool forceLiveForTest=false` שהוא מעביר הלאה — כך שטסט שכן רוצה לתרגל את ה-modal-route המלא (לא רק את הווידג'ט) יוכל. בלי זה, בדיקות ה-E2E של 49 ("אותו `showLipskeyProductSheet` עם siblings") לא יכולות להדליק את הקפיצה דרך הנתיב-האמיתי.

---

### שלב 75 — מחסנית-היסטוריית-מוצר בכרטיס (חזרה מוצר-אחד)

**1. יעד:** `LipskeyProductSheet` מחזיק `List<LipskeyCatalogProduct> _hopHistory` שמחליף/עוטף את שדה-העקיפה היחיד `_chipOverride` (`:121`). לפני השלב, `_switchByChip(q)` (`:364`) פשוט **דורס** את `_chipOverride` — אין דרך-חזרה; קפיצה ב→c מאבדת את b. אחרי: כל קפיצה **דוחפת** ל-`_hopHistory`, ו-`_hopBack()` חוזר מוצר-אחד אחורה. הכל מאחורי `_hopLive` (74). שתי קפיצות → חזרה מחזירה למוצר-הביניים.

**2. איך בונים:** (א) להוסיף `final List<LipskeyCatalogProduct> _hopHistory = [];`. (ב) `LipskeyCatalogProduct get _current` (`:341`) כיום `_chipOverride ?? widget.categoryProducts[_selectedIdx]` — לשנות ל-`_hopHistory.isNotEmpty ? _hopHistory.last : widget.categoryProducts[_selectedIdx]` (כש-`_hopLive`; אחרת התנהגות-`_chipOverride` הישנה). (ג) `_switchByChip(q)` (`:364`): כש-`_hopLive` → `setState(()=>_hopHistory.add(q))` במקום `_chipOverride=q`; לאפס `_openPickerKey/_accSelected/_activeStage` כמו היום. (ד) `void _hopBack(){ if(_hopHistory.isNotEmpty) setState(()=>_hopHistory.removeLast()); }`. (ה) `_selectVariant(i)` (`:354`) מאפס `_chipOverride=null` — להחליף ל-`_hopHistory.clear()` (בחירת-וריאנט-בכותרת = התחלה-נקייה). (ו) להציג כפתור-חזרה (←/back) רק כש-`_hopLive && _hopHistory.isNotEmpty`.

**3. תקלות צפויות:** (א) **`_chipOverride` נקרא בעוד-מקומות** — `_QuickInfoStrips.onPickProduct` (`:563`) קורא `_switchByChip`; `didUpdateWidget` של `_QuickInfoStrips` (`:1965`) משווה `oldWidget.product.sku` כדי לקפל פאנל. אם `_current` משתנה מקור, צריך שכל הצרכנים (כולל `_ensureFacts` ב-`:1953` שממואיז על sku) ימשיכו לעבוד — הם תלויים ב-`p`/`_current.sku`, אז כל עוד `_current` נכון, בסדר. (ב) **`_HeroImage`/`_ProductSide` מאפסים `_i=0` ב-`didUpdateWidget` כש-`sku` משתנה** (`:1181,:1379`) — קפיצה דרך `_hopHistory` משנה את `p`=`_current`, אז התמונה תתאפס נכון. (ג) **השארת `_chipOverride` כשדה-מת** — אם נשאיר את שני המנגנונים, יש סיכון שקוד-ישן יקרא `_chipOverride` והחדש את `_hopHistory` → סטייה. עדיף: `_hopLive` בורר **בנקודה-אחת** (`_current`), ו-`_chipOverride` נשאר כמסלול-ה-OFF בלבד. (ד) **זהות-בייטים** — כש-`_hopLive==false`, `_current` חייב להישאר `_chipOverride ?? ...` **מילה-במילה**, ו-`_hopHistory` ריק-ולא-בשימוש → אפס-שינוי. (ה) **leak** — `_hopHistory` הוא `List` רגיל (לא controller), אין dispose; אך הוא מחזיק רפרנסים ל-`LipskeyCatalogProduct` (const-data) → אין דליפה אמיתית.

**4. פתרון:** (א) למרכז את הבחירה ב-`_current` ולוודא שכל הצרכנים עוברים דרכו (הם כבר עוברים — `_accs`/`_stages`/`_ensureFacts` כולם על `_current.sku`). (ב) אישור שה-`didUpdateWidget` של `_HeroImage` עובד עם המעבר (בדיקת-וידג'ט שהתמונה מתאפסת). (ג) **לא להשאיר שני-מנגנונים פעילים** — `if(_hopLive){_hopHistory...} else {_chipOverride...}` בכל ה-3 הנקודות (`_current`/`_switchByChip`/`_selectVariant`), כך שרק אחד חי בכל מצב. (ד) בדיקת-byte-identity: `_hopLive==false` → `_hopHistory.isEmpty` תמיד, `_current` נופל ל-`_chipOverride`-branch. (ה) אין צורך ב-dispose (List של const-refs).

**5. בדיקות:** `test/screens/sheet_hop_history_test.dart` (עם `forceLiveForTest:true`): (1) `'2 קפיצות → חזרה מחזירה למוצר-הביניים'` — לבנות sheet, לקרוא `_switchByChip(b)`, `_switchByChip(c)`, `_hopBack()` → `_current.sku==b.sku`; `_hopBack()` שוב → חוזר ל-product-המקורי. (2) `'חזרה בהיסטוריה-ריקה = no-op'` — `_hopBack()` על sheet-טרי לא זורק ולא משנה `_current`. (3) `'בחירת-וריאנט מנקה היסטוריה'` — אחרי קפיצה, `_selectVariant(i)` → `_hopHistory.isEmpty`. (4) **`'flag/force OFF → _hopHistory לא-בשימוש, _current==_chipOverride'`** — byte-identity: עם `forceLiveForTest:false`, `_switchByChip(q)` עדיין מציב `_chipOverride` והתצוגה זהה. צריך getter `@visibleForTesting` ל-`_current`/אורך-היסטוריה.

**6. שיפור:** במקום `List<LipskeyCatalogProduct>` שמחזיק אובייקטים-מלאים, להחזיק `List<String> _hopSkus` (skus) ולפתור ל-product דרך `_skuIndex`/הקטלוג בנקודת-התצוגה — מצמצם זיכרון ומונע החזקת-רפרנס. אך מכיוון שהמוצרים const ו-`distinctProducts`/קרוסלות כבר מחזירות אובייקטים, החזקת-האובייקט פשוטה יותר ובלי lookup — להישאר עם objects אלא אם נדרש serialization (שלב 78 breadcrumb עשוי לרצות sku-only).

**7. ריאלי?:** כן, אטומי — מחליף שדה-יחיד במחסנית עם push/pop, מאחורי דגל. בר-בדיקה (4 בדיקות-וידג'ט). תלוי ב-74 (ה-seam). אם 74+75 אוחדו (המלצתי), זה שלב-אחד נקי "seam+history".

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF = בדיקה 4**: `forceLiveForTest:false` → `_hopHistory` ריק, `_current` נופל ל-`_chipOverride`, הגיליון זהה-בייטים. להריץ `floating_card_keyboard_test` + כל טסטי-הקטלוג. לוודא שאין כפל-מנגנון פעיל (grep `_chipOverride` — מופיע רק ב-else-branch). אין-leak (List const-refs, אין controller).

**9. תכנון נוסף (שלי):** לאכוף **cap על `_hopHistory`** (למשל 12) — מסע-קפיצות ארוך מאוד בתוך sheet-יחיד יכול לצבור היסטוריה גדולה; cap עם drop-מהתחתית שומר זיכרון וגם תואם את חוזה-ה-≤4 (אין סיבה לשרשרת ארוכה מ-4 בלי לסגור). זה גם מונע breadcrumb (78) ענק.

**10. תכנון נוסף (שלי):** לטפל ב**מקרה-קצה: קפיצה אל המוצר-הנוכחי עצמו** — אם `q.sku == _current.sku`, לדלג על הדחיפה (אחרת `_hopBack` "תקוע" על אותו מוצר). זה קורה כשהקרוסלות מציגות את עצמן (הקוד מסנן `q.sku != product.sku` ב-`:2269,:2453` אבל לא בכל מקום — למשל override-pairs ב-`:247`). הגנה ב-`_switchByChip` היא ה-seam-הבטוח.

---

### שלב 76 — ניתוב קרוסלת-חיבורים דרך קפיצה-במקום

**1. יעד:** קרוסלת "🔧 חיבורים תואמים" שכיום פותחת **sheet-שני רקורסיבי** (`lipskey_product_sheet.dart:769-781`, `onTap: ()=>showLipskeyProductSheet(context, g.parts[i], ...)`) מנותבת מחדש ל**קפיצה-במקום** דרך `_switchByChip`/`_hopHistory` (75) — בדיוק כמו שקרוסלות-הסטריפ כבר עושות (`:563-567`). לפני השלב, לחיצה על חלק-חיבור פותחת sheet שני מעל הראשון (ערימת-modals). אחרי: לחיצה **מחליפה** את המוצר-הנוכחי במקום, בלי modal-שני, עם היסטוריה לחזרה.

**2. איך בונים:** (א) למצוא את ה-`onTap` ב-`:771` (בתוך ה-`_RelatedCard` של קבוצת-החיבורים, `:769`) ולשנותו: כש-`_hopLive` → `onTap: ()=>_switchByChip(g.parts[i])` (קפיצה-במקום); אחרת ה-`showLipskeyProductSheet` הישן (byte-identity). (ב) זה ה-IIFE הגדול ב-`:649-784` ש-`_connectionGroups(p)` מזין — צריך גישה ל-`_switchByChip` (זמין, אותו state). (ג) `_RelatedCard` (`:1018`) מקבל `onTap` — להעביר את ה-callback הנכון לפי `_hopLive`. (ד) **אזהרה**: יש קרוסלות-חיבור **אחרות** דרך `_StripPanel._buildCompat` (`:2281`) ו-`_miniCarousel` (`:2765`) שכבר עוברות דרך `onPickProduct`→`_switchByChip` (`:2779`) — אלו **כבר** קפיצה-במקום, לא לגעת בהן. רק קרוסלת-ה-🔧-הראשית (`:769`) רקורסיבית.

**3. תקלות צפויות:** (א) **`showLipskeyProductSheet` הרקורסיבי בונה `categoryProducts` שונה** (`:773-778`, `kLipskeyCatalog.where(category==...)`) — קפיצה-במקום דרך `_switchByChip` **לא** משנה את `widget.categoryProducts`, אז ה-variant-pager בכותרת (`_InteractiveChips`, `:542`) ימשיך להראות את ה-siblings של המוצר-**המקורי**, לא של המוצר-שקפצנו-אליו. זו סטייה התנהגותית-עדינה (אבל מקובלת — `_chipOverride` כבר עושה זאת היום ב-strip-carousels). (ב) **`g.parts[i]` עשוי להיות מקטגוריה-אחרת** — `_partsForSize` (`:193`) מחזיר cross-category parts; קפיצה אליו במקום מציגה מוצר מקטגוריה-זרה תחת אותו sheet, מה שתקין אך ה-header/category-emoji ישתנו (זה הרצוי). (ג) **זהות-בייטים** — כש-`_hopLive==false`, ה-`onTap` חייב להישאר **בדיוק** `showLipskeyProductSheet(context, g.parts[i], kLipskeyCatalog.where(...).toList())` מילה-במילה. (ד) **double-tap** → שתי קפיצות; להגן (כמו ה-`_busy` debounce ב-`card_keyboard_screen.dart:313`) — אך הגיליון אין לו debounce כיום; `setState` כפול לא-מזיק (push-כפול → cap מ-75#9).

**4. פתרון:** (א) **לקבל את הסטייה** (variant-pager מציג siblings-מקוריים) כי זה כבר ההתנהגות של strip-carousels היום — או, טוב יותר, ב-`_switchByChip` לטעון מחדש את ה-siblings של המוצר-החדש (דרך `variantSiblingsOf(q)`) ל-state נלווה; אך זה הרחבה — לדחות ל-77/79 (rail-שכן). לתעד שב-76 ה-pager-מקורי הוא known-trade-off. (ב) תקין-בכוונה — header מתעדכן דרך `_current`. (ג) `if(_hopLive) _switchByChip(g.parts[i]) else showLipskeyProductSheet(...)` — ה-else מילה-במילה כמקור. (ד) להוסיף את אותו `_busy`-debounce לגיליון (או הגנת-`q.sku==_current.sku` מ-75#10) — מונע push-כפול.

**5. בדיקות:** `test/screens/sheet_switch_in_place_test.dart` (`forceLiveForTest:true`): (1) **`'tap על חלק-חיבור → אין sheet-שני'`** — לפמפ sheet, למצוא `_RelatedCard` בקרוסלת-🔧, לטפ, ולוודא `find.byType(LipskeyProductSheet)` עדיין **אחד** (לא 2) — היעד המרכזי. (2) `'tap → _current התחלף ל-part'` — אחרי הטפ, `_current.sku == g.parts[0].sku`. (3) `'tap → _hopHistory גדל ב-1'` (חזרה אפשרית). (4) **`'force OFF → tap פותח sheet שני (התנהגות-מקור)'`** — byte-identity: עם `forceLiveForTest:false`, הטפ קורא `showLipskeyProductSheet` (2 sheets) — מאמת שה-OFF-path לא-נגוע.

**6. שיפור:** לאחד את **כל** קרוסלות-המוצר בגיליון (🔧 ראשית + strip-compat + strip-variants + override-pairs) למסלול-`onPickProduct` יחיד שכולן חולקות, במקום שה-🔧-הראשית תהיה היחידה עם נתיב-רקורסיבי. זה מבטל את הא-סימטריה (חלקן קופצות-במקום, אחת פותחת-modal) ומפשט את 78 (breadcrumb) — מקור-קפיצה אחד. עלות: refactor של ה-IIFE הגדול ב-`:649-784`.

**7. ריאלי?:** כן, אטומי — שינוי-ניתוב ממוקד בנקודה-אחת (`:771`) מאחורי דגל. בר-בדיקה (בדיקה 1 חד-משמעית: 1 sheet במקום 2). תלוי ב-75 (`_hopHistory`). לא צריך פיצול.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF = בדיקה 4** (force:false → 2 sheets, נתיב-מקור). regression: כל טסטי-הגיליון הקיימים; במיוחד לוודא שלא שברתי את strip-carousels (`_buildCompat`/`_miniCarousel`) שכבר עבדו (לא נגעתי). אין-leak. לוודא ש-grep `showLipskeyProductSheet` בתוך הגיליון מראה את הקריאה רק ב-else-branch של ה-🔧-carousel + ב-`showLipskeyProductSheet`-הגלובלי.

**9. תכנון נוסף (שלי):** ב-`_switchByChip` (כש-`_hopLive`) **לרענן את `widget.categoryProducts`-המקומי** דרך `variantSiblingsOf(q)` או `categoryProducts==q.category`, השמור ב-`List _activeSiblings` חדש, כך שה-variant-pager בכותרת יתעדכן למוצר-החדש (פותר את תקלה א). בלי זה הקפיצה-במקום משאירה pager-מטעה.

**10. תכנון נוסף (שלי):** לכתוב **golden/byte-test על ה-IIFE של ה-🔧-carousel עם flag-OFF** — כי זה החלק הכי-מסובך בגיליון (`:649-784`, kit + groups + override-pairs) ושינוי-onTap עלול בטעות להזיז layout. golden-ON-OFF משווה מבטיח שרק ה-onTap השתנה, לא הרינדור.

---

### שלב 77 — rail 'קשור' גלוי-תמיד חושף כל קשתות-הוכחת-≤4 בתקציב

**1. יעד:** ל-`LipskeyProductSheet` יש **rail גלוי-תמיד** (כש-`_hopLive`) — שורת-שבבים "קשור" — שמרנדר את שכני-המוצר-הנוכחי לפי `rankedNeighborsOf(_current)` (פונקציה חדשה מעל `hopGraph`/`hubBackbone`), ושהוא **superset** של קשתות-ההוכחה (כל קשת שמסלול-ה-≤4 של 73 משתמש בה היא chip-rail לחיץ). לפני השלב, "מה-מתחבר" קיים רק כסטריפ-נפתח (`_StripKind.compat`, `:2281`) שדורש פתיחה. אחרי: rail-תמידי שמבטיח שמסלול-ה-≤4 **תמיד נגיש בלחיצה-אחת** מכל מוצר.

**2. איך בונים:** (א) `rankedNeighborsOf(card) → List<LipskeyCatalogProduct>` ב-`hop_graph.dart`/`hub_backbone.dart`: לאחד `neighborsOf(cardKey(card))` (כל הקשתות) עם **קשתות-ההוכחה** (`hubOf[card]` + מסלול אל superHub מ-73#10), לדרג (חיבור-פיזי לפני וריאנט לפני קטגוריה — דרך `EdgeKind` מ-71#9), ולחתוך לתקציב (למשל top-8). (ב) **חובת-superset**: התקציב לא יקצץ קשת-הוכחה — תמיד לכלול את `hubOf[card]` ואת מסלול-ההוכחה לפני שאר-השכנים. (ג) ווידג'ט `_HopRail` (rail אופקי של `_RelatedCard`-ים, כמו `_miniCarousel` `:2765`), שמוצב **קבוע** בגוף-ה-ListView (לא בתוך strip-נפתח) כש-`_hopLive`. (ד) כל chip `onTap: ()=>_switchByChip(q)` (קפיצה-במקום, 76). (ה) כותרת "קשור" + glyph.

**3. תקלות צפויות:** (א) **rail-ריק** — אם `rankedNeighborsOf` מחזיר ריק למוצר-כלשהו (מבודד לפני-hubs), ה-rail נעלם וחוזה-ה-≤4 נשבר — אבל זה בדיוק מה ש-79 מתקן (`kMinNeighbors`); 77 חייב להניח ש-73-הגב כבר חיבר הכל (`unreachableCount==0`), אז `hubOf[card]` תמיד קיים → לפחות שכן-אחד. (ב) **superset לא-מובטח** — אם `rankedNeighborsOf` מדרג-וחותך **לפני** שמוסיף את קשת-ההוכחה, הוא עלול לקצץ את ה-hub-edge; חייב להוסיף-קשתות-הוכחה-תחילה ואז למלא-תקציב. (ג) **הקשת בגרף אך לא בקטלוג-הגיליון** — `neighborsOf` מחזיר cardKeys; צריך למפות בחזרה ל-`LipskeyCatalogProduct` נציג (דרך `_cardReps` מ-71); אם הנציג נחתך מ-cap היסטורי → chip חסר. (ד) **זהות-בייטים** — rail גלוי-תמיד הוא **תוספת-נראית**; כש-`_hopLive==false` הוא **חייב להיעדר לחלוטין** (לא SizedBox עם padding — `if(_hopLive) _HopRail(...)` ללא else). (ה) **ביצועים** — `rankedNeighborsOf` נקרא ב-build; אם הוא רץ all-pairs-BFS זה כבד פר-frame; חייב להיות O(deg) (קריאת adjacency ממוקאש).

**4. פתרון:** (א) להישען על 73 (`unreachableCount==0`) כתנאי-מוקדם; 79 יהדק את ה-`kMinNeighbors`. (ב) `rankedNeighborsOf` בונה: `proof = proofEdgesOf(card)` (מ-73#10) **תחילה**, ואז `fill = sortedNeighbors \ proof` עד-תקציב — superset מובטח-בקונסטרוקציה. (ג) למפות cardKey→נציג דרך `_cardReps()` הלא-חתוך (71#פתרון-א). (ד) `if(_hopLive) _HopRail(...)` בלי else — היעדר-מוחלט ב-OFF. (ה) `rankedNeighborsOf` קורא רק adjacency ממוקאש + מסלול-הוכחה-מחושב-מראש (לא BFS-בזמן-build); אם דרוש, לממואיז פר-cardKey.

**5. בדיקות:** `test/features/card_keyboard/hop_rail_test.dart`: (1) **`'כל קשת-הוכחה היא שבב-rail'`** — לכל זוג-מוצרים-מדגם, להוציא את `proofPath` (73#10) ולוודא שכל-קצה בו מופיע ב-`rankedNeighborsOf` של נקודת-הקצה (**superset**). (2) `'rail לא-ריק לכל מוצר'` (מקדים את 79, אך כבר כאן: `expect(rankedNeighborsOf(p), isNotEmpty)` לכל `p∈hopNodes`). (3) `'דירוג: חיבור-פיזי לפני וריאנט'` — לבדוק סדר ה-`EdgeKind`. (4) `'דטרמיניסטי'`. + טסט-וידג'ט `test/screens/sheet_hop_rail_test.dart`: (5) `'force ON → rail "קשור" מרונדר; tap → קפיצה-במקום (1 sheet)'`. (6) **`'force OFF → אין rail "קשור"'`** (byte-identity).

**6. שיפור:** במקום rail-מוצרים גנרי, לקבץ את ה-rail לפי `EdgeKind` עם תוויות-מיני ("מתחבר" / "וריאנט" / "מאותה-קטגוריה") כך שהמשתמש מבין **למה** כל chip שם. זה גם הופך את 89 (rail רך 'מה מתחבר לזה') למיותר-כפילות — אפשר לאחד ל-rail-אחד-מקובץ. עלות: עיצוב-קיבוץ קל.

**7. ריאלי?:** כן, אבל **בגבול** — `rankedNeighborsOf` (לוגיקה+superset+דירוג) + ווידג'ט-rail + חיווט. בר-בדיקה (בדיקה 1 ה-superset היא הליבה). תלוי ב-73 (proof-edges) ו-75/76 (קפיצה-במקום). אפשר לפצל ל-77a (`rankedNeighborsOf` טהור + בדיקות 1-4) ו-77b (ווידג'ט _HopRail + בדיקות 5-6), אך הצימוד הדוק; להשאיר כאחד אם 73#10 כבר חשף `proofPath`.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF = בדיקה 6** (force:false → אין rail). **הליבה = בדיקה 1** (superset — בלעדיה חוזה-ה-≤4 דולף כי מסלול-ההוכחה לא-לחיץ). regression: טסטי-גיליון. אין-leak. לוודא ש-`rankedNeighborsOf` לא רץ BFS-בזמן-build (profile/assert על O(deg)).

**9. תכנון נוסף (שלי):** להדגיש-ויזואלית את **chip-ה-hub** (border-מותג/glyph north_east, התקדים #41 מ-`card_keyboard_screen.dart:239` + memory `fitting-prediction-chip`) — כי `hubOf[card]` הוא ה"קפיצה-החכמה" שמקצרת ל-≤4. בלי הבחנה, המשתמש לא יודע איזה chip מקדם הכי-הרבה.

**10. תכנון נוסף (שלי):** לחווט את ה-rail לכבד את `softTilt` (P9, `card_soft.dart`) **כסדר-בלבד** — כלומר אם מאוחר-יותר יש אות-היסטוריה/מתכון, השכנים מסתדרים-מחדש בתוך ה-rail אך **לעולם** לא נופלים ממנו (superset נשמר). להגדיר את ה-seam עכשיו (פרמטר `tilt` אופציונלי ל-`rankedNeighborsOf`, ברירת-מחדל אינרטי) מונע refactor ב-89/90.

---

### שלב 78 — 'חזרה' נוחת על השורה-הממוזגת + breadcrumb של מסלול

**1. יעד:** כפתורי X/back בגיליון מבצעים **קפיצת-מוצר-אחורה** (`_hopBack`, 75) ולא רק סגירה, ויש **breadcrumb** המציג את מסלול-הקפיצות (`_hopHistory`); ופתיחת-sheet **לא מנקה** את ה-stack של מקלדת-הכרטיס-שמתחת. לפני השלב, ה-X (`:426`, `Navigator.pop`) סוגר את כל ה-sheet ומאבד את כל מסע-הקפיצות. אחרי: back נוחת על המוצר-הקודם (ובתחתית-המחסנית — חזרה לשורה-הממוזגת של המסך-שמתחת), עם breadcrumb-נתיב.

**2. איך בונים:** (א) ווידג'ט `_HopBreadcrumb` שמרנדר `[product₀ › product₁ › _current]` מ-`_hopHistory` (כש-`_hopLive && _hopHistory.isNotEmpty`), כל פריט לחיץ → `_hopTo(index)` (קיצוץ ההיסטוריה לאינדקס). (ב) להציבו מתחת לכפתור-ה-X (`:412-438`) או בכותרת. (ג) **כפתור-back**: כש-`_hopLive && _hopHistory.isNotEmpty` → ה-X (או חץ-נוסף) קורא `_hopBack` (חזרה-מוצר) **במקום** `Navigator.pop`; כשההיסטוריה-ריקה → `Navigator.pop` (סוגר את ה-sheet, נוחת על מקלדת-הכרטיס שמתחת). (ד) **"פתיחת-sheet לא-מנקה-stack"**: זה נוגע ל-`card_keyboard_screen.dart` — `_pushStep`→`showLipskeyProductSheet` (`:211`) ו-`_onWordTap`→`showLipskeyProductSheet` (`:367`); לוודא שהם **לא** קוראים `_restart`/לא מנקים את `stack` בעת פתיחת-הגיליון, כך שסגירת-הגיליון מחזירה לאותה שורה-ממוזגת. (כיום הם **לא** מנקים — לאמת ולקבע בבדיקה.)

**3. תקלות צפויות:** (א) **X שמשנה-משמעות מסכן UX** — משתמש מצפה ש-X סוגר; אם X פתאום "חוזר-מוצר" זה מבלבל. עדיף **חץ-back נפרד** ל-`_hopBack` ו-X נשאר סגירה (אבל אז "back נוחת על השורה-הממוזגת" = סגירת-sheet כשההיסטוריה-ריקה). (ב) **breadcrump עם שמות-ארוכים** — `nameHe` ארוך (memory: "ליטוש תצוגת-רשימת-העבודות") יגלוש; צריך ellipsis/קיצור (`quickLabel`/`distinctSelectionLabels`). (ג) **`Navigator.pop` כפול** — אם back קורא pop וגם ה-modal-barrier קורא pop → קריסה; להגן (`_busy`/בדיקת-`mounted`). (ד) **זהות-בייטים** — breadcrumb ו-back-מותנה הם נראים; OFF → X רגיל (`Navigator.pop`), אין breadcrumb. ה-`else` של ה-X חייב להישאר `Navigator.pop(context)` מילה-במילה (`:426`). (ה) **ה-stack-של-המסך-מתחת** — אם בטעות הגיליון נפתח דרך route-שמנקה את `CardKeyboardScreen` (rebuild), ה-stack יאבד; לאמת שזה `showModalBottomSheet` (overlay, לא מחליף את המסך).

**4. פתרון:** (א) **חץ-back ייעודי** (לא לעמיס על X) — X=סגירה תמיד, חץ-back=`_hopBack` (גלוי רק כש-history לא-ריק). "נחיתה על שורה-ממוזגת" = כש-history-ריק אין חץ, ו-X סוגר → המסך-מתחת (שלא נוקה) מציג את השורה-הממוזגת. (ב) breadcrumb עם `Text(..., maxLines:1, overflow:ellipsis)` + `quickLabel(p)` קצר. (ג) הגנת-`_busy`/`if(!mounted)return` סביב pop. (ד) `else: Navigator.pop(context)` verbatim; `if(_hopLive) _HopBreadcrumb(...)`. (ה) בדיקת-וידג'ט: לפתוח sheet מעל `CardKeyboardScreen(forceLive)`, לסגור, ולוודא ש-`crumbs`/`verdict` של המסך לא-השתנו (stack נשמר).

**5. בדיקות:** `test/screens/back_lands_on_merged_row_test.dart`: (1) **`'פתיחת-sheet לא-מנקה stack של מקלדת-הכרטיס'`** — לבנות `CardKeyboardScreen(forceLive)`, לזרוע צעד, להגיע ל-ShowProducts, לטפ-מוצר (פותח sheet), לסגור (`Navigator.pop`), ולוודא `state.crumbs`/`state.verdict` **זהים** לפני-ואחרי (השורה-הממוזגת חזרה). (2) `'_hopBack מ-breadcrumb מקצר היסטוריה לאינדקס'`. (3) `'history-ריק → אין חץ-back, X סוגר'`. (4) `'breadcrumb מציג מסלול-קפיצות בסדר'`. (5) **`'force OFF → אין breadcrumb, X=Navigator.pop'`** (byte-identity).

**6. שיפור:** לאחד את ה-breadcrumb של הגיליון עם ה-`crumbs` של `CardKeyboardScreen` (`:175`) ל**מסלול-אחד רציף** — צעדי-הצלילה (מילה→חומר→...) ואז קפיצות-המוצר (product→product) באותה שורת-פירורים. זה נותן למשתמש מפה-אחת מהשאלה-הראשונה עד המוצר-הנוכחי, ומבטל את הפיצול בין "stack של המסך" ל-"history של ה-sheet". עלות: להעביר את ה-`crumbs` לגיליון (פרמטר).

**7. ריאלי?:** כן, אטומי — breadcrumb-ווידג'ט + הסטת-back מאחורי דגל. בר-בדיקה (בדיקה 1 ה-stack-preservation היא הליבה). תלוי ב-75/76. בדיקה 1 נוגעת ל-`card_keyboard_screen` אך לא משנה אותו (רק מאמתת התנהגות-קיימת) — לכן השלב בעיקר על הגיליון.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF = בדיקה 5**. **הליבה = בדיקה 1** (stack-preservation — בלעדיה "back נוחת על השורה-הממוזגת" שקרי). regression: כל טסטי-הגיליון + `card_keyboard_screen_test`. לוודא שלא הוספתי `_restart`/ניקוי-stack בנתיב-פתיחת-הגיליון (grep). אין-leak.

**9. תכנון נוסף (שלי):** **deep-link-stability** — ה-breadcrumb צריך להחזיק skus (לא אובייקטים) כדי שאם המוצר-בקטלוג מתעדכן, ה-breadcrumb עדיין מצביע-נכון, ובעתיד אפשר לשחזר מסע-קפיצות מ-URL/state. תואם 75#6 (sku-only).

**10. תכנון נוסף (שלי):** טיפול ב-**back-כפתור-מערכת (Android WillPopScope/PopScope)** — לחיצת-back-של-המכשיר על sheet-עם-history צריכה לעשות `_hopBack` (לקלף קפיצה) **לפני** סגירת-ה-sheet, אחרת המשתמש מאבד את כל המסע בלחיצת-back-אחת. בלי `PopScope` שמיירט, ה-back-הפיזי סוגר מיד. זה תכנון-קריטי-ל-Android שהשלב משמיט.

---

### שלב 79 — rail-שכן לעולם לא-ריק (אין מוצר מבוי-סתום)

**1. יעד:** `rankedNeighborsOf` (77) מובטח להחזיר **≥ `kMinNeighbors`** שכנים לכל מוצר ב-`hopGraph` — **כולל** ה-81 כרטיסי מים-חמים — דרך נפילה היררכית hub → קבוצה/וריאנט → קטגוריה. לפני השלב, מוצר-עלה-מבודד או מוצר-ללא-spec עלול לקבל rail-ריק (מבוי-סתום). אחרי: אין כרטיס מבוי-סתום; ה-rail תמיד נותן ≥kMinNeighbors כיווני-יציאה, מה שמבטיח שחוזה-ה-≤4 לעולם לא נקטע ע"י "אין-לאן-לקפוץ".

**2. איך בונים:** (א) `const int kMinNeighbors = 3;` (OWNER-REVIEW). (ב) ב-`rankedNeighborsOf`, אחרי איסוף הקשתות-הישירות + הוכחה (77), אם `result.length < kMinNeighbors` → **נפילה היררכית**: (1) להוסיף את `hubOf[card]` + שכני-ה-hub; (2) אם עוד חסר — `variantSiblingsOf(card)` (אותה משפחה); (3) אם עוד חסר — מוצרים מאותה `categoryHe` (fallback אחרון, תמיד לא-ריק כי המוצר עצמו בקטגוריה ≥1 אחר, או הקרובים-קטגורית). (ג) לדדפ ולחתוך-לתקציב, אך לעולם לא מתחת ל-`kMinNeighbors` (אלא אם היקום עצמו קטן מ-kMinNeighbors). (ד) לוודא שזה חל גם על מים-חמים (skus 'HW-…' שאין-להם spec → `connectionsFor`=ריק, אז הנפילה לקטגוריה/וריאנט קריטית).

**3. תקלות צפויות:** (א) **מים-חמים ללא-spec ו-ללא-וריאנטים** — `kHotWaterCatalog` synthetic; `variantSiblingsOf` עובד על `kCatalogProducts` (`related_info.dart:476`) ש**לא** כולל מים-חמים! אז ל-HW-card, גם הנפילה-לוריאנט מחזירה ריק → צריך fallback-קטגוריה שעובד על `kDivePool` (לא `kCatalogProducts`). (ב) **fallback-קטגוריה גם ריק** — אם קטגוריית-המוצר יחידנית (מוצר-אחד בקטגוריה), אפילו category-fallback ריק; אז ה-fallback-האחרון חייב להיות `hubOf`/superHub (תמיד קיים אחרי 73). (ג) **`kMinNeighbors > גודל-היקום-בפועל`** למוצר-מבודד-קיצוני → אי-אפשר למלא; הבדיקה חייבת להתנות "≥min(kMinNeighbors, available)". (ד) **זהות-בייטים** — `rankedNeighborsOf` נקרא רק תחת `_hopLive` (77), אז 79 לא-נוגע-בפרודקשן-OFF. (ה) **דירוג-יציבות** — ה-fallback מוסיף-בסוף; לוודא שהתוספת דטרמיניסטית (ממוין).

**4. פתרון:** (א) ה-category-fallback חייב לעבוד על **`kDivePool`** (`p.categoryHe == card.categoryHe`), לא על `kCatalogProducts`, כדי לכסות מים-חמים. (ב) שרשרת-fallback מסתיימת תמיד ב-`hubOf[card]`+superHub (קיים אחרי 73 `unreachableCount==0`) — ערובה אבסולוטית ל-≥1. (ג) הבדיקה: `expect(rankedNeighborsOf(p).length, greaterThanOrEqualTo(min(kMinNeighbors, hopNodes.length-1)))`. (ד) `_hopLive`-gated (יורש מ-77). (ה) כל שלב-fallback ממיין לפני-הוספה (cardKey/page).

**5. בדיקות:** `test/features/card_keyboard/hop_rail_nonempty_test.dart`: (1) **`'כל מוצר ≥kMinNeighbors'`** — `for p in hopNodes: expect(rankedNeighborsOf(p).length >= min(kMinNeighbors, hopNodes.length-1))` — **ממצה על כל היקום**. (2) **`'81 מים-חמים ≥kMinNeighbors'`** — לסנן `kHotWaterCatalog` ולאמת לכל אחד (תקלה א — המקרה הכי-שביר). (3) `'מוצר-קטגוריה-יחידנית עדיין ≥1 (hub-fallback)'`. (4) `'fallback דטרמיניסטי'`. (5) `'אין self ב-rail'` (`isNot(contains(card))`).

**6. שיפור:** במקום fallback-היררכי בזמן-קריאה (שיכול להפתיע עם דירוג-מעורב), **לחזק את `hopGraph` עצמו ב-71/73** כך שכל-צומת כבר מובטח deg≥kMinNeighbors בקונסטרוקציה (להוסיף קשתות-קטגוריה עד שכל-צומת רווי). אז `rankedNeighborsOf` הוא רק "קרא+דרג+חתוך" בלי fallback-מיוחד, וההבטחה היא תכונת-גרף ולא תכונת-פונקציה — נקי יותר ובדיק יותר (בדיקה על הגרף, לא על הקריאה).

**7. ריאלי?:** כן, אטומי — חיזוק-קצה של `rankedNeighborsOf` עם fallback. בר-בדיקה (בדיקה 1 ממצה). תלוי ב-73 (hub) ו-77 (`rankedNeighborsOf`). מקרה-מים-חמים (תקלה א) הוא הסיכון-האמיתי; בדיקה 2 תופסת אותו. לא צריך פיצול.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. זהות-בייטים flag-OFF טריוויאלית (כל הלוגיקה תחת `_hopLive`/בקובץ-גרף-טהור ללא-קוֹרֵא-פרודקשן-OFF). **המלאות = בדיקות 1+2** (כל-היקום כולל מים-חמים). regression: חבילת-`card_keyboard` + טסטי-הגרף (71-73). אין-leak (טהור). אם שיניתי את `hopGraph` (שיפור 6) — בדיקת-71 (`nodeSet`/אין-וירטואלי) חייבת לחזור ירוקה (קשתות נוספו, צמתים לא).

**9. תכנון נוסף (שלי):** **לוג/assert-debug של "מוצרים שנפלו ל-category-fallback"** — אם מוצר מגיע ל-fallback-האחרון, זה מסמן שהגרף דליל-מדי שם; רשימת-ה-offenders היא קלט-עיצוב חשוב (כמו census). בלי זה, fallback-קטגוריה מסתיר חולשת-גרף שתחזור לרדוף ב-80.

**10. תכנון נוסף (שלי):** לחשוף `Map<String,int> degreeReport` (cardKey→deg-לאחר-fallback) ולקבע **golden נומרי על המינימום** (`minDegree >= kMinNeighbors`). זה הופך את "לעולם-לא-ריק" ממדידה-חד-פעמית למשמר-רגרסיה: כל שינוי-קטלוג שמייבש צומת ייתפס בדיף, לא רק כשהשער-המרכזי (100) נופל.

---

### שלב 80 — מפקד ≤4-קפיצות ממצה דרך הגרף-הלחיץ (שער-קשיח)

**1. יעד:** קיים **מפקד-ממצה** (census) שמריץ BFS על **אותן קשתות שה-rail מציג בפועל** (`rankedNeighborsOf`, לא הגרף-הגולמי) ומוכיח שכל זוג-כרטיסים נגיש ב-**≤4** קפיצות; הוא **נכשל-קשיח** על כל זוג>4 מול `kHopPairOverride` (allowlist מצטמצם), כך ש**הבילד נופל** אם זוג חורג. לפני השלב, ≤4 מובטח רק בקונסטרוקציה (73) אך לא נאמת על ה-rail-הנראה. אחרי: הוכחה אמפירית שה-rail-הלחיץ-בפועל מקיים ≤4, עם שער-CI קשיח.

**2. איך בונים:** (א) `hop_census.dart`/טסט: לבנות adjacency **מ-`rankedNeighborsOf`** (לא מ-`neighborsOf` הגולמי!) — כי זה מה שהמשתמש באמת יכול ללחוץ: `railAdj[cardKey(p)] = {for q in rankedNeighborsOf(p): cardKey(q)}`. (ב) all-pairs-BFS על `railAdj`; לאסוף זוגות עם `dist>4` או `dist==∞`. (ג) `const Set<(String,String)> kHopPairOverride = {}` (מתחיל ריק; כל ערך = חוב מתועד). (ד) `expect(offenders \ kHopPairOverride, isEmpty)` — כשל-קשיח. (ה) **חיווט ל-`verify_card_keyboard.ps1`** (שלב 100) כך שהבילד נופל על offender. (ו) ה-BFS חייב להיות **all-pairs אמיתי** (לא double-BFS-אומדן מ-72) כי זו הוכחה, לא ספייק.

**3. תקלות צפויות:** (א) **a-סימטריה של `rankedNeighborsOf`** — ייתכן ש-`q∈rankedNeighborsOf(p)` אבל `p∉rankedNeighborsOf(q)` (דירוג+חיתוך-תקציב שונה לכל צד)! אז ה-rail-adjacency **לא סימטרי**, וקפיצה p→q אפשרית אך לא q→p — ה-BFS חייב לכבד את הכיווניות-האמיתית (כי המשתמש קופץ דרך ה-rail של המוצר-הנוכחי). זו ההפתעה-הגדולה: ההוכחה ב-73 הייתה על גרף-לא-מכוון, אבל ה-rail-בפועל **מכוון**. (ב) **תקציב-החיתוך שובר ≤4** — אם 77 חתך את התקציב והשמיט קשת-הוכחה לצומת-מסוים, ה-rail-adjacency מאבד את הקצה וה-dist קופץ >4. זה בדיוק למה 77 דורש **superset** (קשת-הוכחה לעולם לא-נחתכת) — 80 הוא האימות שזה אכן קרה. (ג) **עלות all-pairs** — O(N²) על מאות-צמתים, כבד; עלול לקרוס isolate (memory gate-flakiness). (ד) **offender אמיתי** → הבדיקה אדומה; הפיתוי לדחוף ל-`kHopPairOverride` במקום לתקן את הגרף — אסור (allowlist=חוב, לא-פתרון). (ה) **דטרמיניזם** — סדר-offenders חייב יציב.

**4. פתרון:** (א) **לבנות `railAdj` מכוון** ולהריץ BFS מכוון — לכבד את הכיווניות. **או**, טוב יותר: לאכוף ב-77/79 ש-`rankedNeighborsOf` **סימטרי-הדדי** (אם q ב-rail של p, להוסיף p ל-rail של q) — אז ה-rail-graph לא-מכוון וההוכחה-של-73 חלה ישירות. זו ההחלטה-הקריטית: **לדרוש הדדיות** ב-77. (ב) ה-superset-של-77 (קשת-הוכחה תחילה, לפני מילוי-תקציב) מבטיח שהקצה לא-נחתך; 80 מאמת. (ג) להריץ עם `--concurrency=1`/retry-wrap/`taskkill dart` (זיכרון gate-flakiness); לממואיז `rankedNeighborsOf`. (ד) **כלל-ברזל**: offender → **לתקן את הגרף/הגב** (להוסיף קשת-קטגוריה/hub), `kHopPairOverride` נשאר ריק; כל ערך בו דורש תיעוד-חוב מפורש. (ה) offenders ממוינים-לקסיקלית.

**5. בדיקות:** `test/features/card_keyboard/hop_census_test.dart`: (1) **`'כל זוג-כרטיסים ≤4 דרך ה-rail-הלחיץ'`** — all-pairs-BFS על `railAdj`; `expect(offenders.difference(kHopPairOverride), isEmpty)` — **הבדיקה-המרכזית, ממצה**. (2) `'BFS על rail-graph, לא על גרף-גולמי'` — לאמת ש-adjacency נבנה מ-`rankedNeighborsOf` (לא `neighborsOf`). (3) **`'rail-graph הדדי'`** (אם בחרנו פתרון א-הדדיות) — `q∈rail(p) ⟺ p∈rail(q)`. (4) `'כולל מים-חמים בזוגות'` — לדגום זוג HW↔non-HW ולאמת ≤4. (5) `'kHopPairOverride ריק (אין-חוב)'` — `expect(kHopPairOverride, isEmpty)` (אם אכן ריק; אחרת מתעד). (6) `'offenders דטרמיניסטי'`.

**6. שיפור:** במקום all-pairs O(N²) יקר, להוכיח ≤4 **קומבינטורית מהגב** (73): אם כל-צומת ≤1 מ-hub וכל hub ≤2 מ-superHub, ו-ה-rail **כולל** את קשתות-הגב (superset, 77+79), אז ≤4 נובע **בלי BFS-מלא**. ה-census הופך לאימות-נקודתי (דגימת-זוגות + אימות-הגב) במקום all-pairs ממצה. זה חוסך זמן-CI עצום ומסיר את סיכון-קריסת-ה-isolate. ה-all-pairs נשאר כטסט-nightly-מלא בלבד.

**7. ריאלי?:** **בגבול — שוקל פיצול.** ה-census-הממצה (all-pairs) + השער-הקשיח + ה-override + החיווט-ל-ps1 הם הרבה. אני מציע: **80a** = `railAdj` + BFS-census + `kHopPairOverride` + בדיקות 1-6 (ההוכחה); **80b** = חיווט ל-`verify_card_keyboard.ps1` שמפיל-בילד (זה שייך יותר ל-100, אפשר לדחות). אם 73#10 כבר נתן `proofPath`+הדדיות, 80 מצטמצם ל-אימות ונשאר אטומי.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. זהות-בייטים flag-OFF טריוויאלית (census=טהור, אפס-קוֹרֵא-פרודקשן). **המלאות = בדיקה 1** (כל-הזוגות ≤4, ממצה) — זו **ההוכחה הסופית** של חצי-ה-≤4 של החוזה. להריץ עם concurrency=1+retry (יציבות-isolate); להריץ **פעמיים** (דטרמיניזם). regression: כל חבילת-הגרף (71-79) + `card_keyboard`. לאמת ש-`kHopPairOverride` ריק (אין-חוב מוסתר). אם offender נמצא — **לא לסגור את השלב** עד שהגרף/גב תוקן (לא override).

**9. תכנון נוסף (שלי):** **eccentricity report** — לפלוט לכל-צומת את המרחק-המקסימלי-שלו (eccentricity); צמתים עם ecc==4 (על-הגבול) הם המועמדים-הראשונים להישבר בשינוי-קטלוג עתידי. רשימה-זו היא early-warning לפני שזוג חוצה ל-5. בלי זה, השער נופל פתאום בעתיד בלי-התראה-מקדימה.

**10. תכנון נוסף (שלי):** לקבע ש-80 חולק את **אותה adjacency** ש-`hopsBetween()` (שלב 90) יבנה — להגדיר עכשיו `railAdjacency` ציבורי יחיד ב-`hop_graph.dart` ש-80, 90 ו-77 כולם קוראים, כדי שלא ייווצר "גרף שלישי" (האזהרה המפורשת ב-90/בהוכחת-החוזה). זו אמת-יחידה שמונעת שלוש-מימושי-BFS-שמסתפצלים — הטעות הקלאסית ש-90 בא למנוע.

</div>

<div dir="rtl">

# פירוק מפורט — שלבים 81–90 (זנב P8 + כל P9: אותות-נסתרים)

> מעוגן בקוד האמיתי תחת `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל ההפניות הן ל-`lib/features/card_keyboard/`, `lib/features/word_finder/`, `lib/screens/lipskey_product_sheet.dart` ו-`lib/widgets/smart_input/keyboard/` בעץ הזה בלבד (כל קלון תחת `New folder/buildsmart` הוא **STALE** ולא נקרא).
>
> **הקשר-המאקרו:** שלב 81 חותם את P8 (גרף-הקפיצה) — אודיט זהות-בייטים flag-OFF לכל אזור-הקפיצה (שלבים 75–78 בכרטיס). שלבים 82–90 הם P9 "אותות-נסתרים": תאימות/מתכון/היסטוריה נכנסים כ**משקל-רך** (`softTilt`) שרק *מסדר-מחדש בתוך ציר* — לעולם לא מוסיף/מפיל שבב ולעולם לא יוצר ענף-ניתוב; שבבי-יעד #41 (`isDestination`) ליד-התכנסות; וגרף-rail אחד קנוני שגם `hopsBetween` (90) וגם מפקד-80 מיושבים אליו (אין גרף שלישי).
>
> **מצב-בסיס קריטי שמצאתי בקוד (משפיע על כל 10 השלבים):**
> - `card_engine.dart` **כבר ממומש מלא** — ה-docstring "PHASE 0 stubbed" (שורות 10–14) **מיושן**; `_mergedChips` (217–297) בנוי, ממיין צירים ב-cross-multiply שלם (267–272), פורש best-axis-first עם floor/cap (277–295), ו-`representativeTake` (308–317) שומר קצוות. ה-docstring (203–213) **כבר מתעד** ש-"realising Phase 3 will mean giving each SignalChip a computed per-chip weight and replacing the per-axis positional take with a per-axis scored top-K — a restructure of this loop, not just populating SignalChip.infoGain (today always 0)". זו **בדיוק** משימת שלב 84.
> - `card_soft.dart` **כבר קיים** (48 שורות): `anchorOf(pool)` (34–37, מחזיר מוצר רק כש-`distinctCardCount==1`, אחרת null) + `softSuggestionsFor(anchor)` (43–47, delegate ל-`connectionsFor`). ה-docstring (1–22) מצהיר במפורש ש**הסופט אינרטי במיזוג** (anchor תמיד null שם). **`softTilt` עדיין לא קיים** — שלב 82 יוצר אותו. **`kitSkusFor`/`softAnchor` עדיין לא קיימים** — שלב 83.
> - `card_signals.dart`: `SignalChip` (ב-`card_engine.dart:43-94`) משווה רק שדות-נתונים (81–93), `infoGain=0` תמיד, `soft=false` תמיד לשבב-נפלט. אין שדה `isDestination`.
> - `word_keys_model.dart`: `WordKey` (8–43) מחזיק `label,payload,imageAsset,semanticLabel,axisGlyph` — **אין `isDestination`** (שלב 86 מוסיף). `word_keyboard.dart` מעביר את כולם ל-`BsKey` (74–93).
> - `bs_keyboard.dart`: `_PredictionChip` (825+) **כבר** מחזיק `isDestination` עם הרינדור-המוכח של #41 (north_east glyph + brand-wash + brand-border, שורות 884–909) ו-`destinationChips` (756). זה ה**תקדים-המוכח** ששלבים 85–87 ממראים ל-`WordKey`/`BsKey` (שעדיין אין להם זאת). `BsKey` (`bs_key.dart`) כבר מטפל ב-`axisGlyph` בענף-render (204–213) — אותו מבנה ש-`isDestination` ייכנס לידו.
> - `lipskey_product_sheet.dart`: `_chipOverride`+`_switchByChip` (121,364–371) = קפיצה-במקום קיימת; אבל ב-שורה **771** קרוסלת-החיבורים עדיין `onTap: () => showLipskeyProductSheet(...)` — **sheet רקורסיבי** (תקלת-שלב-76/78). `connectionsFor`/`isConnectionAnchor` ב-`word_finder_engine.dart:570-598` הם השער היחיד לתאימות; `compatibleWith` (`install_engine.dart:522`) ממומאז על `kCompatCatalog`. הדגל `kCardKeyboardFlag='kCardKeyboard'` OFF כברירת-מחדל, נקרא פעם-אחת ב-`_live` (`card_keyboard_screen.dart:124`).
>
> **הערת-מסגרת:** שלבים 75–81 (אזור-הקפיצה בכרטיס) ושלב 89 (rail הצעות) טרם נבנו בעץ — `hop_graph.dart`, `_hopHistory`, `rankedNeighborsOf`, `kHopPairOverride`, `hopsBetween` עדיין לא קיימים (אומת ב-grep: 0 פגיעות תחת `lib/`). הפירוק להלן מניח שהם נבנו ב-71–80 ומתאר את ה-deltas של 81–90 מעליהם, מעוגן בקוד-האמת הקיים.

---

### שלב 81 — שמירת זהות-בייטים flag-OFF לאזור-הקפיצה
**1. יעד:** קיים שער-אודיט אוטומטי (`test`) שמוכיח שכל הוספות שלבים 75–78 לכרטיס-המוצר (מחסנית-קפיצה `_hopHistory`, קפיצה-במקום בקרוסלה, rail 'קשור' גלוי-תמיד, נחיתת-'חזרה' על השורה-הממוזגת+breadcrumb) הן **dark כש-`kCardKeyboardFlag` OFF**: `LipskeyProductSheet` שנפתח במצב-פרודקשן (הדגל כבוי) מרנדר **בדיוק** את מה שרינדר לפני שלב 75 — אפס rail, אפס breadcrumb, אפס מחסנית. לפני השלב הקוד החדש קיים אך לא הוכח-שקול; אחרי השלב יש assertion שתופס כל דליפה ל-render-tree של הפרודקשן.

**2. איך בונים:** (א) הקפיצה-זונה צריכה seam-דגל מפורש: שלב 74 כבר הוסיף `forceLive` ל-`LipskeyProductSheet` (מקביל ל-`forceLiveForTest` ב-`card_keyboard_screen.dart:106`). לכן הענפים החדשים בכרטיס נשמרים מאחורי `final bool _hopLive = forceLive || ref.read(featureFlagsProvider).contains(kCardKeyboardFlag)` (נקרא פעם-אחת — כמו `_live` ב-screen:124). (ב) לעטוף את כל ה-deltas של 75–78 ב-`if (_hopLive) ...`: ה-rail 'קשור' (77), ה-breadcrumb (78), כפתור-'חזרה'-קופץ-מוצר (78). (ג) **הקרוסלה (76) היא היוצא-דופן** — `_switchByChip` כבר *קיים בפרודקשן*; שינוי 76 הוא רק *ניתוב ה-onTap* מ-`showLipskeyProductSheet` (771) ל-`_switchByChip`. שינוי-התנהגות זה צריך גם-הוא להיות מגודר: `onTap: _hopLive ? () => _switchByChip(...) : () => showLipskeyProductSheet(...)`. (ד) הבדיקה: שני pump-ים של ה-sheet — אחד `forceLive:false` (פרודקשן) ואחד `forceLive:true` — ולאסוף את ה-widget-types/Text הנוגעים, ולאמת שב-OFF ה-rail/breadcrumb **נעדרים** (`findsNothing`).

**3. תקלות צפויות:** (א) **flag-race** — אם `_hopLive` נקרא ב-`build()` במקום פעם-אחת ב-`initState`/`late final`, טעינת-prefs מאוחרת תחליף את ה-render באמצע-צפייה (אותה מלכודת ש-screen:124 פותר עם `late final _live`). (ב) **דליפת-קרוסלה הופכת** — שינוי 76 מנתב את ה-onTap הקיים; אם נשכח לגדר אותו, ה-OFF **כבר לא יפתח sheet שני** והפרודקשן ישתנה (זה לא רק תוספת — זו *החלפת-התנהגות* של קוד-חי). (ג) **`forceLive` לא מספיק לכל הענפים** — אם 77/78 מסתמכים על ספק-היסטוריה (88) שטרם קיים, הבדיקה תיכשל על dep חסר ולא על זהות. (ד) **byte-identity != widget-identity** — `findsNothing` על rail מספיק לכאן, אבל overflow/padding דק יכול לזוז גם בלי rail; להשוות גם את `tester.getSize` של הגוף.

**4. פתרון:** (א) `late final bool _hopLive = ...` בראש ה-state, **לא** ב-build — בדיוק כמו `_live`. (ב) לגדר את **שלושת** ניתובי-ה-onTap בקרוסלה (771 + שתי קריאות `showLipskeyProductSheet` נוספות בקובץ, שורות ~566/?) פרטנית, עם הערת "76: hop-in-place ON, recursive-sheet OFF — production unchanged". (ג) הבדיקה **לא** תלויה ב-88: לפצל — `back_lands_on_merged_row_test` (78) ו-`rail_visible_test` (77) רצים עם `forceLive:true` ו-`categoryProducts` קשיח (לא ספק-היסטוריה). (ד) להוסיף `expect(tester.getSize(find.byType(LipskeyProductSheet)), equalsOFF)` בין שני ה-pumps.

**5. בדיקות:** `test/screens/hop_zone_byte_identity_test.dart`: (1) `'flag OFF → אין rail קשור'` — pump עם `forceLive:false`, `expect(find.text('מה מתחבר לזה'), findsNothing)` + `expect(find.byType(_HopRail), findsNothing)` (או הסמן שבחר 77). (2) `'flag OFF → אין breadcrumb'` — `findsNothing` על widget-ה-breadcrumb. (3) `'flag OFF → קרוסלה פותחת sheet שני (התנהגות-פרודקשן נשמרת)'` — tap על `_RelatedCard`, `expect(find.byType(LipskeyProductSheet), findsNWidgets(2))` (מאמת שב-OFF הרקורסיה **נשמרה**, לא ניתבה). (4) `'flag ON → קרוסלה לא פותחת sheet שני'` — `forceLive:true`, tap, `findsOneWidget`. (5) `'גודל-גוף זהה ON/OFF בפתיחה ללא-קפיצה'` — `getSize` שווה.

**6. שיפור:** במקום bool יחיד `_hopLive` המפוזר על ~5 ענפי-`if`, לחלץ getter בודד `_HopChrome? get _hop => _hopLive ? _HopChrome(...) : null` ולרנדר `if (_hop != null) _hop.rail(...)` — מרכז את הגדר-הדגל בנקודה אחת, מקטין סיכון של ענף-לא-מגודר שנשכח (התקלה הכי מסוכנת כאן), ומקל על שלב 100 להסיר את הגדר.

**7. ריאלי?:** כן, אטומי — זה שלב-אודיט שלא מוסיף לוגיקה אלא *מוודא* את 75–78. ה**סיכון** היחיד הוא שהוא חושף שאחד מ-75–78 לא גודר נכון (אז התיקון שייך לשלב-המקור, לא כאן). הבדיקה עצמה ~60 שורות. אין צורך לפצל.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. להריץ את כל חבילת ה-sheet הקיימת (`sheet_close_test`, `product_sheet_strips_test`, `favorite_tile_opens_sheet_test`, `card_interactions_test`) — חייבות להישאר ירוקות (הן רצות ב-OFF, ומאמתות שזהות-הבייטים החזיקה). להריץ `card_keyboard` המלאה (4 קבצים). grep ש-`forceLive`/`_hopLive` מופיע רק בכרטיס. אין-leak: `ensureSemantics().dispose()` בסוף-גוף (לא `addTearDown` — מלכודת ה-handle-leak ש-screen_test:52 מתעד).

**9. תכנון נוסף (שלי):** השלב מאמת זהות *ויזואלית* אך לא *פעולתית* — ב-OFF, `addPick`/מחסנית-קפיצה לא צריכים גם להריץ side-effects (כתיבה ל-provider). להוסיף assertion: ב-`forceLive:false`, פתיחה+tap לא משנים אף provider (קרא `recentlyViewedProvider`/`cardPicksProvider` לפני ואחרי → שווים). זה תופס דליפת-state-write שהיא בלתי-נראית ל-`findsNothing`.

**10. תכנון נוסף (שלי):** golden-snapshot (PNG) של ה-sheet ב-OFF — `test/screens/goldens/sheet_hop_off.png` — כעוגן-רגרסיה קשיח מעבר ל-`findsNothing`. הקובץ כבר משתמש ב-goldens במקומות אחרים (תיקיית `smart_input/.../goldens`), והוא תופס זחילת-pixel דקה (border/wash) שטסט-מבנה מפספס. נועל את "זהה-בייטים" כפשוטו.

---

### שלב 82 — `softTilt()`: משקל-רך טהור לכל-שבב
**1. יעד:** קיימת פונקציה טהורה `double softTilt(SignalChip chip, {LipskeyCatalogProduct? anchor, Set<String> kitSkus = const {}, Set<String> historySkus = const {}, int tempC = 20})` (ב-`card_soft.dart`) שמחזירה מכפיל ב-`[1.0, ~1.6]`: 1.0 כשאין-עוגן (אינרטי), >1.0 כשהשבב חופף ל-חיבור/מתכון/היסטוריה של העוגן. לפני השלב `card_soft.dart` מחזיק רק `anchorOf`+`softSuggestionsFor`, וה-docstring (16) מבטיח ש"softTilt ≡ 1.0" אך **הפונקציה עצמה לא קיימת**. אחרי: ה-tilt מוגדר, טהור, ודטרמיניסטי — אך עדיין לא-מחווט (84 משלב אותו ל-`_mergedChips`).

**2. איך בונים:** (א) ב-`card_soft.dart` (טהור — אותם imports: `lipskey_catalog.dart` + `word_finder_engine.dart show connectionsFor`; להוסיף `recipe_kit.dart` ל-kit אם נדרש — אך ה-kitSkus מועברים כפרמטר, ר' 83, כדי לשמור טוהר-חישוב). (ב) חתימה כנ"ל. (ג) לוגיקה: `if (anchor == null) return 1.0;` (early-out אינרטי — תואם §1.5). אחרת לחשב 3 בוליאני-חפיפה: `connHit = connectionsFor(anchor, tempC: tempC).any((c) => _chipMatchesSku(chip, c))`, `kitHit = kitSkus...`, `histHit = historySkus...`. (ד) צבירה **מוגבלת**: `1.0 + 0.2*connHit + 0.2*kitHit + 0.2*histHit` עם clamp ל-1.6 (קבועים `kSoftConnW/kSoftKitW/kSoftHistW`, OWNER-REVIEW). (ה) **`_chipMatchesSku`** — שבב-ציר (size/material/...) חופף ל-sku אם `SignalSource.matches(product, chip)` מחזיר true עבור אותו מוצר; כדי לא לייבא את כל ה-sources, להשוות ע"י `chip.value` מול ה-token-set של המוצר, או להעביר predicate. החלטה: לעבוד ברמת-מוצר — לקבל `Set<LipskeyCatalogProduct>` ולא sku, כדי שהבדיקה תהיה `softSet.any((p)=>src.matches(p,chip))`. (ו) docstring: "1.0 inert when anchor==null; only RE-ORDERS within an axis (84) — never adds/drops a chip".

**3. תקלות צפויות:** (א) **דליפת-טוהר/ביצועים** — `connectionsFor` ממומאז (`install_engine.dart:524 _compatCache`) אך עדיין O(kCompatCatalog); קריאתו *פר-שבב* ב-loop של `_mergedChips` תהיה O(chips×|compat|) — חורג מתקציב-הביצועים ש-screen:140 כבר נלחם עליו (memo פר-keystroke). (ב) **float כ-מפתח-מיון** — אם `softTilt` יוזרק ל-comparator של `_mergedChips` (267) שהוא **integer cross-multiply** מכוון (docstring:180 "no float is ever a sort key"), נשבר אינווריאנט-הדטרמיניזם (ULP near-ties / NaN). (ג) **חוסר-קומוטטיביות** — אם הצבירה תלויה בסדר-בדיקת-3-המקורות עם short-circuit, שבב יכול לקבל tilt שונה; חייב להיות סכום-מכפילים בלתי-תלוי-סדר. (ד) **anchor==null במיזוג** — בפועל `softTilt` במיזוג *תמיד* יקבל anchor=null (כי המיזוג רץ רק על בריכה גדולה, `card_soft.dart:30`), אז כל ה-tilt-לוגיקה **מתה-קוד במיזוג** — וזו תכונה רצויה, אך בדיקה חייבת לתעד שלא ניסינו "לתקן" זאת.

**4. פתרון:** (א) לחשב את שלוש-הקבוצות (conn/kit/hist) **פעם-אחת לפני ה-loop** ב-84 (לא פר-שבב) ולהעבירן ל-`softTilt` כ-`Set` מוכנות — `softTilt` עצמה לא קוראת `connectionsFor` אם הקבוצות מוזרקות. (לכן החתימה ב-(ב) מקבלת sets, לא קוראת ל-engine ישירות — `connectionsFor` נשאר רק כ-default-helper לבדיקות.) (ב) **לא** להזריק float ל-comparator הקיים — שלב 84 ישנה את ה**מבנה** ל-top-K-משוקלל (כפי ש-`card_engine.dart:207-210` כבר מנבא), ושם המיון יהיה על `baseWeight*softTilt` בתוך-ציר עם tie-break שלם; הדירוג **בין-צירים** (cross-multiply) נשאר שלם ולא-נגוע. (ג) צבירה = סכום (`1.0 + Σ wᵢ·hitᵢ`), קומוטטיבי מעצם-הגדרתו. (ד) בדיקה מפורשת: `softTilt(chip, anchor: null, ...)==1.0` תמיד.

**5. בדיקות:** `test/features/card_keyboard/card_soft_test.dart` (להרחיב את הקיים): (1) `'tilt==1.0 אינרטי (anchor null)'` — לכל מדגם-שבב, `expect(softTilt(c, anchor: null), 1.0)`. (2) `'חופף → >1.0'` — anchor אמיתי + שבב שערכו תואם sku-חיבור → `expect(greaterThan(1.0))`. (3) `'תקרה 1.6'` — שלושת ה-hit דולקים → `expect(lessThanOrEqualTo(1.6))`. (4) `'קומוטטיבי/דטרמיניסטי'` — אותם קלטים בסדר-הזרקה שונה → ערך זהה. (5) `'אין side-effect/IO'` — קריאה כפולה זהה (טוהר). (6) `'מיזוג: anchorOf(kDivePool)==null ⇒ tilt אינרטי'` — מקשר ל-`card_soft.dart` הקיים.

**6. שיפור:** במקום 3 משקלים שווים (0.2 כ"א), לשקלל לפי-מהימנות: חיבור-מאומת (`isConnectionAnchor` gate, geometry verified) ראוי ל-tilt חזק יותר ממתכון-`ambiguous` (`KitMatch.ambiguous`, `recipe_kit.dart:253`). להעביר את ה-tilt-per-source מ-`KitMatch` enum → משקל, כך שמתכון-`auto` (140 score) דוחף יותר מ-`ambiguous`. עדיין שלם-בתוך-ציר.

**7. ריאלי?:** כן, אטומי במלואו — פונקציה טהורה ~25 שורות, אפס-מצב, אפס-UI, אפס-חיווט. ה-early-out `anchor==null→1.0` הופך אותה לטריוויאלית-לבדיקה. אין צורך לפצל.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. זהות-בייטים flag-OFF **טריוויאלית** — `softTilt` עדיין לא נקרא מאף קוֹרֵא-פרודקשן (grep: מופיע רק ב-`card_soft.dart` + טסט). חבילת `card_soft_test` המורחבת ירוקה. אין-leak (טהור). לאמת שה-comparator ב-`card_engine.dart:267-272` **לא נגע** (השלב לא משלב — 84 משלב).

**9. תכנון נוסף (שלי):** להוסיף `bool softTiltIsInert(...)` או assertion-debug ש-`softTilt` קוראת — `assert(anchor != null || (kitSkus.isEmpty && historySkus.isEmpty) || result == 1.0)` — שתופס באג-עתידי שבו מישהו מזריק sets בלי anchor ומצפה ל-tilt (סתירת-החוזה). מתעד את החוזה ב-runtime.

**10. תכנון נוסף (שלי):** לחשוף `softTiltBreakdown(...)` שמחזיר record `(conn, kit, hist)` בוליאני — לא לשימוש-ייצור אלא ל**בדיקות/דיבוג**, כדי שטסט יוכל לאמת *למה* שבב קיבל tilt (איזה מקור), לא רק שהמכפיל >1.0. מונע בדיקת-תיבה-שחורה שעוברת מסיבה-לא-נכונה.

---

### שלב 83 — עוזרי `kitSkusFor()` + `softAnchor()` ליד-התכנסות
**1. יעד:** קיימים שני עוזרים טהורים ב-`card_soft.dart`: (א) `Set<String> kitSkusFor(LipskeyCatalogProduct anchor)` — ה-skus של ערכת-ההתקנה של העוגן (דרך `assembleKit`); (ב) `LipskeyCatalogProduct? softAnchor(List<LipskeyCatalogProduct> pool)` — מחזיר עוגן-דומיננטי כשהבריכה **קטנה אך טרם-נפתרה** (2..near), ו-**null על בריכה רחבה** (`kDivePool`). לפני השלב יש רק `anchorOf` שמחזיר עוגן *רק ב-distinctCardCount==1* (`card_soft.dart:34`) — כלומר אין עוגן ב"כמעט-נפתר". אחרי: ה-tilt (82) יכול לקבל kit+anchor גם בתור-ליד-התכנסות (85 צורך).

**2. איך בונים:** (א) `kitSkusFor`: למצוא את ה-`SmartProduct` של העוגן — `smartProductForSku(anchor.sku)` (קיים, `smart_tree.dart`) → `assembleKit(recipe)` (`recipe_kit.dart:261`) → לאסוף `line.product.sku` לכל `KitLine` שאינו `KitMatch.none`. החזרה: `Set<String>`. אם אין recipe → `const {}`. (ב) `softAnchor`: `final d = distinctCardCount(pool); if (d == 1) return anchorOf(pool); if (d >= 2 && d <= kSoftAnchorNear) { return distinctProducts(pool).first-by-dominance; } return null;`. ה"דומיננטי" = המוצר עם הכי-הרבה sku-instances בבריכה (representative), tie-break sku-ממוין (כמו `WordSignal.chipsFor:164`). (ג) קבוע `kSoftAnchorNear` (OWNER-REVIEW, נניח 3 — מתחת ל-`kShowProductsThreshold`). (ד) docstring: "softAnchor extends anchorOf to the near-converged band; null on a wide pool so the merge stays soft-inert (82)".

**3. תקלות צפויות:** (א) **חפיפה-עם-anchorOf** — אם `softAnchor` מחזיר עוגן ב-d==1 בדרך שונה מ-`anchorOf`, יהיו שתי הגדרות-עוגן סותרות; חייב `softAnchor` ל**דלגייט** ל-`anchorOf` ב-d==1. (ב) **"דומיננטי" לא-דטרמיניסטי** — אם ה-tie-break על representative-count לא יציב תחת shuffle-בריכה, `softAnchor` יחזיר עוגן שונה → tilt שונה → סדר-שבבים שונה (שובר זהות-בייטים). (ג) **`softAnchor(kDivePool)!=null`** — אם הגבול `kSoftAnchorNear` שגוי או ש-`distinctCardCount` של הבריכה-המלאה נמוך מהצפוי, ה-anchor ידלוף לבריכה-רחבה והמיזוג יקבל tilt — **סתירה ישירה** ל-`card_soft.dart:30-39` ("large pool → null → soft INERT"). (ד) **`assembleKit` יקר** — `recipe_kit.dart` סורק מועמדים פר-acc; קריאה פר-שבב תהיה כבדה (אותה תקלת-82). (ה) **kit כולל `ambiguous`** — אם נכלול `KitMatch.ambiguous` (score נמוך), ה-tilt יחזק שבבים על בסיס-ניחוש.

**4. פתרון:** (א) `if (d == 1) return anchorOf(pool);` כשורה-ראשונה ב-`softAnchor`. (ב) tie-break מפורש: `..sort((a,b){ final c = countB.compareTo(countA); return c!=0?c:a.sku.compareTo(b.sku); })` — count-יורד ואז sku-עולה (דטרמיניסטי תחת shuffle). (ג) **בדיקה קשיחה** `expect(softAnchor(kDivePool), isNull)` — אם נכשלת, `kSoftAnchorNear` או הגבול שגויים (זו הבדיקה-הקריטית של השלב). (ד) `kitSkusFor` נקרא פעם-אחת בנקודת-ההתכנסות (85/87), לא פר-שבב; התוצאה (`Set<String>`) מוזרקת ל-`softTilt`. (ה) להחריג `KitMatch.ambiguous`+`none` — לכלול רק `curated/auto/swarm` (החפיפה צריכה להיות מ-kit-בטוח, מקביל ל-gate של `connectionsFor` שדורש `hasSpec`).

**5. בדיקות:** `card_soft_test.dart`: (1) `'softAnchor(kDivePool)==null (רחב → אינרטי)'` — הבדיקה-הראשית. (2) `'softAnchor של בריכת-1 == anchorOf'` — דלגייט. (3) `'softAnchor בבריכת-2..near → דומיננטי דטרמיניסטי'` — לבנות בריכה קטנה, לאמת אותו עוגן תחת `..shuffle(Random(7))`. (4) `'kitSkusFor: subset של skus-קטלוג ולא-ריק לעוגן-עם-recipe'` — לבחור עוגן עם `smartProductForSku!=null`, `expect(kitSkusFor(a), isNotEmpty)` + כולם ב-`kDivePool` sku-set. (5) `'kitSkusFor מחריג none/ambiguous'` — לאמת שאף sku מ-`KitLine(match:none)` לא בקבוצה. (6) `'kitSkusFor(עוגן-ללא-recipe)=={}'`.

**6. שיפור:** `softAnchor` "דומיננטי" יכול להיות מטעה כשהבריכה 2..near מכילה 3 מוצרים-שקולים (אין דומיננטי אמיתי). לשפר: להחזיר עוגן **רק** כשיש רוב-ברור (`topCount > 2nd*1.5`), אחרת null — מונע tilt על בסיס-עוגן-שרירותי. מקביל ל-`decisiveMargin` ב-`recipe_kit.dart:240` (אותה דוקטרינה: לא לפעול בלי-margin).

**7. ריאלי?:** כן, אטומי — שני עוזרים טהורים מעל `assembleKit`/`anchorOf`/`distinctProducts` הקיימים. ~30 שורות. הסיכון היחיד (גבול `kSoftAnchorNear`) נבדק ישירות. אין צורך לפצל.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. flag-OFF: שני העוזרים עדיין לא-מחווטים (grep: רק ב-`card_soft.dart`+טסט) → זהות-בייטים טריוויאלית. `card_soft_test` ירוק. אין-leak. לאמת ש-`anchorOf` המקורי **לא שונה** (רק נוסף `softAnchor` שמדלגייט אליו).

**9. תכנון נוסף (שלי):** להוסיף `int softAnchorBand(List<...> pool)` שמחזיר 0=wide / 1=near / 2=resolved — כדי ש-85 יוכל לתייג שבבים-כ-DESTINATIONS **רק** ב-band==1 (ליד-התכנסות) במפורש, במקום לשחזר את גבול-ה-near פעמיים. מקור-אמת-יחיד לגבול.

**10. תכנון נוסף (שלי):** caching עדין — `kitSkusFor` על `kSmartProducts` קבוע, אז להוסיף `final Map<String,Set<String>> _kitSkuCache` (מקביל ל-`_bySku` ב-`recipe_kit.dart:148` ול-`_compatCache`), כך שגם אם 85/87 יקראו אותו כמה-פעמים בתור-אחד, אין סריקה-חוזרת. שומר על תקציב-הביצועים של screen:140.

---

### שלב 84 — מבנה-מחדש `_mergedChips` ל-top-K עם softTilt (golden מבורך-מחדש)
**1. יעד:** `_mergedChips` (`card_engine.dart:217`) עובר מ**take-מיקומי פר-ציר** (`representativeTake`/`take(take)`, 291–293) ל**top-K-משוקלל פר-ציר** לפי `baseWeight * softTilt`, כך שכש**יש** עוגן (ליד-התכנסות) השבבים הרלוונטיים-לחיבור/מתכון/היסטוריה עולים בתוך-הציר; וכש**אין** עוגן (רחב-אינרטי, המקרה-הרגיל במיזוג) הפלט **זהה-בייטים ל-golden-66**. לפני: `softTilt` קיים (82) אך לא-מחווט; ה-docstring (203–213) כבר מתאר את הרפקטור הזה כ"the restructure of this loop". אחרי: ה-loop משוקלל, ה-golden-של-66 מבורך-מחדש (כי המבנה השתנה אך הפלט-האינרטי זהה).

**2. איך בונים:** (א) לפני ה-loop של 277, לחשב פעם-אחת: `final anchor = softAnchor(pool); final conn = anchor==null ? const <...>{} : connectionsFor(anchor).toSet(); final kit = anchor==null ? const{} : kitSkusFor(anchor); final hist = historySkus;` (היסטוריה מוזרקת מ-88, ברירת-מחדל `{}`). (ב) בתוך ה-loop פר-ציר (278), במקום `representativeTake/take`, לבנות לכל שבב-מועמד `weighted = (chip, baseWeightOf(chip) * softTilt(chip, anchor:anchor, ...))` ולמיין **בתוך-הציר** לפי weight-יורד עם tie-break = **הסדר-המקורי** (כדי לשמר את representativeTake-קצוות כש-tilt אחיד). (ג) `baseWeightOf` — לשמר את הסמנטיקה הקיימת: לגודל/זווית, ה-base חייב לשמר את "כולל-קצוות" של `representativeTake`; הפתרון: כש-`anchor==null` *לדלג על המיון-המשוקלל לגמרי* ולקרוא לנתיב-הישן (`representativeTake`/`take`) — כך זהות-66 מובטחת **בקונסטרוקציה**, וה-tilt חל **רק** כשיש anchor. (ד) `infoGain` של `SignalChip` (כיום 0 תמיד, 49) יכול להתאכלס כאן ל-display (`n - distinctCardCount(narrowed)`, כפי ש-64 מגדיר). (ה) לברך golden חדש flag-ON רק אם יש anchor-path; לאשר ≤6 מחדש.

**3. תקלות צפויות:** (א) **שבירת golden-66 בנתיב-האינרטי** — אם נחיל מיון-משוקלל גם כש-`anchor==null`, אפילו tilt≡1.0 יכול לשנות סדר (מיון-יציב על מפתח-שווה משמר סדר, אבל מיון על double עם כל-הערכים==base*1.0 עלול לסטות אם ה-comparator לא יציב). זה **שובר זהות-בייטים** מול 66 — האינווריאנט-המרכזי של P9 (91). (ב) **float-מיון** — `weight` הוא double; מיון-תוך-ציר על double עם ties (כל-הקצוות באותו base) חוזר ל-NaN/ULP-סיכון שה-comparator-השלם (267) נבנה להימנע ממנו. (ג) **`representativeTake`-קצוות אובדים** — אם נחליף את representativeTake במיון-top-K, נאבד את ה"כולל-largest" (גודל/זווית, 287–293), והשבב-הגדול ייחתך — בדיוק מה ש-§1.4#11 אוסר (`card_engine.dart:284`). (ד) **anchor במיזוג-רגיל** — `softAnchor` תוכנן (83) להחזיר null על בריכה רחבה, אבל אם המיזוג רץ על בריכה *לאחר* כמה-צמצומים שהיא 2..near, `softAnchor!=null` והמיזוג **כן** יקבל tilt — צריך לוודא שזה רצוי (ליד-התכנסות) ולא מקרי. (ה) **ביצועים** — `connectionsFor`+`kitSkusFor` פר-keystroke; אך פעם-אחת-לפני-loop, לא פר-שבב (תוקן ב-82/83).

**4. פתרון:** (א) **שמירת-נתיב-כפול מפורשת**: `if (anchor == null) { /* exact old path: representativeTake/take */ } else { /* weighted top-K */ }` — זהות-66 בקונסטרוקציה, לא בתקווה. הבדיקה (91) מאמתת שהנתיב-האינרטי זהה-בייטים. (ב) במיון-המשוקלל, להשתמש ב-**מפתח-רציונלי-שלם** כמו ה-comparator הראשי: כפל ב-מכנה-משותף או השוואת-`(weightNumer*other.denom)` — או, פשוט יותר, לכמת tilt ל-int (`(tilt*1000).round()`) ולמיין על int*base; tie-break = אינדקס-מקורי. אפס-float-כמפתח. (ג) בנתיב-המשוקלל לגודל/זווית, להחיל את ה-tilt כ**re-rank של תוצאת `representativeTake`** (קודם representativeTake לקצוות, אז להעלות בתוכה שבב-tilt) — שומר קצוות *וגם* מטה. (ד) להוסיף בדיקה `softAnchor` שמתעדת איזו band מפעילה tilt; אם רצוי שגם near-converged-merge יקבל tilt — לתעד. (ה) memo של screen:144 כבר מכסה את ה-keystroke.

**5. בדיקות:** `test/features/card_keyboard/merged_softtilt_test.dart`: (1) `'היסטוריה-ריקה+אין-anchor → זהה-בייטים ל-golden-66'` — להשוות `_mergedChips(pool, stack, null)` מול ה-golden השמור של 66 (אותו list של `SignalChip`). **הבדיקה-הקריטית.** (2) `'עוגן+חיבור → שבב-חיבור עולה בתוך-הציר'` — בריכת-near עם anchor, לאמת שסדר-החומר/הדגם השתנה לטובת sku-חיבור. (3) `'קצוות-גודל נשמרים גם עם tilt'` — השבב-הגדול עדיין בפלט (לא נחתך). (4) `'מיון דטרמיניסטי תחת shuffle'` — `..shuffle(Random(3))` → פלט זהה. (5) `'≤6 עדיין מאושר'` — re-assert של שער-67 על הפלט-המשוקלל. (6) golden ON חדש מבורך (אם anchor-path מרונדר).

**6. שיפור:** במקום נתיב-כפול (`if anchor==null`), לתכנן את ה-tilt כך ש-`softTilt≡1.0` הוא **no-op מתמטי מובטח** על המיון (מיון-יציב + מפתח-שלם זהה לכולם = הסדר נשמר), ואז נתיב-יחיד. זה נקי יותר (פחות-קוד-כפול) אך דורש הוכחה-פורמלית שהמיון-היציב משמר את representativeTake — מסוכן יותר. החלטה: נתיב-כפול לבטיחות-86, שיפור-לנתיב-יחיד אחרי שה-golden-91 יציב.

**7. ריאלי?:** **גבולי — מועמד-לפיצול.** זה ה-restructure הכי-מהותי ב-P9: משנה את הלולאה-היקרה-ביותר של המודול (`card_engine.dart:217`, ש-screen:140 כבר מתאר כ"most expensive op"), נוגע ב-golden, ובסמנטיקת-הקצוות. לפצל ל-84a ("נתיב-כפול: anchor==null→old path מילולית; אימות זהות-66 לבד") ו-84b ("נתיב-anchor: weighted top-K + golden-ON חדש"). 84a הוא רפקטור-בלי-שינוי-התנהגות (בטוח לאמת), 84b מוסיף התנהגות. הפיצול מבודד את הסיכון-לשבירת-66 מהסיכון-החדש.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF**: עדיין דרך `kCardKeyboardFlag` (screen:400) — הפרודקשן לא מריץ `mergedKeys`; אך כאן ה-OFF-equivalence הקריטי הוא *golden-66 בנתיב-אינרטי* (בדיקה 1). להריץ את **כל** חבילת `card_engine_test`+`card_signals_test`+`card_soft_test`+`card_keyboard_screen_test` — כולן ירוקות. taskkill dart לפני; retry-wrap לכשלי-טעינה; לעולם לא `tail` (מלכודת-הצי). אין-leak (טהור). diff את ה-golden-66: חייב 0-שינוי בנתיב-אינרטי.

**9. תכנון נוסף (שלי):** assertion-debug בתוך `_mergedChips` בנתיב-anchor: `assert(out.length == oldPathLength(...))` — שה-top-K-המשוקלל מחזיר **אותו מספר** שבבים כמו הנתיב-המיקומי (tilt מסדר, לא מוסיף/מפיל — חוזה-91). תופס ב-runtime הפרה של "softTilt רק-מסדר".

**10. תכנון נוסף (שלי):** לחשוף `mergedChipsForTest(pool, stack, subtype, {anchor, conn, kit, hist})` `@visibleForTesting` שמזריק את 4-הקלטים-הרכים ישירות — כך בדיקה תוכל לבדוק את הנתיב-המשוקלל **בלי** לבנות בריכת-near אמיתית (שקשה לשלוט בה). מבודד את לוגיקת-ה-tilt מהקושי-לשחזר-מצב.

---

### שלב 85 — תיוג שבבי-ליד-התכנסות כ-DESTINATIONS (נתוני #41)
**1. יעד:** קיים שדה-נתון `bool isDestination` על `SignalChip` (`card_engine.dart:43`), המסומן `true` **רק** עבור שבבים בתור-ליד-התכנסות (כש-`softAnchor!=null`, band==near), `false` אחרת — render-only, **לעולם לא מנתב** (לא משנה predicate/axisId). לפני: `SignalChip` מחזיק `axisId,value,displayLabel,axisName,infoGain,soft` — אין `isDestination`. אחרי: ה-engine מסמן אילו שבבים הם "יעד-קפיצה-בלחיצה-אחת" (הסמנטיקה של #41), והנתון זמ.ין ל-86/87 לחווט לרינדור.

**2. איך בונים:** (א) להוסיף `final bool isDestination` ל-`SignalChip` (ברירת-מחדל `false`) — לעדכן constructor (44–51), `==` (82–89), `hashCode` (92–93). **קריטי**: ברירת-מחדל `false` שומרת זהות-בייטים (כל שבב קיים נשאר זהה). (ב) ב-`_mergedChips` נתיב-anchor (84), בעת-בניית-שבב, אם band==near להעתיק `chip.copyWith(isDestination: true)` (או לבנותו עם הדגל). (ג) **render-only**: לוודא ש-`isDestination` **לא** נכנס לשום predicate — `SignalSource.matches` (`card_signals.dart:60`) לא קורא אותו, ו-`_predicateFor` (screen:189) משחזר מ-`(axisId,value)` בלבד (לא מ-`isDestination`), אז קפיצה-בלחיצה עדיין מצמצמת נכון. (ד) docstring על השדה: "render-only #41 hint; NEVER routes — the predicate keys on axisId+value only".

**3. תקלות צפויות:** (א) **שבירת golden** — הוספת שדה ל-`SignalChip` עם `==`/`hashCode` משנה את ערך-ההשוואה; אם ה-golden שומר `SignalChip` שלמים (לא רק displayLabel), שבבים-קיימים עם `isDestination:false` חייבים להישאר שווים-לקודמים — ברירת-מחדל `false` + הכללה-נכונה ב-`==` מבטיחה זאת, אך **אם** ה-golden הושווה ע"י `toString` ישן ש-isDestination משנה, ייכשל. (ב) **`copyWith` חסר** — אם נסמן ע"י בנייה-מחדש ידנית, קל לשכוח שדה ולאבד `axisName`/`infoGain`; `SignalChip` כיום חסר `copyWith`. (ג) **דליפת-ניתוב** — אם בטעות `isDestination` ישפיע על `_keysFor`/`_onWordTap` (screen:255/309) מעבר ל-render, שבב-יעד ינהג שונה בלחיצה — סתירה ל"לעולם לא מנתב". (ד) **"רחב→אין-destination"** — חייב להבטיח ש-band==wide (`softAnchor==null`) **אף-פעם** לא מסמן destination (אחרת המיזוג-הרגיל יראה שבבי-יעד).

**4. פתרון:** (א) להוסיף `copyWith` ל-`SignalChip` (כולל כל-6-השדות + isDestination) — מונע אובדן-שדה. (ב) לעדכן `==`/`hashCode` להכליל `isDestination`; אם ה-golden משווה `SignalChip`-שלמים, ברירת-`false` שומרת שוויון (בדיקה: golden-66 לא-משתנה). אם ה-golden משווה רק `displayLabel`/`value` (כפי שסביר — ראה `card_signals_test` שמשווה `.value`/`.displayLabel`), אין-סיכון. (ג) בדיקה ש-`_predicateFor(axisId,value)` (screen:189) **מתעלם** מ-isDestination — לבנות שני שבבים זהים פרט ל-isDestination, predicate זהה. (ד) **בדיקה קשיחה** `'רחב → אין-destination'`: `_mergedChips(kDivePool-wide,...).every((c)=>!c.isDestination)`.

**5. בדיקות:** `test/features/card_keyboard/destination_chip_test.dart`: (1) `'ברירת-מחדל false → golden-66 לא-משתנה'` — re-run בדיקת-זהות-66. (2) `'רחב (anchor null) → כל isDestination==false'` — הבדיקה-הקריטית. (3) `'near-converged → ≥1 שבב isDestination==true'`. (4) `'isDestination לא משנה predicate'` — `_predicateFor` זהה לשני-שבבים-נבדלים-רק-בדגל; או ברמת-engine: `src.matches` זהה. (5) `'copyWith שומר את כל השדות'`. (6) `'==/hashCode מכלילים isDestination'` — שני שבבים זהים פרט-לדגל → לא-שווים.

**6. שיפור:** במקום bool דו-מצבי, `enum ChipRole { word, destination }` (או `ChipKind`) — מרחיב לעתיד (יעד-קו/יעד-קפיצה נבדלים ל-#41 מורחב) ומונע "boolean-blindness". מחיר: שינוי-טיפוס רחב יותר; אך כיום bool מספיק ל-#41, אז זה over-engineering — להשאיר bool, לתעד שהוא ניתן-להרחבה.

**7. ריאלי?:** כן, אטומי — הוספת שדה-נתון טהור + סימון בנקודה-אחת ב-84. ~15 שורות-delta. תלוי ב-84 (נתיב-anchor) אך הסימון-עצמו טריוויאלי. אין צורך לפצל. **הערה**: תלות ב-84 חזקה — אם 84 פוצל, 85 תלוי ב-84b.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF**: שדה חדש ברירת-`false` → כל שבב-קיים זהה; הפרודקשן לא מריץ engine (flag); golden-66 (בדיקה 1) הוא העוגן-הקשיח. כל חבילת `card_engine`+`card_signals`+`card_soft` ירוקה. אין-leak. לאמת ש-`card_signals_test` (שמשווה `.value`/`.displayLabel`) עובר ללא-שינוי (השדה לא נכנס לאותן-בדיקות).

**9. תכנון נוסף (שלי):** invariant-test כללי: `'isDestination ⟹ soft==false'` — שבב-יעד הוא תמיד ציר-קשיח (כמו §1.5: כל שבב-נפלט hard), כך שיעד-#41 לא מתבלבל עם אות-רך. תופס באג שבו עתידית מישהו יסמן שבב-רך כיעד.

**10. תכנון נוסף (שלי):** counter/metric `destinationCount(verdict)` `@visibleForTesting` — כדי ש-87 (החיווט) ובדיקת-end-to-end יוכלו לאמת ש"תור-ליד-התכנסות בונה מקשי-יעד" *כמותית* (לפחות-N), לא רק נוכחות. מקשר בין הסימון (85) לרינדור (86/87) במדד-אחד.

---

### שלב 86 — הוספת isDestination ל-WordKey + ענף-render ב-WordKeyboard (seam נטו-חדש)
**1. יעד:** `WordKey` (`word_keys_model.dart:8`) מקבל שדה `final bool isDestination` (ברירת-מחדל `false`), `WordKeyboard` (`word_keyboard.dart`) מעביר אותו ל-`BsKey`, ו-`BsKey` (`bs_key.dart`) מקבל ענף-render שכאשר `isDestination` דולק מצייר את אפקט-#41 (north_east glyph brand-tinted + brand-border + brand-wash) — **בדיוק** התקדים שכבר קיים ב-`_PredictionChip` (`bs_keyboard.dart:884-909`). ברירת-`false` ⇒ כל מקש קיים (`word_finder`-חי כלול) **זהה-בייטים**. לפני: `WordKey` מחזיק `label,payload,imageAsset,semanticLabel,axisGlyph` — אין isDestination; `BsKey` מצייר axisGlyph (204–213) אך לא אפקט-יעד. אחרי: ה-seam קיים ופועל, מנותק מנתונים (87 מחווט).

**2. איך בונים:** (א) `WordKey`: להוסיף `final bool isDestination` (44–43 area), ל-constructor (9–15) עם `this.isDestination = false`. (ב) `WordKeyboard._buildWordRow` (69–98): להעביר `isDestination: word.isDestination` ל-`BsKey` (ליד `axisGlyph`/`semanticOverride`, שורה 90–91). (ג) `BsKey`: להוסיף `final bool isDestination` (ליד `axisGlyph`, `bs_key.dart:101`) + constructor (112–115). בענף-`_content` (184) או ב-`build` (118): כאשר `isDestination && !isAccent`, להחיל את ה-3-אלמנטים — אפשר **למחזר את הקבועים** מ-`_PredictionChip` (border `BsTokens.brand`, fill `BsTokens.brand.withOpacity(0.06)`, glyph `Icons.north_east`). מיקום-נקי: glyph כ-leading (כמו axisGlyph ב-206–213), border/wash ב-decoration של ה-Container (146–151). (ד) **a11y**: semantic-suffix '(ניווט)' כמו `_PredictionChip:896` — אך `BsKey` כבר תומך `semanticOverride` (139); להוסיף suffix רק כשאין override. (ה) docstring: "default false → byte-identical; mirrors the proven #41 _PredictionChip idiom".

**3. תקלות צפויות:** (א) **שבירת `word_finder`-חי (זהות-בייטים)** — `word_finder_screen.dart` (89068 בתים, החי!) בונה `WordKey`-ים; אם ברירת-המחדל לא-`false` או אם הענף-החדש משנה אפילו-padding כשהדגל כבוי, ה**אתר-החי נשבר** (זו המלכודת-המרכזית, המקבילה ל-`bs_keyboard.dart:822-824` "byte-identical when empty"). (ב) **התנגשות axisGlyph↔north_east** — שבב-מיזוג עם *גם* `axisGlyph` (size→straighten, screen:240) *וגם* `isDestination` יבקש שני-glyphs; `BsKey._content` (204) כבר מציב glyph-יחיד — צריך-החלטה מי-מנצח (כנראה: יעד-glyph מחליף/מצטרף ל-axis-glyph). (ג) **`isAccent`↔destination** — מקש-accent (brand-fill מלא, `bs_key.dart:120`) + destination (brand-wash חלקי) מתנגשים ויזואלית; `_PredictionChip` לא מתמודד (אין accent שם). (ד) **גולדן `word_finder`** — אם יש golden של `word_finder_screen`/keyboard, שינוי-`BsKey` *עלול* להזיז pixel גם ב-false אם הענף לא-מבודד. (ה) **גולדן keyboard קיים** — `test/smart_input/keyboard/kb_golden_test.dart` + PNGs (`kb_full.png` וכו') מרנדרים `BsKey`; שינוי-מבנה ב-`BsKey` יכול לשבור אותם גם בלי-destination.

**4. פתרון:** (א) ברירת-`false` + ענף **early-out**: `if (!isDestination) { /* exact current render */ }` — בדיוק כמו `_PredictionChip:859` ("DEFAULT … EXACTLY the historical render"). זהות-בייטים בקונסטרוקציה. (ב) החלטה מפורשת: כש-`isDestination`, ה-north_east-glyph **מחליף** את ה-axisGlyph (יעד-ניווט גובר על תווית-ציר ב-#41), או מצטרף-מימין — לתעד ולבדוק. (ג) `isDestination` חל **רק** `&& !isAccent` (accent גובר — מקש-ראשי לא הופך-יעד). (ד) **לבדוק את הגולדנים הקיימים מיידית**: להריץ `kb_golden_test` + כל golden של `word_finder` *לפני* החיווט (87) — חייבים להישאר ירוקים עם הענף-הכבוי. אם נשברים → הענף לא-מבודד, לתקן. (ה) `word_finder-חי זהה-בייטים` — בדיקה ייעודית (להלן).

**5. בדיקות:** `test/features/word_finder/word_key_destination_test.dart`: (1) `'WordKey ברירת-מחדל isDestination==false'`. (2) `'word_finder-חי זהה-בייטים: BsKey(isDestination:false) == BsKey ללא-הפרמטר'` — pump שני-מקשים, `getSize`+semantics זהים. (3) `'isDestination:true → north_east glyph נוכח + brand-border'` — `find.byIcon(Icons.north_east)` + בדיקת-decoration. (4) `'isAccent גובר על isDestination'` — מקש accent+destination לא מצייר wash-יעד. (5) **רגרסיה**: להריץ `kb_golden_test` — `kb_full.png`/`kb_hebrew.png` ללא-שינוי. (6) `'semantic suffix (ניווט) כשאין override'`.

**6. שיפור:** במקום 3-bool מקבילים על `BsKey` (`isAccent`, `isDestination`, +עתידיים) שמתנגשים, להגדיר `enum BsKeyVariant { plain, accent, destination }` יחיד — מבטל את שאלת-העדיפות (ב)/(ג) בקומפילציה (variant יחיד, לא צירוף). מחיר: רפקטור call-sites של `isAccent` (כל ה-keyboard). החלטה: כיום bool נפרד עם `&& !isAccent` מספיק ובטוח-לזהות-בייטים; variant הוא שיפור-עתידי (לא בשלב-זה, מסכן את הגולדן).

**7. ריאלי?:** כן, אטומי — seam-render נטו-חדש מאחורי ברירת-`false`, ממראה תקדים-מוכח (`_PredictionChip`). ~25 שורות על-פני 3 קבצים. הסיכון-העיקרי (גולדן/זהות-`word_finder`) נבדק ישירות. אין צורך לפצל, **אך** וידוא-הגולדן הוא תנאי-כניסה ל-87.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF היא העיקר כאן** (`BsKey`/`WordKey` משמשים את ה-`word_finder` החי + `word_finder` הדמו על buildsmart-il.com): בדיקה 2 + הגולדנים (`kb_golden_test`, וכל golden-`word_finder`) חייבים ירוקים ללא-שינוי. להריץ `floating_card_keyboard_test`+`card_keyboard_screen_test` (משתמשי-`WordKeyboard`). taskkill dart; retry-wrap; לא `tail`. אין-leak (widget-tests: `ensureSemantics().dispose()` בגוף).

**9. תכנון נוסף (שלי):** טסט-זהות-בייטים **ממוקד-word_finder-חי** מעבר לכללי: לבנות `WordKey` *בדיוק כפי ש-`word_finder_screen` בונה* (label+payload, בלי isDestination), לרנדר ב-`WordKeyboard`, ולהשוות widget-tree ל-snapshot-קודם. כי `word_finder` הוא הקוד-החי-בפרודקשן (זכרון: kWordFinder ON על האתר) — שבירתו = פגיעה-בייצור, חמור מ-`card_keyboard` (שעדיין dark).

**10. תכנון נוסף (שלי):** לחלץ את אפקט-#41 ל-mixin/helper משותף `bsDestinationDecoration()` ולקרוא לו **גם** מ-`_PredictionChip:901-906` **וגם** מ-`BsKey` — מקור-אמת-יחיד לאפקט-היעד, כך ש-#41 נראה זהה בשתי-המקלדות ושינוי-עיצוב-עתידי במקום-אחד. מונע סחיפת-עיצוב בין שני המימושים.

---

### שלב 87 — חיווט chip.isDestination מהמסך ל-seam-החדש
**1. יעד:** `CardKeyboardScreen._keysFor` (`card_keyboard_screen.dart:255`) מעביר את `chip.isDestination` (שסומן ב-85) ל-`WordKey(...isDestination: c.isDestination)` (seam מ-86), כך שתור-ליד-התכנסות מרנדר מקשי-יעד-#41 בפועל. אדיטיבי בלבד — **אין כפתורים-חדשים**, אין מסלול-ניתוב-חדש; לחיצה על מקש-יעד עדיין עוברת `_ChipTap`→`_pushStep` הקיים. לפני: `_keysFor` (259–278) בונה `WordKey(c.displayLabel, payload:_ChipTap(...), semanticLabel:..., axisGlyph:_glyphForAxis(...))` — בלי isDestination. אחרי: השדה מחווט, ושרשרת 85→86→87 שלמה end-to-end.

**2. איך בונים:** (א) שינוי-יחיד ב-`_keysFor` ענף-`MergedKeys` (259–278): להוסיף `isDestination: c.isDestination` ל-constructor-ה-`WordKey` (אחרי `axisGlyph:`, שורה 276). (ב) זהו — כל השאר (payload `_ChipTap`, semanticLabel, glyph) נשאר. (ג) לוודא ש-`_onWordTap` (309) **לא משתנה** — מקש-יעד נלחץ בדיוק כמו מקש-רגיל (`_ChipTap`→`_pushStep`), כי isDestination הוא render-only (85). (ד) docstring-עדכון על `_keysFor`: "isDestination forwarded (render-only #41); a destination key taps identically to a word key".

**3. תקלות צפויות:** (א) **flag-race/anchor במיזוג-פתיחה** — בפתיחה ובמיזוג-רחב, `chip.isDestination` אמור להיות `false` (85: רחב→אין-destination); אם 84/85 מסמנים בטעות ב-band-לא-נכון, מקשי-יעד יופיעו בפתיחה (חזותית-שגוי). (ב) **תלות-בנייה** — 87 חסר-משמעות בלי 85 (הסימון) ו-86 (ה-seam); אם אחד חסר, או `isDestination` תמיד-`false` (אין מקשי-יעד) או `WordKey` לא-מקבל-שדה (compile-fail). (ג) **CardShowProducts/CardAskWords** — מקשי-מוצר (`_productKeys`, 288) ומקשי-פתיחה (`CardAskWords`, 256) **לא** צריכים isDestination (הם לא שבבי-מיזוג); לוודא שהשדה לא-זולג לשם (נשאר ברירת-`false`). (ד) **זהות-בייטים**: כשאין-anchor (המקרה-הרגיל), כל `c.isDestination==false`, אז `WordKey(...isDestination:false)` ≡ הקודם — הפרודקשן (flag) ממילא dark.

**4. פתרון:** (א) הבדיקה-הקריטית: בפתיחה (`CardAskWords`) ובמיזוג-רחב — `_keysFor` מחזיר מקשים עם `isDestination:false` בלבד (`every`). (ב) שלב-תלוי מפורש: 87 **אחרי** 85+86 ירוקים (אם 84 פוצל — אחרי 84b). (ג) `_productKeys`/`CardAskWords` ענפים לא-נגעו (הוספת-השדה רק בענף-`MergedKeys`). (ד) זהות-בייטים: בדיקת-screen ש-flag-OFF עדיין `SizedBox.shrink` (screen:400) — לא-נגוע.

**5. בדיקות:** `card_keyboard_screen_test.dart` (להרחיב): (1) `'תור-ליד-התכנסות בונה מקשי-יעד'` — לדחוף-stack עד band==near (anchor!=null), `expect` שלפחות מקש-`WordKey` אחד `isDestination==true` (דרך `_keysFor(verdict)` או `find.byIcon(Icons.north_east)`). (2) `'פתיחה → אפס מקשי-יעד'` — `verdict is CardAskWords`, כל `key.isDestination==false`. (3) `'מיזוג-רחב → אפס מקשי-יעד'`. (4) `'מקש-יעד נלחץ כמו מקש-רגיל'` — tap על מקש-יעד → `_ChipTap`→stack-גדל-ב-1 (כמו מקש-מיזוג רגיל), לא מסלול-אחר. (5) `'מקשי-מוצר/פתיחה אינם יעד'`.

**6. שיפור:** השלב מעביר רק bool; שיפור-UX: כש-band==near, אפשר **למיין** את מקשי-היעד לראש-הרשת (יעדים-קודם) כדי שהמשתמש יראה את "הקפיצה-המהירה" ראשונה. אך זה משנה סדר-מקשים (וזהות-66 אם זולג לרחב) — מסוכן; להשאיר ל-`_mergedChips` (84) שכבר ממיין, ולא להוסיף מיון-UI כאן. כלומר: לדחות שיפור-זה, ולתעד.

**7. ריאלי?:** כן, אטומי-לחלוטין — שינוי **שורה-אחת** (הוספת ארגומנט). תלוי-בנייה ב-85+86. אין צורך לפצל. למעשה זה הקטן-ביותר ב-batch.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF**: screen עדיין `SizedBox.shrink` ב-OFF (screen:400, בדיקת-`card_keyboard_screen_test` הקיימת "flag OFF → renders nothing"). להריץ את כל חבילת `card_keyboard` (4 קבצים) + `floating_card_keyboard_test`. אין-leak. לאמת ששרשרת 85→86→87 שלמה: בדיקת-end-to-end ש-`find.byIcon(Icons.north_east)` מופיע בתור-near ונעדר בפתיחה.

**9. תכנון נוסף (שלי):** בדיקת-end-to-end חוצת-3-שלבים `destination_e2e_test.dart` שמדמה דייב מלא: פתיחה(אפס-יעד)→זריעה→צמצום-עד-near→**יעד-מופיע**→tap-יעד→`CardResolve`/sheet. מאמתת ש-85(engine)+86(widget)+87(wiring) עובדים *יחד* על מצב-אמיתי, לא רק כל-אחד-לחוד. תופס ניתוק-שרשרת.

**10. תכנון נוסף (שלי):** flag-משני `kCardDestinations` (תת-דגל מתחת ל-`kCardKeyboardFlag`) לכבות-רק-את-אפקט-היעד — כך שאם #41-בכרטיס מתגלה כמבלבל ב-QA, אפשר לכבותו בלי-לכבות את כל המנוע. ברירת-מחדל ON-כש-`kCardKeyboard`-ON. זול, ומבטל סיכון-החלטת-עיצוב-יחיד (תואם דוקטרינת-"הכל-מאחורי-דגל").

---

### שלב 88 — seam-ספק: היסטוריה-ממוקדת-זהות אל המנוע
**1. יעד:** קיים seam שמזרים `historySkus` (מ-`recentlyViewedProvider`, **ממוקד-זהות**) אל `_mergedChips`/`softTilt`, כך שמוצרים-שנצפו-לאחרונה מקבלים tilt-רך בתור-ליד-התכנסות. **קריטי**: ההיסטוריה ממוקדת-זהות (seam לפי-זהות-פעילה, כפי ששלב 21 קיבע) — A→B לא דולף; וריק→זהה-בייטים (היסטוריה-ריקה ⇒ `softTilt` אינרטי ⇒ golden-66). לפני: `card_keyboard_screen._ensureMemo` (144) קורא `mergedKeys(pool, stack, lexicon, subtype)` — **בלי** היסטוריה; `_mergedChips` (84) מקבל `hist` עם ברירת-`{}`. אחרי: ה-screen מזריק `recentlyViewedProvider` (ref.read, ממוקד-זהות) → `historySkus` → `mergedKeys`.

**2. איך בונים:** (א) `mergedKeys` (engine, `card_engine.dart:149`) מקבל פרמטר-אופציונלי חדש `Set<String> historySkus = const {}` (סוף-החתימה, ברירת-`{}` → זהות-66). מועבר ל-`_mergedChips` → `softTilt`. (ב) ב-`card_keyboard_screen._ensureMemo` (144–152): `final hist = ref.read(recentlyViewedProvider).toSkuSet();` (הספק הממוקד-זהות שכבר קיים ב-state-layer; שלב 13/20 בנו את הכותב-היחיד). להעביר `mergedKeys(pool, stack, lexicon, subtype, historySkus: hist)`. (ג) **memo-invalidation**: `_diveVersion` (135) bumped רק על stack-mutation; אם ההיסטוריה משתנה (מוצר-נצפה), ה-memo יתיישן. פתרון: ההיסטוריה משתנה רק על *פתיחת-sheet* (לא תוך-דייב), ובפתיחה ה-screen ממילא נבנה-מחדש; אך ליתר-בטחון לקרוא `ref.watch` (לא read) ל-`recentlyViewedProvider` כך ש-rebuild קורה, ולכלול אותו ב-memo-key (להוסיף `_memoHistLen` או hash). (ד) docstring-§3-isolation: "history is identity-scoped (step 21); empty → byte-identical (golden-66)".

**3. תקלות צפויות:** (א) **דליפת-זהות (§3)** — אם הספק **גלובלי** ולא ממוקד-זהות, היסטוריית-מעסיק-A תטה את הדייב של מעסיק-B (`MEMORY`: היסטוריה גלובלי-מול-employer-scoped, seam לפי-זהות-פעילה — שלב 21). זו הפרת-בידוד **חמורה**. (ב) **שבירת-טוהר-engine** — `mergedKeys`/`_mergedChips` הם **טהורים** (`card_engine.dart:16-19` "no Riverpod"); אם נקרא provider *בתוך* ה-engine, נשבר הטוהר ואי-אפשר-לבדוק. ההיסטוריה חייבת להיות **פרמטר** (כמו `pool`), מוזרק מה-screen. (ג) **memo-stale** — `_diveVersion` לא מכסה שינוי-היסטוריה (134–138); read-ולא-watch ישאיר tilt-ישן. (ד) **זהות-בייטים-66** — אם ברירת-`historySkus` לא-`{}` או אם `ref.read` מחזיר ערך-לא-ריק בבדיקת-golden, golden-66 ייכשל. (ה) **anchor==null במיזוג-רחב** — היסטוריה רלוונטית רק כש-anchor!=null (band==near, 83); במיזוג-רחב `softTilt` מתעלם (early-out), אז גם היסטוריה-לא-ריקה **לא** משנה את המיזוג-הרחב — תכונה-רצויה (שומר זהות-66 גם עם היסטוריה).

**4. פתרון:** (א) להשתמש ב-`recentlyViewedProvider` **הממוקד-זהות** הקיים (שלב 13/20/21 בנו אותו עם seam-זהות); לאמת בבדיקה ש-A→B לא דולף. אם הספק-הקיים גלובלי — לעטוף ב-selector ממוקד-זהות *לפני* החיווט (שייך ל-21, לא לכאן). (ב) `historySkus` **פרמטר-engine**, ה-engine נשאר טהור; רק ה-screen נוגע ב-provider. בדיקת-טוהר: `card_engine.dart` עדיין `import` ללא-riverpod (grep). (ג) `ref.watch` ב-`build`/`_ensureMemo` + להכליל את ה-history-set-identity ב-memo-key (אם הסט שונה → recompute). (ד) **בדיקה קשיחה**: `mergedKeys(pool, stack, lex, sub)` (בלי-history) **זהה-בייטים** ל-`mergedKeys(..., historySkus: const {})` ול-golden-66. (ה) לתעד ש-history-לא-ריקה במיזוג-רחב עדיין זהה-66 (anchor==null).

**5. בדיקות:** `test/features/card_keyboard/history_seam_test.dart`: (1) `'ריק → זהה-בייטים (golden-66)'` — `mergedKeys` עם `historySkus:{}` == golden-66. (2) `'חוצה-זהות לא-דולף'` — לבנות 2 sets-זהות, לאמת ש-tilt של זהות-A לא-מושפע מ-skus-של-B (ברמת-engine: `mergedKeys(...,historySkus:A)` != tilt-מ-B אלא אם anchor חופף). (3) `'היסטוריה-לא-ריקה + band==near → שבב-נצפה עולה'`. (4) `'היסטוריה-לא-ריקה + רחב → עדיין זהה-66 (anchor null)'`. (5) `'טוהר: engine לא מייבא riverpod'` — grep-test. (6) widget: `'memo recompute על שינוי-היסטוריה'` (ref.watch).

**6. שיפור:** במקום `Set<String>` שטוח, להעביר `List<String> historyOrdered` (סדר-עדכניות) כך ש-`softTilt` יוכל לשקלל **לפי-טריות** (נצפה-עכשיו > נצפה-לפני-שבוע) — tilt רציף ולא בינארי. תואם `lastTouchedSkus` (שלב 19, first-wins סדר). מחיר: `softTilt` (82) צריך index→weight; אך עשיר יותר. החלטה: לדחות ל-iteration-2 (82 כיום בינארי), לתעד.

**7. ריאלי?:** כן, אטומי — פרמטר-engine + 2-שורות-חיווט ב-screen + selector-זהות (אם נדרש). תלוי ב-84(tilt-path)+87+21(seam-זהות). הסיכון (דליפת-זהות) הוא **החלטה-קפואה של שלב-21**, אז 88 רק *צורך* את ה-seam הממוקד — לא ממציא אותו. אין צורך לפצל, **בתנאי** ש-21 כבר סיפק ספק-ממוקד.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF**: screen `SizedBox.shrink` ב-OFF; **וגם** ה-equivalence-הקריטי golden-66 עם history-ריקה (בדיקה 1). **בידוד-זהות**: בדיקה 2 (A→B לא דולף) — קשורה ל-`identity_isolation_test` של שלב-21. כל חבילת `card_keyboard` + state-tests ירוקים. taskkill dart; retry-wrap. אין-leak. לאמת `card_engine.dart` נשאר טהור (אין-riverpod-import).

**9. תכנון נוסף (שלי):** assertion ש-`historySkus` שמוזרק הוא **תמיד** subset של `kDivePool` sku-set — sku-זר (ממסך-אחר) לא יכול להטות את הדייב. תופס דליפה מ-provider-לא-מסונן (היסטוריה-של-הזמנות/צ'אטים שאינם מוצרי-קטלוג). זול וממוקד-בידוד.

**10. תכנון נוסף (שלי):** cap על `historySkus` (למשל top-12 אחרונים, כמו `lastTouchedSkus` cap בשלב-19) — היסטוריה-ארוכה-מדי תיצור tilt על חצי-הקטלוג ותשטח את האות. ה-cap שומר שה-tilt מצביע על *הרלוונטי-באמת* ומונע התנפחות-ביצועים ב-`softTilt`-per-chip-loop.

---

### שלב 89 — rail הצעות-רכות בכרטיס (compat+kit)
**1. יעד:** קיים rail בכרטיס-המוצר ('מה מתחבר לזה') שמרנדר את `softSuggestionsFor(anchor)` (חיבור) + ה-kit (מתכון), **מאחורי-דגל**, ולחיצה על פריט = **קפיצה-במקום** (`_switchByChip`, לא sheet-רקורסיבי). משתמש ב**אותו גרף-קנוני** כמו 77 (`rankedNeighborsOf`/`connectionsFor`) — אין לוגיקת-תאימות-מקבילה. לפני: `card_soft.dart:43` `softSuggestionsFor` קיים אך **לא-מרונדר** בכרטיס; הכרטיס מציג קרוסלת-חיבורים (sheet:740-784) שעדיין `onTap→showLipskeyProductSheet` (771, רקורסיבי). אחרי: rail-רך מגודר-דגל שקופץ-במקום ומשתמש בגרף-77.

**2. איך בונים:** (א) בכרטיס (`lipskey_product_sheet.dart`), מאחורי `_hopLive` (81), להוסיף section 'מה מתחבר לזה' שקורא `connectionsFor(_current)` (או `rankedNeighborsOf` מ-77 אם נבנה) + `kitSkusFor(_current)` (83) → מיזוג-deduped. (ב) רינדור כקרוסלה (למחזר `_miniCarousel`/`_RelatedCard` הקיימים, sheet:2452/769) אך עם `onTap: () => _switchByChip(q)` (364) — **קפיצה-במקום**, לא sheet. (ג) **גרף-קנוני יחיד**: לא להמציא compat — לקרוא `connectionsFor` (`word_finder_engine.dart:592`, ה-gate `isConnectionAnchor`) שזה ה**אותו** מקור ש-77 (`rankedNeighborsOf`) בונה עליו. אם 77 כבר חשף `rankedNeighborsOf` — להשתמש בו (superset של קשתות-ההוכחה). (ד) flag-OFF: כל ה-section מגודר `if (_hopLive)` → נעדר בפרודקשן. (ה) docstring: "same canonical graph as step 77; tap = hop-in-place (_switchByChip), never recursive sheet".

**3. תקלות צפויות:** (א) **sheet רקורסיבי (התקלה-המרכזית, sheet:771)** — אם נשכפל את הקרוסלה-הקיימת בלי-לשנות `onTap`, הלחיצה תפתח sheet-שני (אנטי-תבנית של 76); rail-הרך **חייב** `_switchByChip`. (ב) **שני-גרפים** — אם ה-rail בונה compat **משלו** (לא דרך `connectionsFor`/77), יהיו שתי-הגדרות-שכנות סותרות, ו-`hopsBetween` (90) ימדוד גרף-שונה מה-rail (סתירה ל"גרף-אחד קנוני", §≤4-proof). (ג) **anchor לא-תקף** — `connectionsFor` מחזיר `[]` כש-`!isConnectionAnchor` (gate: `inCompat`+`hasSpec`, engine:570); מוצר-fixture/polyroll ייתן rail-ריק — צריך empty-state ('אין חלקים מתחברים', כמו `_EmptyHint`, sheet:2456) ולא-קריסה. (ד) **flag-OFF דליפה** — אם ה-section לא מגודר, הכרטיס-החי משתנה (זהות-בייטים נשברת). (ה) **כפילות עם הקרוסלה-הקיימת** — הכרטיס *כבר* מציג 'מה מתחבר' (sheet:661); ה-rail-הרך עלול-לכפול — צריך להחליף/למזג, לא להוסיף-שני.

**4. פתרון:** (א) `onTap: () => _switchByChip(q)` מפורש (לא `showLipskeyProductSheet`) — ובדיקה ש-tap **לא** פותח sheet-שני. (ב) **גרף-יחיד**: לקרוא בדיוק `connectionsFor`/`rankedNeighborsOf` (77) — בדיקת-עקביות ש-rail-set ⊆ `rankedNeighborsOf(_current)` (אותו מקור כ-90). (ג) empty-state דרך `isConnectionAnchor` (engine:570) — אם false, `_EmptyHint('אין חלקים מתחברים')`. (ד) כל-ה-section `if (_hopLive)`; flag-OFF → נעדר (בדיקת-81). (ה) להחליף את הקרוסלה-הרקורסיבית (740-784) ב-rail-הרך כש-`_hopLive` (לא לכפול): `_hopLive ? _softRail() : _legacyCarousel()`.

**5. בדיקות:** `test/screens/soft_rail_test.dart`: (1) `'flag-OFF → rail נעדר'` — `forceLive:false`, `find.text('מה מתחבר לזה')` בקונטקסט-rail → `findsNothing` (קשור-81). (2) `'tap → קפיצה-במקום (אין sheet שני)'` — `forceLive:true`, tap-פריט, `expect(find.byType(LipskeyProductSheet), findsOneWidget)` + `_current` השתנה. (3) `'rail ⊆ הגרף-הקנוני (77/connectionsFor)'` — set-ה-rail ⊆ `connectionsFor(anchor)∪kitSkusFor`. (4) `'anchor לא-תקף → empty-state ולא-קריסה'` — מוצר polyroll (לא-compat), rail מראה empty-hint. (5) `'מתכון+חיבור ממוזגים deduped'`.

**6. שיפור:** ה-rail מערבב חיבור (compat) + מתכון (kit) — אך הם סמנטית-שונים ("מה מתחבר פיזית" vs "מה צריך להתקנה"). לשפר: שתי-תת-שורות מתויגות (🤝 מתחבר · 🧰 ערכה) במקום bucket-אחד — בהירות-משתמש. מחיר: יותר-UI. החלטה: למזג-עכשיו (פשטות, החוזה הוא "הצעות-רכות"), לפצל-תצוגה אם QA מבקש.

**7. ריאלי?:** **גבולי — מועמד-לפיצול.** נוגע בכרטיס-החי (3294 שורות), מחליף קרוסלה-קיימת, ומסתמך על 77 (`rankedNeighborsOf`) + 83 (`kitSkusFor`) + 81 (`_hopLive`). לפצל ל-89a ("rail-compat דרך `connectionsFor`+`_switchByChip`, מגודר") ו-89b ("מיזוג kit + empty-state + החלפת-קרוסלה-legacy"). 89a הוא ה-core (קפיצה-במקום במקום-רקורסיה), 89b מעשיר.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. **זהות-בייטים flag-OFF היא קריטית** (כרטיס-חי): בדיקה 1 + הרצת חבילת-ה-sheet (`sheet_close_test`, `product_sheet_strips_test`, `card_interactions_test`, `finder_card_consistency_test`) ירוקה ללא-שינוי. בדיקת-`hop_zone_byte_identity` (81) חייבת לכלול את ה-rail. taskkill dart; retry-wrap; לא `tail`. אין-leak (widget). לאמת **גרף-יחיד**: בדיקה 3 (rail ⊆ 77).

**9. תכנון נוסף (שלי):** golden-snapshot של ה-rail ON (`soft_rail_on.png`) — render ויזואלי קל-לרגרסיה, תופס שינוי-עיצוב-קרוסלה. מקביל ל-goldens הקיימים. נועל את המראה-הרך.

**10. תכנון נוסף (שלי):** מדד-כיסוי `softRailCoverage()` שמודד לכמה-מ-`kDivePool` יש rail-לא-ריק (anchor-תקף). כי `isConnectionAnchor` דורש `inCompat`+`hasSpec` (engine:570) — חלק-גדול-מהקטלוג (polyroll/huliot/fixtures) יקבל rail-ריק. למדוד **לפני** שמכריזים "rail בכל-כרטיס", כדי לדעת אם empty-state הוא הנפוץ (אז אולי להסתיר-section לגמרי כשריק, לא empty-hint). מקשר ל-79 ("rail-שכן לעולם לא-ריק" — אם 79 נבנה, ה-rail-הרך יכול להישען על hub-fallback ולא-להיות-ריק לעולם).

---

### שלב 90 — `hopsBetween()` מיושב לגרף-rail-הקנוני האחד (≤4 קשיח)
**1. יעד:** קיימת `int hopsBetween(LipskeyCatalogProduct a, LipskeyCatalogProduct b)` (BFS) הרצה על **בדיוק אותה adjacency** כמו 77 (`rankedNeighborsOf`, ה-rail הגלוי) ו-80 (מפקד-≤4) — **לא** גרף-נפרד-שלישי. מסכימה עם מפקד-80 על כל-זוג (אין סתירת-גרפים), וכופה ≤4 קשיח. לפני: אין `hopsBetween` בעץ (grep: 0 פגיעות); compat נמדד אד-הוק. אחרי: מרחק-הקפיצה מוגדר ע"י פונקציה-אחת מעל הגרף-הקנוני-היחיד, וזה ה**מקור-היחיד** שגם ה-rail (89/77), גם ה-back (78), וגם השער-המרכזי (100) נשענים עליו.

**2. איך בונים:** (א) `hop_graph.dart` (נבנה ב-71) חושף `Iterable<LipskeyCatalogProduct> rankedNeighborsOf(p)` (77/79) — `hopsBetween` עושה **BFS** מ-`a` עד-`b` על-גבי `rankedNeighborsOf` בלבד (אותה adjacency). (ב) `hopsBetween(a,b)`: אם `a.sku==b.sku` → 0; BFS-שכבתי (queue + visited-by-sku) עד-מציאת-`b`; אם לא-נגיש → `kUnreachable` (sentinel גדול, אך 73 מבטיח 0-בלתי-נגישים). (ג) **אותו גרף**: לקרוא `rankedNeighborsOf` (לא `connectionsFor`-גלם, אלא העטיפה-הקנונית של 77/79 שכוללת hub/קבוצה/קטגוריה-fallback) — כך 90 ⟺ 80 ⟺ 77. (ד) `kHopPairOverride` (מ-80) — אם זוג-מסוים זקוק-לעקיפה, `hopsBetween` מכבד אותה (קשת-נוספת) **כך שגם הוא וגם 80 רואים אותה** (מקור-יחיד). (ה) docstring: "BFS over rankedNeighborsOf — THE one canonical adjacency (77/79/80); agrees with the ≤4 census (80), no third graph".

**3. תקלות צפויות:** (א) **גרף-שלישי (התקלה-המרכזית)** — אם `hopsBetween` בונה adjacency משלו (למשל `connectionsFor`-גלם בלי ה-hub/fallback של 77/79), הוא **יחלוק על מפקד-80** (שמודד על קשתות-ה-rail), וזוג יוכל למדוד ≤4 ב-90 אך >4 ב-80 (או הפוך) — סתירת-ה≤4-proof כולה. (ב) **`kHopPairOverride` לא-משותף** — אם ה-override מיושם ב-80 אך לא ב-`hopsBetween` (או הפוך), אי-עקביות. (ג) **a-symmetry** — אם הגרף לא-סימטרי (`b∈neighbors(a)` אך `a∉neighbors(b)`), `hopsBetween(a,b)!=hopsBetween(b,a)` — צריך-החלטה (כנראה: גרף-לא-מכוון, `rankedNeighborsOf` סימטרי, או BFS דו-כיווני). (ד) **ביצועים** — `hopsBetween` פר-זוג על-פני |kDivePool|² במפקד-80 הוא O(V²·(V+E)); צריך BFS-מ-מקור-יחיד (`hopsFrom(a)`) ולא פר-זוג. (ה) **בלתי-נגיש** — אם 73/79 לא הושלמו, יהיו מבודדים ו-`hopsBetween` יחזיר `kUnreachable` → שער-100 יפיל-בילד; אך זו תכונה-רצויה (תופס מבודד).

**4. פתרון:** (א) **adjacency-יחידה מפורשת**: `hopsBetween` קוראת **רק** `rankedNeighborsOf` (77/79) — אותה פונקציה ש-80 סופר עליה. בדיקת-עקביות מפורשת ש-`hopsBetween` ומפקד-80 **מסכימים** על דגימת-זוגות (בדיקה 1). (ב) `kHopPairOverride` מיושם **בתוך** `rankedNeighborsOf` (קשת-נוספת בגרף-עצמו), כך ש-80 ו-90 יורשים אותה **אוטומטית** — לא יישום-כפול. (ג) גרף לא-מכוון: לוודא ש-`rankedNeighborsOf` סימטרי (אם `compatibleWith` סימטרי — `install_engine`), או BFS על-גרף-ה-undirected-closure. (ד) `hopsFrom(a)` (BFS-מקור-יחיד מחזיר map sku→dist) ל-מפקד-80, ו-`hopsBetween` עוטף אותו; לא-פר-זוג. (ה) להישען על 73/79 (0-בלתי-נגישים); `kUnreachable` רק-defensive.

**5. בדיקות:** `test/.../hops_between_test.dart`: (1) `'מסכים עם מפקד-80 (אין גרף-שלישי)'` — לדגום זוגות, `expect(hopsBetween(a,b), ביקור-80-distance)` — **הבדיקה-הקריטית**. (2) `'hopsBetween(a,a)==0'`. (3) `'סימטרי: hopsBetween(a,b)==hopsBetween(b,a)'`. (4) `'≤4 לכל-זוג ב-kDivePool (כולל מים-חמים)'` — re-assert של 80 דרך 90. (5) `'kHopPairOverride מכובד ב-90 וב-80 זהה'` — זוג-עם-override → אותו-מרחק בשניהם. (6) `'אותה adjacency: neighbors(p) של 90 == של 77'`.

**6. שיפור:** לזכרון-מטמון `hopsFrom` — `final Map<String, Map<String,int>> _hopCache` (מקביל ל-`_compatCache`, `install_engine.dart:524`), כי המפקד-80 והכרטיס (back/rail) קוראים מרחקים חוזרות. שומר על תקציב-ביצועים. מחיר: זיכרון O(V²) — אך |kDivePool| מוגבל (מאות), נסבל.

**7. ריאלי?:** כן, אטומי — BFS-יחיד מעל `rankedNeighborsOf` הקיים (77). ~30 שורות. תלוי-בנייה ב-80(`kHopPairOverride`)+89(rail)+77/79(גרף). הסיכון-העיקרי (גרף-שלישי) נבדק ישירות (בדיקה 1). אין צורך לפצל. **תנאי**: 77/79/80 כבר חשפו `rankedNeighborsOf` כמקור-יחיד.

**8. וידוא-פיקס מלא:** `dart analyze`=0-חדש. flag-OFF: `hopsBetween` הוא פונקציה-טהורה לא-מחווטת-לרינדור-ישיר (משמש את back/rail המגודרים ב-81) → זהות-בייטים דרך גדר-`_hopLive`. **העיקר**: בדיקה 1 (90 ⟺ 80, גרף-יחיד) + בדיקה 4 (≤4 קשיח). להריץ את מפקד-80 ו-`hops_between_test` **יחד** ולוודא-הסכמה. taskkill dart; retry-wrap; לא `tail`. אין-leak (טהור). לאמת ש-`rankedNeighborsOf` (77) הוא ה**יחיד** שמיובא (grep ש-`hopsBetween` לא בונה adjacency עצמאי).

**9. תכנון נוסף (שלי):** property-test ש-`hopsBetween` מקיים **אי-שוויון-המשולש** — `hopsBetween(a,c) <= hopsBetween(a,b)+hopsBetween(b,c)` — אינווריאנט-גרף בסיסי שתופס באג ב-BFS/override (override ששובר metric). מעבר ל-"מסכים עם 80": מאמת שה-metric **קוהרנטי** פנימית.

**10. תכנון נוסף (שלי):** `worstHopPair()` `@visibleForTesting` שמחזיר את הזוג-עם-המרחק-המקסימלי + הערך — כך שכשל-בדיקת-4 (זוג>4) **ידווח איזה זוג** (לא רק "נכשל"), ושלב-100 (`verify_card_keyboard.ps1`) יוכל להדפיס את הזוג-הפוגע ב-build-failure. הופך את השער-הקשיח לדיאגנוסטי (מקביל ל-`worstPair` שספייק-72 כבר מודד).

</div>

<div dir="rtl">

# פירוק-מפורט — שלבים 91–100 (P9 סוף · P10 התכנסות+קו · P11 קאט-אובר)

> מקור-אמת לקוד: `C:/Users/User/Desktop/benzi-kb-build/app_flutter`. כל ההפניות מעוגנות בקבצים האמיתיים שם (לא בשום קלון `New folder/buildsmart`, שהוא STALE).
>
> **הקשר-בנייה קריטי שהתגלה בקריאת-הקוד (משנה ישירות את "ריאלי?" של כל שלב):**
> - **`softTilt` עדיין לא קיים.** `card_soft.dart` היום מכיל רק `anchorOf(pool)` (`card_soft.dart:34`) ו-`softSuggestionsFor(anchor)` (`card_soft.dart:43`) — ה-docstring (`card_soft.dart:8-17`) **מצהיר במפורש** ש-Phase 3 הוא "the anchor rule + the suggestion accessor; it deliberately does NOT re-weight the merge — that would be a guaranteed no-op". כלומר `softTilt` (שלב 82) ושכתוב `_mergedChips` ל-top-K (שלב 84) טרם נכתבו. שלב 91 ("בידוד אותות-רכים") מניח ש-82+84+85+88+90 כבר נבנו — אבל **אף אחד מהם לא קיים בקוד**.
> - **`_mergedChips` היום פוזיציוני, לא scored-top-K.** `card_engine.dart:277-295` בונה את השורה ב-`representativeTake`/`take(take)` פוזיציוני, ו-`SignalChip.soft` (`card_engine.dart:79`) תמיד `false` ו-`SignalChip.infoGain` (`card_engine.dart:74`) תמיד `0`. ה-docstring (`card_engine.dart:206-213`) אומר ש"realising Phase 3 will mean… replacing the per-axis positional take with a per-axis scored top-K — a restructure of this loop". זה הקרקע שעליו 84/91 עומדים.
> - **תכנון-חיבור (P10) חי ובשל.** `install_engine.dart` מכיל `buildInstallation` (`:1240`), `buildTreeInstallation` (`:1393`), `lineComplianceChecklist` (`:151`), `_autoAddCompliance` (`:898`, כולל ה-guard `if (items.length < 2) return` ב-`:926`), והכל מנותב היום דרך `InstallStudioScreen` (`catalog_screen.dart:2478`). ה-rails-הרכים נשענים על `connectionsFor` (`word_finder_engine.dart:592`) ו-`assembleKit`/`kSmartProducts` (`recipe_kit.dart`).
> - **`cardPicksProvider`/`planLineFromPicks`/`hop_graph.dart`/`hopsBetween`/`kMaxDiveTurns`/`kUnifiedFinder`/`UnifiedFinderEntry`/`verify_card_keyboard.ps1` — אף אחד לא קיים.** כולם ארטיפקטים חדשים של P8/P10/P11. `scripts/` כיום מכיל **0 קבצי `.ps1`** (רק `.sh`/`.py`/`.js`), אז שלב 100 גם **יוצר את משטח-ה-PowerShell הראשון** (או צריך להחליט `.sh` במקום).
> - **`LensSelectorRow` כבר קיים** (`lens_selector_row.dart`, מחווט ב-`lipskey_products_screen.dart:192`) — שלב 100 צורך אותו, לא בונה אותו.
>
> **תקדים-זהב שכבר בקוד (ה-DNA של P10/P11):** הזרע-הפטור-משער `_kOpeningWordAxis='מילת-פתיחה'` (`card_keyboard_screen.dart:51`) — מילת-הפתיחה זורעת בלי לסמן את ציר-המילה answered. אותו דפוס. וה-self-gate `if (!_live && !widget.forceLiveForTest) return const SizedBox.shrink()` (`card_keyboard_screen.dart:400`) הוא חומת-זהות-הבייטים שכל שלב חייב להישאר מתחתיה.

---

### שלב 91 — בידוד-אותות-רכים + רשת-רגרסיה אינרטי-במיזוג
**1. יעד:** אחרי השלב מוכח **באינווריאנט בר-בדיקה** ש-`softTilt` (שלב 82) משפיע **רק על הסדר בתוך ציר** (re-rank של top-K לאותו ציר) ו**לעולם לא מוסיף שבב, לא מפיל שבב, ולא מזיז שבב בין-צירים**: קבוצת-השבבים-לכל-ציר ואיברי-הקבוצה זהים עם/בלי הטיה; רק ה-`order` בתוך הציר עשוי להשתנות. ובמקביל: היסטוריה-ריקה → `_mergedChips` **זהה-בייטים** ל-golden של שלב 66 (לפני ה-softTilt), כי `softTilt≡1.0` כשאין-עוגן (`card_soft.dart:11-13` כבר מתאר את האינרטיות הזו — השלב מקבע אותה כבדיקה ולא רק כהערה). לפני השלב, אין שום הוכחה שה-softTilt לא דולף ל-set/לסדר-הצירים — הוא רק "אמור" להיות אינרטי.

**2. איך בונים:** (א) להניח ש-82 בנה `double softTilt(SignalChip, {anchor, history, kit})∈[1.0,~1.6]` ב-`card_soft.dart`, ו-84 שכתב את `_mergedChips` (`card_engine.dart:217`) ל-`baseWeight*softTilt`-per-chip עם **top-K-לפי-משקל בתוך ציר** במקום ה-`representativeTake`/`take(take)` הפוזיציוני (`card_engine.dart:291-293`). (ב) השלב עצמו = **שכבת-בידוד + בדיקות**, לא קוד-מוצר חדש: לחשוף helper טהור `tiltWithinAxis(List<SignalChip> axisChips, ...)` שמחזיר את אותם איברים בסדר ממוין-לפי-tilt, ולוודא שהוא **permutation** של הקלט (אותו multiset). (ג) להוסיף `assert` ב-`_mergedChips` (debug-only) ש-`out.map(axisId).toSet()` וספירת-השבבים-לכל-ציר אינם תלויים ב-history (להשוות מול ריצה עם history ריק). (ד) לכתוב את `card_soft_invariants` שמריץ shuffle של history ומאמת set-יציב.

**3. תקלות צפויות:**
- **השלב מקדים את כל תלויותיו.** `softTilt` (82), `_mergedChips`-top-K (84), `isDestination` (85), `historySkus` (88), `hopsBetween` (90) — **אף אחד לא קיים בקוד**. `card_soft.dart` היום מצהיר במפורש (`card_soft.dart:14-17`) שהוא **לא** משכתב את המיזוג. אז 91 לא ניתן לבנייה כפי-שהוא לפני ש-82+84 נבנו.
- **שבירת golden-66 דרך top-K לא-יציב.** אם 84 החליף את `take(take)` ב-top-K שממיין לפי `baseWeight*tilt` אבל `tilt≡1.0` יוצר tie, ה-`sort` של Dart **אינו יציב** — ה-tie-break חייב להיות דטרמיניסטי (sku/אינדקס-מקורי), אחרת היסטוריה-ריקה **לא** תחזיר את golden-66 והבדיקה "זהה-בייטים ל-66" נכשלת. זו בדיוק מלכודת ה-shuffle-stability ש-`WordSignal.chipsFor` כבר פתר ב-canonical sku-sort (`card_signals.dart:164`).
- **דליפה בין-ציר דרך נורמליזציה.** אם softTilt משנה את ה-`expRem`/דירוג-הצירים (ולא רק את הסדר-הפנימי), שבב מציר-A עלול לדחוף שבב מציר-B מחוץ ל-`kMergedKeyCap=10` (`card_engine.dart:173`) — וזו בדיוק ההפרה ש-91 אמור לאסור. ה-docstring של `SignalChip.soft` (`card_engine.dart:76-79`) כבר מבטיח "never produce a standalone key" — צריך לאמת אותו.
- **`anchorOf` תמיד-null במיזוג ⇒ הבדיקה ואקוּמית.** `card_soft_test.dart:30-39` כבר מוכיח ש-`anchorOf(kDivePool)==null` כי `distinctCardCount(kDivePool) > kShowProductsThreshold`. אם softTilt תלוי-anchor בלבד, הוא **לעולם** לא יורה במיזוג ⇒ בדיקת-האינרטיות עוברת באופן-טריוויאלי בלי להוכיח כלום על המקרה שבו tilt≠1.0.

**4. פתרון:**
- לתעד תלות-קשה ב-82+84 ולא להתחיל את 91 לפניהם; אם רוצים לבנות עכשיו — לפצל: 91-now = רק האינווריאנט "tiltWithinAxis הוא permutation" כבדיקת-יחידה טהורה על softTilt (ברגע ש-82 קיים), ו-91-later = ה-assert ב-`_mergedChips` (אחרי 84).
- ב-84 (ובדיקת 91): ה-top-K-בתוך-ציר חייב `sort` עם tie-break מפורש על sku/אינדקס-מקורי (לא `tilt` לבד), בדיוק כמו ה-cross-multiply ב-`card_engine.dart:267-272`. בדיקת-91 מאמתת `tilt≡1.0 ⇒ סדר==הסדר-הפוזיציוני-המקורי`.
- האינווריאנט המרכזי: לבדוק `setOfChipsPerAxis(withHistory) == setOfChipsPerAxis(emptyHistory)` **ו**-`axisRankOrder` זהה — כך דליפה-בין-ציר נתפסת. (softTilt חייב להיכנס **אחרי** דירוג-הצירים והבחירה-לכל-ציר, רק לסידור-פנימי.)
- להזין ל-בדיקת-האינרטיות בריכה **קטנה-מספיק** (`distinctCardCount<=kShowProductsThreshold+ε` עם anchor אמיתי) כדי ש-tilt≠1.0 ייווצר — אחרת הבדיקה ואקוּמית. או: לבדוק את `softTilt` ישירות עם anchor מוזרק (לא דרך המיזוג).

**5. בדיקות:** `card_soft_invariants_test.dart` (לצד `card_soft_test.dart` הקיים):
- `'softTilt re-orders WITHIN an axis only — same multiset'`: לכל ציר, `tiltWithinAxis(chips, history).toSet() == chips.toSet()` ו-`.length` שווה (permutation).
- `'empty history ⇒ _mergedChips byte-identical to step-66 golden'`: `mergedKeys(pool, stack, lex, null)` עם `historySkus={}` שווה לקובץ-golden של 66 (אותו השוואה כמו `card_engine_test`).
- `'history never adds/drops a chip, never changes axis set'`: עם `historySkus` עשיר מול ריק — `out.map((c)=>c.axisId).toList()` זהה ו-`out.length` זהה; רק ה-`order` בתוך ציר עשוי להשתנות.
- `'shuffle-stable under history permutation'`: shuffle של רשימת-ה-history → אותה תוצאה בדיוק (דטרמיניזם).
- `'tilt==1.0 is the no-anchor default (inert)'`: `softTilt(chip, anchor: null) == 1.0` (חופף את `card_soft.dart:11`).

**6. שיפור:** במקום `assert`-debug-only שנעלם ב-release, להוסיף `@visibleForTesting List<SignalChip> debugMergeWithoutTilt(pool, stack, subtype)` שמחזיר את השורה ללא softTilt — כך בדיקת-91 משווה `mergeWithTilt` מול `mergeWithoutTilt` **ישירות** (set-זהה, סדר-אולי-שונה) במקום לשחזר golden-קפוא נפרד. זה הופך את "softTilt אינרטי-על-ה-set" לאינווריאנט שנבדק על **כל** בריכה (property-based), לא רק על snapshot אחד, ומונע סחיפת-golden ב-66↔84.

**7. ריאלי?:** **לא-אטומי כפי-שמוגדר — חסום-על-82+84 שטרם קיימים, וצריך פיצול.** השלב "מבודד" משהו (`softTilt`) שעוד לא נבנה. כ-scoped-עכשיו הוא לא בדיק. הפיצול הנכון: (91a) אינווריאנט-permutation על `softTilt` הטהור (מיד אחרי 82); (91b) ה-assert במיזוג + golden-זהה-ל-66 (אחרי 84); (91c) רשת-הרגרסיה flag-OFF המלאה. אחרי הפיצול כל תת-שלב אטומי ובדיק-יחידה.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF הוא הליבה** — `_mergedChips` כולו מתחת ל-`mergedKeys` שהמסך קורא רק כש-`_live` (`card_keyboard_screen.dart:400`), אבל `_mergedChips` **טהור ונקרא גם מבדיקות** אז ה-byte-identity הקריטי הוא ש-`card_engine_test`/golden-66 חוזרים ירוקים עם history ריק; כל `test/features/card_keyboard/` ירוק (`card_engine_test`, `card_signals_test`, `card_soft_test`, החדש); להריץ עם taskkill-dart-לפני + retry-wrap לכשלי-טעינת-isolate (תקלת-השער המתועדת); לוודא ש-`SignalChip.soft` נשאר `false` לכל שבב-מ-emitted (אינווריאנט `card_engine.dart:79`); אין memo-leak (`_diveVersion`/`_memoVersion`, `card_keyboard_screen.dart:144-152`).

**9. תכנון נוסף (שלי):** **תקרת-tilt מפורשת + clamp שמוגן-בבדיקה.** אם `softTilt` חוזר מערך מחוץ ל-`[1.0,1.6]` (באג חישוב — כפל שלושה אותות chy compat×kit×history), הוא עלול להפוך אות-רך לאות-קשה שמהפך דירוג. להוסיף `assert(t>=1.0 && t<=kSoftTiltMax)` ב-`softTilt`, ולבדוק שגם בקצוות (כל-האותות-מקסימום) ה-tilt לא חורג — כך "רך לעולם לא מנצח קשה" הוא אינווריאנט מספרי, לא רק כוונה.

**10. תכנון נוסף (שלי):** **בדיקת monotonicity של ההטיה.** מעבר ל"permutation", צריך שההטיה תהיה **משמעותית-נכונה**: שבב שה-anchor/kit/history מצביעים עליו חזק יותר חייב לדורג **לא-נמוך-יותר** משבב חלש-יותר באותו ציר. לכתוב בדיקה: בהינתן anchor ו-2 שבבים שבהם compat של אחד ⊋ של השני, ה-tilt של החזק `>=` של החלש. בלי זה, softTilt יכול להיות permutation-תקין אך **לא-שימושי** (מסדר אקראית-עקבית), והאינווריאנט-בלבד לא יתפוס את זה.

---

### שלב 92 — מודל פריטים-נבחרים + סל `cardPicksProvider`
**1. יעד:** אחרי השלב קיים מודל `CardPick` (טהור, value-equality) ו-`cardPicksProvider` (StateNotifier) עם `addPick(pick)` שמ-dedup לפי sku ושומר סדר-הוספה, ו-`canCompleteLine` שמחזיר `true` רק כש-`picks.length>=2` (קו דורש ≥2 עוגנים, בדיוק כמו `buildInstallation` ש-`anchors.length>=2` ל-loop וכמו ה-gate `found.length>=2` המתועד ב-`install_studio_screen.dart:1309`). לפני השלב אין "סל-בחירות-של-המאתר" נפרד — `InstallStudioScreen` משתמש ב-`chainProvider` (`install_engine.dart:38`), אבל המאתר-המאוחד צריך provider משלו שלא מתנגש.

**2. איך בונים:** (א) `lib/features/card_keyboard/card_picks.dart` (או `state/`): `@immutable class CardPick {final String sku; final String labelHe;}` עם `==`/`hashCode` על sku (כמו `SignalChip` ב-`card_engine.dart:81-93`). (ב) `class CardPicks extends StateNotifier<List<CardPick>>`: `void addPick(CardPick p){ if(state.any((x)=>x.sku==p.sku)) return; state=[...state,p]; }`, `void removePick(String sku)`, `void clear()`. (ג) `bool get canCompleteLine => state.length>=2;` (או getter על provider). (ד) `final cardPicksProvider = StateNotifierProvider<CardPicks,List<CardPick>>((_)=>CardPicks());`. (ה) **לא לחווט עדיין** למסך — זה רק המודל (החיווט ב-96/98).

**3. תקלות צפויות:**
- **התנגשות עם `chainProvider`.** `InstallStudioScreen` כבר מחזיק `chainProvider` (`install_engine.dart:38`) כ"קו-הנבנה". אם `cardPicksProvider` ו-`chainProvider` שניהם מאכלסים את אותו `buildInstallation`, שני מקורות-אמת → קו-כפול. צריך החלטה: או `cardPicksProvider` הוא ה-SSOT והמאתר ממיר אליו, או הוא נפרד-לחלוטין מ-install-studio.
- **value-equality שבור ⇒ dedup דולף.** אם `CardPick` לא מגדיר `==`/`hashCode` (Dart default = identity), `picks.any((x)=>x.sku==p.sku)` עדיין עובד (משווה sku ידנית) אבל בדיקת-`Set<CardPick>` תיכשל. צריך לבחור: dedup-by-field ידני **או** value-equality מלא — לא חצי.
- **provider-leak בין-זהות (P2/שלב 21).** `cardPicksProvider` גלובלי → בחירות-של-מעסיק-א דולפות למעסיק-ב. הזיכרון (`identity_isolation`) ושלב 21/32 כבר התמודדו עם זה ל-`stack`. ה-picks חייבים לעבור אותו seam-איפוס-בהחלפת-זהות.
- **`StateNotifier` שמשנה `state` בלי `[...]`-חדש ⇒ אין rebuild.** אם `addPick` עושה `state.add(p)` במקום `state=[...state,p]`, Riverpod לא מזהה שינוי (אותו reference) → ה-UI לא מתעדכן. מלכודת-Riverpod קלאסית.

**4. פתרון:**
- להחליט ש-`cardPicksProvider` הוא ה-SSOT של המאתר-המאוחד, ו-`planLineFromPicks` (שלב 93) ממיר `picks→anchors` ומזין את `buildInstallation` הקיים — **בלי** לגעת ב-`chainProvider` (install-studio נשאר עצמאי עד החלטת-95). כך אין קו-כפול.
- `CardPick` עם value-equality מלא על `sku` (label לא משתתף ב-`==`, כדי ש-label-שונה-לאותו-sku לא יוצר כפילות). בדיקה: `CardPick(sku:'X',labelHe:'a')==CardPick(sku:'X',labelHe:'b')`.
- לבנות את ה-provider מראש עם seam-זהות (family לפי identityKey, או `ref.invalidate` ב-`_restart` של 32) כך ש-91-style-isolation מובטח. בדיקת-בידוד מפורשת.
- `addPick` תמיד `state=[...state, p]` (רשימה-חדשה). אינווריאנט-immutability בבדיקה.

**5. בדיקות:** `card_picks_test.dart`:
- `'addPick dedups by sku, preserves order'`: `add(X),add(Y),add(X)` → `[X,Y]` (X לא כפול, סדר נשמר).
- `'value-equality on sku only'`: `CardPick(sku:'X',labelHe:'a')==CardPick(sku:'X',labelHe:'b')` ו-`hashCode` שווה.
- `'canCompleteLine needs >= 2'`: 0/1 picks → false, 2 → true.
- `'removePick + clear'`: התנהגות-בסיס.
- `'new-list on every mutation (immutability)'`: `identical(before, after)` הוא `false` אחרי addPick (כדי ש-Riverpod ירענן).

**6. שיפור:** להפוך את `CardPick` למודל-עשיר-מינימלית שנושא גם את ה-`LipskeyCatalogProduct` (או רק sku + lazy-lookup דרך `divePoolIndex`/`_skuOf`) — כך `planLineFromPicks` לא צריך לחפש-מחדש את המוצר מה-sku בכל קריאה. אבל לשמור את ה-`==` על sku-בלבד (לא על המוצר-המלא), אחרת dedup נשבר אם שני references לאותו מוצר. זה מאזן בין dedup-נכון לבין יעילות-בנייה.

**7. ריאלי?:** **כן, אטומי ובדיק** — מודל-טהור + StateNotifier בודד, אפס UI, אפס flag. תלות: — (באמת עצמאי, כפי שהתוכנית מסמנת). אחד השלבים הנקיים ב-P10. הסיכון היחיד הוא החלטת-ה-SSOT-מול-chainProvider (סעיף 4), שהיא החלטת-עיצוב ולא חסם-קוד.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין flag/UI ⇒ byte-identity לא-מופר (provider חדש שאיש לא קורא עדיין — `_FavoritesSection`/install-studio לא נוגעים בו); `card_picks_test` ירוק (dedup, value-equality, canCompleteLine, immutability); לוודא שאף מסך-קיים לא watch-מקרי ל-provider-החדש (grep ל-`cardPicksProvider` = הגדרה-בלבד + בדיקה); אין מצב-גלובלי-דולף (בדיקת-בידוד-זהות עוברת); להריץ עם retry-wrap.

**9. תכנון נוסף (שלי):** **cap על מספר-ה-picks.** קו-התקנה ריאלי הוא 2–8 עוגנים; אם המשתמש מוסיף 40 picks, `buildInstallation` ירוץ BFS על כל זוג-עוגנים-עוקב (`install_engine.dart:1258`) — O(picks × BFS) שיכול להיתקע (בדיוק אזהרת "כיול-לקיבולת" בזיכרון). להוסיף `kMaxPicks` (≈12) ו-`addPick` שמתעלם/מתריע מעבר לכך, עם בדיקה.

**10. תכנון נוסף (שלי):** **שמירת-סדר משמעותית (לא רק הוספה).** `buildInstallation` רגיש-לסדר — הוא מחבר עוגן[i]→עוגן[i+1] (`install_engine.dart:1258`), אז סדר-ה-picks **הוא** טופולוגיית-הקו. צריך `reorderPick(from,to)` (גרירה) כבר במודל, אחרת המשתמש לא יכול לתקן "כניסה לפני יציאה" וה-BOM יוצא לא-נכון. לפחות לתעד שהסדר load-bearing ולבדוק שה-`addPick` שומר אותו דטרמיניסטית.

---

### שלב 93 — קיבוע API של buildInstallation + adapter (בליעת תכנון-חיבור, חתימה-קפואה)
**1. יעד:** אחרי השלב קיים `planLineFromPicks(List<CardPick>, {tempC, accessories, ...}) → InstallationPlan` טהור שעוטף את `buildInstallation` הקיים (`install_engine.dart:1240`) **בלי לשנות את חתימתו**, וקיים contract-test שמקבע את החתימה של `buildInstallation` (פרמטרים + שדות `InstallationPlan`) כך ששינוי-עתידי-לא-מכוון נתפס. לפני השלב, אין שכבת-adapter בין המאתר-המאוחד לבין מנוע-ההתקנה — קריאה ישירה תקשור את המאתר לחתימת-המנוע.

**2. איך בונים:** (א) `planLineFromPicks(picks, ...)`: ממפה `picks→List<LipskeyCatalogProduct>` (lookup ב-`divePoolIndex`/`_skuOf`-public), קורא `buildInstallation(anchors, tempC:tempC, accessories:accessories, autoCompliance:false)` ומחזיר את ה-`InstallationPlan`. (ב) **לא לגעת ב-`buildInstallation`** — רק לעטוף. (ג) contract-test שמקבע: `buildInstallation` מקבל `(List<LipskeyCatalogProduct>, {int maxDepthPerSegment, int tempC, Set<String> accessories, bool loop, bool autoCompliance})` ומחזיר `InstallationPlan` עם `items/gaps/quantities/zones/warnings/isComplete/totalPieces/qtyOf/compliance/criticalOpen` (כל ה-API ב-`install_engine.dart:840-881`).

**3. תקלות צפויות:**
- **`buildInstallation([single])` תקין אבל קו-של-1 חסר-משמעות.** `install_engine.dart:1248` מחזיר plan ל-`anchors.first` בלבד; אם `picks.length==1` ה-plan הוא מוצר-בודד בלי gaps — לא קו. ה-adapter צריך לכבד את `canCompleteLine>=2` (שלב 92) ולא לקרוא ל-build על pick-בודד.
- **lookup sku→product נכשל ⇒ עוגן-נעדר.** אם ה-pick נושא sku שאינו ב-`kCompatCatalog` (המאתר עובד על `kDivePool`, ההתקנה על `kCompatCatalog` — **שתי בריכות שונות!**), ה-lookup מחזיר null וה-anchor נופל בשקט → קו-חסר-עוגן. צריך לאמת ש-`kDivePool ⊆ kCompatCatalog` או למפות במפורש.
- **שבירת-חתימה עתידית שקטה.** אם מישהו יוסיף פרמטר-חובה ל-`buildInstallation`, כל הקוראים נשברים — אבל בלי contract-test זה מתגלה רק ב-build. ה-`_skuCache` (`install_engine.dart:13`) הוא mutable-global — אם בדיקה אחרת מזהמת אותו, ה-adapter עלול לראות catalog-מזוהם.
- **`autoCompliance` default.** התוכנית מפרידה: 93=adapter נקי, 94=temp+compliance. אם ה-adapter כבר מדליק `autoCompliance:true`, הוא בולע את 94 ושובר את האטומיות.

**4. פתרון:**
- ה-adapter מחזיר `null`/`InstallationPlan` ריק כש-`picks.length<2` (כיבוד 92), ולא קורא ל-build.
- בדיקת-מטא: `for(pick in allPossiblePicks) assert(_skuOf(pick.sku)!=null)` — או, מעשי: לאמת `kDivePool.every((p)=>kCompatCatalog.any((c)=>c.sku==p.sku))` בבדיקה (אם זה לא מתקיים, לתעד את הפער ולמפות). זה תופס את הפער בין-הבריכות **בזמן-בנייה**.
- contract-test שקורא ל-`buildInstallation` עם **כל** הפרמטרים-בשמם ומאמת את כל שדות-ה-plan — שינוי-חתימה ⇒ אי-קומפילציה של הבדיקה ⇒ אדום-מיידי.
- ה-adapter ב-93 מעביר `autoCompliance:false` (94 ידליק אותו). חתימת-ה-adapter כבר מקבלת `tempC`/`accessories` כפרמטרים-אופציונליים, מוכנה ל-94.

**5. בדיקות:** `card_line_adapter_test.dart` + הרחבת `build_line_bom_test.dart` הקיים:
- `'2 picks → plan contains both anchors'`: `planLineFromPicks([pickA,pickB])` → `plan.items` מכיל את שני ה-sku (כמו שהתוכנית דורשת מפורשות).
- `'1 pick → no line (respects canCompleteLine)'`: `planLineFromPicks([pickA])` → null/ריק, לא plan-של-1.
- `'adapter does NOT auto-add compliance (that is step 94)'`: plan של 93 = `buildInstallation(autoCompliance:false)` — ספירת-items זהה לקריאה-ישירה ללא-compliance.
- `'every dive-pool sku resolves in compat-catalog'` (מטא): מאמת `kDivePool ⊆ kCompatCatalog` (או רושם את ה-allowlist-של-הפער).
- `'buildInstallation signature frozen'` (contract): קריאה עם כל-הפרמטרים-בשמם מתקמפלת + כל-שדות-plan נגישים.

**6. שיפור:** להפוך את ה-adapter ל-`record` שמחזיר `({InstallationPlan? plan, List<String> unresolvedSkus})` — כך 0-עוגנים-שנפלו-ב-lookup לא נעלם בשקט אלא מוחזר לקורא, שיכול להציג "2 מוצרים לא נמצאו במנוע-ההתקנה". זה הופך את פער-הבריכות (sec 3) ממבוי-סתום-שקט למשוב-בונה, ומכין את sheet-תוצאת-הקו (98).

**7. ריאלי?:** **כן, אטומי** — פונקציית-עטיפה טהורה + contract-test, מעל `buildInstallation` הבשל. תלוי ב-92 בלבד. הסיכון היחיד (פער `kDivePool`↔`kCompatCatalog`) הוא בדיק-מטא ולא חסם. נקי.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין UI/flag (פונקציה-טהורה) — byte-identity לא-רלוונטי-ישירות, אבל **חובה** לאמת ש-`buildInstallation` עצמו **לא זז**: להריץ `build_line_bom_test`, `install_engine_safety_test`, `auto_compliance_test`, `install_plan_coverage_test` ולוודא ספירות-BOM זהות (ה-adapter לא נוגע במנוע); `card_line_adapter_test` ירוק; לאפס `_skuCache` בין-בדיקות (או לוודא שהוא לא מזוהם); contract-test מתקמפל. אין מצב/timer.

**9. תכנון נוסף (שלי):** **חיתוך-`maxDepthPerSegment` למאתר.** `buildInstallation` ברירת-מחדל `maxDepthPerSegment=6` (`install_engine.dart:1242`) — BFS עד-6-קפיצות לכל-זוג. במאתר-המאוחד שכבר מבטיח ≤4-קפיצות (P8), קו עם 8 picks = 7 segments × BFS-עומק-6 יכול להיתקע. ה-adapter צריך להעביר `maxDepthPerSegment` נמוך-יותר (≈4, מתואם לחוזה-ה-≤4 של P8/שלב 80) ולתעד את הקשר, אחרת ה-adapter פותח דלת-קיבולת ש-P8 סגר.

**10. תכנון נוסף (שלי):** **קיבוע snapshot של ה-plan לבדיקת-רגרסיה.** מעבר ל-contract-של-החתימה, צריך golden-snapshot של `planLineFromPicks([2-עוגנים-ידועים])` (ה-BOM המלא: items+qty+gaps) — כך שינוי **התנהגותי** ב-`buildInstallation` (שלא משנה חתימה אבל משנה תוצאה — למשל edge-cost ב-`install_engine.dart:776`) נתפס. חתימה-קפואה לבדה לא תופסת רגרסיית-תוכן.

---

### שלב 94 — חיווט temp + auto-compliance לקו (יכולת install_studio נבלעת)
**1. יעד:** אחרי השלב, `planLineFromPicks` נושא **טמפרטורת-קו** (`tempC`) ו**checklist-תאימות אוטומטי**: מעביר `autoCompliance:true` ל-`buildInstallation` (שמפעיל `_autoAddCompliance`, `install_engine.dart:1345-1347`) ומחזיר גם את `plan.compliance(tempC)` (`install_engine.dart:873`). כך היכולת-המרכזית של `InstallStudioScreen` (`install_studio_screen.dart:984` — `buildInstallation(..., autoCompliance:true)`) **נבלעת** במאתר-המאוחד: שבב-temp מזין את אותו מנוע-בטיחות. לפני השלב, ה-adapter (93) קרא עם `autoCompliance:false` — בלי בטיחות.

**2. איך בונים:** (א) ב-`planLineFromPicks` להעביר `tempC` (כבר פרמטר מ-93) ו-`autoCompliance:true` ל-`buildInstallation`. (ב) להוסיף שבב-temp ל-provider/state (`lineTempProvider` חדש או שדה ב-`CardPicks`) — ערכי-מפתח 20°C (קר, ברירת-מחדל) ו-60°C+ (חם, מפעיל PRV/מיכל-התפשטות/TMTV). (ג) `planLineFromPicks` מחזיר `({InstallationPlan plan, List<LineCheck> checklist})` שבו `checklist=plan.compliance(tempC, accessories)`. (ד) `criticalOpen=plan.criticalOpen(tempC)` (`install_engine.dart:877`) לשבב-אזהרה.

**3. תקלות צפויות:**
- **`_autoAddCompliance` קורס על קו-של-1.** `install_engine.dart:926` כבר מגן (`if (items.length < 2) return` לפני ה-`clamp(1, items.length-1)` שאחרת זורק `ArgumentError`) — אבל זה מניח `items` מ-build תקין. אם ה-adapter מעביר picks ש-build הצטמצם ל-item-בודד (כל-העוגנים-חוץ-מאחד נפלו ב-lookup), `_autoAddCompliance` רץ על item-בודד — ה-guard מציל מ-crash אבל **לא מוסיף בטיחות בשקט** (קו-לא-מוגן נראה "תקין").
- **`tempC` לא-מחווט ⇒ קו-חם נראה קר.** אם שבב-ה-temp לא מזין את `planLineFromPicks`, ברירת-המחדל 20°C → `hot=false` (`install_engine.dart:158`) → **אפס פריטי-בטיחות-חמים** למרות שהקו חם. סכנת-בטיחות אמיתית (PRV חסר על דוד).
- **`lineIsSupply` שקרי ⇒ אין ברז-ניתוק.** `_autoAddCompliance` מוסיף isolation-valve רק אם `lineIsSupply(items)` (`install_engine.dart:949`), שתלוי ב-`kVerifiedSpecs[...].endSystems` (`install_engine.dart:68`). מוצרי-מאתר ללא-spec-מאומת → `lineIsSupply=false` → אין ברז-ניתוק על קו-אספקה-אמיתי.
- **`accessories` mutation.** `_autoAddCompliance` **משנה** את ה-Set שמועבר לו (`install_engine.dart:1049-1052` מוסיף HW-CLIP/HW-SEALANT/HW-INSUL). אם ה-adapter מעביר Set-קבוע (`const {}`) — קריסת unmodifiable. (`buildInstallation` עצמו לא מעביר accessories ל-`_autoAddCompliance` — `install_engine.dart:1346` קורא בלי accessories — אבל אם 94 ינסה לתפוס את ה-accessories-המוזרקים, צריך Set-mutable.)

**4. פתרון:**
- ה-adapter מחזיר את `unresolvedSkus` (שיפור-93) כך שקו-שהצטמצם-ל-1 נראה לקורא, ו-94 מתנה את ה-checklist על `plan.items.length>=2`.
- שבב-temp **חובה-מחווט**: בדיקת-94 מאמתת ש-`tempC=80` מייצר `criticalOpen>0` (PRV/מיכל חסרים עד-שמתווספים) ושהם **נוספים** אחרי autoCompliance.
- לתעד ש-`lineIsSupply`/checklist מדויקים רק על מוצרים-עם-`kVerifiedSpecs`; להוסיף בדיקה שמודדת כמה מ-`kDivePool` נושאים spec (כיסוי), ולתעד שקו ממוצרי-מאתר-ללא-spec לא יקבל בטיחות-מלאה (קיר-נתונים, לא באג).
- ה-adapter בונה `accessories = {...passedIn}` (Set-mutable) לפני ההעברה. בדיקה שמעבירה `const {}` לא קורסת.

**5. בדיקות:** `card_line_compliance_test.dart` + הרחבת `auto_compliance_test.dart` הקיים:
- `'tempC flows: 80°C line surfaces hot-water safety items'`: `planLineFromPicks(picks, tempC:80)` → `checklist` מכיל PRV/Bladder-Tank (severity critical), ו-`plan.items` מכיל אותם (autoCompliance הוסיף).
- `'20°C cold line does not add PRV'`: אותם picks ב-20°C → אין PRV ב-checklist-הקריטי-הפתוח.
- `'autoCompliance replaces manual ticking'`: `plan.criticalOpen(80)` קטן/אפס אחרי autoCompliance (לעומת build-ללא-compliance).
- `'1-item line does not crash, surfaces unresolved'`: picks שמצטמצמים ל-1 → אין crash (guard `install_engine.dart:926`), `unresolvedSkus` לא-ריק.
- `'supply line gets isolation valve'`: קו-אספקה-מאומת → ברז-ניתוק נוסף (`_kIsolationValveSkus`).

**6. שיפור:** במקום שבב-temp בינארי (קר/חם), להציג 3-4 ערכים-מקובעים (20°/45°/60°/80°) שכל-אחד מציג **מראש** כמה פריטי-בטיחות הקו יקבל (preview של `criticalOpen` לכל-טמפ) — כך המשתמש בוחר טמפרטורה ורואה מיד את עלות-הבטיחות, במקום לגלות אחרי-בנייה. מנצל את `lineComplianceChecklist` שכבר טהור ובדיק (`install_engine.dart:151`).

**7. ריאלי?:** **כן, אטומי — אך בעל-משקל-בטיחות.** הקוד עצמו קטן (העברת `tempC`+`autoCompliance:true`+החזרת `compliance`), והמנוע (`_autoAddCompliance`) בשל ובדוק (`auto_compliance_test`). הסיכון אינו קוד אלא **כיסוי-נתונים**: הבטיחות מדויקת רק עד-כמה ש-`kVerifiedSpecs` מכסה את מוצרי-המאתר. אטומי-לבדיקה, אבל לתעד את גבול-הכיסוי.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; אין flag/UI חדש (provider+adapter) ⇒ byte-identity לא-מופר ל-install-studio (`chainProvider` לא נגע); **חובה**: `auto_compliance_test`, `install_engine_safety_test`, `zone_tmtv_test`, `full_compliance_audit_test`, `compliance_why_test` כולם ירוקים (94 לא שינה את המנוע, רק קורא לו); `card_line_compliance_test` ירוק (temp-flow, cold-vs-hot, 1-item-no-crash); לוודא ש-`accessories` Set-mutable (אין unmodifiable-crash); retry-wrap.

**9. תכנון נוסף (שלי):** **גילוי-temp אוטומטי מהעוגנים.** במקום לבקש מהמשתמש לבחור temp, להציע ברירת-מחדל-חכמה: אם אחד מה-picks הוא דוד/קולטר-חם/`productType=='דוד'`, להדליק 60°C אוטומטית (עם אפשרות-עקיפה). זה מונע את הסכנה-העיקרית (sec 3 — קו-חם שנשאר ב-20°). מנצל את אותו זיהוי-landmark ש-`_autoAddCompliance` כבר עושה ל-TMTV (`install_engine.dart:968`).

**10. תכנון נוסף (שלי):** **הפרדת checklist-לתצוגה לפי-severity.** `lineComplianceChecklist` מחזיר critical/warning/info מעורבים (`install_engine.dart:77`). ה-sheet (98) צריך להציג קריטי-בולט-אדום מעל אזהרות. לתכנן כבר ב-94 את ה-grouping (`checklist.where((c)=>c.severity==CheckSeverity.critical)`) ולבדוק שספירת-הקריטיים-הפתוחים == `criticalOpen` — כך אין סתירה בין ה"מספר" שהמשתמש רואה לבין הרשימה.

---

### שלב 95 — מסלול-מתכנן ענף/עץ או החלטת-היקף-מפורשת (הכלי נשמר אם לא-נבנה)
**1. יעד:** אחרי השלב, **שאלת-הענף-הפתוחה נסגרת במפורש**: או (א) המאתר-המאוחד תומך גם ב-`buildTreeInstallation` (`install_engine.dart:1393` — גזע + N ענפים-מקבילים ממניפולד), או (ב) המאתר בולע **רק קו-שטוח** (`buildInstallation`) ו-`InstallStudioScreen` **נשאר כלי-נפרד** למסלול-העץ. בכל מקרה — **שום יכולת לא נעלמת**: אם בוחרים (ב), ה-pill של תכנון-חיבור עדיין מנתב ל-`InstallStudioScreen`. לפני השלב, לא ברור אם המאתר אמור לבלוע גם עץ — סתירה-פתוחה שהתוכנית מסמנת כשאלה-מקובעת-בשלב.

**2. איך בונים:** (א) **החלטה מתועדת** (בראש הקובץ + בבדיקה): מסלול-העץ נשאר ב-install-studio (מומלץ — הוא דורש בחירת-מניפולד + מיפוי-ענפים, UX משלו). (ב) `planLineFromPicks` בולע **רק** `buildInstallation` (קו-שטוח). (ג) לוודא ש-`InstallStudioScreen` עדיין נגיש: ה-pill 'תכנון חיבור' (`catalog_screen.dart:2478`) **לא** מוסתר ע"י דגל-המאתר (זה ההבדל מ-pill-ים שכן יוסתרו ב-100). (ד) בדיקת-`line_branch_scope` שמאמתת ששתי-היכולות (שטוח דרך המאתר, עץ דרך studio) קיימות-ושתיהן-עובדות.

**3. תקלות צפויות:**
- **`buildTreeInstallation` קורא ל-`buildInstallation` פנימית.** `install_engine.dart:1419` (`buildInstallation(trunk, ...)`) — אז אם המאתר משנה את התנהגות-ה-build, הוא משפיע גם על העץ. כל שינוי ב-adapter חייב להישאר עטיפה-בלבד.
- **"בליעה" שמסתירה את studio בטעות.** אם 100 מסתיר את כל-ה-pill-ים כש-`kUnifiedFinder` ON, ו-95 החליט ש-studio נשאר — סתירה: 100 יסתיר כלי ש-95 הבטיח לשמור. צריך תיאום-מפורש: studio הוא **חריג** מרשימת-ההסתרה.
- **מניפולד לא-מזוהה ⇒ עץ-נכשל.** `buildTreeInstallation` תלוי ב-`manifoldOutlets` (`install_engine.dart:1372`) שמזהה רק `productType=='מחלק'`/`categoryHe=='מחלקים'` עם spec ≥3-ends. אם המאתר היה אמור לבנות עץ אבל אין מניפולד-בעוגנים, אין-עץ.
- **בדיקה ואקוּמית.** "שום יכולת לא נעלמת" קל לכתוב ככה שהבדיקה עוברת-תמיד (לא בודקת כלום). צריך בדיקה שבאמת מריצה את שני-המסלולים.

**4. פתרון:**
- ההחלטה (ב) מתועדת ב-docstring + בקבוע/דגל (`kUnifiedFinderAbsorbsTree=false`) שהבדיקה קוראת — כך ההחלטה היא נתון-בדיק, לא הערה.
- 95 רושם במפורש ש-`InstallStudioScreen` ב-allowlist-החריגים של 100 (לא-מוסתר). 100 קורא את אותו allowlist. תיאום מפורש בקבוע משותף.
- ה-adapter נשאר עטיפת-`buildInstallation` בלבד; בדיקה שמוודאת ש-`buildTreeInstallation` (העץ) עדיין מחזיר תוצאה זהה לפני/אחרי (לא-נגע).
- בדיקת-`line_branch_scope`: מריצה `planLineFromPicks` (שטוח) **וגם** `buildTreeInstallation(trunk, branches)` ומאמתת ששתיהן מחזירות plan-תקין — שתי היכולות חיות.

**5. בדיקות:** `line_branch_scope_test.dart`:
- `'flat line via unified finder builds'`: `planLineFromPicks([a,b])` → plan שלם.
- `'tree line via install-studio still builds (capability preserved)'`: `buildTreeInstallation(trunk, [t1,t2])` → zones מכיל 'גזע'+'ענף א'/'ענף ב' (`install_engine.dart` zone-tagging).
- `'scope decision is explicit'`: `expect(kUnifiedFinderAbsorbsTree, isFalse)` (ההחלטה מקובעת).
- `'install-studio is on the 100 keep-list'`: `expect(kUnifiedFinderKeepPills, contains('תכנון חיבור'))` — studio לא-יוסתר ב-cut-over.
- `'tree path unchanged by adapter'`: `buildTreeInstallation` תוצאה זהה לפני/אחרי 93-95.

**6. שיפור:** "שדרוג-הדרגתי" — המאתר בולע קו-שטוח **ומזהה** מתי המשתמש בעצם רוצה עץ (≥2 picks הם terminals שכולם תלויים במניפולד-יחיד), ואז **מציע** "נראה שזה מערכת מסועפת — פתח במתכנן-העץ" (deep-link ל-`InstallStudioScreen` עם ה-picks). כך אין יכולת-אבודה וגם אין UX-עץ-מורכב במאתר — גשר-נקי בין השניים. מנצל את `manifoldOutlets` לזיהוי.

**7. ריאלי?:** **כן, אטומי — זו בעיקרו החלטת-היקף מתועדת + בדיקת-שימור.** מעט קוד (קבוע-החלטה + allowlist-חריגים + בדיקה ששני-המסלולים חיים). תלוי ב-94. הערך הוא בסגירת-הסתירה-הפתוחה, לא בקוד. הסיכון: אם **כן** יבחרו לבלוע עץ, השלב מתפוצץ (UX-מניפולד שלם) — אבל ההמלצה (ב) שומרת אותו אטומי.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; byte-identity — אף-pill לא הוסתר עדיין (זה 100), `InstallStudioScreen` ו-`catalog_screen.dart:2478` ללא-שינוי; `line_branch_scope_test` ירוק; כל-מבחני-העץ הקיימים (`manifold_test`, `install_builder_test`, `install_plan_coverage_test`) ירוקים (95 לא נגע ב-`buildTreeInstallation`); לוודא ש-`kUnifiedFinderKeepPills` קבוע-משותף שגם 100 צורך (אין כפילות-allowlist); retry-wrap.

**9. תכנון נוסף (שלי):** **מטריצת-יכולות מפורשת (capability matrix) כבדיקה.** במקום "שום יכולת לא נעלמת" כאמירה, לבנות `const kFinderCapabilities = {'flat-line', 'tree-line', 'compliance', 'kit', ...}` ובדיקה שכל-יכולת ממופה ל-owner מפורש (מאתר/studio) ושאף owner לא-null. כך אם 100 יסתיר משהו שמכסה יכולת, הבדיקה תאדים. זה הופך את "שום-יכולת-לא-נעלמת" לאינווריאנט-מבני שמחזיק לאורך-זמן, לא רק ב-95.

**10. תכנון נוסף (שלי):** **deep-link דו-כיווני studio↔מאתר.** אם studio נשאר, צריך גשר: מ-studio "המשך-במאתר" (להעביר את `chainProvider` ל-`cardPicksProvider`) ומהמאתר "פתח-במתכנן-עץ" (sec 6). לתכנן את ה-seam-של-העברת-המצב כבר ב-95 (פונקציית-המרה `chainToPicks`/`picksToChain` טהורה + בדיקת-round-trip), אחרת השניים נשארים איים-מנותקים והמשתמש מאבד עבודה במעבר.

---

### שלב 96 — terminus התכנסות→כרטיס רושם את הבחירה
**1. יעד:** אחרי השלב, כשהמאתר-המאוחד מתכנס ומשתמש בוחר מוצר (לחיצת product-key ב-`CardShowProducts`, או `CardResolve`), המוצר **נרשם ב-`cardPicksProvider`** (`addPick`) **לפני** פתיחת ה-sheet — כך הבחירה נאספת לקו. לפני השלב, לחיצת-מוצר רק פותחת `showLipskeyProductSheet` (`card_keyboard_screen.dart:367`/`:211`) בלי לאסוף אותה לשום סל.

**2. איך בונים:** (א) ב-`_onWordTap` ענף ה-`_ProductTap` (`card_keyboard_screen.dart:353-368`): לפני `showLipskeyProductSheet(context, picked, v.products)`, להוסיף `ref.read(cardPicksProvider.notifier).addPick(CardPick(sku:picked.sku, labelHe: picked.nameHe))`. (ב) באותו אופן ב-`_pushStep` כשמגיעים ל-`CardResolve` (`card_keyboard_screen.dart:210-212`): `addPick(v.product)` לפני פתיחת-ה-sheet. (ג) הכל **מתחת ל-self-gate** (`card_keyboard_screen.dart:400`) — נשמר flag-OFF-זהה. (ד) `_CardKeyboardScreenState` הוא `ConsumerState` (`card_keyboard_screen.dart:112`) אז `ref.read` זמין.

**3. תקלות צפויות:**
- **רישום-כפול דרך re-entrancy.** `_onWordTap` כבר מגן double-tap עם `_busy` (`card_keyboard_screen.dart:313-315`), אבל `addPick` בתוך ה-resolve-path **וגם** ב-product-path עלול לרשום את אותו מוצר פעמיים (פעם ב-CardResolve, פעם בלחיצה). dedup של 92 מציל, אבל צריך לוודא שלא-נספר-כמות-כפולה.
- **`openSheetOnResolve=false` בבדיקות עוקף את הרישום.** `card_keyboard_screen.dart:131` — בבדיקות, resolve **לא** פותח sheet. אם ה-`addPick` ממוקם **בתוך** ה-`if(openSheetOnResolve)` (`card_keyboard_screen.dart:210`), בדיקות שלא-פותחות-sheet גם לא-ירשמו pick → הבדיקה "word-tap→pick" נכשלת או בודקת-מסלול-לא-נכון.
- **שבירת byte-identity אם `ref.read` מחוץ-לגייט.** אם הקוד החדש רץ לפני `if(!_live)`, הוא ישנה provider גם כש-OFF → לא-זהה-בייטים (provider-state שונה).
- **`CardPick` נבנה מ-`nameHe` ריק.** מוצר עם `nameHe` ריק → pick עם label-ריק. (`_productKeys` כבר מטפל ב-`labels[p.sku] ?? quickLabel(p)`, `card_keyboard_screen.dart:292` — צריך לעקוב אחר אותו fallback.)

**4. פתרון:**
- למקם `addPick` **לפני** ה-`if(openSheetOnResolve)` (כך הוא רץ בבדיקות גם בלי sheet), אבל **אחרי** ה-self-gate (כך OFF-זהה). dedup של 92 מבטיח שגם אם resolve-path ו-product-path שניהם יורים, ה-sku נספר פעם-אחת.
- בדיקת-96 משתמשת ב-`openSheetOnResolve=false` ומאמתת ש-`cardPicksProvider` **כן** מכיל את ה-sku (הרישום עצמאי-מ-sheet).
- כל הקוד החדש מתחת ל-`card_keyboard_screen.dart:400`; בדיקת-byte-identity (flag-OFF) חוזרת לוודא `SizedBox.shrink` + provider-ריק.
- `CardPick(sku: picked.sku, labelHe: labels[picked.sku] ?? quickLabel(picked))` — אותו fallback כמו `_productKeys`.

**5. בדיקות:** `card_picks_wiring_test.dart`:
- `'product-tap records the pick'`: בונים `CardKeyboardScreen(forceLiveForTest:true, openSheetOnResolve:false)`, מגיעים ל-`CardShowProducts`, מקישים product-key, `expect(container.read(cardPicksProvider).map((p)=>p.sku), contains(thatSku))`.
- `'resolve also records'`: דחיפת-steps עד `CardResolve` → `cardPicksProvider` מכיל את `v.product.sku`.
- `'double-tap records once (dedup)'`: שתי-לחיצות מהירות → pick יחיד (dedup של 92 + `_busy`).
- `'flag OFF: no pick recorded'`: flag-OFF → `SizedBox.shrink` **וגם** `cardPicksProvider` ריק.
- `'label fallback for blank nameHe'`: מוצר עם nameHe-ריק → pick עם label לא-ריק (quickLabel).

**6. שיפור:** להציג **משוב-ויזואלי-מיידי** ברישום: badge על כפתור-הקו ("2 נבחרו") שמתעדכן ב-`addPick`, כך המשתמש יודע שהבחירה נאספה (אחרת הוא בוחר, ה-sheet נפתח, והוא לא יודע שזה "נכנס לקו"). מנצל ש-`cardPicksProvider` הוא StateNotifier שה-UI כבר יכול `watch`. הופך את הרישום-השקט לפעולה-נראית.

**7. ריאלי?:** **כן, אטומי** — 2 שורות `addPick` בשני ה-terminus-paths הקיימים, מתחת לגייט. תלוי ב-92. הסיכון היחיד (מיקום מול `openSheetOnResolve`) הוא נקודתי ונפתר בסעיף 4. בדיק-widget נקי.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF קריטי** — הקוד מתחת ל-self-gate (`card_keyboard_screen.dart:400`), אז `card_keyboard_screen_test` (flag-OFF → `SizedBox.shrink` + `cardPicksProvider` ריק) חוזר ירוק; `card_picks_wiring_test` ירוק; כל `test/features/card_keyboard/` ירוק; לוודא **מספר-overrides-Riverpod קבוע** בין-pumps (מלכודת Riverpod — `cardPicksProvider` override יציב); אין memo-leak; retry-wrap + taskkill-dart-לפני.

**9. תכנון נוסף (שלי):** **ביטול-בחירה (un-pick) מאותו terminus.** אם המשתמש בחר מוצר בטעות, חייב להיות מסלול-חזרה: לחיצה-שנייה על אותו מוצר/כפתור-"הסר" ב-badge → `removePick`. בלי זה, dedup מונע הוספה-כפולה אבל לא **הסרה**, והמשתמש תקוע עם pick-שגוי עד clear-מלא. לתכנן את ה-toggle כבר ב-96.

**10. תכנון נוסף (שלי):** **רישום עם הקשר-המסלול (provenance).** ה-pick צריך לזכור **איך** הגיעו אליו (אילו crumbs/zerע) — לא רק ה-sku. זה מאפשר: (א) ל-sheet-תוצאת-הקו (98) להציג "נבחר דרך: ברז › נחושת › 1/2"", (ב) ל-`back` (78) לחזור למסלול-הבחירה. לשמור `List<String> viaCrumbs` ב-`CardPick` (מ-`crumbs`, `card_keyboard_screen.dart:175`). שדה-נתון בלבד, render-אופציונלי, אפס-סיכון.

---

### שלב 97 — rail בין-מוצרים + חידוד יציאת ≤12 "פשוט בחר"
**1. יעד:** אחרי השלב, ב-`CardShowProducts` (כשהבריכה ≤`kShowProductsThreshold=12`, `card_engine.dart:164`) מוצג **rail בין-מוצרים** (`_BetweenRail`) — top-6 שכנים מהגרף-הקנוני (אותו `hopsBetween`/adjacency של שלב 90), עם כותרת 'בחר מתוך N', וה-≤12 "פשוט בחר" מחודד: הרשימה לעולם ≤12 מקשים. לפני השלב, `CardShowProducts` רק מציג product-keys שטוחים (`card_keyboard_screen.dart:288-294`) בלי rail-קפיצה.

**2. איך בונים:** (א) להניח ש-90 בנה `hopsBetween(a,b)` ו-`rankedNeighborsOf(p)` מעל ה-adjacency-הקנוני (שלב 77/89). (ב) `_BetweenRail` widget שמקבל את ה-`CardShowProducts.products`, לוקח את העוגן-הנוכחי (אם יש pick אחרון/מוצר-במוקד) ומציג `rankedNeighborsOf(anchor).take(6)` כשבבים-לחיצים. (ג) tap על שבב-rail → `_switchByChip`/קפיצה-במקום (שלב 76) — לא sheet-רקורסיבי. (ד) כותרת 'בחר מתוך ${distinctCardCount(products)}'. (ה) הכל מתחת ל-self-gate.

**3. תקלות צפויות:**
- **`hopsBetween`/`rankedNeighborsOf`/`_switchByChip` לא קיימים.** כולם ארטיפקטים של P8 (77/79/80/90) ו-76 — **אף אחד לא בקוד**. `grep` ל-`hopsBetween`/`hop_graph`/`rankedNeighborsOf` = 0-תוצאות. 97 חסום-קשה עליהם.
- **אין "עוגן" ב-CardShowProducts.** ה-rail צריך מ-מי-לחשב-שכנים. ב-`CardShowProducts` הבריכה היא ≤12 מוצרים-שווים — אין "מוקד". אם לוקחים את `products.first` כעוגן, ה-rail שרירותי. צריך עוגן-מוגדר (ה-pick-האחרון? המוצר-תחת-האצבע?).
- **rail מציג מוצר שכבר ברשימה ⇒ כפילות.** `rankedNeighborsOf(anchor)` עלול להחזיר מוצר שכבר ב-`products` (12 הנראים) → שבב-rail כפול לכפתור-מוצר. בלבול.
- **≤12 לא-נאכף.** `distinctProducts` כבר חוסם ל-`kFirstWordCount`? לא — `CardShowProducts(distinctProducts(pool))` (`card_engine.dart:165`) לא חותך ל-12, רק `distinctCardCount<=12` הוא התנאי-לכניסה. אם בריכה בדיוק-12-distinct אך 40-variants, `distinctProducts` מחזיר... צריך לאמת את ה-cap.

**4. פתרון:**
- תלות-קשה ב-90+76+77 — לתעד ולא לבנות 97 לפניהם. ה-rail עצמו זעיר; ה-bottleneck הוא הגרף.
- העוגן = ה-pick-האחרון מ-`cardPicksProvider` (שלב 96) אם קיים, אחרת `products.first` (fallback מתועד). בדיקה לכל-מקרה.
- ה-rail מסנן `rankedNeighborsOf(anchor).where((n)=>!products.contains(n))` — שכנים-מחוץ-לרשימה-הנראית בלבד (קפיצה ליעד-חדש, לא לאותו-מסך).
- לאמת/לאכוף את ה-cap: `_productKeys` או `_BetweenRail` חותך `.take(12)`; בדיקה ש-`keys.length<=12` תמיד.

**5. בדיקות:** `card_between_rail_test.dart`:
- `'between-rail shows ranked neighbors from the canonical graph'`: `CardShowProducts` עם עוגן → ה-rail = `rankedNeighborsOf(anchor).take(6)` (אותו גרף כמו 90).
- `'rail tap jumps in place (no second sheet)'`: tap שבב-rail → אין `showLipskeyProductSheet` שני, הבריכה התחלפה (`_switchByChip`).
- `'≤12 keys in ShowProducts'`: לכל בריכת-ShowProducts, `_keysFor(v).length <= 12`.
- `'rail excludes already-visible products'`: שבבי-rail ∩ products-הנראים = ∅.
- `'title shows distinct count'`: 'בחר מתוך ${distinctCardCount}'.

**6. שיפור:** ה-rail צריך להציג **למה** כל שכן מוצע ("גודל זהה", "אותו חומר", "מתחבר") — לא רק שם, כדי שהקפיצה תהיה מודעת. מנצל ש-`hopsBetween`/הגרף-הקנוני נבנה מ-compat+variants+kit (77/89), אז כל-קשת נושאת-סיבה. הופך את ה-rail מ"6 שמות אקראיים" לניווט-מוסבר, ומחזק את חוזה-ה-≤4 (המשתמש רואה שהקפיצה מקרבת).

**7. ריאלי?:** **לא-אטומי כפי-שמוגדר — חסום-על-P8 (90/76/77) שטרם קיים, ובולע שתי-מטרות.** השלב מערבב (א) rail-קפיצה חדש (תלוי-גרף) ו-(ב) "חידוד ≤12" (אכיפת-cap, עצמאי). מומלץ לפצל: 97a = אכיפת-≤12 ב-`_keysFor` (עצמאי, מיד-בדיק), 97b = `_BetweenRail` (אחרי 90/76/77). אחרת בדיקה-בודדת לא תבחין אם ה-cap או ה-rail שבר.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF** — ה-rail מתחת ל-self-gate (`card_keyboard_screen.dart:400`), `card_keyboard_screen_test` (OFF→shrink) ירוק; `card_between_rail_test` ירוק; לוודא ש-`_switchByChip` לא פותח route-שני (audit-gate כמו שלב 76/81); **חובה**: מפקד-≤4 של שלב 80 עדיין ירוק (ה-rail משתמש באותו גרף — אסור שיסטה); כל `test/features/card_keyboard/` ירוק; retry-wrap.

**9. תכנון נוסף (שלי):** **fallback כשאין-שכנים (rail לעולם-לא-ריק).** שלב 79 כבר דורש `rankedNeighborsOf>=kMinNeighbors`, אבל אם העוגן הוא מוצר-מבודד (81 מים-חמים?), ה-rail עלול לצאת ריק → שורה-מתה. צריך fallback: אם 0-שכנים, להציג שכני-קטגוריה/קבוצה (כמו 79). לבדוק שגם מוצר-קצה נותן rail-לא-ריק, אחרת ה-≤4 לא מובטח דרך-ה-UI.

**10. תכנון נוסף (שלי):** **בידול ויזואלי rail-קפיצה מול product-keys.** ב-`CardShowProducts` יהיו עכשיו **שני** סוגי-מקשים: product-keys (בחר-זה) ו-rail-chips (קפוץ-לשם). בלי בידול ויזואלי (כמו שבב-יעד #41, `Icons.north_east`+border, שכבר קיים בקוד) המשתמש לא יבחין בין "בחירה" ל"קפיצה". לנצל את אותו idiom-יעד הקיים (`card_keyboard_screen.dart:276` כבר משתמש ב-`axisGlyph`) — שבב-rail מקבל glyph-קפיצה מובחן. אחרת לחיצה-על-rail-במקום-בחירה תבלבל.

---

### שלב 98 — הוסף-לקו + שבב-השלם-קו + sheet-תוצאת-קו (BOM/סל)
**1. יעד:** אחרי השלב, ב-sheet-המוצר (`LipskeyProductSheet`) יש כפתור 'הוסף לקו' (→`addPick`), וכשיש ≥2 picks מופיע שבב 'השלם-קו' (`_CompleteLineChip`) שמריץ `planLineFromPikcs` (93+94) ופותח **sheet-תוצאת-קו**: BOM מפורט (items+qty), פערים (`gaps`), checklist-תאימות, וכפתור 'הוסף הכל לסל' (→`smart_cart`). לפני השלב, ה-sheet מציג מוצר-בודד + ערכת-התקנה שלו (`_buildKit`, `lipskey_product_sheet.dart:2300`) אבל אין "אסוף-לקו→BOM→סל".

**2. איך בונים:** (א) ב-`LipskeyProductSheet` להוסיף כפתור 'הוסף לקו' שקורא `ref.read(cardPicksProvider.notifier).addPick(CardPick(sku:widget.product.sku, labelHe:widget.product.nameHe))`. (ב) `_CompleteLineChip` שמרונדר רק כש-`ref.watch(cardPicksProvider).length>=2` (`canCompleteLine`), tap→`planLineFromPicks(picks, tempC)`. (ג) sheet-תוצאת-קו (`_LineResultSheet`): `plan.items` עם `plan.qtyOf(sku)` (`install_engine.dart:869`), `plan.gaps` (`install_engine.dart:849`), `plan.compliance(tempC)` (94), וכפתור 'הוסף הכל לסל' שמוסיף כל item×qty ל-`smart_cart`. (ד) הכל מאחורי `kCardKeyboardFlag` (ה-sheet משותף עם המסלול-החי, אז ה-תוספות חייבות דגל).

**3. תקלות צפויות:**
- **ה-sheet משותף עם הקטלוג-החי!** `showLipskeyProductSheet` (`lipskey_product_sheet.dart:29`) נקרא מ-**הרבה** מקומות (`catalog_screen`, finder, `card_keyboard_screen.dart:367`). הוספת כפתור 'הוסף לקו' **ללא דגל** תופיע בכל-הקטלוג-החי → **שבירת byte-identity** של פרודקשן. חייב `if (ref.watch(featureFlagsProvider).contains(kCardKeyboardFlag))`.
- **`planLineFromPicks` עלול להחזיר plan-עם-gaps.** אם העוגנים לא-מתחברים (`install_engine.dart:1270` רושם gap), ה-BOM חלקי. ה-sheet חייב להציג gaps בכבוד ('לא נמצא חיבור בין X ל-Y'), לא להעמיד-פנים-שלם.
- **'הוסף הכל לסל' עם qty.** `plan.quantities` (`install_engine.dart:853`) — connector שחוזר על-2-מפרקים qty=2. אם הוספה-לסל מתעלמת מ-qty, הסל חסר-חלקים. צריך `for(sku in plan.quantities.keys) addToCart(sku, qty)`.
- **`smart_cart` API לא-מאומת.** `smart_cart.dart` קיים (`state/smart_cart.dart`) אבל ה-API-המדויק (`addToCart`?) לא-מאומת בקריאה — צריך לבדוק את החתימה לפני חיווט.
- **picks לא-מתאפסים אחרי הוספה-לסל** → קו-רפאים נשאר ל-build-הבא.

**4. פתרון:**
- **כל** התוספות ל-sheet עטופות ב-`kCardKeyboardFlag`-watch — בדיקת-byte-identity מאמתת שב-OFF ה-sheet זהה-לחלוטין (אין כפתור-קו, אין שבב). זו ההגנה-הקריטית.
- sheet-תוצאת-קו מציג `if(plan.gaps.isNotEmpty)` בלוק-אדום עם `gap.why` (`install_engine.dart:830`) — פערים גלויים, לא-מוסתרים.
- 'הוסף הכל לסל': `plan.quantities.forEach((sku,qty)=>cart.add(sku, qty))` — qty-aware. בדיקה שהסל מקבל את הכמויות-הנכונות.
- לקרוא את `smart_cart.dart` ולאמת חתימה לפני-חיווט (כבר מיובא ב-`install_studio_screen.dart:20` — לחקות את הקריאה שם).
- אחרי 'הוסף הכל לסל': `ref.read(cardPicksProvider.notifier).clear()` + toast-אישור. בדיקה ש-picks ריק אחרי.

**5. בדיקות:** `card_complete_line_test.dart` + הרחבת `build_line_bom_test.dart`:
- `'add-to-line appends pick'`: tap 'הוסף לקו' → `cardPicksProvider` מכיל את sku.
- `'complete-line chip appears at >=2 picks'`: 1 pick → אין שבב; 2 → שבב מופיע; tap → `_LineResultSheet`.
- `'line result shows detailed BOM with qty'`: `_LineResultSheet` מציג `plan.items` עם `qtyOf` הנכון.
- `'add-all-to-cart respects quantities'`: 'הוסף הכל לסל' → הסל מכיל כל-sku×qty (qty-aware), picks מתאפסים.
- `'flag OFF: sheet is byte-identical (no line affordances)'`: flag-OFF → `LipskeyProductSheet` ללא כפתור-קו/שבב (השוואת-עץ-widgets).
- `'gaps surfaced honestly'`: picks לא-מתחברים → `_LineResultSheet` מציג בלוק-gaps.

**6. שיפור:** sheet-תוצאת-קו צריך לבלוע גם את **ערכת-הכלים-של-הקו** (`recommendedKitFor(chain)`, `install_kit.dart:155`) — לא רק BOM-חלקים אלא גם הכלים (מפתחות/מכווצים/דיאלקטרי) לכל-המפרקים, deduped. ה-`_buildKit` ב-sheet כבר עושה זאת ל-מוצר-בודד (`lipskey_product_sheet.dart:2302`); כאן זה ל-**כל-הקו**. כך "השלם-קו" נותן הזמנה-מלאה (חלקים+כלים+בטיחות) — בדיוק היכולת המרכזית של install-studio, נבלעת.

**7. ריאלי?:** **גבולי — שלושה רכיבים-נפרדים בשלב אחד.** (א) כפתור 'הוסף לקו' ב-sheet, (ב) שבב-השלם-קו, (ג) sheet-תוצאת-קו-עם-BOM-וסל. כל-אחד תלוי-משלו (92/93/94) ושלושתם נוגעים ב-sheet-המשותף-הרגיש. מומלץ לפצל: 98a = 'הוסף לקו' + byte-identity-OFF, 98b = שבב + sheet-תוצאה + סל. אחרת בדיקה-שנכשלת לא תבחין איזה רכיב שבר את ה-sheet-המשותף.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF הוא הסיכון-הגדול-ביותר ב-batch** — ה-sheet משותף עם כל-הקטלוג-החי, אז `product_sheet_strips_test`, `sheet_close_test`, `favorite_tile_opens_sheet_test`, `product_journey_test` **כולם** חייבים לחזור ירוקים עם flag-OFF (ה-sheet זהה-בייטים); `card_complete_line_test` ירוק; `build_line_bom_test`/`auto_compliance_test` ירוקים (המנוע לא-נגע); לאמת ש-`smart_cart` קיבל qty-נכון; picks מתאפסים; retry-wrap + taskkill-dart.

**9. תכנון נוסף (שלי):** **שמירת-קו (saved line) לפני-סל.** install-studio כבר תומך ב-saved-jobs עם autobom (`install_studio_screen.dart:1321`). sheet-תוצאת-הקו צריך 'שמור קו' (לא רק 'הוסף לסל') כך שהמשתמש יכול לחזור לקו מאוחר. מנצל את `saved_line_reconstruct`/`saved_project_autobom` הקיימים. בלי זה, קו-שלם הולך-לאיבוד אם המשתמש לא-קונה-מיד.

**10. תכנון נוסף (שלי):** **gate-בטיחות לפני-סל.** אם `plan.criticalOpen(tempC)>0` (פריט-בטיחות-קריטי חסר, `install_engine.dart:877`), 'הוסף הכל לסל' צריך **להזהיר** ("חסר PRV — קו-חם לא-בטוח") ולא להוסיף-בשקט. autoCompliance של 94 אמור לכסות, אבל אם מוצר חסר-spec → פער-בטיחות שקט. לחבר את `criticalOpen` לכפתור-הסל כ-gate-רך (אישור-מפורש), אחרת המאתר ימכור קו-לא-תקני.

---

### שלב 99 — התכנסות→קו E2E + רגרסיית flag-OFF/בידוד
**1. יעד:** אחרי השלב יש בדיקת-E2E אחת שמריצה את כל-המסלול: פתיחה→`CardAskWords`→זרע→`MergedKeys`→...→`CardShowProducts`→2-picks→שבב-השלם-קו→`_LineResultSheet` עם BOM, **וגם** רגרסיית flag-OFF (כל-המשטח מצטמצם ל-`SizedBox.shrink`) ובידוד-זהות (picks/stack לא-דולפים בין-מעסיקים). זו בדיקת-הקבלה של P10. לפני השלב, כל רכיב (92-98) נבדק-בנפרד אך לא המסלול-המלא.

**2. איך בונים:** (א) `card_line_e2e_test.dart`: `CardKeyboardScreen(forceLiveForTest:true, openSheetOnResolve:false)` ב-`ProviderScope`; לדמות זרע-מילה→לדחוף chips עד `CardShowProducts`→`addPick`×2→לאמת `canCompleteLine`→להריץ `planLineFromPicks`→לאמת BOM-עם-2-העוגנים. (ב) רגרסיית-OFF: אותו flow flag-OFF → `find.byType(WordKeyboard)` = `findsNothing`, `cardPicksProvider` ריק. (ג) בידוד: לשנות זהות (seam של 21/32) → `cardPicksProvider`+`stack` מתאפסים. (ד) להריץ את כל-החבילות שהתוכנית מסמנת ירוקות: `install_engine`/`build_line_bom`/`auto_compliance`.

**3. תקלות צפויות:**
- **תלות-טרנזיטיבית בכל-92-עד-98** (ובעקיפין ב-93/94 שתלויים ב-`buildInstallation`, וב-95). אם **אחד** מהם לא-נבנה, ה-E2E לא-רץ. וכפי שנמצא — `cardPicksProvider`/`planLineFromPicks` עדיין לא-קיימים, אז 99 חסום על כל-P10.
- **flakiness של isolate** (תקלת-השער המתועדת בזיכרון): בדיקת-E2E כבדה (widget+provider+מנוע-BFS) על isolate-אקראי → `Connection closed before test suite loaded`. צריך retry-wrap.
- **`pumpAndSettle` תלוי-sheet.** ה-sheet הוא `showModalBottomSheet` (`lipskey_product_sheet.dart:34`) — `pumpAndSettle` עלול להיתקע על-אנימציה או לדרוש `openSheetOnResolve:false`. ה-E2E צריך לבדוק את ה-plan **לוגית** (`cardPicksProvider`→`planLineFromPicks`) ולא דרך-פתיחת-sheet-אמיתית.
- **בידוד-זהות תלוי-21** שטרם-קיים (כמו 32/88).

**4. פתרון:**
- לתעד תלות-קשה בכל-P10; 99 הוא בדיקת-קבלה, נבנה **אחרון** ב-P10. אם רוצים קודם — לכתוב את ה-skeleton עם `skip:'pending 92-98'` כך שהמבנה-קיים והבדיקות-נדלקות-הדרגתית.
- retry-wrap בשלב-הטסט (העוטף שמריץ-מחדש רק כשלי-טעינה ולעולם-לא-כשל-אמיתי — בדיוק המתועד בזיכרון ל-GATE) + taskkill-dart-לפני.
- ה-E2E בודק את ה-plan דרך `planLineFromPicks(container.read(cardPicksProvider))` **לוגית**, לא דרך ה-modal-sheet (שמשאיר את ה-UI-rendering ל-98's widget-test). מפריד E2E-לוגי מ-sheet-rendering.
- בידוד: להזריק `identityProvider` override (כמו 32) ולאמת לוגית עד-ש-21 נבנה.

**5. בדיקות:** `card_line_e2e_test.dart`:
- `'full path: open → seed → merge → show → 2 picks → plan with both'`: המסלול-המלא; ה-plan מכיל את שני-העוגנים.
- `'flag OFF: whole surface shrinks, no picks'`: flag-OFF → `WordKeyboard` נעדר, `cardPicksProvider` ריק.
- `'identity switch clears picks AND stack (no leak)'`: החלפת-זהות → שניהם מתאפסים, מעסיק-ב לא-יורש.
- `'gaps path: unconnectable picks still produce a (partial) plan, no crash'`: 2 picks-לא-מתחברים → plan עם gaps, אין-throw.
- regression-suite: `install_engine_safety_test`/`build_line_bom_test`/`auto_compliance_test` ירוקים (התוכנית מסמנת אותם מפורשות).

**6. שיפור:** להוסיף **מפקד-≤6-עד-קו** ל-E2E: לא רק "מסלול-אחד עובד" אלא ש-מ-N-זרעים-מייצגים כל-אחד מגיע ל-`CardShowProducts` תוך ≤6 (חוזה-P7/שלב 69) **ואז** ל-2-picks תוך ≤4 (חוזה-P8/שלב 80). כך E2E מאמת את **שני-החוזים** end-to-end, לא רק שהצינור-מחובר. מנצל את `kMaxDiveTurns` (67) ו-`hopsBetween` (90).

**7. ריאלי?:** **לא-אטומי כפי-שמוגדר — חסום על כל-P10 (92-98) שטרם קיים, ובולע 3-מטרות** (E2E-מסלול, רגרסיית-OFF, בידוד-זהות). מומלץ לפצל: 99a = E2E-מסלול-מאושר (אחרי 98), 99b = רגרסיית-OFF + regression-suite, 99c = בידוד-זהות (תלוי-21). כל תת-בדיקה אטומית. כ-batch-אחד הוא "בדיקת-קבלה" שמטבעה אינה-אטומית.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new; **flag-OFF** — ה-E2E עצמו מאמת את ה-shrink, ובנוסף כל-מבחני-ה-sheet-המשותף (`product_sheet_strips_test`, `sheet_close_test`) חוזרים ירוקים; כל `test/features/card_keyboard/` + `install_engine*`/`build_line_bom`/`auto_compliance` ירוקים; להריץ עם retry-wrap-לכשלי-isolate + taskkill-dart-לפני (תקלת-השער); לוודא אין pending-timer/sheet-route-leak (ה-modal נסגר); אין memo-leak; להריץ-פעמיים-לאשר-דטרמיניזם.

**9. תכנון נוסף (שלי):** **baseline-snapshot של ה-analyze (zero-new אמיתי).** התוכנית דורשת "analyze zero-new" אבל בלי baseline-מקובע (כמו שלב 1/2 רושמים 18 infos) "zero-new" לא-מדיד. 99 צריך לקבע baseline-analyze אחרי-P10 ולהשוות מולו, אחרת אזהרה-חדשה-אחת נבלעת. לרשום את ה-baseline בקובץ-בדיקה.

**10. תכנון נוסף (שלי):** **בדיקת-עומס/קיבולת ל-E2E (anti-stuck).** מסלול-של-8-picks × BFS-עומק-6 (sec 93/3) יכול להיתקע — בדיוק "כיול-לקיבולת" המתועד. 99 צריך בדיקה שמודדת **זמן** של `planLineFromPicks` על קו-מקסימלי (`kMaxPicks`) ומוודאת שהוא מתחת-לסף (למשל <500ms), אחרת ה-cut-over (100) יפיל בילד-איטי. מדידה-לפני-אבחון, כפי שהזיכרון מורה.

---

### שלב 100 — קאט-אובר: דגל+ניתוב+כניסה+re-home+הסתרת-כלים + שער-מרכזי קשיח
**1. יעד:** אחרי השלב, מאחורי `kUnifiedFinder` (דגל-חדש, OFF כברירת-מחדל): (א) `pill_routing` ממפה את 9-תוויות-הכלים לתפקידים, (ב) `UnifiedFinderEntry` (שדרה+6-פיות) הוא נקודת-הכניסה-האחת, (ג) כל-pill-מאתר (מאתר/מאתר-חכם/מקלדת-חכמה) מנותב אליו, (ד) קטגוריות/עץ-חכם/וריאנטים→`LensSelectorRow` (הקיים) אחרי-תוצאה, (ה) מועדפים/אחרונים→שבבי-קיצור, (ו) תכנון-חיבור→rails (או נשמר לפי-95), (ז) הכלים מוסתרים כש-ON, (ח) `verify_card_keyboard.ps1` **מפיל בילד** על קוטר>4 או כרטיס>6-תורים. פרודקשן זהה-בייטים עד-שהבעלים מדליק. לפני השלב, `kCardKeyboardFlag` קיים אבל מנתב רק pill-יחיד ('מקלדת חכמה', `catalog_screen.dart:2463`) — אין קאט-אובר-מלא ולא שער-CI.

**2. איך בונים:** (א) `kUnifiedFinder` חדש (כמו `kCardKeyboardFlag`, `card_keyboard_flag.dart:12`). (ב) `pill_routing.dart`: `Map<String,PillRole>` (9 התוויות מ-`catalog_screen.dart:2452-2479` → finder/lens/shortcut/rails). (ג) `UnifiedFinderEntry` עוטף את `CardKeyboardScreen`+6-הפיות (P3/P5). (ד) ב-`_CatalogBody.build` (`catalog_screen.dart:2449`): `if(unifiedOn){ route every finder-pill to UnifiedFinderEntry; }`. (ה) `_SectionChipsRow` (`catalog_screen.dart:712`): כש-ON, **להסתיר** את ה-pill-ים שנבלעו (מאתר/מאתר-חכם/עץ-חכם/וריאנטים) ולהשאיר את החריגים (95: תכנון-חיבור). (ו) `scripts/verify_card_keyboard.ps1`: מריץ את מפקדי-≤6 (69) ו-≤4 (80) ו-`exit 1` על חריגה.

**3. תקלות צפויות:**
- **שבירת byte-identity של הקטלוג-החי.** `_SectionChipsRow` ו-`_CatalogBody` הם **המסך-הראשי-החי** (`catalog_screen.dart`). כל שינוי-ניתוב חייב להיות מתחת ל-`if(unifiedOn)` — אחרת כל-משתמש רואה קטלוג-שונה. זו הפרה-החמורה-ביותר. ה-tutorial-precedent: `kCardKeyboardFlag`/`kWordFinderFlag` כבר עושים זאת נכון (`catalog_screen.dart:722-727`, render-pill-only-when-on).
- **`verify_card_keyboard.ps1` — אין תקדים-ps1.** `scripts/` מכיל **0 קבצי .ps1** (רק .sh/.py/.js). ה-CI הקיים (`audit_gates.sh`, `protocol_check.sh`, `mutation_verify.sh`) הוא **bash**. ps1 על-לינוקס-CI לא-ירוץ. צריך או `.sh` (להתאים לתקדים) או pwsh-מותקן.
- **שני-דגלים בו-זמנית.** `kCardKeyboardFlag` (קיים) ו-`kUnifiedFinder` (חדש) — אם שניהם ON, התנגשות-ניתוב (שני pill-ים מנתבים לאותו מקום). צריך עדיפות-מוגדרת או ש-`kUnifiedFinder` בולע את `kCardKeyboardFlag`.
- **הסתרת-pill ששובר ניווט-קיים.** אם מסתירים 'תכנון חיבור' אבל 95 הבטיח לשמור אותו → סתירה (כפי שזוהה ב-95/sec 3). וה-deep-links הקיימים ל-`InstallStudioScreen` (`catalog_screen.dart:2478`) ישברו.
- **השער מפיל-בילד על baseline-קיים.** אם יש **היום** כרטיס>6-תורים או זוג>4 (offenders ידועים), השער הקשיח יפיל **כל** בילד מיד — חוסם את כל-הפיתוח. צריך allowlist-מצטמצם (כמו 67/33 מתארים).

**4. פתרון:**
- **כל** הניתוב/הסתרה מתחת ל-`if(ref.watch(featureFlagsProvider).contains(kUnifiedFinder))` — בדיקת-`catalog_pills_byte_identity` מאמתת 9-ענפים: OFF→זהים-לחלוטין, ON→`UnifiedFinderEntry`. זו ההגנה-המרכזית, על-דפוס ה-pill-ים הקיימים.
- ה-verify הוא **`.sh`** (לא ps1) להתאים לתקדים `audit_gates.sh`, **או** wrapper שמריץ `flutter test` של מפקדי-69/80 (שכבר ירוקים) ו-`exit 1` על-כשל. שם-הקובץ בתוכנית הוא ps1 אבל הסביבה bash — להחליט מפורשות ולתעד. (הערה: המשתמש על Windows אבל ה-CI/`post_build.sh` הוא bash.)
- `kUnifiedFinder` ON **כולל** את `kCardKeyboardFlag`-behaviour (בולע אותו); עדיפות מוגדרת: unified-מנצח. בדיקה ששני-הדגלים-יחד לא-מתנגשים.
- 'תכנון חיבור' ב-`kUnifiedFinderKeepPills` (allowlist-החריגים של 95) — **לא** מוסתר. 100 קורא את אותו קבוע-משותף.
- השער עם `kHopPairOverride` (80) + allowlist-≤6 (67/69) — מתחיל מ-baseline-הנוכחי (כמה offenders יש) ומצמצם, לא בינארי-מיידי. בדיקה שה-baseline נעול ומונע-רגרסיה.

**5. בדיקות:** `catalog_pills_byte_identity_test.dart` + `unified_cutover_test.dart`:
- `'9 pill branches: OFF byte-identical, ON → UnifiedFinderEntry'`: לכל 9-תוויות, flag-OFF → אותו-widget-כמו-היום; ON → `UnifiedFinderEntry` (finder-pills) / `LensSelectorRow` (category/tree/variants) / shortcut (fav/recent).
- `'default build has no flag (production dark)'`: בלי-seed → `kUnifiedFinder` OFF, קטלוג זהה.
- `'install-studio pill preserved when ON (95 keep-list)'`: ON → 'תכנון חיבור' עדיין מנתב ל-`InstallStudioScreen`.
- `'both flags on → no double-route'`: `kCardKeyboardFlag`+`kUnifiedFinder` → unified-מנצח, pill-יחיד.
- `verify_card_keyboard` (sh/wrapper): מריץ מפקדי-≤6/≤4, `exit 1` על-חריגה; בדיקה שהוא **כן** מפיל על offender-מוזרק ו**לא** מפיל על baseline-נקי.

**6. שיפור:** ה-cut-over צריך **flag-של-pill-בודד** (לא הכל-או-כלום): `kUnifiedFinder` מדליק את ה-`UnifiedFinderEntry`, אבל הסתרת-הכלים-הנבלעים תהיה **הדרגתית** (sub-flag/אחוז-rollout) כך שאפשר A/B: חלק-מהמשתמשים רואים את שניהם (מאתר-ישן+מאוחד) לפני הסתרה-מלאה. זה מקטין סיכון-קאט-אובר (אם המאוחד שובר משהו, הכלים-הישנים עדיין שם). מנצל את `ab_experiments` הקיים (`ab_experiments_test.dart`).

**7. ריאלי?:** **לא-אטומי — זה meta-שלב שבולע 8-יכולות** (דגל+routing+entry+lens+shortcuts+rails+הסתרה+שער-CI), תלוי ב-**7 שלבים** (50/60/80/89/91/95/99) שרובם-המכריע **טרם נבנו**. זה בעצם **אפוס**, לא שלב. חובה-לפצל: 100a=דגל+`UnifiedFinderEntry`+ניתוב-3-pill-מאתר (byte-identity), 100b=lens/shortcuts/rails-routing ל-6-ה-pill-הנותרים, 100c=הסתרת-כלים+keep-list, 100d=`verify` script + שער-CI-קשיח + baseline-allowlist. כל תת-שלב אטומי-ובדיק; כ-שלב-אחד הוא בלתי-ניתן-לאימות-נקודתי.

**8. וידוא-פיקס מלא:** `dart analyze` zero-new מול-baseline-נעול; **flag-OFF הוא כל-המשחק** — `catalog_pills_byte_identity_test` חייב להוכיח שב-OFF **כל** 9-הענפים זהים-בייטים, ובנוסף `catalog_regression_test`, `catalog_static_guard_test`, `wiring_test`, וכל-מבחני-הקטלוג חוזרים ירוקים; build-ברירת-מחדל ללא-דגל (פרודקשן-חשוך); `verify_card_keyboard` רץ ב-CI ומפיל-על-offender-מוזרק; כל-החבילות-של-P3..P10 ירוקות; להריץ עם retry-wrap-לכשלי-isolate + taskkill-dart-לפני (תקלת-השער); **לעולם-לא דחיפה** עד "תדחוף" (כלל-הזיכרון — commit מקומי בלבד).

**9. תכנון נוסף (שלי):** **בדיקת-נגישות-יציאה (escape hatch) כש-ON.** קאט-אובר שמסתיר 9-כלים מסוכן: אם המאתר-המאוחד שובר משהו בפרודקשן, המשתמש תקוע בלי-מאתר-ישן. צריך מסלול-חירום מובנה — long-press על pill-הבית/הגדרה-נסתרת שמחזירה את הכלים-הישנים גם כש-`kUnifiedFinder` ON. לבדוק שהיציאה-קיימת. בלי זה, באג-בודד-במאוחד = קטלוג-שבור-לכל-המשתמשים בלי-דרך-חזרה (פרט ל-hotfix-דחוף).

**10. תכנון נוסף (שלי):** **השער חייב לרוץ על אותו `kReachUniverse` (שלב 1) — אנטי-התכווצות-שקטה.** השער (verify) מודד ≤6/≤4 על יקום-מסוים; אם היקום מתכווץ-בשקט (מוצרים נושרים מ-`kDivePool`), השער "עובר" סתם כי יש פחות-לבדוק. ה-verify חייב **גם** לאמת ש-`kReachUniverse` בגודל-הצפוי (נטען-שווה, שלב 1/33) — אחרת ≤4/≤6 מובטחים על יקום-מצומק. לחבר את ספירת-היקום ל-exit-code של ה-verify (כשל אם היקום קטן מ-baseline). זה האינווריאנט שמונע "ניצחון-מזויף" של השער, מקביל ל"100% מנופח"→87% המתועד בזיכרון.

</div>
