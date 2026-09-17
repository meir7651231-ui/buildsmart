// 🤖 AUTO-EMITTED by gen-max — supTier (transform) מועשר. default ביט-זהה. TARGET_fromSource=פייפליין.
function supScore(sp, rate = 3.7) {
    const tot = supTotalIls(sp, rate);
    const last = supLast(sp);
    const cnt = supCount(sp);
    const days = last
        ? Math.floor((Date.now() - new Date(last + 'T12:00:00').getTime()) / 86400000)
        : 9999;
    const R = days <= 30 ? 350 : days <= 90 ? 280 : days <= 180 ? 200 : days <= 365 ? 120 : 40;
    const F = cnt >= 10 ? 300 : cnt >= 5 ? 230 : cnt >= 3 ? 160 : cnt >= 2 ? 100 : 50;
    const M = tot >= 5000 ? 350 : tot >= 2000 ? 280 : tot >= 1000 ? 210 : tot >= 500 ? 140 : tot >= 100 ? 80 : 40;
    return R + F + M;
}
function supTotalIls(sp, rate = 3.7) {
    return supIls(sp) + supUsd(sp) * rate;
}
function supLast(sp) {
    let m = sp.last || '';
    for (const h of sp.hist ?? [])
        if (h.d > m)
            m = h.d;
    return m;
}
function supCount(sp) {
    return (sp.count || 0) + (sp.hist ?? []).filter((h) => (h.a || 0) > 0).length;
}
function supIls(sp) {
    return (sp.ils || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? 0 : h.a), 0);
}
function supUsd(sp) {
    return (sp.usd || 0) + (sp.hist ?? []).reduce((a, h) => a + (h.c === '$' ? h.a : 0), 0);
}
export function supTier_ORIG(sc) {
    if (sc >= 800)
        return { label: 'זהב', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
    if (sc >= 600)
        return { label: 'כסף', bg: '#eef1f5', c: '#44546a', dot: '#94a3b8' };
    if (sc >= 400)
        return { label: 'ארד', bg: '#f6ead1', c: '#9a6414', dot: '#d97706' };
    return { label: 'רדומה', bg: '#eceae2', c: '#8b8474', dot: '#a8a29e' };
}
function supScoreBins(supporters, rate = 3.7) {
    const bins = Array(10).fill(0);
    for (const sp of supporters)
        bins[Math.min(9, Math.floor(supScore(sp, rate) / 100))]++;
    return bins;
}
export function supTier(sc) { return supTier_ORIG(sc); }
export function supTier_fromSource(supporters, rate) { return supTier_ORIG(supScoreBins(supporters, rate)); }
