// 🤖 AUTO-EMITTED by gen-max — orgLink (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function orgLink_ORIG(origin, basePath, slug) {
    return origin + basePath + '?org=' + slug;
}
function orgJoinLink(origin, basePath, slug, code) {
    return origin + basePath + '?org=' + slug + '&join=' + code;
}
export function orgLink(origin, basePath, slug) { return orgLink_ORIG(origin, basePath, slug); }
export function orgLink_fromSource(origin, basePath, slug, code) { return orgLink_ORIG(orgJoinLink(origin, basePath, slug, code), basePath, slug); }
