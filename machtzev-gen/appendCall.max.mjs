// 🤖 AUTO-EMITTED by gen-max — appendCall (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const CALL_LOG_CAP = 200;
export function appendCall_ORIG(calls, outcome, iso) {
    if (outcome === 'skip')
        return calls;
    const next = [...(calls ?? []), { at: iso, outcome }];
    return next.length > CALL_LOG_CAP ? next.slice(next.length - CALL_LOG_CAP) : next;
}
function popCall(calls) {
    if (!calls || !calls.length)
        return calls;
    return calls.slice(0, -1);
}
export function appendCall(calls, outcome, iso) { return appendCall_ORIG(calls, outcome, iso); }
export function appendCall_fromSource(calls, outcome, iso) { return appendCall_ORIG(popCall(calls), outcome, iso); }
