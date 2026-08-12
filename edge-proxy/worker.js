/**
 * 🌉 מתווך-הקצה של BuildSmart — Cloudflare Worker (12.8.2026)
 *
 * המטרה (הכרעת-בעלים "רק הקישור שלי, אפס בקשות מהסינון"): כל תעבורת-הגוגל של
 * האפליקציה עוברת דרך `api.buildsmart-il.com` — הדומיין המאושר. הלקוח מדבר רק
 * עם הדומיין שלך; המתווך פונה לגוגל מאחורי-הקלעים. הסנן רואה דומיין אחד בלבד.
 *
 * ⚠️ ALLOWLIST בלבד — לא open-proxy. מעביר אך ורק ל-hosts הספציפיים שהאפליקציה
 * צריכה. כך הדומיין לא הופך לטאנל-כללי (מה ששומר על אישור-הסנן, ולא הופך את
 * זה לכלי-עקיפה). כל path שלא ברשימה ⇒ 404.
 *
 * מיפוי הנתיבים (prefix ⇒ host-יעד):
 *   /idt/*       ⇒ identitytoolkit.googleapis.com   (התחברות — Identity Toolkit REST)
 *   /token/*     ⇒ securetoken.googleapis.com       (רענון-טוקן)
 *   /fs/*        ⇒ firestore.googleapis.com          (נתונים חיים)
 *   /fn/*        ⇒ me-west1-<PROJECT>.cloudfunctions.net  (callable functions)
 *
 * פריסה: Cloudflare ← Workers & Pages ← Create Worker ← הדבק קובץ זה ←
 *   Settings ← Triggers ← Custom Domain: api.buildsmart-il.com. זהו.
 * אפס נגיעה ב-Firebase / באפליקציה החיה — תת-דומיין חדש, איש לא פונה אליו עד
 * שדגל-הלקוח נדלק.
 */

// ── התאמה פר-פרויקט ──────────────────────────────────────────────
const PROJECT = 'buildsmart-b0b78';
const FUNCTIONS_REGION = 'me-west1';

// prefix → host. הרשימה סגורה: מה שלא כאן — נחסם.
const ROUTES = {
  idt: 'identitytoolkit.googleapis.com',
  token: 'securetoken.googleapis.com',
  fs: 'firestore.googleapis.com',
  fn: `${FUNCTIONS_REGION}-${PROJECT}.cloudfunctions.net`,
};

// CORS — הבקשות מגיעות מ-buildsmart-il.com (origin שונה מ-api.buildsmart-il.com).
const ALLOW_ORIGIN = 'https://buildsmart-il.com';
const CORS = {
  'Access-Control-Allow-Origin': ALLOW_ORIGIN,
  'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type,Authorization,X-Goog-Api-Client,X-Firebase-GMPID,X-Client-Version,X-Goog-Request-Params',
  'Access-Control-Max-Age': '86400',
};

export default {
  async fetch(request) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS });
    }

    const url = new URL(request.url);
    const seg = url.pathname.split('/').filter(Boolean); // ['fs', 'v1', ...]
    const prefix = seg[0];
    const targetHost = ROUTES[prefix];
    if (!targetHost) {
      return new Response('not found', { status: 404, headers: CORS });
    }

    // בונים את כתובת-היעד: מסירים את ה-prefix, שומרים את שאר הנתיב + query
    const rest = '/' + seg.slice(1).join('/');
    const upstream = new URL('https://' + targetHost + rest + url.search);

    // מעבירים את הבקשה כמות-שהיא (method, headers, body). ה-Host מתעדכן ל-upstream
    // אוטומטית ע"י fetch. streaming-body נשמר (חשוב ל-Firestore long-polling).
    const fwd = new Request(upstream, {
      method: request.method,
      headers: stripHopByHop(request.headers),
      body: request.method === 'GET' || request.method === 'HEAD' ? undefined : request.body,
      redirect: 'manual',
    });

    const resp = await fetch(fwd);

    // מחזירים ללקוח עם כותרות-CORS; שאר הכותרות של גוגל עוברות כמות-שהן.
    const out = new Headers(resp.headers);
    for (const [k, v] of Object.entries(CORS)) out.set(k, v);
    return new Response(resp.body, { status: resp.status, statusText: resp.statusText, headers: out });
  },
};

/** מסיר כותרות hop-by-hop / כותרות-Host שאסור להעביר upstream. */
function stripHopByHop(headers) {
  const h = new Headers(headers);
  for (const k of ['host', 'connection', 'keep-alive', 'transfer-encoding', 'upgrade', 'cf-connecting-ip', 'cf-ray', 'x-forwarded-host']) {
    h.delete(k);
  }
  return h;
}
