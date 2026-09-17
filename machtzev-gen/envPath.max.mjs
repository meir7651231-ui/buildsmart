// 🤖 AUTO-EMITTED by gen-max — envPath (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function envPath_ORIG(slug, cloudRoot) {
    return cloudRoot ? '_enc/envelope' : 'orgs/' + slug + '/_enc/envelope';
}
function colPath(slug, cloudRoot, col) {
    return cloudRoot ? col : 'orgs/' + slug + '/' + col;
}
export function envPath(slug, cloudRoot) { return envPath_ORIG(slug, cloudRoot); }
export function envPath_fromSource(slug, cloudRoot, col) { return envPath_ORIG(colPath(slug, cloudRoot, col), cloudRoot); }
