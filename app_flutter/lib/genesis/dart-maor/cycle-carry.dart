// חוט · cycle-carry — מצטבר מחזורים עם שארית נגררת. מנגנון עיוור: אפס קבועים.
// תאום נאמן ל-new/atoms/cycle-carry.mjs (חוק-4). תחום: מונה אי-שלילי.
int cycleCarry(int n, int base, int p0, int q, int parts) => base * n + (p0 + q * n) ~/ parts;
