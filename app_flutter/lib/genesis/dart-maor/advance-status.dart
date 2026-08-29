/// חוט · advance-status — הסטטוס הבא במסירת-חלוקה (קדימה בלבד).
/// המרה נאמנה מ-new/atoms/advance-status.mjs (חוק-4: המקור קדוש).
/// ORDER היה קבוע פרטי לאותו קובץ — נשאר מקומי, אפס import.
String advanceStatus(String status) {
  const order = ['pickup', 'enroute', 'delivered'];
  final i = order.indexOf(status);
  return (i < 0 || i >= order.length - 1) ? 'delivered' : order[i + 1];
}
