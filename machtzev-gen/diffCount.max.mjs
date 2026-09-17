// 🤖 AUTO-EMITTED by gen-max — diffCount (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
export function diffCount_ORIG(d) {
    return d.features.length + d.terms.length + d.modulesOff.length + d.integrationsOn.length;
}
function wizardDiff(cfg, features, terms) {
    const optIn = new Set(features.filter((f) => f.optIn).map((f) => f.key));
    const featChanged = [];
    for (const [k, v] of Object.entries(cfg.features ?? {})) {
        if (v === false)
            featChanged.push(k);
        else if (v === true && optIn.has(k))
            featChanged.push(k);
    }
    const termChanged = terms
        .filter((t) => {
        const ov = (cfg.terms?.[t.key] ?? '').trim();
        return ov !== '' && ov !== t.fallback;
    })
        .map((t) => t.key);
    const modulesOff = Object.entries(cfg.modules ?? {})
        .filter(([, v]) => v === false)
        .map(([k]) => k);
    const integrationsOn = Object.entries(cfg.integrations ?? {})
        .filter(([, v]) => v?.enabled === true)
        .map(([k]) => k);
    return { features: featChanged, terms: termChanged, modulesOff, integrationsOn };
}
export function diffCount(d) { return diffCount_ORIG(d); }
export function diffCount_fromSource(cfg, features, terms) { return diffCount_ORIG(wizardDiff(cfg, features, terms)); }
