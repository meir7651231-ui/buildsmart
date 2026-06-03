# Visual verification log — app_flutter

תיעוד אימות-ויזואלי לשינויי UI (גייט 107, לקח #2). screenshot/בדיקת-widget לכל שינוי.

---

## v5.92 — Version chrome decoupled (לקח #72, P0)
**שינוי:** תווית-הגרסה ב-AppBar (`home_shell.dart`) עברה ממחרוזת-קשיחה
(`v5.91 · 1.6.48 · 🚚 בנצי #4 — ...`) ל-`kVersionLabel` בלבד מ-`version.g.dart`.
- **לפני:** נקודה ירוקה + טקסט ירוק 10px עם changelog חופשי, 2 שורות ellipsis.
- **אחרי:** `kVersionLabel` בלבד (`v5.92`), אפור-secondary (`BsTokens.mutedLight`),
  שורה אחת, `Key('version_chrome')`. אין נקודה-ירוקה (שמורה ל-`_PulsingStatus`).

**אימות:**
- ✅ `flutter analyze lib/screens/home_shell.dart` — 0 errors (3 info pre-existing).
- ✅ `test/version_g_test.dart` — contract locked (kReleaseNote='' תמיד, label vX.Y).
- ✅ `flutter build web --release` — קומפילציה end-to-end.
- ⏳ **visual sign-off סופי (feel) — ליטוש**, לפי קונצנזוס (סוכן-UI הוא בעל ה-feel).
  הצורה דטרמיניסטית (Text widget פשוט); CanvasKit screenshots לא-אמינים →
  נשענים על widget-test, כהמלצת ליטוש/מקבץ.

---

## v5.93 — תפריט 4 טאבים + מיזוג עדכונים (בנצי #3)
**שינוי:** `home_shell` (IndexedStack + `_BottomNav`) + `updates_screen.dart` חדש +
`catalog_screen` (default section 'בית'→'הכל'). תפריט תחתון: 🏠 בית · ▦ מחלקות ·
🔔 עדכונים · 🛒 חנות. "עדכונים" = מיזוג התראות+שיחות עם מתג עליון.

**אימות ויזואלי (5 screenshots, נסקרו ונשלחו למשתמש לאישור):**
- ✅ טאב בית — חלון "הכל" של הקטלוג (overview קטגוריות, 'הכל' chip פעיל).
- ✅ טאב מחלקות — גריד 9 המחלקות (ללא שינוי, מיקום חדש).
- ✅ טאב עדכונים → התראות — המתג העליון [🔔 התראות · 💬 שיחות], מסך ההתראות מתחת.
- ✅ טאב עדכונים → שיחות — מתג מחליף ל-inbox השיחות (state נשמר ב-IndexedStack).
- ✅ טאב חנות — StoreScreen (ללא שינוי, מיקום חדש).
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1084 ✅ · `build web` — ✓.
- bottom-nav עקבי בכל הטאבים; הסל = FAB צף (מוסתר ב-חנות).

---

## v5.94 — "לאן לשלוח" חלונית חד-פעמית בבחירת מוצר ראשונה (בנצי #4, תיקון)
**שינוי:** `store_screen` (הוסר `_ShipToRow` מה-checkout; `openShipToSheet` public +
`shipToPromptedProvider`) + `home_shell` (listener על `smartCartProvider`) + `main`.
החלונית עברה מ-checkout ל-auto-popup חד-פעמי בהוספת המוצר הראשון.

**אימות ויזואלי (screenshot, נסקר):**
- ✅ הוספת מוצר ראשון (cart 0→1) → חלונית "לאן לשלוח?" קופצת אוטומטית מלמטה,
  לא-מחייבת ("לא חובה — אפשר לאשר גם בלי כתובת"), שדה כתובת + דלג/שמירה.
- ✅ ה-checkout sheet כבר לא מכיל את שורת ה-ship-to.
- ✅ `flutter analyze` lib — 0 errors · `flutter test` — 1086 ✅ · `build web` — ✓.
- חד-פעמיות: `shipToPromptedProvider` נשמר (prefs) → לא קופץ שוב.

---

## v5.95 — Huliot chip picker (בורר) opens (T8 visual verify)
**שינוי:** התיקון של `_cycleHierarchy` + `findHierarchySiblings` שמפעיל את
הבורר הפאסטי למוצרי חוליות (היה מת — אחים ריקים).
- **אימות ויזואלי:** רונדר כרטיס `ברך 45° 32` (SKU 70033460) ב-widget-test
  → הקלקה על chip הצורה (`45°`) → צילום PNG.
  - **לפני התיקון:** הקלקה לא פתחה כלום (שורת-בורר ריקה).
  - **אחרי:** נפתחה שורת-בורר מתחת לכרטיס עם **6 pills של אחים** (45°/90° +
    מידות 32/40/50/63). screenshot: `knowledge/visual/v5.93_huliot_picker_open.png`.
  - הטקסט מרובע (אין פונט עברי ב-test env) אבל המבנה ודאי: pill כתום (גודל)
    + אפור (צורה) בכרטיס, שורת-בורר עם 6 pills מתחתיו.
- **אימות לוגי:** `huliot_picker_test` (4) — shape→{45°,90°}, size→{32,40,50,63},
  Huliot-only, Polyroll regression-guard. mutation_verify על brand-gate (red→green).
