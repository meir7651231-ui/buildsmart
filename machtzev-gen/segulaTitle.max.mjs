// 🤖 AUTO-EMITTED by gen-max — segulaTitle (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function segulaTitle_ORIG(name, r, target) {
    return (r.final ? '🎯 סיום סגולה' : '🕯 סגולה') + ' — ' + (name || '') + ' · יום ' + r.day + '/' + target;
}
export function segulaTitle(name, r, target) { return segulaTitle_ORIG(name, r, target); }
export function segulaTitle_fromSource(note, target, r) { return segulaTitle_ORIG(stripSegulaNote(note, target), r, target); }
