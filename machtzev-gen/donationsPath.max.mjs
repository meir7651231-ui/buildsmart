// 🤖 AUTO-EMITTED by gen-max — donationsPath (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function colPath(slug, cloudRoot, col) {
    return cloudRoot ? col : 'orgs/' + slug + '/' + col;
}
const DONATIONS_COL = 'donations';
export function donationsPath_ORIG(slug, cloudRoot) {
    return colPath(slug, cloudRoot, DONATIONS_COL);
}
function metaPath(slug, cloudRoot) {
    return cloudRoot ? 'meta/org' : 'orgs/' + slug + '/meta/org';
}
export function donationsPath(slug, cloudRoot) { return donationsPath_ORIG(slug, cloudRoot); }
export function donationsPath_fromSource(slug, cloudRoot) { return donationsPath_ORIG(metaPath(slug, cloudRoot), cloudRoot); }
