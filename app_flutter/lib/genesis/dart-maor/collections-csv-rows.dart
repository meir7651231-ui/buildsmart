// ⚛️ אטום-Dart (דרגת-חוזה) · collectionsCsvRows — שורות-CSV של ריקוני קופות-הצדקה.
// מוצא: maor/src/components/tzedaka/lib.ts:281-301 · המקור: new/atoms/collections-csv-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS
//        (המקור קדוש). השכן termOf הוזרק כשקע (חוק-1/חוק-3 — אפס import פנימי).
//
// תפקיד: שקיפות מלאה — שורת-כותרת ואז שורה פר-ריקון (פר כל קופה), בסדר-הנתונים:
//        [date, שם-רכז, '#'+num, שם-משפחה, amount, שם-מבצע]; ישות-חסרה ⇒ ''.
// שקעים (חוק-1/חוק-3):
//   termOf(config, key, fallback) ⇒ המונח הארגוני. נקרא רק כש-config לא-null; אחרת ה-fallback.
// קלט: db (tzBoxes/tzCoordinators/tzCampaigns/families) · config? · השקע termOf.
// פלט: List<List<Object>> — כותרת + שורה פר-ריקון. תא-amount הוא num (לא מחרוזת), כמו במקור.
//
// הערות-המרה (מקור→Dart):
//   • `config ? termOf(...) : fb` (truthiness של אובייקט/undefined) ⇒ `config != null`
//     (חוק-7 של DART-PORTING: תנאי-מפורש; config הוא object|undefined ⇒ null-check מכסה).
//   • `coord?.name ?? ''` (optional-chaining + null-coalescing) ⇒ coord==null ? '' : (name ?? '').
//   • `c.campaignId ?` (truthiness) ⇒ _truthy(campId): מחרוזת-ריקה/null ⇒ falsy ⇒ אין lookup ⇒ ''.
//   • `.find(x => x.id === id)` ⇒ _findById: לולאה עם `==` (הראשון-שמתאים או null). כמו undefined.
//   • `'#' + b.num` ⇒ `'#${b['num']}'` — num→string (int 3 ⇒ '#3', זהה ל-JS).
//   • גישת-שדה JS (b.num/c.date/c.amount) ⇒ מפתחות-Map. תא-amount נשאר num (שומר טיפוס-פלט).
//   • מוטביליות: rows בלבד ממוטב (add). אין locale/פורמט/getMonth מיוחדים.

/// CSV rows for all charity-box collections — full transparency: one row per
/// recorded collection. Header first, then [date, coordName, '#'+num, famName,
/// amount, campaignName]; a missing entity ⇒ ''. Verbatim behaviour of the JS
/// source; the neighbour `termOf` is injected as a socket (Law 1/3).
List<List<Object>> collectionsCsvRows(
  Map<String, dynamic> db,
  Map<String, dynamic>? config,
  String Function(Map<String, dynamic> config, String key, String fallback) termOf,
 {required String Function(String) term}) {
  String t(String k, String fb) => config != null ? termOf(config, k, fb) : fb;

  final List<List<Object>> rows = [
    [term('taryk'), term('rkz'), term('kvph'), t('entity.family', term('mshpchh')), term('skvm'), term('mbtsa')],
  ];

  for (final b in (db['tzBoxes'] as List)) {
    final box = b as Map;
    final coord = _findById(db['tzCoordinators'] as List, box['coordinatorId']);
    final fam = _findById(db['families'] as List, box['famId']);
    for (final cc in (box['collections'] as List)) {
      final c = cc as Map;
      final campId = c['campaignId'];
      final camp =
          _truthy(campId) ? _findById(db['tzCampaigns'] as List, campId) : null;
      rows.add([
        c['date'] as Object,
        coord == null ? '' : ((coord['name'] ?? '') as Object),
        '#${box['num']}',
        fam == null ? '' : ((fam['name'] ?? '') as Object),
        c['amount'] as Object,
        camp == null ? '' : ((camp['name'] ?? '') as Object),
      ]);
    }
  }
  return rows;
}

/// Mirrors JS `list.find(x => x.id === id)` — first element whose 'id' == [id],
/// or null (JS undefined) when none matches.
Map? _findById(List list, Object? id) {
  for (final e in list) {
    if ((e as Map)['id'] == id) return e;
  }
  return null;
}

/// Mirrors JS truthiness for the `campaignId ?` guard: null / '' / 0 / false ⇒ falsy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
