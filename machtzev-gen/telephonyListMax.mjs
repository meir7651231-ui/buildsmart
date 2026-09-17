function previewTelephony(tc, orgName, tenantId) {
    const raw = telephonyToTenant(tc, orgName, tenantId);
    const anchor = anchorToday();
    const opts = { anchorDate: anchor, calendarWindow: 400 };
    const v = validateTenant(raw);
    if (!v.ok)
        return { ok: false, errors: v.errors, warnings: v.warnings, rows: [], trust: null, files: null };
    const tenant = v.tenant;
    const built = buildTenant(raw, opts);
    const voiceDid = (tc.numbers.find((n) => n.kind === 'sim' || n.kind === 'virtual') || tc.numbers[0])?.e164 || '';
    const caller = '050-1234567';
    // תרחישים מייצגים: יום-חול בשעות · יום-חול אחרי-שעות · שבת (אם מגודר).
    const rows = [];
    const scenarios = [
        { when: 'יום שלישי 10:00 (בשעות)', call: { did: voiceDid, callerId: caller, dow: 2, hhmm: '10:00' } },
        { when: 'יום שלישי 20:00 (אחרי-שעות)', call: { did: voiceDid, callerId: caller, dow: 2, hhmm: '20:00' } },
        { when: 'שבת 11:00', call: { did: voiceDid, callerId: caller, dow: 6, hhmm: '11:00' } },
    ];
    for (const s of scenarios) {
        const e = explainCall(tenant, s.call, opts);
        rows.push({ when: s.when, caller, summary: e.summary, outcome: e.outcome });
    }
    let trust = null;
    if (built.ok) {
        const tr = trustReport(built);
        trust = {
            grade: tr.grade,
            score: tr.score,
            ready: tr.ready,
            failing: tr.failing.map((c) => ({ label: c.label, detail: c.detail, severity: c.severity })),
        };
    }
    return { ok: true, errors: [], warnings: built.warnings || v.warnings || [], rows, trust, files: built.files || null };
}
function telephonyToTenant(tc, orgName, tenantId) {
    let gw = 0;
    const numbers = (tc.numbers || [])
        .filter((n) => n.e164 && n.e164.trim())
        .map((n) => {
        const base = {
            id: n.id,
            e164: n.e164.trim(),
            label: n.label || n.id,
            type: n.kind,
            onramp: ONRAMP[n.kind],
            channels: CHANNELS[n.kind],
            ...(n.kosher ? { kosher: true } : {}),
        };
        if (n.kind === 'sim') {
            gw += 1;
            base.gatewayChannel = gw;
        }
        return base;
    });
    const firstSim = numbers.find((n) => n.onramp === 'sim-in-gateway');
    const features = {
        'voice.kosher': tc.kosherMode,
        'calendar.hebrew': tc.hebrewCalendar,
        'calendar.shabbat': tc.shabbat,
        'calendar.fasts': tc.fasts,
        'calendar.zmanim': tc.zmanim,
        voicemail: tc.voicemail,
    };
    return {
        tenantId,
        orgName: orgName || 'ארגון',
        timezone: 'Asia/Jerusalem',
        ...(tc.city ? { city: tc.city } : {}),
        officeHours: { days: [...tc.officeDays].sort((a, b) => a - b), start: tc.officeStart, end: tc.officeEnd },
        numbers,
        destinations: {
            office: { ext: [tc.officeExt], ringSeconds: 25 },
            manager: { ext: tc.managerExt, ringSeconds: 30 },
            voicemail: { box: tc.vmBox },
        },
        outbound: { defaultNumberId: firstSim ? firstSim.id : (numbers[0]?.id ?? 'n1') },
        cti: { org: tenantId, mode: 'directory' },
        features,
    };
}
function anchorToday() {
    const d = new Date();
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}
const ONRAMP = {
    sim: 'sim-in-gateway',
    virtual: 'customer-forward',
    whatsapp: 'device-link',
};
const CHANNELS = {
    sim: ['voice'],
    virtual: ['voice'],
    whatsapp: ['whatsapp'],
};
export function telephonyListMax(items, opts = {}) {
    return {
        count: Array.isArray(items) ? items.length : undefined,
        previewTelephony: (() => { try {
            return previewTelephony(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        telephonyToTenant: (() => { try {
            return telephonyToTenant(items, opts.usdRate ?? 1, opts.todayIso ?? '2026-01-01');
        }
        catch {
            return null;
        } })(),
        rows: Array.isArray(items) ? items.map((it) => ({ item: it })) : undefined,
    };
}
export { previewTelephony, telephonyToTenant };
