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
function diffCount(d) {
    return d.features.length + d.terms.length + d.modulesOff.length + d.integrationsOn.length;
}
export function board_OrgConfig_to_number(x, opts = {}) {
    try {
        x = wizardDiff(x, opts.featuredef, opts.termdef);
    }
    catch {
        return { ok: false, at: 'wizardDiff', value: null };
    }
    try {
        x = diffCount(x);
    }
    catch {
        return { ok: false, at: 'diffCount', value: null };
    }
    return { ok: true, value: x };
}
