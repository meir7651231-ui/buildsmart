/// חוט · set-export-blocked — חישוב מצב שער-יציאת-המידע החדש: דגל-חסימה + התרעה מנורמלת.
/// המרה נאמנה מ-new/atoms/set-export-blocked.mjs (חוק-4: המקור קדוש).
/// ב-JS ‏`onBlocked ?? null` מנרמל undefined⇒null; ב-Dart אין undefined —
/// היעדר-ארגומנט = null (חוק-2), ולכן ההעברה כמות-שהיא שקולה-ביט.
/// ההתרעה עוברת בזהות-הפניה ולעולם אינה נקראת (הקריאה שייכת ל-guardExport).
Map<String, dynamic> setExportBlocked(dynamic isBlocked, [dynamic onBlocked]) {
  return {'blocked': isBlocked, 'notify': onBlocked};
}
