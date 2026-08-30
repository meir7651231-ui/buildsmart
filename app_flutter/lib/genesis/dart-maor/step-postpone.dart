// חוט · step-postpone — כלל דחייה צעדי לפי שארית מול סף. מנגנון עיוור.
// תאום נאמן ל-new/atoms/step-postpone.mjs (חוק-4).
int stepPostpone(int d, int m, int k, int t) => (m * (d + 1)) % k < t ? d + 1 : d;
