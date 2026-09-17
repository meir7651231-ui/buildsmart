// 🤖 AUTO-EMITTED by gen-max — identityAchievements (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function identityAchievements_ORIG(s) {
    return [
        { ic: '🚀', name: 'הזמנה ראשונה', desc: 'ביצעת את ההזמנה הראשונה', on: s.orders >= 1 },
        { ic: '📦', name: '10 הזמנות', desc: '10 הזמנות דרך BuildSmart', on: s.orders >= 10 },
        { ic: '🏗️', name: 'ריבוי אתרים', desc: '3 אתרים פעילים במקביל', on: s.sites >= 3 },
        { ic: '🌳', name: 'חובב עץ מוצרים', desc: '5 עצי מוצרים בעבודה', on: s.trees >= 5 },
        { ic: '🧠', name: 'לא שוכח כלום', desc: '25 אביזרים שהעץ הציל', on: s.autoSaved >= 25 },
        { ic: '💰', name: 'מחזור ₪10K', desc: '₪10,000 דרך האפליקציה', on: s.spent >= 10000 },
    ];
}
function identityStats() {
    /* No live order data yet; in demo mode the prototype shows zeros
     * with the exception of `sites` which mirrors PROJECTS.length. */
    return {
        orders: 0,
        sites: PROJECTS.length,
        trees: 0,
        spent: 0,
        autoSaved: 0,
    };
}
export function identityAchievements(s) { return identityAchievements_ORIG(s); }
export function identityAchievements_fromSource() { return identityAchievements_ORIG(identityStats()); }
