// ⚛️ אטום-Dart (דרגת-חוזה) · thanksPrompt — בונה-פרומפט למכתב-תודה-לתורם.
// מוצא: maor/src/lib/ai.ts:46-60 · המקור: new/atoms/thanks-prompt.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-4 — זהה-ביט למקור-ה-JS.
//
// תפקיד: מרכיב הנחיה בעברית משורות קבועות + שדות-הקלט; שורות-הרשות (ייעוד ·
//        סה"כ-מצטבר) נכנסות רק כשהשדה מסופק (filter(Boolean)); orgName ריק/חסר ⇒
//        'הארגון'. חיבור ב-'\n'.
// קלט:  inp — Map עם orgName · supporterName · lastAmount · designation? · totalSoFar?
//        (הסכומים כבר מעוצבים, למשל '₪500'). פלט: מחרוזת-פרומפט.
//
// הערות-המרה (מקור→Dart):
//  • `inp.orgName` (גישת-שדה על אובייקט) → `inp['orgName']` (Map) — שדה-חסר ⇒ null,
//    מקביל ל-undefined של JS לצורך ה-||.
//  • `||` / תנאי-truthy של JS → `_truthy` מפורש (חוק-7: '' /0/NaN/null כוזבים) —
//    לא `??` (שאינו נופל על '') ולא bool ישיר.
//  • `.filter(Boolean)` על מערך-מחרוזות → `.where(_truthy)` — מסנן בדיוק את ה-''
//    של שורות-הרשות החסרות (השורות הקבועות תמיד truthy). `.join('\n')` זהה.
//  • שרשור `'x' + inp.supporterName` — הקלטים בחוזה מחרוזות; `.toString()` שומר
//    התנהגות גם על dynamic (String(v) של JS למחרוזת = זהות).
//  • מוטביליות: אפס var; אין תאריכים/locale/מספרים ⇒ אין חוקי-V8 נוספים.

/// truthiness של JS (חוק-7): null / '' / 0 / -0 / NaN / false ⇒ כוזב; כל השאר אמת.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Thank-you-letter prompt builder (AI add-on) — verbatim port of
/// new/atoms/thanks-prompt.mjs (`thanksPrompt`). Optional lines only when supplied.
String thanksPrompt(dynamic inp) {
  return [
    'כתוב מכתב תודה קצר (4-6 שורות), חם ואישי, בעברית, מארגון "' +
        (_truthy(inp['orgName']) ? inp['orgName'].toString() : 'הארגון') +
        '"',
    'לתורם/ת בשם "' +
        inp['supporterName'].toString() +
        '" על תרומה של ' +
        inp['lastAmount'].toString() +
        '.',
    _truthy(inp['designation'])
        ? 'התרומה יועדה ל: ' + inp['designation'].toString() + '.'
        : '',
    _truthy(inp['totalSoFar'])
        ? 'סה"כ תרומותיו/ה עד כה: ' +
            inp['totalSoFar'].toString() +
            ' — אפשר לרמוז לנאמנות בעדינות.'
        : '',
    'בלי הגזמות, בלי סופרלטיבים ריקים, בלי לציין סכומים מעבר לנאמר. לסיים בברכה חמה.',
    'להחזיר את המכתב בלבד — בלי הקדמות.',
  ].where(_truthy).join('\n');
}
