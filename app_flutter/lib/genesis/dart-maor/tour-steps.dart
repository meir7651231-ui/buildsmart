// חוט · tour-steps — סינון+מיתוג צעדי-הסיור. חוזה: tour-steps.contract.md
// המרה 1:1 מ-new/atoms/tour-steps.mjs (מוצא: maor/src/lib/tour.ts:64-75).
// שקעים: steps (היה TOUR_STEPS) · isModuleOn · termOf. אפס-import של אטום אחר.

/// truthiness של JS (חוק 7): ''/0/-0/NaN/false/null(=undefined) כוזבים.
bool _falsy(dynamic v) =>
    v == null ||
    v == false ||
    v == '' ||
    (v is num && (v == 0 || v.isNaN));

/// String.prototype.replace של JS עם תבנית-מחרוזת: החלפה ראשונה בלבד,
/// כולל סמנטיקת $ בתחליף ($$ · $& · $` · $'). אין תבנית ⇒ המחרוזת עצמה.
String _jsReplaceFirst(String str, String pattern, String replacement) {
  final i = str.indexOf(pattern);
  if (i < 0) return str;
  final before = str.substring(0, i);
  final after = str.substring(i + pattern.length);
  final sb = StringBuffer();
  for (var j = 0; j < replacement.length; j++) {
    final c = replacement[j];
    if (c == r'$' && j + 1 < replacement.length) {
      final n = replacement[j + 1];
      if (n == r'$') {
        sb.write(r'$');
        j++;
        continue;
      }
      if (n == '&') {
        sb.write(pattern);
        j++;
        continue;
      }
      if (n == '`') {
        sb.write(before);
        j++;
        continue;
      }
      if (n == "'") {
        sb.write(after);
        j++;
        continue;
      }
    }
    sb.write(c);
  }
  return before + sb.toString() + after;
}

/// בניית צעדי-הסיור: סינון לפי מודולים פעילים (צעד בלי module תמיד נשאר)
/// + מיתוג-מחדש דרך termOf. בלי config ⇒ הצעד מוחזר זהה-זהות (אפס-העתקה).
List<dynamic> tourSteps(
    List<dynamic> steps, dynamic isModuleOn, dynamic termOf, Map<String, String> T2, [dynamic config]) {
  dynamic t(String k, String fb) =>
      _falsy(config) ? fb : termOf(config, k, fb);

  dynamic loc(dynamic s) {
    final origCaption = s['caption'] as String;
    var caption = _jsReplaceFirst(
        origCaption, T2['k1']!, '${T2['k2']!}${t('nav.families', 'משפחות')}');
    caption = _jsReplaceFirst(
        caption, T2['k5']!, '${T2['k2']!}${t('nav.courses', 'חוגים')}');
    caption = _jsReplaceFirst(
        caption, T2['k8']!, '${T2['k9']!}${t('nav.courses', 'חוגים')}');
    final origAnchor = s['anchorText'];
    final anchorText = origAnchor == T2['k10']!
        ? '${T2['k11']!}${t('entity.course', 'חוג')}'
        : origAnchor;
    return caption == origCaption && anchorText == origAnchor
        ? s
        : {
            ...(s as Map),
            'caption': caption,
            'anchorText': anchorText,
          };
  }

  return steps
      .where((s) => _falsy(s['module']) || !_falsy(isModuleOn(s['module'])))
      .map(loc)
      .toList();
}
