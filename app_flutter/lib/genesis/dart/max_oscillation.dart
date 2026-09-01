// ⚛️ אטום-Dart (דרגת-חוזה) · maxOscillation
// תפקיד: אורך-הריצה המרבי של תנודה A-B-A-B בנתיב-מחרוזות (גלאי-לולאה מדשדשת).
// מוצא: buildsmart/app_flutter/lib/logic/intel/funnels.dart:269-283 (‏_maxOscillation; חוק-4 — התנהגות זהה, לא-משופרת).
// אחים-שסוקטו/הוטבעו: אין. האטום עצמאי לחלוטין — קורא רק List<String> ואינדוקס.
//   האחים בטיוטה (IntelInsights, analyzeIntel) הם שכנים סמוכים, לא חלק מהאטום.
// טוהר: פונקציית top-level, אפס import (dart:core בלבד). המקור פרטי (`_`), כאן
//        מקודם ל-public לפי כלל-הגלגול (עוזר עצמאי ⇒ קופסה/חוט).
//
// קלט:  path — נתיב-מזהים (List<String>; במקור רצף מסכים/פעולות בסשן).
// פלט:  int — כמה פעמים (ברצף) חזר path[i]==path[i-2] עם path[i]!=path[i-1],
//        כלומר אורך-הריצה המרבי של דפוס-התנדנדות "הלוך-ושוב".

/// Longest run of an A-B-A-B oscillation in [path].
/// Verbatim behaviour of funnels.dart:269-283 (`_maxOscillation`).
int maxOscillation(List<String> path) {
  var best = 0;
  var run = 0;
  for (var i = 2; i < path.length; i++) {
    if (path[i] == path[i - 2] && path[i] != path[i - 1]) {
      run++;
      if (run > best) best = run;
    } else {
      run = 0;
    }
  }
  return best;
}
