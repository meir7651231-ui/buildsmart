# אפיון מלא — app_flutter (Full Functional Specification)

מסמך האפיון הפורמלי של האפליקציה, **מסך-אחר-מסך**, מבוסס לגמרי על הקוד המקורי
(R8 — אין המצאה; כל מחרוזת עברית מועתקת verbatim מהקוד). זה ה"אפיון" שאליו
מפנה `../SPEC.md` (שהוא המפה הקצרה); כאן נמצאים הפרטים המלאים.

## תבנית אחידה לכל מסך
כל קובץ אפיון בנוי לפי 10 הסעיפים:
1. **מזהה ומיקום** — קובץ, widget שורש, מיקום בניווט, providers מרכזיים.
2. **מטרה** — למה המסך קיים ומה המשתמש משיג.
3. **מבנה ופריסה** — מלמעלה למטה, כל אזור.
4. **טבלת אלמנטים** — אלמנט · סוג · תוכן/מקור · אינטראקציה ⇐ תוצאה · סטטוס.
5. **מצבים** — ריק / מלא / קצה / שגיאה.
6. **חוקים עסקיים ולוגיקה** — נוסחאות, ספים, ערכי ברירת מחדל אמיתיים, helpers טהורים.
7. **נתונים, מקורות ושמירה** — מקור הדאטה, SharedPreferences מול in-memory.
8. **תלות בהגדרות** — אילו הגדרות משפיעות ואיך.
9. **קריטריוני קבלה** — Given/When/Then ניתנים לאימות (מתואמים ל-`test/`).
10. **פערים ידועים** — מה 🚧/⛔ ולמה.

סטטוס: ✅ מחווט (אפקט אמיתי) · 🚧 בבנייה (placeholder) · ⛔ חסום (חסר server/data/telephony).

## הקבצים

| קובץ | מכסה | מקור בקוד |
|---|---|---|
| [`catalog.md`](catalog.md) | מסך **קטלוג** (tab 0) | `lib/screens/catalog_screen.dart` |
| [`chats.md`](chats.md) | מסך **שיחות** (tab 1) + שיחה פנימית + ארכיון | `lib/screens/chats_screen.dart` |
| [`notifications.md`](notifications.md) | מסך **התראות** (tab 2) | `lib/screens/notifications_screen.dart` |
| [`store.md`](store.md) | מסך **חנות** (tab 3) + סל + checkout | `lib/screens/store_screen.dart`, `lib/state/smart_cart.dart` |
| [`settings.md`](settings.md) | **4 מסכי הגדרות** (קטלוג/שיחות/התראות/חנות) | `lib/screens/*_settings_screen.dart` |
| [`shell-and-dials.md`](shell-and-dials.md) | **מעטפת** + AppBar + bottom-nav + 3 FAB dials | `lib/screens/home_shell.dart`, `*_dial_widget.dart` |
| [`catalog-secondary.md`](catalog-secondary.md) | מסכי **מוצר/מותג/ספקים** המשניים | `lib/screens/lipskey_*.dart`, `suppliers_screen.dart` |
| [`tools.md`](tools.md) | **כלים**: סטודיו התקנה · רגרסיה · ברקוד · מצלמה | `lib/screens/install_studio_screen.dart`, `regression_panel_screen.dart`, ... |

## מספרי-מפתח שאומתו מול הקוד (לעיון מהיר)
- **מע"מ**: 18% (קבוע בקוד, לא הגדרה). `cartVat` inclusive = `subtotal − round(subtotal/1.18)`, exclusive = `round(subtotal×0.18)`.
- **דמי משלוח**: express 120 · standard 45 · pickup 0.
- **`minOrderAmount`** ברירת מחדל 0 (חוסם רק כש-`>0`); **`largeOrderThreshold`** 5000.
- **אינדקס מילים**: `kIndexMinWordLen = 2` (`indexableWord`); וגייט נפרד `query.trim().length >= 2` לתוצאות חיות.
- **קיפול ריצת התראות**: `kNotifCollapseRunMin = 3`.
- **קטגוריות קטלוג**: 12 (לא 11 כפי שכתוב בהערה ישנה בקוד).
- **threads בשיחות**: 6 seeded; **התראות**: 10 seeded.
- **גרסה נוכחית**: label ב-`home_shell.dart` (מתעדכן בכל שינוי גלוי; נכון לכתיבה ~v4.71).

## הערות תיאום בין-מסכי (discrepancies שנמצאו מול `../SPEC.md`/`../WIRING.md`)
האפיון לעיל הוא המקור המדויק; כשמצאנו פער מול המסמכים הישנים, האמת היא הקוד:
- **`imageSize` / `compactMode`** — ✅ טופל: נצרכים כעת בכרטיסי המוצר של הקטלוג
  בשני המצבים — שורת רשימה (`_ProductRow`) וכרטיס רשת (`gridCardImageMetrics`).
  **`highContrast` / `textSize`** הם אפקט **app-wide** (theme + `textScaler` ב-`main`),
  לא ספציפיים למסך הקטלוג.
- **חיפושים אחרונים** — ✅ טופל (v3.78): נשמר ל-SharedPreferences (`bs.recent-searches.v1`, helper `addRecentSearch`). הגייט `searchHistoryEnabled` שולט בהקלטה.
- ~~**`catalogSortProvider` / `catalogFilterProvider`**~~ ✅ הוסרו; כלי הפאנל
  (⚙️ פילטרים / ↕️ מיון / ▦ קטלוג) חוּוטו לאפקט אמיתי. נותר קוד "מת-למחצה":
  `_LipskeySupplierCard`, `_FeaturedProductCard`, `_CatalogDrillSection`.
- **באנר snooze** — חי בפועל ב-`notif_settings_screen.dart`, לא במסך ההתראות.
- **dials**: רק ה-BS dial מופעל מ-UI (tap על ה-wordmark); `OpenDial.search`/`menu`
  מרונדרים אך לא נקבעים בשום מקום, ו-`bsMode` לא מומש.
- **checkout** במסך החנות הוא mock (toast עם `DateTime.now().second`, ללא יצירת הזמנה).
