/// חוט · telephony-on — מודול-הטלפוניה פעיל רק על enabled:true מפורש (opt-in, חסר=כבוי).
/// חוזה: telephony-on.contract.md
/// מוצא: maor/src/lib/config.ts:90-92. אפס import של אטום אחר.
/// JS: `cfg.telephony?.enabled === true` — optional-chaining ⇒ חסר=false;
/// ‏=== מחמיר ⇒ רק boolean true מדליק ('true' מחרוזת = כבוי).
bool telephonyOn(dynamic cfg) {
  final t = (cfg is Map) ? cfg['telephony'] : null;
  return t is Map && t['enabled'] == true;
}
