// 🔀 AUTO-RESTRUCTURED — tierOf: סולם-if ⇒ טבלת-נתונים+find. API זהה (אפס-אובדן). נתונים מופרדים מלוגיקה.
const CRED_RED_THRESHOLD = 500;
const tierOf_TIERS = [
    { min: 950, v: { key: 'titan', label: 'טיטאן', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' } },
    { min: 800, v: { key: 'lion', label: 'לביאה', bg: '#e4f5ea', c: '#12803c', dot: '#16a34a' } },
    { min: CRED_RED_THRESHOLD, v: { key: 'pale', label: 'טעון שיפור', bg: '#fdf1d4', c: '#9a6414', dot: '#d97706' } },
    { min: -Infinity, v: { key: 'red', label: 'סיכון נטישה', bg: '#fdeaea', c: '#b91c1c', dot: '#dc2626' } },
];
export function tierOf(score) {
    return (tierOf_TIERS.find((t) => score >= t.min) ?? tierOf_TIERS[tierOf_TIERS.length - 1]).v;
}
export function tierOf_ORIG(score) {
    if (score >= 950)
        return { key: 'titan', label: 'טיטאן', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
    if (score >= 800)
        return { key: 'lion', label: 'לביאה', bg: '#e4f5ea', c: '#12803c', dot: '#16a34a' };
    if (score >= CRED_RED_THRESHOLD)
        return { key: 'pale', label: 'טעון שיפור', bg: '#fdf1d4', c: '#9a6414', dot: '#d97706' };
    return { key: 'red', label: 'סיכון נטישה', bg: '#fdeaea', c: '#b91c1c', dot: '#dc2626' };
}
