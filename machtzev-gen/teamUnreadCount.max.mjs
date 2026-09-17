// 🤖 AUTO-EMITTED by gen-max — teamUnreadCount (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function sortTeamMsgs(msgs) {
    return [...msgs].sort((a, b) => (a.at < b.at ? -1 : a.at > b.at ? 1 : 0));
}
export function teamUnreadCount(msgs, lastReadIso, myEmail) { return teamUnreadCount_ORIG(msgs, lastReadIso, myEmail); }
export function teamUnreadCount_fromSource(msgs, lastReadIso, myEmail) { return teamUnreadCount_ORIG(sortTeamMsgs(msgs), lastReadIso, myEmail); }
