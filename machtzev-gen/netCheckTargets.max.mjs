// 🤖 AUTO-EMITTED by gen-max — netCheckTargets משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
export function netCheckTargets_ORIG(origin, firebase) {
    const bust = 'netcheck=' + Math.random().toString(36).slice(2);
    // מזהה-פרויקט/מפתח מהקונפיג — לבניית נתיב-API אמיתי שמחזיר CORS. חסר ⇒ ערך-בדיקה
    // ניטרלי (התשובה עדיין נושאת CORS — מודדים נגישות-רשת, לא תקינות-הבקשה).
    const projectId = firebase?.projectId || 'netcheck';
    const apiKey = firebase?.apiKey || 'netcheck';
    return [
        { key: 'site', label: 'האתר עצמו', url: origin + '/version.json?' + bust, domain: new URL(origin).host },
        ...(firebase
            ? [
                {
                    key: 'auth',
                    label: 'כניסה לחשבון (Auth)',
                    url: 'https://identitytoolkit.googleapis.com/v1/recaptchaParams?' + bust,
                    domain: 'identitytoolkit.googleapis.com',
                },
                {
                    key: 'token',
                    label: 'חידוש-חיבור (Token)',
                    // securetoken מחזיר CORS רק על POST ל-/v1/token (‏robots.txt חסר-CORS).
                    // גוף-מחרוזת ⇒ text/plain ⇒ בקשה-פשוטה בלי preflight; התשובה 400 עם CORS.
                    url: 'https://securetoken.googleapis.com/v1/token?key=' + encodeURIComponent(apiKey) + '&' + bust,
                    method: 'POST',
                    body: 'grant_type=refresh_token&refresh_token=netcheck',
                    domain: 'securetoken.googleapis.com',
                },
                {
                    key: 'db',
                    label: 'סנכרון נתונים (Firestore)',
                    // נתיב-מסמכים אמיתי מחזיר CORS (‏robots.txt לא). מסמך-דמה שלא-קיים ⇒
                    // 4xx עם CORS ⇒ נמדד כפתוח; חסימה ⇒ ה-fetch נדחה ⇒ חסום.
                    url: 'https://firestore.googleapis.com/v1/projects/' +
                        encodeURIComponent(projectId) +
                        '/databases/(default)/documents/__netcheck__/__probe__?' +
                        bust,
                    domain: 'firestore.googleapis.com',
                },
            ]
            : []),
    ];
}
export function netCheckTargets(origin, firebase, __opt = {}) {
    const base = netCheckTargets_ORIG(origin, firebase ?  : );
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    return base;
}
