// ⚛️ אטום-Dart (דרגת-חוזה) · componentTypeNames
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:232-233
//        (‏componentTypeNames; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — Set-comprehension).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • kComponentPalette (component_palette.dart:233) — הפלטה-השכנה הגלובלית
//     (List<ComponentTemplate>). המקור סורק אותה וקורא מכל פריט ערך-אחד בלבד:
//     `t.type.name` (השם של enum-הסוג ComponentType). לכן היא קורסת לשקע `palette`,
//     `Iterable<PaletteEntry>` — מחזיק-קלט טהור שנושא רק את השדה-הנקרא `typeName`.
//     אפס תלות ב-ComponentTemplate, ב-enum ComponentType, או בשדות
//     he/allowedContainers/requiredProps/optionalProps/optionalAction/maxPerContainer.
//     (אותו דפוס-קריסה כמו catalogActionIdsFor שקרס kActionCatalog+a.id/a.mutates.)
//
// קלט:  palette — Iterable<PaletteEntry>: הפלטה-הסגורה, כל פריט נושא typeName אחד.
// פלט:  Set<String> — קבוצת שמות-הסוגים המובחנים בפלטה (סדר-הכנסה, ללא-כפילויות).

/// מחזיק-קלט טהור: רק השדה היחיד ש-componentTypeNames קורא מכל
/// ComponentTemplate (component_palette.dart:233, `t.type.name`).
/// typeName = השם של סוג-הרכיב הסגור (enum ComponentType.name).
class PaletteEntry {
  final String typeName;
  const PaletteEntry({required this.typeName});
}

/// כל שמות סוגי-הרכיבים בפלטה — הקבוצה-הסגורה שהמודל מוגבל אליה
/// (מקביל ל-actionCatalogIds). התנהגות verbatim של
/// component_palette.dart:232-233: Set-comprehension על הפלטה, אוסף `t.typeName`.
/// Set-literal של Dart שומר סדר-הכנסה (LinkedHashSet) ומסיר כפילויות.
Set<String> componentTypeNames(Iterable<PaletteEntry> palette) =>
    {for (final t in palette) t.typeName};
