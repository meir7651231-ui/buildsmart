// Roadmap step 86 — i18n scaffold (NOT wired).
//
// Curated set of SmartProduct card UI strings (Hebrew). This module is the
// scaffolding for a future localization pass — it is a plain constants module
// with NO `intl` / `flutter_localizations` dependency. The values here are
// intended to become the source of truth that the card UI references instead
// of hardcoding string literals inline.
//
// Future translations will add parallel classes with the same field names
// (e.g. `SmartCardStringsEn`, `SmartCardStringsAr`), so a swap-in i18n layer
// can pick the locale-specific class without changing call sites.
//
// IMPORTANT: This step intentionally does NOT modify any existing UI code.
// The strings are extracted FROM `lib/screens/catalog_screen.dart` (proven by
// the companion test `test/smart_card_strings_test.dart`, which asserts every
// value is currently present in that screen — so this list is real, not
// invented). Wiring the screen to reference these constants is a later step.

/// Curated set of SmartProduct card UI labels in Hebrew.
///
/// Each `static const` here is a string the card UI currently renders inline
/// in `lib/screens/catalog_screen.dart`. The companion test guards both
/// non-emptiness and uniqueness, and (for non-exempt entries) verifies the
/// value still appears in the screen source.
abstract class SmartCardStringsHe {
  // 📦 Catalog-data section + readiness badge.
  static const sectionCatalogData = '📦 נתוני קטלוג';
  static const score = 'ציון';

  // Readiness band labels (live in `lib/data/related_info.dart`, NOT in
  // `catalog_screen.dart` — exempted in the companion test). Listed here so
  // that a future i18n pass has the full label palette in one place.
  static const labelExcellent = 'מצוין';
  static const labelGood = 'טוב';
  static const labelBasic = 'בסיסי';
  static const labelPartial = 'חלקי';

  // Expert / simple mode toggle (roadmap step 95).
  static const modeExpanded = 'מצב מורחב ▾';
  static const modeSimple = 'מצב פשוט ▸';

  // Save-config favourite toggle (roadmap step 47).
  static const saveConfig = '☆ שמור';
  static const savedConfig = '★ נשמר';

  // Quote / clipboard (roadmap step 48).
  static const copyQuote = '📋 הצעה';

  // Engine-driven actions (roadmap steps 22, 46, 71, 74, 75, 76).
  static const buildLineBom = '🔧 בנה לי קו (BOM)';
  static const addToProject = '➕ הוסף לפרויקט';
  static const cartPlusSafety = '🛒 + בטיחות לסל';
  static const saveVersion = '💾 שמור גרסה';
  static const projectFullBom = '📋 BOM פרויקט מלא';
  static const projectCustomerQuote = '📋 הצעת מחיר לפרויקט';

  // Project templates row (roadmap step 80).
  static const templates = 'תבניות:';

  // Variants family list (roadmap step 63).
  static const variantsFamily = 'גרסאות נוספות במשפחה';

  // Standards / tools / install / tips / acceptance (roadmap steps 12, 33-35,
  // 38).
  static const israeliStandard = 'תקן ישראלי רלוונטי';
  static const installation = 'התקנה';
  static const tools = 'כלי עבודה';
  static const tipsCommonMistakes = 'טעויות נפוצות וטיפים';
  static const acceptanceTest = 'בדיקת קבלה (סיום התקנה)';

  // Connection needs row (roadmap step 73).
  static const lineNeeds = 'מה הקו צריך לחיבור';

  // Auxiliary card chrome.
  static const recentlyViewed = 'נצפו לאחרונה';
  static const complianceRequired = 'תקינות נדרשת';
  static const whenToPickBrand = 'מתי לבחור איזה מותג';

  /// Complete list of curated values — used by the companion test to iterate
  /// without reflection. KEEP IN SYNC with the constants above.
  static const List<String> all = <String>[
    sectionCatalogData,
    score,
    labelExcellent,
    labelGood,
    labelBasic,
    labelPartial,
    modeExpanded,
    modeSimple,
    saveConfig,
    savedConfig,
    copyQuote,
    buildLineBom,
    addToProject,
    cartPlusSafety,
    saveVersion,
    projectFullBom,
    projectCustomerQuote,
    templates,
    variantsFamily,
    israeliStandard,
    installation,
    tools,
    tipsCommonMistakes,
    acceptanceTest,
    lineNeeds,
    recentlyViewed,
    complianceRequired,
    whenToPickBrand,
  ];

  /// Values intentionally exempt from the "appears in catalog_screen.dart"
  /// test because they live in a sibling helper module (e.g. readiness band
  /// labels in `lib/data/related_info.dart`). They are still included in the
  /// scaffold because they're part of the card's user-visible string palette.
  static const Set<String> screenContainmentExempt = <String>{
    labelExcellent,
    labelGood,
    labelBasic,
    labelPartial,
  };
}
