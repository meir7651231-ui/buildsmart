// 🤖 AUTO-EMITTED by gen-max — orgJoinFullCode (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function orgJoinFullCode_ORIG(slug, code) {
    return slug + '.' + code;
}
function orgLink(origin, basePath, slug) {
    return origin + basePath + '?org=' + slug;
}
export function orgJoinFullCode(slug, code) { return orgJoinFullCode_ORIG(slug, code); }
export function orgJoinFullCode_fromSource(origin, basePath, slug, code) { return orgJoinFullCode_ORIG(orgLink(origin, basePath, slug), code); }
