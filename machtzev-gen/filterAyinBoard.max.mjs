// 🤖 AUTO-EMITTED by gen-max — filterAyinBoard (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function filterAyinBoard_ORIG(items, q, status, stage) {
    const nq = normSearch(q);
    return items.filter((it) => {
        if (status === 'wait' && it.done)
            return false;
        if (status === 'done' && !it.done)
            return false;
        if (stage && it.stage !== stage)
            return false;
        if (!nq)
            return true;
        return normSearch([it.supporter, it.name, it.note].join(' ')).includes(nq);
    });
}
function ayinBoardItems(supporters) {
    const out = [];
    for (const sp of supporters) {
        if (!sp.ayin)
            continue;
        const a = { ...emptyAyin(), ...sp.ayin };
        for (const n of a.names) {
            if (!n.name.trim())
                continue;
            out.push({
                supporterId: sp.id,
                supporter: sp.name,
                phone: sp.phone || '',
                name: n.name,
                eyes: n.eyes !== '' && n.eyes != null ? +n.eyes : '',
                note: n.note || '',
                done: !!n.done,
                stage: a.stage,
            });
        }
    }
    return out;
}
export function filterAyinBoard(items, q, status, stage) { return filterAyinBoard_ORIG(items, q, status, stage); }
export function filterAyinBoard_fromSource(supporters, q, status, stage) { return filterAyinBoard_ORIG(ayinBoardItems(supporters), q, status, stage); }
