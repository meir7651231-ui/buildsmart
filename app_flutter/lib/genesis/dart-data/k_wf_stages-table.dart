// 🗄️ טבלה-מוקלדת · kWfStages (const List<WfStage>) — אטום-דאטה משותף (G69 · חצב-AST, חוק-4 — verbatim מהמקור, כולל סגירת-הטיפוסים).
// מוצא: buildsmart/app_flutter/lib/logic/workflow_engine.dart:24
// טוהר: אפס-import; 1 הצהרות-סגירה + הטבלה. פונקציות-מדף **מייבאות** את הקובץ הזה (ייבוא-לפי-מוצא בחצב) במקום להטביע עותק.
// גודל: 5 רשומות (נמדד בהרצה).
// ייצוא: kWfStages ← buildsmart/app_flutter/lib/logic/workflow_engine.dart
// ייצוא: WfStage ← buildsmart/app_flutter/lib/logic/workflow_engine.dart

/// חמשת השלבים בסדר קבוע (אינדקס 0..4). המפתחות מסתדרים ל-'new'..'done'.
enum WfStage { intake, prep, ready, dispatch, done }

const List<WfStage> kWfStages = [
  WfStage.intake,
  WfStage.prep,
  WfStage.ready,
  WfStage.dispatch,
  WfStage.done,
];
