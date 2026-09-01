> ♻️ **מנוע-נקי (הכרעת-בעלים "אפס-דאטה במנוע"):** 12 מילוני-הסיווג חולצו לדאטה מוזרקת. המנוע=מנגנון-בלבד; הדאטה ב-`dart-data/chip-vocab.dart`. התנהגות זהה-ביט כשמזריקים את מילוני-המקור.

# חוזה · `parseChips`

## תפקיד
מפרק שם-מוצר בעברית (`nameHe`) ל-`ChipPath` לפי היררכיית-§21: שם-סוג מוביל
(`type`) + חמש רמות מסודרות (חיבור→צורה→תכונה→תבריג→מידה) + `leftover` לטוקנים
שלא סווגו. **מנוע-פירוק דאטה-מונחה** — 12 מילוני-הסיווג מוזרקים כשקעים, אינם צרובים.

מוצא: `buildsmart/app_flutter/lib/data/chip_hierarchy.dart:196-315`
(`parseChips`; טיפוס-הפלט `ChipPath` :154-194; חוק-2 — verbatim, לא-משופר).

## חתימה
```dart
ChipPath parseChips(String nameHe, {
  required Set<String> chipTypes,        // ⇔ kChipTypes
  required Set<String> compoundTypes,    // ⇔ kChipCompoundTypes
  required Set<String> level1Connection, // ⇔ kChipLevel1Connection
  required Set<String> level2Shape,      // ⇔ kChipLevel2Shape
  required Set<String> level3Feature,    // ⇔ kChipLevel3Feature
  required Set<String> level4Thread,     // ⇔ kChipLevel4Thread
  required Set<String> chipMaterial,     // ⇔ kChipMaterial
  required Set<String> chipUnits,        // ⇔ kChipUnits
  required Set<String> l1Compounds,      // ⇔ kChipL1Compounds
  required Set<String> l2Compounds,      // ⇔ kChipL2Compounds
  required Set<String> l3Compounds,      // ⇔ kChipL3Compounds
  required Set<String> l4Compounds,      // ⇔ kChipL4Compounds
});
class ChipPath {
  final String? type;
  final List<String> level1, level2, level3, level4, leftover;
  final String? level5;
  List<String> get path;            // [...l1, ...l2, ...l3, ...l4, if l5!=null l5]
  String levelLabelOf(int pathIndex); // §21.C — תווית-רמה לצ'יפ ב-path
}
```

## שקעים (12 מילוני-סיווג מוזרקים) + מקור-הדאטה
כל 12 המילונים חיים ב-`dart-data/chip-vocab.dart` (const, verbatim מ-chip_hierarchy.dart:7-148,317-399),
מוזרקים ע"י קופסת-bs-pipe. **נשמר במנוע (מנגנון/טיפוס, לא-דאטה):** `ChipPath` = טיפוס-פלט
טהור (dart:core בלבד) + `levelLabelOf` — תוויות-הרמה (חיבור/צורה/תכונה/תבריג/מידה) הן
שמות-מבניים הצמודים 1:1 לחמש רמות-הטיפוס, לא קטלוג מתחלף.

## התנהגות (מקריאת-הקוד)
- **טוקניזציה**: פיצול על רווחים; מדלגים טוקנים ריקים ומפרידי-נוי `-`/`—`/`/`.
- **חומר**: טוקן ב-`chipMaterial` (PPR/…) — מושמט לגמרי (badge, לא בנתיב).
- **סוג-מורכב**: לפני בדיקת-הסוג-היחיד — `compoundTypes` (מיכל הדחה/מושב אסלה) נתפסים כ-`type` יחיד.
- **סוג יחיד**: הטוקן הראשון שב-`chipTypes` (וטרם נקבע `type`) ⇒ `type`.
- **מידה**: טוקן שמתאים ל-`sizeRe` (`^["”]?\d`/`^\d`/`^DN\d`) **ואינו** ב-`level2Shape` ⇒ `level5`; טוקן-מספרי נוסף נספח פנימה (`'$l5 $t'`). `45°`/`90°` נחסמים כי הם ב-`level2Shape`.
- **יחידה**: `chipUnits` (מ"מ/mm) נספחת לתוך `level5` הקיים (אם יש), אחרת מושמטת.
- **מורכבים**: התאמת-רב-מילים לפי סדר-עדיפות l3→l2→l1→l4, הארוך-קודם.
- **יחיד**: level1→level2→level3→level4 לפי המילון; טוקן לא-מוכר ⇒ `leftover`.
- **הסרת-סוגריים ללוגיקה בלבד**: `(סיפון)` נבדק כ-`סיפון` אך הטקסט המקורי נשמר.
- טוטאלי: לעולם לא זורק.
- `path` = שרשור l1..l4 + l5 (אם קיים). `levelLabelOf(pathIndex)`: 'חיבור'/'צורה'/'תכונה'/'תבריג'/'מידה'; אינדקס שלילי/מחוץ-לטווח ⇒ `''`.

## דוגמאות-מחייבות (עם מילוני-סיווג מוזרקים זעירים — parse_chips_test.dart)
מילונים מוזרקים: `chipTypes={ברך,צינור}` · `compoundTypes={מיכל הדחה}` · `level2Shape={45°}` ·
`level3Feature={ספיר}` · `level4Thread={פ.פ}` · `chipMaterial={PPR}` · `chipUnits={מ"מ}` · `l2Compounds={אספקת מים}` · השאר ריקים.

| # | קלט `nameHe` | `type` | l1 | l2 | l3 | l4 | l5 | leftover |
|---|---|---|---|---|---|---|---|---|
| 1 | `ברך 45° פ.פ 160` | `ברך` | `[]` | `[45°]` | `[]` | `[פ.פ]` | `160` | `[]` |
| 2 | `צינור אספקת מים 20 מ"מ` | `צינור` | `[]` | `[אספקת מים]` | `[]` | `[]` | `20 מ"מ` | `[]` |
| 3 | `מיכל הדחה ספיר` | `מיכל הדחה` | `[]` | `[]` | `[ספיר]` | `[]` | `null` | `[]` |
| 4 | `צינור PPR 20` | `צינור` | `[]` | `[]` | `[]` | `[]` | `20` | `[]` (חומר מושמט) |
| 5 | `ברך זמבורי 50` | `ברך` | `[]` | `[]` | `[]` | `[]` | `50` | `[זמבורי]` (לא-מוכר⇒leftover) |

### נגזרות (path · levelLabelOf) על דוגמה 1
- `path` = `[45°, פ.פ, 160]`
- `levelLabelOf(0)`=`צורה` · `(1)`=`תבריג` · `(2)`=`מידה` · `(-1)`=`''` · `(3)`=`''`

### הדאטה-מוחלפת ⇒ הפלט-משתנה (הוכחת-הזרקה)
`parseChips('ברך זמבורי 50', chipTypes: {})` ⇒ `type=null`, `leftover=[ברך, זמבורי]` —
מילון-ריק ⇒ 'ברך' חדל להיות type. מוכיח שהמילון מוזרק, לא צרוב.

## DoD (פקודה+פלט-צפוי — דיבר 12)
```
dart run --enable-asserts new/dart/parse_chips_test.dart  ⇒ exit 0 + "OK parseChips: 13 asserts passed"
```
