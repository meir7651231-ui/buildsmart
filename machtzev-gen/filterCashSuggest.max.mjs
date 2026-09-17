// 🤖 AUTO-EMITTED by gen-max — filterCashSuggest (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function filterCashSuggest_ORIG(list, q, max = 8) {
    const words = (q || '').trim().toLowerCase().split(/\s+/u).filter(Boolean);
    if (!words.length)
        return [];
    return list.filter((s) => { const n = s.name.toLowerCase(); return words.every((w) => n.includes(w)); }).slice(0, max);
}
function filterCashSuggest(list, q, max) { return filterCashSuggest_ORIG(list, q, max); }
export function filterCashSuggest_fromSource(courses, q, max) { return filterCashSuggest_ORIG(cashSuggestions(courses), q, max); }
