// 🤖 AUTO-EMITTED by gen-max — encryptExistingCloud משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
async function pushDiff(diff, dek, supKeyBySpId = new Map()) {
    const db = requireDb();
    const ops = [];
    for (const s of diff.sets) {
        const inner = dek ? await encryptDoc(toPlain(s.data), dek) : toPlain(s.data);
        // אכיפת-נתונים (dormant): מסמך באוסף-נאכף (supporters/events) נושא `skey` plaintext
        // מחוץ למעטפה, כדי ש-Rules ושאילתת-where יבחנו אותו גם בארגון-מוצפן. כבוי ⇒ ביט-זהה.
        const keyed = supEnforceOn && SUP_KEYED_COLS.includes(s.col);
        const body = keyed
            ? { skey: docSkey(s.col, s.data, supKeyBySpId), ...inner }
            : inner;
        ops.push((b) => b.set(doc(db, scopedCol(s.col), s.id), body));
    }
    for (const d of diff.deletes) {
        ops.push((b) => b.delete(doc(db, scopedCol(d.col), d.id)));
    }
    for (let i = 0; i < ops.length; i += 400) {
        const batch = writeBatch(db);
        for (const op of ops.slice(i, i + 400))
            op(batch);
        await batch.commit();
    }
    // מסמך ה-meta נכתב בעסקה נפרדת בטוחה-למונים (לא בכתיבת-האצווה העיוורת).
    // אכיפת-נתונים (משטח #3): לוג-הפעולות נושא שמות-תורמים ורוכב על meta המשותף —
    // כשהאכיפה דלוקה מקלפים אותו (הלוג נשאר מקומי). כבוי ⇒ ביט-זהה (רוכב כרגיל).
    const meta = supEnforceOn && diff.meta ? stripAuditMeta(diff.meta) : diff.meta;
    if (meta)
        await pushMetaCounterSafe(toPlain(meta), dek);
}
function requireDb() {
    if (!fsDb)
        throw new Error('הענן לא אותחל — פנו למנהל המערכת');
    return fsDb;
}
function toPlain(data) {
    return JSON.parse(JSON.stringify(data));
}
function scopedCol(col) {
    return colPath(scope.slug, scope.cloudRoot, col);
}
async function pushMetaCounterSafe(meta, dek) {
    const db = requireDb();
    const ref = doc(db, scopedMeta());
    await runTransaction(db, async (tx) => {
        const snap = await tx.get(ref);
        let existing = null;
        if (snap.exists()) {
            const raw = snap.data();
            existing = dek ? await decryptDoc(raw, dek) : raw;
        }
        const safe = { ...meta };
        for (const k of META_COUNTER_KEYS) {
            const cur = existing?.[k];
            const nxt = safe[k];
            if (typeof cur === 'number' && (typeof nxt !== 'number' || cur > nxt))
                safe[k] = cur;
        }
        const body = dek ? await encryptDoc(safe, dek) : safe;
        tx.set(ref, body);
    });
}
function scopedMeta() {
    return metaPath(scope.slug, scope.cloudRoot);
}
const META_COUNTER_KEYS = ['seq', 'receiptSeq', 'donationSeq', 'shopReceiptSeq'];
function supportersImportFormatRows(db) {
    const rows = [['שם', 'טלפון', 'אימייל', 'ת"ז', 'כתובת', 'קטגוריה', 'עבור']];
    for (const sp of db.supporters) {
        rows.push([sp.name, sp.phone, sp.email, sp.idNum, sp.address, sp.cat, sp.forWho]);
    }
    return rows;
}
export async function encryptExistingCloud_ORIG(db, dek) {
    // אכיפת-נתונים: אם דלוקה, גם מיגרציית-ההצפנה שומרת skey על אוספים-נאכפים.
    await pushDiff(fullDbDiff(db), dek, supKeyMapOf(db.supporters));
}
export function encryptExistingCloud(db, dek, __opt = {}) {
    const base = encryptExistingCloud_ORIG(db, dek);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
