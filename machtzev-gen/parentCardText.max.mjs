// 🤖 AUTO-EMITTED by gen-max — parentCardText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function ddmm(iso) {
    return iso.slice(8, 10) + '/' + iso.slice(5, 7);
}
function isoOf(d) {
    const p = (n) => String(n).padStart(2, '0');
    return d.getFullYear() + '-' + p(d.getMonth() + 1) + '-' + p(d.getDate());
}
export function parentCardText_ORIG(card, orgName) {
    const lines = [];
    lines.push('👋 שלום, כאן ' + (orgName || 'העמותה') + '.');
    lines.push('סיכום עבור ' + card.childName + (card.familyName ? ' · משפחת ' + card.familyName : '') + ':');
    lines.push('');
    if (card.courses.length === 0) {
        lines.push('אין חוגים פעילים כרגע.');
    }
    else {
        for (const l of card.courses) {
            const parts = ['• ' + l.courseName];
            if (l.attendancePct != null)
                parts.push('נוכחות ' + l.attendancePct + '%');
            if (l.absences > 0)
                parts.push(l.absences + ' חיסורים');
            if (l.balance > 0)
                parts.push('יתרה ₪' + l.balance.toLocaleString('he-IL'));
            if (l.nextSession)
                parts.push('מפגש קרוב ' + ddmm(l.nextSession));
            lines.push(parts.join(' · '));
        }
    }
    if (card.totalBalance > 0) {
        lines.push('');
        lines.push('💳 יתרת-תשלום כוללת: ₪' + card.totalBalance.toLocaleString('he-IL'));
    }
    if (card.makeups.length > 0) {
        lines.push('🔁 השלמות ממתינות: ' + card.makeups.length);
    }
    return lines.join('\n');
}
function parentCard(db, memberId, now = new Date()) {
    let childName = '—';
    let familyName = '';
    for (const f of db.families) {
        const m = f.members.find((x) => x.id === memberId);
        if (m) {
            childName = m.first;
            familyName = f.name;
            break;
        }
    }
    const courses = [];
    for (const e of db.enrollments) {
        if (e.memberId !== memberId || e.status === 'ended' || e.status === 'wait')
            continue;
        const c = db.courses.find((x) => x.id === e.courseId);
        const present = (e.presents ?? []).length;
        const absences = e.absences.length;
        const denom = present + absences;
        // חוג שהסתיים (c.end עבר) ⇒ אין מפגש-קרוב אמיתי גם אם השיבוץ נשאר 'active'
        const ended = !!(c && c.end && c.end < isoOf(now));
        const next = c && !ended ? nextSessionDate(c, now) : null;
        courses.push({
            courseId: e.courseId,
            courseName: c?.name ?? '—',
            present,
            absences,
            // מודל-החיסורים-ההפוך: presents=[] כברירת-מחדל ⇒ present 0 עם חיסורים היה מציג
            // "0%" שקרי להורה. אחוז אמין רק כשיש נוכחויות מתועדות; אחרת "—" (null).
            attendancePct: present > 0 ? Math.round((present / denom) * 100) : null,
            balance: payBal(e),
            nextSession: next ? isoOf(next) : null,
        });
    }
    const makeups = pendingMakeups(db.enrollments).filter((m) => m.memberId === memberId);
    return {
        memberId,
        childName,
        familyName,
        courses,
        totalBalance: courses.reduce((s, l) => s + l.balance, 0),
        makeups,
    };
}
export function parentCardText(card, orgName) { return parentCardText_ORIG(card, orgName); }
export function parentCardText_fromSource(db, memberId, now, orgName) { return parentCardText_ORIG(parentCard(db, memberId, now), orgName); }
