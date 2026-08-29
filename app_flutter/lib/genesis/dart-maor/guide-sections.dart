// ⚛️ אטום-Dart (דרגת-חוזה) · guideSections (קבוע GUIDE_SECTIONS) — שורות
//    "המדריך המהיר" 📖, שורה לכל מסך, מילה-במילה מהקובץ החי.
// מוצא: maor/src/lib/guide.ts:31-76 (מדריך P2 פער 29 + CONNECT חיבור 5) ·
//        המקור: new/atoms/guide-sections.mjs (`export const GUIDE_SECTIONS = [...]`).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). חוק-5 — הקבוע לא יודע מי דלוק;
//        הסינון/תרגום = החוט guide-sections-of שהקבוע מוזרק לו כשקע.
//
// תפקיד: הרשימה הקבועה של 9 שורות-המדריך, בסדר-המקור בדיוק (סדר-המסכים בלגאסי).
//        מבנה שורה: {module?,term?,title,text}. module חסר ⇒ תמיד מוצג (בית/הגדרות);
//        term = מפתח termOf לכותרת דינמית.
// קלט:  אין. פלט: List<Map<String,dynamic>> באורך 9.
//
// הערות-המרה (מקור→Dart):
//  • `export const GUIDE_SECTIONS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור.
//  • ⚠️ נוכחות-מפתח (כלל-המרה #2): במקור-ה-JS יש שורות **בלי** `module`/`term`
//    (בית/הגדרות/'כרטיס משפחה'). הבדיקה מפרידה `'module' in s` מ-`s.module===undefined`.
//    ⇒ בשורות-האלה **המפתח מושמט מהמפה** (לא מוגדר null!) — כך `containsKey('module')`
//    מחזיר false בדיוק כמו `!('module' in s)` ב-JS, ו-`s['module']` מחזיר null כמו
//    `s.module` undefined. (Map ריק-ממפתח ≠ Map עם ערך-null.)
//  • התוכן מועתק כלשונו — כל תו, אימוג'י ופיסוק זהה למקור (ratchet נוסח-הלגאסי).
//  • אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// Quick-guide sections (`GUIDE_SECTIONS`) — one row per screen, verbatim from
/// the live legacy file. Rows without a `module` key are always shown; rows carry
/// a `term` key for a dynamic title. Absent keys are OMITTED from the map (not
/// set to null) so `containsKey` mirrors JS `in` exactly (porting-rule #2).
/// Verbatim port of new/atoms/guide-sections.mjs. Filtering/translation is the
/// guide-sections-of thread, into which this constant is injected as a socket.
List<Map<String, dynamic>> get guideSections => const [
      {'title': 'בית', 'text': 'תקציר הבוקר, "דורש טיפול" (המשימות שלך), חדרים חיים וגרפים.'},
      {
        'module': 'families',
        'term': 'nav.families',
        'title': 'משפחות',
        'text': 'הטבלה: לחיצה על כותרת ממיינת, ⏷ מסנן כל עמודה, ✦ סינון מורחב עם גלגל.',
      },
      {
        'module': 'families',
        'title': 'כרטיס משפחה',
        'text': 'ניקוב ✓, חיסור ✕, ⚙ לתשלומים וקבלות, 📜 היסטוריה + דוח מלא.',
      },
      {
        'module': 'courses',
        'term': 'nav.courses',
        'title': 'קורסים',
        'text': 'לחיצה על חדר = היומן שלו; בתוך חוג: קבוצות, שיבוץ, ⬇ תדפיס למורה.',
      },
      {
        'module': 'supporters',
        'term': 'nav.supporters',
        'title': 'תומכות',
        'text': 'דרגות זהב/כסף/ארד, ＋ תרומה עם קבלה, 🎯 יעד קשר.',
      },
      {
        'module': 'calendar',
        'term': 'nav.calendar',
        'title': 'לוח שנה',
        'text': 'עברי גדול בכל תא, לחיצה על יום = סדר היום, אזכרות חוזרות בעברי לבד.',
      },
      // העמודות המבודדות (CONNECT חיבור 5) — מה זו כל עמודה + 3 הפעולות העיקריות
      {
        'module': 'tzedaka',
        'term': 'nav.tzedaka',
        'title': 'קופות צדקה',
        'text': 'רכזים וקופות בבתים. שלוש פעולות: ➕ רכז → ➕ קופה מכרטיס הרכז → 💰 ריקון (עם ניקוד ומבצעים).',
      },
      {
        'module': 'shop',
        'term': 'nav.shop',
        'title': 'חנות',
        'text': 'חבילות שירות למצבי חיים. שלוש פעולות: 📦 פריט בקטלוג → 🛍 חבילה → שיוך למשפחה ו-🎁 מימוש (אישור S-).',
      },
      {'title': 'הגדרות', 'text': 'ייצוא לאקסל, דוחות, מורות, וגיבוי מלא (פעם בשבוע!).'},
    ];
