function isAdar(m) {
    return m === 'Adar' || m === 'Adar I' || m === 'Adar II';
}
export function hebAnnualEq_ORIG(anchor, query) {
    // כלל ל׳: עוגן-30 מול א' בחודש-הבא, כשלחודש-העוגן אין 30 בשנת היום-הנבדק.
    if (anchor.day === 30 && query.day === 1 && query.year) {
        const { seq, has30 } = scanHebYear(query.year);
        const qi = seq.indexOf(query.month);
        const prev = qi > 0 ? seq[qi - 1] : null;
        // עוגן 30 אדר-א' בשנה *פשוטה*: אין 'Adar I' ברצף (רק 'Adar'), לכן ההשוואה
        // הישירה נכשלה והאירוע נעלם לגמרי (באג — אזכרה/יום-הולדת ב-30 אדר-א' חסר
        // מ-12 מתוך 19 שנים). כלל ל׳ המתועד: נופל על א' בחודש-הבא (=א' ניסן). אדר-א'
        // בשנה פשוטה = ה-'Adar' היחיד, שאין בו 30 ⇒ יורה. (בשנה מעוברת אין נפילה —
        // ל-Adar I יש 30, ההתאמה המדויקת מטפלת; ראה בדיקת-שימור.)
        const prevMatches = prev === anchor.month || (anchor.month === 'Adar I' && prev === 'Adar');
        if (prev && prevMatches && !has30.has(prev))
            return true;
    }
    if (anchor.day !== query.day)
        return false;
    if (isAdar(anchor.month) || isAdar(query.month)) {
        if (!isAdar(anchor.month) || !isAdar(query.month))
            return false; // אחד אדר, השני לא
        if (query.month === 'Adar')
            return true; // שנה פשוטה — אדר יחיד בולע כל עוגן-אדר
        if (query.month === 'Adar II')
            return anchor.month === 'Adar' || anchor.month === 'Adar II';
        if (query.month === 'Adar I')
            return anchor.month === 'Adar I';
        return false;
    }
    return anchor.month === query.month;
}
export function hebAnnualEq(anchor, query, __opt = {}) {
    const base = hebAnnualEq_ORIG(anchor, query);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
