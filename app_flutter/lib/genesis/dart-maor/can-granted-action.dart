/// חוט · can-granted-action — הרשאת פעולה מוגבלת: מנהל תמיד · אדמין · הדלקה-פר-עובד.
/// המרה נאמנה מ-new/atoms/can-granted-action.mjs (חוק-4: המקור קדוש).
/// השכן isAdminUser נשאר שקע-הצבה (חוק-1 — אפס import פנימי).
/// שוויון קשיח ‏features[key]===true: רק boolean true (מחרוזת 'true' לא נחשבת).
bool canGrantedAction(
  Map<String, dynamic> config,
  String email,
  bool isManager,
  String key,
  bool Function(Map<String, dynamic> config, String email) isAdminUser,
) {
  final features = config['features'];
  return isManager ||
      isAdminUser(config, email) ||
      (features is Map && features[key] == true);
}
