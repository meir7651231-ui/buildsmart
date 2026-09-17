// 🔧 AUTO-FIXED by gen-max — supTier: קבועי-קסם חולצו לפרמטר-opts (ברירת-מחדל=מקורי ⇒ אפס-אובדן). אל תערוך ביד.
export function supTier_ORIG(sc) {
    if (sc >= 800)
        return { label: 'זהב', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
    if (sc >= 600)
        return { label: 'כסף', bg: '#eef1f5', c: '#44546a', dot: '#94a3b8' };
    if (sc >= 400)
        return { label: 'ארד', bg: '#f6ead1', c: '#9a6414', dot: '#d97706' };
    return { label: 'רדומה', bg: '#eceae2', c: '#8b8474', dot: '#a8a29e' };
}
export function supTier(sc, opts = {}) {
    if (sc >= (opts.k0 ?? 800))
        return { label: 'זהב', bg: '#fdf3dd', c: '#9a6414', dot: '#f3c76b' };
    if (sc >= (opts.k1 ?? 600))
        return { label: 'כסף', bg: '#eef1f5', c: '#44546a', dot: '#94a3b8' };
    if (sc >= (opts.k2 ?? 400))
        return { label: 'ארד', bg: '#f6ead1', c: '#9a6414', dot: '#d97706' };
    return { label: 'רדומה', bg: '#eceae2', c: '#8b8474', dot: '#a8a29e' };
}
