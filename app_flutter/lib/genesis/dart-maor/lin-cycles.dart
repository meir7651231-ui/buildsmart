// חוט · lin-cycles — מונה מחזורים ליניארי רצפת חלוקה. מנגנון עיוור: אפס קבועים.
// תאום נאמן ל-new/atoms/lin-cycles.mjs (חוק-4). תחום: מונה חיובי (~/ ≡ floor).
int linCycles(int n, int a, int b, int c) => (a * n - b) ~/ c;
