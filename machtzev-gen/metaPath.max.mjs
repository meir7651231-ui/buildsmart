// 🤖 AUTO-EMITTED by gen-max — metaPath (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function metaPath_ORIG(slug, cloudRoot) {
    return cloudRoot ? 'meta/org' : 'orgs/' + slug + '/meta/org';
}
function colPath(slug, cloudRoot, col) {
    return cloudRoot ? col : 'orgs/' + slug + '/' + col;
}
export function metaPath(slug, cloudRoot) { return metaPath_ORIG(slug, cloudRoot); }
export function metaPath_fromSource(slug, cloudRoot, col) { return metaPath_ORIG(colPath(slug, cloudRoot, col), cloudRoot); }
