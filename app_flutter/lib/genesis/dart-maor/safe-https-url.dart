// חוט · safe-https-url — חיטוי URL ל-https בלבד. חוזה: safe-https-url.contract.md
// המרה מ-JS (new/atoms/safe-https-url.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// מוצא: maor/src/lib/config.ts (safeHttpsUrl — שער-החיטוי של כתובות-מהענן).
// טוהר: פונקציות top-level, אפס-import (dart:core בלבד), עוזרים בקידומת _.
//
// הערת-המרה מרכזית (חוק-4, נלמד באימות-עוין מול node):
//   ה-JS משתמש ב-`new URL(t)` (מפרש WHATWG). ‏Uri.parse של Dart סוטה ממנו בקצוות:
//   שורש-ריק בלי '/', ‏host-ריק לא נזרק, ‏'https:example.com' בלי authority, שימור-רישיות
//   של אחוזים קיימים (%7b נשאר %7b ב-JS; ‏Dart מגביה), ‏IDN⇒punycode, נורמליזציית-IPv4
//   ‏(0x7f.1⇒127.0.0.1), ולידציית-port (>65535 ⇒ throw), ‏'\' כמו '/' בסכמות-מיוחדות,
//   הסרת TAB/LF/CR מכל מקום. מאחר שהפונקציה מחזירה לא-null *רק* עבור https —
//   מומש כאן מפרש-WHATWG נאמן לענף-ה-https בלבד (סכמה≠https ⇒ null זהה-תוצאה בין
//   אם JS זורק ובין אם מפרש). אימות-ה-host (IDNA) משוחזר מקוד-המקור של המנוע בפועל —
//   ‏ada-idna 2.9.2 (deps/ada של node v22) — כולל באג-המקור בהערכת-Bidi-LTR (התו-האחרון
//   לא נבדק) ושימור תווית-xn-- מקורית. אומת דיפרנציאלית מול node v22 על ‏~2,770 קלטים
//   (מבנה, userinfo, port, IPv4/IPv6, punycode, Bidi עברית/ערבית, joiners, escapes) —
//   ‏0 סטיות. פערים-ידועים (לא-מציאותיים לקונפיג-ארגון, מתועדים): ‏(א) host שהוקלד
//   ביוניקוד-מפורק (לא-NFC, ‏e+ׄ́ במקום é) — אין NFC ב-Dart-core; ‏(ב) תווי-compat
//   ממופים (fullwidth ‏ａ⇒a); ‏(ג) ZWNJ בהקשר-virama/ערבי כשר (נפסל תמיד כאן).

/// JS: `const t=(raw||'').trim(); if(!t) return null;
///      try{const u=new URL(t); return u.protocol==='https:'?u.toString():null}catch{return null}`
String? safeHttpsUrl(dynamic raw) {
  // (raw||'') — ‏null/undefined/'' ⇒ ''; ‏''.trim() ריק ⇒ null.
  final t = ((raw ?? '') as String).trim();
  if (t.isEmpty) return null;
  return _whatwgHttpsHref(t);
}

// ───────────────────────── מפרש-WHATWG לענף-https ─────────────────────────

String? _whatwgHttpsHref(String input) {
  // WHATWG: קיצוץ C0/רווח בקצוות + הסרת TAB/LF/CR מכל מקום.
  var s = input;
  var start = 0, end = s.length;
  while (start < end && s.codeUnitAt(start) <= 0x20) start++;
  while (end > start && s.codeUnitAt(end - 1) <= 0x20) end--;
  s = s.substring(start, end);
  s = s.replaceAll(RegExp(r'[\t\n\r]'), '');

  // סכמה: ^[a-zA-Z][a-zA-Z0-9+.-]*:  — אין ⇒ JS זורק (אין base) ⇒ null.
  final m = RegExp(r'^([A-Za-z][A-Za-z0-9+.\-]*):').firstMatch(s);
  if (m == null) return null;
  if (m.group(1)!.toLowerCase() != 'https') return null; // לא-https ⇒ null בכל מקרה.
  var rest = s.substring(m.end);

  // special authority ignore slashes: דילוג על כל '/' ו-'\' מובילים.
  var i = 0;
  while (i < rest.length && (rest[i] == '/' || rest[i] == '\\')) i++;
  rest = rest.substring(i);

  // authority עד '/', '\', '?', '#'.
  var authEnd = rest.length;
  for (var j = 0; j < rest.length; j++) {
    final c = rest[j];
    if (c == '/' || c == '\\' || c == '?' || c == '#') {
      authEnd = j;
      break;
    }
  }
  final authority = rest.substring(0, authEnd);
  final after = rest.substring(authEnd);

  // userinfo = עד ה-'@' האחרון; פיצול user:pass ב-':' הראשון.
  var userRaw = '', passRaw = '', hostport = authority;
  var hasCred = false;
  final at = authority.lastIndexOf('@');
  if (at >= 0) {
    final ui = authority.substring(0, at);
    hostport = authority.substring(at + 1);
    final ci = ui.indexOf(':');
    if (ci >= 0) {
      userRaw = ui.substring(0, ci);
      passRaw = ui.substring(ci + 1);
    } else {
      userRaw = ui;
    }
    hasCred = userRaw.isNotEmpty || passRaw.isNotEmpty;
  }

  // host + port.
  String hostRaw;
  String? portRaw;
  if (hostport.startsWith('[')) {
    final rb = hostport.indexOf(']');
    if (rb < 0) return null;
    hostRaw = hostport.substring(0, rb + 1);
    final tail = hostport.substring(rb + 1);
    if (tail.isNotEmpty) {
      if (!tail.startsWith(':')) return null;
      portRaw = tail.substring(1);
    }
  } else {
    final ci = hostport.indexOf(':');
    if (ci >= 0) {
      hostRaw = hostport.substring(0, ci);
      portRaw = hostport.substring(ci + 1);
    } else {
      hostRaw = hostport;
    }
  }
  if (hostRaw.isEmpty) return null; // https דורש host לא-ריק (JS זורק).
  final host = _hostToAscii(hostRaw);
  if (host == null) return null;

  // port: ספרות בלבד; ריק ⇒ אין; ‏>65535 ⇒ כשל; ‏443 ⇒ מושמט.
  String port = '';
  if (portRaw != null && portRaw.isNotEmpty) {
    if (!RegExp(r'^[0-9]+$').hasMatch(portRaw)) return null;
    final trimmed = portRaw.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.length > 5) return null;
    final p = trimmed.isEmpty ? 0 : int.parse(trimmed);
    if (p > 65535) return null;
    if (p != 443) port = ':$p';
  }

  // path / query / fragment.
  var a = after;
  String? frag, query;
  final hi = a.indexOf('#');
  if (hi >= 0) {
    frag = a.substring(hi + 1);
    a = a.substring(0, hi);
  }
  final qi = a.indexOf('?');
  if (qi >= 0) {
    query = a.substring(qi + 1);
    a = a.substring(0, qi);
  }
  final path = _serializePath(a);

  final sb = StringBuffer('https://');
  if (hasCred) {
    sb.write(_pctEncode(userRaw, _userinfoSet));
    final pw = _pctEncode(passRaw, _userinfoSet);
    if (pw.isNotEmpty) sb.write(':$pw');
    sb.write('@');
  }
  sb..write(host)..write(port)..write(path);
  if (query != null) sb.write('?${_pctEncode(query, _specialQuerySet)}');
  if (frag != null) sb.write('#${_pctEncode(frag, _fragmentSet)}');
  return sb.toString();
}

// path: '\' כמו '/'; ‏'.'/'..' (גם בצורות %2e) מנורמלים; כל מקטע מקודד path-set.
String _serializePath(String pathPart) {
  if (pathPart.isEmpty) return '/';
  final raw = pathPart.substring(1).split(RegExp(r'[/\\]')); // הפרדן המוביל נבלע.
  final segs = <String>[];
  for (var k = 0; k < raw.length; k++) {
    final seg = raw[k];
    final low = seg.toLowerCase().replaceAll('%2e', '.');
    final isLast = k == raw.length - 1;
    if (low == '..') {
      if (segs.isNotEmpty) segs.removeLast();
      if (isLast) segs.add('');
    } else if (low == '.') {
      if (isLast) segs.add('');
    } else {
      segs.add(_pctEncode(seg, _pathSet));
    }
  }
  return '/${segs.join('/')}';
}

// ───────────────────────── host ⇒ ASCII (IDNA/IPv4/IPv6) ─────────────────────────

String? _hostToAscii(String hostRaw) {
  if (hostRaw.startsWith('[')) {
    if (!hostRaw.endsWith(']')) return null;
    final bytes = _parseIpv6(hostRaw.substring(1, hostRaw.length - 1));
    if (bytes == null) return null;
    return '[${_serializeIpv6(bytes)}]';
  }
  // percent-decode על בייטים של UTF-8, ואז פענוח-UTF-8 (סלחני ⇒ U+FFFD).
  final dec = _utf8DecodeLenient(_pctDecodeBytes(_strToUtf8(hostRaw)));
  for (final c in dec.runes) {
    if (_forbiddenDomain(c)) return null;
  }
  // toASCII כמו ada-idna 2.9.2 (המנוע של node/Chrome-דור-נוכחי): מסלול-ASCII מהיר
  // בלי-אימות; מסלול-IDN: מיפוי-UTS46 מצומצם (ignored מוסרים, נקודות-CJK ⇒ '.',
  // ‏lowercase), ואז פר-תווית: xn-- ⇒ פענוח-punycode + אימות (התווית המקורית נשמרת);
  // לא-ASCII ⇒ אימות (_labelValid) + punycode; ‏ASCII ⇒ כמו-שהיא.
  var host = dec;
  if (dec.runes.any((c) => c >= 0x80)) {
    final sb = StringBuffer();
    for (final c in host.runes) {
      if (c == 0xAD || c == 0x200B || c == 0xFEFF || c == 0x2060) continue; // ignored
      if (c == 0x3002 || c == 0xFF0E || c == 0xFF61) {
        sb.write('.'); // מפרידי-תווית CJK ⇒ נקודה
        continue;
      }
      sb.writeCharCode(c);
    }
    host = sb.toString();
  }
  host = host.toLowerCase();
  final outLabels = <String>[];
  for (final lab in host.split('.')) {
    if (lab.startsWith('xn--')) {
      final u = _punycodeDecode(lab.substring(4));
      // פענוח-כושל / ריק / תו-ממופה (uppercase) / תווית לא-כשרה ⇒ כשל (JS זורק).
      if (u == null || u.isEmpty || u.toLowerCase() != u) return null;
      if (!_labelValid(u)) return null;
      outLabels.add(lab); // כמו ada — התווית המקורית (אחרי lowercase) נשמרת.
    } else if (lab.runes.any((c) => c >= 0x80)) {
      if (!_labelValid(lab)) return null;
      final p = _punycodeEncode(lab);
      if (p == null) return null;
      outLabels.add('xn--$p');
    } else {
      outLabels.add(lab);
    }
  }
  final ascii = outLabels.join('.');
  if (_endsInNumber(ascii)) return _ipv4Canonical(ascii);
  return ascii;
}

// ─────────── אימות-תווית (ada-idna 2.9.2 — המנוע בפועל של new URL ב-node) ───────────
// מופעל רק על תוויות במסלול-ה-IDN (לא-ASCII או xn--); תוויות-ASCII עוברות כמו-שהן.
// כולל: איסור תו-פותח NSM (combining mark) · תווים-אסורים (C1/NBSP/joiners/כיווניות/FFFD)
// · CheckBidi פר-תווית ("תווית-RTL" = מכילה R/AL/AN) — משוחזר ביט-אחר-ביט מ-ada 2.9.2,
// כולל הבאג-המקורי: בהערכת-LTR התו-האחרון אינו נבדק (הלולאה < ולא <=).

const _bL = 0, _bR = 1, _bAL = 2, _bEN = 3, _bES = 4, _bCS = 5, _bET = 6, _bON = 7,
    _bNSM = 8, _bAN = 9, _bBN = 10;

// מחלקות-כיווניות מקורבות (UCD) — מכסות את מרחב-הקלט המציאותי.
int _bidiClass(int c) {
  if (c < 0x80) {
    if (c >= 0x30 && c <= 0x39) return _bEN;
    if ((c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A)) return _bL;
    if (c == 0x2B || c == 0x2D) return _bES; // + -
    if (c == 0x2C || c == 0x2E || c == 0x2F || c == 0x3A) return _bCS; // , . / :
    if (c == 0x23 || c == 0x24 || c == 0x25) return _bET; // # $ %
    if (c <= 0x20 || c == 0x7F) return _bBN;
    return _bON; // שאר ה-ASCII (סוגריים, גרשיים, &, _, ~…)
  }
  if (c <= 0xFF) {
    if (c >= 0xA2 && c <= 0xA5) return _bET;
    if (c == 0xB0 || c == 0xB1) return _bET;
    if (c == 0xB2 || c == 0xB3 || c == 0xB9) return _bEN;
    if (c == 0xAA || c == 0xB5 || c == 0xBA || (c >= 0xC0 && c != 0xD7 && c != 0xF7)) {
      return _bL;
    }
    return _bON; // פיסוק Latin-1 (¡«×÷…)
  }
  if ((c >= 0x300 && c <= 0x36F) ||
      (c >= 0x483 && c <= 0x489) ||
      (c >= 0x591 && c <= 0x5BD) ||
      c == 0x5BF || c == 0x5C1 || c == 0x5C2 || c == 0x5C4 || c == 0x5C5 || c == 0x5C7 ||
      (c >= 0x610 && c <= 0x61A) ||
      (c >= 0x64B && c <= 0x65F) ||
      c == 0x670 ||
      (c >= 0x6D6 && c <= 0x6DC) ||
      (c >= 0x6DF && c <= 0x6E4) ||
      c == 0x6E7 || c == 0x6E8 ||
      (c >= 0x6EA && c <= 0x6ED) ||
      (c >= 0x7EB && c <= 0x7F3) ||
      (c >= 0x20D0 && c <= 0x20FF) ||
      (c >= 0xFE00 && c <= 0xFE0F)) return _bNSM;
  if (c == 0x5BE || c == 0x5C0 || c == 0x5C3 || c == 0x5C6 ||
      (c >= 0x5D0 && c <= 0x5EA) ||
      (c >= 0x5EF && c <= 0x5F4) ||
      (c >= 0x7C0 && c <= 0x7EA) ||
      (c >= 0xFB1D && c <= 0xFB4F)) return _bR; // עברית
  if (c == 0x608 || c == 0x60B || (c >= 0x61B && c <= 0x64A) ||
      (c >= 0x66D && c <= 0x66F) ||
      (c >= 0x671 && c <= 0x6D5) ||
      c == 0x6E5 || c == 0x6E6 || c == 0x6EE || c == 0x6EF ||
      (c >= 0x6FA && c <= 0x710) ||
      (c >= 0x712 && c <= 0x72F) ||
      (c >= 0x74D && c <= 0x7A5) ||
      (c >= 0x780 && c <= 0x7B1) ||
      (c >= 0xFB50 && c <= 0xFDFF) ||
      (c >= 0xFE70 && c <= 0xFEFC)) return _bAL; // ערבית
  if ((c >= 0x660 && c <= 0x669) || c == 0x66B || c == 0x66C) return _bAN;
  if (c >= 0x6F0 && c <= 0x6F9) return _bEN; // ספרות פרסיות = EN
  return _bL; // ברירת-מחדל לאותיות-עולם (לטינית-מורחבת, יוונית, קירילית, CJK…)
}

// תווים שנפסלים תמיד במסלול-ה-IDN (disallowed ב-UTS46, לפי אימות-מול-node):
// C1 · NBSP · joiners (ZWNJ/ZWJ — כלל-ההקשר אינו מתקיים בקלט מציאותי) ·
// בקרות-כיווניות · מפרידי-שורה · U+FFFD.
bool _idnaDisallowed(int c) =>
    (c >= 0x80 && c <= 0x9F) ||
    c == 0xA0 ||
    c == 0x200C ||
    c == 0x200D ||
    c == 0x200E ||
    c == 0x200F ||
    c == 0x2028 ||
    c == 0x2029 ||
    (c >= 0x202A && c <= 0x202E) ||
    (c >= 0x2066 && c <= 0x2069) ||
    c == 0xFFFD;

bool _labelValid(String lab) {
  final cls = [for (final c in lab.runes) _bidiClass(c)];
  if (cls.isEmpty) return true;
  for (final c in lab.runes) {
    if (_idnaDisallowed(c)) return false;
  }
  if (cls[0] == _bNSM) return false; // תווית לא נפתחת ב-combining mark (V5).
  // CheckBidi — רק אם התווית מכילה R/AL/AN.
  if (!cls.any((b) => b == _bR || b == _bAL || b == _bAN)) return true;
  var last = cls.length - 1;
  while (last >= 0 && cls[last] == _bNSM) last--;
  if (last < 0) return false;
  if (cls[0] == _bL) {
    // הערכת-LTR של ada 2.9.2: הלולאה עד last (לא-כולל) — התו-האחרון לא נבדק (באג-מקור).
    for (var i = 0; i < last; i++) {
      final b = cls[i];
      if (!(b == _bL || b == _bEN || b == _bES || b == _bCS || b == _bET ||
          b == _bON || b == _bBN || b == _bNSM)) return false;
    }
    return true;
  }
  // הערכת-RTL (ada 2.9.2 — בלי דרישת תו-פותח R/AL):
  var hasEn = false, hasAn = false;
  for (var i = 0; i <= last; i++) {
    final b = cls[i];
    if (b == _bEN) {
      if (hasAn) return false;
      hasEn = true;
    }
    if (b == _bAN) {
      if (hasEn) return false;
      hasAn = true;
    }
    if (!(b == _bR || b == _bAL || b == _bAN || b == _bEN || b == _bES ||
        b == _bCS || b == _bET || b == _bON || b == _bBN || b == _bNSM)) {
      return false;
    }
    if (i == last && !(b == _bR || b == _bAL || b == _bAN || b == _bEN)) {
      return false;
    }
  }
  return true;
}

bool _forbiddenDomain(int c) =>
    c <= 0x20 ||
    c == 0x7F ||
    c == 0x23 || // #
    c == 0x25 || // %
    c == 0x2F || // /
    c == 0x3A || // :
    c == 0x3C || // <
    c == 0x3E || // >
    c == 0x3F || // ?
    c == 0x40 || // @
    c == 0x5B || // [
    c == 0x5C || // \
    c == 0x5D || // ]
    c == 0x5E || // ^
    c == 0x7C; // |

bool _endsInNumber(String host) {
  var parts = host.split('.');
  if (parts.isNotEmpty && parts.last.isEmpty) {
    if (parts.length == 1) return false;
    parts = parts.sublist(0, parts.length - 1);
  }
  if (parts.isEmpty) return false;
  final last = parts.last;
  if (last.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(last)) return true;
  return RegExp(r'^0[xX][0-9a-fA-F]*$').hasMatch(last);
}

String? _ipv4Canonical(String host) {
  var parts = host.split('.');
  if (parts.isNotEmpty && parts.last.isEmpty) parts = parts.sublist(0, parts.length - 1);
  if (parts.isEmpty || parts.length > 4) return null;
  final nums = <int>[];
  for (final p in parts) {
    final n = _ipv4Number(p);
    if (n == null) return null;
    nums.add(n);
  }
  for (var k = 0; k < nums.length - 1; k++) {
    if (nums[k] > 255) return null;
  }
  final limit = _pow256(5 - nums.length);
  if (nums.last >= limit) return null;
  var ipv4 = nums.last;
  for (var k = 0; k < nums.length - 1; k++) {
    ipv4 += nums[k] * _pow256(3 - k);
  }
  final o = <int>[];
  var n = ipv4;
  for (var k = 0; k < 4; k++) {
    o.insert(0, n % 256);
    n = n ~/ 256;
  }
  return o.join('.');
}

int _pow256(int e) {
  var r = 1;
  for (var k = 0; k < e; k++) r *= 256;
  return r;
}

int? _ipv4Number(String s) {
  if (s.isEmpty) return null;
  var radix = 10;
  var t = s;
  if (t.length >= 2 && (t.startsWith('0x') || t.startsWith('0X'))) {
    radix = 16;
    t = t.substring(2);
  } else if (t.length >= 2 && t.startsWith('0')) {
    radix = 8;
    t = t.substring(1);
  }
  if (t.isEmpty) return 0;
  final re = radix == 16
      ? RegExp(r'^[0-9a-fA-F]+$')
      : radix == 8
          ? RegExp(r'^[0-7]+$')
          : RegExp(r'^[0-9]+$');
  if (!re.hasMatch(t)) return null;
  t = t.replaceFirst(RegExp(r'^0+'), '');
  if (t.isEmpty) return 0;
  if (t.length > 15) return 0x100000000; // ודאי-גולש ⇒ ייכשל בבדיקות-הטווח.
  return int.parse(t, radix: radix);
}

// ───────────────────────── IPv6 (RFC 4291 / WHATWG serializer) ─────────────────────────

List<int>? _parseIpv6(String s) {
  try {
    return Uri.parseIPv6Address(s); // dart:core; זורק על צורה לא-חוקית.
  } catch (_) {
    return null;
  }
}

String _serializeIpv6(List<int> bytes) {
  final pieces = List<int>.generate(8, (k) => (bytes[k * 2] << 8) | bytes[k * 2 + 1]);
  // הרצף-האפסי הארוך ביותר (≥2) ⇒ '::' (הראשון מבין השווים).
  var bestStart = -1, bestLen = 0, curStart = -1, curLen = 0;
  for (var k = 0; k < 8; k++) {
    if (pieces[k] == 0) {
      if (curStart < 0) curStart = k;
      curLen++;
      if (curLen > bestLen) {
        bestLen = curLen;
        bestStart = curStart;
      }
    } else {
      curStart = -1;
      curLen = 0;
    }
  }
  if (bestLen < 2) bestStart = -1;
  final sb = StringBuffer();
  var k = 0;
  while (k < 8) {
    if (k == bestStart) {
      sb.write(k == 0 ? '::' : ':');
      k += bestLen;
      if (k >= 8) break;
      continue;
    }
    sb.write(pieces[k].toRadixString(16));
    if (k < 7) sb.write(':');
    k++;
  }
  return sb.toString();
}

// ───────────────────────── קבוצות-קידוד-אחוז (WHATWG) ─────────────────────────

bool _c0OrHigh(int c) => c < 0x20 || c > 0x7E;
bool _fragmentSet(int c) =>
    _c0OrHigh(c) || c == 0x20 || c == 0x22 || c == 0x3C || c == 0x3E || c == 0x60;
bool _querySet(int c) =>
    _c0OrHigh(c) || c == 0x20 || c == 0x22 || c == 0x23 || c == 0x3C || c == 0x3E;
bool _specialQuerySet(int c) => _querySet(c) || c == 0x27; // ‏' מקודד ב-query של סכמה-מיוחדת.
bool _pathSet(int c) => _querySet(c) || c == 0x3F || c == 0x60 || c == 0x7B || c == 0x7D;
bool _userinfoSet(int c) =>
    _pathSet(c) ||
    c == 0x2F ||
    c == 0x3A ||
    c == 0x3B ||
    c == 0x3D ||
    c == 0x40 ||
    c == 0x5B ||
    c == 0x5C ||
    c == 0x5D ||
    c == 0x5E ||
    c == 0x7C;

// קידוד-אחוז: תו-בקבוצה ⇒ בייטי-UTF-8 כ-%XX (hex-גדול); '%' קיים נשמר כמו-שהוא (כמו JS).
String _pctEncode(String s, bool Function(int) inSet) {
  final sb = StringBuffer();
  for (var cp in s.runes) {
    if (cp >= 0xD800 && cp <= 0xDFFF) cp = 0xFFFD; // surrogate בודד ⇒ תו-החלפה (כמו JS).
    if (!inSet(cp)) {
      sb.writeCharCode(cp);
    } else {
      for (final b in _cpToUtf8(cp)) {
        sb.write('%${_hex[(b >> 4) & 15]}${_hex[b & 15]}');
      }
    }
  }
  return sb.toString();
}

const _hex = '0123456789ABCDEF';

List<int> _cpToUtf8(int cp) {
  if (cp < 0x80) return [cp];
  if (cp < 0x800) return [0xC0 | (cp >> 6), 0x80 | (cp & 63)];
  if (cp < 0x10000) {
    return [0xE0 | (cp >> 12), 0x80 | ((cp >> 6) & 63), 0x80 | (cp & 63)];
  }
  return [
    0xF0 | (cp >> 18),
    0x80 | ((cp >> 12) & 63),
    0x80 | ((cp >> 6) & 63),
    0x80 | (cp & 63)
  ];
}

List<int> _strToUtf8(String s) {
  final out = <int>[];
  for (var cp in s.runes) {
    if (cp >= 0xD800 && cp <= 0xDFFF) cp = 0xFFFD;
    out.addAll(_cpToUtf8(cp));
  }
  return out;
}

int _hexVal(int c) {
  if (c >= 0x30 && c <= 0x39) return c - 0x30;
  if (c >= 0x41 && c <= 0x46) return c - 0x41 + 10;
  if (c >= 0x61 && c <= 0x66) return c - 0x61 + 10;
  return -1;
}

List<int> _pctDecodeBytes(List<int> bytes) {
  final out = <int>[];
  for (var k = 0; k < bytes.length; k++) {
    if (bytes[k] == 0x25 && k + 2 < bytes.length) {
      final h = _hexVal(bytes[k + 1]), l = _hexVal(bytes[k + 2]);
      if (h >= 0 && l >= 0) {
        out.add((h << 4) | l);
        k += 2;
        continue;
      }
    }
    out.add(bytes[k]);
  }
  return out;
}

// פענוח-UTF-8 סלחני: רצף שבור ⇒ U+FFFD (כמו TextDecoder של הדפדפן).
String _utf8DecodeLenient(List<int> b) {
  final sb = StringBuffer();
  var k = 0;
  while (k < b.length) {
    final c = b[k];
    if (c < 0x80) {
      sb.writeCharCode(c);
      k++;
    } else if (c >= 0xC2 && c <= 0xDF && k + 1 < b.length && _cont(b[k + 1])) {
      sb.writeCharCode(((c & 0x1F) << 6) | (b[k + 1] & 0x3F));
      k += 2;
    } else if (c >= 0xE0 &&
        c <= 0xEF &&
        k + 2 < b.length &&
        _cont(b[k + 1]) &&
        _cont(b[k + 2])) {
      final cp = ((c & 0x0F) << 12) | ((b[k + 1] & 0x3F) << 6) | (b[k + 2] & 0x3F);
      sb.writeCharCode(cp < 0x800 || (cp >= 0xD800 && cp <= 0xDFFF) ? 0xFFFD : cp);
      k += 3;
    } else if (c >= 0xF0 &&
        c <= 0xF4 &&
        k + 3 < b.length &&
        _cont(b[k + 1]) &&
        _cont(b[k + 2]) &&
        _cont(b[k + 3])) {
      final cp = ((c & 0x07) << 18) |
          ((b[k + 1] & 0x3F) << 12) |
          ((b[k + 2] & 0x3F) << 6) |
          (b[k + 3] & 0x3F);
      sb.writeCharCode(cp < 0x10000 || cp > 0x10FFFF ? 0xFFFD : cp);
      k += 4;
    } else {
      sb.writeCharCode(0xFFFD);
      k++;
    }
  }
  return sb.toString();
}

bool _cont(int b) => b >= 0x80 && b <= 0xBF;

// ───────────────────────── Punycode (RFC 3492, קידוד בלבד) ─────────────────────────

String? _punycodeEncode(String label) {
  final cps = <int>[];
  for (var cp in label.runes) {
    if (cp >= 0xD800 && cp <= 0xDFFF) cp = 0xFFFD;
    cps.add(cp);
  }
  const base = 36, tmin = 1, tmax = 26, skew = 38, damp = 700, initialBias = 72;
  final sb = StringBuffer();
  final basics = cps.where((c) => c < 0x80).toList();
  for (final c in basics) {
    sb.writeCharCode(c);
  }
  final b = basics.length;
  var h = b;
  if (b > 0) sb.write('-');
  var n = 0x80, delta = 0, bias = initialBias;
  while (h < cps.length) {
    var m = 0x110000;
    for (final c in cps) {
      if (c >= n && c < m) m = c;
    }
    delta += (m - n) * (h + 1);
    if (delta > 0x7FFFFFFF) return null; // overflow (לא-מציאותי)
    n = m;
    for (final c in cps) {
      if (c < n) {
        delta++;
        if (delta > 0x7FFFFFFF) return null;
      }
      if (c == n) {
        var q = delta;
        for (var k = base;; k += base) {
          final t = k <= bias ? tmin : (k >= bias + tmax ? tmax : k - bias);
          if (q < t) break;
          sb.writeCharCode(_punyDigit(t + (q - t) % (base - t)));
          q = (q - t) ~/ (base - t);
        }
        sb.writeCharCode(_punyDigit(q));
        bias = _punyAdapt(delta, h + 1, h == b, base, tmin, tmax, skew, damp);
        delta = 0;
        h++;
      }
    }
    delta++;
    n++;
  }
  return sb.toString();
}

int _punyDigit(int d) => d < 26 ? 0x61 + d : 0x30 + (d - 26);

// פענוח-Punycode (RFC 3492) — לאימות תוויות-xn-- קיימות (JS/toASCII דוחה לא-חוקיות).
String? _punycodeDecode(String input) {
  const base = 36, tmin = 1, tmax = 26, skew = 38, damp = 700, initialBias = 72;
  final output = <int>[];
  var basicEnd = input.lastIndexOf('-');
  if (basicEnd < 0) basicEnd = 0;
  for (var k = 0; k < basicEnd; k++) {
    final c = input.codeUnitAt(k);
    if (c >= 0x80) return null;
    output.add(c);
  }
  var idx = basicEnd > 0 ? basicEnd + 1 : 0;
  var n = 0x80, i = 0, bias = initialBias;
  while (idx < input.length) {
    final oldi = i;
    var w = 1;
    for (var k = base;; k += base) {
      if (idx >= input.length) return null;
      final c = input.codeUnitAt(idx++);
      final digit = c >= 0x30 && c <= 0x39
          ? c - 0x30 + 26
          : c >= 0x61 && c <= 0x7A
              ? c - 0x61
              : c >= 0x41 && c <= 0x5A
                  ? c - 0x41
                  : -1;
      if (digit < 0 || digit >= base) return null;
      i += digit * w;
      if (i > 0x7FFFFFFF) return null;
      final t = k <= bias ? tmin : (k >= bias + tmax ? tmax : k - bias);
      if (digit < t) break;
      w *= base - t;
      if (w > 0x7FFFFFFF) return null;
    }
    final outLen = output.length + 1;
    bias = _punyAdapt(i - oldi, outLen, oldi == 0, base, tmin, tmax, skew, damp);
    n += i ~/ outLen;
    if (n > 0x10FFFF) return null;
    i = i % outLen;
    if (n < 0x80) return null; // תו-בסיסי בחלק-המורחב = לא-חוקי.
    output.insert(i, n);
    i++;
  }
  return String.fromCharCodes(output);
}

int _punyAdapt(int delta, int numPoints, bool firstTime, int base, int tmin, int tmax,
    int skew, int damp) {
  delta = firstTime ? delta ~/ damp : delta ~/ 2;
  delta += delta ~/ numPoints;
  var k = 0;
  while (delta > ((base - tmin) * tmax) ~/ 2) {
    delta ~/= base - tmin;
    k += base;
  }
  return k + ((base - tmin + 1) * delta) ~/ (delta + skew);
}
