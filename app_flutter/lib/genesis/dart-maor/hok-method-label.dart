// חוט · hok-method-label — תווית שיטת הו"ק (בנק/אשראי/מזומן/אחר). חוזה: hok-method-label.contract.md
// המרה מ-JS (new/atoms/hok-method-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4). אפס-import (dart-core בלבד).
String hokMethodLabel(String m, {required String Function(String) term}) {
  if (m == 'bank') return term('hvk-bnkayt');
  if (m == 'card') return term('ashray-bslykh');
  if (m == 'cash') return term('mzvmn-chvdshy');
  // JS `m || 'אחר'`: מחרוזת ריקה = falsy ⇒ 'אחר'; אחרת m עצמו (כלל-7: truthiness מפורש).
  return m.isEmpty ? term('achr') : m;
}
