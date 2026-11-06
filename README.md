<p align="left"><a href="README.en.md">English</a> · <b>עברית</b> &nbsp;|&nbsp; ▶️ <a href="https://meir7651231-ui.github.io/buildsmart/flutter/"><b>נסו עכשיו באתר החי</b></a> · <a href="assets/demo.gif">הדגמה (GIF)</a></p>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/hero.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/hero-light.svg">
  <img src="assets/hero-light.svg" alt="BuildSmart — רכש ומשימות לאתר הבנייה, עם קטלוג שיודע מה מתחבר למה. לצד הטקסט: שני מסכים אמיתיים של האפליקציה" width="100%">
</picture>

<p align="center">
<a href="https://github.com/meir7651231-ui/buildsmart/actions/workflows/deploy.yml"><img src="https://github.com/meir7651231-ui/buildsmart/actions/workflows/deploy.yml/badge.svg?branch=main" alt="Deploy to GitHub Pages"></a>
<a href="https://github.com/meir7651231-ui/buildsmart/actions/workflows/protocol-enforce.yml"><img src="https://github.com/meir7651231-ui/buildsmart/actions/workflows/protocol-enforce.yml/badge.svg?branch=main" alt="Protocol Enforcement (flutter analyze + flutter test)"></a>
<a href="https://github.com/meir7651231-ui/buildsmart/actions/workflows/catalog-qa.yml"><img src="https://github.com/meir7651231-ui/buildsmart/actions/workflows/catalog-qa.yml/badge.svg" alt="catalog-qa"></a>
<img src="https://img.shields.io/badge/Flutter-3.44-F26B1D?labelColor=1F1A13" alt="Flutter 3.44">
<img src="https://img.shields.io/badge/platforms-iOS%20·%20Android%20·%20Web-F26B1D?labelColor=1F1A13" alt="iOS · Android · Web">
</p>

<div dir="rtl">

<h3 align="center">אפליקציה אחת לרכש, להזמנות ולמשימות באתר — עם קטלוג אינסטלציה שיודע מה מתחבר למה.</h3>

<p align="center"><a href="#הבעיה"><b>הבעיה</b></a> · <a href="#התחלה-מהירה">התחלה מהירה</a> · <a href="#איך-זה-עובד">איך זה עובד</a> · <a href="#מה-יש-בפנים">מה יש בפנים</a> · <a href="#מתי-לבחור-בנו--ומתי-לא">מתי לבחור בנו</a> · <a href="#במספרים">במספרים</a> · <a href="#הרצה-מקומית">הרצה מקומית</a> · <a href="#סטטוס-וגרסאות">סטטוס</a> · <a href="#שאלות-נפוצות">שאלות</a> · <a href="#מסמכים">מסמכים</a></p>

---

## הבעיה

באתר בנייה, הזמנת חומרים עוברת בטלפון, בוואטסאפ ובקטלוגים של ספקים עם אלפי פריטים כמעט זהים.
מידה לא נכונה או אביזר שלא מתחבר לצנרת שכבר הונחה — ומישהו נוסע שוב לחנות, והעבודה מחכה.

**BuildSmart מרכזת את זה במקום אחד:** קטלוג שנבדק אוטומטית, מנוע שמחשב אילו אביזרים מתחברים זה לזה,
סל והזמנות, שיחות, ומסכים נפרדים לכל תפקיד — קבלן, מנהל, חנות ספק, שליח ועובד.

<p align="center"><img src="assets/beforeafter.svg" alt="בלי BuildSmart: הזמנות בטלפון, מידות מהזיכרון, אביזר שלא מתחבר. עם BuildSmart: קטלוג אחד שנבדק, וריאנט לפי צורה ומידה, המנוע מראה מה מתחבר, הזמנה משויכת לפרויקט" width="100%"></p>

## התחלה מהירה

| דרך | זמן (נמדד 6.11.2026) | מה עושים |
|---|---|---|
| **באתר החי** | 0 — בלי התקנה | פותחים את [התצוגה המקדימה של Flutter](https://meir7651231-ui.github.io/buildsmart/flutter/) ולוחצים **"המשך ללא רישום (דוגמה)"** |
| **מ-clone נקי: בדיקת הקטלוג** | כ-4 שניות (clone ‏3.7 ש׳ + בדיקה 0.1 ש׳) | שלוש הפקודות למטה. צריך רק git ו-Python 3 |
| **מ-clone נקי: האפליקציה המלאה** | כ-86 שניות (pub get ‏2.4 ש׳ + build ‏80.3 ש׳, עם מטמון pub חם) | ראו [הרצה מקומית](#הרצה-מקומית). צריך Flutter 3.44 |

<div dir="ltr">

```bash
git clone --depth 1 https://github.com/meir7651231-ui/buildsmart.git && cd buildsmart
python3 scripts/catalog_qa.py audit      # ✅ אפס שגיאות חוסמות
python3 scripts/catalog_qa.py selftest   # ✅ כל החוקים עובדים
```

</div>

<p align="center"><img src="assets/demo.gif" alt="הדגמה: מסך הבית, קטלוג, אביזרים עם וריאנטים, הוספה לסל" width="300"></p>

## איך זה עובד

<p align="center"><img src="assets/how.svg" alt="קטלוג ספקים ← שער איכות (catalog_qa.py) ← מנוע תאימות ← האפליקציה, מעל צד-שרת Firebase ומתווך-קצה" width="100%"></p>

1. **קטלוג ספקים** — נתוני המוצרים (מידות, קטגוריות, תמונות) יושבים בקוד, ב-`app_flutter/lib/data/`.
2. **שער איכות** — `scripts/catalog_qa.py` בודק את הקטלוג בכל שינוי בנתונים (workflow‏ `catalog-qa`). שגיאה חוסמת = ה-CI אדום.
3. **מנוע תאימות** — גרף מפרטים מאומת, חישוב מסלול חיבור ורשימת חומרים (BOM) — `app_flutter/lib/logic/install_engine.dart`.
4. **האפליקציה** — Flutter, קוד אחד ל-iOS, ל-Android ולווב. צד-השרת הוא Firebase (Firestore, Auth, Cloud Functions וחוקי אבטחה), ולרשתות מסוננות יש מתווך-קצה (Cloudflare Worker) ב-`edge-proxy/`.

הפירוט המלא, כולל ההחלטות המרכזיות: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## מה יש בפנים

<p align="center"><img src="assets/capabilities.svg" alt="קטלוג מאומת · מנוע תאימות · סטודיו התקנה · סל והזמנות · שיחות · 5 תפקידים · ברקוד ומצלמה · רשת מסוננת · קוד אחד" width="100%"></p>

**צילומי מסך** — אמיתיים, מ-`flutter build web` במצב דמו (נתוני דוגמה, בלי התחברות). לחיצה פותחת בגודל מלא; הסבר לכל מסך ב[מדריך](docs/GUIDE.he.md).

<table>
<tr>
<td align="center"><a href="docs/screenshots/01-welcome.png"><img src="docs/screenshots/thumbs/01-welcome.png" alt="מסך הפתיחה עם כפתור מצב הדמו" width="150"></a><br><sub>פתיחה</sub></td>
<td align="center"><a href="docs/screenshots/03-home.png"><img src="docs/screenshots/thumbs/03-home.png" alt="מסך הבית: מחלקות, עץ חכם ומסלול עבודה" width="150"></a><br><sub>בית</sub></td>
<td align="center"><a href="docs/screenshots/04-catalog.png"><img src="docs/screenshots/thumbs/04-catalog.png" alt="קטלוג האינסטלציה לפי קטגוריות" width="150"></a><br><sub>קטלוג</sub></td>
<td align="center"><a href="docs/screenshots/05-variants.png"><img src="docs/screenshots/thumbs/05-variants.png" alt="אביזרים עם בחירת וריאנט: צורה, מידה, תבריג" width="150"></a><br><sub>וריאנטים</sub></td>
<td align="center"><a href="docs/screenshots/06-cart.png"><img src="docs/screenshots/thumbs/06-cart.png" alt="הסל: שיוך לפרויקט ואפשרויות משלוח" width="150"></a><br><sub>סל</sub></td>
</tr>
<tr>
<td align="center"><a href="docs/screenshots/07-notifications.png"><img src="docs/screenshots/thumbs/07-notifications.png" alt="התראות: הזמנות, משלוחים, בטיחות ותקציב" width="150"></a><br><sub>התראות</sub></td>
<td align="center"><a href="docs/screenshots/08-chats.png"><img src="docs/screenshots/thumbs/08-chats.png" alt="שיחות עם ספק, שליח, תמיכה ועובד" width="150"></a><br><sub>שיחות</sub></td>
<td align="center"><a href="docs/screenshots/09-orders-hub.png"><img src="docs/screenshots/thumbs/09-orders-hub.png" alt="מרכז הרכש: הסל, ההזמנות, מועדפים וכספים" width="150"></a><br><sub>רכש</sub></td>
<td align="center"><a href="docs/screenshots/02-roles.png"><img src="docs/screenshots/thumbs/02-roles.png" alt="בחירת תפקיד: קבלן, מנהל, חנות ספק, שליח, עובד" width="150"></a><br><sub>תפקידים</sub></td>
<td></td>
</tr>
</table>

**מפת הריפו:**

| תיקייה / קובץ | מה זה | מצב |
|---|---|---|
| [`app_flutter/`](app_flutter/) | האפליקציה — Flutter + Riverpod, ‏iOS · Android · Web, עברית מימין לשמאל | 🟢 פיתוח פעיל |
| [`app/`](app/) | הגרסה הקודמת — Preact + TypeScript + Vite (PWA) | 🟡 חיה ב-GitHub Pages, תיקוני באגים בלבד |
| [`functions/`](functions/) | Firebase Cloud Functions ‏(TypeScript) — הזמנות, אשראי, התראות ועוד | צד-שרת |
| [`firestore.rules`](firestore.rules) · [`rules_test/`](rules_test/) | חוקי האבטחה של מסד הנתונים + בדיקות שלהם | צד-שרת |
| [`edge-proxy/`](edge-proxy/) | מתווך-קצה (Cloudflare Worker) — כל התעבורה דרך דומיין אחד | צד-שרת |
| [`scripts/`](scripts/) | שער האיכות של הקטלוג, ייבוא קטלוג, סקריפטי build וגרסה | כלים |
| [`docs/`](docs/) | ארכיטקטורה, מדריך, צילומי מסך, פרוטוקול הקטלוג | מסמכים |
| [`orchestrator/`](orchestrator/) · [`perfect-agent/`](perfect-agent/) · [`tools/atom/`](tools/atom/) · [`atom-engine/`](atom-engine/) | הכלים והנהלים של סוכני הפיתוח שבונים את הפרויקט | כלי פיתוח |
| [`index.html`](index.html) | אב-הטיפוס המקורי (כ-22 אלף שורות) — מקור הטקסטים בעברית | ארכיון / מקור |

## מה זה לא עושה

- **עדיין לא בחנויות.** אין עדיין גרסה ב-App Store או ב-Google Play — ההכנה להשקה בעבודה.
- **לא סולק תשלומים.** אין באפליקציה חיבור לסליקת אשראי; הסל מחשב סכומים ואפשרויות משלוח.
- **לא מציג מחירון.** בקטלוג המחיר מופיע כ"מחיר לפי ספק".
- **שער האיכות מכסה קטלוג אחד.** `catalog_qa.py` בודק את קטלוג ליפסקי (`lipskey_catalog.dart`, ‏923 מוצרים) — לא את שאר קטלוגי המותגים.
- **לא מחליף איש מקצוע.** המנוע מציע חיבורים לפי מפרטי הקטלוג; ההחלטה בשטח נשארת של המתקין.
- **חלק מהיכולות כבויות כברירת מחדל.** הסטודיו ללא-קוד רדום עד שמפעילים אותו, ומצב הרשת המסוננת נדלק רק כשהמשתמש בוחר בו.

## מתי לבחור בנו — ומתי לא

| מתאים אם… | פחות מתאים אם… |
|---|---|
| עובדים עם **אינסטלציה** — הקטלוג המאומת הוא של ליפסקי ו-AQUATEC (923 מוצרים, 68 קטגוריות) | צריך קטלוג של תחום אחר — היום הקטלוג המאומת הוא אינסטלציה |
| הצוות **עובד בעברית** — הממשק בעברית מימין לשמאל | צריך ממשק באנגלית או בערבית — v1 בעברית בלבד |
| חלק מהמשתמשים על **אינטרנט מסונן** (נטפרי, רימון) — יש מצב שמעביר את התעבורה דרך דומיין אחד | צריך אפליקציה בחנויות כבר היום — ההשקה עדיין בהכנה |
| רוצים **הזמנות משויכות לפרויקט** ובחירת משלוח (4 שעות · יום-יומיים · איסוף עצמי) | צריך סליקת אשראי בתוך האפליקציה — אין |
| רוצים **ווב, אנדרואיד ואייפון מקוד אחד** | צריך מחירון קבוע בקטלוג — המחירים "לפי ספק" |

## במספרים

<p align="center"><img src="assets/numbers.svg" alt="923 מוצרים בקטלוג המאומת · 6,034 בדיקות Flutter עוברות · 0 שגיאות analyze · 0 שגיאות חוסמות בקטלוג" width="100%"></p>

## הרצה מקומית

<p align="center"><img src="assets/install.svg" alt="הרצה מקומית: בדיקת קטלוג, יצירת גרסה, flutter pub get, flutter build web, הגשת build/web" width="100%"></p>

כל הפקודות כאן הורצו ועברו (6.11.2026). צריך Python 3, ‏Node 20 ומעלה (ה-CI משתמש ב-20) ו-Flutter 3.44 (שני workflows עדיין על 3.29.3).

**שער האיכות של הקטלוג** (Python בלבד, בלי התקנות):

<div dir="ltr">

```bash
python3 scripts/catalog_qa.py audit       # בדיקה מלאה — "אפס שגיאות חוסמות"
python3 scripts/catalog_qa.py selftest    # מוכיח שכל חוק באמת יורה
python3 scripts/test_catalog_qa.py        # בדיקות היחידה של המנוע — 12/12
python3 scripts/catalog_qa.py truthcheck  # השוואה מול source_truth.json (דוח)
python3 scripts/catalog_qa.py coverage    # כיסוי תמונה/מידה לפי מותג (דוח)
python3 scripts/catalog_qa.py report      # מדדי איכות: 923 מוצרים · 68 קטגוריות · 0 שגיאות
```

</div>

**האפליקציה (Flutter):**

<div dir="ltr">

```bash
bash scripts/gen_version.sh               # חובה לפני build — מייצר את lib/version.g.dart
cd app_flutter
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test --concurrency=4              # הסוויטה המלאה — 6,034 בדיקות
flutter build web --release               # התוצר ב-build/web/
cd build/web && python3 -m http.server 8765   # פתחו http://localhost:8765 → "המשך ללא רישום (דוגמה)"
```

</div>

**הגרסה הקודמת (Preact):**

<div dir="ltr">

```bash
cd app
npm ci
npm run build
```

</div>

## סטטוס וגרסאות

- **גרסת האפליקציה:** ‏`1.5.2+14` (לפי `app_flutter/pubspec.yaml`). תווית הבנייה שמופיעה באפליקציה: `v7.02` (מ-`app_flutter/knowledge/STATUS.md`, דרך `scripts/gen_version.sh`).
- **תגיות שחרור:** עדיין אין. יש [הצעת SemVer](CHANGELOG.md#versioning-proposal-semver--הצעת-גרסאות) ב-CHANGELOG.
- **חי עכשיו:** [GitHub Pages](https://meir7651231-ui.github.io/buildsmart/) (גרסת Preact) ו-[תצוגה מקדימה של Flutter](https://meir7651231-ui.github.io/buildsmart/flutter/).
- **CI על `main`:** ‏Deploy to GitHub Pages ✅ · Protocol Enforcement ✅ · Atom Tools ❌ (כלי סוכני-הפיתוח, נפרד מה-CI הראשי — [ריצה](https://github.com/meir7651231-ui/buildsmart/actions/runs/32666555496)).
- **בעבודה:** הכנה להשקה בחנויות. פיצ'רים חדשים מוקפאים עד ההשקה — ראו [`ROADMAP.md`](ROADMAP.md).

## שאלות נפוצות

<details><summary><b>למה יש שתי אפליקציות בריפו?</b></summary>

`app/` (Preact) היא הגרסה שחיה היום בווב. `app_flutter/` היא הגרסה החדשה, עם קוד אחד גם לאייפון ולאנדרואיד.
כשגרסת Flutter תתייצב — עוברים אליה, ו-`app/` נשארת לתיקוני באגים בלבד עד אז.
</details>

<details><summary><b>מה זה "מה מתחבר למה"?</b></summary>

לאביזרים בקטלוג יש מפרט (למשל קוטר וסוג חיבור). המנוע בונה מהם גרף ומחשב אילו פריטים מתחברים,
איזה מסלול חיבור אפשרי, ומה צריך להזמין כדי לסגור אותו.
</details>

<details><summary><b>אפשר לנסות בלי חשבון?</b></summary>

כן. במסך הפתיחה יש "המשך ללא רישום (דוגמה)" — מצב דמו עם נתוני דוגמה. כך צולמו המסכים וההדגמה כאן.
תפקידים כמו חנות ספק דורשים חשבון.
</details>

<details><summary><b>למה צריך מתווך-קצה?</b></summary>

ברשתות מסוננות (כמו נטפרי או רימון) שירותי Google חסומים לפעמים. המתווך מעביר את התעבורה דרך דומיין אחד של הפרויקט. זה מופעל רק במצב "אינטרנט מסונן".
</details>

<details><summary><b>איך יודעים שהקטלוג נקי?</b></summary>

`catalog_qa.py audit` רץ ב-CI על כל שינוי בנתוני הקטלוג, ו-`selftest` מוכיח שכל חוק בודק באמת (חוק שלא יורה — נכשל).
</details>

<details><summary><b>איך אפשר לעזור?</b></summary>

ראו [`CONTRIBUTING.md`](CONTRIBUTING.md). באגים — דרך [issue](https://github.com/meir7651231-ui/buildsmart/issues/new/choose). בעיות אבטחה — רק לפי [`SECURITY.md`](SECURITY.md).
</details>

## מסמכים

| מסמך | מה יש בו |
|---|---|
| [`docs/GUIDE.he.md`](docs/GUIDE.he.md) | מדריך שימוש — 8 משימות עם צילומי מסך |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | איך המערכת בנויה וההחלטות המרכזיות |
| [`docs/CATALOG_PROTOCOL.md`](docs/CATALOG_PROTOCOL.md) · [`scripts/CATALOG_ROADMAP.md`](scripts/CATALOG_ROADMAP.md) | פרוטוקול הידע של הקטלוג ומפת הדרכים שלו |
| [`ROADMAP.md`](ROADMAP.md) | מה עכשיו ומה הלאה |
| [`CHANGELOG.md`](CHANGELOG.md) | מה השתנה, לפי אבני-דרך |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | איך תורמים — זרימה ובדיקות |
| [`SECURITY.md`](SECURITY.md) | דיווח על בעיית אבטחה |

## אבטחה ורישיון

- **דיווח על בעיית אבטחה:** ראו [`SECURITY.md`](SECURITY.md). בבקשה לא לפתוח על זה issue ציבורי.
- **רישיון:** לריפו אין כרגע קובץ רישיון.

</div>
