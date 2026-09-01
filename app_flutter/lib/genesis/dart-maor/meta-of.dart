// חוט · meta-of — גוף מסמך meta/org: כל שדות ה-Db שאינם אוספי-ישויות (בלי v).
// המרה מ-JS (new/atoms/meta-of.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חוזה: new/atoms/meta-of.contract.md. אפס import (רק dart-core).
// db = Map (שדה-חסר ⇒ null, כמו undefined ב-JS); הפלט Map עם בדיוק 16 מפתחות
// בסדר-החוזה. הטלה טהורה: ערכי-עומק עוברים בהפניה (identical), לא העתקה.
// שדה חסר ⇒ המפתח קיים בפלט עם null (undefined ב-JS) — literal-Map תמיד מכניס
// את המפתח (LinkedHashMap שומר סדר-הכנסה = סדר-החוזה).
Map<String, dynamic> metaOf(Map<String, dynamic> db) {
  return {
    'orgName': db['orgName'],
    'orgSite': db['orgSite'],
    'orgDonate': db['orgDonate'],
    'orgGoal': db['orgGoal'],
    'budget': db['budget'],
    'usdRate': db['usdRate'],
    'audit': db['audit'], // לוג-פעולות (#10) — רוכב על meta כמו attnDone
    'notif': db['notif'],
    'reports': db['reports'],
    'ui': db['ui'],
    'seq': db['seq'],
    'receiptSeq': db['receiptSeq'],
    'donationSeq': db['donationSeq'],
    'shopReceiptSeq': db['shopReceiptSeq'],
    'attnDone': db['attnDone'],
    'savedAt': db['savedAt'],
  };
}
