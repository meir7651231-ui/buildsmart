// 🤖 AUTO-EMITTED by gen-max — saveDb משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
async function readRaw() {
    try {
        const raw = localStorage.getItem(LS_KEY);
        if (raw)
            return JSON.parse(raw);
    }
    catch {
        /* חסום או JSON פגום — ננסה IndexedDB */
    }
    try {
        return await (await getIdb()).get(IDB_STORE, 'current');
    }
    catch {
        return null;
    }
}
async function beginEncryption(db, password) {
    const recoveryKey = genRecoveryKey();
    const env = await encryptDb(JSON.stringify({ ...db, savedAt: new Date().toISOString() }), password, recoveryKey);
    const key = await openDek(env, password, 'pass');
    if (!key)
        throw new Error('כשל בהפעלת ההצפנה');
    dek = key;
    envelope = env;
    await writeEnvelope(env);
    // צילומים גלויים ישנים בטבעת ינגחו את ההצפנה — מנקים אותם.
    await purgeSnapshots();
    return recoveryKey;
}
function getIdb() {
    if (!idb) {
        idb = openDB(IDB_NAME, 1, {
            upgrade(d) {
                d.createObjectStore(IDB_STORE);
                d.createObjectStore(IDB_SNAPSHOTS);
            },
        });
    }
    return idb;
}
const IDB_STORE = 'db';
async function writeEnvelope(env) {
    const json = JSON.stringify(env);
    let lsOk = false;
    try {
        localStorage.setItem(LS_KEY, json);
        lsOk = true;
    }
    catch {
        /* מכסה מלאה */
    }
    try {
        await (await getIdb()).put(IDB_STORE, env, 'current');
        // LS נכשל אך IDB הצליח → מוחקים את העותק הישן ב-LS כדי ש-readRaw ייפול
        // לעותק הטרי ב-IndexedDB במקום להחזיר snapshot מיושן וקריא.
        if (!lsOk) {
            try {
                localStorage.removeItem(LS_KEY);
            }
            catch {
                /* חסום — אין מה לעשות */
            }
        }
    }
    catch {
        /* IndexedDB נכשל */
    }
}
async function purgeSnapshots() {
    try {
        const d = await getIdb();
        for (const key of await d.getAllKeys(IDB_SNAPSHOTS)) {
            await d.delete(IDB_SNAPSHOTS, key);
        }
    }
    catch {
        /* לא קריטי — יש עוד שכבות */
    }
}
const IDB_SNAPSHOTS = 'snapshots';
export async function saveDb_ORIG(db, opts) {
    const doc = { ...db, savedAt: new Date().toISOString() };
    const json = JSON.stringify(doc);
    // ⚠️ רב-טאבי: מצב ההצפנה (dek/envelope) הוא ברמת-מודול ולכן פרטי לכל טאב,
    // בלי סנכרון בין טאבים. לפני שדורסים את הערך המאוחסן, קוראים אותו מחדש:
    //  • טאב גלוי (dek==null) שרואה מעטפת מוצפנת = טאב אחר הפעיל הצפנה → אסור
    //    לדרוס אותה בטקסט גלוי (היה מדליף משפחות/טלפונים/תורמים בגלוי).
    //  • טאב מוצפן שהמעטפת בזיכרונו התיישנה (טאב אחר החליף סיסמה) → מאמצים את
    //    עטיפת-הסיסמה הטרייה מהמאוחסן, אחרת reencryptDb היה משחזר את הסיסמה הישנה.
    if (!opts?.plaintext) {
        const stored = await readRaw();
        if (dek && envelope) {
            if (isEncrypted(stored)) {
                // wrapRec/saltRec זהים ⇒ אותו DEK (רק החלפת סיסמה) → מאמצים את עטיפת
                // הסיסמה הטרייה. שונים ⇒ הצפנה הופעלה מחדש עם DEK אחר בטאב אחר; ה-DEK
                // שבידינו מיושן וכתיבה תשחית — נמנעים מדריסה.
                if (stored.wrapRec === envelope.wrapRec && stored.saltRec === envelope.saltRec) {
                    envelope = { ...envelope, saltPass: stored.saltPass, wrapPass: stored.wrapPass, iter: stored.iter };
                }
                else {
                    return false;
                }
            }
            // stored גלוי/חסר → המעטפת שבזיכרון מוסמכת (למשל מיד אחרי beginEncryption)
        }
        else if (isEncrypted(stored)) {
            return false; // טאב גלוי מול מעטפת מוצפנת של טאב אחר — לא דורסים
        }
    }
    // הצפנה פעילה → כותבים מעטפת מוצפנת (אותו DEK, data מעודכן)
    const payload = dek && envelope ? JSON.stringify((envelope = await reencryptDb(envelope, dek, json))) : json;
    const idbValue = dek && envelope ? envelope : doc;
    let ok = false;
    let lsOk = false;
    let idbOk = false;
    try {
        localStorage.setItem(LS_KEY, payload);
        ok = true;
        lsOk = true;
    }
    catch {
        /* מכסה מלאה / מצב פרטי */
    }
    try {
        await (await getIdb()).put(IDB_STORE, idbValue, 'current');
        ok = true;
        idbOk = true;
        // LS נכשל (מכסה מלאה) אך IDB הצליח → מוחקים את העותק הישן ב-LS. אחרת
        // readRaw היה מחזיר את ה-snapshot הקריא שקדם למכסה, וכל עריכה שנשמרה
        // רק ל-IndexedDB לאחר מכן הייתה נעלמת בטעינה הבאה (איבוד נתונים שקט).
        if (!lsOk) {
            try {
                localStorage.removeItem(LS_KEY);
            }
            catch {
                /* חסום — אין מה לעשות */
            }
        }
    }
    catch {
        /* IndexedDB נכשל */
    }
    // מעקב שכבת-הגיבוי: LS נכתב אך IDB נכשל = אין עותק שני (Safari פרטי / IDB חסום).
    if (lsOk && !idbOk)
        idbBackupMissing = true;
    else if (idbOk)
        idbBackupMissing = false;
    return ok;
}
export function saveDb(db, opts, __opt = {}) {
    const base = saveDb_ORIG(db, opts ?  : );
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
