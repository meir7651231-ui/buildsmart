// חוט · merge-families — מיזוג משפחות-כפולות אל "שומר" (אפס אובדן נתונים).
// המרה נאמנה מ-new/atoms/merge-families.mjs (חוק-4: המקור קדוש, התנהגות זהה-לחלוטין).
// השכנים normPhone + dedupById מוזרקים כשקעים (חוק-1 — אפס import פנימי).
// אפס-import (dart-core בלבד). המשפחה = Map<String, dynamic>, בדיוק כמו object ב-JS.
//
// הערות-המרה (לפי DART-PORTING-RULES):
//   • `(x || '').trim()` של JS ⇒ `((x as String?) ?? '').trim()` — null/undefined/'' כולם ⇒ ''.
//   • truthiness (fullSefach/loserNames) ⇒ תנאי-מפורש (isNotEmpty / == true), לא `if(x)`.
//   • `f.kidsHome ?? 0` ⇒ `(f['kidsHome'] as num?) ?? 0` — ?? תופס null בלבד, לא 0 (זהה ל-JS).
//   • `[...new Set(x)]` (שומר-סדר-הכנסה) ⇒ set-literal של Dart `{...x}` (LinkedHashSet, שומר-סדר).
//   • spread `{...keeper, key: v}` ⇒ `{...keeper, 'key': v}` — עדכון-מפתח-קיים שומר מיקום (זהה).
//   • sort של createdAt: מחרוזות-ISO אסקי ⇒ compareTo של Dart ≡ ברירת-מחדל של JS (UTF-16).

/// Merge duplicate families into a keeper (zero data loss), verbatim behavior of
/// new/atoms/merge-families.mjs. `normPhone`/`dedupById` are injected sockets.
Map<String, dynamic> mergeFamilies(
  Map<String, dynamic> keeper,
  List<Map<String, dynamic>> losers,
  String Function(String) normPhone,
  List<dynamic> Function(List<dynamic>) dedupById,
 {required String Function(String) term}) {
  final all = <Map<String, dynamic>>[keeper, ...losers];

  String firstNonEmpty(String? Function(Map<String, dynamic>) pick) {
    for (final f in all) {
      final v = (pick(f) ?? '').trim();
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  // `keeper.<key>?.trim() || firstNonEmpty(f => f.<key>)` — אותו key לשומר ול-pick.
  String keeperOr(String key) {
    final t = (keeper[key] as String?)?.trim();
    if (t != null && t.isNotEmpty) return t;
    return firstNonEmpty((f) => f[key] as String?);
  }

  int rank(String? s) => s == 'active' ? 2 : (s == 'pending' ? 1 : 0);

  // all.reduce(..., 'inactive') — status עולה לדרגה הגבוהה ביותר שנמצאה.
  String status = 'inactive';
  for (final f in all) {
    final s = f['status'] as String?;
    if (rank(s) > rank(status)) status = s!;
  }

  final keeperPhone = ((keeper['phone'] as String?) ?? '').trim();
  final phone = keeperPhone.isNotEmpty
      ? keeperPhone
      : firstNonEmpty((f) => f['phone'] as String?);
  final phoneNorm = normPhone(phone);

  String phone2 = ((keeper['phone2'] as String?) ?? '').trim();
  if (phone2.isEmpty) {
    for (final f in all) {
      for (final cand in [f['phone'] as String?, f['phone2'] as String?]) {
        final c = (cand ?? '').trim();
        if (c.isNotEmpty && normPhone(c) != phoneNorm) {
          phone2 = c;
          break;
        }
      }
      if (phone2.isNotEmpty) break;
    }
  }

  final members =
      dedupById([for (final f in all) ...((f['members'] as List?) ?? const [])]);
  final docs =
      dedupById([for (final f in all) ...((f['docs'] as List?) ?? const [])]);

  // createdAt = הקטן (מוקדם) מבין הלא-ריקים, אחרת של השומר.
  final createdList = <String>[
    for (final f in all)
      if ((f['createdAt'] as String?) != null &&
          (f['createdAt'] as String).isNotEmpty)
        f['createdAt'] as String
  ]..sort();
  final createdAt = createdList.isNotEmpty ? createdList[0] : keeper['createdAt'];

  final loserNames = losers
      .map((l) => l['name'] as String?)
      .where((v) => v != null && v.isNotEmpty)
      .join(', ');

  final notesParts = <String>[
    for (final f in all)
      if (((f['notes'] as String?) ?? '').trim().isNotEmpty)
        ((f['notes'] as String?) ?? '').trim()
  ];
  final baseNotes = {...notesParts}.join(' · ');
  final notes = loserNames.isNotEmpty
      ? ((baseNotes.isNotEmpty ? baseNotes + ' ' : '') + term('mvzg') + loserNames)
      : baseNotes;

  num maxNum(String key) {
    num m = 0;
    for (final f in all) {
      final v = (f[key] as num?) ?? 0;
      if (v > m) m = v;
    }
    return m;
  }

  return {
    ...keeper,
    'father': keeperOr('father'),
    'fatherId': keeperOr('fatherId'),
    'mother': keeperOr('mother'),
    'motherId': keeperOr('motherId'),
    'phone': phone,
    'phone2': phone2,
    'email': keeperOr('email'),
    'city': keeperOr('city'),
    'address': keeperOr('address'),
    'community': keeperOr('community'),
    'maritalStatus': keeperOr('maritalStatus'),
    'language': keeperOr('language'),
    'tzedaka': keeperOr('tzedaka'),
    'discount': keeperOr('discount'),
    'fullSefach': all.any((f) => f['fullSefach'] == true),
    'kidsHome': maxNum('kidsHome'),
    'kidsMarried': maxNum('kidsMarried'),
    'status': status,
    'members': members,
    'docs': docs,
    'createdAt': createdAt,
    'notes': notes,
  };
}
