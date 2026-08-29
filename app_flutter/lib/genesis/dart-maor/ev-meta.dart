// ⚛️ אטום-Dart (דרגת-חוזה) · evMeta — מטא-דאטה של סוגי-אירועים (תווית+פיגמנטים).
// מוצא: maor/src/lib/eventMeta.ts (איחד 4 עותקים זהים במקור) · המקור: new/atoms/ev-meta.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מפת שמונת סוגי-האירועים ⇒ {label, bg, c}, בסדר-המקור בדיוק.
// קלט:  אין. פלט: Map<String, Map<String, String>> באורך 8.
//
// הערות-המרה (מקור→Dart):
//  • `export const EV_META = {...}` → getter top-level שמחזיר `const {...}` מקונן.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם שמונה סוגים, אותן תוויות ופיגמנטים, אותו סדר.
//  • אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד (DART-PORTING-RULES: כלום חל).

/// Event-type metadata map: type-key → {label, bg, c}, in source order.
/// Verbatim port of new/atoms/ev-meta.mjs (`EV_META`).
Map<String, Map<String, String>> get evMeta => const {
      'reminder': {'label': 'תזכורת', 'bg': '#efe7f3', 'c': '#7c3aed'},
      'call': {'label': 'טלפון', 'bg': '#dff0ec', 'c': '#0f766e'},
      'wedding': {'label': 'חתונה', 'bg': '#fdeee0', 'c': '#b45309'},
      'memorial': {'label': 'אזכרה', 'bg': '#eceae2', 'c': '#4d463c'},
      'anniversary': {'label': 'יום נישואים', 'bg': '#fbeef3', 'c': '#be185d'},
      'bday': {'label': 'יום הולדת', 'bg': '#fbeef3', 'c': '#be185d'},
      'org': {'label': 'אירוע', 'bg': '#e7edf5', 'c': '#3a5a86'},
      'custom': {'label': 'אירוע', 'bg': '#e7edf5', 'c': '#3a5a86'},
    };
