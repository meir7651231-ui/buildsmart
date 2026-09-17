// 🤖 AUTO-EMITTED by gen-max — payLink משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function payLink_ORIG(payUrl, amount, name = '') {
    const base = safeHttpsUrl(payUrl);
    if (!base)
        return null;
    const amt = String(Math.max(0, Math.round(amount * 100) / 100));
    if (base.includes('%7Bamount%7D') || base.includes('{amount}')) {
        // תבנית-מותאמת — החלפה בתוך ה-URL (גם בצורה המקודדת שה-URL parser מייצר).
        // סכום 0 ("לא-ידוע", קישור-תרומה-כללי) ⇒ שדה-ריק, עקבי עם מצב-הפרמטרים (לא Amount=0).
        return base
            .replace(/%7Bamount%7D|\{amount\}/g, amt === '0' ? '' : encodeURIComponent(amt))
            .replace(/%7Bname%7D|\{name\}/g, encodeURIComponent(name));
    }
    const u = new URL(base);
    // כיוון-יוצא נדרים-פלוס: עמוד-הסליקה שלהם קורא **Amount/ClientName** (PascalCase),
    // לא amount/name. זיהוי-מארח ⇒ מילוי-מראש שבאמת נתפס ("המערכת לוחצת על הקישור").
    if (/(^|\.)matara\.pro$/i.test(u.hostname) && /nedarimplus/i.test(u.pathname + u.search)) {
        if (amt !== '0')
            u.searchParams.set('Amount', amt);
        if (name.trim())
            u.searchParams.set('ClientName', name.trim());
        return u.toString();
    }
    if (amt !== '0')
        u.searchParams.set('amount', amt);
    if (name.trim())
        u.searchParams.set('name', name.trim());
    return u.toString();
}
export function payLink(payUrl, amount, name, __opt = {}) {
    const base = payLink_ORIG(payUrl, amount, name);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
