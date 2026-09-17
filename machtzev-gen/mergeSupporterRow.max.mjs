// 🤖 AUTO-EMITTED by gen-max — mergeSupporterRow (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function mergeHist(existing, incoming) {
    const key = (h) => h.d + '|' + h.a + '|' + (h.c ?? '₪');
    // אינדקס-נכנס פר-מפתח (בסדר) — משמש גם ל**העשרת** רשומות קיימות וגם לספירה.
    const incByKey = new Map();
    for (const h of incoming) {
        const arr = incByKey.get(key(h));
        if (arr)
            arr.push(h);
        else
            incByKey.set(key(h), [h]);
    }
    // העשרה (13.8b): רשומה קיימת שיובאה **לפני** שדות-המטא-דאטה (בלי txn/מותג/…)
    // מתמלאת מהשורה-הנכנסת התואמת — הערך הקיים גובר, הנכנס ממלא רק חוסרים. כך
    // ייבוא-חוזר של אותו קובץ *משדרג* עסקאות ותיקות בלי לשכפל אותן.
    const usedInc = new Map();
    const out = existing.map((h) => {
        const k = key(h);
        const arr = incByKey.get(k);
        const idx = usedInc.get(k) ?? 0;
        if (arr && idx < arr.length) {
            usedInc.set(k, idx + 1);
            return { ...arr[idx], ...h }; // נכנס ממלא חוסרים; קיים גובר על חפיפה
        }
        return { ...h };
    });
    // דחיפת מופעים-נכנסים מעבר לכמות-הקיימת (עסקאות חדשות באמת) — עם כל שדותיהן.
    const haveCount = new Map();
    for (const h of existing)
        haveCount.set(key(h), (haveCount.get(key(h)) ?? 0) + 1);
    const seen = new Map();
    for (const h of incoming) {
        const k = key(h);
        const n = (seen.get(k) ?? 0) + 1;
        seen.set(k, n);
        if (n > (haveCount.get(k) ?? 0))
            out.push({ ...h });
    }
    return out.sort((x, y) => x.d.localeCompare(y.d));
}
function fixPhone(p) {
    return formatIsraeliPhone(p);
}
export function mergeSupporterRow_ORIG(sp, row) {
    return {
        ...sp,
        ...(row.hist?.length ? { hist: mergeHist(sp.hist ?? [], row.hist) } : {}),
        name: row.name.trim() || sp.name,
        phone: row.phone ? fixPhone(row.phone.trim()) : sp.phone,
        email: row.email.trim() || sp.email,
        idNum: row.idNum.trim() || sp.idNum,
        address: row.address.trim() || sp.address,
        cat: row.cat.trim() || sp.cat,
        forWho: row.forWho.trim() || sp.forWho,
    };
}
function newSupporterFromRow(id, row) {
    return {
        id,
        name: row.name.trim(),
        phone: fixPhone(row.phone.trim()),
        email: row.email.trim(),
        idNum: row.idNum.trim(),
        address: row.address.trim(),
        cat: row.cat.trim(),
        forWho: row.forWho.trim(),
        notes: '',
        count: 0,
        ils: 0,
        usd: 0,
        first: '',
        last: '',
        nextDate: '',
        donations: [],
        ...(row.hist?.length ? { hist: mergeHist([], row.hist) } : {}),
    };
}
export function mergeSupporterRow(sp, row) { return mergeSupporterRow_ORIG(sp, row); }
export function mergeSupporterRow_fromSource(id, row) { return mergeSupporterRow_ORIG(newSupporterFromRow(id, row), row); }
