// ⚛️ אטום-Dart (דרגת-חוזה) · buildCommands — בונה פקודות ⌘K לפי דגלי-ההקשר + כרטיס-לכל-תורם.
// מוצא: maor-system/src/components/supporters/commands.ts:50 · המקור: new/atoms/commands-build-commands.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        טהור, אפס-שקעים; העוזר `norm` מוטבע inline.
//
// הערות-המרה (JS→Dart):
//  • `norm = s.toLowerCase().replace(/\s+/g,' ').trim()` ⇒ `.toLowerCase().replaceAll(RegExp(r'\s+'),' ').trim()`
//    (הנתונים כאן ללא תווי-קצה-יוניקוד/İ/Σ ⇒ toLowerCase/trim הרגילים זהים-JS).
//  • `push(c) = out.push({...c, keywords: norm(c.label+' '+c.keywords)})` — spread+override:
//    ⇒ `Map<String,dynamic>.from(c)..['keywords'] = norm(...)` — 'keywords' כבר קיים במפתח ⇒
//    העדכון משמר את מיקומו (סדר-מפתחות זהה ל-JS).
//  • ctx = Map; `ctx.cockpitOn` ⇒ `ctx['cockpitOn'] == true` · `ctx.dedupCount > 0` ⇒ num-compare.
//  • `sp.name || 'ללא שם'` (falsy) ⇒ `(name==null||name=='') ? 'ללא שם' : name`.
//  • `(sp.name||'') + ' ' + (sp.phone||'')` ⇒ falsy-fallback ל-'' לכל אחד.

/// Builds the ⌘K command list from context flags + one card per supporter.
/// Pure (no sockets); `norm` is inlined. Verbatim port of
/// new/atoms/commands-build-commands.mjs (`buildCommands`).
List<Map<String, dynamic>> buildCommands(Map<String, dynamic> ctx, {required String Function(String) term}) {
  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  final out = <Map<String, dynamic>>[];
  void push(Map<String, dynamic> c) {
    out.add(Map<String, dynamic>.from(c)
      ..['keywords'] = norm('${c['label']} ${c['keywords']}'));
  }

  push({
    'id': 'cmd:add',
    'kind': 'add',
    'label': '${term('xi_hvspt')}${ctx['supporterTerm']}',
    'group': term('pavlh'),
    'keywords': term('hvsph-chdsh-chdshh-tvrm'),
  });
  if (ctx['cockpitOn'] == true) {
    push({
      'id': 'cmd:work',
      'kind': 'work',
      'label': term('chlvn-habvdh'),
      'group': term('nyvvt'),
      'keywords': term('kvkpyt-mshymvt-abvdh-hyvm'),
    });
    push({
      'id': 'cmd:data',
      'kind': 'data',
      'label': term('msk-hntvnym'),
      'group': term('nyvvt'),
      'keywords': term('tblh-ntvnym-rshymh-synvn'),
    });
  }
  if (ctx['importOn'] == true) {
    push({
      'id': 'cmd:import',
      'kind': 'import',
      'label': term('yybva-mkvbts'),
      'group': term('pavlh'),
      'keywords': term('yybva-kvbts'),
    });
  }
  if (ctx['customReportOn'] == true) {
    push({
      'id': 'cmd:customreport',
      'kind': 'customreport',
      'label': term('dvch-mvtam'),
      'group': term('pavlh'),
      'keywords': term('dvch-mvtam-yytsva-tvvch'),
    });
  }
  // ‏JS: `ctx.dedupCount > 0` — `undefined/null > 0` ⇒ false (לא זורק). ‏Dart נאמן:
  // `is num && > 0` (dedupCount = ‏.length ⇒ תמיד מספר או חסר; אין מסלול-מחרוזת).
  final dedupCount = ctx['dedupCount'];
  if (dedupCount is num && dedupCount > 0) {
    push({
      'id': 'cmd:dedup',
      'kind': 'dedup',
      'label': '${term('xi_aychvd-kpvlym')}${ctx['dedupCount']}',
      'group': term('pavlh'),
      'keywords': term('kpvlym-myzvg-aychvd'),
    });
  }
  if (ctx['paymentsOn'] == true) {
    push({
      'id': 'cmd:incoming',
      'kind': 'incoming',
      'label': term('tshlvmym-nknsym'),
      'group': term('pavlh'),
      'keywords': term('tshlvmym-nknsym-slykh'),
    });
    push({
      'id': 'cmd:nedarim',
      'kind': 'nedarim',
      'label': term('snkrvn-mndrym'),
      'group': term('pavlh'),
      'keywords': term('ndrym-snkrvn'),
    });
  }
  for (final sp in (ctx['supporters'] as List)) {
    final name = sp['name'];
    final phone = sp['phone'];
    push({
      'id': 'donor:${sp['id']}',
      'kind': 'openDonor',
      'arg': sp['id'],
      'label': (name == null || name == '') ? term('lla-shm') : name,
      'hint': term('ptycht-krtys'),
      'group': term('tvrm'),
      'keywords':
          '${(name == null || name == '') ? '' : name} ${(phone == null || phone == '') ? '' : phone}',
    });
  }
  return out;
}
