function fillCardFromCharge_ORIG(sp, charge) {
    const fill = {};
    // 🐛 נחיל-סולה C12: טלפון שלא שורד נורמליזציה (קצר/דמה) לא ממלא שדה ריק —
    // אחרת הוא חוסם השלמה אמיתית עתידית (מילוי-אם-ריק לא דורס).
    const rawPhone = (charge.phone || '').trim();
    const phone = normPhone(rawPhone).length >= 7 ? rawPhone : '';
    const email = (charge.email || '').trim();
    const zeout = normId(charge.zeout || '');
    const name = (charge.name || '').trim();
    if (phone && !(sp.phone || '').trim())
        fill.phone = phone;
    if (email && !(sp.email || '').trim())
        fill.email = email;
    if (zeout && !(sp.idNum || '').trim())
        fill.idNum = zeout;
    if (name && !(sp.name || '').trim())
        fill.name = name;
    return Object.keys(fill).length ? { ...sp, ...fill } : sp;
}
function candidateSupportersForCharge(charge, supporters, limit = 8) {
    const ck = new Set(keysOf({ extId: charge.toremId, zeout: charge.zeout, phone: charge.phone, email: charge.email }));
    const cName = nameSortKey(charge.name || '');
    const scored = [];
    for (const sp of supporters) {
        const sk = keysOf({ extId: sp.extId, idNum: sp.idNum, phone: sp.phone, email: sp.email });
        let score = 0;
        for (const k of sk) {
            if (!ck.has(k))
                continue;
            if (k.startsWith('ext:'))
                score = Math.max(score, 5);
            else if (k.startsWith('id:'))
                score = Math.max(score, 4);
            else if (k.startsWith('ph:'))
                score = Math.max(score, 3);
            else if (k.startsWith('em:'))
                score = Math.max(score, 2);
        }
        if (!score && cName && cName.includes(' ') && nameSortKey(sp.name) === cName)
            score = 1;
        if (score)
            scored.push({ sp, score });
    }
    scored.sort((a, b) => b.score - a.score);
    return scored.slice(0, limit).map((x) => x.sp);
}
export function fillCardFromCharge(sp, charge) { return fillCardFromCharge_ORIG(sp, charge); }
export function fillCardFromCharge_fromSource(charge, supporters, limit) { return fillCardFromCharge_ORIG(candidateSupportersForCharge(charge, supporters, limit), charge); }
