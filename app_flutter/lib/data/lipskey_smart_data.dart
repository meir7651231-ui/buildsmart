// Category mapping and per-category smart data for the Lipskey catalog.

// ── Accessory ─────────────────────────────────────────────────────────────────
class LipskeyCatAcc {
  final String name;
  final String emoji;
  final int? price;
  final String why;
  final bool must;

  const LipskeyCatAcc({
    required this.name,
    required this.emoji,
    this.price,
    required this.why,
    this.must = false,
  });
}

// ── Installation stage ────────────────────────────────────────────────────────
class LipskeyCatStage {
  final String emoji;
  final String label;
  final String desc;
  final bool isFinal;

  const LipskeyCatStage({
    required this.emoji,
    required this.label,
    this.desc = '',
    this.isFinal = false,
  });
}

// ── Lipskey catalog section / category hierarchy (from PDF TOC) ──────────────

class LipskeyCatEntry {
  final String name;   // matches categoryHe in LipskeyCatalogProduct
  final String emoji;
  final bool hasData;  // false = extracted in future catalog update
  const LipskeyCatEntry({
    required this.name,
    required this.emoji,
    this.hasData = true,
  });
}

class LipskeySection {
  final String name;
  final String emoji;
  final String nameEn;
  final List<LipskeyCatEntry> entries;
  const LipskeySection({
    required this.name,
    required this.emoji,
    required this.nameEn,
    required this.entries,
  });
}

// PDF page 3 — תוכן עניינים verbatim, two top-level sections.
const List<LipskeySection> kLipskeySections = [
  LipskeySection(
    name: 'אינסטלציה',
    emoji: '🔧',
    nameEn: 'Plumbing',
    entries: [
      LipskeyCatEntry(name: 'מחסומים (סיפונים) גלויים', emoji: '🚰'),
      LipskeyCatEntry(name: 'אמבט ואגנית',               emoji: '🛁'),
      LipskeyCatEntry(name: 'אביזרי תבריג',              emoji: '🔩'),
      LipskeyCatEntry(name: 'מחסומי רצפה',               emoji: '⬇️'),
      LipskeyCatEntry(name: 'מאספים וקולטים',            emoji: '🕳️'),
      LipskeyCatEntry(name: 'אטמים אומים ופקקים',        emoji: '🔧'),
      LipskeyCatEntry(name: 'אביזרי שקע-תקע',            emoji: '🔌'),
      LipskeyCatEntry(name: 'ברכיים',                    emoji: '↩️'),
      LipskeyCatEntry(name: 'מסעפים וחיבורי אסלה',       emoji: '⑂'),
      LipskeyCatEntry(name: 'זקיף אסלה',                 emoji: '🚽'),
      LipskeyCatEntry(name: 'מצמדים וצינורות',           emoji: '🪠'),
      LipskeyCatEntry(name: 'צינורות',                   emoji: '📏'),
    ],
  ),
  LipskeySection(
    name: 'סניטציה',
    emoji: '🚽',
    nameEn: 'Sanitary',
    entries: [
      LipskeyCatEntry(name: 'התקנה גבוהה',               emoji: '🔺'),
      LipskeyCatEntry(name: 'התקנה נמוכה',               emoji: '🔻'),
      LipskeyCatEntry(name: 'התקנה צמודה',               emoji: '⬜'),
      LipskeyCatEntry(name: 'מושבי אסלה',                emoji: '🪑'),
      LipskeyCatEntry(name: 'חלקים סניטריים',            emoji: '🔧'),
    ],
  ),
];

// ── Accessories per Lipskey category ─────────────────────────────────────────
const Map<String, List<LipskeyCatAcc>> kLipskeyAccByCategory = {
  'מחסומים (סיפונים) גלויים': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם את ההברגה — חובה', must: true),
    LipskeyCatAcc(name: 'אטם גומי 32/50mm', emoji: '⚫', price: 8,
        why: 'מונע נזילה בחיבור', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק הסיפון', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום בין הסיפון למשטח', must: false),
  ],
  'מחסומי רצפה': [
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'איטום חיבור לצינור', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם הברגת מכסה', must: true),
    LipskeyCatAcc(name: 'מלט מפרקים', emoji: '🪣',
        why: 'לסביבת הרצפה לאחר התקנה', must: false),
  ],
  'מאספים וקולטים': [
    LipskeyCatAcc(name: 'אטם גומי', emoji: '⚫', price: 8,
        why: 'לחיבורי הצינורות', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'לאיטום ההברגות', must: true),
  ],
  'מסעפים וחיבורי אסלה': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'חיבור לצינור ניקוז', must: true),
  ],
  'מצמדים וצינורות': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק המצמד', must: true),
  ],
  'מושבי אסלה': [
    LipskeyCatAcc(name: 'ברגי הידוק', emoji: '🔩', price: 8,
        why: 'לחיבור המושב לאסלה', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 12,
        why: 'איטום בין המושב לאסלה', must: false),
  ],
  'אמבט ואגנית': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום פריפריאלי', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק', must: true),
  ],
  'אביזרי תבריג': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגה', must: true),
    LipskeyCatAcc(name: 'מפתח ברגים', emoji: '🔩', price: 25,
        why: 'לחיבור', must: true),
  ],
  'אטמים אומים ופקקים': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'לאיטום נוסף', must: false),
  ],
  'ברכיים': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום החיבור לצינור', must: true),
    LipskeyCatAcc(name: 'מפתח שבדי', emoji: '🔧', price: 45,
        why: 'להידוק אומי החיבור', must: true),
  ],
  'אביזרי שקע-תקע': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום החיבורים', must: false),
  ],
  'זקיף אסלה': [
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'איטום חיבור לאסלה', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם הברגות', must: true),
  ],
  'צינורות': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום חיבורים', must: false),
    LipskeyCatAcc(name: 'מסור לפלסטיק', emoji: '🪚', price: 35,
        why: 'חיתוך לאורך הנכון', must: true),
    LipskeyCatAcc(name: 'מחבר כפול', emoji: '🔌', price: 12,
        why: 'חיבור בין הצינורות', must: true),
  ],
  'התקנה גבוהה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור המיכל לקיר', must: true),
    LipskeyCatAcc(name: 'צינור חיבור גמיש', emoji: '🪠', price: 15,
        why: 'מחבר מיכל לקערה', must: true),
  ],
  'התקנה נמוכה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור המיכל לקיר', must: true),
    LipskeyCatAcc(name: 'אטם גומי מיכל', emoji: '⚫', price: 6,
        why: 'מונע נזילה', must: true),
  ],
  'התקנה צמודה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור הקערה לרצפה', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום בסיס הקערה', must: true),
  ],
  'חלקים סניטריים': [
    LipskeyCatAcc(name: 'ברגי הידוק', emoji: '🔩', price: 6,
        why: 'חיבור החלק החדש', must: true),
  ],
};

// ── Installation stages per Lipskey category ─────────────────────────────────
const Map<String, List<LipskeyCatStage>> kLipskeyStagesByCategory = {
  'מחסומים (סיפונים) גלויים': [
    LipskeyCatStage(emoji: '🔩', label: 'הכנה', desc: 'כרוך טפלון על החיבור'),
    LipskeyCatStage(emoji: '🌀', label: 'הברגה', desc: 'הברג את הסיפון ידנית'),
    LipskeyCatStage(emoji: '🔧', label: 'הידוק', desc: 'הדק עם מפתח צינורות'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק ניקוז ואין נזילה', isFinal: true),
  ],
  'מחסומי רצפה': [
    LipskeyCatStage(emoji: '📐', label: 'מדידה', desc: 'ודא מרכוז המחסום בפתח'),
    LipskeyCatStage(emoji: '⚫', label: 'אטם', desc: 'הנח אטם גומי 110mm'),
    LipskeyCatStage(emoji: '🔧', label: 'הידוק', desc: 'הדק את בורג המרכז'),
    LipskeyCatStage(emoji: '✅', label: 'גמר',
        desc: 'השלם ריצוף — בדוק ניקוז', isFinal: true),
  ],
  'מאספים וקולטים': [
    LipskeyCatStage(emoji: '📐', label: 'מיקום', desc: 'סמן מיקום המאסף'),
    LipskeyCatStage(emoji: '⚫', label: 'חיבור', desc: 'חבר עם אטמים לצינורות'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק זרימה', isFinal: true),
  ],
  'מסעפים וחיבורי אסלה': [
    LipskeyCatStage(emoji: '🔩', label: 'הכנה', desc: 'כרוך טפלון'),
    LipskeyCatStage(emoji: '⑂', label: 'חיבור', desc: 'חבר את המסעף לצינורות'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הדחת מים — בדוק הכל', isFinal: true),
  ],
  'מצמדים וצינורות': [
    LipskeyCatStage(emoji: '✂️', label: 'חיתוך', desc: 'חתוך צינור לאורך נדרש'),
    LipskeyCatStage(emoji: '🪠', label: 'חיבור', desc: 'הכנס לתוך המצמד'),
    LipskeyCatStage(emoji: '🔧', label: 'הידוק', desc: 'הדק את אומי המצמד'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק ללא נזילה', isFinal: true),
  ],
  'מושבי אסלה': [
    LipskeyCatStage(emoji: '🔩', label: 'פירוק', desc: 'הסר את המושב הישן'),
    LipskeyCatStage(emoji: '🧹', label: 'ניקוי', desc: 'נקה את משטח האסלה'),
    LipskeyCatStage(emoji: '✅', label: 'התקנה',
        desc: 'הנח מושב חדש + הדק', isFinal: true),
  ],
  'אמבט ואגנית': [
    LipskeyCatStage(emoji: '🔩', label: 'הכנה', desc: 'טפלון על כל ההברגות'),
    LipskeyCatStage(emoji: '🌀', label: 'חיבור', desc: 'חבר לצינור הניקוז'),
    LipskeyCatStage(emoji: '🧴', label: 'איטום', desc: 'סיליקון מסביב לנקז'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק ניקוז ואיטום', isFinal: true),
  ],
  'אביזרי תבריג': [
    LipskeyCatStage(emoji: '🔩', label: 'הכנה', desc: 'טפלון על ההברגה'),
    LipskeyCatStage(emoji: '🔧', label: 'חיבור', desc: 'הברג בידיים + הדק'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק ניקוז', isFinal: true),
  ],
  'אטמים אומים ופקקים': [
    LipskeyCatStage(emoji: '🔧', label: 'הכנסה', desc: 'הכנס אטם/פקק לחיבור'),
    LipskeyCatStage(emoji: '✅', label: 'אישור',
        desc: 'ודא הידוק תקין', isFinal: true),
  ],
  'ברכיים': [
    LipskeyCatStage(emoji: '✂️', label: 'חיתוך', desc: 'חתוך צינור לאורך הנדרש'),
    LipskeyCatStage(emoji: '↩️', label: 'חיבור', desc: 'הכנס הברך לשני הצינורות'),
    LipskeyCatStage(emoji: '🔧', label: 'הידוק', desc: 'הדק את כל החיבורים'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק זרימה ואין נזילה', isFinal: true),
  ],
  'אביזרי שקע-תקע': [
    LipskeyCatStage(emoji: '✂️', label: 'חיתוך', desc: 'חתוך צינור לגודל הנכון'),
    LipskeyCatStage(emoji: '🔌', label: 'חיבור', desc: 'הכנס האביזר לצינור בלחיצה'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'ודא חיבור יציב — בדוק ניקוז', isFinal: true),
  ],
  'זקיף אסלה': [
    LipskeyCatStage(emoji: '🔩', label: 'הכנה', desc: 'כרוך טפלון + הכנס אטם'),
    LipskeyCatStage(emoji: '🚽', label: 'חיבור', desc: 'הברג הזקיף לאסלה'),
    LipskeyCatStage(emoji: '🔧', label: 'הידוק', desc: 'הדק עם מפתח'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הדח — בדוק ניקוז ואין נזילה', isFinal: true),
  ],
  'צינורות': [
    LipskeyCatStage(emoji: '📐', label: 'מדידה', desc: 'מדוד ועסמן את האורך הנדרש'),
    LipskeyCatStage(emoji: '✂️', label: 'חיתוך', desc: 'חתוך בזוית ישרה'),
    LipskeyCatStage(emoji: '🔌', label: 'חיבור', desc: 'הכנס לשקע עם אטם גומי'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל מים — בדוק זרימה ומישור נכון', isFinal: true),
  ],
  'התקנה גבוהה': [
    LipskeyCatStage(emoji: '📐', label: 'סימון', desc: 'סמן מיקום המיכל על הקיר'),
    LipskeyCatStage(emoji: '🔩', label: 'קיבוע', desc: 'קבע המיכל בברגי נירוסטה'),
    LipskeyCatStage(emoji: '🪠', label: 'חיבור', desc: 'חבר צינור הדחה לקערה'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הדח מים — בדוק כל החיבורים', isFinal: true),
  ],
  'התקנה נמוכה': [
    LipskeyCatStage(emoji: '📐', label: 'מיקום', desc: 'מקם הקערה ומרכז לניקוז'),
    LipskeyCatStage(emoji: '🔩', label: 'קיבוע', desc: 'קבע הקערה לרצפה'),
    LipskeyCatStage(emoji: '⚫', label: 'אטם', desc: 'הנח אטם גומי + חבר המיכל'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הדח מים — בדוק ניקוז ואיטום', isFinal: true),
  ],
  'התקנה צמודה': [
    LipskeyCatStage(emoji: '📐', label: 'מיקום', desc: 'מרכז הקערה לניקוז'),
    LipskeyCatStage(emoji: '🧴', label: 'איטום', desc: 'הנח סיליקון סביב הבסיס'),
    LipskeyCatStage(emoji: '🔩', label: 'קיבוע', desc: 'הדק ברגי הרצפה'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הדח מים — בדוק ניקוז ואיטום', isFinal: true),
  ],
  'חלקים סניטריים': [
    LipskeyCatStage(emoji: '🔧', label: 'פירוק', desc: 'פרק החלק הישן מהמיכל'),
    LipskeyCatStage(emoji: '🔌', label: 'התקנה', desc: 'התקן החלק החדש'),
    LipskeyCatStage(emoji: '✅', label: 'בדיקה',
        desc: 'הפעל הדחה — בדוק פעולה תקינה', isFinal: true),
  ],
};
