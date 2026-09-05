/// חוט · can-issue-receipt — מי מנפיק קבלות-§46 (מקצה-יחיד לרצף הקבלות).
/// המרה נאמנה מ-new/atoms/can-issue-receipt.mjs (חוק-4: המקור קדוש).
/// המקור: `p.superAdmin || p.isManager || p.cloudRoot || !p.cloudConnected`.
/// שקעי-האובייקט p הומרו לפרמטרים-שם בוליאניים (ברירת-מחדל false = base של הבדיקה).
bool canIssueReceipt({
  bool superAdmin = false,
  bool isManager = false,
  bool cloudRoot = false,
  bool cloudConnected = false,
}) {
  return superAdmin || isManager || cloudRoot || !cloudConnected;
}
