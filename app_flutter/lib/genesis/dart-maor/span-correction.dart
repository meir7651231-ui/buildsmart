// חוט · span-correction — תיקון מרווחים קדימה ואחורה מול שני ספים. מנגנון עיוור.
// תאום נאמן ל-new/atoms/span-correction.mjs (חוק-4).
int spanCorrection(int prev, int cur, int next, int hi, int lo) =>
    next - cur == hi ? 2 : (cur - prev == lo ? 1 : 0);
