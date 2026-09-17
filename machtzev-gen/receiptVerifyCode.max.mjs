// 🤖 AUTO-EMITTED by gen-max — receiptVerifyCode (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function receiptLines(o) {
    const cur = o.currency || '₪';
    const d = new Date(o.date.slice(0, 10) + 'T12:00:00');
    const gregorian = isNaN(d.getTime()) ? o.date : d.toLocaleDateString('he-IL');
    const heb = hebDateFull(o.date);
    // קבלת סעיף 46 פורמלית — פריסה רשמית עם סכום-במילים, ת"ז ונוסח §46.
    if (o.taxReceipt) {
        const curSym = cur === '$' ? '$' : '₪';
        const words = amountInWords(o.amount, cur === '$' ? '$' : '₪');
        return [
            ...(o.mark === false ? [] : [o.copy ? 'העתק נאמן למקור' : 'מקור']),
            (o.orgName || 'מאור החסד'),
            o.orgTaxId ? 'מס׳ עמותה/מלכ"ר: ' + o.orgTaxId : '',
            '',
            'קבלה על תרומה — לפי סעיף 46 לפקודת מס הכנסה',
            'קבלה מס׳: ' + o.rid,
            ...(o.verify ? ['קוד-אימות: ' + receiptVerifyCode(o.rid, o.amount, cur, o.date)] : []),
            'תאריך: ' + (heb ? heb + ' · ' : '') + gregorian,
            '',
            'התקבל בתודה מאת: ' + o.payer,
            o.payerId ? 'ת"ז / ח"פ: ' + o.payerId : '',
            'סכום: ' + curSym + o.amount.toLocaleString('he-IL'),
            'במילים: ' + words,
            o.method ? 'אמצעי תשלום: ' + o.method : '',
            'עבור: ' + o.forWhat,
            '',
            'תרומה זו מוכרת לצורכי מס לפי סעיף 46 לפקודת מס הכנסה.',
            'קבלה זו מהווה אסמכתא לתרומה שהתקבלה.',
            '',
            'בכבוד רב,',
            (o.signatory ? o.signatory : '') + '  ______________________',
            'חתימה וחותמת',
            o.site ? 'אתר: ' + o.site : '',
        ];
    }
    // תיקון (swarm-audit): סדרת S- (אישורי-תשלום של החנות — shopReceiptSeq, לא קבלת
    // מס) הוצגה בכותרת "קבלה" — מצג-שווא כשההסתייגות קבורה באמצע המסמך. S- מקבל
    // "אישור תשלום"; כל rid אחר (כולל R-/D- מסחריים בלי §46) נשאר ביט-זהה.
    const isShopConfirmation = o.rid.startsWith('S-');
    return [
        ...(o.mark === false ? [] : [o.copy ? 'העתק נאמן למקור' : 'מקור']),
        (isShopConfirmation ? 'אישור תשלום — ' : 'קבלה — ') + (o.orgName || 'מאור החסד'),
        (isShopConfirmation ? 'אישור מס׳: ' : 'קבלה מס׳: ') + o.rid,
        ...(o.verify ? ['קוד-אימות: ' + receiptVerifyCode(o.rid, o.amount, cur, o.date)] : []),
        // תאריך עברי + לועזי, כמו באב-טיפוס
        'תאריך: ' + (heb ? heb + ' · ' : '') + gregorian,
        'התקבל מאת: ' + o.payer,
        'סכום: ' + cur + o.amount,
        o.method ? 'אמצעי תשלום: ' + o.method : '',
        'עבור: ' + o.forWhat,
        // סיכום העסקה — verbatim מלגאסי receipt() (legacy:1264-1265)
        o.summary
            ? 'סה"כ עסקה: ₪' + o.summary.totalDue + ' · שולם עד כה: ₪' + o.summary.paidSoFar + ' · יתרה: ₪' + o.summary.balance
            : '',
        o.summary?.nextDate
            ? 'תשלום הבא: ' + hebDateFull(o.summary.nextDate) + ' · ' + hebrewLocaleDate(o.summary.nextDate)
            : '',
        o.site ? 'אתר: ' + o.site : '',
        'תודה על תמיכתכם',
    ];
}
function esc(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
function hebrewLocaleDate(iso) {
    const d = new Date(iso.slice(0, 10) + 'T12:00:00');
    return isNaN(d.getTime()) ? iso : d.toLocaleDateString('he-IL');
}
export function receiptVerifyCode_ORIG(rid, amount, currency, date) {
    const s = rid + '|' + amount + '|' + (currency || '₪') + '|' + date.slice(0, 10);
    let h = 0x811c9dc5;
    for (let i = 0; i < s.length; i++) {
        h ^= s.charCodeAt(i);
        h = Math.imul(h, 0x01000193) >>> 0;
    }
    const code = h.toString(36).toUpperCase().padStart(7, '0').slice(-6);
    return code.slice(0, 3) + '-' + code.slice(3);
}
function receiptHtml(o) {
    const lines = receiptLines(o).filter((x) => x !== '');
    const [first, ...rest] = lines;
    const body = rest.map((ln) => '<div class="ln">' + esc(ln) + '</div>').join('\n');
    return ('<!doctype html><html dir="rtl" lang="he"><head><meta charset="utf-8">' +
        '<title>' + esc('קבלה ' + o.rid) + '</title>' +
        '<style>' +
        'body{font-family:"Segoe UI",Arial,"Noto Sans Hebrew",sans-serif;color:#111;margin:0;padding:32px;direction:rtl}' +
        '.sheet{max-width:520px;margin:0 auto;border:1px solid #bbb;border-radius:10px;padding:28px 32px}' +
        '.mark{font-size:12px;letter-spacing:.08em;color:#555;text-align:left}' +
        '.ln{font-size:14.5px;line-height:1.9}' +
        '.ln:first-of-type{font-size:19px;font-weight:700;margin-bottom:6px}' +
        '@media print{body{padding:0}.sheet{border:none}}' +
        '</style></head><body><div class="sheet">' +
        '<div class="mark">' + esc(first) + '</div>' +
        body +
        '</div></body></html>');
}
export function receiptVerifyCode(rid, amount, currency, date) { return receiptVerifyCode_ORIG(rid, amount, currency, date); }
export function receiptVerifyCode_fromSource(o, amount, currency, date) { return receiptVerifyCode_ORIG(receiptHtml(o), amount, currency, date); }
