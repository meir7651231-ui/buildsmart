// 🤖 AUTO-EMITTED by gen-max — foldIcsLine (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const enc = new TextEncoder();
export function foldIcsLine_ORIG(line) {
    const out = [];
    let cur = '';
    let curBytes = 0;
    let limit = 75; // השורה הראשונה; שורות-המשך: 74 + רווח מוביל
    for (const ch of line) {
        const b = enc.encode(ch).length;
        if (curBytes + b > limit) {
            out.push(cur);
            cur = ' ' + ch;
            curBytes = 1 + b;
            limit = 75;
        }
        else {
            cur += ch;
            curBytes += b;
        }
    }
    if (cur)
        out.push(cur);
    return out.length ? out : [''];
}
function icsEscape(s) {
    return (s || '')
        .replace(/\\/g, '\\\\')
        .replace(/;/g, '\\;')
        .replace(/,/g, '\\,')
        .replace(/\r?\n/g, '\\n');
}
export function foldIcsLine(line) { return foldIcsLine_ORIG(line); }
export function foldIcsLine_fromSource(s) { return foldIcsLine_ORIG(icsEscape(s)); }
