// 🤖 AUTO-EMITTED by gen-max — expectedDrawer (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function expectedDrawer_ORIG(float, sales) {
    return Math.round(((Number(float) || 0) + (Number(sales) || 0)) * 100) / 100;
}
function drawerDiff(counted, expected) {
    return Math.round(((Number(counted) || 0) - (Number(expected) || 0)) * 100) / 100;
}
export function expectedDrawer(float, sales) { return expectedDrawer_ORIG(float, sales); }
export function expectedDrawer_fromSource(counted, expected, sales) { return expectedDrawer_ORIG(drawerDiff(counted, expected), sales); }
