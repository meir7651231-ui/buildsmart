# מנוע ההתאמות: מה מתחבר למה

המנוע של BuildSmart שעונה על השאלה "איזה מוצר אינסטלציה מתחבר לאיזה". הוא בודק אם שני מוצרים מתחברים, מוצא את המסלול הקצר מצנרת לאביזר, ובונה רשימת התקנה מלאה עם ערכת חלקים.

זה המנוע השלישי (אוקטובר 2026). הקוד לא נכתב מחדש. הוא הוצא מהאפליקציה (`app_flutter/lib/`) כמו שהוא, וכל קובץ הועבר עם ההיסטוריה שלו (`git mv`). זו חבילת Dart נקייה בלי Flutter, ולכן אפשר להריץ אותה גם בשרת, בכלי שורת פקודה או באפליקציה אחרת.

## הרצה

```bash
cd packages/compat_engine
dart pub get
dart test        # 669 בדיקות
dart analyze
```

## מה יש בפנים

| תיקייה | מה יש בה |
|---|---|
| `lib/logic/install_engine.dart` | הלב: `canConnect`, `connectionFailReason`, `compatibleWith`, `findShortestPath`, `findAlternativePaths`, `buildInstallation`, `buildTreeInstallation`, `lineComplianceChecklist` |
| `lib/logic/install_kit.dart` | ערכת חלקים מומלצת למוצר או לשרשרת: `recommendedKitForProduct`, `recommendedKitFor` |
| `lib/domain/` | כללי חיבור (`connection_schema`) ומפענח שמחליט לפיהם (`connection_resolver`) |
| `lib/data/` | הקטלוגים (ליפסקי, פולירול, היוליוט), מפרטים מאומתים, חיבורים מאומתים, משפחות וריאנטים ועץ מוצרים חכם |
| `lib/data/related_info.dart` | גשר ממק"ט למוצר (`catalogProductForSku`) ומידע הנדסי |
| `lib/state/app_profile.dart`, `lib/config/app_brand.dart` | פרופיל ומותג, נקבעים בזמן בנייה (`--dart-define`) |

דוגמה:

```dart
import 'package:compat_engine/logic/install_engine.dart';

final path = findShortestPath(from, to, tempC: 60);
if (path == null) print(connectionFailReason(from, to));
```

## איך האפליקציה משתמשת בזה

- `app_flutter/pubspec.yaml` תלוי בחבילה (`path: ../packages/compat_engine`).
- בנתיבים הישנים ב-`app_flutter/lib/` נשארו קבצים קטנים שמייצאים את החבילה, כך שכל `import 'package:buildsmart/...'` ממשיך לעבוד בלי שינוי.
- מצב המסך של מחשבון ההתאמות (ספקי Riverpod) נשאר באפליקציה, ב-`app_flutter/lib/logic/install_engine.dart`. המנוע עצמו לא מחזיק מצב.

## מה השתנה בהוצאה

- `package:flutter/foundation.dart` הוחלף ב-`package:meta` ובקובץ `lib/src/equality.dart` (`listEquals`, `mapEquals`, באותה התנהגות).
- 83 קבצי בדיקה עברו לכאן, עם `package:test` במקום `flutter_test`.
- בדיקות שסורקות את כל האפליקציה נשארו ב-`app_flutter/test/`, ועכשיו הן סורקות גם את החבילה.
- הסקריפטים (`scripts/catalog_qa.py`, `app_flutter/scripts/*.py`) מצביעים על המיקום החדש של הקטלוג.
- ב-CI נוסף `compat-engine.yml`, ובניית האפליקציה רצה גם כשהחבילה משתנה.
