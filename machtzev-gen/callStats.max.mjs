// 🤖 AUTO-EMITTED by gen-max — callStats (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function callStats_ORIG(calls) {
    const list = calls ?? [];
    let noanswer = 0;
    for (const c of list)
        if (c.outcome === 'noanswer')
            noanswer++;
    return { total: list.length, last: list.length ? list[list.length - 1].at : '', noanswer };
}
function popCall(calls) {
    if (!calls || !calls.length)
        return calls;
    return calls.slice(0, -1);
}
export function callStats(calls) { return callStats_ORIG(calls); }
export function callStats_fromSource(calls) { return callStats_ORIG(popCall(calls)); }
