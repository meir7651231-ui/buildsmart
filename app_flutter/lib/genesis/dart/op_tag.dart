// ⚛️ אטום-Dart (דרגת-חוזה) · opTag
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:474-483 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level ציבורית, אפס import (רק dart:core).
// פרטי-במקור: `_opTag` — הוצא לחוזה כ-top-level ציבורי.
//
// אחים שהוטבעו (טיפוסי-שכן, כלל-1): ה-sealed `ConfigOp` + 6 תת-הטיפוסים
//        (config_store.dart:49+). הפונקציה מתאימה-תבנית לפי הטיפוס בלבד ואינה
//        קוראת שדה — לכן הוטבעו כשלדים ריקים (השדות/מתודות-ההתנהגות הושמטו).
//
// קלט:  op — פעולת-קונפיג.
// פלט:  תג-ה-op כמחרוזת (setText/setEmoji/…), ללא הקצאה.

/// טיפוסי-שכן מוטבעים (config_store.dart) — שלדים לצורך התאמת-תבנית.
sealed class ConfigOp {}

final class SetText extends ConfigOp {}

final class SetEmoji extends ConfigOp {}

final class SetHidden extends ConfigOp {}

final class SetOrder extends ConfigOp {}

final class SetStyle extends ConfigOp {}

final class SetAction extends ConfigOp {}

/// תג-ה-op של [op] (מראה את תג `'op'` של toJson). טהור.
String opTag(ConfigOp op) => switch (op) {
      SetText() => 'setText',
      SetEmoji() => 'setEmoji',
      SetHidden() => 'setHidden',
      SetOrder() => 'setOrder',
      SetStyle() => 'setStyle',
      SetAction() => 'setAction',
    };
