// חוט · wa-birthday-text — נוסח ברכת יום-הולדת לוואטסאפ (פורט-Dart ידני).
// זהה-ביט ל-new/atoms/wa-birthday-text.mjs: האצלה-טהורה לשקעים renderTemplate+orgOf
// (חוק-1 — אפס import פנימי); סדר-הקריאות נשמר (orgOf קודם, בתוך בניית-vars).
String waBirthdayText(String orgName, String firstName, Map<String, dynamic>? cfg,
    dynamic Function(dynamic, String, Map<String, dynamic>) renderTemplate,
    dynamic Function(dynamic) orgOf) {
  return renderTemplate(cfg, 'wa.birthday', {'first': firstName, 'org': orgOf(orgName)});
}
