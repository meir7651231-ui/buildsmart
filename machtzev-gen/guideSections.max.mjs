// 🤖 AUTO-EMITTED by gen-max — guideSections משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function swap(s, from, to) {
    return s.split(from).join(to);
}
const GUIDE_SECTIONS = [
    { title: 'בית', text: 'תקציר הבוקר, "דורש טיפול" (המשימות שלך), חדרים חיים וגרפים.' },
    {
        module: 'families',
        term: 'nav.families',
        title: 'משפחות',
        text: 'הטבלה: לחיצה על כותרת ממיינת, ⏷ מסנן כל עמודה, ✦ סינון מורחב עם גלגל.',
    },
    {
        module: 'families',
        title: 'כרטיס משפחה',
        text: 'ניקוב ✓, חיסור ✕, ⚙ לתשלומים וקבלות, 📜 היסטוריה + דוח מלא.',
    },
    {
        module: 'courses',
        term: 'nav.courses',
        title: 'קורסים',
        text: 'לחיצה על חדר = היומן שלו; בתוך חוג: קבוצות, שיבוץ, ⬇ תדפיס למורה.',
    },
    {
        module: 'supporters',
        term: 'nav.supporters',
        title: 'תומכות',
        text: 'דרגות זהב/כסף/ארד, ＋ תרומה עם קבלה, 🎯 יעד קשר.',
    },
    {
        module: 'calendar',
        term: 'nav.calendar',
        title: 'לוח שנה',
        text: 'עברי גדול בכל תא, לחיצה על יום = סדר היום, אזכרות חוזרות בעברי לבד.',
    },
    // העמודות המבודדות (CONNECT חיבור 5) — מה זו כל עמודה + 3 הפעולות העיקריות
    {
        module: 'tzedaka',
        term: 'nav.tzedaka',
        title: 'קופות צדקה',
        text: 'רכזים וקופות בבתים. שלוש פעולות: ➕ רכז → ➕ קופה מכרטיס הרכז → 💰 ריקון (עם ניקוד ומבצעים).',
    },
    {
        module: 'shop',
        term: 'nav.shop',
        title: 'חנות',
        text: 'חבילות שירות למצבי חיים. שלוש פעולות: 📦 פריט בקטלוג → 🛍 חבילה → שיוך למשפחה ו-🎁 מימוש (אישור S-).',
    },
    { title: 'הגדרות', text: 'ייצוא לאקסל, דוחות, מורות, וגיבוי מלא (פעם בשבוע!).' },
];
function sanitizeSupportText(raw) {
    return (raw ?? '').replace(/\s+$/u, '').replace(/^\s+/u, '').slice(0, SUPPORT_MSG_MAX);
}
function courseDateError(start, end, config) {
    if (start && end && end < start) {
        const courseWord = config ? termOf(config, 'entity.course', 'חוג') : 'חוג';
        return 'תאריך הסיום מוקדם מתאריך ההתחלה — ה' + courseWord + ' לא יופיע בלוח. תקנו את התאריכים';
    }
    return null;
}
export function guideSections_ORIG(isModuleOn, config) {
    const T = (k, fb) => (config ? termOf(config, k, fb) : fb);
    const loc = (s) => {
        let { title, text } = s;
        if (title === 'כרטיס משפחה')
            title = 'כרטיס ' + T('entity.family', 'משפחה');
        text = swap(text, 'חדרים חיים', T('entity.rooms', 'חדרים') + ' חיים');
        text = swap(text, 'על חדר', 'על ' + T('entity.room', 'חדר'));
        text = swap(text, 'בתוך חוג', 'בתוך ' + T('entity.course', 'חוג'));
        text = swap(text, 'תדפיס למורה', 'תדפיס ל' + T('entity.teacher', 'מורה'));
        text = swap(text, '＋ תרומה', '＋ ' + T('entity.donation', 'תרומה'));
        text = swap(text, 'שיוך למשפחה', 'שיוך ל' + T('entity.family', 'משפחה'));
        return title === s.title && text === s.text ? s : { ...s, title, text };
    };
    return GUIDE_SECTIONS.filter((s) => !s.module || isModuleOn(s.module)).map(loc);
}
export function guideSections(isModuleOn, __opt = {}) {
    const base = guideSections_ORIG(isModuleOn);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
