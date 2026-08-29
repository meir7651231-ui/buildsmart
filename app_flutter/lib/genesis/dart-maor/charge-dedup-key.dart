// חוט · charge-dedup-key — מפתח-דדופ לעסקת-סליקה: txn ראשון, נפילה לאסמכתא, ריק ⇒ אין-דדופ.
// חוזה: charge-dedup-key.contract.md
// המרה מ-JS (new/atoms/charge-dedup-key.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// המקור קורא charge.txnId / charge.reference (מחרוזות אופציונליות) ⇒ ב-Dart Map<String,String?>.
// truthiness של JS `x || ''` (null/undefined/'' ⇒ '') מיוצג ב-`?? ''`. אפס-import (dart-core בלבד).
String chargeDedupKey(Map<String, String?> charge) {
  final txn = (charge['txnId'] ?? '').trim();
  if (txn.isNotEmpty) return 'txn:$txn';
  final ref = (charge['reference'] ?? '').trim();
  return ref.isNotEmpty ? 'ref:$ref' : '';
}
