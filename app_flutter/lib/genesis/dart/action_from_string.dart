// ⚛️ אטום-Dart (דרגת-חוזה) · actionFromString
// מוצא: buildsmart/app_flutter/lib/logic/assistant_intent.dart:99-123
//        (_actionFromString; חוק-4 — התנהגות זהה, לא-משופרת. קובץ-המקור הוסר
//        מבנייה-חכמה מאז החציבה; הטיוטה בדרגת-מחצבה היא הקוד-החלוץ הקדוש,
//        וסוקטי-האחים אושרו מול טיוטות-האחיות ב-dart-quarry/*assistant_intent*).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט dart:core).
//
// אח שהוטבע (טיפוס-שכן קטן, כלל-1): ה-enum `AssistantAction` — טיפוס-ההחזרה של
//        האטום. חבריו נקבעים מלואם ע"י ה-switch עצמו (חמשת ה-case-ים ⇒ חמשת
//        החברים, בסדר-ההופעה verbatim מהטיוטה). הוטבע inline כדי לקיים חוק-1
//        (אטום עצמאי, אפס import של אטום-אחר). אין סוקט (שקעים-מועמדים: —).
// פרטי-במקור: `_actionFromString` (עוזר) — הוצא-לחוזה כ-top-level ציבורי
//        `actionFromString` (דגם branch_label: _branchLabel⇒branchLabel).
//
// קלט:  s — מחרוזת-הפעולה מתשובת-המודל (השוואה מדויקת, תלוית-רישיות).
// פלט:  חבר-ה-enum התואם לשם המדויק, או null לכל מחרוזת אחרת (default).

/// The CLOSED assistant action set (BuildSmart procurement copilot).
/// Members verbatim from the switch's case-order (assistant_intent.dart:99-123).
enum AssistantAction {
  answer,
  findProduct,
  summarizeOrders,
  checkBudget,
  addToCart,
}

/// Map a model-reply action string to a trusted [AssistantAction].
/// Exact, case-sensitive match; any unknown string → null (the closed-set guard).
/// Verbatim behaviour of assistant_intent.dart:99-123.
AssistantAction? actionFromString(String s) {
  switch (s) {
    case 'answer':
      return AssistantAction.answer;
    case 'findProduct':
      return AssistantAction.findProduct;
    case 'summarizeOrders':
      return AssistantAction.summarizeOrders;
    case 'checkBudget':
      return AssistantAction.checkBudget;
    case 'addToCart':
      return AssistantAction.addToCart;
    default:
      return null;
  }
}
