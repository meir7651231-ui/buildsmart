/// חוט · enrollment-paid-status — סטטוס-תשלום נגזר-אוטומטית.
/// המרה נאמנה מ-new/atoms/enrollment-paid-status.mjs (חוק-4: המקור קדוש).
/// השכנים payBal/paidOf הוזרקו כשקעים (חוק-1 — אפס import פנימי).
/// כללי-המרה: truthiness מפורש (paidFull==true, totalDue||0 ⇒ בדיקת-num).
String enrollmentPaidStatus(
  Map<String, dynamic> e,
  num Function(Map<String, dynamic>) payBal,
  num Function(Map<String, dynamic>) paidOf,
) {
  if (e['paidFull'] == true) return 'paid';
  final td = e['totalDue'];
  final num due = td is num ? td : 0; // e.totalDue || 0 — falsy⇒0
  if (due > 0) {
    return payBal(e) == 0 ? 'paid' : (paidOf(e) > 0 ? 'partial' : 'unpaid');
  }
  return 'unpaid';
}
