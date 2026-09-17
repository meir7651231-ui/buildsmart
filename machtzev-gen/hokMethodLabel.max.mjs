// 🤖 AUTO-EMITTED by gen-max — hokMethodLabel (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function supIls(sp) {
    return (sp.ils || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? 0 : h.a), 0);
}
function supUsd(sp) {
    return (sp.usd || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? h.a : 0), 0);
}
export function hokMethodLabel_ORIG(m) {
    if (m === 'bank')
        return 'הו"ק בנקאית';
    if (m === 'card')
        return 'אשראי בסליקה';
    if (m === 'cash')
        return 'מזומן חודשי';
    return m || 'אחר';
}
function totalLabel(sp) {
    const i = supIls(sp);
    const u = supUsd(sp);
    const ils = i ? '₪' + i.toLocaleString('he-IL') : '';
    const usd = u ? '$' + u.toLocaleString('he-IL') : '';
    return ils && usd ? ils + ' + ' + usd : ils || usd || '—';
}
export function hokMethodLabel(m) { return hokMethodLabel_ORIG(m); }
export function hokMethodLabel_fromSource(sp) { return hokMethodLabel_ORIG(totalLabel(sp)); }
