// ⚛️ אטום-Dart · lipskeyStagesFor
// מוצא: buildsmart/app_flutter/lib/data/lipskey_smart_data.dart:334-336 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `LipskeyCatStage` (:21-33) הוטבע verbatim; הקבועים `kLipskeyStagesBySku` (:328)
//        ו-`kLipskeyStagesByCategory` (:207-319) הוטבעו verbatim (נתוני-קטלוג, dart:core בלבד).

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



const Map<String, List<LipskeyCatStage>> kLipskeyStagesBySku = {};

const Map<String, List<LipskeyCatStage>> kLipskeyStagesByCategory = {
  'מחסומים גלויים': [
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
  'אטמים ופקקים': [
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


/// שלבי-התקנה למוצר: דריסת-SKU → ברירת-קטגוריה → ריק. PURE.
List<LipskeyCatStage> lipskeyStagesFor(String sku, String categoryHe) =>
    kLipskeyStagesBySku[sku] ?? kLipskeyStagesByCategory[categoryHe] ?? const [];
