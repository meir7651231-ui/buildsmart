// 🤖 AUTO-EMITTED by gen-max — applyEntityPartial (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function sanitizeIncoming(col, item) {
    const fields = LIST_FIELDS[col];
    if (!fields)
        return item;
    let out = item;
    for (const f of fields) {
        if (!Array.isArray(out[f]))
            out = { ...out, [f]: [] };
    }
    return out;
}
function mergeDonationsPreserving(col, local, incoming) {
    if (col !== 'supporters')
        return incoming;
    const localDon = Array.isArray(local.donations) ? local.donations : [];
    const incDon = Array.isArray(incoming.donations) ? incoming.donations : [];
    const incRids = new Set(incDon.map((d) => d && d.rid).filter(Boolean));
    const localOnly = localDon.filter((d) => d && d.rid && !incRids.has(d.rid));
    const num = (v) => (typeof v === 'number' && Number.isFinite(v) ? v : 0);
    const count = Math.max(num(incoming.count), num(local.count));
    const ils = Math.max(num(incoming.ils), num(local.ils));
    const usd = Math.max(num(incoming.usd), num(local.usd));
    // אם אין תרומה מקומית-בלבד והמונים לא גדלו — אין מה לשמר, הענן כמות-שהוא.
    if (localOnly.length === 0 && count === num(incoming.count) && ils === num(incoming.ils) && usd === num(incoming.usd)) {
        return incoming;
    }
    return { ...incoming, donations: [...incDon, ...localOnly], count, ils, usd };
}
const LIST_FIELDS = {
    families: ['members', 'docs'],
    enrollments: ['payments', 'absences'],
    supporters: ['donations'],
    // קופות צדקה — ריקונים ולוג ניקוד (BUILD-ORDER-TZEDAKA)
    tzBoxes: ['collections'],
    tzCoordinators: ['scoreLog'],
    // חנות — רכיבי מוצר, מימושים וקריטריונים (BUILD-ORDER-SHOP)
    shopProducts: ['components'],
    shopAssignments: ['redemptions', 'criterionIds'],
    // רשימת ההמתנה על הפריט (SHOP6 חנות 27)
    shopItems: ['waits'],
};
export function applyEntityPartial_ORIG(db, col, docs) {
    if (!ENTITY_COLLECTIONS.includes(col))
        return db;
    const key = col;
    const list = db[key];
    const deleted = new Set(docs.filter((d) => d.deleted).map((d) => d.id));
    const incoming = new Map(docs
        .filter((d) => !d.deleted)
        .map((d) => [d.id, sanitizeIncoming(col, { ...d.data, id: d.id })]));
    // עדכונים במקומם (שומר סדר), חדשים לראש הרשימה — כמו upsertIn של ה-store
    const kept = list
        .filter((x) => !deleted.has(x.id))
        .map((x) => {
        const inc = incoming.get(x.id);
        if (inc) {
            incoming.delete(x.id);
            // איחוד-תרומות חסין-אובדן (פריט ח') — לתומכים בלבד; שאר האוספים כרגיל.
            const merged = mergeDonationsPreserving(col, x, inc);
            return merged;
        }
        return x;
    });
    const next = [...incoming.values(), ...kept];
    if (JSON.stringify(next) === JSON.stringify(list))
        return db;
    return { ...db, [key]: next };
}
function applyMetaPartial(db, meta) {
    const next = { ...db };
    let changed = false;
    const assign = (k, v) => {
        if (v === undefined)
            return;
        if (JSON.stringify(db[k]) !== JSON.stringify(v)) {
            next[k] = v;
            changed = true;
        }
    };
    assign('orgName', meta.orgName);
    assign('orgSite', meta.orgSite);
    assign('orgDonate', meta.orgDonate);
    assign('orgGoal', meta.orgGoal);
    assign('budget', meta.budget); // ORGADMIN/SHOP9 — סנכרון סקלר ארגוני (ציד-באגים 3.8)
    assign('usdRate', meta.usdRate);
    assign('audit', meta.audit); // לוג-פעולות (#10) — הענן-מנצח כמו שאר ה-meta
    // 🪦 מצבות (ביקורת-האמון 24.8): איחוד — לא הענן-מנצח, אחרת מצבה מקומית
    // טרייה (מחיקה שטרם נדחפה) נמחקת מהטבעת והרשומה קמה לתחייה בסיבוב הבא.
    if (Array.isArray(meta.delLog)) {
        const mergedDel = mergeDelLogs(db.delLog, meta.delLog);
        if (JSON.stringify(mergedDel) !== JSON.stringify(db.delLog ?? [])) {
            next.delLog = mergedDel;
            changed = true;
        }
    }
    assign('notif', meta.notif);
    assign('reports', meta.reports);
    assign('ui', meta.ui);
    assign('attnDone', meta.attnDone);
    // מונים: לעולם לא מקטינים — מונע התנגשות מזהים/מספרי-קבלה בין מכשירים
    const bumpCounter = (k) => {
        const v = meta[k];
        if (typeof v === 'number' && Number.isFinite(v) && v > db[k]) {
            next[k] = v;
            changed = true;
        }
    };
    bumpCounter('seq');
    bumpCounter('receiptSeq');
    bumpCounter('donationSeq');
    bumpCounter('shopReceiptSeq');
    return changed ? next : db;
}
export function applyEntityPartial(db, col, docs) { return applyEntityPartial_ORIG(db, col, docs); }
export function applyEntityPartial_fromSource(db, meta, col, docs) { return applyEntityPartial_ORIG(applyMetaPartial(db, meta), col, docs); }
