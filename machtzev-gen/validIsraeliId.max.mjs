// 🤖 AUTO-EMITTED by gen-max — validIsraeliId משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function validIsraeliId_ORIG(id) {
    const s = String(id).trim();
    if (!/^\d{5,9}$/.test(s))
        return false;
    if (!/[1-9]/.test(s))
        return false; // ת"ז של אפסים בלבד אינה תקינה
    const p = s.padStart(9, '0');
    let sum = 0;
    for (let i = 0; i < 9; i++) {
        let d = +p[i] * (i % 2 === 0 ? 1 : 2);
        if (d > 9)
            d -= 9;
        sum += d;
    }
    return sum % 10 === 0;
}
export function validIsraeliId(id, __opt = {}) {
    const base = validIsraeliId_ORIG(id);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
