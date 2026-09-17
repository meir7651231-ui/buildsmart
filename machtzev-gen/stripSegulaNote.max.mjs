// 🤖 AUTO-EMITTED by gen-max — stripSegulaNote (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function segulaTitle(name, r, target) {
    return (r.final ? '🎯 סיום סגולה' : '🕯 סגולה') + ' — ' + (name || '') + ' · יום ' + r.day + '/' + target;
}
export function stripSegulaNote(note, target) { return stripSegulaNote_ORIG(note, target); }
export function stripSegulaNote_fromSource(name, r, target) { return stripSegulaNote_ORIG(segulaTitle(name, r, target), target); }
