// 🔀 AUTO-RESTRUCTURED — supTier: סולם-if ⇒ טבלת-נתונים+find. API זהה (אפס-אובדן). נתונים מופרדים מלוגיקה.
const supTier_TIERS = [
    { min: 800, v: { label: 'זהב', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' } },
    { min: 600, v: { label: 'כסף', bg: '#eef1f5', c: '#44546a', dot: '#94a3b8' } },
    { min: 400, v: { label: 'ארד', bg: '#f6ead1', c: '#9a6414', dot: '#d97706' } },
    { min: -Infinity, v: { label: 'רדומה', bg: '#eceae2', c: '#8b8474', dot: '#a8a29e' } },
];
export function supTier(sc) {
    return (supTier_TIERS.find((t) => sc >= t.min) ?? supTier_TIERS[supTier_TIERS.length - 1]).v;
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
