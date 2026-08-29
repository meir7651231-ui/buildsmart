/// חוט · revert-patch — patch לחזרת תיק-ayin לשלב קודם; לפני 'answer' ⇒ ביטול דגל-הדחיפה.
/// המרה נאמנה מ-new/atoms/revert-patch.mjs (חוק-4: המקור קדוש).
/// השכן stageIndex (מיקום בסדר-השלבים) מוזרק כשקע (חוק-1 — אפס import פנימי).
/// פלט = Map (אובייקט-patch): תמיד {stage}; לפני-'answer' מתווסף answerPushed:false —
/// ב-'answer'/'done' המפתח לא קיים כלל (מקביל ל-'in' של JS).
Map<String, dynamic> revertPatch(dynamic stage, dynamic stageIndex) {
  final patch = <String, dynamic>{'stage': stage};
  if (stageIndex(stage) < stageIndex('answer')) {
    patch['answerPushed'] = false;
  }
  return patch;
}
