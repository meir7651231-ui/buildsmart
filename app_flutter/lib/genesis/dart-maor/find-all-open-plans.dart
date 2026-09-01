/// חוט · find-all-open-plans — כל החיובים-המתוכננים הפתוחים ב-DB (Dart≡JS).
/// חולץ כלשונו מ-maor/src/lib/plannedMatch.ts:71-106 דרך new/atoms/find-all-open-plans.mjs.
/// אטום-טהור, אפס-שקעים, אפס-import (dart-core בלבד). התנהגות זהה-לחלוטין למקור-ה-JS.
///
/// db = Map עם המפתחות supporters/enrollments/families/shopAssignments (כל אחד List של Map).
/// מחזיר List של Map עם המפתחות entityType/entityId/plan/name.

/// truthiness של JavaScript: false ל-null · false · 0 · NaN · '' — אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

List<dynamic> findAllOpenPlans(dynamic db) {
  final out = <dynamic>[];

  // supporters: sup.plannedCharges || []  (מערך-ריק נשאר מערך-ריק; חסר/null ⇒ [])
  for (final sup in (db['supporters'] as List)) {
    final pcRaw = sup['plannedCharges'];
    final plans = pcRaw is List ? pcRaw : const <dynamic>[];
    for (final pl in plans) {
      // pl.chargedRid || pl.cancelledAt  ⇒  דילוג אם אחד מהם truthy
      if (_truthy(pl['chargedRid']) || _truthy(pl['cancelledAt'])) continue;
      out.add({
        'entityType': 'supporter',
        'entityId': sup['id'],
        'plan': pl,
        'name': sup['name'],
      });
    }
  }

  // enrollments: !en.plannedCharges?.length  ⇒  דילוג אם אין מערך או שהוא ריק
  for (final en in (db['enrollments'] as List)) {
    final pcRaw = en['plannedCharges'];
    if (!(pcRaw is List && pcRaw.isNotEmpty)) continue;
    // שם: חבר-במשפחה של השיבוץ (לצורך התאמה מול name בעסקה)
    dynamic fam;
    for (final f in (db['families'] as List)) {
      final members = f['members'];
      if (members is List && members.any((m) => m['id'] == en['memberId'])) {
        fam = f;
        break;
      }
    }
    dynamic mem;
    if (fam != null) {
      final members = fam['members'];
      if (members is List) {
        for (final m in members) {
          if (m['id'] == en['memberId']) {
            mem = m;
            break;
          }
        }
      }
    }
    // ((mem?.first || '') + ' ' + (fam?.name || '')).trim()
    final memFirst = (mem != null && _truthy(mem['first'])) ? mem['first'] : '';
    final famName = (fam != null && _truthy(fam['name'])) ? fam['name'] : '';
    final nm = ('$memFirst $famName').trim();
    for (final pl in pcRaw) {
      if (_truthy(pl['chargedRid']) || _truthy(pl['cancelledAt'])) continue;
      out.add({
        'entityType': 'enrollment',
        'entityId': en['id'],
        'plan': pl,
        'name': nm,
      });
    }
  }

  // shopAssignments: !a.plannedCharges?.length  ⇒  דילוג אם אין מערך או שהוא ריק
  for (final a in (db['shopAssignments'] as List)) {
    final pcRaw = a['plannedCharges'];
    if (!(pcRaw is List && pcRaw.isNotEmpty)) continue;
    dynamic fam;
    for (final f in (db['families'] as List)) {
      if (f['id'] == a['famId']) {
        fam = f;
        break;
      }
    }
    final nm = (fam != null && _truthy(fam['name'])) ? fam['name'] : '';
    for (final pl in pcRaw) {
      if (_truthy(pl['chargedRid']) || _truthy(pl['cancelledAt'])) continue;
      out.add({
        'entityType': 'shopAssignment',
        'entityId': a['id'],
        'plan': pl,
        'name': nm,
      });
    }
  }

  return out;
}
