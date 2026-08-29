// חוט · wizard-step-error — ולידציית-שלב באשף-ההרשמה (5 שלבים); null = תקין.
// פורט-Dart ידני, זהה-ביט ל-new/atoms/wizard-step-error.mjs.
// הערות-המרה: ‏s.industry/s.size = truthiness-JS (חוק-7: ''/null/0 כוזבים);
// ‏s.orgName.trim() — כמו-JS: שדה-חסר יפיל (המצב מגיע מלא מהאשף, בחוזה);
// ‏signUpError(...) || null — '' כוזב ⇒ null (נרמול-הצלחה). שקע מוזרק (חוק-1).
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

dynamic wizardStepError(dynamic step, dynamic s, dynamic Function(dynamic, dynamic, dynamic, dynamic, dynamic, dynamic) signUpError) {
  switch (step) {
    case 0:
      return _truthy(s['industry']) ? null : 'בחרו את תחום העסק כדי להמשיך';
    case 1:
      return _truthy(s['size']) ? null : 'בחרו את גודל הארגון';
    case 2:
      return null; // צרכים — אופציונלי
    case 3:
      if (!_truthy((s['orgName'] as String).trim())) return 'שם הארגון חובה';
      if (!_truthy((s['contactName'] as String).trim())) return 'שם איש קשר חובה';
      if (!_truthy((s['phone'] as String).trim())) return 'טלפון חובה — נחזור אליכם לאישור';
      return null;
    case 4:
      final e = signUpError(s['orgName'], s['contactName'], s['phone'], s['email'], s['password'], s['password2']);
      return _truthy(e) ? e : null;
    default:
      return null;
  }
}
