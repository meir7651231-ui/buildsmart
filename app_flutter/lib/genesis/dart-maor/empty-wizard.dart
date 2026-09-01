/// אטום-קבוע · empty-wizard — קודם אוטומטית (צילום-ערך). חוזה: empty-wizard.contract.md
///
/// המקור (JS) הוא אובייקט-קבוע יחיד. כאן פונקציית-top-level טהורה שמחזירה
/// עותק-טרי בכל קריאה (מוטביליות בטוחה) — הערכים זהים-לחלוטין למקור.
/// שגיאת השלב הנוכחי (0-based) — null = תקין להמשך. שלב הצרכים (2) אופציונלי.
/// השלב האחרון (4) עובר דרך signUpError — אותה ולידציה כמו הטופס הרזה.
///
/// אפס-import (dart-core בלבד).
Map<String, dynamic> emptyWizard() {
  return <String, dynamic>{
    'industry': '',
    'size': '',
    'needs': <dynamic>[],
    'orgName': '',
    'contactName': '',
    'phone': '',
    'email': '',
    'password': '',
    'password2': '',
  };
}
