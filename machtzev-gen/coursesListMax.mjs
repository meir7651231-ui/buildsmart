function sheetSummary(roster, dateIso) {
    return { present: roster.filter((e) => (e.presents ?? []).includes(dateIso)).length, total: roster.length };
}
function debtors(enrollments) {
    return enrollments
        .filter((e) => e.status !== 'ended' && e.status !== 'wait')
        .map((e) => ({ e, bal: payBal(e) }))
        .filter((x) => x.bal > 0)
        .sort((a, b) => b.bal - a.bal);
}
function punchLowList(enrollments, threshold = 2) {
    return enrollments
        .filter((e) => e.status === 'active' && e.plan === 'punch')
        .map((e) => ({ e, left: Math.max(0, e.purchased - e.used) }))
        .filter((x) => x.left <= threshold)
        .sort((a, b) => a.left - b.left);
}
function dropoutRisk(enrollments, minAbs = 3) {
    return enrollments
        .filter((e) => e.status === 'active')
        .map((e) => ({ e, absences: e.absences.length }))
        .filter((x) => x.absences >= minAbs)
        .sort((a, b) => b.absences - a.absences);
}
function pendingMakeups(enrollments, courseId) {
    const out = [];
    for (const e of enrollments) {
        if (e.status === 'ended' || e.status === 'wait')
            continue;
        if (courseId && e.courseId !== courseId)
            continue;
        for (const a of e.absences) {
            if (!a.makeup)
                continue;
            out.push({ enrollmentId: e.id, memberId: e.memberId, courseId: e.courseId, date: a.date, reason: a.reason, makeupDate: a.makeupDate });
        }
    }
    return out.sort((x, y) => (x.makeupDate ? 1 : 0) - (y.makeupDate ? 1 : 0) || x.date.localeCompare(y.date));
}
function waitlistFor(enrollments, courseId) {
    return enrollments
        .filter((e) => e.courseId === courseId && e.status === 'wait')
        .sort((a, b) => (a.enrolledAt || '').localeCompare(b.enrolledAt || ''));
}
function sheetRoster(enrollments, courseId) {
    return enrollments.filter((e) => e.courseId === courseId && e.status !== 'ended' && e.status !== 'wait');
}
function dropoutInsights(enrollments, minAbs = 3) {
    return dropoutRisk(enrollments, minAbs)
        .map(({ e, absences }) => {
        const debt = payBal(e);
        const base = Math.min(100, 50 + (absences - minAbs) * 12);
        const score = Math.min(100, base + (debt > 0 ? 10 : 0));
        const reasonParts = [absences + ' חיסורים שנצברו'];
        if (debt > 0)
            reasonParts.push('יתרת-חוב פתוחה ₪' + debt.toLocaleString('he-IL'));
        return {
            enrollmentId: e.id,
            memberId: e.memberId,
            courseId: e.courseId,
            absences,
            debt,
            score,
            reason: reasonParts.join(' · '),
        };
    })
        .sort((a, b) => b.score - a.score);
}
function enrollmentPaidStatus(e) {
    if (e.paidFull)
        return 'paid';
    const due = e.totalDue || 0;
    if (due > 0)
        return payBal(e) === 0 ? 'paid' : paidOf(e) > 0 ? 'partial' : 'unpaid';
    return 'unpaid';
}
function payBal(e) {
    return Math.max(0, (e.totalDue || 0) + (e.carryBalance || 0) - paidOf(e));
}
function paidOf(e) {
    return (e.payments || []).reduce((a, p) => a + (Number.isFinite(p.amount) ? p.amount : 0), 0);
}
function enrollStatusMeta(e) {
    if (e.status === 'paused')
        return { label: 'מוקפא', bg: '#fdf1d4', c: '#9a6414' };
    if (e.status === 'ended')
        return { label: 'הסתיים', bg: '#eceae2', c: '#8b8474' };
    // ⏳ רשימת-המתנה — קודם נפלה ל"פעיל" והטעתה (למשל בכרטיס ⚙ ניהול-שיבוץ)
    if (e.status === 'wait')
        return { label: 'רשימת-המתנה ⏳', bg: '#e7edf5', c: '#3a5a86' };
    return { label: 'פעיל', bg: '#e4f5ea', c: '#12803c' };
}
function renewOf(e) {
    return e.renew ?? '';
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
const STATUS_LABEL = {
    active: 'פעיל',
    paused: 'מושהה',
    ended: 'הסתיים',
    wait: 'רשימת-המתנה',
};
function planLabelOf(e) {
    let s = e.plan === 'punch' ? 'כרטיסייה · ' + e.purchased : planWord(e.plan);
    if (e.status === 'paused')
        s += ' · מוקפא ⏸';
    else if (e.status === 'ended')
        s += ' · הסתיים';
    if (e.absences.length)
        s += ' · ' + e.absences.length + ' חיס׳';
    const bal = payBal(e);
    if (bal > 0)
        s += ' · 💳 ₪' + bal;
    return s;
}
function planWord(model) {
    return model === 'punch'
        ? 'כרטיסייה'
        : model === 'half_year'
            ? 'מנוי חצי-שנתי'
            : model === 'year'
                ? 'מנוי שנתי'
                : 'מנוי חודשי';
}
function isRenewed(e) {
    return !!e.renewedToId;
}
function payCredit(e) {
    return Math.max(0, paidOf(e) - (e.totalDue || 0) - (e.carryBalance || 0));
}
export function coursesListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        sheetSummary: (() => { try {
            return sheetSummary(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        debtors: (() => { try {
            return debtors(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        punchLowList: (() => { try {
            return punchLowList(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        dropoutRisk: (() => { try {
            return dropoutRisk(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        pendingMakeups: (() => { try {
            return pendingMakeups(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        waitlistFor: (() => { try {
            return waitlistFor(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        sheetRoster: (() => { try {
            return sheetRoster(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        dropoutInsights: (() => { try {
            return dropoutInsights(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it, enrollmentPaidStatus: (() => { try {
                return enrollmentPaidStatus(it);
            }
            catch {
                return null;
            } })(), enrollStatusMeta: (() => { try {
                return enrollStatusMeta(it);
            }
            catch {
                return null;
            } })(), renewOf: (() => { try {
                return renewOf(it);
            }
            catch {
                return null;
            } })(), enrollSummary: (() => { try {
                return enrollSummary(it);
            }
            catch {
                return null;
            } })(), planLabelOf: (() => { try {
                return planLabelOf(it);
            }
            catch {
                return null;
            } })(), isRenewed: (() => { try {
                return isRenewed(it);
            }
            catch {
                return null;
            } })(), paidOf: (() => { try {
                return paidOf(it);
            }
            catch {
                return null;
            } })(), payBal: (() => { try {
                return payBal(it);
            }
            catch {
                return null;
            } })(), payCredit: (() => { try {
                return payCredit(it);
            }
            catch {
                return null;
            } })() })) : undefined,
    };
}
export { sheetSummary, debtors, punchLowList, dropoutRisk, pendingMakeups, waitlistFor, sheetRoster, dropoutInsights, enrollmentPaidStatus, enrollStatusMeta, renewOf, enrollSummary, planLabelOf, isRenewed, paidOf, payBal, payCredit };
