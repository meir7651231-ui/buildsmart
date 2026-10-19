# מנוע בדיקת הקטלוג

נותנים לו קטלוג מוצרים, והוא מוצא את הטעויות לפני שהלקוח רואה אותן: שמות משובשים, מק"טים כפולים, קטגוריות שלא קיימות, מותגים לא מוכרים ותמונות שלא שייכות למוצר. הוא גם מתקן שמות בצורה בטוחה, ומשווה את השמות לקטלוג המקור של היצרן.

זה המנוע הרביעי (מאי 2026). הוא נבנה בשביל הקטלוג של BuildSmart והוצא לכאן כמו שהוא. ההיסטוריה הישנה שלו נמצאת תחת `scripts/catalog_qa.py` (`git log scripts/catalog_qa.py`). קובץ אחד של Python, בלי תלויות. רק הפקודות שקוראות PDF צריכות את `pymupdf`.

## הרצה על קטלוג של חנות

```bash
cd packages/catalog_qa/examples
python3 ../catalog_qa.py audit        # בדיקה מלאה. נכשל (exit 1) אם יש שגיאות חוסמות
python3 ../catalog_qa.py fix          # מה היה מתוקן (לא משנה כלום)
python3 ../catalog_qa.py fix --apply  # מתקן, שומר גיבוי .bak ויומן fix_log.csv
python3 ../catalog_qa.py export out.csv  # כל מוצר עם הבעיות שלו, לפתיחה ב-Excel
```

בתיקייה `examples/` יש קטלוג לדוגמה עם טעויות שנשתלו בו בכוונה. ההגדרות נמצאות ב-`catalog_qa.json`.

בלי קובץ הגדרות אפשר להעביר הכל בשורת הפקודה:

```bash
python3 catalog_qa.py audit --catalog products.csv --categories categories.txt --brands "חמת,פלסון"
```

## הקטלוג

- **CSV** עם שורת כותרת: `sku, name, category, brand, image`. אפשר להוסיף גם `nameEn`, `page` ו-`color`.
- **JSON**: רשימה של מוצרים, או `{"products": [...]}`.
- **שמות עמודות אחרים**, למשל `מק"ט`: מגדירים `"columns": {"sku": "מק\"ט", "name": "שם"}`.
- **תמונה:** קובץ (`1001.jpg`) או כן/לא (`Y`, `true`). כשיש קובץ, `imgmatch` בודק ששם הקובץ מתחיל במק"ט.

## קובץ ההגדרות

```json
{
  "catalog": "store_catalog.csv",
  "categories": "categories.txt",
  "brands": ["חמת", "פלסון"],
  "truth": "source_truth.json",
  "images_dir": "images",
  "out_dir": "."
}
```

- הנתיבים יחסיים לקובץ ההגדרות.
- `categories` הוא קובץ עם קטגוריה בכל שורה, או קובץ JSON.
- **בלי `categories` או בלי `brands`, החוק המתאים מדולג.** אין מול מה לבדוק.
- המנוע מחפש `catalog_qa.json` בתיקייה הנוכחית, או מקבל `--config <file>`.

## החוקים

| חומרה | חוקים |
|---|---|
| ‏ERROR (חוסם) | שם ריק, שם משובש (`\|`, "כמות באריזה"), ספרה דבוקה לאות, סוגריים לא סגורים, מק"ט חסר או כפול, קטגוריה חסרה או לא קיימת |
| ‏WARN (לבדיקה) | מותג לא מוכר, רווחים כפולים, ברז בקטגוריית ניקוז, שם זהה בלי שום הבדל בגוון או במידה |
| ‏INFO (השלמה) | אין מידה בשם, אין תמונה, שם זהה שמובחן בגוון או במידה |

`selftest` מוכיח שכל חוק חוסם אכן תופס טעות.

## כל הפקודות

`lookup <sku...>` מחזיר JSON עם המוצר וההפרות שלו. בו משתמשים מנועים אחרים, למשל "המחסנאי" בחדר הישיבות.

`audit [--json]` · `selftest` · `fix [--apply] [--rule=packaging|gershayim|stuck|spaces]` · `export <csv>` · `truthcheck` · `truthapply [--apply]` · `schema` · `coverage` · `images` · `imgmatch` · `report` · `diff <old> <new>` · `crossdedup`. עם PDF: `crosscheck` · `suspects` · `pdfmap` · `verify`.

## בדיקות

```bash
python3 packages/catalog_qa/tests/test_engine.py   # 14 בדיקות, בלי קבצי BuildSmart
```

## ב-BuildSmart

- `python3 scripts/catalog_qa.py <cmd>` עובד כמו קודם. הוא מריץ את המנוע עם `scripts/catalog_qa.buildsmart.json`, ו-CI (`catalog-qa.yml`) לא השתנה.
- הקטלוג שם הוא קובץ ה-Dart של האפליקציה. אם מנוע ההתאמות כבר הוצא ל-`packages/compat_engine`, הקובץ נקרא משם. אחרת הוא נקרא מ-`app_flutter`.

## מה השתנה בהוצאה

- הנתיבים ורשימת המותגים עברו מהקוד לקובץ הגדרות.
- נוספה קריאה של CSV ו-JSON, וכתיבה חזרה אליהם ב-`fix --apply` וב-`truthapply --apply`.
- תוקן: התיקון האוטומטי מחק מידה שהופיעה באותו קטע עם "כמות באריזה". לדוגמה, "מצמד \| 20 כמות באריזה DN50" הפך ל"מצמד" במקום "מצמד · DN50".
- `audit` נכשל (exit 1) כשיש שגיאות חוסמות. עד עכשיו רק `audit --json` עשה את זה.
- על הקטלוג של BuildSmart, כל הפקודות מוציאות בדיוק את אותו פלט כמו לפני ההוצאה.
