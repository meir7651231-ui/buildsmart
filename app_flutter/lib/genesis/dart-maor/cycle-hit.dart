// חוט · cycle-hit — פגיעת מחזור לפי שארית מול סף. מנגנון עיוור: אפס קבועים, אפס משמעות.
// תאום נאמן ל-new/atoms/cycle-hit.mjs (חוק-4). תחום: מונים אי-שליליים.
bool cycleHit(int i, int a, int b, int m, int t) => (a * i + b) % m < t;
