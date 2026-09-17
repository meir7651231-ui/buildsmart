// 🤖 AUTO-EMITTED by gen-max — normalizeConfig משודרג. default ביט-זהה למקורי (אפס-אובדן). אל תערוך ביד.
function normalizeFirebase(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw))
        return undefined;
    const f = raw;
    const req = [f.apiKey, f.authDomain, f.projectId, f.appId];
    if (!req.every((v) => typeof v === 'string' && v.length > 0))
        return undefined;
    const out = {
        apiKey: f.apiKey,
        authDomain: f.authDomain,
        projectId: f.projectId,
        appId: f.appId,
    };
    if (typeof f.storageBucket === 'string' && f.storageBucket)
        out.storageBucket = f.storageBucket;
    if (typeof f.messagingSenderId === 'string' && f.messagingSenderId) {
        out.messagingSenderId = f.messagingSenderId;
    }
    return out;
}
function donationSplitOn(cfg) {
    return cfg.donationSplit === true;
}
function applyTheme(theme, accent, motion) {
    const el = document.documentElement;
    el.dataset.theme = theme || DEFAULT_CONFIG.theme;
    if (accent && isSafeAccent(accent.trim()))
        el.style.setProperty('--accent', accent.trim());
    else
        el.style.removeProperty('--accent');
    // סגנון-תנועה פר-ורטיקל — data-motion על ה-root; חסר ⇒ ברירת-המחדל (ביט-זהה להיום).
    if (motion && MOTION_KEYS.includes(motion))
        el.dataset.motion = motion;
    else
        delete el.dataset.motion;
}
function isSafeAccent(a) {
    return (/^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(a) ||
        /^(?:rgb|rgba|hsl|hsla)\([0-9.,%\s/]+\)$/i.test(a) ||
        /^[a-zA-Z]{3,20}$/.test(a));
}
const TEL_KINDS = ['sim', 'virtual', 'whatsapp'];
function telStr(v, max) {
    return typeof v === 'string' ? v.replace(/\p{Cc}/gu, '').trim().slice(0, max) : '';
}
const TEL_HHMM_RE = /^([01]\d|2[0-3]):[0-5]\d$/;
function telExt(v, def) {
    const s = typeof v === 'string' ? v.replace(/\D/g, '').slice(0, 8) : '';
    return s || def;
}
function siteStr(v, max) {
    return typeof v === 'string' ? v.replace(/\p{Cc}/gu, '').trim().slice(0, max) : '';
}
function normLocalized(v, max) {
    if (typeof v === 'string') {
        const s = siteStr(v, max);
        return s || undefined;
    }
    if (v && typeof v === 'object' && !Array.isArray(v)) {
        const out = {};
        for (const l of SITE_LANGS) {
            const s = siteStr(v[l], max);
            if (s)
                out[l] = s;
        }
        return Object.keys(out).length ? out : undefined;
    }
    return undefined;
}
function sitePosNum(v) {
    return typeof v === 'number' && Number.isFinite(v) && v >= 0 ? v : undefined;
}
function safeHttpsUrl(raw) {
    const t = (raw || '').trim();
    if (!t)
        return null;
    try {
        const u = new URL(t);
        return u.protocol === 'https:' ? u.toString() : null;
    }
    catch {
        return null;
    }
}
function sitePhone(v) {
    return typeof v === 'string' ? v.replace(/[^\d+()\-\s]/g, '').trim().slice(0, 24) : '';
}
function sanitizeTemplates(raw) {
    const out = {};
    if (raw && typeof raw === 'object') {
        for (const [k, v] of Object.entries(raw)) {
            if (TEMPLATE_KEYS.has(k) && typeof v === 'string')
                out[k] = v;
        }
    }
    return out;
}
function isValidSlug(slug) {
    return /^[a-z0-9-]{2,40}$/.test(slug);
}
function normalizeTelephony(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw))
        return undefined;
    const t = raw;
    const numsRaw = Array.isArray(t.numbers) ? t.numbers.slice(0, 64) : [];
    const numbers = [];
    numsRaw.forEach((n, i) => {
        if (!n || typeof n !== 'object' || Array.isArray(n))
            return;
        const o = n;
        const kind = TEL_KINDS.includes(o.kind) ? o.kind : 'sim';
        const e164 = typeof o.e164 === 'string' ? o.e164.replace(/[^\d+()\-\s]/g, '').trim().slice(0, 24) : '';
        const id = telStr(o.id, 32) || `n${i + 1}`;
        const num = { id, e164, label: telStr(o.label, 60) || id, kind };
        if (o.kosher === true)
            num.kosher = true;
        numbers.push(num);
    });
    const daysRaw = Array.isArray(t.officeDays) ? t.officeDays : [0, 1, 2, 3, 4];
    const officeDays = [
        ...new Set(daysRaw.filter((d) => Number.isInteger(d) && d >= 0 && d <= 6)),
    ].sort((a, b) => a - b);
    const bool = (v, def) => (typeof v === 'boolean' ? v : def);
    const hhmm = (v, def) => (typeof v === 'string' && TEL_HHMM_RE.test(v) ? v : def);
    // עיר — [a-z] בלבד, 2–20 תווים (תואם לקבלה של validate.mjs); אורך פסול ⇒ '' (מושמט,
    // לא נגזם — קלט חורג הוא זבל, עדיף נפילה לברירת-מחדל מאשר שם-עיר שגוי-שקט).
    const cityRaw = typeof t.city === 'string' ? t.city.toLowerCase().replace(/[^a-z]/g, '') : '';
    return {
        // מתג-המקטע — opt-in: הכותרת נשמרת רק כשהיא true (חסר/false ⇒ כבוי, מושמט).
        ...(t.enabled === true ? { enabled: true } : {}),
        numbers,
        officeDays,
        officeStart: hhmm(t.officeStart, '09:00'),
        officeEnd: hhmm(t.officeEnd, '17:00'),
        officeExt: telExt(t.officeExt, '101'),
        managerExt: telExt(t.managerExt, '201'),
        vmBox: telExt(t.vmBox, '100'),
        city: cityRaw.length >= 2 && cityRaw.length <= 20 ? cityRaw : '',
        kosherMode: bool(t.kosherMode, false),
        hebrewCalendar: bool(t.hebrewCalendar, true),
        zmanim: bool(t.zmanim, false),
        shabbat: bool(t.shabbat, true),
        fasts: bool(t.fasts, false),
        voicemail: bool(t.voicemail, true),
    };
}
function normalizeSite(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw))
        return undefined;
    const s = raw;
    const out = {};
    if (s.enabled === false)
        out.enabled = false;
    else if (s.enabled === true)
        out.enabled = true;
    const icon = siteStr(s.icon, 12);
    if (icon)
        out.icon = icon;
    const langs = Array.isArray(s.langs)
        ? [...new Set(s.langs.filter((l) => SITE_LANGS.includes(l)))]
        : [];
    if (langs.length)
        out.langs = langs;
    const tagline = normLocalized(s.tagline, 200);
    if (tagline)
        out.tagline = tagline;
    if (Array.isArray(s.heroWords)) {
        const words = s.heroWords.map((w) => normLocalized(w, 60)).filter((w) => !!w).slice(0, 8);
        if (words.length)
            out.heroWords = words;
    }
    if (Array.isArray(s.stats)) {
        const stats = s.stats
            .map((st) => {
            if (!st || typeof st !== 'object')
                return null;
            const o = st;
            const value = siteStr(o.value, 24);
            const label = normLocalized(o.label, 60);
            return value && label ? { value, label } : null;
        })
            .filter((x) => !!x)
            .slice(0, 8);
        if (stats.length)
            out.stats = stats;
    }
    if (s.liveFamilies === true)
        out.liveFamilies = true;
    const lfl = normLocalized(s.liveFamiliesLabel, 60);
    if (lfl)
        out.liveFamiliesLabel = lfl;
    if (s.campaign && typeof s.campaign === 'object' && !Array.isArray(s.campaign)) {
        const c = s.campaign;
        const camp = {};
        const ct = normLocalized(c.title, 120);
        if (ct)
            camp.title = ct;
        const goal = sitePosNum(c.goal);
        if (goal !== undefined)
            camp.goal = goal;
        const raised = sitePosNum(c.raised);
        if (raised !== undefined)
            camp.raised = raised;
        const end = siteStr(c.end, 30);
        if (end)
            camp.end = end;
        const cur = siteStr(c.currency, 4);
        if (cur)
            camp.currency = cur;
        if (Object.keys(camp).length)
            out.campaign = camp;
    }
    if (Array.isArray(s.services)) {
        const svcs = s.services
            .map((sv) => {
            if (!sv || typeof sv !== 'object')
                return null;
            const o = sv;
            const title = normLocalized(o.title, 80);
            if (!title)
                return null;
            const svc = { title };
            const icon = siteStr(o.icon, 12);
            if (icon)
                svc.icon = icon;
            const text = normLocalized(o.text, 240);
            if (text)
                svc.text = text;
            return svc;
        })
            .filter((x) => !!x)
            .slice(0, 12);
        if (svcs.length)
            out.services = svcs;
    }
    const news = normLocalized(s.news, 800);
    if (news)
        out.news = news;
    const story = normLocalized(s.story, 2000);
    if (story)
        out.story = story;
    if (Array.isArray(s.gallery)) {
        const imgs = s.gallery
            .map((g) => (typeof g === 'string' ? safeHttpsUrl(g) : null))
            .filter((g) => !!g)
            .slice(0, 24);
        if (imgs.length)
            out.gallery = imgs;
    }
    if (s.contact && typeof s.contact === 'object' && !Array.isArray(s.contact)) {
        const c = s.contact;
        const contact = {};
        if (Array.isArray(c.phones)) {
            const phones = c.phones.map(sitePhone).filter((p) => p).slice(0, 8);
            if (phones.length)
                contact.phones = phones;
        }
        const wa = sitePhone(c.whatsapp);
        if (wa)
            contact.whatsapp = wa;
        const email = siteStr(c.email, 120);
        if (email && email.includes('@'))
            contact.email = email;
        const addr = normLocalized(c.address, 200);
        if (addr)
            contact.address = addr;
        const hours = normLocalized(c.hours, 120);
        if (hours)
            contact.hours = hours;
        const taxNote = normLocalized(c.taxNote, 200);
        if (taxNote)
            contact.taxNote = taxNote;
        if (typeof c.mapUrl === 'string') {
            const mu = safeHttpsUrl(c.mapUrl);
            if (mu)
                contact.mapUrl = mu;
        }
        if (Object.keys(contact).length)
            out.contact = contact;
    }
    if (typeof s.donateUrl === 'string') {
        const u = safeHttpsUrl(s.donateUrl);
        if (u)
            out.donateUrl = u;
    }
    /* ── עיצוב-דף-התרומות: שדות חדשים (allowlist + תקרות) ── */
    const imgUrl = (v) => (typeof v === 'string' ? safeHttpsUrl(v) || undefined : undefined);
    const setLT = (k, v, max) => {
        const t = normLocalized(v, max);
        if (t)
            out[k] = t;
    };
    const hi = imgUrl(s.heroImage);
    if (hi)
        out.heroImage = hi;
    setLT('heroTitle', s.heroTitle, 80);
    setLT('brandLine', s.brandLine, 60);
    setLT('heroBadge', s.heroBadge, 80);
    setLT('titleAccent', s.titleAccent, 60);
    setLT('servicesHeading', s.servicesHeading, 80);
    setLT('microCopy', s.microCopy, 120);
    setLT('ticker', s.ticker, 160);
    setLT('storyTitle', s.storyTitle, 120);
    setLT('storyTitleAccent', s.storyTitleAccent, 80);
    setLT('storyBadge', s.storyBadge, 80);
    setLT('donateNote', s.donateNote, 240);
    if (Array.isArray(s.marquee)) {
        const mq = s.marquee.map((m) => normLocalized(m, 80)).filter((m) => !!m).slice(0, 16);
        if (mq.length)
            out.marquee = mq;
    }
    if (s.calc && typeof s.calc === 'object' && !Array.isArray(s.calc)) {
        const c = s.calc;
        const calc = {};
        const amt = sitePosNum(c.unitAmount);
        if (amt !== undefined)
            calc.unitAmount = amt;
        const unit = normLocalized(c.unit, 60);
        if (unit)
            calc.unit = unit;
        const note = normLocalized(c.note, 120);
        if (note)
            calc.note = note;
        if (Object.keys(calc).length)
            out.calc = calc;
    }
    if (Array.isArray(s.tiers)) {
        const tiers = s.tiers.map((tr) => {
            if (!tr || typeof tr !== 'object')
                return null;
            const o = tr;
            const name = normLocalized(o.name, 60);
            if (!name)
                return null;
            const t = { name };
            const amt = sitePosNum(o.amount);
            if (amt !== undefined)
                t.amount = amt;
            const period = normLocalized(o.period, 40);
            if (period)
                t.period = period;
            if (Array.isArray(o.perks)) {
                const perks = o.perks.map((p) => normLocalized(p, 100)).filter((p) => !!p).slice(0, 8);
                if (perks.length)
                    t.perks = perks;
            }
            if (o.featured === true)
                t.featured = true;
            const url = imgUrl(o.url);
            if (url)
                t.url = url;
            return t;
        }).filter((x) => !!x).slice(0, 6);
        if (tiers.length)
            out.tiers = tiers;
    }
    if (Array.isArray(s.testimonials)) {
        const items = s.testimonials.map((tt) => {
            if (!tt || typeof tt !== 'object')
                return null;
            const o = tt;
            const quote = normLocalized(o.quote, 400);
            if (!quote)
                return null;
            const t = { quote };
            const author = siteStr(o.author, 80);
            if (author)
                t.author = author;
            const role = normLocalized(o.role, 80);
            if (role)
                t.role = role;
            return t;
        }).filter((x) => !!x).slice(0, 12);
        if (items.length)
            out.testimonials = items;
    }
    if (Array.isArray(s.faq)) {
        const items = s.faq.map((f) => {
            if (!f || typeof f !== 'object')
                return null;
            const o = f;
            const q = normLocalized(o.q, 200);
            const a = normLocalized(o.a, 800);
            return q && a ? { q, a } : null;
        }).filter((x) => !!x).slice(0, 20);
        if (items.length)
            out.faq = items;
    }
    if (Array.isArray(s.events)) {
        const items = s.events.map((e) => {
            if (!e || typeof e !== 'object')
                return null;
            const o = e;
            const title = normLocalized(o.title, 120);
            if (!title)
                return null;
            const ev = { title };
            const date = siteStr(o.date, 30);
            if (date)
                ev.date = date;
            const meta = normLocalized(o.meta, 120);
            if (meta)
                ev.meta = meta;
            const url = imgUrl(o.url);
            if (url)
                ev.url = url;
            return ev;
        }).filter((x) => !!x).slice(0, 12);
        if (items.length)
            out.events = items;
    }
    if (Array.isArray(s.partners)) {
        const items = s.partners.map((p) => {
            if (!p || typeof p !== 'object')
                return null;
            const o = p;
            const name = siteStr(o.name, 80);
            if (!name)
                return null;
            const pt = { name };
            const logo = imgUrl(o.logo);
            if (logo)
                pt.logo = logo;
            const url = imgUrl(o.url);
            if (url)
                pt.url = url;
            return pt;
        }).filter((x) => !!x).slice(0, 24);
        if (items.length)
            out.partners = items;
    }
    if (s.transparency && typeof s.transparency === 'object' && !Array.isArray(s.transparency)) {
        const o = s.transparency;
        const tr = {};
        const heading = normLocalized(o.heading, 120);
        if (heading)
            tr.heading = heading;
        const text = normLocalized(o.text, 600);
        if (text)
            tr.text = text;
        const url = imgUrl(o.reportsUrl);
        if (url)
            tr.reportsUrl = url;
        if (Array.isArray(o.badges)) {
            const badges = o.badges.map((b) => normLocalized(b, 60)).filter((b) => !!b).slice(0, 6);
            if (badges.length)
                tr.badges = badges;
        }
        if (Object.keys(tr).length)
            out.transparency = tr;
    }
    /* ── סיפור: מייסד/ת + ציר-זמן ── */
    if (s.founder && typeof s.founder === 'object' && !Array.isArray(s.founder)) {
        const o = s.founder;
        const f = {};
        const name = normLocalized(o.name, 80);
        if (name)
            f.name = name;
        const quote = normLocalized(o.quote, 200);
        if (quote)
            f.quote = quote;
        const photo = imgUrl(o.photo);
        if (photo)
            f.photo = photo;
        if (Object.keys(f).length)
            out.founder = f;
    }
    if (Array.isArray(s.timeline)) {
        const items = s.timeline.map((m) => {
            if (!m || typeof m !== 'object')
                return null;
            const o = m;
            const year = siteStr(o.year, 12);
            const title = normLocalized(o.title, 120);
            if (!year || !title)
                return null;
            const it = { year, title };
            const note = normLocalized(o.note, 160);
            if (note)
                it.note = note;
            return it;
        }).filter((x) => !!x).slice(0, 10);
        if (items.length)
            out.timeline = items;
    }
    if (s.growth && typeof s.growth === 'object' && !Array.isArray(s.growth)) {
        const o = s.growth;
        const g = {};
        const label = normLocalized(o.label, 120);
        if (label)
            g.label = label;
        const delta = siteStr(o.delta, 40);
        if (delta)
            g.delta = delta;
        if (Array.isArray(o.points)) {
            const pts = o.points.map((p) => (typeof p === 'number' && Number.isFinite(p) ? Math.max(0, Math.min(1, p)) : null)).filter((p) => p !== null).slice(0, 40);
            if (pts.length >= 2)
                g.points = pts;
        }
        if (Object.keys(g).length)
            out.growth = g;
    }
    if (Array.isArray(s.paymentMethods)) {
        const items = s.paymentMethods.map((p) => {
            if (!p || typeof p !== 'object')
                return null;
            const o = p;
            const label = normLocalized(o.label, 60);
            const detail = normLocalized(o.detail, 200);
            if (!label || !detail)
                return null;
            const pm = { label, detail };
            if (o.ltr === true)
                pm.ltr = true;
            return pm;
        }).filter((x) => !!x).slice(0, 6);
        if (items.length)
            out.paymentMethods = items;
    }
    if (s.contactForm && typeof s.contactForm === 'object' && !Array.isArray(s.contactForm)) {
        const o = s.contactForm;
        const cf = {};
        if (o.enabled === true)
            cf.enabled = true;
        else if (o.enabled === false)
            cf.enabled = false;
        const note = normLocalized(o.note, 200);
        if (note)
            cf.note = note;
        if (Object.keys(cf).length)
            out.contactForm = cf;
    }
    return Object.keys(out).length ? out : undefined;
}
export function normalizeConfig_ORIG(raw) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw))
        return null;
    const c = raw;
    if (typeof c.slug !== 'string' && typeof c.orgName !== 'string' && typeof c.theme !== 'string') {
        return null;
    }
    const cfg = {
        ...DEFAULT_CONFIG,
        ...c,
        slug: typeof c.slug === 'string' && c.slug ? c.slug : DEFAULT_CONFIG.slug,
        orgName: typeof c.orgName === 'string' ? c.orgName : DEFAULT_CONFIG.orgName,
        theme: typeof c.theme === 'string' && c.theme ? c.theme : DEFAULT_CONFIG.theme,
        modules: c.modules && typeof c.modules === 'object' && !Array.isArray(c.modules) ? { ...c.modules } : {},
        features: c.features && typeof c.features === 'object' && !Array.isArray(c.features)
            ? { ...c.features }
            : {},
        terms: c.terms && typeof c.terms === 'object' && !Array.isArray(c.terms) ? { ...c.terms } : {},
    };
    const fb = normalizeFirebase(c.firebase);
    if (fb)
        cfg.firebase = fb;
    else
        delete cfg.firebase;
    // נתיבי-שורש בענן (CLOUD2) — רק true מפורש נשמר; כל השאר = orgs/{slug}
    if (c.cloudRoot === true)
        cfg.cloudRoot = true;
    else
        delete cfg.cloudRoot;
    // מסלול-B — פיצול-תרומות: רק true מפורש נשמר (off-by-default; השורש פטור ב-donationSplitOn).
    if (c.donationSplit === true)
        cfg.donationSplit = true;
    else
        delete cfg.donationSplit;
    // אכיפת-תומכים — רק true מפורש נשמר (off-by-default; ארגוני-פלטפורמה בלבד).
    if (c.supporterEnforce === true)
        cfg.supporterEnforce = true;
    else
        delete cfg.supporterEnforce;
    // הרחבות (INTEGRATIONS גל א׳) — חיטוי: רק מפתחות מה-allowlist (שגיאת-כתיב
    // לא נבלעת בשקט — ביקורת 4.8) ורק רשומות {enabled:boolean}. ריק ⇒ מוסר.
    const intsRaw = c.integrations;
    if (intsRaw && typeof intsRaw === 'object' && !Array.isArray(intsRaw)) {
        const ints = {};
        for (const [k, v] of Object.entries(intsRaw)) {
            if (!INTEGRATION_KEYS.includes(k))
                continue;
            if (v && typeof v === 'object' && !Array.isArray(v) && typeof v.enabled === 'boolean') {
                const entry = { enabled: v.enabled };
                // גל ג׳: הגדרות-מחרוזת מה-allowlist בלבד (payUrl וכו') — השאר נזרק
                for (const s of INTEGRATION_SETTING_KEYS[k] ?? []) {
                    const sv = v[s];
                    if (typeof sv === 'string' && sv.trim())
                        entry[s] = sv.trim();
                }
                ints[k] = entry;
            }
        }
        if (Object.keys(ints).length)
            cfg.integrations = ints;
        else
            delete cfg.integrations;
    }
    else
        delete cfg.integrations;
    // תבניות-הודעה (#12) — allowlist ‏TEMPLATE_KEYS, מחרוזות בלבד, תקרת-אורך 500
    const tplRaw = c.templates;
    if (tplRaw && typeof tplRaw === 'object' && !Array.isArray(tplRaw)) {
        const tpl = {};
        for (const [k, v] of Object.entries(tplRaw)) {
            if (!TEMPLATE_KEYS.includes(k))
                continue;
            if (typeof v === 'string' && v.trim())
                tpl[k] = v.trim().slice(0, 500);
        }
        if (Object.keys(tpl).length)
            cfg.templates = tpl;
        else
            delete cfg.templates;
    }
    else
        delete cfg.templates;
    // מיילי-אדמין — רק מחרוזות לא-ריקות; ריק/לא-מערך → מוסר (אין הגבלה)
    const admins = Array.isArray(c.adminEmails)
        ? c.adminEmails.filter((e) => typeof e === 'string' && e.trim() !== '')
        : [];
    if (admins.length)
        cfg.adminEmails = admins;
    else
        delete cfg.adminEmails;
    // תפקידים (P3 פריט 15) — מפת מורות מייל→teacherId, רק זוגות מחרוזת לא-ריקים
    const rolesRaw = c.roles;
    const teachersRaw = rolesRaw && typeof rolesRaw === 'object' && rolesRaw.teachers && typeof rolesRaw.teachers === 'object'
        ? rolesRaw.teachers
        : null;
    if (teachersRaw) {
        const teachers = {};
        for (const [k, v] of Object.entries(teachersRaw))
            if (k.trim() && typeof v === 'string' && v.trim())
                teachers[k.trim()] = v.trim();
        if (Object.keys(teachers).length)
            cfg.roles = { teachers };
        else
            delete cfg.roles;
    }
    else
        delete cfg.roles;
    // טלפוניה (downstream) — חיטוי allowlist מלא; חסר/לא-אובייקט ⇒ מוסר (ה-spread
    // של ...c היה מעביר telephony לא-מחוטא, לכן חובה set/delete מפורש).
    const tel = normalizeTelephony(c.telephony);
    if (tel)
        cfg.telephony = tel;
    else
        delete cfg.telephony;
    // זהות-ורטיקל חזותית (16.8) — אימוג'י-ארגון: מחרוזת קצרה בלבד (glyph),
    // תקרת-אורך 12 (אימוג'י מרובה-נקודות-קוד). ריק/לא-מחרוזת ⇒ מוסר (ביט-זהה להיום).
    if (typeof c.emoji === 'string' && c.emoji.trim())
        cfg.emoji = c.emoji.trim().slice(0, 12);
    else
        delete cfg.emoji;
    // סגנון-תנועה — allowlist בלבד (calm/snappy/bold); כל ערך אחר ⇒ מוסר.
    if (typeof c.motion === 'string' && MOTION_KEYS.includes(c.motion))
        cfg.motion = c.motion;
    else
        delete cfg.motion;
    // צבע-מותאם-ידני (provenance) — רק true מפורש נשמר.
    if (c.accentCustom === true)
        cfg.accentCustom = true;
    else
        delete cfg.accentCustom;
    // 🔴 נחיל-אבטחה 16.8 — חיטוי accent: הערך מוזרק ל-CSS `--accent` (applyTheme,
    // setProperty) ונצרך כ-background ⇒ ערך זדוני מהענן כמו `url('https://attacker/b.gif')`
    // היה מבצע GET-מאולץ מכל דפדפן-עובד (ביקון-מעקב). מתירים רק צבע-CSS אמיתי:
    // hex · rgb/rgba/hsl/hsla (ספרות/פסיקים/רווח/%/. בלבד) · מילת-צבע. אחרת מוסר.
    if (typeof cfg.accent === 'string' && isSafeAccent(cfg.accent.trim()))
        cfg.accent = cfg.accent.trim();
    else
        delete cfg.accent;
    // אתר-ציבורי — חיטוי allowlist מלא (ה-spread של ...c היה מעביר site לא-מחוטא,
    // לכן חובה set/delete מפורש). חסר/לא-אובייקט ⇒ מוסר (⇒ אין אתר, ביט-זהה להיום).
    const site = normalizeSite(c.site);
    if (site)
        cfg.site = site;
    else
        delete cfg.site;
    // הגנת-מקור (16.8) — allowlist מארחים: מערך-מחרוזות מנוקה (עד 12, כ"א ≤120).
    if (Array.isArray(c.allowedHosts)) {
        const hosts = c.allowedHosts.filter((h) => typeof h === 'string' && !!h.trim()).map((h) => h.trim().slice(0, 120)).slice(0, 12);
        if (hosts.length)
            cfg.allowedHosts = hosts;
        else
            delete cfg.allowedHosts;
    }
    else
        delete cfg.allowedHosts;
    return cfg;
}
export function normalizeConfig(raw, __opt = {}) {
    const base = normalizeConfig_ORIG(raw);
    if (__opt.strict !== true)
        return base; // ← default: החזק לא נשבר (ביט-זהה)
    if (base !== null && base !== undefined && base !== '')
        return base; // המקורי כבר פסל — כבד אותו
    if (typeof raw.slug === 'string' && raw.slug && !isValidSlug(raw.slug))
        return 'slug לא חוקי';
    return base;
}
