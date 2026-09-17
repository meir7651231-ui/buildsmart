// 🤖 AUTO-EMITTED by gen-max — icsEscape (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function stampUtc(now) {
    const p = (n) => String(n).padStart(2, '0');
    return (String(now.getUTCFullYear()) + p(now.getUTCMonth() + 1) + p(now.getUTCDate()) +
        'T' + p(now.getUTCHours()) + p(now.getUTCMinutes()) + p(now.getUTCSeconds()) + 'Z');
}
function basicLocal(d) {
    const p = (n, w = 2) => String(n).padStart(w, '0');
    return (String(d.getFullYear()) + p(d.getMonth() + 1) + p(d.getDate()) +
        'T' + p(d.getHours()) + p(d.getMinutes()) + p(d.getSeconds()));
}
function basicDate(iso) {
    return iso.replace(/-/g, '');
}
function nextIso(iso) {
    const d = new Date(iso + 'T12:00:00');
    d.setDate(d.getDate() + 1);
    const p = (n) => String(n).padStart(2, '0');
    return String(d.getFullYear()) + '-' + p(d.getMonth() + 1) + '-' + p(d.getDate());
}
function foldIcsLine(line) {
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
const enc = new TextEncoder();
export function icsEscape_ORIG(s) {
    return (s || '')
        .replace(/\\/g, '\\\\')
        .replace(/;/g, '\\;')
        .replace(/,/g, '\\,')
        .replace(/\r?\n/g, '\\n');
}
function buildIcs(occurrences, calName, now) {
    const lines = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//maor-system//he//',
        'CALSCALE:GREGORIAN',
        'METHOD:PUBLISH',
        'X-WR-CALNAME:' + icsEscape(calName),
    ];
    const stamp = stampUtc(now);
    for (const oc of occurrences) {
        lines.push('BEGIN:VEVENT');
        lines.push('UID:' + icsEscape(oc.uid));
        lines.push('DTSTAMP:' + stamp);
        // שעה שאינה HH:MM (ייבוא-JSON ידני, '9:00') ⇒ Invalid Date ⇒ VEVENT מושחת
        // שמפיל את **כל** הקובץ ביבואן. נפילה בטוחה: אירוע יום-שלם. (ביקורת 4.8.)
        // 🐛 נחיל-עמוק (13.8): '25:00'/'12:60' עברו את הרגקס אך יצרו Invalid Date —
        // כעת מאמתים גם את הערך בפועל (isNaN), לא רק את הפורמט.
        const parsedStart = oc.time && /^\d{2}:\d{2}$/.test(oc.time) ? new Date(oc.date + 'T' + oc.time + ':00') : null;
        if (parsedStart && !Number.isNaN(parsedStart.getTime())) {
            const end = new Date(parsedStart.getTime() + 3600e3); // שעה — כולל גלגול-חצות
            lines.push('DTSTART:' + basicLocal(parsedStart));
            lines.push('DTEND:' + basicLocal(end));
        }
        else {
            lines.push('DTSTART;VALUE=DATE:' + basicDate(oc.date));
            lines.push('DTEND;VALUE=DATE:' + basicDate(nextIso(oc.date)));
        }
        lines.push('SUMMARY:' + icsEscape(oc.title));
        if (oc.notes)
            lines.push('DESCRIPTION:' + icsEscape(oc.notes));
        if (oc.location)
            lines.push('LOCATION:' + icsEscape(oc.location));
        lines.push('END:VEVENT');
    }
    lines.push('END:VCALENDAR');
    return lines.flatMap(foldIcsLine).join('\r\n') + '\r\n';
}
export function icsEscape(s) { return icsEscape_ORIG(s); }
export function icsEscape_fromSource(occurrences, calName, now) { return icsEscape_ORIG(buildIcs(occurrences, calName, now)); }
