// 🔌 מנוע-קטלוג-3D · פאזה B (שלב 32) — תאימות-בטיחות לקו-חם (מגודר).
//
// 🛡️ **בטיחות = אחריות (M5).** הפריטים כאן הם **המלצות-בטיחות עקרוניות** (ערכי-
// ייחוס), **לא דרישות-מחייבות**. כל [SafetyAdvisory] נושא-מבנית את [caveat] (שדה
// required) — אי-אפשר להחזיר המלצת-בטיחות בלי אזהרת-"לא-מחייב / מתקין-מוסמך /
// קוד-מקומי". קו לא-חם → **רשימה ריקה** (אין דרישת-שווא). מגודר ⇒ tree-shaken בכבוי.

import 'package:flutter/foundation.dart' show immutable;

/// סף קו-חם (°C) — זהה ל-`install_engine._kHotThresholdC`.
const int kHotLineThresholdC = 60;

/// אזהרת-החובה (M5) — נלווית לכל המלצת-בטיחות, verbatim בכל פריט.
const String kSafetyCaveat =
    '⚠️ המלצת-בטיחות עקרונית — לא ערך-מחייב. לתכנון/ביצוע ע״י מתקין או מהנדס '
    'מוסמך בלבד, לפי התקן והקוד המקומי (ISO 15874 · DVS 2207-11).';

/// המלצת-בטיחות יחידה לקו — **תמיד** נושאת [caveat] (M5: אין המלצה בלי אזהרה).
@immutable
class SafetyAdvisory {
  const SafetyAdvisory({
    required this.title,
    required this.whyHe,
    required this.caveat, // חובה-מבנית
  });

  final String title;
  final String whyHe;
  final String caveat;

  @override
  bool operator ==(Object other) =>
      other is SafetyAdvisory &&
      other.title == title &&
      other.whyHe == whyHe &&
      other.caveat == caveat;

  @override
  int get hashCode => Object.hash(title, whyHe, caveat);
}

/// המלצות-הבטיחות לקו-**PP-R חם** ב-[tempC] (שלב 32: PRV · פיצוי-התפשטות ·
/// אנטי-כוויה). 🛡️ M5: **המלצות-ייחוס בלבד**, כל אחת עם [kSafetyCaveat], לעולם
/// לא ערך-מחייב. קו לא-חם (`< 60°C`) או חומר-לא-PP-R → **ריק** (אין דרישת-שווא,
/// M1). לא מוחזר שום ערך-מספרי-מחייב (סף/לחץ/זמן) — רק דרישות-איכותיות מתועדות.
List<SafetyAdvisory> hotLineSafetyFor(String material, int tempC) {
  if (tempC < kHotLineThresholdC) return const []; // קו-קר → אין בטיחות-חום
  // 🛡️ prefix-match (מנרמל מקף) ולא `==`: התוויות ב-קוד הן `'PPR'` **וגם**
  // `'PPR · מחוזק בסיבי זכוכית (faser)'` / `'PPRCT'` / `'PP-RCT'` — וה-faser הוא
  // בדיוק צינור-הקו-החם. `==` היה משמיט בטיחות מקו-חם אמיתי (under-warning · תיקון
  // מביקורת-היריב). המקף מנורמל כדי ש-`'PP-RCT'` יזוהה כ-PP-R.
  if (!material.replaceAll('-', '').startsWith('PPR')) return const [];
  return const [
    SafetyAdvisory(
      title: 'שסתום ביטחון-לחץ (PRV)',
      whyHe: 'קו-אספקה חם ולחוץ — הגנה מפני עליית-לחץ עם החימום.',
      caveat: kSafetyCaveat,
    ),
    // "מיכל" מהטריאדה של שלב-32 — כלי-התפשטות בקו-חם סגור (נפח-מים גדל בחימום),
    // נבדל מפיצוי-התפשטות-הצינור למטה (תיקון-scope מביקורת-היריב).
    SafetyAdvisory(
      title: 'כלי-התפשטות (מיכל)',
      whyHe: 'קו-חם סגור — נפח-המים גדל בחימום; מיכל-התפשטות סופג את העלייה.',
      caveat: kSafetyCaveat,
    ),
    SafetyAdvisory(
      title: 'פיצוי התפשטות-תרמית של הצינור',
      whyHe: 'PP-R מתפשט משמעותית יותר ממתכת בחום — לולאת/מפרק-התפשטות ותמיכות מתאימות.',
      caveat: kSafetyCaveat,
    ),
    SafetyAdvisory(
      title: 'מגן אנטי-כוויה (TMV)',
      whyHe: 'מים ≥60°C — סיכון-כוויה בנקודות-השימוש; ברז-ערבוב תרמוסטטי.',
      caveat: kSafetyCaveat,
    ),
    // בידוד-תרמי — הפסדי-חום + סכנת-כוויה במגע-משטח (הזרימה-החיה מסמנת זאת לכל
    // קו-חם; נוסף מביקורת-היריב).
    SafetyAdvisory(
      title: 'בידוד תרמי',
      whyHe: 'קו-חם — הפחתת הפסדי-חום + מניעת כוויית-מגע במשטח החם.',
      caveat: kSafetyCaveat,
    ),
  ];
}
