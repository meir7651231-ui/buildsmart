// ⚛️ אטום-Dart (דרגת-חוזה) · publishIcsFeed — פרסום/רענון פיד-ICS.
// מוצא: maor/src/lib/icsFeed.ts:34-43 → new/atoms/publish-ics-feed.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). שכני-הענן הוזרקו כשקעים
//        (חוק-1 — אפס import פנימי): readToken · mintToken · writeFeed · nowIso.
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט — dart:core).
//
// תפקיד: אם ה-ICS חורג מ-MAX_ICS_BYTES (מדידה בבתי-UTF-8) ⇒ זריקה בעברית, אפס כתיבה.
//        אחרת: token = rotate ? חדש : (קיים ?? חדש); כותב {token,ics,updatedAt}; מחזיר token.
// קלט:  slug · ics · opts (nullable, {rotate}) · 4 שקעים (readToken · mintToken · writeFeed · nowIso).
// פלט:  Future<dynamic> token; חריגת-גודל ⇒ StateError בעל message (עברית).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • פורמט/locale (כלל 6): המדידה JS היא new TextEncoder().encode(ics).length =
//    בתי-UTF-8. אין dart:convert (אפס-import) ⇒ מונה-בתים ידני על runes (code-points),
//    ביט-זהה: <0x80⇒1 · <0x800⇒2 · <0x10000⇒3 · אחרת⇒4. עברית 'א'=U+05D0 ⇒ 2 בתים.
//  • truthiness (כלל 7): JS `opts?.rotate` — opts חסר/רוטייט falsy ⇒ מסלול-שימור;
//    שקע-`_truthy` מפורש + מגן-null על opts.
//  • `??` של JS (null/undefined בלבד) ≡ `??` של Dart (null בלבד) — שימור-token מדויק.
//  • Error של JS ⇒ StateError של Dart (נושא `message` לצורך רתמת-הזהב).

typedef ReadToken = dynamic Function(dynamic slug);
typedef MintToken = dynamic Function();
typedef WriteFeed = dynamic Function(dynamic slug, dynamic data);
typedef NowIso = String Function();

const int _maxIcsBytes = 900000;

int _utf8ByteLength(String s) {
  var n = 0;
  for (final cp in s.runes) {
    if (cp < 0x80) {
      n += 1;
    } else if (cp < 0x800) {
      n += 2;
    } else if (cp < 0x10000) {
      n += 3;
    } else {
      n += 4;
    }
  }
  return n;
}

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Publish or refresh an ICS feed: keep the existing token, or mint a new one
/// (or force a fresh one on rotate). Throws a Hebrew error when the ICS exceeds
/// the UTF-8 byte limit, writing nothing. Verbatim behaviour of the JS source
/// new/atoms/publish-ics-feed.mjs.
Future<dynamic> publishIcsFeed(
  dynamic slug,
  dynamic ics,
  dynamic opts, {
  required ReadToken readToken,
  required MintToken mintToken,
  required WriteFeed writeFeed,
  NowIso? nowIso,
}) async {
  final now = nowIso ?? () => DateTime.now().toUtc().toIso8601String();
  if (_utf8ByteLength(ics as String) > _maxIcsBytes) {
    throw StateError('לוח-השנה גדול מדי לפרסום כפיד — פנו לתמיכה');
  }
  final rotate = opts != null && _truthy(opts['rotate']);
  final token = (rotate ? null : await readToken(slug)) ?? mintToken();
  await writeFeed(slug, {'token': token, 'ics': ics, 'updatedAt': now()});
  return token;
}
