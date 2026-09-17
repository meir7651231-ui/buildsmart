function gradeFits(c, childGrade) {
    if (!c.gradeMin && !c.gradeMax)
        return true;
    const gi = gradeIndex(childGrade);
    if (gi < 0)
        return true;
    const lo = gradeIndex(c.gradeMin);
    const hi = gradeIndex(c.gradeMax);
    if (lo >= 0 && gi < lo)
        return false;
    if (hi >= 0 && gi > hi)
        return false;
    return true;
}
export function board_Course_to_boolean(x, opts = {}) {
    try {
        x = gradeFits(x, opts.arg);
    }
    catch {
        return { ok: false, at: 'gradeFits', value: null };
    }
    return { ok: true, value: x };
}
