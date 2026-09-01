// ⚛️ אטום-Dart (דרגת-חוזה) · kindPlural
// תפקיד: שם-עצם עברי ברבים לספירת-קבוצה פר-סוג-פעולה (§9) — SetStyle=='צבעים' רק כש-styleAllColor, אחרת 'עיצובים'.
// מוצא: buildsmart/app_flutter/lib/logic/studio/diff_preview.dart:151-164 (‏_kindPlural; חוק-4 — verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). ה-enum-השכן `ConfigOpKind` הוטבע
//        inline verbatim (טיפוס-שכן-קטן, 6 ערכים — נגזרים מסדר-ה-case). פרטי-במקור (`_`) ⇒ public.
//        switch ממצה על ה-enum — שפה/סטנדרט.
//
// קלט:  kind          — ConfigOpKind.
//        styleAllColor — האם כל-הפעולות בקבוצת-הסגנון הן שינויי-צבע (משפיע רק על setStyle).
// פלט:  String — שם-הרבים המתאים.

// טיפוס-שכן-קטן הוטבע inline verbatim (סדר-ה-case, diff_preview.dart).
enum ConfigOpKind { setText, setEmoji, setHidden, setOrder, setStyle, setAction }

/// Hebrew plural noun per config-op kind. Verbatim of diff_preview.dart:151-164.
String kindPlural(ConfigOpKind kind, bool styleAllColor, {required String Function(String) term}) => switch (kind) {
      ConfigOpKind.setText => term('tkstym'),
      ConfigOpKind.setEmoji => term('amvgym'),
      ConfigOpKind.setHidden => term('hstrvt'),
      ConfigOpKind.setOrder => term('shynvyy-sdr'),
      ConfigOpKind.setStyle => styleAllColor ? term('tsbaym') : term('aytsvbym'),
      ConfigOpKind.setAction => term('pavlvt'),
    };
