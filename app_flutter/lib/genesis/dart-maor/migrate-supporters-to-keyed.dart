// ⚛️ אטום-Dart (דרגת-חוזה) · migrateSupportersToKeyed — מיגרציית אכיפת-התומכים:
//    כתיבה-מחדש של כל התומכים והאירועים עם skey (צברי-400, dek אופציונלי; אידמפוטנטית).
// מוצא: maor/src/lib/cloud.ts:215-240 → new/atoms/migrate-supporters-to-keyed.mjs
//        (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת). תשעת השכנים
//        (requireDb · supKeyMapOf · supKeyOf · docSkey · toPlain · encryptDoc ·
//         scopedCol · doc · writeBatch) הוזרקו כאובייקט-שקעים io (חוק-1 — אפס import פנימי).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: לכל תומך ⇒ set(doc(supporters, id), {skey: supKeyOf(sp), ...inner}); לכל אירוע ⇒
//        set(doc(events, id), {skey: docSkey('events', ev, map), ...inner}). inner = תוכן-plain,
//        או מעטפת-encryptDoc כשיש dek. כתיבה בצברי-400 (מגבלת WriteBatch). מוחזר מספר-המסמכים.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • truthiness (כלל 7): JS `dek ?` — null/undefined/''/0/false נחשבים falsy;
//    ב-Dart שקע-`_falsy` מפורש (במקור dek הוא מפתח-הצפנה/null, נשמר ביט-זהה).
//  • ה-records (sp/ev) הם מפות-נתונים כמו object של JS ⇒ גישת-מפתח `sp['id']`
//    (מקביל ל-`sp.id`), כמדיניות-הפורט של apply-entity-partial.
//  • `{ skey: X, ...inner }`: אובייקט-JS מציב skey ואז מרחיב את inner (מפתח-חופף
//    ב-inner גובר). ב-Dart: מפה שמתחילה ב-skey ואז addAll(inner) — סדר-דריסה זהה.
//  • הבנייה `{skey, ...inner}` יושבת בתוך ה-closure (op) כמו במקור — supKeyOf/docSkey/
//    doc/scopedCol נקראים בזמן-ביצוע-הצבר, ו-inner (עם await encryptDoc) נלכד מראש.
//  • batch.commit() מוחזר-Future ⇒ `await`; slice(i,i+400) ⇒ מעבר-אינדקסים תחום.

typedef RequireDb = dynamic Function();
typedef SupKeyMapOf = dynamic Function(List<dynamic> supporters);
typedef SupKeyOf = dynamic Function(dynamic sp);
typedef DocSkey = dynamic Function(String col, dynamic data, dynamic map);
typedef ToPlain = dynamic Function(dynamic x);
typedef EncryptDoc = dynamic Function(dynamic plain, dynamic dek);
typedef ScopedCol = String Function(String col);
typedef DocRef = dynamic Function(dynamic db, String colPath, dynamic id);
typedef WriteBatchFn = dynamic Function(dynamic db);

/// אובייקט-השקעים (חוק-1): כל השכנים של המקור מוזרקים דרך io.
class MigrateIo {
  final RequireDb requireDb;
  final SupKeyMapOf supKeyMapOf;
  final SupKeyOf supKeyOf;
  final DocSkey docSkey;
  final ToPlain toPlain;
  final EncryptDoc encryptDoc;
  final ScopedCol scopedCol;
  final DocRef doc;
  final WriteBatchFn writeBatch;
  const MigrateIo({
    required this.requireDb,
    required this.supKeyMapOf,
    required this.supKeyOf,
    required this.docSkey,
    required this.toPlain,
    required this.encryptDoc,
    required this.scopedCol,
    required this.doc,
    required this.writeBatch,
  });
}

bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// `{ skey: X, ...inner }` — skey מוצב ואז inner מורחב (מפתח-חופף ב-inner גובר).
Map<String, dynamic> _withSkey(Object? skey, dynamic inner) {
  final Map<String, dynamic> out = {'skey': skey};
  if (inner is Map) {
    inner.forEach((k, v) => out['$k'] = v);
  }
  return out;
}

/// Rewrite every supporter & calendar-event doc to the cloud with a plaintext
/// `skey` filter key (upsert by id): supporter ⇒ skey=supKeyOf(sp); event ⇒
/// skey=docSkey (linked supporter's key; unlinked=shared). With a `dek` the
/// inner payload is encrypted while skey stays plaintext. Writes in 400-doc
/// batches (WriteBatch limit). Returns supporters.length + events.length.
/// Verbatim behaviour of the JS source new/atoms/migrate-supporters-to-keyed.mjs.
Future<int> migrateSupportersToKeyed(
  List<dynamic> supporters,
  List<dynamic> events,
  dynamic dek,
  MigrateIo io,
) async {
  final db = io.requireDb();
  final map = io.supKeyMapOf(supporters);
  final ops = <void Function(dynamic)>[];

  for (final sp in supporters) {
    final inner =
        !_falsy(dek) ? await io.encryptDoc(io.toPlain(sp), dek) : io.toPlain(sp);
    ops.add((b) => b.set(
          io.doc(db, io.scopedCol('supporters'), sp['id']),
          _withSkey(io.supKeyOf(sp), inner),
        ));
  }

  // אירועי-הלוח: skey=מפתח-התומך-המקושר (אירוע כללי ⇒ משותף) — כדי ששם-תורם בלוח
  // לא ידלוף לעובדת אחרת. אירוע ללא-קישור נשאר גלוי לכולן (משותף).
  for (final ev in events) {
    final inner =
        !_falsy(dek) ? await io.encryptDoc(io.toPlain(ev), dek) : io.toPlain(ev);
    ops.add((b) => b.set(
          io.doc(db, io.scopedCol('events'), ev['id']),
          _withSkey(io.docSkey('events', ev, map), inner),
        ));
  }

  for (var i = 0; i < ops.length; i += 400) {
    final batch = io.writeBatch(db);
    final end = (i + 400 < ops.length) ? i + 400 : ops.length;
    for (var j = i; j < end; j++) {
      ops[j](batch);
    }
    await batch.commit();
  }

  return supporters.length + events.length;
}
