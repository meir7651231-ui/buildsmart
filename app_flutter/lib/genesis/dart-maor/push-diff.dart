// ⚛️ אטום-Dart (דרגת-חוזה) · pushDiff — דחיפת diff-הישויות לענן בצברי-≤400 +
//    כתיבת-meta בטוחה-למונים בעסקה נפרדת.
// מוצא: maor/src/lib/cloud.ts:422-457 → new/atoms/push-diff.mjs (חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS, לא-משופרת). השכנים (db · scopedCol · fs=doc/writeBatch ·
//        encryptDoc · pushMeta · sup=enforceOn/keyedCols/docSkey/stripAuditMeta)
//        הוזרקו כשקעים (חוק-1 — אפס import פנימי). toPlain הוטמע (עוזר-פרטי של המקור).
// טוהר: פונקציית top-level אסינכרונית, אפס import (רק dart-core/dart:math לא-נדרש).
//
// תפקיד: לכל set ⇒ b.set(doc(scopedCol(col), id), body); לכל delete ⇒ b.delete(doc(...)).
//        body = inner (תוכן-plain או מעטפת-encryptDoc כשיש dek); באוסף-נאכף (enforceOn +
//        col∈keyedCols) מוקדם לו `skey` plaintext ({skey, ...inner}). כתיבה בצברי-400
//        (מגבלת WriteBatch), commit לכל צבר. אח"כ meta נכתב בעסקה נפרדת בטוחה-למונים
//        (עם קילוף-לוג-ביקורת כשהאכיפה דלוקה). void — כל האפקט דרך השקעים.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • truthiness (כלל 7): JS `dek ?` / `diff.meta ?` / `if (meta)` — null/''/0/false falsy.
//    שוקע ל-`_falsy` מפורש (dek=מפתח/null, meta=מפה/חסר — נשמר ביט-זהה).
//  • null≠undefined (כלל 2): שדה-חסר במפה=null=undefined של JS; toPlain (=JSON round-trip)
//    מפיל שדות-undefined — כאן: מפתח-מפה בעל-ערך-null מושמט (מקביל להשמטת-undefined ע"י
//    JSON.stringify), ואיברי-מערך-null נשמרים (JSON.stringify ממיר undefined→null במערך).
//    ההעתקה-העמוקה מנתקת-הפניה (JSON.parse(JSON.stringify) של המקור).
//  • `{ skey: X, ...inner }`: skey מוצב ואז inner מורחב (מפתח-חופף ב-inner גובר) —
//    ב-Dart מפה שמתחילה ב-skey ואז addAll(inner). סדר-דריסה + סדר-מפתחות זהים.
//  • docSkey/body מחושבים בלולאת-ה-set (eager, כמו במקור — לא בתוך ה-closure); רק
//    doc/scopedCol/b.set נדחים לזמן-ביצוע-הצבר. inner (עם await encryptDoc) נלכד מראש.
//  • batch.commit() מוחזר-Future ⇒ `await`; slice(i,i+400) ⇒ מעבר-אינדקסים תחום.
//  • s.data הגולמי (לא-toPlain) מועבר ל-docSkey — כמו במקור (cloud.ts:433).

typedef ScopedCol = String Function(String col);
typedef DocRef = dynamic Function(dynamic db, String colPath, dynamic id);
typedef WriteBatchFn = dynamic Function(dynamic db);
typedef EncryptDoc = dynamic Function(dynamic plain, dynamic dek);
typedef PushMeta = dynamic Function(dynamic meta, dynamic dek);
typedef DocSkey = dynamic Function(String col, dynamic data, dynamic map);
typedef StripAuditMeta = dynamic Function(dynamic meta);

/// שקע-ה-Firestore (חוק-1): שתי המתודות של ערכת-ה-SDK — doc ו-writeBatch.
class PushDiffFs {
  final DocRef doc;
  final WriteBatchFn writeBatch;
  const PushDiffFs({required this.doc, required this.writeBatch});
}

/// שקע-אכיפת-הנתונים (dormant): כבוי ⇒ ביט-זהה למקור-לא-נאכף.
class SupEnforce {
  final bool enforceOn;
  final List<dynamic> keyedCols;
  final DocSkey? docSkey;
  final StripAuditMeta? stripAuditMeta;
  const SupEnforce({
    this.enforceOn = false,
    this.keyedCols = const [],
    this.docSkey,
    this.stripAuditMeta,
  });
}

/// `!x` של JS (null/''/0/false/NaN ⇒ falsy) — לתחום שקעי-האטום (dek/meta).
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

/// `JSON.parse(JSON.stringify(data))` — העתקה-עמוקה שמנתקת-הפניה ומפילה undefined.
/// במפה: מפתח בעל-ערך-null מושמט (=undefined של JS). במערך: null נשמר.
dynamic _toPlain(dynamic data) {
  if (data is Map) {
    final Map<String, dynamic> out = {};
    data.forEach((k, v) {
      if (v == null) return; // undefined-valued key ⇒ dropped by JSON.stringify
      out['$k'] = _toPlain(v);
    });
    return out;
  }
  if (data is List) {
    return [for (final e in data) e == null ? null : _toPlain(e)];
  }
  return data;
}

/// `{ skey: X, ...inner }` — skey ראשון, inner מורחב (מפתח-חופף ב-inner גובר).
Map<String, dynamic> _withSkey(Object? skey, dynamic inner) {
  final Map<String, dynamic> out = {'skey': skey};
  if (inner is Map) {
    inner.forEach((k, v) => out['$k'] = v);
  }
  return out;
}

/// Push the entity diff to the cloud in ≤400-op batches, then write meta in a
/// separate counter-safe transaction. Each set ⇒ b.set(doc(scopedCol(col), id),
/// body); each delete ⇒ b.delete(...). body = inner (plain payload, or the
/// encryptDoc envelope when a `dek` is present); in an enforced collection
/// (enforceOn && col∈keyedCols) a plaintext `skey` is prepended ({skey,...inner}).
/// Meta is stripped of its audit-log when enforcement is on. Verbatim behaviour
/// of the JS source new/atoms/push-diff.mjs.
Future<void> pushDiff(
  Map<dynamic, dynamic> diff,
  dynamic dek,
  Map<dynamic, dynamic> supKeyBySpId,
  dynamic db,
  ScopedCol scopedCol,
  PushDiffFs fs,
  EncryptDoc encryptDoc,
  PushMeta pushMeta, [
  SupEnforce sup = const SupEnforce(),
]) async {
  final ops = <void Function(dynamic)>[];

  final List<dynamic> sets = (diff['sets'] as List?) ?? const [];
  for (final s in sets) {
    final inner = !_falsy(dek)
        ? await encryptDoc(_toPlain(s['data']), dek)
        : _toPlain(s['data']);
    // אכיפת-נתונים (dormant): מסמך באוסף-נאכף נושא `skey` plaintext מחוץ למעטפה,
    // כדי ש-Rules ושאילתת-where יבחנו אותו גם בארגון-מוצפן. כבוי ⇒ ביט-זהה.
    final keyed = sup.enforceOn && sup.keyedCols.contains(s['col']);
    final body = keyed
        ? _withSkey(sup.docSkey!(s['col'], s['data'], supKeyBySpId), inner)
        : inner;
    ops.add((b) => b.set(fs.doc(db, scopedCol(s['col']), s['id']), body));
  }

  final List<dynamic> deletes = (diff['deletes'] as List?) ?? const [];
  for (final d in deletes) {
    ops.add((b) => b.delete(fs.doc(db, scopedCol(d['col']), d['id'])));
  }

  for (var i = 0; i < ops.length; i += 400) {
    final batch = fs.writeBatch(db);
    final end = (i + 400 < ops.length) ? i + 400 : ops.length;
    for (var j = i; j < end; j++) {
      ops[j](batch);
    }
    await batch.commit();
  }

  // מסמך ה-meta נכתב בעסקה נפרדת בטוחה-למונים (לא בכתיבת-האצווה העיוורת).
  // אכיפת-נתונים (משטח #3): הלוג נושא שמות-תורמים ורוכב על meta המשותף — כשהאכיפה
  // דלוקה מקלפים אותו (הלוג נשאר מקומי). כבוי ⇒ ביט-זהה (רוכב כרגיל).
  final meta = (sup.enforceOn && !_falsy(diff['meta']))
      ? sup.stripAuditMeta!(diff['meta'])
      : diff['meta'];
  if (!_falsy(meta)) await pushMeta(_toPlain(meta), dek);
}
