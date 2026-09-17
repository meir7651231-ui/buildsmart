// 🤖 AUTO-EMITTED by gen-max — segulaReminders (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SEGULA_OFFSETS = [1, 7, 21, 35, 40];
export function segulaReminders_ORIG(startIso, offsets = SEGULA_OFFSETS) {
    const base = new Date(`${startIso}T12:00:00`);
    const max = Math.max(...offsets);
    return offsets.map((day) => {
        const d = new Date(base);
        d.setDate(d.getDate() + day);
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const dd = String(d.getDate()).padStart(2, '0');
        return { day, date: `${y}-${m}-${dd}`, final: day === max };
    });
}
function segulaTitle(name, r, target) {
    return (r.final ? '🎯 סיום סגולה' : '🕯 סגולה') + ' — ' + (name || '') + ' · יום ' + r.day + '/' + target;
}
export function segulaReminders(startIso, offsets) { return segulaReminders_ORIG(startIso, offsets); }
export function segulaReminders_fromSource(name, r, target, offsets) { return segulaReminders_ORIG(segulaTitle(name, r, target), offsets); }
