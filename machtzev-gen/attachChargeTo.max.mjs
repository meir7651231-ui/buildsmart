// 🤖 AUTO-EMITTED by gen-max — attachChargeTo (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function fillCardFromCharge(sp, charge) {
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
export function attachChargeTo(supporters, supId, charge) { return attachChargeTo_ORIG(supporters, supId, charge); }
export function attachChargeTo_fromSource(sp, charge, supId) { return attachChargeTo_ORIG(fillCardFromCharge(sp, charge), supId, charge); }
