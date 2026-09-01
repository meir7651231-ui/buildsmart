/// חוט · beneficiary-label — תווית מוטב לשיבוץ-חנות.
/// המרה נאמנה מ-new/atoms/beneficiary-label.mjs (חוק-4: המקור קדוש).
/// השכן termOf (מילון-מונחי-הארגון) מוזרק כשקע-פרמטר (חוק-1: אפס import פנימי).
/// db/a/config = מבני-נתונים דינמיים (Map); termOf נקרא רק כשיש config.
String beneficiaryLabel(
  Map<String, dynamic> db,
  Map<String, dynamic> a,
  Map<String, dynamic>? config,
  String Function(Map<String, dynamic> config, String key, String fallback) termOf,
 {required String Function(String) term}) {
  // T: config truthy ⇒ termOf, אחרת fallback (JS: config ? termOf(...) : fb).
  String t(String k, String fb) => config != null ? termOf(config, k, fb) : fb;

  // db.families.find(f => f.id === a.famId) ⇒ null אם לא נמצא.
  Map<String, dynamic>? fam;
  for (final f in (db['families'] as List)) {
    if ((f as Map)['id'] == a['famId']) {
      fam = f.cast<String, dynamic>();
      break;
    }
  }

  final famLabel = fam != null
      ? '${t('entity.familyOf', term('mshpcht'))} ${fam['name']}'
      : '${t('entity.family', term('mshpchh'))}${term('xi_la-ydvah')}';

  // !a.memberId (truthiness: undefined/'' ⇒ נסיגה) || !fam ⇒ החזרת התווית המשפחתית.
  final mid = a['memberId'];
  if (mid == null || (mid is String && mid.isEmpty) || fam == null) return famLabel;

  // fam.members.find(x => x.id === a.memberId).
  Map<String, dynamic>? m;
  for (final x in (fam['members'] as List)) {
    if ((x as Map)['id'] == mid) {
      m = x.cast<String, dynamic>();
      break;
    }
  }

  return m != null ? '$famLabel — ${m['first']}' : famLabel;
}
