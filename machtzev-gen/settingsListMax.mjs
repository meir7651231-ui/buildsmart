function applyScale(scale) {
    // zoom מגדיל את כל הממשק — כולל רכיבים עם מידות px קבועות, ש-root font-size
    // לא השפיע עליהם (נתמך בכל הדפדפנים המודרניים, כולל Firefox 126+).
    // ההצהרה עדיין לא בכל גרסאות lib.dom — לכן ההרחבה הטיפוסית המקומית.
    document.body.style.zoom = String(scale);
    // ניקוי המנגנון הישן (root font-size) — שלא יוכפל עם ה-zoom
    document.documentElement.style.fontSize = '';
    // דגל-זום ל-CSS: ‏zoom על body שובר יחידות-viewport (50vw) — באנר הבית של קהילה
    // גלש והתוכן נחתך בזום>1. הדגל מחליף את מילוי-הרוחב מבוסס-ה-vw בשוליים-בפיקסלים
    // (עקביים-לזום). scale=1 ⇒ הדגל מוסר ⇒ מילוי-הרוחב המקורי חוזר ביט-זהה.
    if (Math.abs(scale - 1) > 0.001)
        document.documentElement.setAttribute('data-ui-zoom', '1');
    else
        document.documentElement.removeAttribute('data-ui-zoom');
}
function persistScale(scale) {
    try {
        localStorage.setItem(SCALE_KEY, String(scale));
    }
    catch {
        /* localStorage חסום — ההעדפה תחזיק עד רענון */
    }
}
const SCALE_KEY = 'maor_ui_scale';
export function settingsListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        applyScale: (() => { try {
            return applyScale(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        persistScale: (() => { try {
            return persistScale(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { applyScale, persistScale };
