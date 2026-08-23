// 🔌 דגלי מנוע-הקטלוג-3D — כולם **default-OFF** ⇒ כל ה-graph של `features/fittings/`
// tree-shaken מ-build-הפרודקשן עד שמדליקים במפורש. שער #124 (GATE_REGISTRY).
//
// הפעלה: `--dart-define=FITTING_ENGINE=true` וכו׳.

/// שכבת-הליבה: המנוע הטהור (`generate`/`base`/families) + plan (BOM/cut-list).
/// OFF ⇒ אין נגיעה בזרימה החיה; ON ⇒ המנוע זמין לגזירת-specs/מידות.
const bool kFittingEngine = bool.fromEnvironment('FITTING_ENGINE');

/// שכבת-ה-3D: layout (turtle) + geometry + render. web-first (פאזה C).
const bool kFittingEngine3d = bool.fromEnvironment('FITTING_ENGINE_3D');

/// שכבת-האינטליגנציה: תכנון-חיבור/ניתוב/AI (פאזה D). מאומת ע"י המנוע הדטרמיניסטי.
const bool kFittingEngineIntel = bool.fromEnvironment('FITTING_ENGINE_INTEL');
