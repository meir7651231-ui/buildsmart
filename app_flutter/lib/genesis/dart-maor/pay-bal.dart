/// חוט · pay-bal — יתרת-חוב על שיבוץ: max(0, totalDue + carryBalance − שולם).
/// carryBalance (25.8): יתרת-אשתקד נישאת קדימה (חיובי=חוב, שלילי=זכות); חסר=0 ⇒
/// ביט-זהה לשיבוץ ישן. שקע paidOf מוזרק (חוק-1). מקור: maor courses/lib.ts:312-313.
num payBal(Map e, num Function(Map) paidOf) {
  final num totalDue = (e['totalDue'] as num?) ?? 0;
  final num carry = (e['carryBalance'] as num?) ?? 0;
  final num bal = totalDue + carry - paidOf(e);
  return bal > 0 ? bal : 0;
}
