// חוט · volunteer-load-hint — רמז-קיבולת (לא-חוסם) למתנדב ביום-חלוקה.
// פורט-Dart ידני, זהה-ביט ל-new/atoms/volunteer-load-hint.mjs.
// הערות: ‏maxDeliveries == null תופס גם חסר וגם null — בדיוק ‏== null הרופף של JS
// (undefined≡null בהשוואה-רופפת ⇒ מפתח-חסר-במפה ⇒ null ⇒ אותו ענף; כלל-2 לא-נדרש
// כאן במכוון כי המקור משתמש ב-== ולא ב-===). ‏count >= max — השוואה מספרית ישירה.
// שקע: deliveriesOfVolunteer(db, volId, dayId) ⇒ List (חוק-1).
Map<String, dynamic> volunteerLoadHint(dynamic db, dynamic vol, dynamic dayId,
    List<dynamic> Function(dynamic, dynamic, dynamic) deliveriesOfVolunteer) {
  final count = deliveriesOfVolunteer(db, vol['id'], dayId).length;
  final max = vol['maxDeliveries'];
  if (max == null) return {'count': count, 'over': false};
  return {'count': count, 'over': count >= (max as num)};
}
