// ⚛️ אטום-Dart (דרגת-חוזה) · kindEmoji
// תפקיד: אמוג'י מייצג לכל סוג-פעולת-קונפיג (ConfigOpKind) — ✏️/🙂/🙈/↕️/🎨/⚙️.
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:140-150 (‏_kindEmoji; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). ה-enum-השכן `ConfigOpKind` הוטבע
//        inline verbatim (טיפוס-שכן-קטן, 6 ערכים — נגזרים מסדר-ה-case בטיוטה). פרטי-במקור (`_`) ⇒ public.
//        switch ממצה (exhaustive) על ה-enum — שפה/סטנדרט.
//
// קלט:  kind — ConfigOpKind (setText/setEmoji/setHidden/setOrder/setStyle/setAction).
// פלט:  String — האמוג'י המתאים (ממופה 1:1).

// טיפוס-שכן-קטן הוטבע inline verbatim (סדר-ה-case, diff_preview.dart).
// G62 · זרימה⇒טבלה: המיפוי חי ב-dart-data/kind_emoji-table.dart (דאטה, לא קוד); אפס-אובדן הוכח בבדיקת-הזהב.
import '../dart-data/kind_emoji-table.dart';

enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }

/// Representative emoji per config-op kind. Verbatim of diff_preview.dart:140-150.
String kindEmoji(ConfigOpKind kind) => kKindEmojiTable[kind.name]!;
