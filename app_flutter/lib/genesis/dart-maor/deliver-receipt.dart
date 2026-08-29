/// חוט · deliver-receipt — מברז מסירת-קבלה: 'pdf' ⇒ הדפסה, אחרת ⇒ הורדת-טקסט.
/// המרה נאמנה מ-new/atoms/deliver-receipt.mjs (חוק-4: המקור קדוש).
/// השכנים printReceipt/downloadReceipt הוזרקו כשקעים (חוק-1 — אפס import פנימי).
/// המקור מחזיר undefined ⇒ ב-Dart פונקציית void (אין ערך-החזרה).
void deliverReceipt(
  dynamic o,
  dynamic fmt,
  void Function(dynamic) printReceipt,
  void Function(dynamic) downloadReceipt,
) {
  if (fmt == 'pdf') {
    printReceipt(o);
  } else {
    downloadReceipt(o);
  }
}
