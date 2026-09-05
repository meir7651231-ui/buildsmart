/// חוט · merge-families-by-fields — מיזוג-כפולים לפי בחירת-שדות (בסיס-בטוח + דריסה נבחרת).
/// המרה נאמנה מ-new/atoms/merge-families-by-fields.mjs (חוק-4: המקור קדוש).
/// השכנים mergeFamilies · dupFieldValue · dupFields הוזרקו כשקעים ב-deps (חוק-1).
/// המנוע לא ייצר טיוטה (draft ריק) ⇒ הומר ידנית. תיקונים מעבר ל-AST:
///  · deps = Map (גישת-מפה), לא property-access; def = Map (def['key']/def['get']).
///  · `+val` של JS ⇒ שקע `_jsNum` (num.tryParse, כלל-10) — '4'⇒int 4, לא זריקה.
///  · `val || base.status` truthiness של JS ⇒ שקע `_truthy` (כלל-7).
///  · `{...base}` ⇒ Map.from (מוטביליות — עותק, לא הפניה).
Map<String, dynamic> mergeFamiliesByFields(
    List fams, Map pick, Map edit, Map deps) {
  final mergeFamilies = deps['mergeFamilies'] as dynamic Function(dynamic, dynamic);
  final dupFieldValue =
      deps['dupFieldValue'] as dynamic Function(dynamic, dynamic, dynamic, dynamic);
  final dupFields = deps['dupFields'] as List;

  final base = mergeFamilies(fams[0], fams.sublist(1)) as Map;
  final out = Map<String, dynamic>.from(base);

  for (final defAny in dupFields) {
    final def = defAny as Map;
    final val = dupFieldValue(fams, def, pick, edit);
    switch (def['key']) {
      case 'kidsHome':
        out['kidsHome'] = val == '' ? 0 : _jsNum(val);
        break;
      case 'kidsMarried':
        out['kidsMarried'] = val == '' ? 0 : _jsNum(val);
        break;
      case 'status':
        // JS: `val || base.status` — ערך falsy נופל לסטטוס-הבסיס.
        out['status'] = _truthy(val) ? val : base['status'];
        break;
      case 'name':
        out['name'] = val;
        break;
      case 'mother':
        out['mother'] = val;
        break;
      case 'father':
        out['father'] = val;
        break;
      case 'phone':
        out['phone'] = val;
        break;
      case 'phone2':
        out['phone2'] = val;
        break;
      case 'email':
        out['email'] = val;
        break;
      case 'city':
        out['city'] = val;
        break;
      case 'address':
        out['address'] = val;
        break;
      case 'motherId':
        out['motherId'] = val;
        break;
      case 'fatherId':
        out['fatherId'] = val;
        break;
      case 'community':
        out['community'] = val;
        break;
      case 'language':
        out['language'] = val;
        break;
      case 'maritalStatus':
        out['maritalStatus'] = val;
        break;
      case 'createdAt':
        out['createdAt'] = val;
        break;
      case 'notes':
        out['notes'] = val;
        break;
    }
  }
  return out;
}

/// שקע-`+val` של JS: '' כבר טופל למעלה; מספר⇒כמותשהוא, מחרוזת⇒parse (int אם שלם),
/// bool⇒1/0, null⇒0, קלט-רע⇒NaN (כלל-10: Dart num.parse זורק ⇒ tryParse).
num _jsNum(dynamic v) {
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v == null) return 0;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  return num.tryParse(s) ?? double.nan;
}

/// שקע-truthiness שמחקה את JS: '' / 0 / null / false / NaN = falsy, השאר truthy.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}
