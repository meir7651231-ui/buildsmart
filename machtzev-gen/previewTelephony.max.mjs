// 🤖 AUTO-EMITTED by gen-max — previewTelephony (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
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
export function previewTelephony_ORIG(tc, orgName, tenantId) {
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
function emptyTelephonyConfig() {
    return {
        numbers: [{ id: 'n1', e164: '', label: 'קו ראשי', kind: 'sim' }],
        officeDays: [0, 1, 2, 3, 4],
        officeStart: '09:00',
        officeEnd: '17:00',
        officeExt: '101',
        managerExt: '201',
        vmBox: '100',
        city: '',
        kosherMode: false,
        hebrewCalendar: true,
        zmanim: false,
        shabbat: true,
        fasts: false,
        voicemail: true,
    };
}
export function previewTelephony(tc, orgName, tenantId) { return previewTelephony_ORIG(tc, orgName, tenantId); }
export function previewTelephony_fromSource(orgName, tenantId) { return previewTelephony_ORIG(emptyTelephonyConfig(), orgName, tenantId); }
