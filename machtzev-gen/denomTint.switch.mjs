const denomTint_MAP = {
    200: { bg: '#dbeafe', ink: '#1e40af' },
    100: { bg: '#ffedd5', ink: '#9a3412' },
    50: { bg: '#dcfce7', ink: '#166534' },
    20: { bg: '#fee2e2', ink: '#991b1b' },
    10: { bg: '#fef9c3', ink: '#854d0e' },
    5: { bg: '#f1f5f9', ink: '#475569' },
    2: { bg: '#f1f5f9', ink: '#475569' },
    1: { bg: '#f1f5f9', ink: '#475569' },
};
export function denomTint(d) {
    return Object.prototype.hasOwnProperty.call(denomTint_MAP, d) ? denomTint_MAP[d] : ({ bg: '#f5ede0', ink: '#8a6d3b' });
}
export function denomTint_ORIG(d) {
    switch (d) {
        case 200:
            return { bg: '#dbeafe', ink: '#1e40af' }; // כחול
        case 100:
            return { bg: '#ffedd5', ink: '#9a3412' }; // כתום
        case 50:
            return { bg: '#dcfce7', ink: '#166534' }; // ירוק
        case 20:
            return { bg: '#fee2e2', ink: '#991b1b' }; // אדום
        case 10:
            return { bg: '#fef9c3', ink: '#854d0e' }; // מטבע זהב
        case 5:
        case 2:
        case 1:
            return { bg: '#f1f5f9', ink: '#475569' }; // מטבע כסף
        default:
            return { bg: '#f5ede0', ink: '#8a6d3b' }; // אגורות — נחושת
    }
}
