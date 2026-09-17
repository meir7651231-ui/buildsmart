// 🤖 AUTO-EMITTED by gen-max — campaignCsvRows (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const OUTCOME_LABELS = {
    donated: 'תרם/ה',
    noanswer: 'לא ענה',
    refused: 'סירב/ה',
    callback: 'לחזור',
    done: 'טופל',
    skip: 'דילוג',
};
export function campaignCsvRows_ORIG(c, nameOf) {
    const rows = [['שם', 'תוצאה', 'הערה', 'מתי']];
    for (const e of c.log) {
        rows.push([nameOf(e.id), OUTCOME_LABELS[e.outcome], e.note ?? '', e.at]);
    }
    return rows;
}
function startCampaign(name, ids, iso) {
    const seen = new Set();
    const queue = [];
    for (const id of ids) {
        if (!id || seen.has(id))
            continue;
        seen.add(id);
        queue.push(id);
    }
    return { name, startedAt: iso, queue, total: queue.length, log: [] };
}
export function campaignCsvRows(c, nameOf) { return campaignCsvRows_ORIG(c, nameOf); }
export function campaignCsvRows_fromSource(name, ids, iso, nameOf) { return campaignCsvRows_ORIG(startCampaign(name, ids, iso), nameOf); }
