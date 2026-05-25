# BuildSmart

![catalog-qa](https://github.com/meir7651231-ui/buildsmart/actions/workflows/catalog-qa.yml/badge.svg)

אפליקציית קטלוג אינסטלציה (Flutter) עם מנוע תאימות "מה מתחבר למה".

## QA הקטלוג
מנוע אכיפה רב-פעמי מבטיח אפס שגיאות בנתונים (גם ב-80,000 מוצרים):

```bash
python3 scripts/catalog_qa.py audit       # בדיקה תחבירית מלאה
python3 scripts/catalog_qa.py selftest    # מוכיח שכל חוק יורה
python3 scripts/catalog_qa.py truthcheck  # אימות מול source_truth.json
python3 scripts/catalog_qa.py coverage    # כיסוי תמונה/גודל לפי מותג
python3 scripts/catalog_qa.py report      # KPI איכות
```

- פרוטוקול ידע: [`CATALOG_PROTOCOL.md`](CATALOG_PROTOCOL.md)
- מפת דרכים (100 צעדים): [`scripts/CATALOG_ROADMAP.md`](scripts/CATALOG_ROADMAP.md)
- בדיקת רגרסיה באפליקציה: BS → 👔 מנהל → 🛠️ ניהול → 🔬 בדיקות רגרסיה
