// 🤖 AUTO-EMITTED by gen-max — studentHistoryText (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function academicYearLabel(startIso) {
    if (!startIso)
        return '';
    const d = atNoon(startIso);
    // מתי חלה ה-31.12 שבתוך שנת-הלימודים הזאת:
    // חוג שנפתח 1.9.2026 (September=8) ⇒ 31.12.2026 = תוך-השנה, שיין ל-תשפ״ז.
    // חוג שנפתח 1.3.2026 (March=2) ⇒ שנת-הלימודים ההיא נפתחה 1.9.2025 ⇒ 31.12.2025.
    const yy = d.getMonth() >= 8 ? d.getFullYear() : d.getFullYear() - 1;
    return gemYear(hebPartsOfIso(`${yy}-12-31`).year);
}
function enrollSummary(e) {
    const presents = (e.presents ?? []).length;
    const absences = (e.absences ?? []).length;
    const noshow = (e.absences ?? []).filter((a) => a.noshow).length;
    const lastPresent = (e.presents ?? []).slice().sort().slice(-1)[0] ?? '';
    return {
        presents,
        absences,
        noshow,
        balance: payBal(e),
        paid: paidOf(e),
        statusLabel: STATUS_LABEL[e.status] ?? '',
        lastPresent,
    };
}
function atNoon(iso) {
    return new Date(`${iso}T12:00:00`);
}
const STATUS_LABEL = {
    active: 'פעיל',
    paused: 'מושהה',
    ended: 'הסתיים',
    wait: 'רשימת-המתנה',
};
export function studentHistoryText_ORIG(entries) {
    return entries
        .map((h) => {
        const yr = h.yearLabel ? `[${h.yearLabel}] ` : '';
        const grp = h.group ? ` · ${h.group}` : '';
        return `${yr}${h.courseName}${grp} — נוכחות ${h.summary.presents}, חיסורים ${h.summary.absences} · ${h.summary.statusLabel}`;
    })
        .join('\n');
}
function studentHistory(db, memberId) {
    // מזהי-שיבוצים שמישהו התחדש אליהם (יעד-רישום) — לזיהוי fromRenewal.
    const renewTargetIds = new Set(db.enrollments.map((e) => e.renewedToId).filter(Boolean));
    const out = [];
    for (const e of db.enrollments) {
        if (e.memberId !== memberId)
            continue;
        const course = db.courses.find((c) => c.id === e.courseId) ?? null;
        const start = course?.start ?? '';
        out.push({
            enrollment: e,
            courseId: e.courseId,
            courseName: course?.name ?? '—',
            group: e.group || '',
            yearLabel: course?.year || (start ? academicYearLabel(start) : ''),
            start,
            end: course?.end ?? '',
            summary: enrollSummary(e),
            fromRenewal: renewTargetIds.has(e.id),
            renewedForward: !!e.renewedToId,
        });
    }
    // מהחדש לישן — תאריך-פתיחת-החוג יורד, ואז enrolledAt יורד.
    out.sort((a, b) => (b.start || '').localeCompare(a.start || '') || (b.enrollment.enrolledAt || '').localeCompare(a.enrollment.enrolledAt || ''));
    return out;
}
export function studentHistoryText(entries) { return studentHistoryText_ORIG(entries); }
export function studentHistoryText_fromSource(db, memberId) { return studentHistoryText_ORIG(studentHistory(db, memberId)); }
