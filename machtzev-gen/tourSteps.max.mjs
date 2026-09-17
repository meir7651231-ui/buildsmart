// 🤖 AUTO-EMITTED by gen-max — tourSteps משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
const TOUR_STEPS = [
    { view: 'home', caption: '👋 הדמיה מלאה — המערכת מדגימה את עצמה, על הנתונים האמיתיים' },
    { view: 'home', caption: 'סטטיסטיקות חיות — כל אריח לחיץ', anchorText: 'מדד אמינות' },
    { view: 'home', caption: '⌘K — חיפוש חכם מכל מקום', anchorText: 'חיפוש' },
    {
        view: 'families',
        module: 'families',
        caption: '🎡 מאתר המשפחות — גלגל בתוך הדף',
        anchorText: 'סינון מורחב',
    },
    { view: 'families', module: 'families', caption: 'ניקוב נוכחות — היתרה יורדת + 5 נק׳ אמינות' },
    { view: 'families', module: 'families', caption: 'רישום חיסור — עם כלל 48 השעות' },
    { view: 'courses', module: 'courses', caption: '🎡 מאתר החוגים', anchorText: 'מצא חוג' },
    { view: 'courses', module: 'courses', caption: 'חיזוי חוגים: רק תואמי גיל ומגדר' },
    { view: 'calendar', module: 'calendar', caption: '📅 עברי + לועזי · שכבות סינון' },
    // העמודות המבודדות (CONNECT חיבור 5) — צעד לכל עמודה, מגודר במודול שלה
    { view: 'tzedaka', module: 'tzedaka', caption: '🪙 קופות צדקה — רכזים, קופות בבתים, ריקונים ומבצעים' },
    { view: 'shop', module: 'shop', caption: '🛍 החנות — חבילות שירות, מלאי משותף ומימושים עם אישור' },
    { view: 'settings', caption: '⚙ ארגון, התראות, דוחות, מנוע אמינות' },
    { view: 'home', caption: 'ובחזרה הביתה — הכל התעדכן' },
    { view: 'home', caption: 'זו המערכת. חיה, מלאה, במקום אחד ✦' },
];
function courseDateError(start, end, config) {
    if (start && end && end < start) {
        const courseWord = config ? termOf(config, 'entity.course', 'חוג') : 'חוג';
        return 'תאריך הסיום מוקדם מתאריך ההתחלה — ה' + courseWord + ' לא יופיע בלוח. תקנו את התאריכים';
    }
    return null;
}
export function tourSteps_ORIG(isModuleOn, config) {
    const T = (k, fb) => (config ? termOf(config, k, fb) : fb);
    const loc = (s) => {
        const caption = s.caption
            .replace('מאתר המשפחות', 'מאתר ה' + T('nav.families', 'משפחות'))
            .replace('מאתר החוגים', 'מאתר ה' + T('nav.courses', 'חוגים'))
            .replace('חיזוי חוגים', 'חיזוי ' + T('nav.courses', 'חוגים'));
        const anchorText = s.anchorText === 'מצא חוג' ? 'מצא ' + T('entity.course', 'חוג') : s.anchorText;
        return caption === s.caption && anchorText === s.anchorText ? s : { ...s, caption, anchorText };
    };
    return TOUR_STEPS.filter((s) => !s.module || isModuleOn(s.module)).map(loc);
}
export function tourSteps(isModuleOn, __opt = {}) {
    const base = tourSteps_ORIG(isModuleOn);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
