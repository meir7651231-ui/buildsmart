function suggestions(db, todayIso, config) {
    const T = (k, fb) => (config ? termOf(config, k, fb) : fb);
    // גידור-מודולים במנוע (20.8, ממצא-ביקורת): הצעה שה-act שלה במודול כבוי לא נוצרת —
    // בלי config (בדיקות ישנות) הכול פעיל, כמו חוזה-הדגלים.
    const modOn = (m) => !config || moduleOn(config, m);
    const out = [];
    const activeFams = db.families.filter((f) => f.status === 'active');
    // A — חג מתקרב (מודול חנות בלבד — היעד הוא מתנת-חג בחנות)
    const hol = upcomingHoliday(todayIso, 30);
    if (modOn('shop') && hol && activeFams.length > 0) {
        // תיקון (swarm-audit): מפתחות 'sug:' פטורים מגיזום-30-הימים (useApp postLoad) —
        // מפתח בלי שנה עברית ⇒ ביטול חד-פעמי של "מתנת-חג · פסח" קובר את ההצעה לנצח,
        // לכל השנים. השנה העברית של מופע-החג במפתח ⇒ החג הבא (שנה אחרת) עולה מחדש.
        out.push({
            key: `sug:holiday:${hol.name}:${hol.hebYear}`,
            emoji: '🎁',
            title: `מתנת-חג · ${hol.name} בעוד ${hol.inDays} ימים`,
            detail: `${activeFams.length} ${T('nav.families', 'משפחות')} פעילות — שקלו חלוקת מתנות לקראת החג`,
            act: 'shop',
        });
    }
    // B/C — לפי גיל הילדים
    for (const f of activeFams) {
        for (const m of f.members) {
            if (m.isParent)
                continue;
            const age = ageAt(m.birth, todayIso);
            if (age === 6 || age === 5) {
                // תיקון (swarm-audit): הגיל במפתח — ביטול בגיל 5 לא מסתיר את ההצעה
                // המחודשת בגיל 6 (מפתח יחיד היה מכסה את שתי השנים; 'sug:' לא נגזם).
                out.push({
                    key: `sug:school:${m.id}:${age}`,
                    emoji: '🎒',
                    title: `ערכת בית-ספר · ${m.first} (${f.name})`,
                    detail: `בן/בת ${age} — לקראת/בתחילת כיתה א׳`,
                    famId: f.id,
                    act: 'families',
                });
            }
            else if (age === 0) {
                out.push({
                    key: `sug:baby:${m.id}`,
                    emoji: '👶',
                    title: `ערכת תינוק · ${T('entity.familyOf', 'משפחת')} ${f.name}`,
                    detail: `${m.first} — תינוק/ת חדש/ה ב${T('entity.family', 'משפחה')}`,
                    famId: f.id,
                    act: 'families',
                });
            }
        }
    }
    // D — כרטיסייה נגמרת (מודול חוגים בלבד — הנתון והיעד שניהם בחוגים)
    for (const e of modOn('courses') ? db.enrollments : []) {
        if (e.plan !== 'punch' || e.status !== 'active')
            continue;
        const rem = e.purchased - e.used;
        if (rem > 2 || rem < 0)
            continue;
        const course = db.courses.find((c) => c.id === e.courseId);
        const fam = db.families.find((f) => f.members.some((m) => m.id === e.memberId));
        const member = fam?.members.find((m) => m.id === e.memberId);
        // תיקון (swarm-audit): purchased = סמן-דור-מילוי דטרמיניסטי — אחרי חידוש
        // הכרטיסייה (purchased גדל) המפתח מתחלף, וההצעה הבאה כש"נגמרת שוב" עולה
        // גם אם הקודמת בוטלה ('sug:' פטור מגיזום ⇒ מפתח קבוע היה נקבר לנצח).
        out.push({
            key: `sug:renew:${e.id}:${e.purchased}`,
            emoji: '🎫',
            title: `חידוש כרטיסייה · ${member?.first ?? '—'} · ${course?.name ?? '—'}`,
            detail: rem <= 0 ? 'הכרטיסייה נגמרה' : `נותרו ${rem} ניקובים`,
            famId: fam?.id,
            courseId: e.courseId,
            act: 'courses',
        });
    }
    return out;
}
function upcomingHoliday(todayIso, windowDays) {
    const base = atNoon(todayIso);
    for (let i = 1; i <= windowDays; i++) {
        const d = new Date(base.getTime() + i * 86400000);
        const h = holidayOf(d);
        if (h)
            return { name: h, inDays: i, hebYear: hebParts(d).year };
    }
    return null;
}
function ageAt(birth, todayIso) {
    if (!birth)
        return null;
    const b = atNoon(birth);
    const t = atNoon(todayIso);
    if (isNaN(b.getTime()) || isNaN(t.getTime()))
        return null;
    let a = t.getFullYear() - b.getFullYear();
    const md = t.getMonth() - b.getMonth();
    if (md < 0 || (md === 0 && t.getDate() < b.getDate()))
        a--;
    return a;
}
function atNoon(iso) {
    return new Date(iso.slice(0, 10) + 'T12:00:00');
}
export function shop8ListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        suggestions: (() => { try {
            return suggestions(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { suggestions };
