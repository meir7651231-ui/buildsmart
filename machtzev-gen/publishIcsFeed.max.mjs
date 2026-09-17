// 🤖 AUTO-EMITTED by gen-max — publishIcsFeed (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
const MAX_ICS_BYTES = 900000;
async function readIcsFeedToken(slug) {
    const snap = await getDoc(doc(cloudDb(), ICS_FEEDS, slug));
    const d = snap.exists() ? snap.data() : null;
    return d && typeof d.token === 'string' && d.token ? d.token : null;
}
const ICS_FEEDS = 'icsFeeds';
export async function publishIcsFeed_ORIG(slug, ics, opts) {
    if (new TextEncoder().encode(ics).length > MAX_ICS_BYTES) {
        throw new Error('לוח-השנה גדול מדי לפרסום כפיד — פנו לתמיכה');
    }
    const token = (opts?.rotate ? null : await readIcsFeedToken(slug)) ?? mintFeedToken();
    await setDoc(doc(cloudDb(), ICS_FEEDS, slug), { token, ics, updatedAt: new Date().toISOString() });
    return token;
}
function mintFeedToken() {
    const b = new Uint8Array(16);
    crypto.getRandomValues(b);
    return Array.from(b, (x) => x.toString(16).padStart(2, '0')).join('');
}
export function publishIcsFeed(slug, ics, opts) { return publishIcsFeed_ORIG(slug, ics, opts); }
export function publishIcsFeed_fromSource(ics, opts) { return publishIcsFeed_ORIG(mintFeedToken(), ics, opts); }
