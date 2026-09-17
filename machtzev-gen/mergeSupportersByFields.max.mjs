// 🤖 AUTO-EMITTED by gen-max — mergeSupportersByFields (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function mergeSupportersGroup(keeper, losers) {
    return losers.reduce((acc, l) => mergeSupporterInto(acc, l), keeper);
}
const SUP_DUP_FIELDS = [
    { key: 'name', label: 'שם', get: (s) => s.name || '' },
    { key: 'phone', label: 'טלפון', get: (s) => s.phone || '' },
    { key: 'email', label: 'אימייל', get: (s) => s.email || '' },
    { key: 'idNum', label: 'ת"ז', get: (s) => s.idNum || '' },
    { key: 'city', label: 'עיר', get: (s) => s.city || '' },
    { key: 'address', label: 'כתובת', get: (s) => s.address || '' },
    { key: 'cat', label: 'קטגוריה', get: (s) => s.cat || '' },
    { key: 'forWho', label: 'ייעוד', get: (s) => s.forWho || '' },
    { key: 'notes', label: 'הערות', get: (s) => s.notes || '' },
];
function supDupFieldValue(sups, def, pick, edit) {
    const edited = edit[def.key];
    if (edited != null)
        return edited;
    const idx = pick[def.key] ?? sups.findIndex((s) => def.get(s));
    return def.get(sups[idx >= 0 ? idx : 0]);
}
export function mergeSupportersByFields_ORIG(sups, pick, edit) {
    const base = mergeSupportersGroup(sups[0], sups.slice(1));
    const out = { ...base };
    for (const def of SUP_DUP_FIELDS) {
        const val = supDupFieldValue(sups, def, pick, edit);
        switch (def.key) {
            case 'name':
                out.name = val;
                break;
            case 'phone':
                out.phone = val;
                break;
            case 'email':
                out.email = val;
                break;
            case 'idNum':
                out.idNum = val;
                break;
            case 'city':
                out.city = val;
                break;
            case 'address':
                out.address = val;
                break;
            case 'cat':
                out.cat = val;
                break;
            case 'forWho':
                out.forWho = val;
                break;
            case 'notes':
                out.notes = val;
                break;
        }
    }
    return out;
}
function mergeSupporterInto(keep, drop) {
    const donations = [...keep.donations, ...drop.donations].sort((a, b) => a.date.localeCompare(b.date));
    // 🐛 (21.8): ההיסטוריה שורשרה כמו-שהיא — אותו חיוב-סליקה שישב על **שני** כרטיסי-
    // הכפילות (ייבוא לשניהם) נספר פעמיים ב-supIls לנצח אחרי המיזוג. mergeHist
    // האידמפוטנטי (מפתח d|a|c, כמות=max) הוא אותו-כלל כמו בייבוא — עסקת-אמת כפולה
    // באותו כרטיס נשמרת, כפל-בין-כרטיסים מתמזג.
    const hist = mergeHist(keep.hist ?? [], drop.hist ?? []);
    // 🐛 (21.8): photos של הנמחק נזרקו בשקט (כל שדה-תוכן אחר ניצל) — איחוד עד
    // תקרת-האפליקציה (PHOTO_MAX), של השומר קודם; nextNote — של השומר גובר, ריק ⇒ של הנמחק.
    const photos = [...new Set([...(keep.photos ?? []), ...(drop.photos ?? [])])].slice(0, PHOTO_MAX);
    const nextNote = keep.nextNote || drop.nextNote;
    const ils = donations.filter((d) => d.cur !== '$').reduce((a, d) => a + d.amount, 0);
    const usd = donations.filter((d) => d.cur === '$').reduce((a, d) => a + d.amount, 0);
    const notes = [keep.notes, drop.notes].map((n) => (n || '').trim()).filter(Boolean);
    return {
        ...keep,
        phone: keep.phone || drop.phone,
        email: keep.email || drop.email,
        address: keep.address || drop.address,
        city: keep.city || drop.city,
        idNum: keep.idNum || drop.idNum,
        cat: keep.cat || drop.cat,
        forWho: keep.forWho || drop.forWho,
        notes: [...new Set(notes)].join(' · '),
        nextDate: keep.nextDate || drop.nextDate,
        ...(nextNote ? { nextNote } : {}),
        nextEventId: keep.nextEventId || undefined,
        donations,
        ...(hist.length ? { hist } : {}),
        ...(photos.length ? { photos } : {}),
        count: donations.length,
        ils,
        usd,
        first: donations[0]?.date ?? keep.first ?? '',
        last: donations[donations.length - 1]?.date ?? keep.last ?? '',
        ...(keep.extId || drop.extId ? { extId: keep.extId || drop.extId } : {}),
        ...(keep.hok || drop.hok ? { hok: keep.hok ?? drop.hok } : {}),
        ...(keep.ayin || drop.ayin ? { ayin: keep.ayin ?? drop.ayin } : {}),
    };
}
export function mergeSupportersByFields(sups, pick, edit) { return mergeSupportersByFields_ORIG(sups, pick, edit); }
export function mergeSupportersByFields_fromSource(keep, drop, pick, edit) { return mergeSupportersByFields_ORIG(mergeSupporterInto(keep, drop), pick, edit); }
