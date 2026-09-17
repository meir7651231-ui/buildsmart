// 🤖 AUTO-EMITTED by gen-max — latestTeamAt (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function sortTeamMsgs(msgs) {
    return [...msgs].sort((a, b) => (a.at < b.at ? -1 : a.at > b.at ? 1 : 0));
}
export function latestTeamAt(msgs) { return latestTeamAt_ORIG(msgs); }
export function latestTeamAt_fromSource(msgs) { return latestTeamAt_ORIG(sortTeamMsgs(msgs)); }
