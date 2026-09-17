// 🤖 AUTO-EMITTED by gen-max — parseAyinSheet (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function normName(s) {
    return normSearch(s).replace(/\s/g, '');
}
function stageLabel(cfg, stage) {
    return termOf(cfg, 'ayin.stage.' + stage, STAGE_FALLBACK[stage]);
}
const STAGE_FALLBACK = {
    new: 'חדש',
    lead: 'בהכנה',
    eyes: 'רישום',
    answer: 'מסירה',
    done: 'הושלם',
};
export function parseAyinSheet_ORIG(rows, supporters) {
    if (rows.length < 2)
        return { upds: [], miss: 0, error: 'הקובץ ריק או לא בפורמט CSV' };
    const clean = (x) => (x ?? '').replace(/\s+/g, ' ').trim();
    const header = (rows[0] ?? []).map((h) => clean(h));
    const hIdx = (keys) => header.findIndex((h) => keys.some((k) => h.includes(k)));
    const iSup = hIdx(['תומכת', 'תומך']);
    const iNm = hIdx(['שם למסירה', 'שם לעופרת', 'שם']);
    const iEyes = hIdx(['עיניים']);
    const iDone = hIdx(['נמסר']);
    const iPaid = hIdx(['שולם', 'תשלום']);
    const iAns = hIdx(['תשובה', 'הערה']);
    const iLead = hIdx(['עופרת']);
    if (iNm < 0 || iEyes < 0) {
        return { upds: [], miss: 0, error: 'חסרות עמודות "שם למסירה" ו/או "כמה עיניים"' };
    }
    const yes = (v) => /כן|yes|✓|v|שולם/i.test(v);
    const upds = [];
    let miss = 0;
    for (let r = 1; r < rows.length; r++) {
        const row = rows[r] ?? [];
        const supN = clean(iSup >= 0 ? row[iSup] : '');
        const nm = clean(row[iNm]);
        if (!nm)
            continue;
        const raw = clean(row[iEyes]);
        const eyes = /^\d+$/.test(raw) ? +raw : null;
        const doneRaw = clean(iDone >= 0 ? row[iDone] : '');
        const paidRaw = iPaid >= 0 ? clean(row[iPaid]) : '';
        const ansRaw = iAns >= 0 ? clean(row[iAns]) : '';
        const leadRaw = iLead >= 0 ? clean(row[iLead]) : '';
        const sp = supporters.find((x) => (!supN || normName(x.name) === normName(supN)) &&
            (x.ayin?.names ?? []).some((n) => normName(n.name) === normName(nm)));
        if (!sp) {
            miss++;
            continue;
        }
        const rec = (sp.ayin?.names ?? []).find((n) => normName(n.name) === normName(nm));
        if (eyes == null && !doneRaw && !paidRaw && !ansRaw && !leadRaw)
            continue;
        upds.push({
            supporterId: sp.id,
            nameId: rec.id,
            eyes,
            done: doneRaw ? yes(doneRaw) : null,
            paid: paidRaw ? yes(paidRaw) : null,
            answer: ansRaw || null,
            lead: leadRaw ? yes(leadRaw) : null,
        });
    }
    return { upds, miss };
}
function ayinAdvanceLabel(cfg, a) {
    const st = a.stage;
    if (st === 'new')
        return stageLabel(cfg, 'lead') + ' ←';
    if (st === 'lead')
        return '✓ אישור — ' + stageLabel(cfg, 'lead');
    if (st === 'eyes')
        return stageLabel(cfg, 'answer') + ' ←';
    if (st === 'answer')
        return a.answerPushed ? '✓ ' + stageLabel(cfg, 'done') : '📞 דחיפה ללוח';
    return '';
}
export function parseAyinSheet(rows, supporters) { return parseAyinSheet_ORIG(rows, supporters); }
export function parseAyinSheet_fromSource(cfg, a, supporters) { return parseAyinSheet_ORIG(ayinAdvanceLabel(cfg, a), supporters); }
