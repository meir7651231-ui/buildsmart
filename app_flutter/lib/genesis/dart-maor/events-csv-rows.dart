/// חוט · events-csv-rows — שורות ייצוא-CSV של האירועים (Dart).
/// חוזה: events-csv-rows.contract.md · שקעים: termOf, hebDateFull, evMeta
/// הומר מ-new/atoms/events-csv-rows.mjs — התנהגות זהה-לחלוטין (חוק-4).
/// אפס-import (dart-core בלבד).


// truthiness של JS: false/0/''/null/undefined/NaN הם falsy (כלל-המרה 7).
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}

String _fmtD(dynamic iso) {
  if (_falsy(iso)) return '';
  final parts = (iso as String).split('-');
  final y = parts[0];
  final m = parts[1];
  final d = parts[2];
  return '$d/$m/$y';
}

List<List<dynamic>> eventsCsvRows(dynamic db,
  dynamic config,
  dynamic termOf,
  dynamic hebDateFull,
  dynamic evMeta, Map<String, String> T2) {
  final Map<String, String> _priorityLabel = {
  'green': T2['k1']!,
  'orange': T2['k2']!,
  'red': T2['k3']!,
};
  dynamic T(String k, String fb) => _falsy(config) ? fb : termOf(config, k, fb);

  final rows = <List<dynamic>>[
    [
      T2['k4']!,
      T2['k5']!,
      T2['k6']!,
      T2['k7']!,
      T2['k8']!,
      T('entity.family', T2['k10']!),
      T2['k11']!,
      T2['k12']!,
      T2['k13']!,
    ],
  ];

  // מיון-יציב (כלל-המרה 1): decorate-sort עם אינדקס-מקורי כשובר-שוויון,
  // כי [...arr].sort ב-JS יציב אך List.sort של Dart אינו.
  final source = (db['events'] as List).toList();
  final indexed = <List<dynamic>>[];
  for (var i = 0; i < source.length; i++) {
    indexed.add([i, source[i]]);
  }
  indexed.sort((a, b) {
    final da = _falsy(a[1]['date']) ? '' : a[1]['date'] as String;
    final dbv = _falsy(b[1]['date']) ? '' : b[1]['date'] as String;
    final c = da.compareTo(dbv);
    if (c != 0) return c;
    return (a[0] as int).compareTo(b[0] as int);
  });
  final evs = indexed.map((e) => e[1]).toList();

  for (final ev in evs) {
    // customType || evMeta[type].label
    final ct = ev['customType'];
    final typeCell = _falsy(ct) ? evMeta[ev['type']]['label'] : ct;

    // families.find(f => f.id === famId)?.name || ''
    dynamic famName = '';
    for (final f in (db['families'] as List)) {
      if (f['id'] == ev['famId']) {
        famName = _falsy(f['name']) ? '' : f['name'];
        break;
      }
    }

    // PRIORITY_LABEL[priority] || priority
    final pl = _priorityLabel[ev['priority']];
    final priCell = _falsy(pl) ? ev['priority'] : pl;

    rows.add([
      ev['title'],
      typeCell,
      _falsy(ev['date']) ? '' : hebDateFull(ev['date']),
      _fmtD(ev['date']),
      _falsy(ev['time']) ? '' : ev['time'],
      famName,
      priCell,
      _falsy(ev['notes']) ? '' : ev['notes'],
      _falsy(ev['done']) ? T2['k15']! : T2['k14']!,
    ]);
  }
  return rows;
}
