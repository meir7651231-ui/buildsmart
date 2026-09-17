// 🤖 AUTO-EMITTED by gen-max — orgJoinLink (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function orgJoinLink_ORIG(origin, basePath, slug, code) {
    return origin + basePath + '?org=' + slug + '&join=' + code;
}
function orgLink(origin, basePath, slug) {
    return origin + basePath + '?org=' + slug;
}
export function orgJoinLink(origin, basePath, slug, code) { return orgJoinLink_ORIG(origin, basePath, slug, code); }
export function orgJoinLink_fromSource(origin, basePath, slug, code) { return orgJoinLink_ORIG(orgLink(origin, basePath, slug), basePath, slug, code); }
