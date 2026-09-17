// 🤖 AUTO-EMITTED by gen-max — drawerDiff (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function drawerDiff_ORIG(counted, expected) {
    return Math.round(((Number(counted) || 0) - (Number(expected) || 0)) * 100) / 100;
}
function expectedDrawer(float, sales) {
    return Math.round(((Number(float) || 0) + (Number(sales) || 0)) * 100) / 100;
}
export function drawerDiff(counted, expected) { return drawerDiff_ORIG(counted, expected); }
export function drawerDiff_fromSource(float, sales, expected) { return drawerDiff_ORIG(expectedDrawer(float, sales), expected); }
