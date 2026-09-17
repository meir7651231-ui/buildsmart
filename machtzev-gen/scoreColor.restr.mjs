const scoreColor_TIERS = [
    { min: 80, v: { bg: '#fdeaea', c: '#b91c1c' } },
    { min: 60, v: { bg: '#fdf1d4', c: '#9a6414' } },
    { min: -Infinity, v: { bg: '#f2e8dc', c: '#8b6b3d' } },
];
export function scoreColor(score) {
    return (scoreColor_TIERS.find((t) => score >= t.min) ?? scoreColor_TIERS[scoreColor_TIERS.length - 1]).v;
}
export function scoreColor_ORIG(score) {
    if (score >= 80)
        return { bg: '#fdeaea', c: '#b91c1c' };
    if (score >= 60)
        return { bg: '#fdf1d4', c: '#9a6414' };
    return { bg: '#f2e8dc', c: '#8b6b3d' };
}
