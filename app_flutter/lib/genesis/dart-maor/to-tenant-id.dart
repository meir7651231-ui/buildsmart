/// חוט · to-tenant-id — הומר מ-JS (new/atoms/to-tenant-id.mjs). חוזה: to-tenant-id.contract.md
/// חוקים: ‏#7 truthiness-של-JS מפורש · ‏#5 slice-בטוח עם גידור-אורך · ‏#13 toLowerCase נאמן-JS.

/// truthiness של JS (חוק-7): '' / 0 / -0 / NaN / null כוזבים.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// slice(start, end) של JS על מחרוזת — גידור-אורך, לא זורק (חוק-5).
String _slice(String s, int start, int end) {
  var st = start < 0 ? s.length + start : start;
  var en = end < 0 ? s.length + end : end;
  if (st < 0) st = 0;
  if (en > s.length) en = s.length;
  return st >= en ? '' : s.substring(st, en);
}

/// עזר ל-Final_Sigma: האם התו הוא "אות" (Cased) לצורך גבול-מילה.
bool _isCased(int c) {
  final s = String.fromCharCode(c);
  return s.toLowerCase() != s.toUpperCase();
}

/// חוק-13 · toLowerCase נאמן-JS (מיפוי-מלא). Dart-VM עושה מיפוי-פשוט וחוסר
/// חריגים תלויי-הקשר/מלאים; כאן מוסיפים את הידועים שנתפסו באימות-העוין:
///  • U+0130 (İ) ⇒ "i" + U+0307 (נקודה-מעל) — מיפוי-מלא.
///  • טווח-צ'רוקי רבתי U+13A0–U+13EF ⇒ +0x97D0 (קטנות U+AB70–U+ABBF).
///  • Σ סופית (Final_Sigma) ⇒ ς בסוף-מילה; אחרת σ.
String _jsLower(String s) {
  final out = StringBuffer();
  final runes = s.runes.toList();
  for (var i = 0; i < runes.length; i++) {
    final c = runes[i];
    if (c == 0x0130) {
      out.writeCharCode(0x69); // i
      out.writeCharCode(0x0307); // combining dot above
    } else if (c >= 0x13A0 && c <= 0x13EF) {
      out.writeCharCode(c + 0x97D0); // Cherokee upper ⇒ lower
    } else if (c == 0x03A3) {
      // Σ · Final_Sigma: קטנה-סופית ς אם אחריה אין תו-מילה (ותו-מילה לפניה)
      final prevWord = i > 0 && _isCased(runes[i - 1]);
      final nextWord = i + 1 < runes.length && _isCased(runes[i + 1]);
      out.write(prevWord && !nextWord ? 'ς' : 'σ');
    } else {
      out.write(String.fromCharCode(c).toLowerCase());
    }
  }
  return out.toString();
}

dynamic toTenantId(dynamic slug, dynamic orgName) {
  final String src = (_truthy(slug) && slug != 'default')
      ? slug as String
      : (_truthy(orgName) ? orgName as String : 'org');
  final base = _slice(
    _jsLower(src)
        .replaceAll(RegExp(r'[^a-z0-9-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), ''),
    0,
    38,
  );
  final padded = base.length >= 3 ? base : '$base-org';
  return RegExp(r'^[a-z0-9]').hasMatch(padded) ? padded : _slice('x-$padded', 0, 40);
}
