// 🤖 AUTO-EMITTED by gen-max — annualAllLines (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function donationsOfYear(donations, year) {
    return donations.filter((d) => (d.date || '').startsWith(year + '-')).sort((a, b) => a.date.localeCompare(b.date));
}
function money(amount, cur) {
    return (cur === '$' ? '$' : '₪') + amount.toLocaleString('he-IL');
}
export function annualAllLines_ORIG(orgName, orgTaxId, year, supporters, site) {
    const out = [];
    let count = 0;
    for (const sp of supporters) {
        if (donationsOfYear(sp.donations, year).length === 0)
            continue;
        if (count > 0)
            out.push('', '\f', '');
        out.push(...annualReportLines({ orgName, orgTaxId, supporterName: sp.name, payerId: sp.idNum, year, donations: sp.donations, site }));
        count++;
    }
    if (count === 0)
        out.push('אין תורמים עם תרומות בשנת ' + year + '.');
    return out;
}
function annualReportLines(inp) {
    const rows = donationsOfYear(inp.donations, inp.year);
    const ils = rows.filter((d) => d.cur !== '$').reduce((a, d) => a + (Number.isFinite(d.amount) ? d.amount : 0), 0);
    const usd = rows.filter((d) => d.cur === '$').reduce((a, d) => a + (Number.isFinite(d.amount) ? d.amount : 0), 0);
    const out = [
        '='.repeat(46),
        '        דוח תרומות שנתי — שנת ' + inp.year,
        '='.repeat(46),
        '',
        'הארגון: ' + inp.orgName,
        ...(inp.orgTaxId ? ['מס׳ עמותה/מלכ"ר: ' + inp.orgTaxId] : []),
        'התורם/ת: ' + inp.supporterName + (inp.payerId ? ' · ת"ז ' + inp.payerId : ''),
        '',
        '-'.repeat(46),
    ];
    if (rows.length === 0) {
        out.push('אין תרומות רשומות בשנת ' + inp.year + '.');
    }
    else {
        for (const d of rows) {
            out.push(d.date + '  ' + money(d.amount, d.cur).padStart(12) + (d.rid ? '  קבלה ' + d.rid : '') + (d.designation ? '  · ' + d.designation : ''));
        }
    }
    out.push('-'.repeat(46));
    out.push('סה"כ ' + rows.length + ' תרומות בשנת ' + inp.year);
    if (ils > 0)
        out.push('סה"כ בשקלים: ' + money(ils));
    if (usd > 0)
        out.push('סה"כ בדולרים: ' + money(usd, '$'));
    if (inp.orgTaxId) {
        out.push('');
        out.push('לארגון אישור מוסד ציבורי לעניין תרומות לפי סעיף 46 לפקודת מס הכנסה.');
        out.push('דוח-ריכוז זה אינו קבלה — הקבלות המקוריות צוינו לצד כל תרומה.');
    }
    if (inp.site) {
        out.push('');
        out.push(inp.site);
    }
    return out;
}
export function annualAllLines(orgName, orgTaxId, year, supporters) { return annualAllLines_ORIG(orgName, orgTaxId, year, supporters); }
export function annualAllLines_fromSource(inp, orgTaxId, year, supporters) { return annualAllLines_ORIG(annualReportLines(inp), orgTaxId, year, supporters); }
