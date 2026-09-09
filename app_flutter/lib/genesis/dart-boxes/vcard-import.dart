// 📦 קופסת-חיבורים · vcard-import (Dart) — מחווטת אטומי-Dart. מקבילה ל-new/boxes/vcard-import.mjs.
// חוזה משותף: new/boxes/vcard-import.contract.md · מקור-האמת: maor/src/lib/vcardImport.ts.
// זו ההוכחה ש-מאור(JS) ובנייה-חכמה(Dart) מתחברות לאותה קופסה: אותם קלטים ⇒ אותו פלט.
// ההכרעות (סדר-שדות, מילון-תוויות, כלל-ריכוך-QP) חיות כאן; שכני-המקור
// (unfold/split/decode/label/join/digits) הם חיווט-מקומי (ידע-קופסה, חוק-5) — לא אטומים.
import '../dart-maor/parse-vcards.dart' as pv;
import '../dart-maor/is-junk-contact.dart' as ijc;
import '../dart-maor/importable-contacts.dart' as ic;
import '../dart-maor/contact-to-row.dart' as ctr;
import '../dart-maor/decode-quoted-printable.dart' as dqp;

// ── סטיית-תאום מדווחת (מול קופסת-ה-JS): קופסת-ה-JS מחזיקה decodeQuotedPrintable מקומי
//    כי אטום-ה-JS decode-quoted-printable.mjs שבור (HEX2 לא-מוגדר, השמטת vcardImport.ts:33).
//    אטום-ה-Dart decode-quoted-printable.dart **תוקן** (HEX2 מוטמע) ⇒ הקופסה-הזו מחווטת אותו
//    ישירות (dqp.decodeQuotedPrintable), כפי ש"קופסה מחווטת אטומים בלבד" מבקש. הפלט זהה-ביט
//    לזה של הקופסה-המקומית ב-JS. אין באג-אטום ב-Dart. ──

// ── slice בסגנון-JS (start/end שליליים; start≥end ⇒ '') — נדרש ל-phoneLabel על היעדר-סוגריים.
String _jsSlice(String s, int start, [int? end]) {
  final len = s.length;
  var a = start < 0 ? (len + start < 0 ? 0 : len + start) : (start > len ? len : start);
  final e = end == null
      ? len
      : (end < 0 ? (len + end < 0 ? 0 : len + end) : (end > len ? len : end));
  if (a >= e) return '';
  return s.substring(a, e);
}

// ── שכני-המקור (חיווט-מקומי — יחידות-מקור שאינן אטומים) ──

/// איחוד שורות פיזיות → לוגיות: קיפול-vCard רגיל + ריכוך-QP רך (רק בשדה QP). (מקור:65-87)
final RegExp _qpEnc = RegExp('ENCODING=QUOTED-PRINTABLE', caseSensitive: false);
List<String> _unfoldLines(String text) {
  final raw = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final out = <String>[];
  var qpActive = false;
  for (final line in raw) {
    if (out.isNotEmpty && (line.startsWith(' ') || line.startsWith('\t'))) {
      out[out.length - 1] += line.substring(1);
      if (!out[out.length - 1].endsWith('=')) qpActive = false;
      continue;
    }
    if (out.isNotEmpty && qpActive && out[out.length - 1].endsWith('=')) {
      final prev = out[out.length - 1];
      out[out.length - 1] = prev.substring(0, prev.length - 1) + line;
      if (!out[out.length - 1].endsWith('=')) qpActive = false;
      continue;
    }
    out.add(line);
    qpActive = _qpEnc.hasMatch(line) && line.endsWith('=');
  }
  return out;
}

/// פיצול "NAME;PARAM;PARAM:VALUE" ל-{name,params[],value}. ה-`:` הראשון מפריד. (מקור:90-99)
Map<String, dynamic>? _splitProperty(String line) {
  final colon = line.indexOf(':');
  if (colon < 0) return null;
  final head = line.substring(0, colon);
  final value = line.substring(colon + 1);
  final segs = head.split(';'); // גדיל-צמיח (split מחזיר growable) ⇒ removeAt(0) חוקי
  final name = (segs.isNotEmpty ? segs.removeAt(0) : '').trim().toUpperCase();
  if (name.isEmpty) return null;
  return {'name': name, 'params': segs, 'value': value};
}

bool _hasParam(List<String> params, String token) =>
    params.any((p) => p.toUpperCase().contains(token));

/// ערך-שדה מפוענח לפי הפרמטרים (QP אם צוין; אחרת גלמי). (מקור:105-107)
String _decodeValue(String value, List<String> params) =>
    _hasParam(params, 'QUOTED-PRINTABLE') ? dqp.decodeQuotedPrintable(value) : value;

// מילון-תוויות-הטלפון — הכרעה חיה-בקופסה (מקור:109-117).
const Map<String, String> _phoneLabels = {
  'CELL': 'נייד',
  'HOME': 'בית',
  'WORK': 'עבודה',
  'FAX': 'פקס',
  'MAIN': 'ראשי',
  'VOICE': '',
  'PREF': '',
};

final RegExp _hexPair = RegExp(r'=[0-9A-Fa-f]{2}');

/// תווית-טלפון קריאה: X-CUSTOM(…עברית…) מפוענח, אחרת מיפוי CELL/HOME/… (מקור:120-137)
String _phoneLabel(List<String> params) {
  for (final p in params) {
    final up = p.toUpperCase();
    if (up.startsWith('X-CUSTOM')) {
      final inner = _jsSlice(p, p.indexOf('(') + 1, p.lastIndexOf(')'));
      final parts = inner.split(',');
      final last = parts.isNotEmpty ? parts[parts.length - 1] : '';
      final decoded =
          _hexPair.hasMatch(last) ? dqp.decodeQuotedPrintable(last) : last;
      if (decoded.trim().isNotEmpty) return decoded.trim();
    }
  }
  for (final p in params) {
    final key = p.toUpperCase().trim();
    if (_phoneLabels.containsKey(key) && _phoneLabels[key]!.isNotEmpty) {
      return _phoneLabels[key]!;
    }
  }
  return '';
}

/// ADR מובנה (po;ext;street;city;region;postal;country) → מחרוזת נקייה. (מקור:140-147)
String _joinAddress(String value, List<String> params) {
  final decoded = _decodeValue(value, params);
  return decoded
      .split(';')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(', ');
}

/// ספרות בלבד ממספר-טלפון (לזיהוי מספרי-זבל קצרים). (מקור:223)
String _digitsOnly(dynamic s) =>
    ((s ?? '') as String).replaceAll(RegExp(r'\D'), '');

// ── החיווט: הזרקת השקעים לאטומים לפי גרף-המקור ──
List<Map<String, dynamic>> _wiredParseVcards(String? text) => pv.parseVcards(
    text, _unfoldLines, _splitProperty, _decodeValue, _phoneLabel, _joinAddress);
bool _wiredIsJunk(Map c) => ijc.isJunkContact(c, _digitsOnly);
List<dynamic> _wiredImportable(dynamic text) => ic.importableContacts(
      text,
      (t) => _wiredParseVcards(t as String?),
      (c) => _wiredIsJunk(c as Map),
    );

// ── ה-API הפומבי (ביט-זהה לחתימות vcard-import.mjs) ──
List<Map<String, dynamic>> parseVcards(String? text) => _wiredParseVcards(text);
bool isJunkContact(Map c) => _wiredIsJunk(c);
List<dynamic> importableContacts(dynamic text) => _wiredImportable(text);
Map<String, String> contactToRow(Map<String, dynamic> c) => ctr.contactToRow(c);
String decodeQuotedPrintable(String s) => dqp.decodeQuotedPrintable(s);
/// G48 · נקודת-כניסה אחת לייבוא: טקסט-VCF ⇒ שורות-ייבוא ניטרליות (name · phone · phone2 · email · address · notes), בניכוי זבל.
List<Map<String, String>> vcardImportRows(String? text) => [for (final c in _wiredImportable(text)) ctr.contactToRow(c as Map<String, dynamic>)];
