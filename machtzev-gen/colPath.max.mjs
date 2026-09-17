// 🤖 AUTO-EMITTED by gen-max — colPath (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function colPath_ORIG(slug, cloudRoot, col) {
    return cloudRoot ? col : 'orgs/' + slug + '/' + col;
}
function metaPath(slug, cloudRoot) {
    return cloudRoot ? 'meta/org' : 'orgs/' + slug + '/meta/org';
}
export function colPath(slug, cloudRoot, col) { return colPath_ORIG(slug, cloudRoot, col); }
export function colPath_fromSource(slug, cloudRoot, col) { return colPath_ORIG(metaPath(slug, cloudRoot), cloudRoot, col); }
