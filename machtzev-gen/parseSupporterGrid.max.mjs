// 🤖 AUTO-EMITTED by gen-max — parseSupporterGrid (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const SUP_NAME_KEYS = ['שם', 'תורם'];
function excelSerialToIso(serial) {
    if (!isFinite(serial) || serial < 1)
        return '';
    const dt = new Date(Math.round((serial - 25569) * 86400000));
    if (isNaN(dt.getTime()))
        return '';
    const mo = String(dt.getUTCMonth() + 1).padStart(2, '0');
    const da = String(dt.getUTCDate()).padStart(2, '0');
    return `${dt.getUTCFullYear()}-${mo}-${da}`;
}
export function parseSupporterGrid_ORIG(rows) {
    if (!rows.length)
        return [];
    // שורת-הכותרות = הראשונה (מבין 15 העליונות) שיש בה עמודת-שם ("שם"/"תורם").
    const hdrIdx = rows
        .slice(0, 15)
        .findIndex((r) => r.some((h) => SUP_NAME_KEYS.some((k) => (h ?? '').includes(k))));
    const header = (hdrIdx >= 0 ? rows[hdrIdx] : rows[0]).map((h) => (h ?? '').trim());
    const find = (keys) => header.findIndex((h) => keys.some((k) => h.includes(k)));
    let iName = find(SUP_NAME_KEYS);
    let iPhone = find(['טלפון', 'נייד']);
    let iEmail = find(['אימייל', 'מייל', 'email']);
    let iId = find(['ת"ז', 'תז', 'זהות']);
    let iAddr = find(['כתובת']);
    let iCat = find(['קטגוריה']);
    let iFor = find(['עבור', 'ייעוד']);
    // קובץ מסוף-הסליקה (ExportHistory, 9.8): עמודות סכום/תאריך-עסקה/מטבע ⇒
    // כל שורה נושאת גם עסקה — נכנסת כהיסטוריה-ללא-קבלה (הכרעת-בעלים).
    const iAmount = find(['סכום']);
    const iTxDate = find(['תאריך']);
    const iCur = find(['מטבע']);
    // 13.8 — כל שאר עמודות-הסליקה נקלטות למטא-דאטה של רשומת-ההיסטוריה.
    const iRef = find(['אסמכתא']);
    const iTxn = find(['מספר עסקה']);
    const iReceipt = find(['מספר קבלה']);
    const iBrand = find(['מותג']);
    const iLast4 = find(['4 ספרות', 'ספרות']);
    const iClearer = find(['חברה סולקת', 'סולק']);
    const iPays = find(['תשלומים']);
    const iStatus = find(['סטטוס']);
    let start = hdrIdx >= 0 ? hdrIdx + 1 : 1;
    if (iName < 0) {
        // אין שורת כותרות מזוהה — סדר עמודות קבוע
        iName = 0;
        iPhone = 1;
        iEmail = 2;
        iId = 3;
        iAddr = 4;
        iCat = 5;
        iFor = 6;
        start = 0;
    }
    const g = (r, i) => (i >= 0 ? (r[i] ?? '').trim() : '');
    const out = [];
    for (const r of rows.slice(start)) {
        const name = g(r, iName);
        if (!name)
            continue;
        const row = {
            name,
            phone: g(r, iPhone),
            email: g(r, iEmail),
            idNum: g(r, iId),
            address: g(r, iAddr),
            cat: g(r, iCat),
            forWho: g(r, iFor),
        };
        if (iAmount >= 0 && iTxDate >= 0) {
            const amount = Math.round(Number(g(r, iAmount).replace(/[^\d.-]/g, '')) * 100) / 100;
            // 'תאריך עסקה' מגיע עם שעה ("09/08/26 00:36") — התאריך בלבד. אם התא מספר-
            // סריאל של Excel (יצוא ששומר תאריך כמספר) — parseAnyDate נכשל ⇒ המרה מסריאל.
            const rawDate = g(r, iTxDate).split(' ')[0];
            const d = parseAnyDate(rawDate) || (/^\d+(\.\d+)?$/.test(rawDate) ? excelSerialToIso(Number(rawDate)) : '');
            if (isFinite(amount) && amount > 0 && d) {
                // 13.8 — מטא-דאטה: רק שדות שקיימים בפועל (נשארים undefined אחרת).
                const pays = Number(g(r, iPays));
                row.hist = [
                    {
                        d,
                        a: amount,
                        ...(/דולר|\$|usd/i.test(g(r, iCur)) ? { c: '$' } : {}),
                        ...(g(r, iRef) ? { ref: g(r, iRef) } : {}),
                        ...(g(r, iTxn) ? { txn: g(r, iTxn) } : {}),
                        ...(g(r, iReceipt) ? { receipt: g(r, iReceipt) } : {}),
                        ...(g(r, iBrand) ? { brand: g(r, iBrand) } : {}),
                        ...(g(r, iLast4) ? { last4: g(r, iLast4) } : {}),
                        ...(g(r, iClearer) ? { clearer: /נדרים|nedarim/i.test(g(r, iClearer)) ? 'נדרים' : g(r, iClearer) } : {}),
                        ...(iPays >= 0 && isFinite(pays) && pays > 0 ? { pays } : {}),
                        ...(g(r, iStatus) ? { status: g(r, iStatus) } : {}),
                    },
                ];
            }
        }
        // 13.8 (בקשת-בעלים) — הוסר אוטומט-העי"ן: קטגוריה "הסרת עין הרע" היא ייעוד-
        // תרומה, לא הוראה לפתוח תיק-מעקב. תיק-עי"ן נפתח רק כשצוין במפורש (ידנית
        // בכרטיס/בלוח-העי"ן), לא מזיהוי-מחרוזת בקטגוריה. (ביטול הכרעת-9.8.)
        out.push(row);
    }
    return out;
}
function parseSupporterGrid(rows) { return parseSupporterGrid_ORIG(rows); }
export function parseSupporterGrid_fromSource(sup) { return parseSupporterGrid_ORIG(supporterPurposes(sup)); }
