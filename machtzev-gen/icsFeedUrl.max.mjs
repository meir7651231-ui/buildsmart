// 🤖 AUTO-EMITTED by gen-max — icsFeedUrl (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function icsFeedUrl_ORIG(projectId, slug, token) {
    return 'https://us-central1-' + projectId + '.cloudfunctions.net/icsFeed?org=' + encodeURIComponent(slug) + '&key=' + token;
}
function mintFeedToken() {
    const b = new Uint8Array(16);
    crypto.getRandomValues(b);
    return Array.from(b, (x) => x.toString(16).padStart(2, '0')).join('');
}
export function icsFeedUrl(projectId, slug, token) { return icsFeedUrl_ORIG(projectId, slug, token); }
export function icsFeedUrl_fromSource(slug, token) { return icsFeedUrl_ORIG(mintFeedToken(), slug, token); }
